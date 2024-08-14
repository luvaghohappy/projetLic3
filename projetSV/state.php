<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header('Content-Type: application/json');

// Inclure le fichier de connexion à la base de données
include 'conn.php'; 

// Vérifier la connexion à la base de données
if (!$connect) {
    die(json_encode(['error' => 'Failed to connect to the database: ' . mysqli_connect_error()]));
}

// Obtenir l'année actuelle
$currentYear = date('Y');

// Requête SQL pour sélectionner les enregistrements de l'année actuelle
$query = "SELECT table_names, record_count, created_at 
          FROM states 
          WHERE YEAR(created_at) = '$currentYear'"; 

// Exécuter la requête SQL
$result = mysqli_query($connect, $query);

// Vérifier si la requête a échoué
if (!$result) {
    echo json_encode(['error' => 'Query failed: ' . mysqli_error($connect)]);
    exit();
}

// Vérifier s'il y a des enregistrements retournés
if (mysqli_num_rows($result) == 0) {
    echo json_encode(['message' => 'No records found for the current year']);
    exit();
}

// Initialiser un tableau pour stocker les données
$data = [];
while ($row = mysqli_fetch_assoc($result)) {
    // Convertir la date en objet DateTime pour obtenir le mois
    $date = new DateTime($row['created_at']);
    $month = $date->format('M'); // Format du mois en texte, par exemple 'Jan'

    // Conversion de record_count en entier
    $recordCount = (int)$row['record_count'];

    // Initialiser les données si c'est la première fois que la table est rencontrée
    if (!isset($data[$row['table_names']])) {
        $data[$row['table_names']] = [
            'table_names' => $row['table_names'],
            'record_count' => $recordCount,
            'monthly_data' => []
        ];
    }

    // Initialiser les données mensuelles si le mois n'existe pas encore
    if (!isset($data[$row['table_names']]['monthly_data'][$month])) {
        $data[$row['table_names']]['monthly_data'][$month] = 0;
    }

    // Ajouter le count des enregistrements pour le mois correspondant
    $data[$row['table_names']]['monthly_data'][$month] += $recordCount;
}

// Renvoi des données formatées en JSON
echo json_encode(array_values($data));

?>
