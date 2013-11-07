<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_SeoOption.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_SeoOption.value != document.main.DTA_SeoOption.value) {bolChange = true;}
      if (document.main.INP_SeoDescription.value != document.main.DTA_SeoDescription.value) {bolChange = true;}
      if (document.main.INP_SeoScript.value != document.main.DTA_SeoScript.value) {bolChange = true;}
      if (document.main.INP_SeoStatus.value != document.main.DTA_SeoStatus.value) {bolChange = true;}
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
      if (document.main.INP_SeoOption.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Option code must be entered';
      }
      if (document.main.INP_SeoDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Option description must be entered';
      }
      if (document.main.INP_SeoScript.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Option script must be entered';
      }
      if (document.main.INP_SeoStatus.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Option status must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_SeoOption.value = document.main.INP_SeoOption.value;
      document.main.DTA_SeoDescription.value = document.main.INP_SeoDescription.value;
      document.main.DTA_SeoScript.value = document.main.INP_SeoScript.value;
      document.main.DTA_SeoStatus.value = document.main.INP_SeoStatus.value;
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
   function selectStatus(objSelect) {
      document.main.INP_SeoStatus.value = objSelect.options[objSelect.selectedIndex].value;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_sec_opt_configuration_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert Option');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Option Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_SeoOption" size="32" maxlength="32" value="<%=objForm.Fields().Item("DTA_SeoOption")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Option Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SeoDescription" size="128" maxlength="128" value="<%=objForm.Fields().Item("DTA_SeoDescription")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Option Script:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SeoScript" size="128" maxlength="256" value="<%=replace(objForm.Fields().Item("DTA_SeoScript"), """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Option Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltSeoStatus" onChange="selectStatus(this);">
               <option value="0"<%if objForm.Fields().Item("DTA_SeoStatus") = "0" or objForm.Fields().Item("DTA_SeoStatus") = "" then%> selected<%end if%>>Inactive
               <option value="1"<%if objForm.Fields().Item("DTA_SeoStatus") = "1" then%> selected<%end if%>>Active
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
   <input type="hidden" name="DTA_SeoOption" value="<%=objForm.Fields().Item("DTA_SeoOption")%>">
   <input type="hidden" name="DTA_SeoDescription" value="<%=objForm.Fields().Item("DTA_SeoDescription")%>">
   <input type="hidden" name="DTA_SeoScript" value="<%=replace(objForm.Fields().Item("DTA_SeoScript"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_SeoStatus" value="<%=objForm.Fields().Item("DTA_SeoStatus")%>">
   <input type="hidden" name="INP_SeoStatus" value="<%=objForm.Fields().Item("DTA_SeoStatus")%>">
</form>
</body>
</html>