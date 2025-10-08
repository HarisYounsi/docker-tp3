FROM php:8.2-fpm

# Installer l'extension mysqli et pdo_mysql
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Activer les extensions
RUN docker-php-ext-enable mysqli pdo_mysql