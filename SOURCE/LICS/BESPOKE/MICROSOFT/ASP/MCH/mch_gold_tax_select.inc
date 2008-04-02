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
   function doExport() {
      if (!processForm()) {return;};
      var strMessage = '';
      if (document.main.INP_TaxClass01.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Tax classification range from value must be entered';
      }
      if (document.main.INP_TaxClass02.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Tax classification range to value must be entered';
      }
      if (document.main.INP_SupplyPlant.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Supply plant value must be entered';
      }
      if (document.main.INP_SupplyLocation.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Supply location value must be entered';
      }
      if (document.main.INP_ReceivingPlant.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Receiving plant value must be entered';
      }
      if (document.main.INP_GIDate01.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Goods issued date range from value must be entered';
      }
      if (document.main.INP_GIDate02.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Goods issued date range to value must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strFunction = 'dw_tax_reporting.gold_tax_file(\'' + document.main.INP_TaxClass01.value.replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_TaxClass02.value.replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_SupplyPlant.value.toUpperCase().replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_SupplyLocation.value.toUpperCase().replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_ReceivingPlant.value.toUpperCase().replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_GIDate01.value.replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_GIDate02.value.replace(/\'/g,'').replace(/ /g,'') + '\')';
      doExportOutput(eval('document.body'),'Gold Tax Report','*FILE',strFunction,'','');
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
<!--#include file="ics_std_export.inc"-->
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
            <input class="clsInputNN" type="text" name="INP_TaxClass01" size="20" maxlength="20" value="" onFocus="setSelect(this);">
            <font class="clsLabelBB">&nbsp;to&nbsp;</font>
            <input class="clsInputNN" type="text" name="INP_TaxClass02" size="20" maxlength="20" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Supply Plants:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_SupplyPlant" size="100" maxlength="200" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Supply Storage Locations:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_SupplyLocation" size="100" maxlength="200" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Receiving Plants:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_ReceivingPlant" size="100" maxlength="200" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Goods Issued Date Range (YYYYMMDD):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_GIDate01" size="8" maxlength="8" value="" onFocus="setSelect(this);">
            <font class="clsLabelBB">&nbsp;to&nbsp;</font>
            <input class="clsInputNN" type="text" name="INP_GIDate02" size="8" maxlength="8" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doExport();">&nbsp;Export&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
</form>
</body>
</html>