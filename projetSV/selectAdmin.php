<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST");
include('conn.php');

$response = array();

// Définir les identifiants d'administrateur directement dans le code
$admin_email = 'happy@viesauve.com';
$admin_password = 'admin1'; // Notez que ceci est en texte clair et non recommandé pour la production

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['email']) && isset($_POST['passwords'])) {
    $email = $_POST['email'];
    $password = $_POST['passwords'];

    // Vérifiez si les identifiants correspondent à ceux de l'administrateur
    if ($email === $admin_email && $password === $admin_password) {
        $response['success'] = true;
        $response['message'] = "Connexion réussie.";
    } else {
        $response['success'] = false;
        $response['message'] = "Identifiants incorrects.";
    }
} else {
    http_response_code(405);
    $response['success'] = false;
    $response['message'] = "Méthode non autorisée.";
}

echo json_encode($response);
?>
