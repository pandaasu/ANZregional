<html>
<script language="javascript">
<!--
   function showError() {<%if strError <> "" then%>
      alert('<%=strError%>');<%else%>return;<%end if%>
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
   function showList() {
      var objList = eval('document.all("tabList")');
      var objPanel = eval('document.all("tabPanel")');
      objPanel.style.display = 'none';
      objPanel.style.visibility = 'hidden';
      objList.style.display = 'block';
      objList.style.visibility = 'visible';
   }
   function showPanel() {
      var objList = eval('document.all("tabList")');
      var objPanel = eval('document.all("tabPanel")');
      objList.style.display = 'none';
      objList.style.visibility = 'hidden';
      objPanel.style.display = 'block';
      objPanel.style.visibility = 'visible';
   }
   function doRefresh() {
      if (!processForm()) {return;}
      doActivityStart(eval('document.body'));
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SELECT';
      document.main.submit();
   }
   function doCreate() {
      if (!processForm()) {return;}
      var strMessage = '';
      var strDetail = '';
      if (document.main.INP_ExtractIdentifier.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Extract identifier must be entered';
      }
      if (document.main.INP_ExtractDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Extract description must be entered';
      }
      if (document.main.INP_ExtractType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Extract type must be selected';
      }
      if (document.main.INP_ExtractVersion.value == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Extract version must be entered';
      }
      if (document.main.INP_LoadIdentifier.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Extract loads must be selected';
      }
      if (document.main.INP_ExtractType.value != '') {
         strDetail = checkExtractLinks(document.main.INP_ExtractType.value);
      }
      if (strDetail != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strDetail;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(eval('document.body'));
      document.main.DTA_ExtractIdentifier.value = document.main.INP_ExtractIdentifier.value;
      document.main.DTA_ExtractDescription.value = document.main.INP_ExtractDescription.value;
      document.main.DTA_ExtractType.value = document.main.INP_ExtractType.value
      document.main.DTA_ExtractVersion.value = document.main.INP_ExtractVersion.value;
      document.main.DTA_LoadIdentifier.value = document.main.INP_LoadIdentifier.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'CREATE';
      document.main.submit();
   }
   function doDelete(strIdentifier) {
      if (!processForm()) {return;}
      if (confirm('Please confirm that you wish to delete '+strIdentifier+'\r\nPress OK to continue or press Cancel')) {
         doActivityStart(eval('document.body'));
         document.main.DTA_ExtractIdentifier.value = strIdentifier;
         document.main.action = '<%=strBase%><%=strTarget%>';
         document.main.Mode.value = 'DELETE';
         document.main.submit();
      }
   }
   function doReport(strIdentifier) {
      if (!processForm()) {return;}
      doActivityStart(eval('document.body'));
      doSpreadsheetDownload(eval('document.body'),'*DISP','dw_fcst_xxxxx.report_extract(\'' + strIdentifier + '\')');
   }
   function doExport(strIdentifier) {
      if (!processForm()) {return;}
      doActivityStart(eval('document.body'));
      doTextDownload(eval('document.body'),'*DISP','dw_fcst_xxxxx.report_extract(\'' + strIdentifier + '\')');
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectType(strType) {
      document.main.INP_ExtractType.value = strType;
      loadExtractLinks();
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<!--#include file="ics_std_spreadsheet.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_mch_fcst_extract_links.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="no" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('mch_fcst_extract_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');<%if strMode = "CREATE" then%>showPanel();<%end if%>showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table id="tabList" style="display:block;visibility:visible" class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:showPanel();">&nbsp;Create&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=7 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Action&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Identifier&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Description&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Version&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Create User/Time&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=6 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("LIST") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=12 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:doReport('<%=objSelection.ListValue01("LIST",i)%>');">Report</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doExport('<%=objSelection.ListValue01("LIST",i)%>');">Export</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doDelete('<%=objSelection.ListValue01("LIST",i)%>');">Delete</a></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                        </tr><%next%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="tabPanel" style="display:none;visibility:hidden" class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>Create Forecast Extract</nobr></td>
      </tr>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_ExtractIdentifier" size="64" maxlength="64" value="<%=objForm.Fields("DTA_ExtractIdentifier").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_ExtractDescription" size="128" maxlength="128" value="<%=objForm.Fields("DTA_ExtractDescription").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Extract Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltType" onChange="selectType(this);">
               <option value=""<%if objForm.Fields("DTA_ExtractType").Value = "" then%> selected<%end if%>>** select extract type **<%for i = 0 to objSelection.ListCount("EXTRACT") - 1%>
               <option value="<%=objSelection.ListValue01("EXTRACT",i)%>"<%if objForm.Fields("DTA_ExtractType").Value = objSelection.ListValue01("EXTRACT",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("EXTRACT",i)%>) <%=objSelection.ListValue02("EXTRACT",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Extract Version:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_ExtractVersion" size="6" maxlength="6" value="<%=objForm.Fields("DTA_ExtractVersion").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);setFileText();" onChange="loadExtractLinks();">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Extract Loads&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
            <table align=center border=0 cellpadding=0 cellspacing=2 cols=2>
               <tr>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Loads&nbsp;</nobr></td>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Selected&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="sltLink" name="sltExtractLink" style="width:400px" multiple size=10></select>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="sltDetail" name="sltExtractDetail" style="width:400px" multiple size=10></select>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:selectExtractLinks();">&nbsp;Select >>&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:removeExtractLinks();">&nbsp;<< Remove&nbsp;</a></nobr></td>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:showList();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCreate();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_ExtractIdentifier" value="<%=objForm.Fields("DTA_ExtractIdentifier").Value%>">
   <input type="hidden" name="DTA_ExtractDescription" value="<%=objForm.Fields("DTA_ExtractDescription").Value%>">
   <input type="hidden" name="DTA_ExtractType" value="<%=objForm.Fields("DTA_ExtractType").Value%>">
   <input type="hidden" name="DTA_ExtractVersion" value="<%=objForm.Fields("DTA_ExtractVersion").Value%>">
   <input type="hidden" name="INP_ExtractType" value="<%=objForm.Fields("DTA_ExtractType").Value%>">
   <input type="hidden" name="DET_ExtractLinkCount" value="">
</form>
</body>
</html>