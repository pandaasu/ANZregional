<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_FilName.focus();<%if strError <> "" then%>
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
   function doAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_FilName.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Budget import file must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
           
      loadFile(document.main.INP_FilName.value);
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
<!--#include file="ics_std_file.inc"-->
<!--#include file="ics_std_scrollable.inc"-->

<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('hermes_budget_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100%  cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;TP Actual File (Tab Delimited):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="file" name="INP_FilName" size="128" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
                  <%if objSelection.ListCount("LIST") > 0 then%>
                  <%end if%>
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
                     <table class="clsTableHead" id="tabHead" align=left cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Company&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Period&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Customer&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Material&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;TP Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;TP Actuals&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Actual Date&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cellpadding="0" cellspacing="1"><%if objSelection.ListCount("LIST") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=3 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=right colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                        </tr><%next%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr>
					<td id="hidLines" colspan=2 style="display:none"></td>
				</tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_TpaComCode" value="<%=objForm.Fields("DTA_TpaComCode").Value%>">
   <input type="hidden" name="DTA_TpaCurrPrd" value="<%=objSelection.ListValue02("LIST",1)%>">
   <input type="hidden" name="LIN_Count" value="">
</form>
</body>
</html>