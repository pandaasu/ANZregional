<html>
<script language="javascript">
<!--
   function showError() {<%if strReturn <> "*OK" then%>
      alert('<%=strReturn%>');<%else%>
      return;<%end if%>
   }
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
      if (objElement.className == 'clsButtonN') {
         objElement.className = 'clsButtonNX';
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
      if (objElement.className == 'clsButtonNX') {
         objElement.className = 'clsButtonN';
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
      strDetail = checkMaterials();
      if (strDetail != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strDetail;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'MATERIAL_ACCEPT';
      document.main.submit();
   }
   function doRefresh() {
      doActivityStart(document.body);
      window.setTimeout('getMaterials(\'<%=objForm.Fields("DTA_ReportId").Value%>\');',10);
   }
   function doSelect(objSelected) {
      if (cobjSelected) {
         cobjSelected.className = 'clsList';
      }
      cobjSelected = objSelected;
      cobjSelected.className = 'clsListX';
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
<script language="javascript">
<!--
   ////////////////////////////
   // Report material script //
   ////////////////////////////
   var cobjMaterials = new Array();
   var cobjSelected = null;
   function loadMaterials() {<%if objSelection.ListCount("MATERIAL") <> 0 then%><%for i = objSelection.ListLower("MATERIAL") to objSelection.ListUpper("MATERIAL")%>
      cobjMaterials[<%=i%>] = new clsMaterial('<%=objSelection.ListValue01("MATERIAL",i)%>','<%=replace(objSelection.ListValue02("MATERIAL",i), "'", "\'", 1, -1, 1)%>');<%next%><%end if%>
      var objTable;
      var objRow;
      var objCell;
      var intRowCount;
      var intCellCount;
      objTable = document.getElementById('tabMatl');
      intRowCount = 0;
      for (var i=0;i<cobjMaterials.length;i++) {
         objRow = objTable.insertRow(intRowCount);
         objCell = objRow.insertCell(0);
         objCell.innerText = cobjMaterials[i].code;
         objCell.onclick = function() {doSelect(this);};
         objCell.className = 'clsList';
         objCell.setAttribute('idx',i);
         objCell = objRow.insertCell(1);
         objCell.innerText = cobjMaterials[i].desc;
         objCell.className = 'clsLabelFN';
         intRowCount++;
      }
   }
   function getMaterials(strReportId) {
      doGetRequest('<%=strBase%>prc_lst_matl_lookup.asp?QRY_ReportId='+strReportId,function(strResponse) {reloadMaterials(strResponse);},false);
   }
   function reloadMaterials(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var aryRows = strResponse.substring(3,strResponse.length).split('\n');
         var aryColumns;
         cobjMaterials.length = 0;
         for (var i=0;i<aryRows.length;i++) {
            aryColumns = aryRows[i].split('\t');
            cobjMaterials[i] = new clsMaterial(aryColumns[0],aryColumns[1]);
         }
         var objTable;
         var objRow;
         var objCell;
         var intRowCount;
         var intCellCount;
         objTable = document.getElementById('tabMatl');
         for (var i=objTable.rows.length;i>0;i--) {
            objTable.deleteRow(i-1);
         }
         intRowCount = 0;
         for (var i=0;i<cobjMaterials.length;i++) {
            objRow = objTable.insertRow(intRowCount);
            objCell = objRow.insertCell(0);
            objCell.innerText = cobjMaterials[i].code;
            objCell.onclick = function() {doSelect(this);};
            objCell.className = 'clsList';
            objCell.setAttribute('idx',i);
            objCell = objRow.insertCell(1);
            objCell.innerText = cobjMaterials[i].desc;
            objCell.className = 'clsLabelFN';
            intRowCount++;
         }
      }
      doActivityStop();
   }
   function clsMaterial(strCode,strDesc) {
      this.code = strCode;
      this.desc = strDesc;
   }
   function removeMaterial() {
   }
   function checkMaterials() {
      var strReturn = '';
      var objHidden = null;
      return strReturn;
   }
   function changeMaterials() {
      var bolReturn = false;
      return bolReturn;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('prc_lst_configuration_material_help.htm');parent.setHeading('<%=strHeading%> - Report Materials');parent.showContent();loadMaterials();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Report Name:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=replace(objSelection.ListValue02("REPORT",objSelection.ListLower("REPORT")), """", "&#34;", 1, -1, 1)%></nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAdd();">&nbsp;Add&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100% width=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01">
               <table id="tabMatl" class="clsTableBody" align=left cellpadding="0" cellspacing="1"></table>
            </div>
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
   <input type="hidden" name="DTA_ReportId" value="<%=objForm.Fields("DTA_ReportId").Value%>">
   <input type="hidden" name="DET_RepMatCount" value="">
</form>
</body>
</html>