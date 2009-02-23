<html>
<script language="javascript">
<!--
   function showError() {
      document.main.sltInterface.focus();<%if strError <> "" then%>
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
   function doSubmit() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_Interface.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface must be selected';
      }
      if (document.main.INP_DataFile.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Data file must be specified';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (!readTextFile(document.main.INP_DataFile.value)) {
         return;
      }
      if (confirm('Please confirm that you wish to continue\r\nPress OK to continue\r\nOr press Cancel')) {
         doActivityStart(eval('document.body'));
         document.main.SLT_Interface.value = document.main.INP_Interface.value;
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
   function selectInterface(objSelect) {
      document.main.INP_Interface.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function setSelect(objInput) {
      objInput.select();
   }
   function readTextFile(strTextFile) {
      var objHidden;
      var intPart = 0;
      var aryStream = loadStreamXML(strTextFile,'*NO').match(RegExp('.{1,2000}','g'));
      for (var i=0;i<aryStream.length;i++) {
         intPart++;
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','StreamPart'+intPart);
         objHidden.setAttribute('value',aryStream[i]);
         document.forms['main'].appendChild(objHidden);
      }
      objHidden = document.createElement('input');
      objHidden.setAttribute('type','hidden');
      objHidden.setAttribute('name','StreamCount');
      objHidden.setAttribute('value',intPart);
      document.forms['main'].appendChild(objHidden);
      return true;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_stream_xml.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_int_loader_help.htm');parent.setHeading('<%=strHeading%> - Submit');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltInterface" onChange="selectInterface(this);">
               <option value="" selected>** select interface **<%for i = 0 to objSelection.ListCount("INTERFACE") - 1%>
               <option value="<%=objSelection.ListValue01("INTERFACE",i)%>">(<%=objSelection.ListValue01("INTERFACE",i)%>)&nbsp;<%=objSelection.ListValue02("INTERFACE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Data File:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="file" name="INP_DataFile" size="64" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSubmit();">&nbsp;Submit&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr><%if strConfirm <> "" then%>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;<%=strConfirm%>&nbsp;</nobr></td>
      </tr><%end if%>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="SLT_Interface" value="<%=objForm.Fields("SLT_Interface").Value%>">
   <input type="hidden" name="INP_Interface" value="<%=objForm.Fields("SLT_Interface").Value%>">
</form>
</body>
</html>