<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_VinDescription.focus();<%if strError <> "" then%>
      alert('<%=strError%>');<%else%>return;<%end if%>
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
      if (document.main.INP_VinDescription.value != document.main.DTA_VinDescription.value) {bolChange = true;}
      if (document.main.INP_VinLogon01.value != document.main.DTA_VinLogon01.value) {bolChange = true;}
      if (document.main.INP_VinLogon02.value != document.main.DTA_VinLogon02.value) {bolChange = true;}
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
      if (document.main.INP_VinDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface description must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_VinDescription.value = document.main.INP_VinDescription.value;
      document.main.DTA_VinLogon01.value = document.main.INP_VinLogon01.value;
      document.main.DTA_VinLogon02.value = document.main.INP_VinLogon02.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'UPDATE_ACCEPT';
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
   function selectLogon02(strValue) {
      document.main.INP_VinLogon02.value = strValue;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_vds_int_help.htm');parent.setHeading('<%=strHeading%> - Update Interface');parent.showContent();paintTypeRules();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields().Item("DTA_VinInterface")%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VinDescription" size="64" maxlength="128" value="<%=objForm.Fields().Item("DTA_VinDescription")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Secondary Logon:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltLogon02"<%if objForm.Fields().Item("DTA_VinLogon02") = "1" then%> checked<%end if%> value="1" onClick="javascript:selectLogon02('1');">Yes&nbsp;
            <input type="radio" name="sltLogon02"<%if objForm.Fields().Item("DTA_VinLogon02") = "0" then%> checked<%end if%> value="0" onClick="javascript:selectLogon02('0');">No&nbsp;
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
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="DTA_VinInterface" value="<%=objForm.Fields().Item("DTA_VinInterface")%>">
   <input type="hidden" name="DTA_VinDescription" value="<%=objForm.Fields().Item("DTA_VinDescription")%>">
   <input type="hidden" name="DTA_VinLogon01" value="<%=objForm.Fields().Item("DTA_VinLogon01")%>">
   <input type="hidden" name="DTA_VinLogon02" value="<%=objForm.Fields().Item("DTA_VinLogon02")%>">
   <input type="hidden" name="INP_VinLogon01" value="<%=objForm.Fields().Item("DTA_VinLogon01")%>">
   <input type="hidden" name="INP_VinLogon02" value="<%=objForm.Fields().Item("DTA_VinLogon02")%>">
</form>
</body>
</html>