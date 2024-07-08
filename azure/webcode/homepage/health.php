<?php
$results = shell_exec("grep " . $_SERVER['HTTP_USER_AGENT'] . " /var/www/user-agents.csv");
if ($results) {
    http_response_code(403);
    echo "Go away!";
} else {
    echo "The server is alive!<br>Your user agent is: " . $_SERVER['HTTP_USER_AGENT'] . "<br>";
}
?>