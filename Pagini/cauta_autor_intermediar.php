<?php
  session_start();
  $_SESSION['cauta_nume'] = $_GET['nume'];
  $_SESSION['cauta_prenume'] = $_GET['prenume'];
  $_SESSION['cauta_autor_ISBN'] = null;
  $_SESSION['cauta_autor_next'] = true;
  header('Location: ./cauta_autor.php');
  exit;
 ?>
