<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_GroDescription.focus();<%if strReturn <> "*OK" then%>
      alert('<%=strReturn%>');<%else%>return;<%end if%>
   }
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
   function checkChange() {
      var bolChange = false;
      var bolReturn;
      if (document.main.INP_ReportGrpName.value != document.main.DTA_ReportGrpName.value) {bolChange = true;}
      if (document.main.INP_Status.value != document.main.DTA_Status.value) {bolChange = true;}
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
      if (document.main.INP_ReportGrpId.value == '') {
         if (strMessage != null) {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Report group name must be entered';
      }
      if (document.main.INP_Status.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Status must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_ReportGrpName.value = document.main.INP_ReportGrpName.value;
      document.main.DTA_Status.value = document.main.INP_Status.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'DEFINE_ACCEPT';
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
   function selectStatus(strValue) {
      document.main.INP_Status.value = strValue;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('prc_lst_group_define_help.htm');parent.setHeading('<%=strHeading%> - Define Report Group');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Report Group Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_ReportGrpName" size="128" maxlength="200" value="<%=replace(objForm.Fields("DTA_ReportGrpName").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltStatus"<%if objForm.Fields("DTA_Status").Value = "" or objForm.Fields("DTA_Status").Value = "I" then%> checked<%end if%> value="I" onClick="javascript:selectStatus('Unavailable');">No&nbsp;
            <input type="radio" name="sltStatus"<%if objForm.Fields("DTA_Status").Value = "V" then%> checked<%end if%> value="V" onClick="javascript:selectStatus('Y');">Available&nbsp;
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
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
   <input type="hidden" name="DTA_ReportGrpId" value="<%=objForm.Fields("DTA_ReportGrpId").Value%>">
   <input type="hidden" name="DTA_ReportGrpName" value="<%=replace(objForm.Fields("DTA_ReportGrpName").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_Status" value="<%=objForm.Fields("DTA_Status").Value%>">
   <input type="hidden" name="INP_Status" value="<%=objForm.Fields("DTA_Status").Value%>">
</form>
</body>
</html>