<html>
<script language="javascript">
<!--
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_asn_dcs_detail_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head01','Body01','horizontal');setScrollable('Head','Body','horizontal');">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr height=50%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead01">
                     <table class="clsTableHead" id="tabHead01" align=left cols=3 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Header Data&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Value&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody01">
                     <table class="clsTableBody" id="tabBody01" align=left cols=2 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Mars code</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Pick number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Pick type</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue03("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Created</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue04("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Updated</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue05("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Sent</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue06("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Acknowledged</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue07("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Status</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue08("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Delivery received</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue09("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Order received</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue10("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Shipment received</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue11("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Invoice received</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue12("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Supplier IID</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue13("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Supplier name</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue14("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Send number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue15("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Send count</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue16("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Error message</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue17("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>Warehouse System</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Warehouse file identifier</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue18("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Warehouse pick number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue19("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Warehouse ship from</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue20("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Warehouse send date</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue21("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Warehouse despatch date</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue22("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Warehouse pallet number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue23("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Warehouse pallet spaces</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue24("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Warehouse consignment number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue25("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Warehouse ship to</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue26("HEADER01",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>Transaction System</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction pick number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction order number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction shipment number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue03("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction invoice number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue04("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction Mars IID</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue05("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction customer IID</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue06("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction customer PO number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue07("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction agreed delivery date</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue08("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction order date</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue09("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction invoice date</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue10("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction split shipment</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue11("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction invoice value</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue12("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction invoice GST</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue13("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction currency</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue14("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction ship to IID</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue15("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction ship to name</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue16("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction dock number</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue17("HEADER02",0)%></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelFB" align=left colspan=1 nowrap><nobr>Transaction buyer identifier</nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue18("HEADER02",0)%></nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=13 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;SSCC Number&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Id Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Pack Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Equipment Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;GTIN&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Batch&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;BB Date&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Pallet Quantity&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Pallet Layers&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Layer Units&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Material Code&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Customer GTIN&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=12 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("DETAIL") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=11 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%for i = objSelection.ListLower("DETAIL") to objSelection.ListUpper("DETAIL")%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue08("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue09("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue10("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue11("DETAIL",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue12("DETAIL",i)%></nobr></td>
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