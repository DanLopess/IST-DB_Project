<?php
include 'PDOmodules.php';

printUpperPage();
listEvents($_POST['product']);
printLowerPage();

?>