<?PHP
	require('dbHelper.php');
	
	$latVal = $_GET['lat'];	
	$lonVal = $_GET['lon'];
	$distVal = $_GET['dist'];
	
	$rsNumRows = '';
	
	$sql = "CALL getLocations($latVal, $lonVal, $distVal);";
 
	$rs = $conn->query($sql);
	 
	if ($rs === false) {
		echo('SQL Error: '.$conn->error.E_USER_ERROR);
	}
	else {		
		$json_response = array();
		
		$numRows_array['rows_returned'] = $rs->num_rows;
		array_push($json_response, $numRows_array);
		
		while($row = $rs->fetch_assoc()) {		
	        $row_array['email_address'] = $row['email_address'];
	        $row_array['city'] = $row['city'];
	        $row_array['region'] = $row['region'];
	        $row_array['distnace'] = $row['distance'];
	        
	        array_push($json_response,$row_array);
		}
	}
	
	echo json_encode($json_response);
	
	mysqli_close($conn);
?>