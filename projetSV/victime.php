<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Récupérer et échapper les valeurs POST
$nom = htmlspecialchars($_POST["nom"]);
$postnom = htmlspecialchars($_POST["postnom"]);
$prenom = htmlspecialchars($_POST["prenom"]);
$sexe = htmlspecialchars($_POST["sexe"]);
$Date_naissance = htmlspecialchars($_POST["Date_naissance"]);
$Adresse = htmlspecialchars($_POST["Adresse"]);
$Etat_civil = htmlspecialchars($_POST["Etat_civil"]);
$nombre_enfant = $Etat_civil === 'Marié(e)' && isset($_POST["nombre_enfant"]) ? htmlspecialchars($_POST["nombre_enfant"]) : null;
$Etat_sanitaire = htmlspecialchars($_POST["Etat_sanitaire"]);
$allergie = htmlspecialchars($_POST["allergie"]);
$Taille = htmlspecialchars($_POST["Taille"]);
$Poids = htmlspecialchars($_POST["Poids"]);
$Numero = htmlspecialchars($_POST["Numero"]);
$email = htmlspecialchars($_POST["email"]);
$mot_de_passe = htmlspecialchars($_POST["mot_de_passe"]);
$conf_passe = htmlspecialchars($_POST["conf_passe"]);

// Validation des champs requis
if (empty($nom) || empty($postnom) || empty($prenom) || empty($sexe) || empty($Date_naissance) || empty($Adresse) || empty($Etat_civil) || ($Etat_civil === 'Marié(e)' && empty($nombre_enfant)) || empty($Etat_sanitaire) || empty($allergie) || empty($Taille) || empty($Poids) || empty($Numero) || empty($email) || empty($mot_de_passe) || empty($conf_passe)) {
    echo json_encode(array("status" => "failed", "error" => "All fields are required."));
    exit;
}

// Vérification des mots de passe
if ($mot_de_passe !== $conf_passe) {
    echo json_encode(array("status" => "failed", "error" => "Passwords do not match."));
    exit;
}

// Hachage du mot de passe
$hashed_password = password_hash($mot_de_passe, PASSWORD_DEFAULT);

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
            $stmt = $connect->prepare("INSERT INTO utilisateurs (nom, postnom, prenom, sexe, Date_naissance, Adresse, Etat_civil, nombre_enfant, Etat_sanitaire, allergie, Taille, Poids, Numero, email, mot_de_passe, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("ssssssssssssssss", $nom, $postnom, $prenom, $sexe, $Date_naissance, $Adresse, $Etat_civil, $nombre_enfant, $Etat_sanitaire, $allergie, $Taille, $Poids, $Numero, $email, $hashed_password, $target_file);
            
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
