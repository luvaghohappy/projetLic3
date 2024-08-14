<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

// Inclusion du fichier connect.php qui contient la connexion à la base de données
include('conn.php');

// Requête SQL pour sélectionner toutes les lignes de la table 'pompier' et convertir les colonnes 'locations' en texte
$rqt = "SELECT id, nom, postnom, prenom, sexe, ST_AsText(locations) as locations, created_at FROM police ORDER BY id DESC";

// Exécution de la requête SQL
$rqt2 = mysqli_query($connect, $rqt) OR die("Erreur d'exécution de la requête : " . mysqli_error($connect));

// Initialisation d'un tableau pour stocker les résultats de la requête
$result = array();

// Parcours des résultats de la requête et stockage dans le tableau $result
while ($fetchData = $rqt2->fetch_assoc()) {
    $result[] = $fetchData;
}

// Conversion du tableau en format JSON et affichage
echo json_encode($result);
?>
