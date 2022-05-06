<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="joda" uri="http://www.joda.org/joda/time/tags"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<script type="text/javascript">
//holder to make Data Table more widely available.
var oTable;
var debug = false;
function successEvents(msg, msgText) {
  $("#client-script-return-msg-rtn").html(msgText);
  //  microseconds to show return message block
  var defaultmessagedisplay = 1000;

  //  fade in our return message block
  $(msg).fadeIn('slow');

  //  remove return message block
  setTimeout(function() {
   $(msg).fadeOut('slow');
   oTable.ajax.reload();
  }, defaultmessagedisplay);
};

// Document ready function will load after DOM and before content.
$(function() {
  $("#pageHelp").html("Review and Maintain Training and Certifications");
  $("#adminHelp").html("ADMIN_CERT_TRAINING");

  $("#importCertificationTrainingAction").button();

  // takes all links ex: <a href=...> of class primeButton ex: class="primeButton" and creates buttons. NOTE: all classes are referenced by (.)className
  $("a", ".primeButton").button();
  $("#modifyCertificationTrainingAction").button("disable");
  $("#deleteCertificationTrainingAction").button("disable");

  $("#certificationtrainingTable thead th.textSearch").each( function () {
    $(this).html($(this).text() + '<br><input type="text" size="8" placeholder="Search" class="text ui-widget-content ui-corner-all"/>' );
  });

  // Convert the table to a data table.
  oTable = $("#certificationtrainingTable").DataTable({
    "jQueryUI" : true,
    "searching": true,
    "paging" : false,
    "info" : false,
    "processing" : true, 
    "scrollX": true,
    "scrollY" : ($(window).height() - 300),
    "scrollCollapse" : true,
    "dom" : 'Bf<"clear">r<"borderedDatatable"t>',
    "ajax" : "loadDataAjax",
    "columns" : [
      {"data" : "className"},
      {"data" : "classNumber"},
      {"data" : "expirationInDays"},
      {"data" : "expirationInMonths"}
    ],
    "columnDefs" : [
      {"className" : "ajaxDataTableCenterAligned", "targets" : "centerColumn"},
      {"className" : "ajaxDataTableLeftAligned", "targets" : "_all"},
      {"render": function(data, type, row) {
        if (!data) return "";
        return $.fn.dataTable.render.text().display(data);
      }, "targets": "_all"}
    ],
    "buttons": [
      { extend: 'copy',
        exportOptions: {
          columns: ':visible',
          orthogonal: 'export'
        }
      },
      { extend: 'excel',
        text: 'Export',
        exportOptions: {
          columns: ':visible',
          orthogonal: 'export'
        }
      },
      { extend: 'print',
        exportOptions: {
          columns: ':visible',
          orthogonal: 'export'
        }
      }
    ]
  });

  if (debug) {
    console.log('DataTable version in use is ' + $.fn.DataTable.version);
  }
  
  oTable.columns().eq( 0 ).each( function ( colIdx ) {
    $('input', oTable.column( colIdx ).header() ).on('keyup change', function() {
      oTable.column( colIdx ).search( this.value ).draw();
    });

    $('input', oTable.column(colIdx).header()).on('click', function(e) {
      e.stopPropagation(); 
    });
  });

  // Highlight selected row in the table
  $("#certificationtrainingTable tbody").on("click", "tr", function(e) {
   if ($(this).hasClass('row_selected')) {
    $(this).removeClass('row_selected');
    $("#modifyCertificationTrainingAction").button("disable");
    $("#deleteCertificationTrainingAction").button("disable");
   } 
   else {
    oTable.$('tr.row_selected').removeClass('row_selected');
    $(this).addClass('row_selected');
    $("#modifyCertificationTrainingAction").button("enable");
    $("#deleteCertificationTrainingAction").button("enable");
   }
  });

  // newCertificationTrainingActionForm validate and then submit using Jquery.
  $("#newCertificationTrainingActionForm").validate({
       onkeyup : false,
       focusCleanup : false,
       onclick : false,
       onfocusout : false,
       highlight : function(element, errorClass) { },

       // make sure we show/hide both blocks
       errorContainer : "#addErrorBlock1, #addErrorBlock2",
       // put all error messages in a UL
       errorLabelContainer : "#addErrorBlock2 ul",

       // wrap all error messages in an LI tag
       wrapper : "li",

       // rules/messages are for the validation
       rules : {
        className : "required",
        classNumber : "required",
       },
       messages : {
        className : "Please enter a class name.",
        classNumber : "Please enter a class Number.",
       },

       // our form submit
       submitHandler : function(form) {
         jQuery(form).ajaxSubmit({
             // what to do on form submit success
             success : function(r, s) {
              if (r == "success") {
                $('#addCertificationTrainingModal').dialog('close');
                successEvents(
                 '#client-script-return-msg',
                 "Certification Training successfully added!");
              } 
              else {
               if (r.indexOf("<html>") != -1) {
                document.open();
                document.write(r);
                document.close();
               } 
               else {
                $("#addErrorMessage")
                  .html('<p style="color: red; margin-bottom: 10px;">' + r + '</p>');
               }
              }
             },
             error : function() {
              alert("An error was received by the server and it is unable to process your request at this time.");
             }
         });
       }
    });

  // our add Certification Training Form modal dialog setup
  $("#addCertificationTrainingModal").dialog({
    bgiframe : true,
    autoOpen : false,
    width : 350,
    modal : true,
    buttons : {
      'Save Certification Training' : function() {
        //  submit the form
        $("#addErrorMessage").html("");
        $("#newCertificationTrainingActionForm").submit();
      },
      Cancel : function() {
        //  close the dialog, reset the form
        $(this).dialog('close');
      }
    }
  });

  // onclick action for our button
  $('#newCertificationTrainingAction').click(function() {
    $("#newCertificationTrainingActionForm")[0].reset();
    $("#addErrorBlock1").css("display", "none");
    $("#addErrorMessage").html("");
    $('#addCertificationTrainingModal').dialog('open');
  });

  // modify Certification Training Form validate and then submit using Jquery.
  $("#modifyCertificationTrainingForm").validate({
       onkeyup : false,
       focusCleanup : false,
       onclick : false,
       onfocusout : false,
       highlight : function(element, errorClass) { },

       // make sure we show/hide both blocks
       errorContainer : "#modifyErrorBlock1, #modifyErrorBlock2",
       // put all error messages in a UL
       errorLabelContainer : "#modifyErrorBlock2 ul",

       // wrap all error messages in an LI tag
       wrapper : "li",

       // rules/messages are for the validation
       rules : {
        className : "required",
        classNumber : "required",
       },
       messages : {
        className : "Please enter a class name.",
        classNumber : "Please enter a class Number.",
       },

       // our form submit
       submitHandler : function(form) {
         jQuery(form).ajaxSubmit({
           // what to do on form submit success
           success : function(r, s) {
            if (r == "success") {
              $('#modifyCertificationTrainingModal').dialog('close');
              successEvents('#client-script-return-msg', "Certification Training successfully modified!");
            } else {
              if (r.indexOf("<html>") != -1) {
                document.open();
                document.write(r);
                document.close();
              } else {
                $("#modifyErrorMessage").html('<p style="color: red; margin-bottom: 10px;">' + r + '</p>');
              }
            }
           },
           error : function() {
             alert("An error was received by the server and it is unable to process your request at this time.");
           }
         });
       }
     });

  // our modify Certification Training modal dialog setup
  $("#modifyCertificationTrainingModal").dialog({
    bgiframe : true,
    autoOpen : false,
    width : 350,
    modal : true,
    buttons : {
      'Modify Certification Training' : function() {
        //  submit the form
        $("#modifyErrorMessage").html("");
        $("#modifyCertificationTrainingForm").submit();
      },
      Cancel : function() {
        //  close the dialog, reset the form
        $(this).dialog('close');
      }
    }
  });

  // onclick action for our button
  $('#modifyCertificationTrainingAction').click(function() {
    $("#modifyErrorMessage").html("");
    $("#modifyErrorBlock1").css("display", "none");
    
    var tr = $("tr.row_selected", oTable.table().body());
    if (tr.size() == 0) {
      alert("Must select a row to modify!");
      return;
    }
    var data = oTable.row(tr).data();

    $("input[name=id]", $("#modifyCertificationTrainingModal")).val(data["id"]);
    $("input[name=version]",$("#modifyCertificationTrainingModal")).val(data["version"]);
    $("input[name=className]", $("#modifyCertificationTrainingModal")).val(data["className"]);
    $("input[name=classNumber]", $("#modifyCertificationTrainingModal")).val(data["classNumber"]);
    $("input[name=expirationInDays]", $("#modifyCertificationTrainingModal")).val(data["expirationInDays"]);
    $("input[name=expirationInMonths]", $("#modifyCertificationTrainingModal")).val(data["expirationInMonths"]);
    $('#modifyCertificationTrainingModal').dialog('open');
  });

  // delete CertificationTraining Form validate and then submit using Jquery.
  $("#deleteCertificationTrainingForm").validate({
       onkeyup : false,
       focusCleanup : false,
       onclick : false,
       onfocusout : false,
       highlight : function(element, errorClass) { },

       // make sure we show/hide both blocks
       errorContainer : "#deleteErrorBlock1, #deleteErrorBlock2",
       // put all error messages in a UL
       errorLabelContainer : "#deleteErrorBlock2 ul",

       // wrap all error messages in an LI tag
       wrapper : "li",

       // rules/messages are for the validation
       rules : {},

       // our form submit (I want to play with this some more.  I think there is a newer format for this.)
       submitHandler : function(form) {
         jQuery(form).ajaxSubmit({
           // what to do on form submit success
           success : function(r, s) {
             if (r == "success") {
               $('#deleteCertificationTrainingModal').dialog('close');
               successEvents('#client-script-return-msg', "Certification Training successfully deleted!");
             } else {
               if (r.indexOf("<html>") != -1) {
                document.open();
                document.write(r);
                document.close();
               } else {
                $("#deleteErrorMessage").html('<p style="color: red; margin-bottom: 10px;">' + r + '</p>');
               }
             }
           },
           error : function() {
              alert("An error was received by the server and it is unable to process your request at this time.");
           }
         });
       }
  });

  // our delete Certification Training modal dialog setup
  $("#deleteCertificationTrainingModal").dialog({
    bgiframe : true,
    autoOpen : false,
    width : 400,
    modal : true,
    buttons : {
      'Delete' : function() {
         //  submit the form
         $("#deleteErrorMessage").html("");
         $("#deleteCertificationTrainingForm").submit();
      },
      Cancel : function() {
        //  close the dialog, reset the form
        $(this).dialog('close');
      }
    }
  });

  // onclick action for our button
  $("#importCertificationTrainingAction").click(function() {
       $("#importForm")[0].reset();
       $("#importErrorMessage").html("");
       $("#importCertificationTrainingModal").dialog('open');
   });
  
  $("#importCertificationTrainingModal").dialog({
    bgiframe: true,
    autoOpen: false,
    width: 500,
    modal: true,
    buttons: {
      'Import': function() {
        $("#importForm").submit();
      },
      Cancel: function() {
        $(this).dialog('close');
      }
    }
  });

  $("#importForm").validate({
    onkeyup: false,
    focusCleanup: false,
    onclick: false,
    onfocusout: false,
    highlight: function(element, errorClass) {},

    // make sure we show/hide both blocks
    errorContainer: "#importErrorBlock1, #importErrorBlock2",
    // put all error messages in a UL
    errorLabelContainer: "#importErrorBlock2 ul",

    rules: {
        filename: "required",
    },
    messages: {
        filename: "Please select a file to upload.",
    },

    // our import Certification Training form submit 
    submitHandler: function(form) {
        jQuery(form).ajaxSubmit({
            // what to do on form submit success
            success: function(r, s) {
                if (r == "success") {
                    $("#importCertificationTrainingModal").dialog("close");
                    successEvents("#client-script-return-msg", "Successful Upload!");
                } else {
                  if (r.indexOf("<html") != -1) {
                    document.open();
                    document.write(r);
                    document.close();
                  } else {
                    $("#importErrorMessage").html('<p style="color: red; margin-bottom: 10px;">' + r + '</p>');
                  }
                }
            },
            error: function(jqXHR, statusText, errorThrown) {
                $("#importErrorMessage").text(jqXHR.responseText);
            }
        });
    }
  });
  

  $('#deleteCertificationTrainingAction').click(function() {
    $("#deleteErrorMessage").html("");
    $("#deleteErrorBlock1").css("display", "none");
    
    var tr = $("tr.row_selected", oTable.table().body());
    if (tr.size() == 0) {
      alert("Must select a row to delete!");
      return;
    }
    var data = oTable.row(tr).data();

    $("input[name=id]", $("#deleteCertificationTrainingModal")).val(data["id"]);
    $("input[name=version]", $("#deleteCertificationTrainingModal")).val(data["version"]);
    $("input[name=classNumber]",$("#deleteCertificationTrainingModal")).val(data["classNumber"]);
    $("#deleteClassName").text(data["className"]);
    $("#deleteClassNumber").text(data["classNumber"]);
    $("#deleteExpirationInDays").text(data["expirationInDays"] == null ? "" : data["expirationInDays"]);
    $("#deleteExpirationInMonths").text(data["expirationInMonths"] == null ? "" : data["expirationInMonths"]);
    $('#deleteCertificationTrainingModal').dialog('open');
  });
});

</script>
<!-- JDR: our return message block -->
<div class="ui-widget ui-helper-hidden" id="client-script-return-msg">
	<div class="ui-state-highlight ui-corner-all"
		style="padding: 0pt 0.7em; margin-top: 0px; margin-bottom: 5px;">
		<p>
			<span class="ui-icon ui-icon-circle-check"
				style="float: left; margin-right: 0.3em;"></span>
			<!-- JDR: our return message will go in the following span -->
			<span id="client-script-return-msg-rtn"></span>
		</p>
	</div>
</div>

<div class="primeButton"
	style="float: left; display: inline-block; position: absolute; z-index: 50;">
	<p class="primeNav">
		<sec:authorize access="primeAccess('ADMIN_CERT_TRAINING_ADD_MOD_DEL')">
			<a href="javascript:void(0)" id="newCertificationTrainingAction">New</a>
			<a href="javascript:void(0)" id="modifyCertificationTrainingAction">Modify</a>
			<a href="javascript:void(0)" id="deleteCertificationTrainingAction">Delete</a>
			<a href="javascript:void(0)" id="importCertificationTrainingAction">Import</a>
		</sec:authorize>
	</p>
</div>

<table id="certificationtrainingTable" style="width: 100%;">
	<thead>
		<tr>
			<th class="textSearch">Class Name</th>
			<th class="textSearch">Class Number</th>
			<th class="centerColumn">Expiration In Days</th>
			<th class="centerColumn">Expiration In Months</th>
		</tr>
	</thead>
	<tbody></tbody>
</table>

<!-- JDR: generic container -->
<div class="jdr-blockwidth">

	<!-- Add Certification Training Modal Window -->
	<div id="addCertificationTrainingModal" title="Add">

		<!-- form validation error container -->
		<div id="addErrorBlock1" style="display: none">
			<div style="padding: 0pt 0.7em;" id="addErrorBlock2">
				<p>
					<!--  fancy icon -->
					<span class="ui-icon ui-icon-alert"
						style="float: left; margin-right: 0.3em;"></span> <strong>Alert:</strong>
					Errors detected!
				</p>
				<!-- k validation plugin will target this UL for error messages -->
				<ul></ul>
			</div>
		</div>
		<div id="addErrorMessage"></div>

		<!-- JDR: our form, no buttons (buttons generated by jQuery UI dialog() function) -->
		<form action="newCertificationTrainingAjax"
			name="newCertificationTrainingActionForm"
			id="newCertificationTrainingActionForm" method="POST">
			<fieldset>
				<label for="className">Class Name:</label><br /> <input type="text"
					name="className" id="className"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
				<label for="classNumber">Class Number:</label><br /> <input
					type="text" name="classNumber" id="classNumber"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
				<label for="expirationInDays">Expiration In Days:</label><br /> <input
					type="number" name="expirationInDays" id="expirationInDays"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
				<label for="expirationInMonths">Expiration In Months:</label><br />
				<input type="number" name="expirationInMonths"
					id="expirationInMonths"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
			</fieldset>
		</form>
	</div>

	<!-- Modify Certification Training Modal Window -->
	<div id="modifyCertificationTrainingModal" title="Modify">

		<!-- form validation error container -->
		<div id="modifyErrorBlock1" style="display: none">
			<div style="padding: 0pt 0.7em;" id="modifyErrorBlock2">
				<p>
					<!--  fancy icon -->
					<span class="ui-icon ui-icon-alert"
						style="float: left; margin-right: 0.3em;"></span> <strong>Alert:</strong>
					Errors detected!
				</p>
				<!-- k validation plugin will target this UL for error messages -->
				<ul></ul>
			</div>
		</div>
		<div id="modifyErrorMessage"></div>

		<!-- JDR: our form, no buttons (buttons generated by jQuery UI dialog() function) -->
		<form action="modifyCertificationTrainingAjax"
			name="modifyCertificationTrainingForm"
			id="modifyCertificationTrainingForm" method="POST">
			<fieldset>
				<input type="hidden" name="id" value=""
					class="text ui-widget-content ui-corner-all" /> <input
					type="hidden" name="version" value=""
					class="text ui-widget-content ui-corner-all" /> <label
					for="className">Class Name:</label><br /> <input type="text"
					name="className" id="className"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
				<label for="classNumber">Class Number:</label><br /> <input
					type="text" name="classNumber" id="classNumber" readonly
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
				<label for="expirationInDays">Expiration In Days:</label><br /> <input
					type="number" name="expirationInDays" id="expirationInDays"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
				<label for="expirationInMonths">Expiration In Months:</label><br />
				<input type="number" name="expirationInMonths"
					id="expirationInMonths"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
			</fieldset>
		</form>
	</div>

	<!-- Delete Certification Training Modal Window -->
	<div id="deleteCertificationTrainingModal" title="Delete">

		<!-- form validation error container -->
		<div id="deleteErrorBlock1" style="display: none">
			<div style="padding: 0pt 0.7em;" id="deleteErrorBlock2">
				<p>
					<!--  fancy icon -->
					<span class="ui-icon ui-icon-alert"
						style="float: left; margin-right: 0.3em;"></span> <strong>Alert:</strong>
					Errors detected!
				</p>
				<!-- k validation plugin will target this UL for error messages -->
				<ul></ul>
			</div>
		</div>
		<div id="deleteErrorMessage"></div>

		<!-- JDR: our form, no buttons (buttons generated by jQuery UI dialog() function) -->
		<form action="deleteCertificationTrainingAjax"
			name="deleteCertificationTrainingForm"
			id="deleteCertificationTrainingForm" method="POST">
			<fieldset>
				<input type="hidden" name="id" value=""
					class="text ui-widget-content ui-corner-all" /> 
				<input type="hidden" name="version" value=""
					class="text ui-widget-content ui-corner-all" /> 
				<label for="deleteClassName">Class Name:</label><br /> <span
					id="deleteClassName" style="color: red;"></span><br />  
				<label for="classNumber">Class Number:</label><br /> 
				<input type="text" name="classNumber" id="classNumber" value="" readonly
				    style="color: red;"
					class="text ui-widget-content ui-corner-all" /><br />
                <label
					for="deleteExpirationInDays">Expiration In Days:</label><br /> <span
					id="deleteExpirationInDays" style="color: red;"></span><br /> <label
					for="deleteExpirationInMonths">Expiration In Months:</label><br />
				<span id="deleteExpirationInMonths" style="color: red;"></span><br />
			</fieldset>
		</form>
	</div>

	<div id="importCertificationTrainingModal" title="Import Certification Training">
		<!-- form validation error container -->
		<div id="importErrorBlock1" style="display: none">
			<div style="padding: 0pt 0.7em;" id="importErrorBlock2">
				<p>
					<!--  fancy icon -->
					<span class="ui-icon ui-icon-alert"
						style="float: left; margin-right: 0.3em;"></span> <strong>Alert:</strong>
					Errors detected!
				</p>
				<!-- k validation plugin will target this UL for error messages -->
				<ul></ul>
			</div>
		</div>

		<div id="importErrorMessage" style="color: red"></div>
		<form action="importCertificationTraining" name="importForm"
			id="importForm" enctype="multipart/form-data" method="POST">
			<h3 style="display: inline">Template File:</h3>
			<input type="file" name="filename"
				class="text ui-widget-content ui-corner-all" />
		</form>
		<div id="dialog-message" title="Status">
			<div id="message-paragraph"></div>
		</div>
	</div>

</div>