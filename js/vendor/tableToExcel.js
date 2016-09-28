function exportToExcel() {
	//Get table
	var table = $("#resultsTbl")[0];
	
	//Get number of rows/columns
	var rowLength = table.rows.length;
	var colLength = table.rows[0].cells.length;

	//Declare string to fill with table data
	var tableString = "";

	//Get column headers
	for (var i = 0; i < colLength; i++) {
		tableString += table.rows[0].cells[i].innerHTML.split(",").join("") + ",";
	}

	tableString = tableString.substring(0, tableString.length - 1);
	tableString += "\r\n";

	//Get row data
	for (var j = 1; j < rowLength; j++) {
		for (var k = 0; k < colLength; k++) {
			tableString += table.rows[j].cells[k].innerHTML.split(",").join("") + ",";
		}
		tableString += "\r\n";
	}

	//Save file
	if (navigator.appName == "Microsoft Internet Explorer") {
		//Optional: If you run into delimiter issues (where the commas are not interpreted and all data is one cell), then use this line to manually specify the delimeter
		tableString = 'sep=,\r\n' + tableString;
		
		myFrame.document.open("text/html", "replace");
        myFrame.document.write(tableString);
        myFrame.document.close();
        myFrame.focus();
        myFrame.document.execCommand('SaveAs', true, 'data.csv');
    }
    else {
    	csvData = 'data:application/csv;charset=utf-8,' + encodeURIComponent(tableString);
        $(event.target).attr({
        	'href': csvData,
            'target': '_blank',
            'download': 'my_data.csv'
        });
    }
}