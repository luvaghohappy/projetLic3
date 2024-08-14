<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Retrieve user data from POST request
$userid = $_POST['Userid'];
$nom = $_POST['nom'];
$postnom = $_POST['postnom'];
$prenom = $_POST['prenom'];
$sexe = $_POST['sexe'];
$date_naissance = $_POST['Date_naissance'];
$adresse = $_POST['Adresse'];
$etat_civil = $_POST['Etat_civil'];
$etat_sanitaire = $_POST['Etat_sanitaire'];
$allergie = $_POST['allergie'];
$taille = $_POST['Taille'];
$poids = $_POST['Poids'];
$numero = $_POST['Numero'];
$email = $_POST['email'];

// Check if 'nombre_enfant' should be updated
if ($etat_civil == 'Marié(e)') {
    $nombre_enfant = $_POST['nombre_enfant'];
    $query = "UPDATE utilisateurs SET nom='$nom', postnom='$postnom', prenom='$prenom', sexe='$sexe', 
    Date_naissance='$date_naissance', Adresse='$adresse', Etat_civil='$etat_civil', 
    nombre_enfant='$nombre_enfant', Etat_sanitaire='$etat_sanitaire', allergie='$allergie', 
    Taille='$taille', Poids='$poids', Numero='$numero', email='$email' WHERE Userid='$userid'";
} else {
    // Exclude 'nombre_enfant' from the update query if not 'mariee'
    $query = "UPDATE utilisateurs SET nom='$nom', postnom='$postnom', prenom='$prenom', sexe='$sexe', 
    Date_naissance='$date_naissance', Adresse='$adresse', Etat_civil='$etat_civil', 
    Etat_sanitaire='$etat_sanitaire', allergie='$allergie', Taille='$taille', Poids='$poids', 
    Numero='$numero', email='$email' WHERE Userid='$userid'";
}

// Execute the query
if (mysqli_query($conn, $query)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "error" => mysqli_error($conn)]);
}

mysqli_close($conn);
?>
