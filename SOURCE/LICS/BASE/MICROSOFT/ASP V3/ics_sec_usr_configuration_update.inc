<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_SeuDescription.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_SeuDescription.value != document.main.DTA_SeuDescription.value) {bolChange = true;}
      if (document.main.INP_SeuMenu.value != document.main.DTA_SeuMenu.value) {bolChange = true;}
      if (document.main.INP_SeuStatus.value != document.main.DTA_SeuStatus.value) {bolChange = true;}
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
      if (document.main.INP_SeuDescription.value == '') {
         if (strMessage != null) {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'User description must be entered';
      }
      if (document.main.INP_SeuMenu.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'User menu must be selected';
      }
      if (document.main.INP_SeuStatus.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'User status must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_SeuDescription.value = document.main.INP_SeuDescription.value;
      document.main.DTA_SeuMenu.value = document.main.INP_SeuMenu.value;
      document.main.DTA_SeuStatus.value = document.main.INP_SeuStatus.value;
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
   function selectMenu(objSelect) {
      document.main.INP_SeuMenu.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectStatus(objSelect) {
      document.main.INP_SeuStatus.value = objSelect.options[objSelect.selectedIndex].value;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_sec_usr_configuration_update_help.htm');parent.setHeading('<%=strHeading%> - Update User');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;User Code:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields().Item("DTA_SeuUser")%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;User Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SeuDescription" size="128" maxlength="128" value="<%=objForm.Fields().Item("DTA_SeuDescription")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;User Menu:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltSeuMenu" onChange="selectMenu(this);">
               <option value=""<%if objForm.Fields().Item("DTA_SeuMenu") = "" then%> selected<%end if%>>** select menu **<%for i = 0 to clng(objSelection.ListCount("MENU")) - 1%>
               <option value="<%=objSelection.ListValue01("MENU",i)%>"<%if objForm.Fields().Item("DTA_SeuMenu") = objSelection.ListValue01("MENU",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("MENU",i)%>) <%=objSelection.ListValue02("MENU",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;User Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltSeuStatus" onChange="selectStatus(this);">
               <option value="0"<%if objForm.Fields().Item("DTA_SeuStatus") = "0" or objForm.Fields().Item("DTA_SeuStatus") = "" then%> selected<%end if%>>Inactive
               <option value="1"<%if objForm.Fields().Item("DTA_SeuStatus") = "1" then%> selected<%end if%>>Active
            </select>
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
   <input type="hidden" name="DTA_SeuUser" value="<%=objForm.Fields().Item("DTA_SeuUser")%>">
   <input type="hidden" name="DTA_SeuDescription" value="<%=objForm.Fields().Item("DTA_SeuDescription")%>">
   <input type="hidden" name="DTA_SeuMenu" value="<%=objForm.Fields().Item("DTA_SeuMenu")%>">
   <input type="hidden" name="DTA_SeuStatus" value="<%=objForm.Fields().Item("DTA_SeuStatus")%>">
   <input type="hidden" name="INP_SeuMenu" value="<%=objForm.Fields().Item("DTA_SeuMenu")%>">
   <input type="hidden" name="INP_SeuStatus" value="<%=objForm.Fields().Item("DTA_SeuStatus")%>">
</form>
</body>
</html>