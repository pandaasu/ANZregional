<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_EdiAgencyCode.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_EdiAgencyCode.value != document.main.DTA_EdiAgencyCode.value) {bolChange = true;}
      if (document.main.INP_SapSalesCode.value != document.main.DTA_SapSalesCode.value) {bolChange = true;}
      if (document.main.INP_SapDistributionCode.value != document.main.DTA_SapDistributionCode.value) {bolChange = true;}
      if (document.main.INP_SapDivisionCode.value != document.main.DTA_SapDivisionCode.value) {bolChange = true;}
      if (document.main.INP_EdiInterface.value != document.main.DTA_EdiInterface.value) {bolChange = true;}
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
      if (document.main.INP_EdiAgencyCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'collection agency code must be entered';
      }
      if (document.main.INP_SapSalesCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'SAP sales organisation must be entered';
      }
      if (document.main.INP_SapDistributionCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'SAP distribution channel must be entered';
      }
      if (document.main.INP_SapDivisionCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'SAP division must be entered';
      }
      if (document.main.INP_EdiInterface.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'ICS interface code must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_EdiAgencyCode.value = document.main.INP_EdiAgencyCode.value;
      document.main.DTA_SapSalesCode.value = document.main.INP_SapSalesCode.value;
      document.main.DTA_SapDistributionCode.value = document.main.INP_SapDistributionCode.value;
      document.main.DTA_SapDivisionCode.value = document.main.INP_SapDivisionCode.value;
      document.main.DTA_EdiInterface.value = document.main.INP_EdiInterface.value;
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
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('mjp_edi_agency_interface_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert Interface');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Collection Agency Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EdiAgencyCode" size="20" maxlength="20" value="<%=objForm.Fields("DTA_EdiAgencyCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SAP Sales Organisation Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SapSalesCode" size="10" maxlength="10" value="<%=objForm.Fields("DTA_SapSalesCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SAP Distribution Channel Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SapDistributionCode" size="10" maxlength="10" value="<%=objForm.Fields("DTA_SapDistributionCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SAP Division Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SapDivisionCode" size="10" maxlength="10" value="<%=objForm.Fields("DTA_SapDivisionCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;ICS Interface Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_EdiInterface" size="32" maxlength="32" value="<%=objForm.Fields("DTA_EdiInterface").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
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
   <input type="hidden" name="DTA_EdiAgencyCode" value="<%=objForm.Fields("DTA_EdiAgencyCode").Value%>">
   <input type="hidden" name="DTA_SapSalesCode" value="<%=objForm.Fields("DTA_SapSalesCode").Value%>">
   <input type="hidden" name="DTA_SapDistributionCode" value="<%=objForm.Fields("DTA_SapDistributionCode").Value%>">
   <input type="hidden" name="DTA_SapDivisionCode" value="<%=objForm.Fields("DTA_SapDivisionCode").Value%>">
   <input type="hidden" name="DTA_EdiInterface" value="<%=objForm.Fields("DTA_EdiInterface").Value%>">
</form>
</body>
</html>