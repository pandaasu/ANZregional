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
      if (document.main.INP_LoadIdentifier.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Load identifier must be entered';
      }
      if (document.main.INP_LoadDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Load description must be entered';
      }
      if (document.main.INP_LoadType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Load type must be selected';
      }
      if (document.main.INP_LoadDataType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Load data type must be selected';
      }
      if (document.main.INP_LoadDataVersion.value == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Load data version must be entered';
      }
      if (document.main.INP_LoadDataRange.value == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Load data range must be entered';
      }
      if (document.main.INP_LoadDataFile.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Load data file must be specified';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (!readTextFile(document.main.INP_LoadDataFile.value)) {
         return;
      }
      doActivityStart(eval('document.body'));
      document.main.DTA_LoadIdentifier.value = document.main.INP_LoadIdentifier.value;
      document.main.DTA_LoadDescription.value = document.main.INP_LoadDescription.value;
      document.main.DTA_LoadType.value = document.main.INP_LoadType.value
      document.main.DTA_LoadDataType.value = document.main.INP_LoadDataType.value;
      document.main.DTA_LoadDataVersion.value = document.main.INP_LoadDataVersion.value;
      document.main.DTA_LoadDataRange.value = document.main.INP_LoadDataRange.value;
      document.main.DTA_LoadDataFile.value = document.main.INP_LoadDataFile.value;
      document.main.DTA_LoadStream.value = document.main.INP_LoadStream.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'CREATE';
      document.main.submit();
   }
   function doDelete(strIdentifier) {
      if (!processForm()) {return;}
      if (confirm('Please confirm that you wish to delete '+strIdentifier+'\r\nPress OK to continue or press Cancel')) {
         doActivityStart(eval('document.body'));
         document.main.DTA_LoadIdentifier.value = strIdentifier;
         document.main.action = '<%=strBase%><%=strTarget%>';
         document.main.Mode.value = 'DELETE';
         document.main.submit();
      }
   }
   function doDownload(strIdentifier) {
      if (!processForm()) {return;}
      doActivityStart(eval('document.body'));
      doSpreadsheetDownload(eval('document.body'),'*DISP','dw_forecast_loading.select_load(\'' + strIdentifier + '\')');
   }
   function doUpload() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_Upload.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Forecast load spreadsheet must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (confirm('Please confirm that you wish to update the forecast load\r\nPress OK to continue or press Cancel')) {
         doActivityStart(eval('document.body'));
         doSpreadsheetUpload(eval('document.body'),document.main.INP_Upload.value,'dw_forecast_loading.update_period_load(\'<%=strUser%>\')');
      }
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectType(strType) {
      document.main.INP_LoadType.value = strType;
   }
   function selectDataType(strType) {
      document.main.INP_LoadDataType.value = strType;
      setFileText();
   }
   function setSelect(objInput) {
      objInput.select();
   }
   function readTextFile(strTextFile) {
      var objClient;
      var strReturn;
      var strStream;
      objClient = new ActiveXObject('ICS_XLCLIENT.Object');
      strReturn = objClient.GetTextStream(strTextFile);
      strStream = objClient.XMLString;
      objClient = null;
      if (strReturn != '*OK') {
         alert(strReturn); 
         return false;
      }
      document.main.INP_LoadStream.value = strStream;
      return true;
   }
   function setFileText() {
      var strFileText = '';
      if (document.main.INP_LoadDataType.value == '*QTY_ONLY') {
         strFileText = 'The data file must be a tab delimited file - Demand Group, Material Code, ' + document.main.INP_LoadDataRange.value + ' Quantity Values';
      }
      if (document.main.INP_LoadDataType.value == '*QTY_GSV') {
         strFileText = 'The data file must be a tab delimited file - Demand Group, Material Code, ' + document.main.INP_LoadDataRange.value + ' Quantity Values, ' + document.main.INP_LoadDataRange.value + ' GSV Values';
      }
      document.all.fntFileText.innerText = strFileText;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<!--#include file="ics_std_spreadsheet.inc"-->
<!--#include file="ics_std_activity.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="no" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('mch_fcst_maintenance_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');setFileText();<%if strMode = "CREATE" then%>showPanel();<%end if%>showError();">
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
                     <table class="clsTableHead" id="tabHead" align=left cols=9 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Action&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Identifier&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Description&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Status&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Data Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Data Version&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Update User/Time&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=8 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("LIST") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=12 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:doDownload('<%=objSelection.ListValue01("LIST",i)%>');">Download</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doDelete('<%=objSelection.ListValue01("LIST",i)%>');">Delete</a></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
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
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>Create Forecast Load</nobr></td>
      </tr>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_LoadIdentifier" size="64" maxlength="64" value="<%=objForm.Fields("DTA_LoadIdentifier").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_LoadDescription" size="128" maxlength="128" value="<%=objForm.Fields("DTA_LoadDescription").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Forecast Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltType" onChange="selectType(this);">
               <option value=""<%if objForm.Fields("DTA_LoadType").Value = "" then%> selected<%end if%>>** select **<%for i = 0 to objSelection.ListCount("LOAD") - 1%>
               <option value="<%=objSelection.ListValue01("LOAD",i)%>"<%if objForm.Fields("DTA_LoadType").Value = objSelection.ListValue01("LOAD",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("LOAD",i)%>) <%=objSelection.ListValue02("LOAD",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Forecast Data Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <input type="radio" name="sltDataType"<%if objForm.Fields("DTA_LoadDataType").Value = "*QTY_ONLY" then%> checked<%end if%> value="*QTY_ONLY" onClick="javascript:selectDataType('*QTY_ONLY');">Quantity Only&nbsp;
            <input type="radio" name="sltDataType"<%if objForm.Fields("DTA_LoadDataType").Value = "*QTY_GSV" then%> checked<%end if%> value="*QTY_GSV" onClick="javascript:selectDataType('*QTY_GSV');">Quantity and GSV&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Forecast Data Version:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_LoadDataVersion" size="6" maxlength="6" value="<%=objForm.Fields("DTA_LoadDataVersion").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);setFileText();">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Forecast Data Range:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_LoadDataRange" size="3" maxlength="3" value="<%=objForm.Fields("DTA_LoadDataRange").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);setFileText();">
         &nbsp;(number of periods)</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Forecast Data File:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="file" name="INP_LoadDataFile" size="64" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;<font id="fntFileText">The text file must be a tab delimited file - Demand Group, Material Code, Quantity Values</font>&nbsp;</nobr></td>
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
   <input type="hidden" name="DTA_LoadIdentifier" value="<%=objForm.Fields("DTA_LoadIdentifier").Value%>">
   <input type="hidden" name="DTA_LoadDescription" value="<%=objForm.Fields("DTA_LoadDescription").Value%>">
   <input type="hidden" name="DTA_LoadType" value="<%=objForm.Fields("DTA_LoadType").Value%>">
   <input type="hidden" name="DTA_LoadDataType" value="<%=objForm.Fields("DTA_LoadDataType").Value%>">
   <input type="hidden" name="DTA_LoadDataVersion" value="<%=objForm.Fields("DTA_LoadDataVersion").Value%>">
   <input type="hidden" name="DTA_LoadDataRange" value="<%=objForm.Fields("DTA_LoadDataRange").Value%>">
   <input type="hidden" name="DTA_LoadDataFile" value="<%=objForm.Fields("DTA_LoadDataFile").Value%>">
   <input type="hidden" name="DTA_LoadStream" value="">
   <input type="hidden" name="INP_LoadType" value="<%=objForm.Fields("DTA_LoadType").Value%>">
   <input type="hidden" name="INP_LoadDataType" value="<%=objForm.Fields("DTA_LoadDataType").Value%>">
   <input type="hidden" name="INP_LoadStream" value="">
</form>
</body>
</html>