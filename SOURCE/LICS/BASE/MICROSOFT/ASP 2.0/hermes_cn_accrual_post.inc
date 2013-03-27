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
      if ('Yes' != prompt('Calculate accruals(Yes/No)?','No')){ return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'CREATE';
      document.main.submit();
   }
   function doDownload() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_accrual_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_FILENUM=0 ';
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
   function doDownload1() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_accrual_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_FILENUM=1 ';
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
    function doDownload2() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_accrual_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_FILENUM=2 ';
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
    function doDownload3() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_accrual_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_FILENUM=3 ';
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
    function doDownload4() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_accrual_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_FILENUM=4 ';
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
    function doDownload5() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_accrual_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_FILENUM=5 ';
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
    function doDownload6() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_accrual_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_FILENUM=6 ';
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
    function doDownload7() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_accrual_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_FILENUM=7 ';
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
    function doDownload8() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_accrual_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_FILENUM=8 ';
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
    function doDownload9() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_accrual_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_FILENUM=9 ';
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
   function doSend() {
      if (!processForm()) {return;}
      if ('Yes' != prompt('Send Accruals to Atlas(Yes/No)?','No')){ return;}
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
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('hermes_cn_accrual_post_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
       <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
       </tr>
       <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=2 nowrap><nobr><a class="clsButton" href="javascript:doCreate();">&nbsp;Calculate Accrual&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
                  <td align=center colspan=2 nowrap><nobr><a class="clsButton" href="javascript:doSend();">&nbsp;Send Accrual to Atlas&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
               </tr>
            </table>
         </nobr></td>
       </tr>
   </table>
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
       <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
       </tr>
       <tr>
             <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload();">&nbsp;Download File1&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload1();">&nbsp;Download File2&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload2();">&nbsp;Download File3&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
               </tr>
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload3();">&nbsp;Download File4&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload4();">&nbsp;Download File5&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload5();">&nbsp;Download File6&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
               </tr>
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload6();">&nbsp;Download File7&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload7();">&nbsp;Download File8&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload8();">&nbsp;Download File9&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
               </tr>
            </table>
         </nobr></td>
         
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="DTA_TpaComCode" value="<%=objForm.Fields().Item("DTA_TpaComCode")%>">
   <input type="hidden" name="DTA_FILENUM" value="<%=objForm.Fields().Item("DTA_FILENUM")%>">
   
</form>
</body>
</html>