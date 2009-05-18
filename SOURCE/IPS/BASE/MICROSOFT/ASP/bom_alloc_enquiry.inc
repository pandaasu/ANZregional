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
   function doExecute() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.DTA_Company.value == '') {
         if (strMessage != null) {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Company code must be entered';
      }
      if (document.main.DTA_Material.value == '') {
         if (strMessage != null) {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Material code must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'EXECUTE';
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
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="no" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('bom_alloc_enquiry_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Company Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DTA_Company" size="3" maxlength="3" value="<%=objForm.Fields("DTA_Company").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Material Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DTA_Material" size="18" maxlength="18" value="<%=objForm.Fields("DTA_Material").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Enquiry Date (YYYYMMDD):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DTA_Date" size="8" maxlength="8" value="<%=objForm.Fields("DTA_Date").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doExecute();">&nbsp;Execute&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      </table></nobr></td></tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=23 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Plant&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Material&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Allocation %&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Alternative&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Qty&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM UOM&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM TDU&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Base UOM&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Net Weight&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Gross Weight&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Child Material&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Child Qty&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Child UOM&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Child Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Child Base UOM&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Child Net Weight&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Child Gross Weight&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Path Level&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Path Root&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BOM Path&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=22 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("REPORT") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=1 nowrap><nobr>&nbsp;NO BOM DATA FOUND&nbsp</nobr></td></tr><%else%><%for i = objSelection.ListLower("REPORT") to objSelection.ListUpper("REPORT")%>
                        <tr>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue03("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue19("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue04("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue05("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue06("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue07("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue08("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue09("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue10("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue11("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue12("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue13("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue14("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue15("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue16("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue17("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue18("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue20("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue21("REPORT",i)%></nobr></td>
                           <td class="clsList" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue22("REPORT",i)%></nobr></td>
                        </tr><%next%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
</form>
</body>
</html>