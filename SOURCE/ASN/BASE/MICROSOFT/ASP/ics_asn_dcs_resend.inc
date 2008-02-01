<html>
<script language="javascript">
<!--
   function showError() {<%if strReturn <> "*OK" then%>
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
   function doSearch() {
      if (!processForm()) {return;}
      document.main.QRY_SendNumber.value = document.main.SLT_SendNumber.value;
      document.main.QRY_MarsCode.value = document.main.SLT_MarsCode.value;
      document.main.QRY_PickNumber.value = document.main.SLT_PickNumber.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SEARCH';
      document.main.submit();
   }
   function doPrevious() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'PREVIOUS';
      document.main.submit();
   }
   function doNext() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'NEXT';
      document.main.submit();
   }
   function doResend(strSendNumber) {
      if (!processForm()) {return;}
      if (confirm('Please confirm that you wish to continue\r\nPress OK to continue\r\nOr press Cancel')) {
         document.main.action = '<%=strBase%><%=strTarget%>';
         document.main.Mode.value = 'UPDATE';
         document.main.DTA_SendNumber.value = strSendNumber;
         document.main.submit();
      }
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectMarsCode(objSelect) {
      document.main.SLT_MarsCode.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_child.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_asn_dcs_resend_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Send Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_SendNumber" size="8" maxlength="8" value="<%=objForm.Fields("QRY_SendNumber").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Mars Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltMarsCode" onChange="selectMarsCode(this);">
               <option value=""<%if objForm.Fields("QRY_MarsCode").Value = "" then%> selected<%end if%>>All
               <option value="FOOD"<%if objForm.Fields("QRY_MarsCode").Value = "FOOD" then%> selected<%end if%>>MFANZ Food
               <option value="PETCARE"<%if objForm.Fields("QRY_MarsCode").Value = "PETCARE" then%> selected<%end if%>>MFANZ Petcare
               <option value="SNACKFOOD"<%if objForm.Fields("QRY_MarsCode").Value = "SNACKFOOD" then%> selected<%end if%>>MFANZ Snackfood
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pick Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_PickNumber" size="10" maxlength="10" value="<%=objForm.Fields("QRY_PickNumber").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelUL" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSearch();">Search</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr><%if bolStrList = true then%>
                  <td align=left colspan=1 nowrap><nobr><font class="clsButtonD"><&nbsp;Prev&nbsp</font></nobr></td><%else%>
                  <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPrevious();"><&nbsp;Prev&nbsp</a></nobr></td><%end if%>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td><%if bolEndList = true then%>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbspNext&nbsp></font></nobr></td><%else%>
                  <td align=right colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doNext();">&nbspNext&nbsp></a></nobr></td><%end if%>
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
                     <table class="clsTableHead" id="tabHead" align=left cols=9 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Action&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Send Number&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Mars Code&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Pick Number&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Pick Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Created&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Updated&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Sent Count&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=8 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("LIST") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=8 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%if objForm.Fields("Mode").Value <> "PREVIOUS" then%><%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:doResend('<%=objSelection.ListValue01("LIST",i)%>');">Resend</a></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                        </tr><%next%><%else%><%for i = objSelection.ListUpper("LIST") to objSelection.ListLower("LIST") step -1%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:doResend('<%=objSelection.ListValue01("LIST",i)%>');">Resend</a></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                        </tr><%next%><%end if%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="STR_SendNumber" value="<%if objForm.Fields("Mode").Value <> "PREVIOUS" then%><%=objSelection.ListValue01("LIST",objSelection.ListLower("LIST"))%><%else%><%=objSelection.ListValue01("LIST",objSelection.ListUpper("LIST"))%><%end if%>">
   <input type="hidden" name="END_SendNumber" value="<%if objForm.Fields("Mode").Value <> "PREVIOUS" then%><%=objSelection.ListValue01("LIST",objSelection.ListUpper("LIST"))%><%else%><%=objSelection.ListValue01("LIST",objSelection.ListLower("LIST"))%><%end if%>">
   <input type="hidden" name="QRY_SendNumber" value="<%=objForm.Fields("QRY_SendNumber").Value%>">
   <input type="hidden" name="QRY_MarsCode" value="<%=objForm.Fields("QRY_MarsCode").Value%>">
   <input type="hidden" name="QRY_PickNumber" value="<%=objForm.Fields("QRY_PickNumber").Value%>">
   <input type="hidden" name="SLT_MarsCode" value="<%=objForm.Fields("QRY_MarsCode").Value%>">
   <input type="hidden" name="DTA_SendNumber" value="">
</form>
</body>
</html>