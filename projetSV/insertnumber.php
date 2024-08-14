<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Récupération et échappement des valeurs POST
$nom = htmlspecialchars($_POST["nom"]);
$postnom = htmlspecialchars($_POST["postnom"]);
$prenom = htmlspecialchars($_POST["prenom"]);
$numero1 = htmlspecialchars($_POST["numero1"]);
$numero2 = htmlspecialchars($_POST["numero2"]);

// Validation des champs requis
if (empty($nom) || empty($postnom) || empty($prenom) || empty($numero1) || empty($numero2)) {
    echo json_encode(array("status" => "failed", "error" => "Tous les champs sont requis."));
    exit;
}

// Vérification si l'utilisateur a déjà enregistré des numéros
$checkSql = "SELECT * FROM numero_urgence WHERE nom = '$nom' AND postnom = '$postnom' AND prenom = '$prenom'";
$result = mysqli_query($connect, $checkSql);

if (mysqli_num_rows($result) > 0) {
    // L'utilisateur a déjà enregistré des numéros
    echo json_encode(array("status" => "failed", "error" => "Vous avez déjà enregistré des numéros d'urgence."));
} else {
    // Insérer les nouveaux numéros
    $insertSql = "INSERT INTO numero_urgence (nom, postnom, prenom, numero1, numero2) VALUES ('$nom','$postnom','$prenom', '$numero1','$numero2')";

    if (mysqli_query($connect, $insertSql)) {
        echo json_encode(array("status" => "success"));
    } else {
        echo json_encode(array("status" => "failed", "error" => mysqli_error($connect)));
    }
}

$connect->close();
?>
