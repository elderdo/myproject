$.fn.dataTableExt.oApi.fnReloadAjax = function ( oSettings, sNewSource, fnCallback, bStandingRedraw ) {
    if ( typeof sNewSource != 'undefined' && sNewSource != null ) {
        oSettings.sAjaxSource = sNewSource;
    }
 
    // Server-side processing should just call fnDraw
    if ( oSettings.oFeatures.bServerSide ) {
        this.fnDraw();
        return;
    }
 
    this.oApi._fnProcessingDisplay( oSettings, true );
    var that = this;
    var iStart = oSettings._iDisplayStart;
    var aData = [];
  
    this.oApi._fnServerParams( oSettings, aData );
      
    oSettings.fnServerData.call( oSettings.oInstance, oSettings.sAjaxSource, aData, function(json) {
        /* Clear the old information from the table */
        that.oApi._fnClearTable( oSettings );
          
        /* Got the data - add it to the table */
        var aData =  (oSettings.sAjaxDataProp !== "") ?
            that.oApi._fnGetObjectDataFn( oSettings.sAjaxDataProp )( json ) : json;
          
        for ( var i=0 ; i<aData.length ; i++ ) {
            that.oApi._fnAddData( oSettings, aData[i] );
        }
          
        oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();
          
        if ( typeof bStandingRedraw != 'undefined' && bStandingRedraw === true ) {
            oSettings._iDisplayStart = iStart;
            that.fnDraw( false );
        } else {
            that.fnDraw();
        }
          
        that.oApi._fnProcessingDisplay( oSettings, false );
          
        /* Callback user function - for event handlers etc */
        if ( typeof fnCallback == 'function' && fnCallback != null ) {
            fnCallback( oSettings );
        }
    }, oSettings );
};

jQuery.validator.addMethod("integer", function(value, element) {
    return this.optional(element) || (parseFloat(value) == Math.floor(parseFloat(value)));
}, "* must not be a decimal.");

jQuery.validator.addMethod("selectionRequired", function(value, element) {
    return (value != null && value != "" && value != "-1" && value != -1);
}, "* requires a selection.");

jQuery.validator.addMethod("positiveNumber", function (value) {
    return Number(value) >= 0;
}, "Enter a positive number");

jQuery.validator.addMethod("formattedDate", function(value, element) {
    if(value.length > 0)  {
    return value.match(/^\d\d?\/\d\d?\/\d\d\d\d$/);
    }
    else  { return "ok";
    }
}, "Please enter a date in the format dd/mm/yyyy.");

jQuery.validator.addMethod("time", function (value, element) {
    return this.optional(element) || /^(([0-1]?[0-9])|([2][0-3])):([0-5]?[0-9])(:([0-5]?[0-9]))?$/i.test(value);
}, "Please enter a valid time in format HH:mm");

jQuery.validator.addMethod("lettersOrNumbers", function (value, element) {
	return this.optional(element) || value.match(/^[a-zA-Z0-9]*$/);
}, "Please use only letters (a-z, A-Z) or numbers (0-9).");

jQuery.validator.addMethod("requireOne", function (value, element) {
	return $(".require-one:checked").size() > 0;
}, "At least one selection is required.");

jQuery.validator.addMethod("requireOnlyOne", function (value, element) {
	return $(".require-one:checked").size() <= 1;
}, "Only one selection can be selected.");

/** Since this is based on $.serializeArray, all form elements must have a name attribute for this to work.*/
$.fn.serializeObject = function() {
	var o = {};
	var a = this.serializeArray();
	$.each(a, function() {
		if (o[this.name] !== undefined) {
			if (!o[this.name].push) {
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else {
			o[this.name] = this.value || '';
		}
	});
	return o;
};

function dateFormat(date) {
	if (date == null ){
		return '';
	}
	return $.format.date(date, 'MM/dd/yyyy');
}

function setDisabled(selectorString, doDisable) {
	if(doDisable) {
		$(selectorString).attr("disabled", "disabled");
		$(selectorString).addClass("disabled");
	} else {
		$(selectorString).removeAttr("disabled");
		$(selectorString).removeClass("disabled");
	}
}

function msieBrowser() {
  var ua = window.navigator.userAgent;
  var msie = ua.indexOf("MSIE ");

  if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) {
    return true;
  }

   return false;
}

function isDate(txtDate) {
  var currVal = txtDate; 
  if(currVal == '') 
    return false; 
  //Declare Regex   
  var rxDatePattern = /^(\d{1,2})(\/)(\d{1,2})(\/)(\d{4})$/;  
  var dtArray = currVal.match(rxDatePattern); // is format OK? 
  if (dtArray == null)  
     return false; 
  //Checks for mm/dd/yyyy format. 
  dtMonth = dtArray[1]; 
  dtDay= dtArray[3]; 
  dtYear = dtArray[5]; 
  if (dtMonth < 1 || dtMonth > 12) 
      return false; 
  else if (dtDay < 1 || dtDay> 31)  
      return false; 
  else if ((dtMonth==4 || dtMonth==6 || dtMonth==9 || dtMonth==11) && dtDay ==31) 
      return false; 
  else if (dtMonth == 2) 
  {
     var isleap = (dtYear % 4 == 0 && (dtYear % 100 != 0 || dtYear % 400 == 0)); 
     if (dtDay> 29 || (dtDay ==29 && !isleap)) 
          return false; 
  } 
  return true; 
}

function allowBarCodeScan() {
  // Function to catch the "control" key in any of the input fields and ignore them
  $("input").on("keydown", function (event) {
    // check if user pressed ctrl-f5 - probably from prox reader
    if ((event.keyCode == 116) && event.ctrlKey) {
      event.keyCode = 0;
      return false;
    }
    // check if user pressed ctrl-f6 - probably from barcode scan
    else if ((event.keyCode == 117) && event.ctrlKey) {
      event.keyCode = 0;
      return false;
    }
    // check if user pressed ctrl-f7 - probably from prox reader
    else if ((event.keyCode == 118) && event.ctrlKey) {
      var inputs = $(this).closest('form').find(':focusable');
      inputs.eq(inputs.index(this) + 1).focus();
      return false;
    }
    // check if user pressed ctrl-f8 - probably from barcode scan
    else if ((event.keyCode == 119) && event.ctrlKey) {
      var inputs = $(this).closest('form').find(':focusable');
      inputs.eq(inputs.index(this) + 1).focus();
      return false;
    }
  });    
}

//Pass in either file name or extension
function getImageNameForFileExtension(filename) {
  var extension = filename.substr(filename.lastIndexOf(".") + 1).toLowerCase();
  var name = "arrow_blue_down.png";
  //https://en.wikipedia.org/wiki/List_of_Microsoft_Office_filename_extensions
  const wordExtensions = [
    "doc", "dot", "wbk", "docx", "docm", "dotx", "dotm", "docb"
  ];
  const ppExtensions = [
    "ppt", "pot", "pps", "pptx", "pptm", "potx", "potm", "ppam", "ppsx", "ppsm", "sldx", "sldm"
  ];
  const excelExtensions = [
    "xls", "xlt", "xlm", "xlsx", "xlsm", "xltx", "xltm", "xlsb", "xla", "xlam", "xll", "xlw"
  ];
  const pdfExtensions = [
    		"pdf", "fdf", "pdfxml", "xdp", "xfdf"
  ];
  const txtExtensions = [
    		"txt", "ini", "log", "scp", "wtx"
  ];
  const imgExtensions = [
    		"gif", "jpeg", "jpg", "png", "tif", "tiff"
  ];
  const oneNoteExtensions = [
    		"one", "onepkg", "onetoc", "onetoc2"
  ];
  const visioExtensions = [
    		"vsd", "vsdx", "vss", "vst", "vdw", "vdx", "vtx", "vsdm", "vssx", "vssm", "vstx", "vstm", "vsl"
  ];
  
  if (ppExtensions.indexOf(extension) > -1) {
    name = "ppt-icon.gif";
  }
  else if (wordExtensions.indexOf(extension) > -1) {
    name = "word-icon.gif";
  }
  else if (excelExtensions.indexOf(extension) > -1) {
    name = "xls-icon.gif";
  }
  else if (pdfExtensions.indexOf(extension) > -1) {
    name = "pdf-icon.gif";
  }
  else if (txtExtensions.indexOf(extension) > -1) {
    name = "txt-icon.gif";
  }
  else if (imgExtensions.indexOf(extension) > -1) {
    name = "img-icon.gif";
  }
  else if (oneNoteExtensions.indexOf(extension) > -1) {
    name = "one-icon.gif";
  }
  else if (visioExtensions.indexOf(extension) > -1) {
    name = "vsd-icon.gif";
  }
  else if (extension == "vf") {
    name = "vf-icon.gif";
  }
  return "/prime/resources/images/" + name;
}

//https://stackoverflow.com/questions/20830309/download-file-using-an-ajax-request/49674385#49674385
function downloadURL(url, callback, successCb, errorCb) {
  var req = new XMLHttpRequest();
  req.open("GET", url, true);
  req.responseType = "blob";

  req.onload = function (event) {
    if (req.status !== 200) {
      var errorType = "Server ";
      if (req.status === 400) {
        errorType = "";
      }
      if (req.status === 401) {
        errorType = "Security ";
      }
      if (errorCb) {
        errorCb(errorType);
      }
      else {
        alert(errorType + "Error downloading File.");
      }
    }
    else {
      var el = $("<a style='display:none;'></a>");
      try { 
        var blob = req.response;
        var fileName = null;
        var contentType = req.getResponseHeader("content-type");
    
        // IE/EDGE seems not returning some response header
        if (req.getResponseHeader("content-disposition")) {
          var contentDisposition = req.getResponseHeader("content-disposition");
          fileName = contentDisposition.substring(contentDisposition.indexOf("=")+1);
        } else {
          fileName = "FILE." + contentType.substring(contentType.indexOf("/")+1);
        }
    
        if (window.navigator.msSaveOrOpenBlob) {
          // Internet Explorer
          window.navigator.msSaveOrOpenBlob(new Blob([blob], {type: contentType}), fileName);
        } else {
          document.body.appendChild(el[0]);
          el.attr("href", window.URL.createObjectURL(blob));
          el.attr("download", fileName);
          el[0].click();
        }
        el.remove();
        if (successCb) {
          successCb();
        }
      } 
      catch(ex) {
        el.remove();
        console.error(ex);
        if (errorCb) {
          errorCb("Browser");
        }
        else {
          alert("Error opening File.");
        }
     }
   }
   if (callback) {
     callback(); //Happens after success or error.
   }
  };
  req.send();
}

function getPartIcon(id, tab) {
  if (!id) {
    return "";
  }
  const path = window.location.pathname.split("/", 3);
  var href = "/" + path[1] + "/" + path[2] + "/parts/index.html?id=" + id;
  if (tab) {
    href = href + "&selectedTab=" + tab;
  }
  return ' <a href="' + href +
  '" target="_blank"><img class="partInfo" ' +
  'src="/prime/resources/images/Info.png" ' + 
  'title="View Part Info" ' +
  'style="height:14px; display:inline; cursor:pointer;"></a> '
}

function persistInputsWithLocalStorage(className) {
  if (!className) {
    className = "primeStateSave";
  }
  var inputs = $("." + className + ":input");
  var path = window.location.pathname;
  
  var out = {};
  
  $(inputs).each(function() {
    var id = $(this).attr("id");
    if (!id) {
      console.error("Every input must have an ID attribute for its state to save in local storage.");
      return;
    }
    var storageKey = path + " " + id;
    var stateSaveParam = localStorage.getItem(storageKey);
    out[id] = stateSaveParam;
    
    if ($(this).is("input[type=checkbox]")) {
      if (stateSaveParam !== null) {
        if (stateSaveParam == $(this).val()) {
          $(this).prop("checked", true);
        }
        else {
          $(this).prop("checked", false);
        }
      }
      
      $(this).on("change input updateLocalStorage", function() {
        var value = $(this).prop("checked") ? $(this).val() : "";
        localStorage.setItem(storageKey, value);
        //console.log(localStorage.getItem(storageKey));
      });
    }
    else {
      if (stateSaveParam !== null) {
        $(this).val(stateSaveParam);
      }
      
      $(this).on("change input updateLocalStorage", function() {
        var value = $(this).val() ? $(this).val() : "";
        localStorage.setItem(storageKey, value);
        //console.log(localStorage.getItem(storageKey));
      });
    }
  });
  return out;
}

$(function() {
  allowBarCodeScan();    
});

//If element is a select and it has at least 2 options,
//enable it (first option is blank). Otherwise, disable it.
$.fn.disableSelectIfEmpty = function() {
if (this.is('select')) {
   if ($('option', this).length > 1) {
       setDisabled(this, false);
   } else {
       setDisabled(this, true);
   }
}
}

$.fn.enableUiElement = function() {
	this.prop("disabled", false);
  this.removeClass("ui-state-disabled");
}

$.fn.disableUiElement = function() {
	this.prop("disabled", true);
  this.addClass("ui-state-disabled");
}

//Global functions to help prevent double form submissions from modals

$(document).on("click", ".ui-button", function(e) {
  var buttonDelay = 300;
  var button = $(this);
  button.addClass("pushed_button");
  setTimeout(function() { 
    button.removeClass("pushed_button");
  }, buttonDelay);
});

var ajaxUrlToDialog = new Map();

$(document).on("dialogcreate", function(e) {
  var modal = $(e.target);
  var dialog = $(modal).closest(".ui-dialog");
  var form = $("form", modal);
  
  $(modal).on("dialogopen", function() {
    $(form).each(function() {
      var url = $(this).attr("action");
      ajaxUrlToDialog.set(url, dialog);
    });
    $(".ui-dialog-buttonset", dialog).children().button("enable");
  });
});

$(document).ajaxSend(function( event, request, settings ) {
  var url = settings.url;
  //console.log("OUTGOING " + url);
  var dialog = ajaxUrlToDialog.get(url);
  if (dialog) {
    $(".ui-dialog-buttonset", dialog).children().button("disable");
    $("body").addClass("modal_processing");
  }
});

$(document).ajaxComplete(function( event, request, settings ) {
  var url = settings.url;
  //console.log("INCOMING " + url);
  var dialog = ajaxUrlToDialog.get(url);
  if (dialog) {
    $(".ui-dialog-buttonset", dialog).children().button("enable");
    $("body").removeClass("modal_processing");
  }
});

function sanitizeUndefinedOrNullString(str) {
  return (typeof str == 'undefined' || str === null) ? "" : str;
}
