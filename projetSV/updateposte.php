<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json; charset=UTF-8");
include('conn.php');

$nom_post = $_POST['nom_post'] ?? '';
$adresse = $_POST['adresse'] ?? '';
$id = $_POST['id'] ?? '';

if (empty($nom_post) || empty($adresse) || empty($id)) {
    echo json_encode(['success' => false, 'message' => 'Tous les champs sont requis']);
    exit;
}

$query = "UPDATE postes SET nom_post = ?, adresse = ? WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("ssi", $nom_post, $adresse, $id);

if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Erreur lors de la mise à jour']);
}

$stmt->close();
$conn->close();
?>
