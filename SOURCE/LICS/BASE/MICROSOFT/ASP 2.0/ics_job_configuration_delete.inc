<html>
<script language="javascript">
<!--
   function showError() {<%if strReturn <> "*OK" then%>
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
   function doCancel() {
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SELECT';
      document.main.submit();
   }
   function doAccept() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'DELETE_ACCEPT';
      document.main.submit();
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_job_configuration_delete_help.htm');parent.setHeading('<%=strHeading%> - Delete Job');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields().Item("DTA_JobJob")%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Description:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields().Item("DTA_JobDescription")%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Type:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields().Item("DTA_JobType")%></nobr></td>
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
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="DTA_JobJob" value="<%=objForm.Fields().Item("DTA_JobJob")%>">
   <input type="hidden" name="DTA_JobDescription" value="<%=objForm.Fields().Item("DTA_JobDescription")%>">
   <input type="hidden" name="DTA_JobResGroup" value="<%=objForm.Fields().Item("DTA_JobResGroup")%>">
   <input type="hidden" name="DTA_JobExeHistory" value="<%=objForm.Fields().Item("DTA_JobExeHistory")%>">
   <input type="hidden" name="DTA_JobOprAlert" value="<%=objForm.Fields().Item("DTA_JobOprAlert")%>">
   <input type="hidden" name="DTA_JobEmaGroup" value="<%=objForm.Fields().Item("DTA_JobEmaGroup")%>">
   <input type="hidden" name="DTA_JobType" value="<%=objForm.Fields().Item("DTA_JobType")%>">
   <input type="hidden" name="DTA_JobIntGroup" value="<%=objForm.Fields().Item("DTA_JobIntGroup")%>">
   <input type="hidden" name="DTA_JobProcedure" value="<%=objForm.Fields().Item("DTA_JobProcedure")%>">
   <input type="hidden" name="DTA_JobNext" value="<%=objForm.Fields().Item("DTA_JobNext")%>">
   <input type="hidden" name="DTA_JobInterval" value="<%=objForm.Fields().Item("DTA_JobInterval")%>">
   <input type="hidden" name="DTA_JobStatus" value="<%=objForm.Fields().Item("DTA_JobStatus")%>">
</form>
</body>
</html>