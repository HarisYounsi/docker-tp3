-- Créer la base de données si elle n'existe pas
CREATE DATABASE IF NOT EXISTS testdb;
USE testdb;

-- Créer la table counter
CREATE TABLE IF NOT EXISTS counter (
    id INT PRIMARY KEY AUTO_INCREMENT,
    count INT NOT NULL DEFAULT 0
);

-- Insérer une valeur initiale
INSERT INTO counter (id, count) VALUES (1, 0) ON DUPLICATE KEY UPDATE count = count;