<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

$userid = $_POST['Userid'];

// Supprimer l'utilisateur de la base de données
$query = "DELETE FROM utilisateurs WHERE Userid='$userid'";

if (mysqli_query($conn, $query)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "error" => mysqli_error($conn)]);
}

mysqli_close($conn);
?>
