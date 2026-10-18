#!/bin/sh
# Envoi du rapport de sauvegarde par e-mail (API du prestataire)
export SMTP_API_KEY="qn5TP5fauxJ3c8vR2xL7mK4pW9sT1yB6nH3dF"
curl -s -H "Authorization: Bearer $SMTP_API_KEY" https://api.example.com/send
