#!/bin/sh
# Installe la cle publique du poste de controle, puis demarre systemd (PID 1).
cp /lab-ssh/id_ed25519.pub /home/student/.ssh/authorized_keys
chown student:student /home/student/.ssh/authorized_keys
chmod 600 /home/student/.ssh/authorized_keys
exec /sbin/init
