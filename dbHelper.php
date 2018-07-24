<?php
    require __DIR__ . '/vendor/autoload.php';
    $dotenv = new \Dotenv\Dotenv(__DIR__);
	$dotenv->load();  
	
    $DBServer = $_ENV['DBServer'];
	$DBUser   = $_ENV['DBUser'];
	$DBPass   = $_ENV['DBPass'];
	$DBName   = $_ENV['DBName'];
	
	$conn = new mysqli($DBServer, $DBUser, $DBPass, $DBName);
	
	// check connection
	if ($conn->connect_error) {
		echo ('Database connection failed: '.$conn->connect_error.E_USER_ERROR);
	}
?>