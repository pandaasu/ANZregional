<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_EdiSndtoCode.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_EdiSndtoCode.value != document.main.DTA_EdiSndtoCode.value) {bolChange = true;}
      if (document.main.INP_EdiWhslrCode.value != document.main.DTA_EdiWhslrCode.value) {bolChange = true;}
      if (document.main.INP_EdiWhslrName.value != document.main.DTA_EdiWhslrName.value) {bolChange = true;}
      if (document.main.INP_EdiDiscCode.value != document.main.DTA_EdiDiscCode.value) {bolChange = true;}
      if (document.main.INP_EdiEmailGroup.value != document.main.DTA_EdiEmailGroup.value) {bolChange = true;}
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
      if (document.main.INP_EdiSndtoCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Send to code must be entered';
      }
      if (document.main.INP_EdiWhslrCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Wholesaler code must be entered';
      }
      if (document.main.INP_EdiWhslrName.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Wholesaler name must be entered';
      }
      if (document.main.INP_EdiDiscCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Discount code must be selected';
      }
      if (document.main.INP_EdiEmailGroup.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Email group must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_EdiSndtoCode.value = document.main.INP_EdiSndtoCode.value;
      document.main.DTA_EdiWhslrCode.value = document.main.INP_EdiWhslrCode.value;
      document.main.DTA_EdiWhslrName.value = document.main.INP_EdiWhslrName.value;
      document.main.DTA_EdiDiscCode.value = document.main.INP_EdiDiscCode.value;
      document.main.DTA_EdiEmailGroup.value = document.main.INP_EdiEmailGroup.value;
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
   function setSelect(objInput) {
      objInput.select();
   }
   function selectDiscCode(objSelect) {
      document.main.INP_EdiDiscCode.value = objSelect.options[objSelect.selectedIndex].value;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('mjp_edi_whslr_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Send To Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_EdiSndtoCode" size="20" maxlength="20" value="<%=objForm.Fields("DTA_EdiSndtoCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Wholesaler Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_EdiWhslrCode" size="20" maxlength="20" value="<%=objForm.Fields("DTA_EdiWhslrCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Wholesaler Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EdiWhslrName" size="64" maxlength="128" value="<%=objForm.Fields("DTA_EdiWhslrName").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Discount Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltEdiDiscCode" onChange="selectDiscCode(this);">
               <option value="A"<%if objForm.Fields("DTA_EdiDiscCode").Value = "A" then%> selected<%end if%>>All
               <option value="V"<%if objForm.Fields("DTA_EdiDiscCode").Value = "V" then%> selected<%end if%>>Volume only
               <option value="N"<%if objForm.Fields("DTA_EdiDiscCode").Value = "N" then%> selected<%end if%>>None
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;EDI Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EdiEmailGroup" size="64" maxlength="64" value="<%=replace(objForm.Fields("DTA_EdiEmailGroup").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
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
   <input type="hidden" name="DTA_EdiSndtoCode" value="<%=objForm.Fields("DTA_EdiSndtoCode").Value%>">
   <input type="hidden" name="DTA_EdiWhslrCode" value="<%=objForm.Fields("DTA_EdiWhslrCode").Value%>">
   <input type="hidden" name="DTA_EdiWhslrName" value="<%=objForm.Fields("DTA_EdiWhslrName").Value%>">
   <input type="hidden" name="DTA_EdiDiscCode" value="<%=objForm.Fields("DTA_EdiDiscCode").Value%>">
   <input type="hidden" name="DTA_EdiEmailGroup" value="<%=replace(objForm.Fields("DTA_EdiEmailGroup").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="INP_EdiDiscCode" value="<%=objForm.Fields("DTA_EdiDiscCode").Value%>">
</form>
</body>
</html>