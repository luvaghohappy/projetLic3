<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json; charset=UTF-8");
include('conn.php');

$id = $_POST['id'] ?? null;

if ($id === null) {
    echo json_encode([
        "success" => false,
        "message" => "ID non fourni."
    ]);
    exit();
}

// Mettre à jour l'état
$sql = "UPDATE ambulance SET Etat='valide' WHERE id='$id'";

if ($conn->query($sql) === TRUE) {
    echo json_encode([
        "success" => true,
        "message" => "L'état a été mis à jour avec succès"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Erreur de mise à jour: " . $conn->error
    ]);
}

$conn->close();
?>
