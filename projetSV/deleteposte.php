<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

// Inclusion du fichier de connexion à la base de données
include('conn.php');

// Récupérer l'ID envoyé depuis Flutter
$data = $_POST['id'] ?? '';

if (empty($data)) {
    echo json_encode(['status' => 'error', 'message' => 'ID invalide']);
    exit;
}

$sql = "DELETE FROM postes WHERE id = ?";
$stmt = $connect->prepare($sql);
$stmt->bind_param('i', $data);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $stmt->error]);
}

$stmt->close();
$connect->close();
?>
