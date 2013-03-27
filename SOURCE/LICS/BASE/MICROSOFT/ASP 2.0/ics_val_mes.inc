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
   function doEnquire() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_Group.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Group must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'ENQUIRE';
      document.main.DTA_Group.value = document.main.INP_Group.value;
      document.main.submit();
   }
   function doDownload(strGroup,strData,strSelect) {
      var strURL = '<%=strBase%>ics_val_mes_download.asp';
      strURL = strURL + '?DTA_Data=' + strData;
      strURL = strURL + '&DTA_Group=' + strGroup;
      strURL = strURL + '&DTA_Select=' + strSelect;
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectGroup(objSelect) {
      document.main.INP_Group.value = objSelect.options[objSelect.selectedIndex].value;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_val_mes_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" name="sltGroup" onChange="selectGroup(this);">
                        <option value=""<%if objForm.Fields().Item("DTA_Group") = "" then%> selected<%end if%>>** select group **<%for i = 0 to clng(objSelection.ListCount("GROUP")) - 1%>
                        <option value="<%=objSelection.ListValue01("GROUP",i)%>"<%if objForm.Fields().Item("DTA_Group") = objSelection.ListValue01("GROUP",i) then%> selected<%end if%>><%=objSelection.ListValue02("GROUP",i)%><%next%>
                     </select>
                  </nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doEnquire();">&nbsp;Enquire&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=10 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Action&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Group&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Statistic&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Identifier&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Description&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Missing&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Valid&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;In Error&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Messages&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=9 cellpadding="0" cellspacing="1"><%if clng(objSelection.ListCount("LIST")) = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=9 nowrap><nobr>&nbsp;No Selection&nbsp</nobr></td></tr><%else%><%for i = clng(objSelection.ListLower("LIST")) to clng(objSelection.ListUpper("LIST"))%>
                        <tr>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:doDownload('<%=objSelection.ListValue01("LIST",i)%>','<%=objSelection.ListValue02("LIST",i)%>','<%=objSelection.ListValue03("LIST",i)%>');">Download</a></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue08("LIST",i)%></nobr></td>
                        </tr><%next%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="DTA_Group" value="<%=objForm.Fields().Item("DTA_Group")%>">
   <input type="hidden" name="INP_Group" value="<%=objForm.Fields().Item("DTA_Group")%>">
</form>
</body>
</html>