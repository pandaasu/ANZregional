<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_VafFilter.focus();<%if strError <> "" then%>
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
      if (document.main.INP_VafFilter.value != document.main.DTA_VafFilter.value) {bolChange = true;}
      if (document.main.INP_VafDescription.value != document.main.DTA_VafDescription.value) {bolChange = true;}
      if (document.main.INP_VafType.value != document.main.DTA_VafType.value) {bolChange = true;}
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
      if (document.main.INP_VafFilter.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Filter identifier must be entered';
      }
      if (document.main.INP_VafDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Filter description must be entered';
      }
      if (document.main.INP_VafType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Filter type must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_VafFilter.value = document.main.INP_VafFilter.value;
      document.main.DTA_VafDescription.value = document.main.INP_VafDescription.value;
      document.main.DTA_VafType.value = document.main.INP_VafType.value;
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
      document.main.INP_VafType.value = objSelect.options[objSelect.selectedIndex].value;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_val_fil_help.htm');parent.setHeading('<%=strHeading%> - Insert Filter');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Group:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields().Item("DTA_VafGroup")%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Filter:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_VafFilter" size="30" maxlength="30" value="<%=objForm.Fields().Item("DTA_VafFilter")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VafDescription" size="64" maxlength="128" value="<%=objForm.Fields().Item("DTA_VafDescription")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltType" onChange="selectType(this);">
               <option value=""<%if objForm.Fields().Item("DTA_VafType") = "" then%> selected<%end if%>>** select type **<%for i = 0 to clng(objSelection.ListCount("TYPE")) - 1%>
               <option value="<%=objSelection.ListValue01("TYPE",i)%>"<%if objForm.Fields().Item("DTA_VafType") = objSelection.ListValue01("TYPE",i) then%> selected<%end if%>><%=objSelection.ListValue02("TYPE",i)%><%next%>
            </select>
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
   <input type="hidden" name="DTA_VafFilter" value="<%=objForm.Fields().Item("DTA_VafFilter")%>">
   <input type="hidden" name="DTA_VafDescription" value="<%=objForm.Fields().Item("DTA_VafDescription")%>">
   <input type="hidden" name="DTA_VafGroup" value="<%=objForm.Fields().Item("DTA_VafGroup")%>">
   <input type="hidden" name="DTA_VafType" value="<%=objForm.Fields().Item("DTA_VafType")%>">
   <input type="hidden" name="INP_VafType" value="<%=objForm.Fields().Item("DTA_VafType")%>">
</form>
</body>
</html>