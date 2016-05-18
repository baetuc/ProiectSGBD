<?php
  session_start();
  $_SESSION['next_principala'] = true;
  header('Location: ./pagina_principala.php');
  exit;
 ?>
