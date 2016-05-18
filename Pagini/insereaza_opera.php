<?php
session_start();

if(isset($_REQUEST['titlu'])){
    $_SESSION['titlu']=$_REQUEST['titlu'];
    $_SESSION['nume']=$_REQUEST['nume'];
    $_SESSION['prenume']=$_REQUEST['prenume'];
    $_SESSION['volum']=$_REQUEST['volum'];
}
    

$conn = oci_connect('STUDENT', 'STUDENT', 'localhost/XE');
if (!$conn) {
    $_SESSION['mesaj_exceptie']='Eroare la conectare!';
    $_SESSION['link_exceptie']='pagina_principala.html';
    header('Location: ./eroare.php');
    exit;
}

$query= "
begin
  CRUD.insereaza_opera(
      :titlu,
      :volum,
      :nume,
      :prenume);
end;";

$stid = oci_parse($conn, $query);

oci_bind_by_name($stid, ":titlu", $_SESSION['titlu']);
oci_bind_by_name($stid, ":volum", $_SESSION['volum']);
oci_bind_by_name($stid, ":nume", $_SESSION['nume']);
oci_bind_by_name($stid, ":prenume", $_SESSION['prenume']);

$r = @oci_execute($stid);

if (!$r) {
    $m = oci_error($stid);
    $_SESSION['mesaj_exceptie']=$m['message'];
    $_SESSION['link_exceptie']='pagina_principala.html';
    header('Location: ./eroare.php');
    exit;
}

echo '
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Insereaza opera</title>
</head>
<body>
<div><a href = "pagina_principala.php"> Înapoi</a></div> 
Succes!
</body>
</html>';

?>