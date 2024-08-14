<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

// Inclusion du fichier connect.php qui contient la connexion à la base de données
include('conn.php');

// Vérification de la méthode de la requête
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Récupération des données envoyées en POST
    $id = htmlspecialchars($_POST["id"]);

    // Requête SQL pour supprimer l'enregistrement de la table 'operateurs'
    $sql = "DELETE FROM operateurs WHERE userId = '$id'";
    
    // Exécution de la requête SQL
    if (mysqli_query($connect, $sql)) {
        // Affichage d'un message en cas de réussite de la suppression
        echo json_encode(['status' => 'success', 'message' => 'Suppression réussie']);
    } else {
        // Affichage d'un message d'erreur en cas d'échec de la suppression
        echo json_encode(['status' => 'error', 'message' => 'Erreur lors de la suppression : ' . $connect->error]);
    }
} else {
    // Méthode de requête non supportée
    http_response_code(405); // Method Not Allowed
}
?>
