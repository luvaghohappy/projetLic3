<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST");
include('conn.php');

$response = array();

// Traitement de la connexion
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['email']) && isset($_POST['passwords'])) {
    // Récupérer les données de l'utilisateur
    $email = $_POST['email'];
    $password = $_POST['passwords'];

    // Requête SQL pour vérifier les informations d'identification dans la table "users"
    $query = "SELECT passwords, services FROM operateurs WHERE email = ?";
    $statement = mysqli_prepare($connect, $query);
    if ($statement) {
        mysqli_stmt_bind_param($statement, 's', $email);
        mysqli_stmt_execute($statement);
        mysqli_stmt_store_result($statement);

        // Vérifier si l'utilisateur existe
        if (mysqli_stmt_num_rows($statement) > 0) {
            // Récupérer le mot de passe haché et le service
            mysqli_stmt_bind_result($statement, $hashed_password, $service);
            mysqli_stmt_fetch($statement);

            // Vérifier si le mot de passe correspond
            if (password_verify($password, $hashed_password)) {
                // Enregistrement de la date et de l'heure de la connexion dans la table "historique_travail"
                $currentDateTime = date('Y-m-d H:i:s');
                $insert_query = "INSERT INTO historique_travail (Email, Heure_Entree) VALUES (?, ?)";
                $insert_statement = mysqli_prepare($connect, $insert_query);
                if ($insert_statement) {
                    mysqli_stmt_bind_param($insert_statement, 'ss', $email, $currentDateTime);
                    mysqli_stmt_execute($insert_statement);
                }

                // Utilisateur authentifié avec succès
                $response['success'] = true;
                $response['message'] = "Connexion réussie.";
                $response['service'] = $service;
            } else {
                // Mot de passe incorrect
                $response['success'] = false;
                $response['message'] = "Identifiants incorrects.";
            }
        } else {
            // Utilisateur non trouvé
            $response['success'] = false;
            $response['message'] = "Identifiants incorrects.";
        }
    } else {
        // Erreur de préparation de la requête
        $response['success'] = false;
        $response['message'] = "Erreur de préparation de la requête.";
    }

    // Renvoyer la réponse au format JSON à l'application Flutter
    echo json_encode($response);
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['email'])) {
    // Traitement de la déconnexion
    // Récupérer l'email de l'utilisateur
    $email = $_POST['email'];

    // Enregistrement de la date et de l'heure de la déconnexion dans la table "historique_travail"
    $currentDateTime = date('Y-m-d H:i:s');
    $update_query = "UPDATE historique_travail SET Heure_Sortie = ? WHERE Email = ? AND Heure_Sortie IS NULL";
    $update_statement = mysqli_prepare($connect, $update_query);
    if ($update_statement) {
        mysqli_stmt_bind_param($update_statement, 'ss', $currentDateTime, $email);
        mysqli_stmt_execute($update_statement);
    }
} else {
    // Méthode non autorisée
    http_response_code(405);
    echo json_encode(array("message" => "Méthode non autorisée."));
}
?>
