<html>
<script language="javascript">
<!--
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
      if (document.main.INP_Invoice.value == '' && document.main.INP_Delivery.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Either invoice or delivery number must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.SLT_Invoice.value = document.main.INP_Invoice.value;
      document.main.SLT_Delivery.value = document.main.INP_Delivery.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
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
   <meta http-equiv="content-type" content="text/html;">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_con_note_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=4 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=4 nowrap><nobr>
            <table class="clsBody02" align=center cols=4 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Select Invoice:&nbsp;</nobr></td>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
                     <input class="clsInputNN" type="text" name="INP_Invoice" size="10" maxlength="10" value="<%=objForm.Fields("SLT_Invoice").Value%>" onFocus="setSelect(this);">
                  </nobr></td>
                  <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;&nbsp;or&nbsp;Delivery:&nbsp;</nobr></td>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
                  <input class="clsInputNN" type="text" name="INP_Delivery" size="10" maxlength="10" value="<%=objForm.Fields("SLT_Delivery").Value%>" onFocus="setSelect(this);">
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=4 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=4 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=4 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=4 nowrap><nobr>&nbsp;<%=strReturn%>&nbsp;</td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="SLT_Invoice" value="<%=objForm.Fields("SLT_Invoice").Value%>">
   <input type="hidden" name="SLT_Delivery" value="<%=objForm.Fields("SLT_Delivery").Value%>">
</form>
</body>
</html>