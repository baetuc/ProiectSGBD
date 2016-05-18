<?php
session_start();

if(isset($_REQUEST['titlu']))
    $_SESSION['titlu']=$_REQUEST['titlu'];

$conn = oci_connect('STUDENT', 'STUDENT', 'localhost/XE');
if (!$conn) {
    $_SESSION['mesaj_exceptie']='Eroare la conectare!';
    $_SESSION['link_exceptie']='pagina_principala.php';
    header('Location: ./eroare.php');
    exit;
}

$query= "
begin
  :pagina := paginare.paginare_opere_".$_SESSION['unde_cauta_carte']."(
      :titlu,
      :isbn,
      1,
      :isbn_out);
end;";

$stid = oci_parse($conn, $query);

oci_bind_by_name($stid, ":titlu", $_SESSION['titlu']);
oci_bind_by_name($stid, ":isbn", $_SESSION['isbn_cauta_carte']);
oci_bind_by_name($stid, ":isbn_out", $aux,100);
oci_bind_by_name($stid, ":pagina", $pagina, 10000);

$r = @oci_execute($stid);

if (!$r) {
    $m = oci_error($stid);
    $_SESSION['mesaj_exceptie']=$m['message'];
    $_SESSION['link_exceptie']='pagina_principala.php';
    header('Location: ./eroare.php');
    exit;
}

$_SESSION['isbn_cauta_carte'] = $aux;

echo '
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Carte</title>
</head>
<body>
<div><a href = "pagina_principala.php"> Înapoi</a></div>' . $pagina. '<div style="display:inline"><a href="cauta_carte_stanga.php"> Cărțile anterioare </a></div><div style="float:right;display:inline"><a href="cauta_carte_dreapta.php"> Cărțile următoare </a></div>
</body>
</html>';

?>
