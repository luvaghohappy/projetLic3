<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Récupération et échappement des valeurs POST
$nom = htmlspecialchars($_POST["nom"]);
$postnom = htmlspecialchars($_POST["postnom"]);
$prenom = htmlspecialchars($_POST["prenom"]);
$email = htmlspecialchars($_POST["email"]);
$password = htmlspecialchars($_POST["passwords"]);
$role = htmlspecialchars($_POST["roles"]);
$service = htmlspecialchars($_POST["services"]);

// Validation des champs requis
if (empty($nom) || empty($postnom) || empty($prenom) || empty($email) || empty($password) || empty($role) || empty($service)) {
    echo json_encode(array("status" => "failed", "error" => "All fields are required."));
    exit;
}

// Hash du mot de passe
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

$upload_dir = "uploads/"; // Chemin vers le dossier d'upload

// Créer le dossier d'upload si ce n'est pas déjà fait
if (!file_exists($upload_dir)) {
    mkdir($upload_dir, 0777, true);
}

$target_file = $upload_dir . basename($_FILES["profil"]["name"]);
$imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

// Vérification que le fichier est une image
$check = getimagesize($_FILES["profil"]["tmp_name"]);
if($check !== false) {
    if (move_uploaded_file($_FILES["profil"]["tmp_name"], $target_file)) {
        // Préparation et exécution de la requête SQL
        try {
            $stmt = $connect->prepare("INSERT INTO operateurs (nom, postnom, prenom, email, passwords, roles,services, profil) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("ssssssss", $nom, $postnom, $prenom, $email, $hashedPassword, $role,$service, $target_file);
            
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
