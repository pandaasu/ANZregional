<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_SeiInterface.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.DTA_SeiInterface.value != '') {bolChange = true;}
      if (document.main.DTA_SeiUser.value != '') {bolChange = true;}
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
      if (document.main.DTA_SeiInterface.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface identifier must be entered';
      }
      if (document.main.DTA_SeiUser.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'User must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
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
   function selectBasicInterface(objSelect) {
      document.main.DTA_SeiInterface.value = objSelect.options[objSelect.selectedIndex].value;
   }   
   function selectBasicUser(objSelect) {
      document.main.DTA_SeiUser.value = objSelect.options[objSelect.selectedIndex].value;
   }  
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_sec_int_configuration_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert Interface Security');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltBasicInterface" onChange="selectBasicInterface(this);">
               <option value=""<%if objForm.Fields("DTA_SeiInterface").Value = "" then%> selected<%end if%>>Please select interface<%for i = 0 to objSelection.ListCount("INTERFACE") - 1%>
               <option value="<%=objSelection.ListValue01("INTERFACE",i)%>"<%if objForm.Fields("DTA_SeiInterface").Value = objSelection.ListValue01("INTERFACE",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("INTERFACE",i)%>) <%=objSelection.ListValue02("INTERFACE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>     
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;User:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltBasicUser" onChange="selectBasicUser(this);">
               <option value=""<%if objForm.Fields("DTA_SeiUser").Value = "" then%> selected<%end if%>>Please select user<%for i = 0 to objSelection.ListCount("USER") - 1%>
               <option value="<%=objSelection.ListValue01("USER",i)%>"<%if objForm.Fields("DTA_SeiUser").Value = objSelection.ListValue01("USER",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("USER",i)%>) <%=objSelection.ListValue02("USER",i)%><%next%>
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
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_SeiInterface" value="<%=objForm.Fields("DTA_SeiInterface").Value%>">
   <input type="hidden" name="DTA_SeiUser" value="<%=objForm.Fields("DTA_SeiUser").Value%>">
</form>
</body>
</html>