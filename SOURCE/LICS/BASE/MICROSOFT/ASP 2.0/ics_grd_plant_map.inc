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
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;MFG Plant Code&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Atlas Plant Code&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Atlas Description&nbsp;</nobr></td>
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
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>MSFH</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN01</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>HUA Snackfood plant</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>MPFH</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN02</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>HUA Petfood plant</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>EPEK</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN03</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>DHL Beijing</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>ESHA</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN04</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>DHL Shanghai</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>PCSY</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN05</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>Pacific W/H</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>AHRU</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN06</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>ANDA W/H</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>ECAN</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN07</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>DHL Guangzhou</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>ECTU</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN08</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>DHL Chengdu</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>ESHE</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN09</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>DHL Shenyang</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>EWUH</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN10</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>DHL Wuhan</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>MGIT</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN11</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN logic plant</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>XDFG</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN15</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>HUA Snack Crossdock Plant</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>MIYU</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN16</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>Miyun Bonded W/H</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>MSFJ</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN17</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>JXG Snackfood Plant</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>N/A</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN12</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>HUA Pet Crossdock Plant</nobr></td></tr>
						<tr><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>N/A</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>CN18</nobr></td><td class="clsLabelFN" align=left colspan=1 nowrap><nobr>JXG W/H</nobr></td></tr>
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