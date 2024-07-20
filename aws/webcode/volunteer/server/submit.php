<?php
// Dependencies
require 'vendor/autoload.php';
use Aws\S3\S3Client;

// Create client
$s3Client = new S3Client([
    'version' => '2006-03-01',
    'region' => '${REGION}'
]);

$buckets = $s3Client->listBuckets();

// Check if temp file is lingering and delete it
if ($tempfile = fopen($_POST["email"], "r")) {
    echo "You can only sign up once!<br/>";
    echo "<p style=\"color:red;\">";
    $content = fread($tempfile, 1000);
    echo str_replace("\n", "<br/>", $content);
    echo "</p>";
    fclose($tempfile);
    unlink($_POST["email"]);
    exit();
} else {
    // Create temp file
    $tempfile = fopen($_POST["email"], "w");
    $txt = "Name: " .
        $_POST["name"] . "\n" .
        "Email: " . 
        $_POST["email"] . "\n" .
        "Phone: " .
        $_POST["phone"] . "\n" .
        "Shift: " .
        $_POST["preferred_shift"] . "\n";
    fwrite($tempfile, $txt);
    fclose($tempfile);
}

// Upload file to S3
foreach ($buckets['Buckets'] as $bucket) {
    if (str_starts_with($bucket['Name'], 'volunteers-')) {
        $result = $s3Client->putObject([
            'Bucket' => $bucket['Name'],
            'Key' => $_POST["email"],
            'Body' => json_encode($_POST)
        ]);
        if ($result) {
            echo "Thank you for signing up!";
            unlink($_POST["email"]);
        } else {
            echo "There was an error signing up!";
        }
        exit();
    }
}
echo "There was an error signing up!";
exit();

?>