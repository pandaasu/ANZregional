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
   function checkChange() {
      bolReturn = confirm('Please confirm the cancel\r\npress OK continue (any changes will be lost)\r\npress Cancel to return to the function');
      return bolReturn;
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
      if (document.main.INP_ReportName.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Report name must be entered';
      }
      if (document.main.INP_ReportGrpId.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Report group must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_ReportName.value = document.main.INP_ReportName.value;
      document.main.DTA_ReportGrpId.value = document.main.INP_ReportGrpId.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'COPY_ACCEPT';
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
   function selectReportGrpId(objSelect) {
      document.main.INP_ReportGrpId.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectCopyRptId(objSelect) {
      document.main.INP_CopyRptId.value = objSelect.options[objSelect.selectedIndex].value;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('prc_lst_configuration_copy_help.htm');parent.setHeading('<%=strHeading%> - Copy Report');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Copy Name:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=replace(objForm.Fields("DTA_CopyName").Value, """", "&#34;", 1, -1, 1)%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Report Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_ReportName" size="100" maxlength="200" value="<%=replace(objForm.Fields("DTA_ReportName").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Report Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltReportGrpId" onChange="selectReportGrpId(this);">
               <option value=""<%if objForm.Fields("DTA_ReportGrpId").Value = "" then%> selected<%end if%>>** select report group **<%for i = 0 to objSelection.ListCount("REPORT_GRP") - 1%>
               <option value="<%=objSelection.ListValue01("REPORT_GRP",i)%>"<%if objForm.Fields("DTA_ReportGrpId").Value = objSelection.ListValue01("REPORT_GRP",i) then%> selected<%end if%>><%=replace(objSelection.ListValue02("REPORT_GRP",i), """", "&#34;", 1, -1, 1)%><%next%>
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
   <input type="hidden" name="DTA_ReportId" value="<%=objForm.Fields("DTA_ReportId").Value%>">
   <input type="hidden" name="DTA_ReportGrpId" value="<%=objForm.Fields("DTA_ReportGrpId").Value%>">
   <input type="hidden" name="DTA_ReportName" value="<%=replace(objForm.Fields("DTA_ReportName").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="INP_ReportGrpId" value="<%=objForm.Fields("DTA_ReportGrpId").Value%>">
</form>
</body>
</html>