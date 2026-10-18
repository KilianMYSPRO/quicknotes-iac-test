# QuickNotes : code de départ

Mini-API de prise de notes (Python/Flask + PostgreSQL), fil rouge du module Infrastructure as Code.

- `app/app.py` : l'application (NE PAS MODIFIER sauf consigne)
- `app/requirements.txt` : dépendances Python
- `nginx/default.conf` : configuration du reverse proxy
- `.env.example` : modèle de variables d'environnement (copier en `.env`)
- `ansible/` : squelette du TP2 (rôles Ansible à compléter)
- `lab/` : lab local du TP2 (deux serveurs Ubuntu + poste de contrôle Ansible), voir `lab/README.md`
- `terraform/` : squelette du TP3 (réseau, VM et stockage sur Azure, à compléter) ; `terraform test` vérifie votre travail sans compte Azure
- `terraform-local/` : **plan B** du TP3 sans Azure (mêmes principes, des conteneurs Docker jouent le rôle des VM)
- `.github/workflows/ci.yml` : squelette du pipeline CI du TP5 (jour 3, TODO à compléter) ; `.github/dependabot.yml` : mises à jour automatiques
- `.yamllint`, `.trivyignore` : règles de yamllint et exceptions justifiées de trivy (TP5)
- `scripts/ci-local.sh` : lance les mêmes contrôles que la CI sur la VM, sans GitHub (`bash scripts/ci-local.sh`)
- `SECURITE.md` : modèle du plan de sécurisation (exercice 5) à compléter
- `k8s/` : manifestes Kubernetes du TP6 (`app.yaml` et `configmap.yaml` à compléter, `db.yaml` fourni comme modèle, `kind-config.yaml` pour le cluster local)

Endpoints :
- `GET /` : page d'accueil (affiche l'environnement et le serveur qui répond)
- `GET /health` : état de santé (200 si la base répond, 503 sinon)
- `GET /api/notes` : liste des notes
- `POST /api/notes` avec `{"content": "..."}` : ajoute une note

Configuration (variables d'environnement) : `APP_ENV`, `APP_VERSION`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `APP_PORT`.
