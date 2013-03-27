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
      if ('Yes' != prompt('Calculate Claim(Yes/No)?','No')){ return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'CREATE';
      document.main.submit();
   }
   function doDownload() {
      if (!processForm()) {return;}
      var strURL = '<%=strBase%>hermes_cn_claim_post_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_UserSec=' + document.main.DTA_UserSec.value;
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
   function doSend() {
      if (!processForm()) {return;}
      if ('Yes' != prompt('Send Claim to Atlas(Yes/No)?','No')){ return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SEND';
      document.main.submit();
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      if (document.main.SLS_UserSec.value == '')
      {
         alert('Please select a valid user');      	 
      	 return false; 
      }	
      document.main.DTA_UserSec.value = document.main.SLS_UserSec.value;
      return true;
   }
   function setSelect(objInput) {
      objInput.select();
   }
   function selectUser(objSelect) {
      document.main.SLS_UserSec.value = objSelect.options[objSelect.selectedIndex].value;
   }   
   
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('hermes_cn_claim_post_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;User:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN"  name="sltUser" onChange="selectUser(this);">
               <option value=""<%if objForm.Fields().Item("DTA_UserSec") = "" then%> selected<%end if%>>
               <option value="BJ"<%if objForm.Fields().Item("DTA_UserSec") = "BJ" then%> selected<%end if%>>BJ
               <option value="SH"<%if objForm.Fields().Item("DTA_UserSec") = "SH" then%> selected<%end if%>>SH
               <option value="GZ"<%if objForm.Fields().Item("DTA_UserSec") = "GZ" then%> selected<%end if%>>GZ
               <option value="CD"<%if objForm.Fields().Item("DTA_UserSec") = "CD" then%> selected<%end if%>>CD
               <option value="WH"<%if objForm.Fields().Item("DTA_UserSec") = "WH" then%> selected<%end if%>>WH
               <option value="SY"<%if objForm.Fields().Item("DTA_UserSec") = "SY" then%> selected<%end if%>>SY
            </select>
         </nobr></td>
       </tr>
       <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
       </tr>
       <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCreate();">&nbsp;Calculate Claim&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload();">&nbsp;Download&nbsp;</a></nobr></td>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSend();">&nbsp;Send Claim to Atlas&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
       </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="DTA_TpaComCode" value="<%=objForm.Fields().Item("DTA_TpaComCode")%>">
   <input type="hidden" name="DTA_UserSec" value="<%=objForm.Fields().Item("DTA_UserSec")%>">
   <input type="hidden" name="SLS_UserSec" value="<%=objForm.Fields().Item("DTA_UserSec")%>">
   
</form>
</body>
</html>