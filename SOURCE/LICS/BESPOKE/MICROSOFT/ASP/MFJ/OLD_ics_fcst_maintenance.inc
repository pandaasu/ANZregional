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
      if (document.main.INP_ForIdentifier.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Load identifier must be entered';
      }
      if (document.main.INP_ForDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Load description must be entered';
      }
      if (document.main.INP_ForReplace.value != '*SPLIT' &&
          document.main.INP_ForReplace.value != '*MATERIAL') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Forecast replacement must be selected';
      }
      if (document.main.INP_ForType.value != 'PRDBR' &&
          document.main.INP_ForType.value != 'PRDOP1' &&
          document.main.INP_ForType.value != 'PRDOP2') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Forecast type must be selected';
      }
      if (document.main.INP_ForType.value == 'PRDOP1' ||
          document.main.INP_ForType.value == 'PRDOP2') {
         if (document.main.INP_ForSource.value != '*TXQ' &&
             document.main.INP_ForSource.value != '*TXV') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Forecast source must be text file for Operating plan';
         }
      }
      if (document.main.INP_ForSplit.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Forecast split must be selected';
      }
      if (document.main.INP_ForSource.value != '*PLN' &&
          document.main.INP_ForSource.value != '*TXQ' &&
          document.main.INP_ForSource.value != '*TXV') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Forecast data source must be selected';
      }
      if (document.main.INP_ForSource.value == '*PLN') {
         if (document.main.INP_ForMaterial.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Forecast material list must be *ALL or a comma separated list of materials for forecast planning data source';
         }
         document.main.INP_ForFileTXQ.value = '';
         document.main.INP_ForFileTXV.value = '';
         document.main.INP_ForStream.value = '';
      }
      if (document.main.INP_ForSource.value == '*TXQ') {
         if (document.main.INP_ForFileTXQ.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Forecast text file must be specified for forecast text file quantity data source';
         }
         document.main.INP_ForMaterial.value = '';
         document.main.INP_ForFileTXV.value = '';
      }
      if (document.main.INP_ForSource.value == '*TXV') {
         if (document.main.INP_ForFileTXV.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Forecast text file must be specified for forecast text file quantity/value data source';
         }
         document.main.INP_ForMaterial.value = '';
         document.main.INP_ForFileTXQ.value = '';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (document.main.INP_ForSource.value == '*TXQ') {
         if (!readTextFile(document.main.INP_ForFileTXQ.value)) {
            return;
         }
      }
      if (document.main.INP_ForSource.value == '*TXV') {
         if (!readTextFile(document.main.INP_ForFileTXV.value)) {
            return;
         }
      }
      doActivityStart(eval('document.body'));
      document.main.DTA_ForIdentifier.value = document.main.INP_ForIdentifier.value;
      document.main.DTA_ForDescription.value = document.main.INP_ForDescription.value;
      document.main.DTA_ForReplace.value = document.main.INP_ForReplace.value
      document.main.DTA_ForType.value = document.main.INP_ForType.value;
      document.main.DTA_ForSplit.value = document.main.INP_ForSplit.value;
      document.main.DTA_ForSource.value = document.main.INP_ForSource.value;
      document.main.DTA_ForMaterial.value = document.main.INP_ForMaterial.value;
      document.main.DTA_ForFileTXQ.value = document.main.INP_ForFileTXQ.value;
      document.main.DTA_ForFileTXV.value = document.main.INP_ForFileTXV.value;
      document.main.DTA_ForStream.value = document.main.INP_ForStream.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'CREATE';
      document.main.submit();
   }
   function doDelete(strIdentifier) {
      if (!processForm()) {return;}
      if (confirm('Please confirm that you wish to delete '+strIdentifier+'\r\nPress OK to continue or press Cancel')) {
         doActivityStart(eval('document.body'));
         document.main.DTA_ForIdentifier.value = strIdentifier;
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
   function selectReplace(strReplace) {
      document.main.INP_ForReplace.value = strReplace;
   }
   function selectType(strType) {
      document.main.INP_ForType.value = strType;
   }
   function selectSplit(objSelect) {
      document.main.INP_ForSplit.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectSource(strSource) {
      document.main.INP_ForSource.value = strSource;
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
      document.main.INP_ForStream.value = strStream;
      return true;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<!--#include file="ics_std_spreadsheet.inc"-->
<!--#include file="ics_std_activity.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="no" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_fcst_maintenance_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');<%if strMode = "CREATE" then%>showPanel();<%end if%>showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table id="tabList" style="display:block;visibility:visible" class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=5 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:showPanel();">&nbsp;Create&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doUpload();">&nbsp;Upload&nbsp;</a><input class="clsInputNN" type="file" name="INP_Upload" size="64" value="" onFocus="setSelect(this);"></nobr></td>
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
                     <table class="clsTableHead" id="tabHead" align=left cols=13 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Action&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Identifier&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Description&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Status&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Replace&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Forecast Split&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Time&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Casting&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Source&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Materials&nbsp;</nobr></td>
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
                     <table class="clsTableBody" id="tabBody" align=left cols=12 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("LIST") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=12 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:doDownload('<%=objSelection.ListValue01("LIST",i)%>');">Download</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doDelete('<%=objSelection.ListValue01("LIST",i)%>');">Delete</a></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue08("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue09("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue10("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue11("LIST",i)%></nobr></td>
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
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_ForIdentifier" size="64" maxlength="64" value="<%=objForm.Fields("DTA_ForIdentifier").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_ForDescription" size="64" maxlength="128" value="<%=objForm.Fields("DTA_ForDescription").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Forecast Replacement:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltReplace"<%if objForm.Fields("DTA_ForReplace").Value = "*SPLIT" then%> checked<%end if%> value="*SPLIT" onClick="javascript:selectReplace('*SPLIT');">Replace all materials in forecast split&nbsp;
            <input type="radio" name="sltReplace"<%if objForm.Fields("DTA_ForReplace").Value = "*MATERIAL" then%> checked<%end if%> value="*MATERIAL" onClick="javascript:selectReplace('*MATERIAL');">Replace selected materials only&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Forecast Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltType"<%if objForm.Fields("DTA_ForType").Value = "PRDBR" then%> checked<%end if%> value="PRDBR" onClick="javascript:selectType('PRDBR');">Period Business Review&nbsp;
            <input type="radio" name="sltType"<%if objForm.Fields("DTA_ForType").Value = "PRDOP1" then%> checked<%end if%> value="PRDOP1" onClick="javascript:selectType('PRDOP1');">Period Operating Plan - This Year&nbsp;
            <input type="radio" name="sltType"<%if objForm.Fields("DTA_ForType").Value = "PRDOP2" then%> checked<%end if%> value="PRDOP2" onClick="javascript:selectType('PRDOP2');">Period Operating Plan - Next Year&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Forecast Split:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltSplit" onChange="selectSplit(this);">
               <option value=""<%if objForm.Fields("DTA_ForSplit").Value = "" then%> selected<%end if%>>** select **<%for i = 0 to objSelection.ListCount("SPLIT") - 1%>
               <option value="<%=objSelection.ListValue01("SPLIT",i)%>"<%if objForm.Fields("DTA_ForSplit").Value = objSelection.ListValue01("SPLIT",i) then%> selected<%end if%>><%=objSelection.ListValue02("SPLIT",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Forecast Data:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltSource"<%if objForm.Fields("DTA_ForSource").Value = "*PLN" then%> checked<%end if%> value="*PLN" onClick="javascript:selectSource('*PLN');">Planning&nbsp;
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_ForMaterial" size="64" maxlength="2000" value="<%=objForm.Fields("DTA_ForMaterial").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <font class="clsWorking">&nbsp;A filter list of material codes can be supplied (*ALL or comma delimited list)&nbsp;</font>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <input type="radio" name="sltSource"<%if objForm.Fields("DTA_ForSource").Value = "*TXQ" then%> checked<%end if%> value="*TXQ" onClick="javascript:selectSource('*TXQ');">Text File (Quantity Only)&nbsp;
            <input class="clsInputNN" type="file" name="INP_ForFileTXQ" size="64" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <font class="clsWorking">&nbsp;The text file must be a tab delimited file (material code plus 13 quantities)&nbsp;</font>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <input type="radio" name="sltSource"<%if objForm.Fields("DTA_ForSource").Value = "*TXV" then%> checked<%end if%> value="*TXV" onClick="javascript:selectSource('*TXV');">Text File (Quantity and Values)&nbsp;
            <input class="clsInputNN" type="file" name="INP_ForFileTXV" size="64" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <font class="clsWorking">&nbsp;The text file must be a tab delimited file (material code plus 13 quantities, 13 BPS values and 13 GSV values)&nbsp;</font>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
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
   <input type="hidden" name="DTA_ForIdentifier" value="<%=objForm.Fields("DTA_ForIdentifier").Value%>">
   <input type="hidden" name="DTA_ForDescription" value="<%=objForm.Fields("DTA_ForDescription").Value%>">
   <input type="hidden" name="DTA_ForReplace" value="<%=objForm.Fields("DTA_ForReplace").Value%>">
   <input type="hidden" name="DTA_ForType" value="<%=objForm.Fields("DTA_ForType").Value%>">
   <input type="hidden" name="DTA_ForSplit" value="<%=objForm.Fields("DTA_ForSplit").Value%>">
   <input type="hidden" name="DTA_ForSource" value="<%=objForm.Fields("DTA_ForSource").Value%>">
   <input type="hidden" name="DTA_ForMaterial" value="<%=objForm.Fields("DTA_ForMaterial").Value%>">
   <input type="hidden" name="DTA_ForFileTXQ" value="<%=objForm.Fields("DTA_ForFileTXQ").Value%>">
   <input type="hidden" name="DTA_ForFileTXV" value="<%=objForm.Fields("DTA_ForFileTXV").Value%>">
   <input type="hidden" name="DTA_ForStream" value="">
   <input type="hidden" name="INP_ForReplace" value="<%=objForm.Fields("DTA_ForReplace").Value%>">
   <input type="hidden" name="INP_ForType" value="<%=objForm.Fields("DTA_ForType").Value%>">
   <input type="hidden" name="INP_ForSplit" value="<%=objForm.Fields("DTA_ForSplit").Value%>">
   <input type="hidden" name="INP_ForSource" value="<%=objForm.Fields("DTA_ForSource").Value%>">
   <input type="hidden" name="INP_ForStream" value="">
</form>
</body>
</html>