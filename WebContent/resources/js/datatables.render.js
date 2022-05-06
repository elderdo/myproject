/**
 * Rewrite DataTable's render text function to better handle null or undefined data
 */
$.fn.dataTable.render.text = function() {
  return {
    _ : sanitizeUndefinedOrNullString,
    display : function(data) {
      var out = sanitizeUndefinedOrNullString(data);
      return $("<span/>").text(out).html();
    }
  };
};
/**
 * Renders data as text that shows line breaks
 * @return {object}
 */
$.fn.dataTable.render.textWithLineBreaks = function() {
  return {
    _ : sanitizeUndefinedOrNullString,
    display : function(data) {
      var out = sanitizeUndefinedOrNullString(data);
      return $("<span style='white-space: pre-wrap'>").text(out).prop("outerHTML");
    }
  };
};

/**
 * Renders data as a checkbox
 * @param  {object} Object representing the following params. Any param not supplied will use the default.
 *         condition {boolean || function} [condition = function(data) {return data;}] Boolean or 
 *             function used to determine truthiness of data. Set to false if value cannot be determined
 *         enable {boolean || function} [false] Boolean or function used to determine if checkbox 
 *             should be enabled. Set to false if value cannot be determined
 *         name {string} [name = ""] Name of the input
 *         textForTrue {string} [textForTrue = "Yes"] Text to use when data is true
 *         textForFalse {string} [textForFalse = "No"] Text to use when data is false
 
 * @return {object}
 */
$.fn.dataTable.render.checkbox = function(params) {
  
  //Set the default parameters
  var defaults = {
      condition : function(data) {return data;},
      enable : false,
      name : "",
      textForTrue : "Yes",
      textForFalse : "No"
  };
  
  //Merge the default parameters with the input parameters. Any input parameters specified will
  //overwrite the default values
  var mergedParams = Object.assign(defaults, params);
  
  //Write function to check the condition to see if data is true or false
  //Determine the condition boolean to use.
  //If condition is a function, evaluate the function
  //If condition is a boolean, use the boolean
  //Otherwise, default to false
  var checkCondition = function(data, type, row) {
    if (typeof mergedParams.condition === "function") {
      conditionBool = mergedParams.condition(data, type, row);
    } else if (typeof mergedParams.condition === "boolean") {
      conditionBool = mergedParams.condition;
    } else {
      console.error("Bad checkbox checked condition: " + mergedParams.condition);
      conditionBool = false;
    }
    
    return conditionBool;
  };
  
  return {
    _ : function(data, type, row) {
      return checkCondition(data, type, row) ? mergedParams.textForTrue : mergedParams.textForFalse;
    },
    display : function(data, type, row) {
      //Determine the enable boolean to use.
      //If enable is a function, evaluate the function
      //If enable is a boolean, use the boolean
      //Otherwise, default to false
      var enableBool;
      if (typeof mergedParams.enable === "function") {
        enableBool = mergedParams.enable(data, type, row);
      } else if (typeof mergedParams.enable === "boolean") {
        enableBool = mergedParams.enable;
      } else {
        console.error("Bad checkbox enable condition: " + mergedParams.enable);
        enableBool = false;
      }
      
      var checkbox = "<input type='checkbox' ";
      
      //If there is a name parameter, add it to the html
      if (mergedParams.name) {
        checkbox += "name='" + mergedParams.name + "' ";
      }
      
      //If enableBool is not truthy, disable the checkbox
      if (!enableBool) {
        checkbox += "disabled ";
      }
      
      //If the condition is met, check the checkbox
      if (checkCondition(data, type, row)) {
        checkbox += "checked='checked' ";
      }
      
      checkbox += "/>";
      
      return checkbox;
    }
  };
};

/**
 * Renders data as a list. If data has a header, data must be an object with a [list] and [header] property.
 * @return {object}
 */
$.fn.dataTable.render.list = function() {
  var getHeader = function(data) {
    if (typeof data == 'object' && data.hasOwnProperty("header")) {
      return data.header;
    }
    return null;
  };
  
  var getList = function(data) {
    var list = data;
    if (typeof data == 'object' && data.hasOwnProperty("list")) {
      list = data.list;
    }
    
    if (typeof list == 'undefined' || list === null) {
      return "";
    }
    
    //Return empty string if data is not an array
    if (!Array.isArray(list)) {
      console.error("Data is not an array");
      return "";
    }
    
    //Prepend header if there is one
    var header = getHeader(data);
    if (header) {
      list.unshift(header);
    }
    
    return list;
  };
  
  return {
    _ : function(data) {
      var arr = getList(data);
      if (arr === "") {
        return "";
      }
      return arr.join(", ");
    },
    display : function(data) {
      var arr = getList(data);
      if (arr === "") {
        return "";
      }
      var span = $("<span/>");
      arr.forEach(function(elem, index, array) {
        array[index] = span.text(elem).html();
      })
      if (getHeader(data)) {
        arr[0] = "<b>" + arr[0] + "</b>";
      }
      return arr.join("<br/>");
    }
  };
};

/**
 * Renders text with supplied CSS styles
 * @param  {string || object || function} [input = ""] If string or object, apply the styles to the text.
 *             If string, styles are in the format "color: red; font-weight: bold". 
 *             If object styles are in the format { "color": "red", "font-weight" : "bold" } or 
 *                 { color: "red", fontWeight : "bold" }.
 *             If function, function should return a string or object that specifies the styles to apply.
 *                 The returned string or object should be in the format listed above.
 * @return {object}
 */
$.fn.dataTable.render.cssText = function(input = "") {
  return {
    _ : sanitizeUndefinedOrNullString,
    display : function(data, type, row) {
      //Determine CSS styles
      var styles;
      if (typeof input === "function") {
        styles = input(data, type, row);
      } else {
        styles = input;
      }
        
      //Render styles as object, string, or no style
      var out = sanitizeUndefinedOrNullString(data);
      if (typeof styles === "object") {
        return $("<span/>").text(out).css(styles).prop("outerHTML");
      } else if (typeof styles === "string" && styles !== "") {
        return $("<span/>").text(out).attr("style", styles).prop("outerHTML");
      } else {
        return $("<span/>").text(out).prop("outerHTML");
      }
    }
  };
};
  
/**
 * Renders Part Number with Part Icon next to it. Data must be object with a partNumber and an id.
 * @param  {integer} [tab] What 0-indexed tab to open on Part Information. By default, tab is undefined,
 * which is equivalent to setting tab = 0.
 * @param {string} [dom] The layout of the icon and Part. By default, 
 * icon goes before Part with a space in between. Key:
 *    [i]: Part Icon (link to Part Information)
 *    [P]: Part Number
 *    [ ]: Space
 *    [U]: Underlined Part Number (link to Part Information)
 *    [!]: Show warning when no Id is given
 * @return {object}
 */
$.fn.dataTable.render.part = function(tab, dom = 'i P') {
  dom = dom.toLowerCase();
  return {
    _ : function(data) {
      if (data === null || data === undefined) {
        return "";
      }
      if (typeof data !== 'object') {
        console.error("Invalid part render data");
        return "";
      }
      if (!data.hasOwnProperty("partNumber")) {
        return "";
      }
      return sanitizeUndefinedOrNullString(data.partNumber);
    },
    display : function(data) {
      if (data === null || data === undefined) {
        return "";
      }
      if (typeof data !== 'object') {
        console.error("Invalid part render data");
        return "";
      }
      
      var partNumber = "";
      if (data.hasOwnProperty("partNumber")) {
        partNumber = sanitizeUndefinedOrNullString(data.partNumber);
        partNumber = $("<span/>").text(partNumber).html();
      }
      
      var icon = "";
      var ulPart = "";
      var id;
      if (data.hasOwnProperty("id")) {
        id = data.id;
        if (id) {
          const path = window.location.pathname.split("/", 3);
          var href = "/" + path[1] + "/" + path[2] + "/parts/index.html?id=" + id;
          if (tab) {
            href = href + "&selectedTab=" + tab;
          }
          var aTag = $('<a target="_blank"></a>').attr("href", href);
          
          icon = aTag.html(
              '<img class="partInfo" ' +
              'src="/prime/resources/images/Info.png" ' + 
              'title="View Part Info" ' +
              'style="height:14px; display:inline; cursor:pointer;">'
              ).prop("outerHTML");
          ulPart = aTag.text(partNumber).prop("outerHTML");
        }
      }
      
      var warning = "";
      if (!id) {
        warning = "<img class='partWarning' " +
        		"src='/prime/resources/images/warning.png' " +
        		"title='Unmatched Part' " +
        		"style='height:14px; display:inline; cursor:help;'/>";
      }
      
      var out = "";
      for (var i = 0; i < dom.length; i++) {
        var c = dom.charAt(i);
        switch (c) {
          case 'i':
            out = out + icon;
            break;
          case 'p':
            out = out + partNumber;
            break;
          case ' ':
            out = out + " ";
            break;
          case 'u':
            out = out + ulPart;
            break;
          case '!':
            out = out + warning;
            break;
        }
      }
      
      return out;
    }
  }
};

/**
 * Renders SubTask with A/D icons next to it. Data should include text, effSubTaskId, and optionally, effStepId.
 * @param  {integer} [tab] What 0-indexed tab to open on Part Information. 
 * By default, tab is 0 if no effStepId is provided, and 1 if it is provided.
 * @param {string} [dom] The layout of the icon and Part. By default, 
 * icon goes before Part with a space in between. Key:
 *    [A]: Authoring icon (link to Authoring)
 *    [D]: Delivery icon (link to Delivery)
 *    [ ]: Space
 *    [T]: Text (or Task) to show
 * @return {object}
 */
$.fn.dataTable.render.subTask = function(tab, dom = 'A D T') {
  dom = dom.toLowerCase();
  return {
    _ : function(data) {
      if (data === null || data === undefined) {
        return "";
      }
      if (typeof data !== 'object') {
        console.error("Invalid subTask render data");
        return "";
      }
      if (!data.hasOwnProperty("text")) {
        return "";
      }
      return sanitizeUndefinedOrNullString(data.text);
    },
    display : function(data) {
      if (data === null || data === undefined) {
        return "";
      }
      if (typeof data !== 'object') {
        console.error("Invalid part render data");
        return "";
      }
      
      var subTask = "";
      if (data.hasOwnProperty("text")) {
        subTask = sanitizeUndefinedOrNullString(data.text);
        subTask = $("<span/>").text(subTask).html();
      }
      
      var aIcon = "";
      var dIcon = "";
      if (data.hasOwnProperty("effSubTaskId")) {
        var effSubTaskId = data.effSubTaskId;
        if (effSubTaskId) {
          var effStepId = null;
          if (data.hasOwnProperty("effStepId")) {
            effStepId = data.effStepId;
          }
          var hrefTab = 0;
          if (tab !== null && tab !== undefined) {
            hrefTab = tab;
          }
          else if (effStepId) {
            hrefTab = 1;
          }
          const path = window.location.pathname.split("/", 3);
          var aHref = "/" + path[1] + "/" + path[2] + "/workInstr/authoring.html?effSubTaskId=" + effSubTaskId;
          var dHref = "/" + path[1] + "/" + path[2] + "/workInstr/delivery.html?effSubTaskId=" + effSubTaskId;
          if (effStepId) {
            aHref = aHref + "&effStepId=" + effStepId;
            dHref = dHref + "&effStepId=" + effStepId;
          }
          if (hrefTab) {
            aHref = aHref + "&selectedTab=" + hrefTab;
            dHref = dHref + "&selectedTab=" + hrefTab;
          }
          
          var aTag = $('<a target="_blank"></a>').attr("href", aHref);
          aIcon = aTag.html(
              '<img class="authLink" ' +
              'src="/prime/resources/images/A-icon.png" ' + 
              'title="Open Authoring" ' +
              'style="height:14px; display:inline; cursor:pointer;">'
              ).prop("outerHTML");
          
          aTag.attr("href", dHref);
          dIcon = aTag.html(
              '<img class="delvLink" ' +
              'src="/prime/resources/images/D-icon.png" ' + 
              'title="Open Delivery" ' +
              'style="height:14px; display:inline; cursor:pointer;">'
              ).prop("outerHTML");
        }
      }
      
      var out = "";
      for (var i = 0; i < dom.length; i++) {
        var c = dom.charAt(i);
        switch (c) {
          case 'a':
            out = out + aIcon;
            break;
          case 'd':
            out = out + dIcon;
            break;
          case ' ':
            out = out + " ";
            break;
          case 't':
            out = out + $.fn.dataTable.render.text().display(subTask);
            break;
        }
      }
      
      return out;
    }
  }
};