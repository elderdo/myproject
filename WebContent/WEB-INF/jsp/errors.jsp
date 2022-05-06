<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>


<script type="text/javascript" src="/prime/resources/js/jquery.steps.js"></script> 
  <link type="text/css" href="/prime/resources/css/jquery.steps.css" rel="Stylesheet" />
<script type="text/javascript">
  // function updates the success message on the main page.
  function successEvents(msg, msgText) {
  
    $("#client-script-return-msg-rtn").html(msgText);
    //  microseconds to show return message block
    var defaultmessagedisplay = 3000;
  
    //  fade in our return message block
    $(msg).fadeIn('slow');
  
    //  remove return message block
    setTimeout(function() { 
      $(msg).fadeOut('slow');}, 
      defaultmessagedisplay);
  };

	function warningEvents(msgText) {
    $("#warningText").html(msgText);
    //  microseconds to show return message block
    var defaultmessagedisplay = 20000;

    //  fade in our return message block
    $("#closeWarning").show();
    $("#warningText").fadeIn('slow');

    //  remove return message block
/*     setTimeout(function() {
      $("#warningText").fadeOut('slow');
      }, 
      defaultmessagedisplay); */
  }

  $(function() {
  	//Errors
  	if("${haserrors}"=="true"){
  		warningEvents("${errors}");
  	}
  	$("#closeWarning").click(function(){
  		var redirect = "${redirect}";
  		if (redirect && redirect.charAt(0) == "/") {
  			redirect = "/prime/${programName.name}" + redirect;
  		}
    	window.open(redirect, "_self");
  	});
		//Tooltips
		 $( document ).tooltip({
      	position: {
      		my: "center bottom-20",
      		at: "center top",
      		using: function( position, feedback ) {
        		$( this ).css( position );
        		$( "<div>" )
          		.addClass( "arrow" )
          		.addClass( feedback.vertical )
          		.addClass( feedback.horizontal )
          		.appendTo( this );
      		}
      	}
     });

   

  });
</script>

<style>


  
</style>

<div>
  <legend>The Following Errors were encountered.</legend>
  <p><c:out value="${summaryMessage}"/></p>
</div>

<div id="warningText" style="display:none;font-size:1.1em;" class="alert alert-danger"></div>
<button type="button" id="closeWarning" class="btn btn-danger" style="display:none;margin-bottom:10px;">Close</button>
<div class="ui-widget ui-helper-hidden" id="client-script-return-msg">
  <div class="ui-state-highlight ui-corner-all" style="padding: 0pt 0.7em; margin-top: 0px; margin-bottom: 5px;"> 
    <p><span class="ui-icon ui-icon-circle-check" style="float: left; margin-right: 0.3em;"></span>
    <!-- JDR: our return message will go in the following span -->
    <span id="client-script-return-msg-rtn"></span></p>
  </div>
</div>

 


    




