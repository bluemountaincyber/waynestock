<?php
// Dependencies
require 'vendor/autoload.php';
use Aws\S3\S3Client;

// Replaces /var/www/submit.php.bak

// Create client
$s3Client = new S3Client([
    'version' => '2006-03-01',
    'region' => 'REGION_PLACEHOLDER'
]);

$buckets = $s3Client->listBuckets();

$filename = preg_replace('/\s+/', '', $_POST["name"]) . ".txt";
$tempfile = fopen($filename, "w");
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

// Upload file to S3
foreach ($buckets['Buckets'] as $bucket) {
    if (str_starts_with($bucket['Name'], 'volunteers-')) {
        $result = $s3Client->putObject([
            'Bucket' => $bucket['Name'],
            'Key' => $filename,
            'Body' => json_encode($_POST)
        ]);
        if ($result) {
            echo "Thank you for signing up!";
            unlink($filename);
        } else {
            echo "There was an error signing up!";
        }
        exit();
    }
}
echo "There was an error signing up!";
exit();

?>