<?php
include 'PDOmodules.php';

printUpperPage();
addSimpleCategory($_POST['category']);
printLowerPage();

?>

