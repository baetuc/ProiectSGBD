<?php
session_start();

if(isset($_REQUEST['titlu'])){
    $_SESSION['titlu']=$_REQUEST['titlu'];
    $_SESSION['volum']=$_REQUEST['volum'];
    $_SESSION['isbn']=$_REQUEST['isbn'];
    $_SESSION['editura']=$_REQUEST['editura'];
    $_SESSION['calea']=$_REQUEST['calea'];
    $_SESSION['an']=$_REQUEST['an'];
    $_SESSION['subgen']=$_REQUEST['subgen'];
    $_SESSION['nume']=$_REQUEST['nume'];
    $_SESSION['prenume']=$_REQUEST['prenume'];
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
  CRUD.insereaza_carte(
      :titlu,
      :volum,
      :isbn,
      :editura,
      :calea,
      :an,
      :subgen,
      :nume,
      :prenume);
end;";

$stid = oci_parse($conn, $query);

oci_bind_by_name($stid, ":titlu", $_SESSION['titlu']);
oci_bind_by_name($stid, ":volum", $_SESSION['volum']);
oci_bind_by_name($stid, ":isbn", $_SESSION['isbn']);
oci_bind_by_name($stid, ":editura", $_SESSION['editura']);
oci_bind_by_name($stid, ":calea", $_SESSION['calea']);
oci_bind_by_name($stid, ":an", $_SESSION['an']);
oci_bind_by_name($stid, ":subgen", $_SESSION['subgen']);
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
  <title>Insereaza Carte</title>
</head>
<body>
<div><a href = "pagina_principala.php"> Înapoi</a></div> 
Succes!
</body>
</html>';

?>