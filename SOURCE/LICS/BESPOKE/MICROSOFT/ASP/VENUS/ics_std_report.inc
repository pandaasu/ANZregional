<html>
<script language="javascript">
<!--
   function setActions() {
      var strText = '<nobr>&nbsp;<%=strHeading%> - SAVE OUTPUT -';
      strText = strText + '&nbsp;<a class="clsButton" href="javascript:doAction(\'Cancel\');">Cancel</a>&nbsp;';
      strText = strText + '|&nbsp;<a class="clsButton" href="javascript:doAction(\'Save\');">Save</a>&nbsp;</nobr>';
      parent.setActions(strText);
   }
   function doAction(strAction) {
      if (strAction == 'Cancel') {
         cancelForm();
      }
      if (strAction == 'Save') {
         processForm();
      }
   }
   function cancelForm() {
      parent.setActions('<nobr>&nbsp;<%=strHeading%> - SAVE OUTPUT - Processing request - please wait&nbsp;</nobr>');
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'PROMPT';
      document.main.submit();
   }
   function processForm() {
      parent.setActions('<nobr>&nbsp;<%=strHeading%> - SAVE OUTPUT - Processing request - please wait&nbsp;</nobr>');
      window.setTimeout('generateReport();',10);
   }
   function generateReport() {
      var objXLClient;
      var strReturn;
      objXLClient = new ActiveXObject('XL_CLIENT.Object');
      strReturn = objXLClient.ExecuteXMLStream('<%=replace(strXML, "'", "\'", 1, -1, 1)%>');
      objXLClient = null;
      if (strReturn == '*OK') {
         document.main.action = '<%=strBase%><%=strTarget%>';
         document.main.Mode.value = 'PROMPT';
         document.main.submit();
      } else {
         document.location.href = '<%=strBase%>mfjpln_fatal.asp?type=02&error=' + strReturn;
      }
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html;charset=Shift-JIS">
   <link rel="stylesheet" type="text/css" href="mfjpln_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');setActions();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=center height=100% cols=1>
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=1 nowrap>&nbsp;Report Output Generated<br>&nbsp;<br>Press Save to save the output&nbsp;</td>
      </tr>
   </table>
   <%=strSaved%>
</form>
</body>
</html>