<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_VaeEmail.focus();<%if strError <> "" then%>
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
      if (document.main.INP_VaeEmail.value != document.main.DTA_VaeEmail.value) {bolChange = true;}
      if (document.main.INP_VaeDescription.value != document.main.DTA_VaeDescription.value) {bolChange = true;}
      if (document.main.INP_VaeAddress.value != document.main.DTA_VaeAddress.value) {bolChange = true;}
      if (document.main.INP_VaeStatus.value != document.main.DTA_VaeStatus.value) {bolChange = true;}
      if (changeEmailDetails() == true) {bolChange = true;}
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
      var strDetail = '';
      if (document.main.INP_VaeEmail.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Email identifier must be entered';
      }
      if (document.main.INP_VaeDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Email description must be entered';
      }
      if (document.main.INP_VaeAddress.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Email address must be entered';
      }
      if (document.main.INP_VaeStatus.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Email status must be selected';
      }
      strDetail = checkEmailDetails();
      if (strDetail != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strDetail;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_VaeEmail.value = document.main.INP_VaeEmail.value;
      document.main.DTA_VaeDescription.value = document.main.INP_VaeDescription.value;
      document.main.DTA_VaeAddress.value = document.main.INP_VaeAddress.value;
      document.main.DTA_VaeStatus.value = document.main.INP_VaeStatus.value;
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
   function selectStatus(strValue) {
      document.main.INP_VaeStatus.value = strValue;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_val_ema_detail.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_val_ema_help.htm');parent.setHeading('<%=strHeading%> - Insert Email');parent.showContent();paintEmailDetails();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Email:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_VaeEmail" size="30" maxlength="30" value="<%=objForm.Fields("DTA_VaeEmail").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VaeDescription" size="64" maxlength="128" value="<%=objForm.Fields("DTA_VaeDescription").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Address:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VaeAddress" size="64" maxlength="64" value="<%=replace(objForm.Fields("DTA_VaeAddress").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltStatus"<%if objForm.Fields("DTA_VaeStatus").Value = "1" then%> checked<%end if%> value="1" onClick="javascript:selectStatus('1');">Active&nbsp;
            <input type="radio" name="sltStatus"<%if objForm.Fields("DTA_VaeStatus").Value = "0" then%> checked<%end if%> value="0" onClick="javascript:selectStatus('0');">Inactive&nbsp;
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Email Message Selection&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center colspan=2 nowrap><nobr><select class="clsInputBN" id="sltEmailDetail" name="sltEmailDetail" multiple size=15></select></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:selectEmailDetails();">&nbsp;Select&nbsp;</a></nobr></td></tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" id="tabEmailDetail" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
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
   <input type="hidden" name="DTA_VaeEmail" value="<%=objForm.Fields("DTA_VaeEmail").Value%>">
   <input type="hidden" name="DTA_VaeDescription" value="<%=objForm.Fields("DTA_VaeDescription").Value%>">
   <input type="hidden" name="DTA_VaeAddress" value="<%=replace(objForm.Fields("DTA_VaeAddress").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_VaeStatus" value="<%=objForm.Fields("DTA_VaeStatus").Value%>">
   <input type="hidden" name="INP_VaeStatus" value="<%=objForm.Fields("DTA_VaeStatus").Value%>">
   <input type="hidden" name="DET_DetailCount" value="">
</form>
</body>
</html>