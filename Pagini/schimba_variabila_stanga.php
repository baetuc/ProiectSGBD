<?php
  session_start();
  $_SESSION['next_principala'] = false;
  header('Location: ./pagina_principala.php');
  exit;
 ?>
