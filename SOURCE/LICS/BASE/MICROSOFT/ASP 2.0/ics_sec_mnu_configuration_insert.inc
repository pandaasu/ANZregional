<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_SemMenu.focus();<%if strReturn <> "*OK" then%>
      alert('<%=strReturn%>');<%else%>return;<%end if%>
   }
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
      if (objElement.className == 'clsSelect') {
         objElement.className = 'clsSelectX';
      }
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
      if (objElement.className == 'clsSelectX') {
         objElement.className = 'clsSelect';
      }
   }
   function checkChange() {
      var bolChange = false;
      var bolReturn;
      if (document.main.INP_SemMenu.value != document.main.DTA_SemMenu.value) {bolChange = true;}
      if (document.main.INP_SemDescription.value != document.main.DTA_SemDescription.value) {bolChange = true;}
      if (changeMenuLinks() == true) {bolChange = true;}
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
      if (document.main.INP_SemMenu.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Menu code must be entered';
      }
      if (document.main.INP_SemDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Menu description must be entered';
      }
      strDetail = checkMenuLinks();
      if (strDetail != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strDetail;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_SemMenu.value = document.main.INP_SemMenu.value;
      document.main.DTA_SemDescription.value = document.main.INP_SemDescription.value;
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
<!--#include file="ics_sec_mnu_configuration_links.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_sec_mnu_configuration_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert Menu');parent.showContent();loadMenuLinks();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Menu Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_SemMenu" size="32" maxlength="32" value="<%=objForm.Fields().Item("DTA_SemMenu")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Menu Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SemDescription" size="128" maxlength="128" value="<%=objForm.Fields().Item("DTA_SemDescription")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Menu Links&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
            <table align=center border=0 cellpadding=0 cellspacing=2 cols=2>
               <tr>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Menus&nbsp;</nobr></td>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Selected&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="sltLink" name="sltMenuLink" style="width:400px" multiple size=10></select>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="sltDetail" name="sltMenuDetail" style="width:400px" multiple size=10></select>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:selectMenuLinks('*MNU');">&nbsp;Select >>&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:removeMenuLinks('*MNU');">&nbsp;<< Remove&nbsp;</a></nobr></td>
                            <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:upMenuLinks('*MNU');">&nbsp;Up&nbsp;</a></nobr></td>
                            <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:downMenuLinks('*MNU');">&nbsp;Down&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
            <table align=center border=0 cellpadding=0 cellspacing=2 cols=2>
               <tr>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Options&nbsp;</nobr></td>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Selected&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="sltLink" name="sltOptionLink" style="width:400px" multiple size=10></select>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="sltDetail" name="sltOptionDetail" style="width:400px" multiple size=10></select>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:selectMenuLinks('*OPT');">&nbsp;Select >>&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:removeMenuLinks('*OPT');">&nbsp;<< Remove&nbsp;</a></nobr></td>
                            <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:upMenuLinks('*OPT');">&nbsp;Up&nbsp;</a></nobr></td>
                            <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:downMenuLinks('*OPT');">&nbsp;Down&nbsp;</a></nobr></td></tr>
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
   <input type="hidden" name="DTA_SemMenu" value="<%=objForm.Fields().Item("DTA_SemMenu")%>">
   <input type="hidden" name="DTA_SemDescription" value="<%=objForm.Fields().Item("DTA_SemDescription")%>">
   <input type="hidden" name="DET_LinkMenuCount" value="">
   <input type="hidden" name="DET_LinkOptionCount" value="">
</form>
</body>
</html>