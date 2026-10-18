#!/usr/bin/env bash
# shellcheck disable=SC2329  # les fonctions sont appelees indirectement par etape()
# =============================================================================
#  ci-local.sh : les MEMES controles que .github/workflows/ci.yml, sur la VM,
#  sans GitHub (plan B si GitHub Actions est indisponible, ou avant un push).
#
#  Usage (a la racine du depot) :   bash scripts/ci-local.sh
#  Prerequis : Docker (les scanners tournent dans des conteneurs), terraform et
#              ansible-lint (deja sur la VM).
#  Code retour : 0 si tout est vert, 1 sinon (avec la liste des controles en echec).
#
#  Comme la CI, les scanners ne voient QUE les fichiers que Git enverrait :
#  fichiers suivis + nouveaux fichiers non ignores. .vault_pass, .env, .terraform/,
#  les etats Terraform (qui contiennent des secrets) et les inventaires generes
#  sont donc exclus, exactement comme sur GitHub.
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

# Images des outils : versions figees, comme dans la CI
GITLEAKS=ghcr.io/gitleaks/gitleaks:v8.30.1
TRIVY=aquasec/trivy:0.76.0
HADOLINT=ghcr.io/hadolint/hadolint:v2.15.1
KUBECONFORM=ghcr.io/yannh/kubeconform:v0.8.0
CHECKOV=bridgecrew/checkov:3.3.29

ECHECS=()
VERT=$'\e[32m'; ROUGE=$'\e[31m'; GRAS=$'\e[1m'; RAZ=$'\e[0m'

etape() {   # etape "nom" commande...
  local nom=$1; shift
  echo; echo "${GRAS}==> ${nom}${RAZ}"
  if "$@"; then echo "${VERT}OK${RAZ}  ${nom}"; else echo "${ROUGE}ECHEC${RAZ}  ${nom}"; ECHECS+=("$nom"); fi
}

# Instantane des fichiers vus par Git (suivis + nouveaux non ignores)
SNAP=$(mktemp -d)
trap 'rm -rf "$SNAP"' EXIT
git ls-files -z -co --exclude-standard \
  | tar --null --ignore-failed-read -T - -cf - 2>/dev/null | tar -xf - -C "$SNAP"

# Cache trivy (base de vulnerabilites) conserve entre deux lancements
CACHE="$HOME/.cache/trivy"; mkdir -p "$CACHE"
# Conteneur jetable, instantane monte en lecture seule, avec l'UID de l'utilisateur
outil() { docker run --rm -u "$(id -u):$(id -g)" -v "$SNAP:/src:ro" -w /src "$@"; }

# Meme liste d'exclusions checkov que la CI (TP5 : k8s/ exclu tant que le TP6 n'est pas fait)
SKIP=(--skip-path lab)
if grep -q -- '--skip-path k8s' .github/workflows/ci.yml 2>/dev/null; then SKIP+=(--skip-path k8s); fi

# ---------- 1. Lint ----------
lint_ansible() {
  [ -d ansible ] || return 0
  # Meme astuce que la CI : un mot de passe Vault factice suffit pour le lint
  local vp rc; vp=$(mktemp); echo "mot-de-passe-factice-ci" > "$vp"
  (cd ansible && ANSIBLE_VAULT_PASSWORD_FILE="$vp" ansible-lint -q); rc=$?
  rm -f "$vp"; return "$rc"
}
lint_terraform() {
  terraform fmt -check -recursive || return 1
  local d
  for d in terraform terraform-local; do
    [ -d "$d" ] || continue
    terraform -chdir="$d" init -backend=false -input=false >/dev/null || return 1
    terraform -chdir="$d" validate -no-color || return 1
    # Workspace "default" comme en CI (votre VM est sur dev ou test depuis le TP4)
    if [ -d "$d/tests" ]; then
      TF_WORKSPACE=default terraform -chdir="$d" test -no-color | tail -1 || return 1
    fi
  done
}
etape "ansible-lint"            lint_ansible
etape "terraform fmt/validate/test" lint_terraform
etape "hadolint app/Dockerfile" outil "$HADOLINT" hadolint app/Dockerfile
if [ -d k8s ]; then
  etape "kubeconform k8s/"      outil "$KUBECONFORM" -strict -summary -kubernetes-version 1.33.1 \
                                  -ignore-filename-pattern 'kind-config|kustomization' k8s/
fi

# ---------- 2. Securite ----------
# gitleaks lit l'historique Git : il a besoin du vrai depot (.git), pas de l'instantane
etape "gitleaks (tout l'historique)" docker run --rm -u "$(id -u):$(id -g)" -v "$PWD:/src:ro" \
                                  "$GITLEAKS" git /src --redact --no-banner
etape "checkov"                 outil "$CHECKOV" -d /src --framework terraform dockerfile kubernetes github_actions \
                                  "${SKIP[@]}" --compact --quiet
etape "trivy fs (CRITICAL)"     outil -v "$CACHE:/cache" -e TRIVY_CACHE_DIR=/cache "$TRIVY" fs /src \
                                  --scanners misconfig,vuln,secret --severity CRITICAL --skip-dirs /src/lab \
                                  --ignore-unfixed --exit-code 1 --quiet

# ---------- 3. Build + scan ----------
build_et_scan() {
  docker build -q -t quicknotes:ci-local "$SNAP/app" >/dev/null || return 1
  docker run --rm -u "$(id -u):$(id -g)" --group-add "$(stat -c %g /var/run/docker.sock)" \
    -v /var/run/docker.sock:/var/run/docker.sock -v "$CACHE:/cache" -e TRIVY_CACHE_DIR=/cache "$TRIVY" \
    image --quiet --severity CRITICAL --ignore-unfixed --exit-code 1 --format table --table-mode summary \
    quicknotes:ci-local 2>&1 | tail -4
  return "${PIPESTATUS[0]}"
}
etape "docker build + trivy image" build_et_scan

echo
if [ ${#ECHECS[@]} -eq 0 ]; then
  echo "${VERT}${GRAS}Tous les controles sont verts.${RAZ}"; exit 0
else
  echo "${ROUGE}${GRAS}${#ECHECS[@]} controle(s) en echec :${RAZ}"; printf '  - %s\n' "${ECHECS[@]}"; exit 1
fi
