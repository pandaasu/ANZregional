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
   function doClose() {
      if (!processForm()) {return;}
      if ('Yes' != prompt('Close the current period(Yes/No)?','No')){ return;}
		document.main.action = '<%=strBase%><%=strTarget%>';
		document.main.Mode.value = 'CLOSE';
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('hermes_com_info.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2  width=100% cellpadding="1" cellspacing="0">
      <tr>
		<td>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doClose();">&nbsp;Close Current Period&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
		<td>&nbsp;</td>
      </tr>
      <tr>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=7 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Company&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Open Period&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Accrual Account Code&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Tax Code&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Currency&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Plant Code&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=6 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("LIST") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=3 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>     
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
   <input type="hidden" name="DTA_TpaComCode" value="<%=objForm.Fields("DTA_TpaComCode").Value%>">
</form>
</body>
</html>