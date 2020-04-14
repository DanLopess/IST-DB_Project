<?php
include 'PDOmodules.php';

printUpperPage();
listAllCategories($_POST['cat_name']);
printLowerPage();

?>