<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_IntInterface.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_IntInterface.value != document.main.DTA_IntInterface.value) {bolChange = true;}
      if (document.main.INP_IntDescription.value != document.main.DTA_IntDescription.value) {bolChange = true;}
      if (document.main.INP_IntType.value != document.main.DTA_IntType.value) {bolChange = true;}
      if (document.main.INP_IntGroup.value != document.main.DTA_IntGroup.value) {bolChange = true;}
      if (document.main.INP_IntPriority.value != document.main.DTA_IntPriority.value) {bolChange = true;}
      if (document.main.INP_IntHdrHistory.value != document.main.DTA_IntHdrHistory.value) {bolChange = true;}
      if (document.main.INP_IntDtaHistory.value != document.main.DTA_IntDtaHistory.value) {bolChange = true;}
      if (document.main.INP_IntFilPath.value != document.main.DTA_IntFilPath.value) {bolChange = true;}
      if (document.main.INP_IntFilPrefix.value != document.main.DTA_IntFilPrefix.value) {bolChange = true;}
      if (document.main.INP_IntFilSequence.value != document.main.DTA_IntFilSequence.value) {bolChange = true;}
      if (document.main.INP_IntFilExtension.value != document.main.DTA_IntFilExtension.value) {bolChange = true;}
      if (document.main.INP_IntOprAlert.value != document.main.DTA_IntOprAlert.value) {bolChange = true;}
      if (document.main.INP_IntEmaGroup.value != document.main.DTA_IntEmaGroup.value) {bolChange = true;}
      if (document.main.INP_IntSearch.value != document.main.DTA_IntSearch.value) {bolChange = true;}
      if (document.main.INP_IntProcedure.value != document.main.DTA_IntProcedure.value) {bolChange = true;}
      if (document.main.INP_IntStatus.value != document.main.DTA_IntStatus.value) {bolChange = true;}
      if (document.main.INP_IntUsrInvocation.value != document.main.DTA_IntUsrInvocation.value) {bolChange = true;}
      if (document.main.INP_IntUsrValidation.value != document.main.DTA_IntUsrValidation.value) {bolChange = true;}
      if (document.main.INP_IntUsrMessage.value != document.main.DTA_IntUsrMessage.value) {bolChange = true;}
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
      if (document.main.INP_IntInterface.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface identifier must be entered';
      }
      if (document.main.INP_IntDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface description must be entered';
      }
      if (document.main.INP_IntGroup.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface group must be entered';
      }
      if (document.main.INP_IntPriority.value == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface priority must not be zero';
      }
      if (document.main.INP_IntHdrHistory.value == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface header history must not be zero';
      }
      if (document.main.INP_IntDtaHistory.value == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface data history must not be zero';
      }
      if (document.main.INP_IntFilPath.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface file path must be entered';
      }
      if (document.main.INP_IntType.value == '*INBOUND') {
         if (document.main.INP_IntFilPrefix.value != '' &&
             document.main.INP_IntFilSequence.value != '0' &&
             document.main.INP_IntFilExtension.value != '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Interface file prefix, sequence and extension must not be entered for *INBOUND';
         }
      } else {
         if (document.main.INP_IntFilPrefix.value != '') {
            if (document.main.INP_IntFilExtension.value == '') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Interface file extension must be entered when file prefix entered';
            }
         } else {
            if (document.main.INP_IntFilSequence.value != '0' &&
                document.main.INP_IntFilExtension.value != '') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Interface file sequence and extension must not be entered when file prefix not entered';
            }
         }
      }
      if (document.main.INP_IntType.value == '*OUTBOUND') {
         if (document.main.INP_IntSearch.value != '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Interface search procedure must not be entered for *OUTBOUND';
         }
      }
      if (document.main.INP_IntProcedure.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface processing procedure must be entered';
      }
      if (document.main.INP_IntUsrInvocation.value == '1') {
         if (document.main.INP_IntType.value != '*OUTBOUND') {
            if (document.main.INP_IntUsrMessage.value != '') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'User invocation outbound message can only be entered for *OUTBOUND';
            }
         }
      } else {
         if (document.main.INP_IntUsrValidation.value != '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'User invocation validation procedure can only be entered when user invocation selected';
         }
         if (document.main.INP_IntUsrMessage.value != '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'User invocation outbound message can only be entered when user invocation selected';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_IntInterface.value = document.main.INP_IntInterface.value;
      document.main.DTA_IntDescription.value = document.main.INP_IntDescription.value;
      document.main.DTA_IntType.value = document.main.INP_IntType.value;
      document.main.DTA_IntGroup.value = document.main.INP_IntGroup.value;
      document.main.DTA_IntPriority.value = document.main.INP_IntPriority.value;
      document.main.DTA_IntHdrHistory.value = document.main.INP_IntHdrHistory.value;
      document.main.DTA_IntDtaHistory.value = document.main.INP_IntDtaHistory.value;
      document.main.DTA_IntFilPath.value = document.main.INP_IntFilPath.value;
      document.main.DTA_IntFilPrefix.value = document.main.INP_IntFilPrefix.value;
      document.main.DTA_IntFilSequence.value = document.main.INP_IntFilSequence.value;
      document.main.DTA_IntFilExtension.value = document.main.INP_IntFilExtension.value;
      document.main.DTA_IntOprAlert.value = document.main.INP_IntOprAlert.value;
      document.main.DTA_IntEmaGroup.value = document.main.INP_IntEmaGroup.value;
      document.main.DTA_IntSearch.value = document.main.INP_IntSearch.value;
      document.main.DTA_IntProcedure.value = document.main.INP_IntProcedure.value;
      document.main.DTA_IntStatus.value = document.main.INP_IntStatus.value;
      document.main.DTA_IntUsrInvocation.value = document.main.INP_IntUsrInvocation.value;
      document.main.DTA_IntUsrValidation.value = document.main.INP_IntUsrValidation.value;
      document.main.DTA_IntUsrMessage.value = document.main.INP_IntUsrMessage.value;
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
      document.main.INP_IntType.value = objSelect.options[objSelect.selectedIndex].value;
      var objReference =  eval('document.all("INP_IntFilPath")');
      if (document.main.INP_IntType.value == '*OUTBOUND') {
         objReference.value = 'ICS_OUTBOUND';
      } else {
         objReference.value = 'ICS_INBOUND';
      }
   }
   function selectStatus(objSelect) {
      document.main.INP_IntStatus.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectInvocation(objSelect) {
      document.main.INP_IntUsrInvocation.value = objSelect.options[objSelect.selectedIndex].value;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_int_configuration_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert Interface');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_IntInterface" size="32" maxlength="32" value="<%=objForm.Fields().Item("DTA_IntInterface")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntDescription" size="64" maxlength="128" value="<%=objForm.Fields().Item("DTA_IntDescription")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltIntType" onChange="selectType(this);">
               <option value="*INBOUND"<%if objForm.Fields().Item("DTA_IntType") = "*INBOUND" or objForm.Fields().Item("DTA_IntType") = "" then%> selected<%end if%>>*INBOUND
               <option value="*OUTBOUND"<%if objForm.Fields().Item("DTA_IntType") = "*OUTBOUND" then%> selected<%end if%>>*OUTBOUND
               <option value="*PASSTHRU"<%if objForm.Fields().Item("DTA_IntType") = "*PASSTHRU" then%> selected<%end if%>>*PASSTHRU
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_IntGroup" size="10" maxlength="10" value="<%=objForm.Fields().Item("DTA_IntGroup")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Priority:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntPriority" size="2" maxlength="2" value="<%=objForm.Fields().Item("DTA_IntPriority")%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Header History (days):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntHdrHistory" size="5" maxlength="5" value="<%=objForm.Fields().Item("DTA_IntHdrHistory")%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Data History (days):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntDtaHistory" size="5" maxlength="5" value="<%=objForm.Fields().Item("DTA_IntDtaHistory")%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface File Path:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntFilPath" size="64" maxlength="128" readonly value="<%=objForm.Fields().Item("DTA_IntFilPath")%>">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface File Prefix:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntFilPrefix" size="10" maxlength="10" value="<%=objForm.Fields().Item("DTA_IntFilPrefix")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface File Sequence:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntFilSequence" size="2" maxlength="2" value="<%=objForm.Fields().Item("DTA_IntFilSequence")%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface File Extension:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntFilExtension" size="10" maxlength="10" value="<%=objForm.Fields().Item("DTA_IntFilExtension")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Operator Alert:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntOprAlert" size="64" maxlength="256" value="<%=replace(objForm.Fields().Item("DTA_IntOprAlert"), """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntEmaGroup" size="64" maxlength="64" value="<%=replace(objForm.Fields().Item("DTA_IntEmaGroup"), """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Search Procedure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntSearch" size="64" maxlength="256" value="<%=replace(objForm.Fields().Item("DTA_IntSearch"), """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Processing Procedure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntProcedure" size="64" maxlength="256" value="<%=replace(objForm.Fields().Item("DTA_IntProcedure"), """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltIntStatus" onChange="selectStatus(this);">
               <option value="0"<%if objForm.Fields().Item("DTA_IntStatus") = "0" or objForm.Fields().Item("DTA_IntStatus") = "" then%> selected<%end if%>>Inactive
               <option value="1"<%if objForm.Fields().Item("DTA_IntStatus") = "1" then%> selected<%end if%>>Active
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;User Invocation:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltIntUsrInvocation" onChange="selectInvocation(this);">
               <option value="0"<%if objForm.Fields().Item("DTA_IntUsrInvocation") = "0" or objForm.Fields().Item("DTA_IntStatus") = "" then%> selected<%end if%>>Inactive
               <option value="1"<%if objForm.Fields().Item("DTA_IntUsrInvocation") = "1" then%> selected<%end if%>>Active
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;User Invocation Validation Procedure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntUsrValidation" size="64" maxlength="256" value="<%=replace(objForm.Fields().Item("DTA_IntUsrValidation"), """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;User Invocation Outbound Message:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_IntUsrMessage" size="64" maxlength="64" value="<%=replace(objForm.Fields().Item("DTA_IntUsrMessage"), """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
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
   <input type="hidden" name="DTA_IntInterface" value="<%=objForm.Fields().Item("DTA_IntInterface")%>">
   <input type="hidden" name="DTA_IntDescription" value="<%=objForm.Fields().Item("DTA_IntDescription")%>">
   <input type="hidden" name="DTA_IntType" value="<%=objForm.Fields().Item("DTA_IntType")%>">
   <input type="hidden" name="DTA_IntGroup" value="<%=objForm.Fields().Item("DTA_IntGroup")%>">
   <input type="hidden" name="DTA_IntPriority" value="<%=objForm.Fields().Item("DTA_IntPriority")%>">
   <input type="hidden" name="DTA_IntHdrHistory" value="<%=objForm.Fields().Item("DTA_IntHdrHistory")%>">
   <input type="hidden" name="DTA_IntDtaHistory" value="<%=objForm.Fields().Item("DTA_IntDtaHistory")%>">
   <input type="hidden" name="DTA_IntFilPath" value="<%=objForm.Fields().Item("DTA_IntFilPath")%>">
   <input type="hidden" name="DTA_IntFilPrefix" value="<%=objForm.Fields().Item("DTA_IntFilPrefix")%>">
   <input type="hidden" name="DTA_IntFilSequence" value="<%=objForm.Fields().Item("DTA_IntFilSequence")%>">
   <input type="hidden" name="DTA_IntFilExtension" value="<%=objForm.Fields().Item("DTA_IntFilExtension")%>">
   <input type="hidden" name="DTA_IntOprAlert" value="<%=replace(objForm.Fields().Item("DTA_IntOprAlert"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_IntEmaGroup" value="<%=replace(objForm.Fields().Item("DTA_IntEmaGroup"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_IntSearch" value="<%=replace(objForm.Fields().Item("DTA_IntSearch"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_IntProcedure" value="<%=replace(objForm.Fields().Item("DTA_IntProcedure"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_IntStatus" value="<%=objForm.Fields().Item("DTA_IntStatus")%>">
   <input type="hidden" name="DTA_IntUsrInvocation" value="<%=objForm.Fields().Item("DTA_IntUsrInvocation")%>">
   <input type="hidden" name="DTA_IntUsrValidation" value="<%=replace(objForm.Fields().Item("DTA_IntUsrValidation"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_IntUsrMessage" value="<%=replace(objForm.Fields().Item("DTA_IntUsrMessage"), """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="INP_IntType" value="<%=objForm.Fields().Item("DTA_IntType")%>">
   <input type="hidden" name="INP_IntStatus" value="<%=objForm.Fields().Item("DTA_IntStatus")%>">
   <input type="hidden" name="INP_IntUsrInvocation" value="<%=objForm.Fields().Item("DTA_IntUsrInvocation")%>">
</form>
</body>
</html>