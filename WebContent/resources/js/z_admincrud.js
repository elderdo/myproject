// Include this file to remove a lot of the tedious coding for the admin pages.


	// The base javascript object that holds a reference to the datatable.
	var crudTable;

// function updates the success message on the main page.
	function successEvents(msg, msgText) {

		$("#client-script-return-msg-rtn").html(msgText);
		//  microseconds to show return message block
		var defaultmessagedisplay = 1000;

		//  fade in our return message block
		$(msg).fadeIn('slow');

		$("#modify, #delete").button("disable");

		//  remove return message block
		setTimeout(function() { 
			$(msg).fadeOut('slow');
			locationTable.fnReloadAjax();}, 
			defaultmessagedisplay);
	}
	
	$("document").ready(function() {
		

      	

      	
      	
	}); // End Document Ready