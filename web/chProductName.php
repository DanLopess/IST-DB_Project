<?php
include 'PDOmodules.php';

printUpperPage();
changeProductName($_POST['newName'], $_POST['oldName']);
printLowerPage();

?>