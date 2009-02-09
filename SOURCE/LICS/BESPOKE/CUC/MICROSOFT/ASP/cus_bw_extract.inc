<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_Interface.focus();<%if strError <> "" then%>
      alert('<%=strError%>');<%end if%>
      return;
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
   function doSubmit() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_Period.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Period must be selected';
      }
      if (document.main.INP_Ation.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Action must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (confirm('Please confirm that you wish to continue\r\nPress OK to continue\r\nOr press Cancel')) {
         document.main.DTA_Period.value = document.main.INP_Period.value;
         document.main.DTA_Action.value = document.main.INP_Action.value;
         document.main.action = '<%=strBase%><%=strTarget%>';
         document.main.Mode.value = 'SUBMIT';
         document.main.submit();
      }
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectPeriod(objSelect) {
      document.main.INP_Period.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectAction(objSelect) {
      document.main.INP_Action.value = objSelect.options[objSelect.selectedIndex].value;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('cus_bw_extract_help.htm');parent.setHeading('<%=strHeading%> - Submit');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Extract Period:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltPeriod" onChange="selectPeriod(this);">
               <option value="*LAST"<%if objForm.Fields("DTA_Period").Value = "*LAST" then%> selected<%end if%>>Consumer response data for the previous three periods
               <option value="*CURRENT"<%if objForm.Fields("DTA_Period").Value = "*CURRENT" then%> selected<%end if%>>Consumer response data for the current period<%for intCount = 1 to 13%><%intPeriod = intPeriod - 1%><%if intPeriod mod 100 = 0 then%><%intPeriod = intPeriod - 88%><%end if%>
               <option value="<%=cstr(intPeriod)%>"<%if objForm.Fields("DTA_Period").Value = "<%=cstr(intPeriod)%>" then%> selected<%end if%>>Consumer response data for <%=cstr(intPeriod)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Extract Action:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltAction" onChange="selectAction(this);">
               <option value="*VALIDATE"<%if objForm.Fields("DTA_Action").Value = "*VALIDATE" then%> selected<%end if%>>Validate Only
               <option value="*EXECUTE"<%if objForm.Fields("DTA_Action").Value = "*EXECUTE" then%> selected<%end if%>>Validate and Execute
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSubmit();">&nbsp;Submit&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr><%if strConfirm <> "" then%>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;<%=strConfirm%>&nbsp;</nobr></td>
      </tr><%end if%>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_Period" value="<%=objForm.Fields("DTA_Period").Value%>">
   <input type="hidden" name="DTA_Action" value="<%=objForm.Fields("DTA_Action").Value%>">
   <input type="hidden" name="INP_Period" value="<%=objForm.Fields("DTA_Period").Value%>">
   <input type="hidden" name="INP_Action" value="<%=objForm.Fields("DTA_Action").Value%>">
</form>
</body>
</html>