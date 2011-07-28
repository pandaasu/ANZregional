<html>
<script language="javascript">
<!--
   function showError() {<%if strMode <> "CONFIRM" then%>
      document.main.INP_Group.focus();<%end if%><%if strReturn <> "*OK" then%>
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
   }<%if strMode <> "CONFIRM" then%>
   function doSubmit() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_Group.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Group must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (confirm('Please confirm that you wish to continue\r\nPress OK to continue\r\nOr press Cancel')) {
         document.main.DTA_Group.value = document.main.INP_Group.value;
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
   function selectGroup(objSelect) {
      document.main.INP_Group.value = objSelect.options[objSelect.selectedIndex].value;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_val_sbm_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0"><%if strMode = "CONFIRM" then%>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=2 nowrap><nobr>&nbsp;Validation successfully submitted for - <%=objForm.Fields("DTA_Group").Value%>&nbsp;</nobr></td>
      </tr><%else%>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltGroup" onChange="selectGroup(this);">
               <option value=""<%if objForm.Fields("DTA_Group").Value = "" then%> selected<%end if%>>** select group **<%for i = 0 to objSelection.ListCount("GROUP") - 1%>
               <option value="<%=objSelection.ListValue01("GROUP",i)%>"<%if objForm.Fields("DTA_Group").Value = objSelection.ListValue01("GROUP",i) then%> selected<%end if%>><%=objSelection.ListValue02("GROUP",i)%><%next%>
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
      </tr><%end if%>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_Group" value="<%=objForm.Fields("DTA_Group").Value%>">
   <input type="hidden" name="INP_Group" value="<%=objForm.Fields("DTA_Group").Value%>">
</form>
</body>
</html>