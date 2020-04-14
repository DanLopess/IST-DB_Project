<?php
include 'PDOmodules.php';

printUpperPage();
addSuperCategory($_POST['categoryName'], $_POST['simpleName']);
printLowerPage();

?>