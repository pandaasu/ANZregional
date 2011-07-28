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
   function doSearch() {
      if (!processForm()) {return;}
      document.main.QRY_CODE.value = document.main.SLT_CODE.value;
      document.main.QRY_DESC.value = document.main.SLT_DESC.value;
      document.main.QRY_ACC_GRP.value = document.main.SLT_ACC_GRP.value;
      document.main.INP_CODE_TYPE.value = document.main.INP_CODE_TYPE.value;
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
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function processLog(strSequence) {
      var strParameters;
      strParameters = 'Child=ics_log_detail.asp';
      strParameters = strParameters + '&QRY_Sequence=' + strSequence;
      openWindow(strParameters);
   }
   function setSelect(objInput) {
      objInput.select();
   }
   function selectStatus(strValue) {
      document.main.INP_CODE_TYPE.value = strValue;
   }
// -->
</script>
<!--#include file="ics_std_child.inc"-->
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_timestamp.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_log_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');">

   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=4 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;MFG Code&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Atlas Code&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=3 cellpadding="0" cellspacing="1">

						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>kg</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>KG</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CS</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CS</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>PC</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>PC</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>OT</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>SB</nobr></td></tr>

                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
</body>
</html>