<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

// Inclusion du fichier de connexion à la base de données
include('conn.php');

// Récupérer les données envoyées depuis Flutter
$data = json_decode(file_get_contents('php://input'), true);

$nom = $data['nom'];
$adresse = $data['adresse'];

// Préparation de la requête SQL pour insérer un poste avec adresse
$sql = "INSERT INTO postes (nom_post, adresse) VALUES (?, ?)";
$stmt = $connect->prepare($sql);
$stmt->bind_param('ss', $nom, $adresse);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'id' => $stmt->insert_id]);
} else {
    echo json_encode(['success' => false, 'message' => $stmt->error]);
}

$stmt->close();
$connect->close();
?>
