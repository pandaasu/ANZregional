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
      var bolChange = false;
      var bolReturn;
      if (changeMaterials() == true) {bolChange = true;}
      if (bolChange == true) {
         bolReturn = confirm('Changes have been made to this information\r\npress OK continue (changes will be lost)\r\npress Cancel to return to the function');
         return bolReturn;
      }
      return true;
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
      document.main.Mode.value = 'DEFINE_ACCEPT';
      document.main.submit();
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
   function selectPriceMdlId(objSelect) {
      var strPriceMdlId = objSelect.options[objSelect.selectedIndex].value;
      document.main.INP_PriceMdlId.value = strPriceMdlId;
      if (strPriceMdlId != '') {
         doActivityStart(document.body);
         window.setTimeout('getPriceItems(\''+strPriceMdlId+'\');',10);
      }
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
      cobjMaterials[<%=i%>] = new clsMaterial('<%=objSelection.ListValue01("MATERIAL",i)%>','<%=replace(objSelection.ListValue02("MATERIAL",i), "'", "\'", 1, -1, 1)%>'<%next%><%end if%>
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
         cobjPriceItems.length = 0;
         for (var i=0;i<aryRows.length;i++) {
            aryColumns = aryRows[i].split('\t');
            cobjPriceItems[i] = new clsPriceItem(aryColumns[0],aryColumns[1],aryColumns[2]);
         }
         var objSltPriceItem = document.getElementById('sltPriceItem');
         objSltPriceItem.options.length = 0;
         objSltPriceItem.selectedIndex = -1;
         for (var i=0;i<cobjPriceItems.length;i++) {
            objSltPriceItem.options[i] = new Option(cobjPriceItems[i].name,cobjPriceItems[i].prcid);
         }
         var objWork = new Array();
         var intIndex = 0;
         objWork.length = 0;
         intIndex = 0;
         var objSltReportData = document.getElementById('sltReportData');
         for (var i=0;i<objSltReportData.options.length;i++) {
            for (var j=0;j<cobjPriceItems.length;j++) {
               if (objSltReportData.options[i].getAttribute('prcid') == cobjPriceItems[j].prcid) {
                  objWork[intIndex] = objSltReportData[i];
                  intIndex++;
               }
            }
         }
         objSltReportData.options.length = 0;
         objSltReportData.selectedIndex = -1;
         for (var i=0;i<objWork.length;i++) {
            objSltReportData.options[i] = objWork[i];
         }
         objWork.length = 0;
         intIndex = 0;
         var objSltReportBreak = document.getElementById('sltReportBreak');
         for (var i=0;i<objSltReportBreak.options.length;i++) {
            for (var j=0;j<cobjPriceItems.length;j++) {
               if (objSltReportBreak.options[i].getAttribute('prcid') == cobjPriceItems[j].prcid) {
                  objWork[intIndex] = objSltReportBreak[i];
                  intIndex++;
               }
            }
         }
         objSltReportBreak.options.length = 0;
         objSltReportBreak.selectedIndex = -1;
         for (var i=0;i<objWork.length;i++) {
            objSltReportBreak.options[i] = objWork[i];
         }
         objWork.length = 0;
         intIndex = 0;
         var objSltReportOrder = document.getElementById('sltReportOrder');
         for (var i=0;i<objSltReportOrder.options.length;i++) {
            for (var j=0;j<cobjPriceItems.length;j++) {
               if (objSltReportOrder.options[i].getAttribute('prcid') == cobjPriceItems[j].prcid) {
                  objWork[intIndex] = objSltReportOrder[i];
                  intIndex++;
               }
            }
         }
         objSltReportOrder.options.length = 0;
         objSltReportOrder.selectedIndex = -1;
         for (var i=0;i<objWork.length;i++) {
            objSltReportOrder.options[i] = objWork[i];
         }
      }
      doActivityStop();
   }
   function clsMaterial(strCode,strDesc) {
      this.code = strCode;
      this.desc = strDesc;
   }
   function removeMaterial() {
      var objSltPriceItem = document.getElementById('sltPriceItem');
      var objSltReportData = document.getElementById('sltReportData');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objSltReportData.options.length;i++) {
         if (objSltReportData.options[i].selected == false) {
            objWork[intIndex] = objSltReportData[i];
            intIndex++;
         }
      }
      objSltReportData.options.length = 0;
      objSltReportData.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSltReportData.options[i] = objWork[i];
      }
   }
   function checkMaterials() {
      var strReturn = '';
      var objHidden = null;
      var objSltReportData = document.getElementById('sltReportData');
      var objSltReportBreak = document.getElementById('sltReportBreak');
      var objSltReportOrder = document.getElementById('sltReportOrder');
      var objTxtReportTerm = document.getElementById('txtReportTerm');
      if (objSltReportData.options.length == 0) {
         strReturn = 'At least one data item must be selected';
      } else {
         for (var i=0;i<objSltReportData.options.length;i++) {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepDatId'+(i+1));
            objHidden.setAttribute('value',objSltReportData.options[i].getAttribute('repid'));
            document.forms['main'].appendChild(objHidden);
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepDatPrcId'+(i+1));
            objHidden.setAttribute('value',objSltReportData.options[i].getAttribute('prcid'));
            document.forms['main'].appendChild(objHidden);
         }
         document.getElementById('DET_RepDatCount').value = objSltReportData.options.length;
         for (var i=0;i<objSltReportBreak.options.length;i++) {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepBrkId'+(i+1));
            objHidden.setAttribute('value',objSltReportBreak.options[i].getAttribute('repid'));
            document.forms['main'].appendChild(objHidden);
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepBrkPrcId'+(i+1));
            objHidden.setAttribute('value',objSltReportBreak.options[i].getAttribute('prcid'));
            document.forms['main'].appendChild(objHidden);
         }
         document.getElementById('DET_RepBrkCount').value = objSltReportBreak.options.length;
         for (var i=0;i<objSltReportOrder.options.length;i++) {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepOrdId'+(i+1));
            objHidden.setAttribute('value',objSltReportOrder.options[i].getAttribute('repid'));
            document.forms['main'].appendChild(objHidden);
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepOrdPrcId'+(i+1));
            objHidden.setAttribute('value',objSltReportOrder.options[i].getAttribute('prcid'));
            document.forms['main'].appendChild(objHidden);
         }
         document.getElementById('DET_RepOrdCount').value = objSltReportOrder.options.length;
         var aryTerms = objTxtReportTerm.value.split('\n');
         for (var i=0;i<aryTerms.length;i++) {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepTerText'+(i+1));
            objHidden.setAttribute('value',aryTerms[i]);
            document.forms['main'].appendChild(objHidden);
         }
         document.getElementById('DET_RepTerCount').value = aryTerms.length;
      }
      return strReturn;
   }
   function changeMaterials() {
      var bolReturn = false;
      var objSltReportData = document.getElementById('sltReportData');
      var objSltReportBreak = document.getElementById('sltReportBreak');
      var objSltReportOrder = document.getElementById('sltReportOrder');
      var objTxtReportTerm = document.getElementById('txtReportTerm');
      if (cobjReportData.length != objSltReportData.options.length) {
         bolReturn = true;
      } else {
         for (var i=0;i<cobjReportData.length;i++) {
            if (cobjReportData[i].repid != objSltReportData.options[i].getAttribute('repid') ||
                cobjReportData[i].prcid != objSltReportData.options[i].getAttribute('prcid')) {
               bolReturn = true;
               break;
            }
         }
      }
      if (cobjReportBreak.length != objSltReportBreak.options.length) {
         bolReturn = true;
      } else {
         for (var i=0;i<cobjReportBreak.length;i++) {
            if (cobjReportBreak[i].repid != objSltReportBreak.options[i].getAttribute('repid') ||
                cobjReportBreak[i].prcid != objSltReportBreak.options[i].getAttribute('prcid')) {
               bolReturn = true;
               break;
            }
         }
      }
      if (cobjReportOrder.length != objSltReportOrder.options.length) {
         bolReturn = true;
      } else {
         for (var i=0;i<cobjReportOrder.length;i++) {
            if (cobjReportOrder[i].repid != objSltReportOrder.options[i].getAttribute('repid') ||
                cobjReportOrder[i].prcid != objSltReportOrder.options[i].getAttribute('prcid')) {
               bolReturn = true;
               break;
            }
         }
      }
      return bolReturn;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('prc_lst_configuration_material_help.htm');parent.setHeading('<%=strHeading%> - Report Materials');parent.showContent();loadMaterials();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Report Name:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=replace(objForm.Fields("DTA_ReportName").Value, """", "&#34;", 1, -1, 1)%></nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsTabB" align=center colspan=2 nowrap><nobr>&nbsp;Materials&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
                     <div class="clsScroll">
                     <table id="tabMatl" class="clsTableBody" align=left cols=2 cellpadding="0" cellspacing="1"></table>
                     </div>
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
   <input type="hidden" name="DTA_ReportId" value="<%=objForm.Fields("DTA_ReportId").Value%>">
   <input type="hidden" name="DET_RepMatCount" value="">
</form>
</body>
</html>