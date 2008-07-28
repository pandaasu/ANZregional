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
   function processHeaderMessage(strHeader,strTrace) {
      var strURL;
      strURL = '<%=strBase%>ics_int_hdr_message.asp?';
      strURL = strURL + 'QRY_Header=' + strHeader;
      strURL = strURL + '&QRY_Trace=' + strTrace;
      openDialog(strURL);
   }
   function processDataMessage(strHeader,strTrace,strSequence) {
      var strURL;
      strURL = '<%=strBase%>ics_int_dta_message.asp?';
      strURL = strURL + 'QRY_Header=' + strHeader;
      strURL = strURL + '&QRY_Trace=' + strTrace;
      strURL = strURL + '&QRY_Sequence=' + strSequence;
      openDialog(strURL);
   }
   function selectError(objSelect) {
      document.main.QRY_Error.value = objSelect.options[objSelect.selectedIndex].value;
      document.all.conBody.innerHTML = '<font style="color=#ffffff">&nbsp;** RELOADING **&nbsp;</font>';
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.submit();
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_modal.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_int_detail_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue01("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Trace:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue02("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue03("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue04("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue05("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue06("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface User:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue07("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Start Time:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue08("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface End Time:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue09("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Status:&nbsp;</nobr></td>
         <td class="<%=aryIntClass(objSelection.ListValue10("DETAIL",0))%>" align=left colspan=1 nowrap><nobr>&nbsp;<%if objSelection.ListValue11("DETAIL",0) = "x" then%><a class="clsError" href="javascript:processHeaderMessage('<%=objForm.Fields("QRY_Header").Value%>','<%=objForm.Fields("QRY_Trace").Value%>');"><%=aryIntStatus(objSelection.ListValue10("DETAIL",0))%></a><%else%><%=aryIntStatus(objSelection.ListValue10("DETAIL",0))%><%end if%>&nbsp;</nobr></td>
      </tr>
      <tr><%if objSelection.ListValue04("DETAIL",0) = "*INBOUND" then%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Errors Lines Only:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltQryError" onChange="selectError(this);">
               <option value="N"<%if objForm.Fields("QRY_Error").Value <> "Y" then%> selected<%end if%>>No
               <option value="Y"<%if objForm.Fields("QRY_Error").Value = "Y" then%> selected<%end if%>>Yes
            </select>
         </nobr></td>
      </tr><%end if%>
      <tr>
         <td class="clsLabelBB" align=right colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=2 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHC" align=left colspan=1 nowrap><nobr><%=strDataHead%></nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=1 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("DATA") = 0 then%>
                        <tr><td class="clsLabelFB" align=left colspan=1 nowrap><nobr>&nbsp;NO DATA FOUND&nbsp</nobr></td></tr><%else%>
                        <tr>
                           <td class="clsNormalFix" align=left colspan=1><pre><%for i = objSelection.ListLower("DATA") to objSelection.ListUpper("DATA")%><%if i < lngMaximum - 1 then%><%if objSelection.ListValue04("DETAIL",0) = "*INBOUND" and objSelection.ListValue03("DATA",i) = "x" then%>
<a class="clsErrorFix" href="javascript:processDataMessage('<%=objForm.Fields("QRY_Header").Value%>','<%=objForm.Fields("QRY_Trace").Value%>','<%=objSelection.ListValue02("DATA",i)%>');"><%=replace(replace(objSelection.ListValue01("DATA",i), "<", "&lt;", 1, -1, 1), ">", "&gt;", 1, -1, 1)%></a><%else%>
<font class="clsNormalFix"><%=replace(replace(objSelection.ListValue01("DATA",i), "<", "&lt;", 1, -1, 1), ">", "&gt;", 1, -1, 1)%></font><%end if%><%else%>
<font class="clsNormalFix">**MAXIMUM VIEWABLE ROWS RETRIEVED**</font><%end if%><%next%></pre></td>
                        </tr><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="QRY_Header" value="<%=objForm.Fields("QRY_Header").Value%>">
   <input type="hidden" name="QRY_Trace" value="<%=objForm.Fields("QRY_Trace").Value%>">
   <input type="hidden" name="QRY_Error" value="<%=objForm.Fields("QRY_Error").Value%>">
</form>
</body>
</html>