<?php
session_start();

$conn = oci_connect('STUDENT', 'STUDENT', 'localhost/XE');
if (!$conn) {
    $_SESSION['mesaj_exceptie']='Eroare la conectare!';
    $_SESSION['link_exceptie']='login.html';
    header('Location: ./eroare.php');
    exit;
}

$query= "
begin
  :rasp := logica_aplicatiei.login(:user,:parola);
end;";

$stid = oci_parse($conn, $query);

oci_bind_by_name($stid, ":user", $_REQUEST['username']);
oci_bind_by_name($stid, ":parola", $_REQUEST['password']);
oci_bind_by_name($stid, ":rasp", $rasp, 1);

$r = oci_execute($stid);

if (!$r) {
    $_SESSION['mesaj_exceptie']='Eroare la executare interogare!';
    $_SESSION['link_exceptie']='login.html';
    header('Location: ./eroare.php');
    exit;
}

    if($rasp == 'T')
    {
        $_SESSION['login'] = true;
        $_SESSION['utilizator'] = $_REQUEST['username'];
        $_SESSION['rate_maxim'] = null;
        $_SESSION['ISBN_maxim'] = null;
        $_SESSION['next_principala'] = true;
        
        $_SESSION['unde_cauta_carte'] = 'next';
        $_SESSION['isbn_cauta_carte'] = null;
        header('Location: ./pagina_principala.php');
        exit;
    }
    else
    {
        $_SESSION['mesaj_exceptie']='Eroare la logare! Parola incorecta sau user incorect!';
        $_SESSION['link_exceptie']='login.html';
        header('Location: ./eroare.php');
        exit;
    }

?>