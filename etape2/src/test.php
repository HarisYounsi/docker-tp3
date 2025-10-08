<?php
// Configuration de la connexion à la base de données
$host = 'DATA';
$dbname = 'testdb';
$username = 'root';
$password = 'rootpassword';

try {
    // Connexion à la base de données
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // UPDATE : Incrémenter le compteur
    $stmt = $pdo->prepare("UPDATE counter SET count = count + 1 WHERE id = 1");
    $stmt->execute();
    
    // READ : Lire le compteur mis à jour
    $stmt = $pdo->query("SELECT count FROM counter WHERE id = 1");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $count = $row ? $row['count'] : 0;
    
    echo "<h1>Count updated</h1>";
    echo "<h2>Count : " . htmlspecialchars($count) . "</h2>";
    
} catch (PDOException $e) {
    echo "<h1>Erreur de connexion</h1>";
    echo "<p>Message : " . htmlspecialchars($e->getMessage()) . "</p>";
}
?>