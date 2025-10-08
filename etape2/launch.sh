#!/bin/bash

# Arrêter et supprimer les containers existants
echo "Nettoyage des containers existants..."
docker stop HTTP script DATA 2>/dev/null
docker rm HTTP script DATA 2>/dev/null

# Créer un réseau
echo "Création du réseau Docker..."
docker network create tp3-network 2>/dev/null || true

# Mot de passe root pour MariaDB
MARIADB_PASSWORD="rootpassword"

# 1. Lancer le container MariaDB
echo "Lancement du container DATA (MariaDB)..."
docker run -d \
  --name DATA \
  --network tp3-network \
  -e MARIADB_ROOT_PASSWORD=${MARIADB_PASSWORD} \
  -e MARIADB_DATABASE=testdb \
  mariadb:latest

# Attendre que MariaDB soit prêt
echo "Attente du démarrage de MariaDB..."
sleep 10

# Copier le fichier SQL dans le container et l'exécuter
echo "Initialisation de la base de données..."
docker cp sql/create.sql DATA:/tmp/create.sql
docker exec DATA sh -c "mysql -uroot -p${MARIADB_PASSWORD} < /tmp/create.sql"

# 2. Builder l'image PHP personnalisée avec mysqli
echo "Construction de l'image PHP avec mysqli..."
docker build -t php-mysqli:custom .

# 3. Lancer le container PHP-FPM
echo "Lancement du container script (PHP-FPM)..."
docker run -d \
  --name script \
  --network tp3-network \
  -e MARIADB_ROOT_PASSWORD=${MARIADB_PASSWORD} \
  php-mysqli:custom

# Attendre que PHP démarre
sleep 2

# Copier les fichiers PHP dans le container
echo "Copie des fichiers PHP..."
docker exec script mkdir -p /app
docker cp src/. script:/app/

# 4. Lancer le container NGINX
echo "Lancement du container HTTP (NGINX)..."
docker run -d \
  --name HTTP \
  --network tp3-network \
  -p 8080:80 \
  nginx:latest

# Attendre que NGINX démarre
sleep 2

# Copier les fichiers dans NGINX
echo "Copie des fichiers dans NGINX..."
docker exec HTTP mkdir -p /app
docker cp src/. HTTP:/app/

# Copier la configuration NGINX
echo "Configuration de NGINX..."
docker cp config/default.conf HTTP:/etc/nginx/conf.d/default.conf

# Recharger NGINX
docker exec HTTP nginx -s reload

echo ""
echo "✓ Containers lancés avec succès !"
echo ""
echo "Accédez aux pages :"
echo "  - http://localhost:8080/index.php  (phpinfo)"
echo "  - http://localhost:8080/test.php   (test base de données)"
echo ""
echo "Pour voir les logs :"
echo "  docker logs HTTP"
echo "  docker logs script"
echo "  docker logs DATA"
echo ""
echo "Pour arrêter les containers :"
echo "  docker stop HTTP script DATA"
echo ""