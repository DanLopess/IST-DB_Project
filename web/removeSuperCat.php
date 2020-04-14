<?php
include 'PDOmodules.php';

printUpperPage();
removeSuperCategory($_POST['cat_name']);
printLowerPage();

?>