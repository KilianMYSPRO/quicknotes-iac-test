#!/bin/sh
# Genere UNE fois la cle SSH du lab (partagee via le volume lab-ssh).
set -e
if [ ! -f /lab-ssh/id_ed25519 ]; then
  ssh-keygen -q -t ed25519 -N "" -C "lab-control" -f /lab-ssh/id_ed25519
fi
printf 'Host *\n  StrictHostKeyChecking accept-new\n  User student\n' > /lab-ssh/config
chmod 700 /lab-ssh
chmod 600 /lab-ssh/id_ed25519 /lab-ssh/config
echo "Cle SSH du lab prete."
