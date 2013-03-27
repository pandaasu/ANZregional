<html>
<script language="javascript">
<!--<%if strMode = "ERROR" then%>
   function showError() {
      alert('<%=strError%>');
   }<%end if%><%if strMode = "CONFIRM" then%>
   function showConfirm() {
      if (confirm('<%=strConfirm%>\r\n\r\npress OK confirm\r\npress Cancel to ignore')) {
         document.main.DTA_Transaction.value = document.main.INP_Transaction.value;
         document.main.DTA_Identifier.value = document.main.INP_Identifier.value;
         document.main.action = '<%=strBase%><%=strTarget%>';
         document.main.Mode.value = 'DELETE';
         document.main.submit();
      }
   }<%end if%><%if strMode = "FINAL" then%>
   function showFinal() {
      alert('<%=strFinal%>');
   }<%end if%>
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
   function doDelete() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_Transaction.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Transaction type must be selected';
      }
      if (document.main.INP_Identifier.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Transaction identifier must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_Transaction.value = document.main.INP_Transaction.value;
      document.main.DTA_Identifier.value = document.main.INP_Identifier.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'CONFIRM';
      document.main.submit();
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectTransaction(strTransaction) {
      document.main.INP_Transaction.value = strTransaction;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_lads_deletion_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();<%if strMode = "ERROR" then%>showError();<%end if%><%if strMode = "CONFIRM" then%>showConfirm();<%end if%><%if strMode = "FINAL" then%>showFinal();<%end if%>">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Transaction Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltTransaction"<%if objForm.Fields().Item("DTA_Transaction") = "*ORD" then%> checked<%end if%> value="*ORD" onClick="javascript:selectTransaction('*ORD');">Sales Order&nbsp;
            <input type="radio" name="sltTransaction"<%if objForm.Fields().Item("DTA_Transaction") = "*DLV" then%> checked<%end if%> value="*DLV" onClick="javascript:selectTransaction('*DLV');">Delivery&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Transaction Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_Identifier" size="10" maxlength="10" value="<%=objForm.Fields().Item("DTA_Identifier")%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="DTA_Transaction" value="<%=objForm.Fields().Item("DTA_Transaction")%>">
   <input type="hidden" name="DTA_Identifier" value="<%=objForm.Fields().Item("DTA_Identifier")%>">
   <input type="hidden" name="INP_Transaction" value="<%=objForm.Fields().Item("DTA_Transaction")%>">
</form>
</body>
</html>