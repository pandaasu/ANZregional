<html>
<script language="javascript">
<!--
   function showError() {
      document.main.sltType.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_SapCustType.value != document.main.DTA_SapCustType.value) {bolChange = true;}
      if (document.main.INP_SapCustCode.value != document.main.DTA_SapCustCode.value) {bolChange = true;}
      if (document.main.INP_EdiLink.value != document.main.DTA_EdiLink.value) {bolChange = true;}
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
      if (document.main.INP_SapCustType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'SAP customer type must be selected';
      }
      if (document.main.INP_SapCustCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'SAP customer code must be entered';
      }
      if (document.main.INP_EdiLink.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'EDI link must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_SapCustType.value = document.main.INP_SapCustType.value;
      document.main.DTA_SapCustCode.value = document.main.INP_SapCustCode.value;
      document.main.DTA_EdiLink.value = document.main.INP_EdiLink.value;
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
      document.main.INP_SapCustType.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectLink(objSelect) {
      document.main.INP_EdiLink.value = objSelect.options[objSelect.selectedIndex].value;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('mjp_edi_link_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert Link');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;SAP Customer Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltType" onChange="selectType(this);">
               <option value=""<%if objForm.Fields("DTA_SapCustTtpe").Value = "" then%> selected<%end if%>>** select type **
               <option value="*SOLDTO"<%if objForm.Fields("DTA_SapCustType").Value = "*SOLDTO" then%> selected<%end if%>>Sold To Customer
               <option value="*PAYER"<%if objForm.Fields("DTA_SapCustType").Value = "*PAYER" then%> selected<%end if%>>Payer Customer
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SAP Customer Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SapCustCode" size="10" maxlength="10" value="<%=objForm.Fields("DTA_SapCustCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;EDI Link:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltLink" onChange="selectLink(this);">
               <option value=""<%if objForm.Fields("DTA_EdiLink").Value = "" then%> selected<%end if%>>** select link **<%for i = 0 to objSelection.ListCount("EDILINK") - 1%>
               <option value="<%=objSelection.ListValue01("EDILINK",i)%>"<%if objForm.Fields("DTA_EdiLink").Value = objSelection.ListValue01("EDILINK",i) then%> selected<%end if%>><%=objSelection.ListValue02("EDILINK",i)%><%next%>
            </select>
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
   <input type="hidden" name="DTA_SapCustType" value="<%=objForm.Fields("DTA_SapCustType").Value%>">
   <input type="hidden" name="DTA_SapCustCode" value="<%=objForm.Fields("DTA_SapCustCode").Value%>">
   <input type="hidden" name="DTA_EdiLink" value="<%=objForm.Fields("DTA_EdiLink").Value%>">
   <input type="hidden" name="INP_SapCustType" value="<%=objForm.Fields("DTA_SapCustType").Value%>">
   <input type="hidden" name="INP_EdiLink" value="<%=objForm.Fields("DTA_EdiLink").Value%>">
</form>
</body>
</html>