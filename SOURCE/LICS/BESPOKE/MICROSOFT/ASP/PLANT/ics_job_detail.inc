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
   function processGroup(strExecution) {
      var strParameters;
      strParameters = 'Child=ics_int_monitor.asp';
      strParameters = strParameters + '&QRY_Execution=' + strExecution;
      openWindow(strParameters);
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_child.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_job_detail_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue01("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue02("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue03("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Execution:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%if mid(objSelection.ListValue04("DETAIL",0), 1, 9) = "Interface" then%><a class="clsSelect" href="javascript:processGroup('<%=objSelection.ListValue01("DETAIL",0)%>');"><%=objSelection.ListValue04("DETAIL",0)%></a><%else%><%=objSelection.ListValue04("DETAIL",0)%><%end if%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job User:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue05("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Start Time:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue06("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job End Time:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue07("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Status:&nbsp;</nobr></td>
         <td class="<%=aryJobClass(objSelection.ListValue08("DETAIL",0))%>" align=left colspan=1 nowrap><nobr>&nbsp;<%=aryJobStatus(objSelection.ListValue08("DETAIL",0))%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Message:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<%=objSelection.ListValue09("DETAIL",0)%>&nbsp;</nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
</form>
</body>
</html>