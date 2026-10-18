# Plan de sécurisation de l'infrastructure QuickNotes

> **Exercice 5 de la fiche module.** Complétez chaque section `✏️`. Les exemples en *italique* montrent le niveau de détail attendu : remplacez-les.
> **Règle d'or :** chaque mesure doit être **vérifiable**. Citez le fichier du dépôt, la commande ou le réglage GitHub/Azure qui la met en œuvre. « Utiliser des mots de passe forts » ne vaut rien ; « mot de passe généré par `openssl rand -hex 16`, stocké dans `vault.yml` chiffré » vaut des points.
> Longueur visée : 3 à 5 pages. Les tableaux suffisent : pas besoin de rédiger de longs paragraphes.

| | |
|---|---|
| **Auteur** | ✏️ |
| **Relecteur (revue croisée)** | ✏️ |
| **Version / date** | ✏️ |
| **Périmètre** | ✏️ *Dépôt GitHub, pipeline CI, image GHCR, environnements Azure dev/test, cluster Kubernetes* |
| **Hors périmètre** | ✏️ |

---

## 1. Inventaire et analyse des risques

### 1.1 Ce qu'on protège (actifs)

✏️ Listez au moins **6 actifs** : secrets, accès, données, code, image…

| Actif | Où se trouve-t-il ? | Sensibilité (faible / moyenne / élevée / critique) |
|---|---|---|
| *Mot de passe PostgreSQL* | *`ansible/inventories/dev/group_vars/all/vault.yml` (chiffré) ; Secret Kubernetes* | *Élevée* |
| ✏️ | | |

### 1.2 Menaces principales

✏️ Au moins **5 menaces**. Pensez à : fuite de secret, mauvaise configuration cloud, CVE dans une dépendance, action GitHub compromise, modification manuelle (dérive), attaque non détectée.

| # | Menace | Probabilité | Impact | Mesures (n° de section) |
|---|---|---|---|---|
| M1 | *Un secret est commité dans Git* | *Forte* | *Critique* | *2.1, 2.3* |
| M2 | ✏️ | | | |

---

## 2. Gestion des secrets

### 2.1 Règles

✏️ 3 à 5 règles que toute l'équipe doit suivre (que commite-t-on ou non ? un secret par environnement ? comment les générer ? quand les changer ?).

1. ✏️
2. ✏️

### 2.2 Où vit chaque secret

| Secret | Stockage | Qui y accède |
|---|---|---|
| *Mot de passe BDD (VM Azure)* | *Ansible Vault* | *Admins* |
| *Mot de passe Ansible Vault* | ✏️ | ✏️ |
| *Mot de passe BDD (Kubernetes)* | ✏️ | ✏️ |
| *Accès Azure depuis la CI* | ✏️ *(indice : OIDC)* | ✏️ |
| *Push d'image sur GHCR* | ✏️ *(indice : GITHUB_TOKEN)* | ✏️ |

✏️ **Limites connues** (au moins une) : *un Secret Kubernetes est-il chiffré ?*

### 2.3 Détection des fuites et procédure en cas de fuite

✏️ Quels outils détectent un secret, à quel moment (poste, push, CI) ? Sont-ils bloquants ?

✏️ **Procédure en cas de fuite**, en 4 étapes, dans l'ordre. Expliquez pourquoi supprimer le fichier ne suffit pas.

---

## 3. Conformité et configuration sécurisée

### 3.1 Règles de configuration

✏️ Au moins **8 règles**, réparties sur : réseau Azure, VM, stockage, image Docker, Kubernetes, pipeline.

| Domaine | Règle | Où c'est appliqué (fichier) |
|---|---|---|
| *Réseau Azure* | *SSH autorisé uniquement depuis l'IP de l'école* | *`terraform/network.tf`* |
| ✏️ | | |

### 3.2 Contrôle automatisé (policy as code)

| Outil | Ce qu'il contrôle | Job CI | Bloquant ? |
|---|---|---|---|
| *checkov* | ✏️ | ✏️ | ✏️ |
| ✏️ | | | |

✏️ **Gestion des exceptions** : comment justifiez-vous un finding accepté ? Citez **une exception réelle** de votre dépôt, avec sa justification.

### 3.3 Processus de changement

✏️ Comment une modification arrive-t-elle en production ? (branche, PR, checks, protection de branche, qui déploie, détection de dérive.)

### 3.4 Conteneurs et Kubernetes

✏️ 3 mesures minimum (images de confiance, securityContext, NetworkPolicy, RBAC, Pod Security…).

---

## 4. Mises à jour et correctifs de sécurité

| Couche | Comment c'est mis à jour | Fréquence | Responsable |
|---|---|---|---|
| *Dépendances Python* | *Dependabot ouvre une PR, la CI la teste* | *Hebdomadaire* | *Développeur* |
| *Image de base Docker* | ✏️ | ✏️ | ✏️ |
| *Actions GitHub* | ✏️ | | |
| *Providers Terraform* | ✏️ | | |
| *OS des VM Azure* | ✏️ *(indice : unattended-upgrades)* | | |
| *Cluster et images Kubernetes* | ✏️ | | |

✏️ **Seuil de blocage** du pipeline (quelle gravité de CVE bloque ? pourquoi `--ignore-unfixed` ?) et **délais de correction** par gravité.

---

## 5. Surveillance et détection des menaces

### 5.1 Ce qu'on journalise

| Source | Ce qu'on y voit | Outil / commande |
|---|---|---|
| *Activity Log Azure* | *Qui a créé, modifié ou supprimé quelle ressource* | *`az monitor activity-log list`* |
| ✏️ *(GitHub)* | | |
| ✏️ *(VM)* | | |
| ✏️ *(Kubernetes)* | | |

### 5.2 Alertes

✏️ Au moins **4 événements** qui doivent déclencher une alerte, avec l'outil qui les détecte et l'action prévue. Au moins un doit concerner une **menace** (et pas seulement une panne).

| Événement | Détection | Action |
|---|---|---|
| ✏️ | | |

### 5.3 Réponse à incident

✏️ Les grandes étapes. En quoi l'IaC aide-t-elle à reconstruire un serveur compromis ?

---

## 6. Plan d'action

✏️ Ce qui est **fait** dans votre dépôt, et ce qui reste **à faire**, par priorité.

| Priorité | Action | État (✅ fait / ⏳ à faire / 💡 envisagé) |
|---|---|---|
| 1 | ✏️ | |
