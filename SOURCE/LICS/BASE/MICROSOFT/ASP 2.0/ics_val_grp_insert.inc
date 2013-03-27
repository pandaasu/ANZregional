<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_VagGroup.focus();<%if strError <> "" then%>
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
      if (document.main.INP_VagGroup.value != document.main.DTA_VagGroup.value) {bolChange = true;}
      if (document.main.INP_VagDescription.value != document.main.DTA_VagDescription.value) {bolChange = true;}
      if (document.main.INP_VagCodLength.value != document.main.DTA_VagCodLength.value) {bolChange = true;}
      if (document.main.INP_VagCodQuery.value != document.main.DTA_VagCodQuery.value) {bolChange = true;}
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
      if (document.main.INP_VagGroup.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Group identifier must be entered';
      }
      if (document.main.INP_VagDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Group description must be entered';
      }
      if (document.main.INP_VagCodLength.value == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Group code length must not be zero';
      }
      if (document.main.INP_VagCodQuery.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Group code query must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_VagGroup.value = document.main.INP_VagGroup.value;
      document.main.DTA_VagDescription.value = document.main.INP_VagDescription.value;
      document.main.DTA_VagCodLength.value = document.main.INP_VagCodLength.value;
      document.main.DTA_VagCodQuery.value = document.main.INP_VagCodQuery.value;
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
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_val_grp_help.htm');parent.setHeading('<%=strHeading%> - Insert Group');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_VagGroup" size="30" maxlength="30" value="<%=objForm.Fields().Item("DTA_VagGroup")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VagDescription" size="64" maxlength="128" value="<%=objForm.Fields().Item("DTA_VagDescription")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Code Length:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VagCodLength" size="5" maxlength="5" value="<%=objForm.Fields().Item("DTA_VagCodLength")%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Code Query:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <textarea class="clsInputFN" type="text" name="INP_VagCodQuery" rows="20" cols="100" wrap="off" onFocus="setSelect(this);"><%=replace(objForm.Fields().Item("DTA_VagCodQuery"), """", "&#34;", 1, -1, 1)%></textArea>
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
   <input type="hidden" name="DTA_VagGroup" value="<%=objForm.Fields().Item("DTA_VagGroup")%>">
   <input type="hidden" name="DTA_VagDescription" value="<%=objForm.Fields().Item("DTA_VagDescription")%>">
   <input type="hidden" name="DTA_VagCodLength" value="<%=objForm.Fields().Item("DTA_VagCodLength")%>">
   <input type="hidden" name="DTA_VagCodQuery" value="<%=replace(objForm.Fields().Item("DTA_VagCodQuery"), """", "&#34;", 1, -1, 1)%>">
</form>
</body>
</html>