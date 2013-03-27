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
   function doReport() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_DeliveryPlant.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Delivery plant value must be entered';
      }
      if (document.main.INP_PDDate01.value != '' || document.main.INP_PDDate02.value != '') {
         if (document.main.INP_PDDate01.value == '' || document.main.INP_PDDate02.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'POD date range to and from values must both be entered';
         }
      }
      if (document.main.INP_OrderType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Order type value must be entered';
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
      var strFunction = 'dw_tax_reporting.sample_pricing(\'' + document.main.INP_DeliveryPlant.value.toUpperCase().replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_PDDate01.value.toUpperCase().replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_PDDate02.value.toUpperCase().replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_OrderType.value.toUpperCase().replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_GIDate01.value.toUpperCase().replace(/\'/g,'').replace(/ /g,'') + '\'';
      strFunction = strFunction + ',\'' + document.main.INP_GIDate02.value.toUpperCase().replace(/\'/g,'').replace(/ /g,'') + '\')';
      doReportOutput(eval('document.body'),'Sample Pricing Tax Report','*SPREADSHEET','select * from table(' + strFunction + ')');
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
<!--#include file="ics_std_report.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('mch_tax_sample_pricing_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Delivery Plants:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_DeliveryPlant" size="100" maxlength="200" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;POD Date Range (YYYYMMDD - Optional):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_PDDate01" size="8" maxlength="8" value="" onFocus="setSelect(this);">
            <font class="clsLabelBB">&nbsp;to&nbsp;</font>
            <input class="clsInputNN" type="text" name="INP_PDDate02" size="8" maxlength="8" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Order Types:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_OrderType" size="100" maxlength="200" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doReport();">&nbsp;Report&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
</form>
</body>
</html>