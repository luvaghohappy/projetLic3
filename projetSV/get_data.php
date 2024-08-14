<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include('conn.php');

$response = array();

// Fonction pour récupérer les données d'une table donnée
function getTableData($tableName) {
    global $connect;
    $stmt = $connect->prepare("SELECT id, nom, postnom, prenom, sexe, ST_AsText(locations) as locations, created_at FROM $tableName ORDER BY id DESC");
    $stmt->execute();
    $data = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    
    // Ajouter le champ 'service' pour indiquer la source des données
    foreach ($data as &$row) {
        $row['service'] = $tableName;
    }
    
    return $data;
}

try {
    // Fusionner les données des trois tables
    $response = array_merge(
        getTableData('ambulance'),
        getTableData('police'),
        getTableData('pompier')
    );

    // Retourner les données sous forme de JSON
    echo json_encode($response);

} catch (Exception $e) {
    // En cas d'erreur, retourner un message d'erreur
    echo json_encode(['error' => 'An error occurred while retrieving data']);
}
?>
