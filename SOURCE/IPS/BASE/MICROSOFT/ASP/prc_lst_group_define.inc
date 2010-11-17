<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_GroDescription.focus();<%if strReturn <> "*OK" then%>
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
   function checkChange() {
      bolReturn = confirm('Please confirm the cancel\r\npress OK continue (any changes will be lost)\r\npress Cancel to return to the function');
      return bolReturn;
   }
   function doCancel() {
      if (checkChange() == false) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SELECT';
      document.main.submit();
   }
   function doAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      var strDetail = '';
      if (document.main.INP_ReportGrpName.value == '') {
         if (strMessage != null) {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Report group name must be entered';
      }
      if (document.main.INP_Status.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Status must be selected';
      }
      strDetail = checkItems();
      if (strDetail != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strDetail;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_ReportGrpName.value = document.main.INP_ReportGrpName.value;
      document.main.DTA_Status.value = document.main.INP_Status.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'DEFINE_ACCEPT';
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
   function selectStatus(strValue) {
      document.main.INP_Status.value = strValue;
   }

   /////////////////////////////
   // Group definition script //
   /////////////////////////////
   var cstrReportTerm = '';
   function loadReportTerms() {<%if objSelection.ListCount("GROUP_TERM") <> 0 then%><%for i = objSelection.ListLower("GROUP_TERM") to objSelection.ListUpper("GROUP_TERM")%>
      cstrReportTerm = <%if i > 0 then%>cstrReportTerm+<%end if%>'<%=replace(objSelection.ListValue01("GROUP_TERM",i), "'", "\'", 1, -1, 1)%>'<%if i < objSelection.ListCount("GROUP_TERM")-1 then%>+'\n'<%end if%>;<%next%><%end if%>
      var objTxtRepGrpTerm = document.getElementById('txtRepGrpTerm');
      objTxtRepGrpTerm.value = cstrReportTerm;
   }
   function checkItems() {
      var strReturn = '';
      var objHidden = null;
      var objTxtRepGrpTerm = document.getElementById('txtRepGrpTerm');
      var aryTerms = objTxtRepGrpTerm.value.split('\n');
      for (var i=0;i<aryTerms.length;i++) {
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_RepTerText'+(i+1));
         objHidden.setAttribute('value',aryTerms[i]);
         document.forms['main'].appendChild(objHidden);
      }
      document.getElementById('DET_RepTerCount').value = aryTerms.length;
      return strReturn;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('prc_lst_group_define_help.htm');parent.setHeading('<%=strHeading%> - Define Report Group');parent.showContent();loadReportTerms();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Report Group Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_ReportGrpName" size="128" maxlength="200" value="<%=replace(objForm.Fields("DTA_ReportGrpName").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Available:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltStatus"<%if objForm.Fields("DTA_Status").Value = "" or objForm.Fields("DTA_Status").Value = "I" then%> checked<%end if%> value="I" onClick="javascript:selectStatus('I');">No&nbsp;
            <input type="radio" name="sltStatus"<%if objForm.Fields("DTA_Status").Value = "V" then%> checked<%end if%> value="V" onClick="javascript:selectStatus('V');">Yes&nbsp;
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table id="tabTerm" class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsTabB" align=center colspan=2 nowrap><nobr>&nbsp;Terms and Conditions&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
                     <textarea class="clsInputNN" id="txtRepGrpTerm" name="txtRepGrpTerm" style="width:700px;" rows="20" wrap="off"></textarea>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
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
   <input type="hidden" name="DTA_ReportGrpId" value="<%=objForm.Fields("DTA_ReportGrpId").Value%>">
   <input type="hidden" name="DTA_ReportGrpName" value="<%=replace(objForm.Fields("DTA_ReportGrpName").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_Status" value="<%=objForm.Fields("DTA_Status").Value%>">
   <input type="hidden" name="INP_Status" value="<%=objForm.Fields("DTA_Status").Value%>">
   <input type="hidden" name="DET_RepTerCount" value="">
</form>
</body>
</html>