<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_JobJob.focus();<%if strReturn <> "*OK" then%>
      alert('<%=strReturn%>');<%else%>return;<%end if%>
   }
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
   }
   function checkChange() {
      var bolChange = false;
      var bolReturn;
      if (document.main.INP_JobJob.value != document.main.DTA_JobJob.value) {bolChange = true;}
      if (document.main.INP_JobDescription.value != document.main.DTA_JobDescription.value) {bolChange = true;}
      if (document.main.INP_JobResGroup.value != document.main.DTA_JobResGroup.value) {bolChange = true;}
      if (document.main.INP_JobExeHistory.value != document.main.DTA_JobExeHistory.value) {bolChange = true;}
      if (document.main.INP_JobOprAlert.value != document.main.DTA_JobOprAlert.value) {bolChange = true;}
      if (document.main.INP_JobEmaGroup.value != document.main.DTA_JobEmaGroup.value) {bolChange = true;}
      if (document.main.INP_JobType.value != document.main.DTA_JobType.value) {bolChange = true;}
      if (document.main.INP_JobIntGroup.value != document.main.DTA_JobIntGroup.value) {bolChange = true;}
      if (document.main.INP_JobProcedure.value != document.main.DTA_JobProcedure.value) {bolChange = true;}
      if (document.main.INP_JobNext.value != document.main.DTA_JobNext.value) {bolChange = true;}
      if (document.main.INP_JobInterval.value != document.main.DTA_JobInterval.value) {bolChange = true;}
      if (document.main.INP_JobStatus.value != document.main.DTA_JobStatus.value) {bolChange = true;}
      if (bolChange == true) {
         bolReturn = confirm('Changes have been made to this information\r\npress OK continue (changes will be lost)\r\npress Cancel to return to the function');
         return bolReturn;
      }
      return true;
   }
   function doCancel() {
      if (checkChange() == false) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SELECT';
      document.main.submit();
   }
   function doAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      var strParser = '';
      var strArray = new Array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
                               'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
                               'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3',
                               '4', '5', '6', '7', '8', '9', '_', '#');
      var bolCharFound = false;
      var bolCharError = false;
      var intHashCount = 0;
      var intHashIndex = -1;
      if (document.main.INP_JobJob.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Job identifier must be entered';
      }
      if (document.main.INP_JobDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Job description must be entered';
      }
      if (document.main.INP_JobExeHistory.value == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Job execution history must not be zero';
      }
      if (document.main.INP_JobType.value == '*FILE' ||
          document.main.INP_JobType.value == '*INBOUND' ||
          document.main.INP_JobType.value == '*OUTBOUND' ||
          document.main.INP_JobType.value == '*PASSTHRU' ||
          document.main.INP_JobType.value == '*DAEMON' ||
          document.main.INP_JobType.value == '*POLLER') {
         if (document.main.INP_JobIntGroup.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Job group must be entered for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU, *DAEMON or *POLLER';
         } else {
            bolCharError = false;
            intHashCount = 0;
            intHashIndex = -1;
            strParser = document.main.INP_JobIntGroup.value.toUpperCase();
            for (i=0;i<strParser.length;i++) {
               bolCharFound = false;
               for (j=0;j<strArray.length;j++) {
                  if (strParser.charAt(i) == strArray[j].charAt(0)) {
                     if (strParser.charAt(i) == '#') {
                        intHashCount++;
                        intHashIndex = i;
                     }
                     bolCharFound = true;
                     break;
                  }
               }
               if (!bolCharFound) {bolCharError = true;}
            }
            if (bolCharError) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Job group invalid - allowable characters A-Z, 0-9, _, #';
            }
            if (intHashCount > 1) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Job group invalid - only one parallel separator (#) allowed';
            }
            if (intHashCount == 1) {
               if (intHashIndex <= 0 || intHashIndex >= strParser.length - 1) {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + 'Job group invalid - parallel separator (#) must not be in first or last position';
               }
            }
         }
         if (document.main.INP_JobType.value == '*DAEMON' ||
             document.main.INP_JobType.value == '*POLLER') {
            if (document.main.INP_JobProcedure.value == '') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Job procedure must be entered for *DAEMON or *POLLER';
            }
         } else {
            if (document.main.INP_JobProcedure.value != '') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Job procedure must not be entered for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU';
            }
         }
         if (document.main.INP_JobNext.value != 'sysdate' &&
             document.main.INP_JobNext.value != 'SYSDATE') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Job next must be SYSDATE for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU, *DAEMON or *POLLER';
         }
         if (document.main.INP_JobType.value == '*POLLER') {
            if (document.main.INP_JobInterval.value == '') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Job interval (polling seconds) must be entered for *POLLER';
            }
         } else {
            if (document.main.INP_JobInterval.value != '') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Job interval must not be entered for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU or *DAEMON';
            }
         }
      } else {
         if (document.main.INP_JobIntGroup.value != '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Job group must not be entered for *PROCEDURE';
         }
         if (document.main.INP_JobProcedure.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Job procedure must be entered for *PROCEDURE';
         }
         if (document.main.INP_JobNext.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Job next must be entered for *PROCEDURE';
         }
         if (document.main.INP_JobInterval.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Job interval must be entered for *PROCEDURE';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_JobJob.value = document.main.INP_JobJob.value;
      document.main.DTA_JobDescription.value = document.main.INP_JobDescription.value;
      document.main.DTA_JobResGroup.value = document.main.INP_JobResGroup.value;
      document.main.DTA_JobExeHistory.value = document.main.INP_JobExeHistory.value;
      document.main.DTA_JobOprAlert.value = document.main.INP_JobOprAlert.value;
      document.main.DTA_JobEmaGroup.value = document.main.INP_JobEmaGroup.value;
      document.main.DTA_JobType.value = document.main.INP_JobType.value;
      document.main.DTA_JobIntGroup.value = document.main.INP_JobIntGroup.value;
      document.main.DTA_JobProcedure.value = document.main.INP_JobProcedure.value;
      document.main.DTA_JobNext.value = document.main.INP_JobNext.value;
      document.main.DTA_JobInterval.value = document.main.INP_JobInterval.value;
      document.main.DTA_JobStatus.value = document.main.INP_JobStatus.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'INSERT_ACCEPT';
      document.main.submit();
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectType(objSelect) {
      document.main.INP_JobType.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectStatus(objSelect) {
      document.main.INP_JobStatus.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_job_configuration_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert Job');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_JobJob" size="32" maxlength="32" value="<%=objForm.Fields("DTA_JobJob").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_JobDescription" size="64" maxlength="128" value="<%=objForm.Fields("DTA_JobDescription").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Resource Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_JobResGroup" size="32" maxlength="32" value="<%=objForm.Fields("DTA_JobResGroup").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Execution History (number):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_JobExeHistory" size="5" maxlength="5" value="<%=objForm.Fields("DTA_JobExeHistory").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Operator Alert:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_JobOprAlert" size="64" maxlength="256" value="<%=replace(objForm.Fields("DTA_JobOprAlert").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_JobEmaGroup" size="64" maxlength="64" value="<%=replace(objForm.Fields("DTA_JobEmaGroup").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltJobType" onChange="selectType(this);">
               <option value="*FILE"<%if objForm.Fields("DTA_JobType").Value = "*FILE" then%> selected<%end if%>>*FILE
               <option value="*INBOUND"<%if objForm.Fields("DTA_JobType").Value = "*INBOUND" then%> selected<%end if%>>*INBOUND
               <option value="*OUTBOUND"<%if objForm.Fields("DTA_JobType").Value = "*OUTBOUND" then%> selected<%end if%>>*OUTBOUND
               <option value="*PASSTHRU"<%if objForm.Fields("DTA_JobType").Value = "*PASSTHRU" then%> selected<%end if%>>*PASSTHRU
               <option value="*DAEMON"<%if objForm.Fields("DTA_JobType").Value = "*DAEMON" then%> selected<%end if%>>*DAEMON
               <option value="*POLLER"<%if objForm.Fields("DTA_JobType").Value = "*POLLER" then%> selected<%end if%>>*POLLER
               <option value="*PROCEDURE"<%if objForm.Fields("DTA_JobType").Value = "*PROCEDURE" or objForm.Fields("DTA_JobType").Value = "" then%> selected<%end if%>>*PROCEDURE
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_JobIntGroup" size="10" maxlength="10" value="<%=objForm.Fields("DTA_JobIntGroup").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Procedure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_JobProcedure" size="64" maxlength="256" value="<%=replace(objForm.Fields("DTA_JobProcedure").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Next:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <textarea class="clsInputNN" type="text" name="INP_JobNext" rows="5" cols="64" onFocus="setSelect(this);"><%=replace(objForm.Fields("DTA_JobNext").Value, """", "&#34;", 1, -1, 1)%></textArea>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Interval:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <textarea class="clsInputNN" type="text" name="INP_JobInterval" rows="5" cols="64" onFocus="setSelect(this);"><%=replace(objForm.Fields("DTA_JobInterval").Value, """", "&#34;", 1, -1, 1)%></textArea>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltJobStatus" onChange="selectStatus(this);">
               <option value="0"<%if objForm.Fields("DTA_JobStatus").Value = "0" or objForm.Fields("DTA_JobStatus").Value = "" then%> selected<%end if%>>Inactive
               <option value="1"<%if objForm.Fields("DTA_JobStatus").Value = "1" then%> selected<%end if%>>Active
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_JobJob" value="<%=objForm.Fields("DTA_JobJob").Value%>">
   <input type="hidden" name="DTA_JobDescription" value="<%=objForm.Fields("DTA_JobDescription").Value%>">
   <input type="hidden" name="DTA_JobResGroup" value="<%=objForm.Fields("DTA_JobResGroup").Value%>">
   <input type="hidden" name="DTA_JobExeHistory" value="<%=objForm.Fields("DTA_JobExeHistory").Value%>">
   <input type="hidden" name="DTA_JobOprAlert" value="<%=replace(objForm.Fields("DTA_JobOprAlert").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_JobEmaGroup" value="<%=replace(objForm.Fields("DTA_JobEmaGroup").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_JobType" value="<%=objForm.Fields("DTA_JobType").Value%>">
   <input type="hidden" name="DTA_JobIntGroup" value="<%=objForm.Fields("DTA_JobIntGroup").Value%>">
   <input type="hidden" name="DTA_JobProcedure" value="<%=replace(objForm.Fields("DTA_JobProcedure").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_JobNext" value="<%=replace(objForm.Fields("DTA_JobNext").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_JobInterval" value="<%=replace(objForm.Fields("DTA_JobInterval").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_JobStatus" value="<%=objForm.Fields("DTA_JobStatus").Value%>">
   <input type="hidden" name="INP_JobType" value="<%=objForm.Fields("DTA_JobType").Value%>">
   <input type="hidden" name="INP_JobStatus" value="<%=objForm.Fields("DTA_JobStatus").Value%>">
</form>
</body>
</html>