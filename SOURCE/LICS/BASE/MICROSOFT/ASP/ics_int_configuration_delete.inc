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
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
   }
   function doCancel() {
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SELECT';
      document.main.submit();
   }
   function doAccept() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'DELETE_ACCEPT';
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_int_configuration_delete_help.htm');parent.setHeading('<%=strHeading%> - Delete Interface');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_IntInterface").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Description:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_IntDescription").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Type:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_IntType").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_IntInterface" value="<%=objForm.Fields("DTA_IntInterface").Value%>">
   <input type="hidden" name="DTA_IntDescription" value="<%=objForm.Fields("DTA_IntDescription").Value%>">
   <input type="hidden" name="DTA_IntType" value="<%=objForm.Fields("DTA_IntType").Value%>">
   <input type="hidden" name="DTA_IntGroup" value="<%=objForm.Fields("DTA_IntGroup").Value%>">
   <input type="hidden" name="DTA_IntPriority" value="<%=objForm.Fields("DTA_IntPriority").Value%>">
   <input type="hidden" name="DTA_IntHdrHistory" value="<%=objForm.Fields("DTA_IntHdrHistory").Value%>">
   <input type="hidden" name="DTA_IntDtaHistory" value="<%=objForm.Fields("DTA_IntDtaHistory").Value%>">
   <input type="hidden" name="DTA_IntFilPath" value="<%=objForm.Fields("DTA_IntFilPath").Value%>">
   <input type="hidden" name="DTA_IntFilPrefix" value="<%=objForm.Fields("DTA_IntFilPrefix").Value%>">
   <input type="hidden" name="DTA_IntFilSequence" value="<%=objForm.Fields("DTA_IntFilSequence").Value%>">
   <input type="hidden" name="DTA_IntFilExtension" value="<%=objForm.Fields("DTA_IntFilExtension").Value%>">
   <input type="hidden" name="DTA_IntOprAlert" value="<%=objForm.Fields("DTA_IntOprAlert").Value%>">
   <input type="hidden" name="DTA_IntEmaGroup" value="<%=objForm.Fields("DTA_IntEmaGroup").Value%>">
   <input type="hidden" name="DTA_IntSearch" value="<%=objForm.Fields("DTA_IntSearch").Value%>">
   <input type="hidden" name="DTA_IntProcedure" value="<%=objForm.Fields("DTA_IntProcedure").Value%>">
   <input type="hidden" name="DTA_IntStatus" value="<%=objForm.Fields("DTA_IntStatus").Value%>">
   <input type="hidden" name="DTA_IntUsrInvocation" value="<%=objForm.Fields("DTA_IntUsrInvocation").Value%>">
   <input type="hidden" name="DTA_IntUsrValidation" value="<%=objForm.Fields("DTA_IntUsrValidation").Value%>">
   <input type="hidden" name="DTA_IntUsrMessage" value="<%=objForm.Fields("DTA_IntUsrMessage").Value%>">
</form>
</body>
</html>