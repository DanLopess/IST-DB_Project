<?php
include 'PDOmodules.php';

printUpperPage();
removeSimpleCategory($_POST['cat_name']);
printLowerPage();

?>