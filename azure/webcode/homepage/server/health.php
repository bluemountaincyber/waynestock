<?php
$results = shell_exec("grep " . $_SERVER['HTTP_USER_AGENT'] . " /var/www/user-agents.csv");
if ($results) {
    http_response_code(403);
    echo "Go away! You have an untrusted User-Agent!<br>";
    echo "Your user agent is:<br>";
    echo $results;
} else {
    echo "The server is alive!<br>Your user agent is: " . $_SERVER['HTTP_USER_AGENT'] . "<br>";
}
?>