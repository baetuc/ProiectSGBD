<?php
  session_start();
  $inceput = '<!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <title>Pagina principală</title>
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

  $statement = 'BEGIN :carti := paginare.paginare_autori_';
  if ($_SESSION['cauta_autor_next'] == true) {
    $statement = $statement . 'next';
  } else {
    $statement = $statement . 'back';
  }
  $statement = $statement . '(:nume, :prenume, :ISBN_vechi, :html, :ISBN_nou); END;';
  $stmt = oci_parse($connection, $statement);
    if (!$stmt) {
        $error = oci_error($connection);  // For oci_parse errors pass the connection handle
        $_SESSION['mesaj_exceptie'] = $error['message'];
        $_SESSION['link_exceptie'] = 'pagina_principala.php';
        header('Location: ./eroare.php');
        exit;
    }

    oci_bind_by_name($stmt, ':carti', $carti, 32767);
    oci_bind_by_name($stmt, ':nume', $_SESSION['cauta_nume']);
    oci_bind_by_name($stmt, ':prenume', $_SESSION['cauta_prenume']);
    oci_bind_by_name($stmt, ':ISBN_vechi', $_SESSION['cauta_autor_ISBN']);
    $hhtml = 1;
    oci_bind_by_name($stmt, ':html', $hhtml);
    oci_bind_by_name($stmt, ':ISBN_nou', $ISBN, 100);

    $response = @oci_execute($stmt);
    if (!$response) {
        $error = oci_error($stmt);  // For oci_execute errors pass the statement handle
        $_SESSION['mesaj_exceptie'] = $error['message'];
        $_SESSION['link_exceptie'] = 'pagina_principala.php';
        header('Location: ./eroare.php');
        exit;
    }

    $_SESSION['cauta_autor_ISBN'] = $ISBN;

    $pagina_finala = $inceput . '<div><a href = "pagina_principala.php"> Înapoi</a></div>';
    $pagina_finala = $pagina_finala . '<h3> Cărțile cu autorii căutați: </h3>';
    $pagina_finala = $pagina_finala . $carti . '<div style="display:inline"><a href="autori_schimba_variabila_stanga.php"> Cărțile anterioare </a></div>';
    $pagina_finala = $pagina_finala . '<div style="float:right;display:inline"><a href="autori_schimba_variabila_dreapta.php"> Cărțile următoare </a></div>';
    echo $pagina_finala . $final;

 ?>
