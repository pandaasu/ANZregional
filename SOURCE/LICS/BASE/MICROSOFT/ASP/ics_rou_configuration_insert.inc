<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_RouSource.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_RouSource.value != document.main.DTA_RouSource.value) {bolChange = true;}
      if (document.main.INP_RouDescription.value != document.main.DTA_RouDescription.value) {bolChange = true;}
      if (document.main.INP_RouPreLength.value != document.main.DTA_RouPreLength.value) {bolChange = true;}
      if (changeRoutingDetails() == true) {bolChange = true;}
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
      if (document.main.INP_RouSource.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Routing source must be entered';
      }
      if (document.main.INP_RouDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Routing description must be entered';
      }
      if (document.main.INP_RouPreLength.value == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Routing prefix length must not be zero';
      }
      strDetail = checkRoutingDetails();
      if (strDetail != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strDetail;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_RouSource.value = document.main.INP_RouSource.value;
      document.main.DTA_RouDescription.value = document.main.INP_RouDescription.value;
      document.main.DTA_RouPreLength.value = document.main.INP_RouPreLength.value;
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
<!--#include file="ics_rou_configuration_details.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_rou_configuration_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert Routing');parent.showContent();loadRoutingDetails();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Routing Source:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_RouSource" size="32" maxlength="32" value="<%=objForm.Fields("DTA_RouSource").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Routing Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_RouDescription" size="64" maxlength="128" value="<%=objForm.Fields("DTA_RouDescription").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Routing Prefix Length:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_RouPreLength" size="2" maxlength="2" value="<%=objForm.Fields("DTA_RouPreLength").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Routing Details&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" id="tabRoutingDetails" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
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
   <input type="hidden" name="DTA_RouSource" value="<%=objForm.Fields("DTA_RouSource").Value%>">
   <input type="hidden" name="DTA_RouDescription" value="<%=objForm.Fields("DTA_RouDescription").Value%>">
   <input type="hidden" name="DTA_RouPreLength" value="<%=objForm.Fields("DTA_RouPreLength").Value%>">
   <input type="hidden" name="DET_Count" value="">
</form>
</body>
</html>