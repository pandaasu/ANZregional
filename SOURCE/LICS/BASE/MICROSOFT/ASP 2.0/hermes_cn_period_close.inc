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
   function doCreate() {
      if (!processForm()) {return;}
      if ('Yes' != prompt('Calculate Reversal(Yes/No)?','No')){ return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'CREATE';
      document.main.submit();
   }
   function doDownload() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_period_close_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
   function doSend() {
      if (!processForm()) {return;}
      if ('Yes' != prompt('Send Reversal to Atlas(Yes/No)?','No')){ return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SEND';
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('hermes_cn_period_close_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
       <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
       </tr>
       <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
				  <td align=center> <font color=#ffffff><b>Current&nbsp;Period:&nbsp;<%=objSelection.ListValue02("LIST",0)%></b></font></td>
			   </tr>
               <tr>
				  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCreate();">&nbsp;Calculate Reversals&nbsp;</a></nobr>
                  <nobr><font class="clsButtonD">&nbsp</font></nobr>
                  <nobr><a class="clsButton" href="javascript:doDownload();">&nbsp;Download&nbsp;</a></nobr>
                  <nobr><font class="clsButtonD">&nbsp</font></nobr>
                  <nobr><a class="clsButton" href="javascript:doSend();">&nbsp;Send Reversals to Atlas&nbsp;</a></nobr>               </tr>
            </table>
         </nobr></td>
       </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="DTA_TpaComCode" value="<%=objForm.Fields().Item("DTA_TpaComCode")%>">
   
</form>
</body>
</html>