<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    include('conn.php');

    $data = json_decode(file_get_contents('php://input'), true);

    $nom = $data['nom'] ?? null;
    $postnom = $data['postnom'] ?? null;
    $prenom = $data['prenom'] ?? null;
    $sexe = $data['sexe'] ?? null;
    $latitude = $data['latitude'] ?? null;
    $longitude = $data['longitude'] ?? null;
    $type = $data['type'] ?? null;

    if ($nom && $postnom && $prenom && $sexe && $latitude && $longitude && $type) {
        $validTypes = ['police', 'ambulance', 'pompier'];
        if (!in_array($type, $validTypes)) {
            echo json_encode(['success' => false, 'message' => 'Type d\'urgence invalide']);
            exit();
        }

        $stmt = $connect->prepare("INSERT INTO $type (nom, postnom, prenom, sexe, locations) VALUES (?, ?, ?, ?, ST_GeomFromText(?))");

        $point = "POINT($longitude $latitude)";

        $stmt->bind_param("sssss", $nom, $postnom, $prenom, $sexe, $point);

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'id' => $stmt->insert_id]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Erreur lors de l\'insertion']);
        }

        $stmt->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'Données manquantes']);
    }
}
?>
