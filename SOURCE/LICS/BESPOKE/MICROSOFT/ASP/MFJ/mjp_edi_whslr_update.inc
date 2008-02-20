<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_EdiWhslrCode.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_EdiWhslrCode.value != document.main.DTA_EdiWhslrCode.value) {bolChange = true;}
      if (document.main.INP_EdiWhslrName.value != document.main.DTA_EdiWhslrName.value) {bolChange = true;}
      if (document.main.INP_EdiDiscCode.value != document.main.DTA_EdiDiscCode.value) {bolChange = true;}
      if (document.main.INP_EdiEmailGroup.value != document.main.DTA_EdiEmailGroup.value) {bolChange = true;}
      if (document.main.INP_EdiGentoDay.value != document.main.DTA_EdiGentoDay.value) {bolChange = true;}
      if (document.main.INP_EdiGentoYear.value != document.main.DTA_EdiGentoYear.value) {bolChange = true;}
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
      if (document.main.INP_EdiWhslrCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Wholesaler code must be entered';
      }
      if (document.main.INP_EdiWhslrName.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Wholesaler name must be entered';
      }
      if (document.main.INP_EdiDiscCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Discount code must be selected';
      }
      if (document.main.INP_EdiEmailGroup.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Email group must be entered';
      }
      if (document.main.INP_EdiGentoDay.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Generate billing events must be selected';
      }
      if (document.main.INP_EdiGentoDay.value != '*NONE') {
         if (document.main.INP_EdiGentoYear.value < '2000') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Generate billing year must be entered and greater than 2000';
         }
      } else {
         if (document.main.INP_EdiGentoYear.value != '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Generate billing year must not be entered';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_EdiWhslrCode.value = document.main.INP_EdiWhslrCode.value;
      document.main.DTA_EdiWhslrName.value = document.main.INP_EdiWhslrName.value;
      document.main.DTA_EdiDiscCode.value = document.main.INP_EdiDiscCode.value;
      document.main.DTA_EdiEmailGroup.value = document.main.INP_EdiEmailGroup.value;
      document.main.DTA_EdiGentoDay.value = document.main.INP_EdiGentoDay.value;
      document.main.DTA_EdiGentoYear.value = document.main.INP_EdiGentoYear.value;
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
   function selectDiscCode(objSelect) {
      document.main.INP_EdiDiscCode.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectGentoDay(objSelect) {
      document.main.INP_EdiGentoDay.value = objSelect.options[objSelect.selectedIndex].value;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('mjp_edi_whslr_update_help.htm');parent.setHeading('<%=strHeading%> - Update');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Send To Code:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_EdiSndtoCode").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Wholesaler Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_EdiWhslrCode" size="20" maxlength="20" value="<%=objForm.Fields("DTA_EdiWhslrCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Wholesaler Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EdiWhslrName" size="64" maxlength="128" value="<%=objForm.Fields("DTA_EdiWhslrName").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Discount Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltEdiDiscCode" onChange="selectDiscCode(this);">
               <option value="A"<%if objForm.Fields("DTA_EdiDiscCode").Value = "A" then%> selected<%end if%>>All
               <option value="V"<%if objForm.Fields("DTA_EdiDiscCode").Value = "V" then%> selected<%end if%>>Volume only
               <option value="N"<%if objForm.Fields("DTA_EdiDiscCode").Value = "N" then%> selected<%end if%>>None
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EdiEmailGroup" size="64" maxlength="64" value="<%=replace(objForm.Fields("DTA_EdiEmailGroup").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Last Monthly Billing Event Date:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_EdiBiltoDate").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Generate Monthly Billing Events:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltEdiGentoDay" onChange="selectGentoDay(this);">
               <option value="*NONE"<%if objForm.Fields("DTA_EdiGentoDay").Value = "*NONE" then%> selected<%end if%>>No generation
               <option value="*LAST">Last day of the month
               <option value="01">Day 1 of the month
               <option value="02">Day 2 of the month
               <option value="03">Day 3 of the month
               <option value="04">Day 4 of the month
               <option value="05">Day 5 of the month
               <option value="06">Day 6 of the month
               <option value="07">Day 7 of the month
               <option value="08">Day 8 of the month
               <option value="09">Day 9 of the month
               <option value="10">Day 10 of the month
               <option value="11">Day 11 of the month
               <option value="12">Day 12 of the month
               <option value="13">Day 13 of the month
               <option value="14">Day 14 of the month
               <option value="15">Day 15 of the month
               <option value="16">Day 16 of the month
               <option value="17">Day 17 of the month
               <option value="18">Day 18 of the month
               <option value="19">Day 19 of the month
               <option value="20">Day 20 of the month
               <option value="21">Day 21 of the month
               <option value="22">Day 22 of the month
               <option value="23">Day 23 of the month
               <option value="24">Day 24 of the month
               <option value="25">Day 25 of the month
               <option value="26">Day 26 of the month
               <option value="27">Day 27 of the month
               <option value="28">Day 28 of the month
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Generate Monthly Billing Events End Year:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EdiGentoYear" size="4" maxlength="4" value="<%=objForm.Fields("DTA_EdiGentoYear").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
   <input type="hidden" name="DTA_EdiSndtoCode" value="<%=objForm.Fields("DTA_EdiSndtoCode").Value%>">
   <input type="hidden" name="DTA_EdiWhslrCode" value="<%=objForm.Fields("DTA_EdiWhslrCode").Value%>">
   <input type="hidden" name="DTA_EdiWhslrName" value="<%=objForm.Fields("DTA_EdiWhslrName").Value%>">
   <input type="hidden" name="DTA_EdiDiscCode" value="<%=objForm.Fields("DTA_EdiDiscCode").Value%>">
   <input type="hidden" name="DTA_EdiEmailGroup" value="<%=replace(objForm.Fields("DTA_EdiEmailGroup").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_EdiBiltoDate" value="<%=objForm.Fields("DTA_EdibiltoDate").Value%>">
   <input type="hidden" name="DTA_EdiGentoDay" value="<%=objForm.Fields("DTA_EdiGentoDay").Value%>">
   <input type="hidden" name="DTA_EdiGentoYear" value="<%=objForm.Fields("DTA_EdiGentoYear").Value%>">
   <input type="hidden" name="INP_EdiDiscCode" value="<%=objForm.Fields("DTA_EdiDiscCode").Value%>">
   <input type="hidden" name="INP_EdiGentoDay" value="<%=objForm.Fields("DTA_EdiGentoDay").Value%>">
</form>
</body>
</html>