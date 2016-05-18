<?php
session_start();
echo '
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="refresh" content="5;url=' . $_SESSION['link_exceptie'] . '" />
    </head>
    <body>
        <p>' . $_SESSION['mesaj_exceptie'] . '</p>
        <p>Vei fi redirectat in 5 secunde pe o pagina corespunzatoare...</p>
    </body>
</html>';
    
?>