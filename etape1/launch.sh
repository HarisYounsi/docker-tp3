#!/bin/bash

# Arrêter et supprimer les containers existants si présents
echo "Nettoyage des containers existants..."
docker stop HTTP script 2>/dev/null
docker rm HTTP script 2>/dev/null

# Créer un réseau pour permettre la communication entre les containers
echo "Création du réseau Docker..."
docker network create tp3-network 2>/dev/null || true

# Récupérer le chemin absolu du répertoire courant
CURRENT_DIR=$(pwd)

# Lancer le container PHP-FPM
echo "Lancement du container SCRIPT (PHP-FPM)..."
docker run -d \
  --name SCRIPT \
  --network tp3-network \
  -v "${CURRENT_DIR}/src:/app" \
  php:8.2-fpm

# Lancer le container NGINX
echo "Lancement du container HTTP (NGINX)..."
docker run -d \
  --name HTTP \
  --network tp3-network \
  -p 8080:80 \
  -v "${CURRENT_DIR}/src:/app" \
  -v "${CURRENT_DIR}/config/default.conf:/etc/nginx/conf.d/default.conf" \
  nginx:latest

# Attendre que les containers démarrent
sleep 2

# Recharger la configuration NGINX
echo "Rechargement de la configuration NGINX..."
docker exec HTTP nginx -s reload 2>/dev/null || true

echo ""
echo "✓ Containers lancés avec succès !"
echo "Accédez à l'application sur : http://localhost:8080"
echo ""
echo "Pour voir les logs :"
echo "  docker logs HTTP"
echo "  docker logs SCRIPT"
echo ""
echo "Pour arrêter les containers :"
echo "  docker stop HTTP SCRIPT"
echo ""