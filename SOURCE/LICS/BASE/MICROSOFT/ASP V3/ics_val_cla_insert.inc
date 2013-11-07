<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_VacClass.focus();<%if strError <> "" then%>
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
      if (document.main.INP_VacClass.value != document.main.DTA_VacClass.value) {bolChange = true;}
      if (document.main.INP_VacDescription.value != document.main.DTA_VacDescription.value) {bolChange = true;}
      if (document.main.INP_VacLstQuery.value != document.main.DTA_VacLstQuery.value) {bolChange = true;}
      if (document.main.INP_VacOneQuery.value != document.main.DTA_VacOneQuery.value) {bolChange = true;}
      if (document.main.INP_VacExeBatch.value != document.main.DTA_VacExeBatch.value) {bolChange = true;}
      if (changeClassRules() == true) {bolChange = true;}
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
      var strRule = '';
      if (document.main.INP_VacClass.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Classification identifier must be entered';
      }
      if (document.main.INP_VacDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Classification description must be entered';
      }
      if (document.main.INP_VacLstQuery.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Classification list query must be entered';
      }
      if (document.main.INP_VacOneQuery.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Classification single query must be entered';
      }
      if (document.main.INP_VacExeBatch.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Classification batch validation must be entered';
      }
      strRule = checkClassRules();
      if (strRule != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strRule;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_VacClass.value = document.main.INP_VacClass.value;
      document.main.DTA_VacDescription.value = document.main.INP_VacDescription.value;
      document.main.DTA_VacLstQuery.value = document.main.INP_VacLstQuery.value;
      document.main.DTA_VacOneQuery.value = document.main.INP_VacOneQuery.value;
      document.main.DTA_VacExeBatch.value = document.main.INP_VacExeBatch.value;
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
   function selectBatch(strValue) {
      document.main.INP_VacExeBatch.value = strValue;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_val_cla_rules.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_val_cla_help.htm');parent.setHeading('<%=strHeading%> - Insert Classification');parent.showContent();paintClassRules();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Group:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields().Item("DTA_VacGroup")%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Classification:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_VacClass" size="30" maxlength="30" value="<%=objForm.Fields().Item("DTA_VacClass")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VacDescription" size="64" maxlength="128" value="<%=objForm.Fields().Item("DTA_VacDescription")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;List Query:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <textarea class="clsInputFN" type="text" name="INP_VacLstQuery" rows="10" cols="100" wrap="off" onFocus="setSelect(this);"><%=replace(objForm.Fields().Item("DTA_VacLstQuery"), """", "&#34;", 1, -1, 1)%></textArea>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Single Query:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <textarea class="clsInputFN" type="text" name="INP_VacOneQuery" rows="10" cols="100" wrap="off" onFocus="setSelect(this);"><%=replace(objForm.Fields().Item("DTA_VacOneQuery"), """", "&#34;", 1, -1, 1)%></textArea>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Batch Validation:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltBatch"<%if objForm.Fields().Item("DTA_VacExeBatch") = "Y" then%> checked<%end if%> value="Y" onClick="javascript:selectBatch('Y');">Yes&nbsp;
            <input type="radio" name="sltBatch"<%if objForm.Fields().Item("DTA_VacExeBatch") = "N" then%> checked<%end if%> value="N" onClick="javascript:selectBatch('N');">No&nbsp;
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Classification Rules&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
            <table align=center border=0 cellpadding=0 cellspacing=2 cols=2>
               <tr>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Available Rules&nbsp;</nobr></td>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Selected Rules&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="sltRule" name="sltRule" style="width:400px" multiple size=15></select>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="sltRuleSelected" name="sltRuleSelected" style="width:400px" multiple size=15></select>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:selectClassRules();">&nbsp;Select >>&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:removeClassRules();">&nbsp;<< Remove&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
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
   <input type="hidden" name="DTA_VacClass" value="<%=objForm.Fields().Item("DTA_VacClass")%>">
   <input type="hidden" name="DTA_VacDescription" value="<%=objForm.Fields().Item("DTA_VacDescription")%>">
   <input type="hidden" name="DTA_VacGroup" value="<%=objForm.Fields().Item("DTA_VacGroup")%>">
   <input type="hidden" name="DTA_VacLstQuery" value="<%=replace(objForm.Fields().Item("DTA_VacLstQuery"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_VacOneQuery" value="<%=replace(objForm.Fields().Item("DTA_VacOneQuery"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_VacExeBatch" value="<%=objForm.Fields().Item("DTA_VacExeBatch")%>">
   <input type="hidden" name="INP_VacExeBatch" value="<%=objForm.Fields().Item("DTA_VacExeBatch")%>">
   <input type="hidden" name="DET_RuleCount" value="">
</form>
</body>
</html>