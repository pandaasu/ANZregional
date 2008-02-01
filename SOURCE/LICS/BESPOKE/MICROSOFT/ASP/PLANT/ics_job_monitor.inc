<html>
<script language="javascript">
<!--
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
      if (objElement.className == 'clsSelect') {
         objElement.className = 'clsSelectX';
      }
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
      if (objElement.className == 'clsSelectX') {
         objElement.className = 'clsSelect';
      }
   }
   function doSearch() {
      if (!processForm()) {return;}
      document.main.QRY_Execution.value = document.main.SLT_Execution.value;
      document.main.QRY_Test.value = document.main.SLT_Test.value;
      document.main.QRY_Job.value = document.main.SLT_Job.value;
      document.main.QRY_Group.value = document.main.SLT_Group.value;
      document.main.QRY_StrTime.value = document.main.SLT_StrTime.value;
      document.main.QRY_EndTime.value = document.main.SLT_EndTime.value;
      document.main.QRY_Status.value = document.main.SLT_Status.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SEARCH';
      document.main.submit();
   }
   function doPrevious() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'PREVIOUS';
      document.main.submit();
   }
   function doNext() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'NEXT';
      document.main.submit();
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function processJob(strExecution) {
      var strParameters;
      strParameters = 'Child=ics_job_detail.asp';
      strParameters = strParameters + '&QRY_Execution=' + strExecution;
      openWindow(strParameters);
   }
   function processGroup(strExecution) {
      var strParameters;
      strParameters = 'Child=ics_int_monitor.asp';
      strParameters = strParameters + '&QRY_Execution=' + strExecution;
      openWindow(strParameters);
   }
   function selectTest(strValue) {
      document.main.SLT_Test.value = strValue;
   }
   function selectJob(objSelect) {
      document.main.SLT_Job.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectGroup(objSelect) {
      document.main.SLT_Group.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectStatus(objSelect) {
      document.main.SLT_Status.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_child.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_timestamp.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_job_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltJob" onChange="selectJob(this);">
               <option value=""<%if objForm.Fields("QRY_Job").Value = "" then%> selected<%end if%>>All<%for i = 0 to objSelection.ListCount("JOB") - 1%>
               <option value="<%=objSelection.ListValue01("JOB",i)%>"<%if objForm.Fields("QRY_Job").Value = objSelection.ListValue01("JOB",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("JOB",i)%>) <%=objSelection.ListValue02("JOB",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltGroup" onChange="selectGroup(this);">
               <option value=""<%if objForm.Fields("QRY_Group").Value = "" then%> selected<%end if%>>All<%for i = 0 to objSelection.ListCount("GROUP") - 1%>
               <option value="<%=objSelection.ListValue01("GROUP",i)%>"<%if objForm.Fields("QRY_Group").Value = objSelection.ListValue01("GROUP",i) then%> selected<%end if%>><%=objSelection.ListValue01("GROUP",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_Execution" size="15" maxlength="15" value="<%=objForm.Fields("QRY_Execution").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
            <input type="radio" name="sltTest"<%if objForm.Fields("QRY_Test").Value = "EQ" then%> checked<%end if%> value="EQ" onClick="javascript:selectTest('EQ');">EQ&nbsp;
            <input type="radio" name="sltTest"<%if objForm.Fields("QRY_Test").Value = "LE" then%> checked<%end if%> value="LE" onClick="javascript:selectTest('LE');">LE&nbsp;
            <input type="radio" name="sltTest"<%if objForm.Fields("QRY_Test").Value = "GE" then%> checked<%end if%> value="GE" onClick="javascript:selectTest('GE');">GE&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Start Time (YYYYMMDDHHMISS):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_StrTime" size="14" maxlength="14" value="<%=objForm.Fields("QRY_StrTime").Value%>" onFocus="setSelect(this);" onBlur="validateTimestamp(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job End Time (YYYYMMDDHHMISS):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_EndTime" size="14" maxlength="14" value="<%=objForm.Fields("QRY_EndTime").Value%>" onFocus="setSelect(this);" onBlur="validateTimestamp(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltStatus" onChange="selectStatus(this);">
               <option value=""<%if objForm.Fields("QRY_Status").Value = "" then%> selected<%end if%>>All
               <option value="1"<%if objForm.Fields("QRY_Status").Value = "1" then%> selected<%end if%>>Working
               <option value="2"<%if objForm.Fields("QRY_Status").Value = "2" then%> selected<%end if%>>Idle
               <option value="3"<%if objForm.Fields("QRY_Status").Value = "3" then%> selected<%end if%>>Suspended
               <option value="4"<%if objForm.Fields("QRY_Status").Value = "4" then%> selected<%end if%>>Completed
               <option value="5"<%if objForm.Fields("QRY_Status").Value = "5" then%> selected<%end if%>>Aborted
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelUL" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSearch();">Search</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr><%if bolStrList = true then%>
                  <td align=left colspan=1 nowrap><nobr><font class="clsButtonD"><&nbsp;Prev&nbsp</font></nobr></td><%else%>
                  <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPrevious();"><&nbsp;Prev&nbsp</a></nobr></td><%end if%>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td><%if bolEndList = true then%>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbspNext&nbsp></font></nobr></td><%else%>
                  <td align=right colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doNext();">&nbspNext&nbsp></a></nobr></td><%end if%>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=9 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Job Number&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Job Identifer&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Job Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Group/Procedure&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;User&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Start Time&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;End Time&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Status&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=8 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("LIST") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=8 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%if objForm.Fields("Mode").Value <> "PREVIOUS" then%><%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:processJob('<%=objSelection.ListValue01("LIST",i)%>');"><%=objSelection.ListValue01("LIST",i)%></a></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%if objSelection.ListValue04("LIST",i) <> "*PROCEDURE" then%><a class="clsSelect" href="javascript:processGroup('<%=objSelection.ListValue01("LIST",i)%>');"><%=objSelection.ListValue04("LIST",i)%></a><%else%><%=objSelection.ListValue04("LIST",i)%><%end if%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                           <td class="<%=aryJobClass(objSelection.ListValue08("LIST",i))%>" align=center colspan=1 nowrap><nobr><%=aryJobStatus(objSelection.ListValue08("LIST",i))%></nobr></td>
                        </tr><%next%><%else%><%for i = objSelection.ListUpper("LIST") to objSelection.ListLower("LIST") step -1%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:processJob('<%=objSelection.ListValue01("LIST",i)%>');"><%=objSelection.ListValue01("LIST",i)%></a></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%if objSelection.ListValue04("LIST",i) <> "*PROCEDURE" then%><a class="clsSelect" href="javascript:processGroup('<%=objSelection.ListValue01("LIST",i)%>');"><%=objSelection.ListValue04("LIST",i)%></a><%else%><%=objSelection.ListValue04("LIST",i)%><%end if%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                           <td class="<%=aryJobClass(objSelection.ListValue08("LIST",i))%>" align=center colspan=1 nowrap><nobr><%=aryJobStatus(objSelection.ListValue08("LIST",i))%></nobr></td>
                        </tr><%next%><%end if%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="STR_Execution" value="<%if objForm.Fields("Mode").Value <> "PREVIOUS" then%><%=objSelection.ListValue01("LIST",objSelection.ListLower("LIST"))%><%else%><%=objSelection.ListValue01("LIST",objSelection.ListUpper("LIST"))%><%end if%>">
   <input type="hidden" name="END_Execution" value="<%if objForm.Fields("Mode").Value <> "PREVIOUS" then%><%=objSelection.ListValue01("LIST",objSelection.ListUpper("LIST"))%><%else%><%=objSelection.ListValue01("LIST",objSelection.ListLower("LIST"))%><%end if%>">
   <input type="hidden" name="QRY_Execution" value="<%=objForm.Fields("QRY_Execution").Value%>">
   <input type="hidden" name="QRY_Test" value="<%=objForm.Fields("QRY_Test").Value%>">
   <input type="hidden" name="QRY_Job" value="<%=objForm.Fields("QRY_Job").Value%>">
   <input type="hidden" name="QRY_Group" value="<%=objForm.Fields("QRY_Group").Value%>">
   <input type="hidden" name="QRY_StrTime" value="<%=objForm.Fields("QRY_StrTime").Value%>">
   <input type="hidden" name="QRY_EndTime" value="<%=objForm.Fields("QRY_EndTime").Value%>">
   <input type="hidden" name="QRY_Status" value="<%=objForm.Fields("QRY_Status").Value%>">
   <input type="hidden" name="SLT_Job" value="<%=objForm.Fields("QRY_Job").Value%>">
   <input type="hidden" name="SLT_Group" value="<%=objForm.Fields("QRY_Group").Value%>">
   <input type="hidden" name="SLT_Test" value="<%=objForm.Fields("QRY_Test").Value%>">
   <input type="hidden" name="SLT_Status" value="<%=objForm.Fields("QRY_Status").Value%>">
</form>
</body>
</html>