<?php
  session_start();
$inceput = '<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Șterge subgen</title>
  </head>
  <body>';

  $final = '</body>
  </html>';

  $connection = oci_connect("STUDENT", "STUDENT", "localhost/XE");

  if (!$connection) {
      $error = oci_error();
      $_SESSION['mesaj_exceptie'] = 'Eroare la conectare la baza de date';
      $_SESSION['link_exceptie'] = 'pagina_principala.php';
      header('Location: ./eroare.php');
      exit;
  }
  $stmt = oci_parse($connection, 'BEGIN CRUD.sterge_subgen(:subgen, :mesaj); END;');
  if (!$stmt) {
      $error = oci_error($connection);  // For oci_parse errors pass the connection handle
      $_SESSION['mesaj_exceptie'] = $error['message'] ;
      $_SESSION['link_exceptie'] = 'pagina_principala.php';
      header('Location: ./eroare.php');
      exit;
  }
  oci_bind_by_name($stmt, ':subgen', $_GET['subgen']);
  oci_bind_by_name($stmt, ':mesaj', $mesaj, 32767);

  $response = @oci_execute($stmt);
  if (!$response) {
      $error = oci_error($stmt);  // For oci_execute errors pass the statement handle
      $_SESSION['mesaj_exceptie'] = $error['message'];
      $_SESSION['link_exceptie'] = 'pagina_principala.php';
      header('Location: ./eroare.php');
      exit;
  }

  $pagina_finala = $inceput . '<div><a href = "pagina_principala.php"> Înapoi</a></div>' . '<h3>' . $mesaj . '</h3>';
  $pagina_finala = $pagina_finala . $final;
  echo $pagina_finala;

 ?>
