<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

include('conn.php');

// Récupération des paramètres
$tableNames = $_GET['table_names'] ?? '';
$services = $_GET['services'] ?? '';

// Liste des valeurs valides
$validValues = ['pompier', 'police', 'ambulance'];

// Vérification des paramètres
if (in_array($tableNames, $validValues) && in_array($services, $validValues)) {
    // Préparation de la requête pour obtenir le nombre d'enregistrements pour le service spécifié
    $stmt = $connect->prepare("
        SELECT record_count
        FROM states
        WHERE table_names = ? AND EXISTS (
            SELECT 1 FROM operateurs WHERE services = ?
        )
    ");

    if ($stmt === false) {
        echo json_encode(array("success" => false, "error" => 'Erreur de préparation de la requête : ' . htmlspecialchars($connect->error)));
        exit();
    }

    $stmt->bind_param("ss", $tableNames, $services);

    if (!$stmt->execute()) {
        echo json_encode(array("success" => false, "error" => 'Erreur d\'exécution de la requête : ' . htmlspecialchars($stmt->error)));
        exit();
    }

    $result = $stmt->get_result();

    if ($result === false) {
        echo json_encode(array("success" => false, "error" => 'Erreur lors de la récupération du résultat : ' . htmlspecialchars($stmt->error)));
        exit();
    }

    $data = $result->fetch_assoc();

    $stmt->close();
    $connect->close();

    if ($data) {
        echo json_encode(array("success" => true, "record_count" => $data['record_count']));
    } else {
        echo json_encode(array("success" => false, "error" => "Aucun enregistrement trouvé pour les valeurs spécifiées."));
    }
} else {
    echo json_encode(array("success" => false, "error" => "Paramètres invalides. Valeurs acceptées pour table_names et services : 'pompier', 'police', 'ambulance'."));
}
?>
