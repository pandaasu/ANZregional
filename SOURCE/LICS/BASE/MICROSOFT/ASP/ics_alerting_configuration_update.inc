<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_MsgTxt.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_MsgTxt.value != document.main.DTA_MsgTxt.value) {bolChange = true;}
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
      if (document.main.INP_MsgTxt.value == '') {
         if (strMessage != null) {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Setting value must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_MsgTxt.value = document.main.INP_MsgTxt.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'UPDATE_ACCEPT';
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
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_alerting_configuration_update_help.htm');parent.setHeading('<%=strHeading%> - Update Setting');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Search Text:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_SrchTxt").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Message Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_MsgTxt" size="64" maxlength="256" value="<%=objForm.Fields("DTA_MsgTxt").Value%>" onFocus="setSelect(this);">
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
   <input type="hidden" name="DTA_SrchTxt" value="<%=objForm.Fields("DTA_SrchTxt").Value%>">
   <input type="hidden" name="DTA_MsgTxt" value="<%=replace(objForm.Fields("DTA_MsgTxt").Value, """", "&#34;", 1, -1, 1)%>">
</form>
</body>
</html>