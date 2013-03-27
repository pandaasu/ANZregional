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
      document.main.QRY_Time.value = document.main.SLT_Time.value;
      document.main.QRY_Result.value = document.main.SLT_Result.value;
      document.main.QRY_Job.value = document.main.SLT_Job.value;
      document.main.QRY_Interface.value = document.main.SLT_Interface.value;
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
   function processInterface(strHeader,strTrace) {
      var strParameters;
      strParameters = 'Child=ics_int_detail.asp';
      strParameters = strParameters + '&QRY_Header=' + strHeader;
      strParameters = strParameters + '&QRY_Trace=' + strTrace;
      openWindow(strParameters);
   }
   function selectResult(objSelect) {
      document.main.SLT_Result.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectJob(objSelect) {
      document.main.SLT_Job.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectInterface(objSelect) {
      document.main.SLT_Interface.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_child.inc"-->
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_timestamp.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_eve_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Time (YYYYMMDDHHMISS):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_Time" size="14" maxlength="14" value="<%=objForm.Fields().Item("QRY_Time")%>" onFocus="setSelect(this);" onBlur="validateTimestamp(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Result:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltResult" onChange="selectResult(this);">
               <option value=""<%if objForm.Fields().Item("QRY_Result") = "" then%> selected<%end if%>>All
               <option value="*SUCCESS"<%if objForm.Fields().Item("QRY_Result") = "*SUCCESS" then%> selected<%end if%>>Success
               <option value="*ERROR"<%if objForm.Fields().Item("QRY_Result") = "*ERROR" then%> selected<%end if%>>Error
               <option value="*WARNING"<%if objForm.Fields().Item("QRY_Result") = "*WARNING" then%> selected<%end if%>>Warning
               <option value="*FATAL"<%if objForm.Fields().Item("QRY_Result") = "*FATAL" then%> selected<%end if%>>Fatal
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltJob" onChange="selectJob(this);">
               <option value=""<%if objForm.Fields().Item("QRY_Job") = "" then%> selected<%end if%>>All<%for i = 0 to clng(objSelection.ListCount("JOB")) - 1%>
               <option value="<%=objSelection.ListValue01("JOB",i)%>"<%if objForm.Fields().Item("QRY_Job") = objSelection.ListValue01("JOB",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("JOB",i)%>) <%=objSelection.ListValue02("JOB",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltInterface" onChange="selectInterface(this);">
               <option value=""<%if objForm.Fields().Item("QRY_Interface") = "" then%> selected<%end if%>>All<%for i = 0 to clng(objSelection.ListCount("INTERFACE")) - 1%>
               <option value="<%=objSelection.ListValue01("INTERFACE",i)%>"<%if objForm.Fields().Item("QRY_Interface") = objSelection.ListValue01("INTERFACE",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("INTERFACE",i)%>) <%=objSelection.ListValue02("INTERFACE",i)%><%next%>
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
                     <table class="clsTableHead" id="tabHead" align=left cols=14 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Event Time&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Result&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Identifier&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Number&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Group&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Procedure&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Identifier&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Number&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Trace&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Message&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Alert&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Email&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=13 cellpadding="0" cellspacing="1"><%if clng(objSelection.ListCount("LIST")) = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=13 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%for i = clng(objSelection.ListLower("LIST")) to clng(objSelection.ListUpper("LIST"))%>
                        <tr>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td <%if objSelection.ListValue02("LIST",i) = "*SUCCESS" then%>class="clsLabelFN"<%else%>class="clsLabelFR"<%end if%> align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%if objSelection.ListValue04("LIST",i) <> "" then%><a class="clsSelect" href="javascript:processJob('<%=objSelection.ListValue04("LIST",i)%>');"><%=objSelection.ListValue04("LIST",i)%></a><%else%><%=objSelection.ListValue04("LIST",i)%><%end if%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue08("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%if objSelection.ListValue09("LIST",i) <> "" then%><a class="clsSelect" href="javascript:processInterface('<%=objSelection.ListValue09("LIST",i)%>','<%=objSelection.ListValue10("LIST",i)%>');"><%=objSelection.ListValue09("LIST",i)%></a><%else%><%=objSelection.ListValue09("LIST",i)%><%end if%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue10("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue11("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue12("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue13("LIST",i)%></nobr></td>
                        </tr><%next%><%else%><%for i = clng(objSelection.ListUpper("LIST")) to clng(objSelection.ListLower("LIST")) step -1%>
                        <tr>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td <%if objSelection.ListValue02("LIST",i) = "*SUCCESS" then%>class="clsLabelFN"<%else%>class="clsLabelFR"<%end if%> align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%if objSelection.ListValue04("LIST",i) <> "" then%><a class="clsSelect" href="javascript:processJob('<%=objSelection.ListValue04("LIST",i)%>');"><%=objSelection.ListValue04("LIST",i)%></a><%else%><%=objSelection.ListValue04("LIST",i)%><%end if%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue08("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%if objSelection.ListValue09("LIST",i) <> "" then%><a class="clsSelect" href="javascript:processInterface('<%=objSelection.ListValue09("LIST",i)%>','<%=objSelection.ListValue10("LIST",i)%>');"><%=objSelection.ListValue09("LIST",i)%></a><%else%><%=objSelection.ListValue09("LIST",i)%><%end if%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue10("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue11("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue12("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue13("LIST",i)%></nobr></td>
                        </tr><%next%><%end if%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="STR_Sequence" value="<%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%=objSelection.ListValue14("LIST",objSelection.ListLower("LIST"))%><%else%><%=objSelection.ListValue14("LIST",objSelection.ListUpper("LIST"))%><%end if%>">
   <input type="hidden" name="END_Sequence" value="<%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%=objSelection.ListValue14("LIST",objSelection.ListUpper("LIST"))%><%else%><%=objSelection.ListValue14("LIST",objSelection.ListLower("LIST"))%><%end if%>">
   <input type="hidden" name="QRY_Time" value="<%=objForm.Fields().Item("QRY_Time")%>">
   <input type="hidden" name="QRY_Result" value="<%=objForm.Fields().Item("QRY_Result")%>">
   <input type="hidden" name="QRY_Job" value="<%=objForm.Fields().Item("QRY_Job")%>">
   <input type="hidden" name="QRY_Interface" value="<%=objForm.Fields().Item("QRY_Interface")%>">
   <input type="hidden" name="SLT_Result" value="<%=objForm.Fields().Item("QRY_Result")%>">
   <input type="hidden" name="SLT_Job" value="<%=objForm.Fields().Item("QRY_Job")%>">
   <input type="hidden" name="SLT_Interface" value="<%=objForm.Fields().Item("QRY_Interface")%>">
</form>
</body>
</html>