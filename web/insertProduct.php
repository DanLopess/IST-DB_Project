<?php
include 'PDOmodules.php';

printUpperPage();
insertProduct($_POST['ean'], $_POST['design'], $_POST['categoria'], $_POST['forn_prim'], $_POST['forn_sec']);
printLowerPage();

?>