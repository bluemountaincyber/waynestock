<?php
exec("grep " . $_SERVER['HTTP_USER_AGENT'] . " /var/www/user-agents.csv", $output, $exit_code);
if ($exit_code == 0) {
    http_response_code(403);
    echo "Go away! You have an untrusted User-Agent!<br>";
    echo "Your user agent is:<br>";
    echo $output[0];
} else {
    echo "The server is alive!<br>Your user agent is: " . $_SERVER['HTTP_USER_AGENT'] . "<br>";
}
?>