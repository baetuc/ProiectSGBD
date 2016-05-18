<?php
session_start();
$_SESSION['unde_cauta_carte'] = 'next';
$_SESSION['isbn_cauta_carte'] = null;
$inceput = '<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Carte random</title>
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
  $stmt = oci_parse($connection, 'BEGIN :carte := gestioneaza_carte.carte_random(:html); END;');
  if (!$stmt) {
      $error = oci_error($connection);  // For oci_parse errors pass the connection handle
      $_SESSION['mesaj_exceptie'] = $error['message'] ;
      $_SESSION['link_exceptie'] = 'pagina_principala.php';
      header('Location: ./eroare.php');
      exit;
  }
  oci_bind_by_name($stmt, ':carte', $carte, 32767);
  $hhtml = 1;
  oci_bind_by_name($stmt, ':html', $hhtml);
  $response = @oci_execute($stmt);
  if (!$response) {
      $error = oci_error($stmt);  // For oci_execute errors pass the statement handle
      $_SESSION['mesaj_exceptie'] = $error['message'];
      $_SESSION['link_exceptie'] = 'pagina_principala.php';
      header('Location: ./eroare.php');
      exit;
  }

  $pagina_finala = $inceput . '<div><a href = "pagina_principala.php"> Înapoi</a></div>' . '<h3> Carte aleasă random: </h3>';
  $pagina_finala = $pagina_finala . $carte . $final;
  echo $pagina_finala;
 ?>
