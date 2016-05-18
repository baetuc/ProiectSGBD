<?php
  session_start();
  $_SESSION['cauta_autor_next'] = false;
  header('Location: ./cauta_autor.php');
  exit;
 ?>
