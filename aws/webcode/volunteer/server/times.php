<?php
$shift = $_GET["shift"];

$times_file = fopen($shift, "r") or die("Unable to access hours!");
$times = fread($times_file, 1200);
fclose($times_file);

echo $times;
?>