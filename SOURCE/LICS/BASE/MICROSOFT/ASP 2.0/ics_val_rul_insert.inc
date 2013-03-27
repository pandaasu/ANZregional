<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_VarRule.focus();<%if strError <> "" then%>
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
      if (document.main.INP_VarRule.value != document.main.DTA_VarRule.value) {bolChange = true;}
      if (document.main.INP_VarDescription.value != document.main.DTA_VarDescription.value) {bolChange = true;}
      if (document.main.INP_VarQuery.value != document.main.DTA_VarQuery.value) {bolChange = true;}
      if (document.main.INP_VarTest.value != document.main.DTA_VarTest.value) {bolChange = true;}
      if (document.main.INP_VarMessage.value != document.main.DTA_VarMessage.value) {bolChange = true;}
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
      if (document.main.INP_VarRule.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Rule identifier must be entered';
      }
      if (document.main.INP_VarDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Rule description must be entered';
      }
      if (document.main.INP_VarQuery.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Rule query must be entered';
      }
      if (document.main.INP_VarTest.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Rule test must be selected';
      }
      if (document.main.INP_VarTest.value == '*ANY_ROWS' || document.main.INP_VarTest.value == '*NO_ROWS') {
         if (document.main.INP_VarMessage.value == '*NONE') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Rule static message must be specified for tests *ANY_ROWS and *NO_ROWS';
         }
      } else {
         if (document.main.INP_VarMessage.value != '*NONE') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Rule static message must be *NONE for tests *FIRST_ROW, *EACH_ROW and *LAST_ROW';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_VarRule.value = document.main.INP_VarRule.value;
      document.main.DTA_VarDescription.value = document.main.INP_VarDescription.value;
      document.main.DTA_VarQuery.value = document.main.INP_VarQuery.value;
      document.main.DTA_VarTest.value = document.main.INP_VarTest.value;
      document.main.DTA_VarMessage.value = document.main.INP_VarMessage.value;
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
   function selectTest(objSelect) {
      document.main.INP_VarTest.value = objSelect.options[objSelect.selectedIndex].value;
      if (document.main.INP_VarTest.value != '*ANY_ROWS' && document.main.INP_VarTest.value != '*NO_ROWS') {
         document.main.INP_VarMessage.value = '*NONE';
      }
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_val_rul_help.htm');parent.setHeading('<%=strHeading%> - Insert Rule');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Group:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields().Item("DTA_VarGroup")%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Rule:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_VarRule" size="30" maxlength="30" value="<%=objForm.Fields().Item("DTA_VarRule")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VarDescription" size="64" maxlength="128" value="<%=objForm.Fields().Item("DTA_VarDescription")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <textarea class="clsInputFN" type="text" name="INP_VarQuery" rows="20" cols="100" wrap="off" onFocus="setSelect(this);"><%=replace(objForm.Fields().Item("DTA_VarQuery"), """", "&#34;", 1, -1, 1)%></textArea>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Test:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltTest" onChange="selectTest(this);">
               <option value="*FIRST_ROW"<%if objForm.Fields().Item("DTA_VarTest") = "*FIRST_ROW" then%> selected<%end if%>>*FIRST_ROW
               <option value="*EACH_ROW"<%if objForm.Fields().Item("DTA_VarTest") = "*EACH_ROW" then%> selected<%end if%>>*EACH_ROW
               <option value="*LAST_ROW"<%if objForm.Fields().Item("DTA_VarTest") = "*LAST_ROW" then%> selected<%end if%>>*LAST_ROW
               <option value="*ANY_ROWS"<%if objForm.Fields().Item("DTA_VarTest") = "*ANY_ROWS" or objForm.Fields().Item("DTA_VarTest") = "" then%> selected<%end if%>>*ANY_ROWS
               <option value="*NO_ROWS"<%if objForm.Fields().Item("DTA_VarTest") = "*NO_ROWS" then%> selected<%end if%>>*NO_ROWS
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Static Message:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VarMessage" size="100" maxlength="4000" value="<%=replace(objForm.Fields().Item("DTA_VarMessage"), """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
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
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="DTA_VarRule" value="<%=objForm.Fields().Item("DTA_VarRule")%>">
   <input type="hidden" name="DTA_VarDescription" value="<%=objForm.Fields().Item("DTA_VarDescription")%>">
   <input type="hidden" name="DTA_VarGroup" value="<%=objForm.Fields().Item("DTA_VarGroup")%>">
   <input type="hidden" name="DTA_VarQuery" value="<%=replace(objForm.Fields().Item("DTA_VarQuery"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_VarTest" value="<%=objForm.Fields().Item("DTA_VarTest")%>">
   <input type="hidden" name="DTA_VarMessage" value="<%=replace(objForm.Fields().Item("DTA_VarMessage"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="INP_VarTest" value="<%=objForm.Fields().Item("DTA_VarTest")%>">
</form>
</body>
</html>