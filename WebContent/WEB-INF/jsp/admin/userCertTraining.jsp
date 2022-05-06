<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="joda" uri="http://www.joda.org/joda/time/tags"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<script type="text/javascript">
//holder to make Data Table more widely available.
var oTable = null;
var debug = true;
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

  $("#importUserCertTrainingAction").button();

  // takes all links ex: <a href=...> of class primeButton ex: class="primeButton" and creates buttons. NOTE: all classes are referenced by (.)className
  $("a", ".primeButton").button();
  $("#modifyUserCertTrainingAction").button("disable");
  $("#deleteUserCertTrainingAction").button("disable");

  $("#userCertTrainingTable thead th.textSearch").each( function () {
    $(this).html($(this).text() + '<br><input type="text" size="8" placeholder="Search" class="text ui-widget-content ui-corner-all"/>' );
  });

  // Convert the table to a data table.
  oTable = $("#userCertTrainingTable").DataTable({
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
      {"data" : "name"},
      {"data" : "bemsId"},
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
  


  if (typeof oTable !== 'undefined' && oTable.length > 0) {

      oTable.columns().eq(0).each(
          function(colIdx) {
            $('input', oTable.column(colIdx).header()).on('keyup change',
                function() {
                  oTable.column(colIdx).search(this.value).draw();
                });

            $('input', oTable.column(colIdx).header()).on('click', function(e) {
              e.stopPropagation();
            });

          });
    }

    // Highlight selected row in the table
    $("#userCertTrainingTable tbody").on("click", "tr", function(e) {
      if ($(this).hasClass('row_selected')) {
        $(this).removeClass('row_selected');
        $("#modifyUserCertTrainingAction").button("disable");
        $("#deleteUserCertTrainingAction").button("disable");
      } else {
        oTable.$('tr.row_selected').removeClass('row_selected');
        $(this).addClass('row_selected');
        $("#modifyUserCertTrainingAction").button("enable");
        $("#deleteUserCertTrainingAction").button("enable");
      }
    });

    // newUserCertTrainingActionForm validate and then submit using Jquery.
    $("#newUserCertTrainingActionForm")
        .validate(
            {
              onkeyup : false,
              focusCleanup : false,
              onclick : false,
              onfocusout : false,
              highlight : function(element, errorClass) {
              },

              // make sure we show/hide both blocks
              errorContainer : "#addErrorBlock1, #addErrorBlock2",
              // put all error messages in a UL
              errorLabelContainer : "#addErrorBlock2 ul",

              // wrap all error messages in an LI tag
              wrapper : "li",

              // rules/messages are for the validation
              rules : {
                bemsId : "required",
                classNumber : "required",
              },
              messages : {
                bemsId : "Please enter a bemsId",
                classNumber : "Please enter a class Number.",
              },

              // our form submit
              submitHandler : function(form) {
                jQuery(form)
                    .ajaxSubmit(
                        {
                          // what to do on form submit success
                          success : function(r, s) {
                            if (r == "success") {
                              $('#addUserCertTrainingModal').dialog('close');
                              successEvents('#client-script-return-msg',
                                  "User Certification Training successfully added!");
                            } else {
                              if (r.indexOf("<html>") != -1) {
                                document.open();
                                document.write(r);
                                document.close();
                              } else {
                                $("#addErrorMessage").html(
                                    '<p style="color: red; margin-bottom: 10px;">'
                                        + r + '</p>');
                              }
                            }
                          },
                          error : function() {
                            alert("An error was received by the server and it is unable to process your request at this time.");
                          }
                        });
              }
            });

    // our add User Certification Training Form modal dialog setup
    $("#addUserCertTrainingModal").dialog({
      bgiframe : true,
      autoOpen : false,
      width : 350,
      modal : true,
      buttons : {
        'Save User Certification Training' : function() {
          //  submit the form
          $("#addErrorMessage").html("");
          $("#newUserCertTrainingActionForm").submit();
        },
        Cancel : function() {
          //  close the dialog, reset the form
          $(this).dialog('close');
        }
      }
    });

    // onclick action for our button
    $('#newUserCertTrainingAction').click(function() {
      $("#newUserCertTrainingActionForm")[0].reset();
      $("#addErrorBlock1").css("display", "none");
      $("#addErrorMessage").html("");
      $('#addUserCertTrainingModal').dialog('open');
    });

    // modify User Certification Training Form validate and then submit using Jquery.
    $("#modifyUserCertTrainingForm")
        .validate(
            {
              onkeyup : false,
              focusCleanup : false,
              onclick : false,
              onfocusout : false,
              highlight : function(element, errorClass) {
              },

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
                jQuery(form)
                    .ajaxSubmit(
                        {
                          // what to do on form submit success
                          success : function(r, s) {
                            if (r == "success") {
                              $('#modifyUserCertTrainingModal').dialog('close');
                              successEvents('#client-script-return-msg',
                                  "User Certification Training successfully modified!");
                            } else {
                              if (r.indexOf("<html>") != -1) {
                                document.open();
                                document.write(r);
                                document.close();
                              } else {
                                $("#modifyErrorMessage").html(
                                    '<p style="color: red; margin-bottom: 10px;">'
                                        + r + '</p>');
                              }
                            }
                          },
                          error : function() {
                            alert("An error was received by the server and it is unable to process your request at this time.");
                          }
                        });
              }
            });

    // our modify User Certification Training modal dialog setup
    $("#modifyUserCertTrainingModal").dialog({
      bgiframe : true,
      autoOpen : false,
      width : 350,
      modal : true,
      buttons : {
        'Modify User Certification Training' : function() {
          //  submit the form
          $("#modifyErrorMessage").html("");
          $("#modifyUserCertTrainingForm").submit();
        },
        Cancel : function() {
          //  close the dialog, reset the form
          $(this).dialog('close');
        }
      }
    });

    // onclick action for our button
    $('#modifyUserCertTrainingAction')
        .click(
            function() {
              $("#modifyErrorMessage").html("");
              $("#modifyErrorBlock1").css("display", "none");

              var tr = $("tr.row_selected", oTable.table().body());
              if (tr.size() == 0) {
                alert("Must select a row to modify!");
                return;
              }
              var data = oTable.row(tr).data();

              $("input[name=id]", $("#modifyUserCertTrainingModal")).val(
                  data["id"]);
              $("input[name=version]", $("#modifyUserCertTrainingModal")).val(
                  data["version"]);
              $("input[name=className]", $("#modifyUserCertTrainingModal"))
                  .val(data["className"]);
              $("input[name=classNumber]", $("#modifyUserCertTrainingModal"))
                  .val(data["classNumber"]);
              $("input[name=expirationInDays]",
                  $("#modifyUserCertTrainingModal")).val(
                  data["expirationInDays"]);
              $("input[name=expirationInMonths]",
                  $("#modifyUserCertTrainingModal")).val(
                  data["expirationInMonths"]);
              $('#modifyUserCertTrainingModal').dialog('open');
            });

    // delete UserCertTraining Form validate and then submit using Jquery.
    $("#deleteUserCertTrainingForm")
        .validate(
            {
              onkeyup : false,
              focusCleanup : false,
              onclick : false,
              onfocusout : false,
              highlight : function(element, errorClass) {
              },

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
                jQuery(form)
                    .ajaxSubmit(
                        {
                          // what to do on form submit success
                          success : function(r, s) {
                            if (r == "success") {
                              $('#deleteUserCertTrainingModal').dialog('close');
                              successEvents('#client-script-return-msg',
                                  "User Certification Training successfully deleted!");
                            } else {
                              if (r.indexOf("<html>") != -1) {
                                document.open();
                                document.write(r);
                                document.close();
                              } else {
                                $("#deleteErrorMessage").html(
                                    '<p style="color: red; margin-bottom: 10px;">'
                                        + r + '</p>');
                              }
                            }
                          },
                          error : function() {
                            alert("An error was received by the server and it is unable to process your request at this time.");
                          }
                        });
              }
            });

    // our delete User Certification Training modal dialog setup
    $("#deleteUserCertTrainingModal").dialog({
      bgiframe : true,
      autoOpen : false,
      width : 400,
      modal : true,
      buttons : {
        'Delete' : function() {
          //  submit the form
          $("#deleteErrorMessage").html("");
          $("#deleteUserCertTrainingForm").submit();
        },
        Cancel : function() {
          //  close the dialog, reset the form
          $(this).dialog('close');
        }
      }
    });

    // onclick action for our button
    $("#importUserCertTrainingAction").click(function() {
      $("#importForm")[0].reset();
      $("#importErrorMessage").html("");
      $("#importUserCertTraining").dialog('open');
    });

    $("#importUserCertTraining").dialog({
      bgiframe : true,
      autoOpen : false,
      width : 500,
      modal : true,
      buttons : {
        'Import' : function() {
          $("#importForm").submit();
        },
        Cancel : function() {
          $(this).dialog('close');
        }
      }
    });

    $("#importForm").validate(
        {
          onkeyup : false,
          focusCleanup : false,
          onclick : false,
          onfocusout : false,
          highlight : function(element, errorClass) {
          },

          // make sure we show/hide both blocks
          errorContainer : "#importErrorBlock1, #importErrorBlock2",
          // put all error messages in a UL
          errorLabelContainer : "#importErrorBlock2 ul",

          rules : {
            filename : "required",
          },
          messages : {
            filename : "Please select a file to upload.",
          },

          // our import User Certification Training form submit 
          submitHandler : function(form) {
            jQuery(form).ajaxSubmit(
                {
                  // what to do on form submit success
                  success : function(r, s) {
                    if (r == "success") {
                      $("#importUserCertTraining").dialog("close");
                      successEvents("#client-script-return-msg",
                          "Successful Upload!");
                    } else {
                      if (r.indexOf("<html") != -1) {
                        document.open();
                        document.write(r);
                        document.close();
                      } else {
                        $("#importErrorMessage").html(
                            '<p style="color: red; margin-bottom: 10px;">' + r
                                + '</p>');
                      }
                    }
                  },
                  error : function(jqXHR, statusText, errorThrown) {
                    $("#importErrorMessage").text(jqXHR.responseText);
                  }
                });
          }
        });

    $('#deleteUserCertTrainingAction')
        .click(
            function() {
              $("#deleteErrorMessage").html("");
              $("#deleteErrorBlock1").css("display", "none");

              var tr = $("tr.row_selected", oTable.table().body());
              if (tr.size() == 0) {
                alert("Must select a row to delete!");
                return;
              }
              var data = oTable.row(tr).data();

              $("input[name=id]", $("#deleteUserCertTrainingModal")).val(
                  data["id"]);
              $("input[name=version]", $("#deleteUserCertTrainingModal")).val(
                  data["version"]);
              $("#deleteBemsId").text(data["bemsId"]);
              $("#deleteName").text(data["name"]);
              $("#deleteClassName").text(data["className"]);
              $("#deleteClassNumber").text(data["classNumber"]);
              $("#deleteExpirationInDays").text(
                  data["expirationInDays"] == null ? ""
                      : data["expirationInDays"]);
              $("#deleteExpirationInMonths").text(
                  data["expirationInMonths"] == null ? ""
                      : data["expirationInMonths"]);
              $('#deleteUserCertTrainingModal').dialog('open');
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
			<a href="javascript:void(0)" id="newUserCertTrainingAction">New</a>
			<!--  
			<a href="javascript:void(0)" id="modifyUserCertTrainingAction">Modify</a>
			-->
			<a href="javascript:void(0)" id="deleteUserCertTrainingAction">Delete</a>
			<a href="javascript:void(0)" id="importUserCertTrainingAction">Import</a>
		</sec:authorize>
	</p>
</div>
<br/><br/>
<div>
	<table id="userCertTrainingTable" style="width: 100%;">
		<thead>
			<tr>
				<th class="textSearch">Name</th>
				<th class="textSearch">BemsId</th>
				<th class="textSearch">Class Name</th>
				<th class="textSearch">Class Number</th>
				<th class="centerColumn">Expiration In Days</th>
				<th class="centerColumn">Expiration In Months</th>
			</tr>
		</thead>
		<tbody></tbody>
	</table>
</div>
<!-- JDR: generic container -->
<div class="jdr-blockwidth">

	<!-- Add User Certification Training Modal Window -->
	<div id="addUserCertTrainingModal" title="Add">

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
		<form action="newUserCertTrainingAjax"
			name="newUserCertTrainingActionForm"
			id="newUserCertTrainingActionForm" method="POST">
			<fieldset>
				<label for="bemsId">BemsId:</label><br /> <input type="text"
					name="bemsId" id="bemsId"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
				<label for="className">Class Name:</label><br /> <input type="text"
					name="className" id="className"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
				<label for="classNumber">Class Number:</label><br /> <input
					type="text" name="classNumber" id="classNumber"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
			</fieldset>
		</form>
	</div>

	<!-- Modify User Certification Training Modal Window -->
	<div id="modifyUserCertTrainingModal" title="Modify">

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
		<form action="modifyUserCertTrainingAjax"
			name="modifyUserCertTrainingForm"
			id="modifyUserCertTrainingForm" method="POST">
			<fieldset>
				<input type="hidden" name="id" value=""
					class="text ui-widget-content ui-corner-all" /> <input
					type="hidden" name="version" value=""
					class="text ui-widget-content ui-corner-all" /> 
				<label for="className">BemsId:</label><br /> <input type="text"
					name="className" id="modifyBemsId"
					class="text ui-widget-content ui-corner-all" maxlength="50" /><br />
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

	<!-- Delete User Certification Training Modal Window -->
	<div id="deleteUserCertTrainingModal" title="Delete">

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
		<form action="deleteUserCertTrainingAjax"
			name="deleteUserCertTrainingForm"
			id="deleteUserCertTrainingForm" method="POST">
			<fieldset>
				<input type="hidden" name="id" value=""
					class="text ui-widget-content ui-corner-all" /> <input
					type="hidden" name="version" value=""
					class="text ui-widget-content ui-corner-all" /> 
				<label for="deleteBemsId">BemsId</label><br /> <span
					id="deleteBemsId" style="color: red;"></span><br /> 
				<label for="deleteName">Name</label><br /> <span
					id="deleteName" style="color: red;"></span><br /> 
				<label for="deleteClassName">Class Name:</label><br /> <span
					id="deleteClassName" style="color: red;"></span><br /> 
				<label for="deleteClassNumber">Class Number:</label><br /> <span
					id="deleteClassNumber" style="color: red;"></span><br /> 
				<label for="deleteExpirationInDays">Expiration In Days:</label><br /> <span
					id="deleteExpirationInDays" style="color: red;"></span><br /> 
				<label for="deleteExpirationInMonths">Expiration In Months:</label><br />
				<span id="deleteExpirationInMonths" style="color: red;"></span><br />
			</fieldset>
		</form>
	</div>

	<div id="importUserCertTraining" title="Import User Cert Training">
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
		<form action="importUserCertTraining" name="importForm"
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
