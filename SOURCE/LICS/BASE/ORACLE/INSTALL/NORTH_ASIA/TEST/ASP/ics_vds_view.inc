<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_Query.focus();<%if strError <> "" then%>
      alert('<%=strError%>');<%end if%>
      return;
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
   function doGenerate() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_Query.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Query must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (confirm('Please confirm that you wish to continue\r\nPress OK to continue\r\nOr press Cancel')) {
         document.main.SLT_Query.value = document.main.INP_Query.value;
         document.main.action = '<%=strBase%><%=strTarget%>';
         document.main.Mode.value = 'SUBMIT';
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
   function selectQuery(objSelect) {
      document.main.INP_Query.value = objSelect.options[objSelect.selectedIndex].value;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_vds_view_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltQuery" onChange="selectQuery(this);">
               <option value="" selected>** select query **<%for i = 0 to objSelection.ListCount("QUERY") - 1%>
               <option value="<%=objSelection.ListValue01("QUERY",i)%>"><%=objSelection.ListValue01("QUERY",i)%> - <%=objSelection.ListValue02("QUERY",i)%><%next%>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doGenerate();">&nbsp;Generate&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="SLT_Query" value="">
   <input type="hidden" name="INP_Query" value="">
</form>
</body>
</html>