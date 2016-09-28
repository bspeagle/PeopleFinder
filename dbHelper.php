<?php
    $DBServer = 'localhost';
	$DBUser   = 'root';
	$DBPass   = 'root';
	$DBName   = 'LocationData';
	
	$conn = new mysqli($DBServer, $DBUser, $DBPass, $DBName);
	
	// check connection
	if ($conn->connect_error) {
		echo ('Database connection failed: '.$conn->connect_error.E_USER_ERROR);
	}
?>