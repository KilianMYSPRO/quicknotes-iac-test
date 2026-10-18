# Lab du jour 1

Deux « serveurs » Ubuntu 24.04 (`web1`, `db1`) et un poste de contrôle Ansible (`lab-control`), tous en conteneurs.
Il tourne dans votre poste de travail (VM), avec Docker.

```bash
cd ~/quicknotes-iac/lab
docker compose up -d --build          # 1re fois : 3 à 5 min (téléchargements)
docker exec -it lab-control bash      # terminal de contrôle
```

Dans `lab-control` :

```bash
cd /work/ansible
ansible all -m ping
ssh web1 hostname
```

- Vos fichiers sont dans `/work` : éditez-les avec VS Code, ils sont partagés.
- Le site déployé sur `web1` : `http://<IP de votre VM>:8081`
- Serveurs neufs (tout effacer) : `docker compose down -v` puis `docker compose up -d`
