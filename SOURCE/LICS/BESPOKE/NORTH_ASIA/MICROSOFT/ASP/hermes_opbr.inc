<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_FilNameOP.focus();<%if strError <> "" then%>
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
   
   function doAcceptOP() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_FilNameOP.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'OP file must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
            
      loadFile(document.main.INP_FilNameOP.value);
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'ACCEPTOP';
      document.main.submit();
   }
   function regInput(obj, reg, inputStr) 
    { 
    var docSel = document.selection.createRange() 
    if (docSel.parentElement().tagName != "INPUT") return false 
    oSel = docSel.duplicate() 
    oSel.text = "" 
    var srcRange = obj.createTextRange() 
    oSel.setEndPoint("StartToStart", srcRange) 
    var str = oSel.text + inputStr + srcRange.text.substr(oSel.text.length) 
    return reg.test(str) 
    } 
   function doDownloadOP() {
       if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.DTA_TpaOPSdt.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'OP Start Period must be entered';
      } 
      if (document.main.DTA_TpaOPEnd.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'OP End Period must be entered';
      }
      if (checkIsInteger(document.main.DTA_TpaOPEnd.value)) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'OP End Period must be number';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strURL = '<%=strBase%>hermes_opbr_downloadOP.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_TpaOPSdt=' + document.main.DTA_TpaOPSdt.value;
      strURL = strURL + '&DTA_TpaOPEnd=' + document.main.DTA_TpaOPEnd.value;
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
function doDownloadBR() {
       if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.DTA_TpaBRSdt.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'BR Start Period must be entered';
      } 
      if (document.main.DTA_TpaBREnd.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'BR End Period must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strURL = '<%=strBase%>hermes_opbr_downloadBR.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_TpaBRSdt=' + document.main.DTA_TpaBRSdt.value;
      strURL = strURL + '&DTA_TpaBREnd=' + document.main.DTA_TpaBREnd.value;
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
   function doAcceptBR() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_FilNameBR.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'BR file must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
            
      loadFile(document.main.INP_FilNameBR.value);
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'ACCEPTBR';
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

<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('hermes_opbr_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 width=100%  cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;OP File (Tab Delimited):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="file" name="INP_FilNameOP" size="128" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAcceptOP();">&nbsp;Accept OP&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
		<td id="hidLines" colspan=2 style="display:none"></td>
      </tr>
<tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;OP Download Start Period:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input maxlength=6 class="clsInputNN" type ="text" name="DTA_TpaOPSdt" size="5" onkeypress="return regInput(this,/^[0-9]*$/,String.fromCharCode(event.keyCode))" onpaste="return regInput(this,/^[0-9]*$/,window.clipboardData.getData('Text'))" ondrop="return regInput(this,/^[0-9]*$/,event.dataTransfer.getData('Text'))">
         </nobr></td>
</tr>
<tr>        
 <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;OP Download End Period:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input maxlength=6 class="clsInputNN" type ="text" name="DTA_TpaOPEnd" size="5" onkeypress="return regInput(this,/^[0-9]*$/,String.fromCharCode(event.keyCode))" onpaste="return regInput(this,/^[0-9]*$/,window.clipboardData.getData('Text'))" ondrop="return regInput(this,/^[0-9]*$/,event.dataTransfer.getData('Text'))">
         </nobr></td>
      </tr>
<tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>           
         <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownloadOP();">&nbsp;Download OP&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>

      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>

      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
<tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;BR File (Tab Delimited):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="file" name="INP_FilNameBR" size="128" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAcceptBR();">&nbsp;Accept BR&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;BR Download Start Period:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input maxlength=6 class="clsInputNN" type ="text" name="DTA_TpaBRSdt" size="5" onkeypress="return regInput(this,/^[0-9]*$/,String.fromCharCode(event.keyCode))" onpaste="return regInput(this,/^[0-9]*$/,window.clipboardData.getData('Text'))" ondrop="return regInput(this,/^[0-9]*$/,event.dataTransfer.getData('Text'))">
         </nobr></td>
</tr>
<tr>        
 <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;BR Download End Period:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input maxlength=6 class="clsInputNN" type ="text" name="DTA_TpaBREnd" size="5" onkeypress="return regInput(this,/^[0-9]*$/,String.fromCharCode(event.keyCode))" onpaste="return regInput(this,/^[0-9]*$/,window.clipboardData.getData('Text'))" ondrop="return regInput(this,/^[0-9]*$/,event.dataTransfer.getData('Text'))">
         </nobr></td>
      </tr>
<tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>           
         <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownloadBR();">&nbsp;Download BR&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_TpaComCode" value="<%=objForm.Fields("DTA_TpaComCode").Value%>">
   <input type="hidden" name="LIN_Count" value="">
</form>
</body>
</html>