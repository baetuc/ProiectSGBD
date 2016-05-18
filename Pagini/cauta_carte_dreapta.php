<?php
  session_start();
  $_SESSION['unde_cauta_carte'] = 'next';
  header('Location: ./cauta_carte.php');
  exit;
 ?>
