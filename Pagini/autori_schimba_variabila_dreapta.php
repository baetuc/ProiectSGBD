<?php
  session_start();
  $_SESSION['cauta_autor_next'] = true;
  header('Location: ./cauta_autor.php');
  exit;
 ?>
