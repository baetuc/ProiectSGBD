<?php
session_start();

if(isset($_REQUEST['subgen'])){
    $_SESSION['subgen']=$_REQUEST['subgen'];
    $_SESSION['gen']=$_REQUEST['gen'];
}


$conn = oci_connect('STUDENT', 'STUDENT', 'localhost/XE');
if (!$conn) {
    $_SESSION['mesaj_exceptie']='Eroare la conectare!';
    $_SESSION['link_exceptie']='pagina_principala.php';
    header('Location: ./eroare.php');
    exit;
}

$query= "
begin
  CRUD.insereaza_subgen(
      :subgen,
      :gen);
end;";

$stid = oci_parse($conn, $query);

oci_bind_by_name($stid, ":gen", $_SESSION['gen']);
oci_bind_by_name($stid, ":subgen", $_SESSION['subgen']);

$r = @oci_execute($stid);

if (!$r) {
    $m = oci_error($stid);
    $_SESSION['mesaj_exceptie']=$m['message'];
    $_SESSION['link_exceptie']='pagina_principala.php';
    header('Location: ./eroare.php');
    exit;
}

echo '
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Insereaza Subgen</title>
</head>
<body>
<div><a href = "pagina_principala.php"> Înapoi</a></div>
Succes!
</body>
</html>';

?>
