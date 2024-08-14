<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

include('conn.php');

try {
    $rqt = "
        SELECT 
            id, 
            nom_post, 
            adresse 
        FROM postes 
        ORDER BY id DESC
    ";
    $rqt2 = mysqli_query($connect, $rqt);

    if (mysqli_num_rows($rqt2) > 0) {
        $result = array();
        while ($fetchData = $rqt2->fetch_assoc()) {
            $result[] = $fetchData;
        }
        echo json_encode($result);
    } else {
        echo json_encode([]);
    }
} catch (Exception $e) {
    echo json_encode(['error' => 'An error occurred while retrieving data']);
}
?>
