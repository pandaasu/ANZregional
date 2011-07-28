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
   }<%if strMode <> "CONFIRM" then%>
   function doSubmit() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_Interface.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface must be selected';
      }
      if (document.main.INP_User.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'User must be entered';
      }
      if (document.main.INP_Password.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Password must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (confirm('Please confirm that you wish to continue\r\nPress OK to continue\r\nOr press Cancel')) {
         document.main.SLT_Interface.value = document.main.INP_Interface.value;
         document.main.SLT_User.value = document.main.INP_User.value;
         document.main.SLT_Password.value = document.main.INP_Password.value;
         document.main.action = '<%=strBase%><%=strTarget%>';
         document.main.Mode.value = 'SUBMIT';
         document.main.submit();
      }
   }<%end if%>
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectInterface(objSelect) {
      document.main.INP_Interface.value = objSelect.options[objSelect.selectedIndex].value;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_sap_interface_help.htm');parent.setHeading('<%=strHeading%> - Submit');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltInterface" onChange="selectInterface(this);">
               <option value="" selected>** select interface **<%for i = 0 to objSelection.ListCount("INTERFACE") - 1%>
               <option value="<%=objSelection.ListValue01("INTERFACE",i)%>">(<%=objSelection.ListValue01("INTERFACE",i)%>)&nbsp;<%=objSelection.ListValue02("INTERFACE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SAP User:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_User" size="30" maxlength="30" value="<%=objForm.Fields("SLT_User").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SAP Password:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="password" name="INP_Password" size="30" maxlength="30" value="<%=objForm.Fields("SLT_Password").Value%>" onFocus="setSelect(this);">
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
   <input type="hidden" name="SLT_Interface" value="<%=objForm.Fields("SLT_Interface").Value%>">
   <input type="hidden" name="INP_Interface" value="<%=objForm.Fields("SLT_Interface").Value%>">
   <input type="hidden" name="SLT_User" value="<%=objForm.Fields("SLT_User").Value%>">
   <input type="hidden" name="SLT_Password" value="<%=objForm.Fields("SLT_Password").Value%>">
</form>
</body>
</html>