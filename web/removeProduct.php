<?php
include 'PDOmodules.php';

printUpperPage();
removeProduct($_POST['nome']);
printLowerPage();

?>