<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Récupérer et échapper les valeurs POST
$nom = htmlspecialchars($_POST["nom"]);
$postnom = htmlspecialchars($_POST["postnom"]);
$prenom = htmlspecialchars($_POST["prenom"]);
$email = htmlspecialchars($_POST["email"]);

// Validation des champs requis
if (empty($nom) || empty($postnom) || empty($prenom) || empty($email)) {
    echo json_encode(array("status" => "failed", "error" => "All fields are required."));
    exit;
}

$upload_dir = "uploads/"; // Chemin vers le dossier d'upload

// Créer le dossier d'upload si ce n'est pas déjà fait
if (!file_exists($upload_dir)) {
    mkdir($upload_dir, 0777, true);
}

$target_file = $upload_dir . basename($_FILES["image"]["name"]);
$imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

// Vérification que le fichier est une image
$check = getimagesize($_FILES["image"]["tmp_name"]);
if($check !== false) {
    if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
        // Préparation et exécution de la requête SQL
        try {
            $stmt = $connect->prepare("INSERT INTO operateur (nom, postnom, prenom, email, image_path) VALUES (?, ?, ?, ?, ? )");
            $stmt->bind_param("sssss", $nom, $postnom, $prenom, $email, $target_file);
            
            $stmt->execute();
            echo json_encode(array("status" => "success", "image_path" => $target_file));
        } catch (Exception $e) {
            echo json_encode(array("status" => "failed", "error" => $e->getMessage()));
        }
    } else {
        echo json_encode(array("status" => "failed", "error" => "Sorry, there was an error uploading your file."));
    }
} else {
    echo json_encode(array("status" => "failed", "error" => "File is not an image."));
}

$connect->close();

?>
