<?php
  session_start();
  $_SESSION['unde_cauta_carte'] = 'back';
  header('Location: ./cauta_carte.php');
  exit;
 ?>
