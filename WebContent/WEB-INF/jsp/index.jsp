<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="joda" uri="http://www.joda.org/joda/time/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<script >
  $("document").ready(function() {

    $("#orphanedPartsModal").dialog({
        bgiframe: true,
        autoOpen: false,
        width: 350,
        modal: true,
        buttons: {
            Close : function() { 
            // close the dialog
            $(this).dialog('close'); 
          }
        }
    });

    $("#orphanPartsAlert").click(function() {
      $("#orphanedPartsModal").dialog("open");
    });

    $("#orphanedPartsTable").dataTable({
        "bPaginate": false, 
        "bInfo": false,
        "bFilter": false
      });
    
  });
</script>

<style>
.collapsible {
  background-color: #555;
  color: white;
  cursor: pointer;
  padding: 5px;
  width: 99%;
  border: none;
  text-align: left;
  outline: none;
  font-size: 15px;
}

.content {
  width: 99%;
  overflow: hidden;
  background-color: #f1f1f1;
}

.content ul li {
	padding:2px;
}
</style>

<c:if test="${ not empty systemMessages}">
<button type="button" class="collapsible">System Messages : </button>
<div class="content" >
<ul>
<c:forEach var="message" items="${ systemMessages }" >
  <li>
    <c:out value="${message.message }" escapeXml="false"></c:out>
  </li>
</c:forEach>
</ul>
</div>
</c:if>

<table class="messageTable">
  <tr>
    <th>Messages:</th>
  </tr>
  <tr>
    <td><c:out value="${program.message}"></c:out></td>
  </tr>
</table>

<br/><br/>
<ul id="dashboardList">
	<c:if test="${chargingTo != null}">
	<li>
	  <b><font style="color: red;">You are charging to ${chargingTo} 
	    <a href="/prime/${otherProgram}/workInstr/delivery?effSubTaskId=${subTaskInWork.id}&selectedTab=0">View here</a>
	  </font></b>
	</li>
	</c:if>
	
	<c:if test="${needRRCount > 0}">
	<li>
	  <b><font style="color: red;">You are responsible for <c:out value="${needRRCount}"/> Parts that need requirements release.
	  <sec:authorize access="primeAccess('PART_VIEW || PROC_PRG_VIEW')">
        <a href="/prime/${programName.name}/needReqRel/index?showWhat=${bemsId}&panstock=true">View here</a>
      </sec:authorize>
	  </font></b>
	</li>
	</c:if>
	
	<c:if test="${nullTaskCount > 0}">
	<li>
	  <b><font style="color: red;"><c:out value="${nullTaskCount}"/> Tasks need a Jig Load Date.
	  <sec:authorize access="primeAccess('ADMIN_TASK')">
	    <a href="/prime/${programName.name}/admin/effectivityTask/effectivityTasks">View here</a>
	  </sec:authorize>
	  </font></b>
	</li>
	</c:if>
	
	<sec:authorize access="primeAccess('WI_QUALITY')">
	  <c:if test="${qrCount > 0}">
		<li>
	  <b><font style="color: red;"><c:out value="${qrCount}"/> Subtasks need Review.
	    <a href="/prime/${programName.name}/workInstr/delivery/taskDetails?defaultStatus=Quality%20Review">View here</a>
	  </font></b>
	  </li>
	  </c:if>
	</sec:authorize>
	
	<c:if test="${!empty parts}">
	<li>
	  <b><font style="color: red;">Orphaned Parts exist. 
	    <a id="orphanPartsAlert" href="#">View here</a>
	  </font></b>
	</li>
	</c:if>
	
	<c:if test="${calDueNow != 0}">
	<li>
	  <b><font style="color: red;"><c:out value="${calDueNow}"/> Calibrations overdue.
	  <sec:authorize access="primeAccess('CALIBRATION_VIEW')">
	    <a href="/prime/${programName.name}/property/calibration">View here</a>
	  </sec:authorize>
	  </font></b>
	</li>
	</c:if>
	
	<c:if test="${calDueSoon != 0}">
  <li>
    <b><font style="color: red;"><c:out value="${calDueSoon}"/> Calibrations due soon.
    <sec:authorize access="primeAccess('CALIBRATION_VIEW')">
      <a href="/prime/${programName.name}/property/calibration">View here</a>
    </sec:authorize>
    </font></b>
  </li>
  </c:if>
</ul>

<table class="activityTable">
  <tr>
    <th>
      Activity:
    </th>
    <th>
      Last Update:
    </th>
    <th>
      &nbsp;
    </th>
  </tr>
  <c:forEach var="programActivity" items="${programActivities}" >
    <tr>
      <td>${programActivity.activity.activity}</td>
      <td><joda:format value="${programActivity.latestActivityHistory.completedDateTime}" pattern="MM/dd/YYYY hh:mm:ss a"/>
      <c:choose>
        <c:when test="${programActivity.activityCurrent == true}">
          <td>&nbsp;</td>
        </c:when>
        <c:otherwise>
          <td class="activityTableLate">Warning: Activity is Late!</td>
        </c:otherwise>
      </c:choose>
    </tr>
  </c:forEach>
  
</table>

<div id="orphanedPartsModal" title="Orphaned Parts">
  <table id="orphanedPartsTable">
    <thead>
      <tr>
        <th>Part Number</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="part" items="${parts}"> 
  
        <tr><td><a href="parts/index?id=<c:out value='${part.id}'/>&selectedTab=3"><c:out value="${part.partNumber}"/></a></td></tr>   
      
      </c:forEach>
    </tbody>
  
  </table>
</div>


