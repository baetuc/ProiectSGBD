<?php
  session_start();
  $_SESSION['unde_cauta_carte'] = 'next';
  $_SESSION['isbn_cauta_carte'] = null;
  $inceput = '<!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <title>Pagina principală</title>
    </head>
    <body>';
  $linkuri =
      '<div><a href="cauta_carte.html"> Caută cărți după titlu </a></div>
      <div><a href="cauta_autor.html"> Caută cărți după autor </a></div>
      <div><a href ="carte_random.php"> Generează o carte random </a></div>
      <div><a href="recomandare.php"> Cere o recomandare</a></div>
      <div><a href="rate.html"> Notează o carte </a></div>
      <div><a href="insereaza_carte.html"> Inserează o carte </a></div>
      <div><a href="insereaza_autor.html"> Inserează un autor </a></div>
      <div><a href="insereaza_opera.html"> Inserează o operă </a></div>
      <div><a href="insereaza_subgen.html"> Inserează un subgen </a></div>
      <div><a href="sterge_carte.html"> Șterge o carte </a></div>
      <div><a href="sterge_autor.html"> Șterge un autor </a></div>
      <div><a href="sterge_opera.html"> Șterge o operă </a></div>
      <div><a href="sterge_subgen.html"> Șterge un subgen </a></div>
    ';
  $final = '</body>
  </html>';
  // Citat random

  $connection = oci_connect("STUDENT", "STUDENT", "localhost/XE");

  if (!$connection) {
      $error = oci_error();
      $_SESSION['mesaj_exceptie'] = 'Eroare la conectare la baza de date';
      $_SESSION['link_exceptie'] = 'pagina_principala.php';
      header('Location: ./eroare.php');
      exit;
  }
  $stmt = oci_parse($connection, 'BEGIN logica_aplicatiei.citat_random(:citat, :autor); END;');
  if (!$stmt) {
      $error = oci_error($connection);  // For oci_parse errors pass the connection handle
      $_SESSION['mesaj_exceptie'] = $error['message'] ;
      $_SESSION['link_exceptie'] = 'pagina_principala.php';
      header('Location: ./eroare.php');
      exit;
  }
  oci_bind_by_name($stmt, ':citat', $citat, 32767);
  oci_bind_by_name($stmt, ':autor', $autor, 32767);
  $response = @oci_execute($stmt);
  if (!$response) {
      $error = oci_error($stmt);  // For oci_execute errors pass the statement handle
      $_SESSION['mesaj_exceptie'] = $error['message'];
      $_SESSION['link_exceptie'] = 'pagina_principala.php';
      header('Location: ./eroare.php');
      exit;
  }

  $statement = 'BEGIN :carti := paginare.paginare_carti_';
  if ($_SESSION['next_principala'] == true) {
    $statement = $statement . 'next';
  } else {
    $statement = $statement . 'back';
  }
  $statement = $statement . '(:rating_vechi, :ISBN_vechi, :html, :rating_nou, :ISBN_nou); END;';
  $stmt = oci_parse($connection, $statement);
    if (!$stmt) {
        $error = oci_error($connection);  // For oci_parse errors pass the connection handle
        $_SESSION['mesaj_exceptie'] = $error['message'];
        $_SESSION['link_exceptie'] = 'pagina_principala.php';
        header('Location: ./eroare.php');
        exit;
    }
    oci_bind_by_name($stmt, ':carti', $carti, 32767);
    oci_bind_by_name($stmt, ':rating_vechi', $_SESSION['rate_maxim']);
    oci_bind_by_name($stmt, ':ISBN_vechi', $_SESSION['ISBN_maxim']);
    $hhtml = 1;
    oci_bind_by_name($stmt, ':html', $hhtml);
    oci_bind_by_name($stmt, ':rating_nou', $rating, 100);
    oci_bind_by_name($stmt, ':ISBN_nou', $ISBN, 100);

    $response = @oci_execute($stmt);
    if (!$response) {
        $error = oci_error($stmt);  // For oci_execute errors pass the statement handle
        $_SESSION['mesaj_exceptie'] = $error['message'];
        $_SESSION['link_exceptie'] = 'pagina_principala.php';
        header('Location: ./eroare.php');
        exit;
    }


    $_SESSION['rate_maxim'] = $rating;
    $_SESSION['ISBN_maxim'] = $ISBN;

    $pagina_finala = $inceput . '<div style="float:right"><a style="font-size: 20px" href = "logout.php"> Logout </a></div><h3> Citatul paginii: ';
    $pagina_finala = $pagina_finala . $citat . '</h3> <div style="float:right"><h3> Autor: ' . $autor . '</h3></div>';
    $pagina_finala = $pagina_finala . $linkuri . $carti . '<div style="display:inline"><a href="schimba_variabila_stanga.php"> Cărțile anterioare </a></div>';
    $pagina_finala = $pagina_finala . '<div style="float:right;display:inline"><a href="schimba_variabila_dreapta.php"> Cărțile următoare </a></div>';

    echo $pagina_finala;

 ?>
