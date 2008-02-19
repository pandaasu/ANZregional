<html>
<script language="javascript">
<!--
   function showError() {<%if strError <> "" then%>
      alert('<%=strError%>');<%else%>return;<%end if%>
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
   function doDisplay() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_TaxClass01.value = document.main.INP_TaxClass01.value;
      document.main.DTA_TaxClass02.value = document.main.INP_TaxClass02.value;
      document.main.DTA_SupplyPlant.value = document.main.INP_SupplyPlant.value;
      document.main.DTA_SupplyLocation.value = document.main.INP_SupplyLocation.value;
      document.main.DTA_ReceivingPlant.value = document.main.INP_ReceivingPlant.value;
      document.main.DTA_GIDate01.value = document.main.INP_GIDate01.value;
      document.main.DTA_GIDate02.value = document.main.INP_GIDate02.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'ACCEPT';
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('mch_gold_tax_select_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Tax Classification Range:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_TaxClass01" size="20" maxlength="20" value="<%=objForm.Fields("DTA_TaxClass01").Value%>" onFocus="setSelect(this);">
            <font class="clsLabelBB">&nbsp;to&nbsp;</font>
            <input class="clsInputNN" type="text" name="INP_TaxClass02" size="20" maxlength="20" value="<%=objForm.Fields("DTA_TaxClass02").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Supply Plants:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_SupplyPlant" size="100" maxlength="200" value="<%=objForm.Fields("DTA_SupplyPlant").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Supply Storage Locations:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_SupplyLocation" size="100" maxlength="200" value="<%=objForm.Fields("DTA_SupplyLocation").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Receiving Plants:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_TaxClass02").Value%>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_ReceivingPlant" size="100" maxlength="200" value="<%=objForm.Fields("DTA_ReceivingPlant").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Goods Issued Date Range (YYYYMMDD):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_GIDate01" size="8" maxlength="8" value="<%=objForm.Fields("DTA_GIDate01").Value%>" onFocus="setSelect(this);">
            <font class="clsLabelBB">&nbsp;to&nbsp;</font>
            <input class="clsInputNN" type="text" name="INP_GIDate02" size="8" maxlength="8" value="<%=objForm.Fields("DTA_GIDate02").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDisplay();">&nbsp;Display&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_TaxClass01" value="<%=objForm.Fields("DTA_TaxClass01").Value%>">
   <input type="hidden" name="DTA_TaxClass02" value="<%=objForm.Fields("DTA_TaxClass02").Value%>">
   <input type="hidden" name="DTA_TaxClass02" value="<%=objForm.Fields("DTA_SupplyPlant").Value%>">
   <input type="hidden" name="DTA_TaxClass02" value="<%=objForm.Fields("DTA_SupplyLocation").Value%>">
   <input type="hidden" name="DTA_TaxClass02" value="<%=objForm.Fields("DTA_ReceivingPlant").Value%>">
   <input type="hidden" name="DTA_TaxClass02" value="<%=objForm.Fields("DTA_GIDate01").Value%>">
   <input type="hidden" name="DTA_TaxClass02" value="<%=objForm.Fields("DTA_GIDate02").Value%>">
</form>
</body>
</html>