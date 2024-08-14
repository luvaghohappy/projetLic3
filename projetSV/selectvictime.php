<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Récupérer les données des utilisateurs
$query = "SELECT userId, nom, postnom, prenom, sexe, Date_naissance, Adresse, Etat_civil, nombre_enfant, Etat_sanitaire, allergie, Taille, Poids, Numero, email, image_path FROM utilisateurs";
$result = $connect->query($query);

$utilisateurs = array();
while ($row = $result->fetch_assoc()) {
    $utilisateurs[] = $row;
}

echo json_encode($utilisateurs);

$connect->close();
?>
