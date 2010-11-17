<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_ReportName.focus();<%if strReturn <> "*OK" then%>
      alert('<%=strReturn%>');<%else%>return;<%end if%>
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
      if (document.main.INP_ReportName.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Report name must be entered';
      }
      if (document.main.INP_ReportGrpId.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Report group must be selected';
      }
      if (document.main.INP_PriceMdlId.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Price model must be selected';
      }
      if (document.main.INP_MatlAlrtng.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Material alerting must be selected';
      }
      if (document.main.INP_AutoMatlUpdate.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Auto material update must be selected';
      }
      if (document.main.INP_EmailAddress.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Notification email address must be entered';
      }
      if (document.main.INP_Status.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Status must be selected';
      }
      if (document.main.INP_CopyTerms.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Copy report group terms and conditions must be selected';
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
      document.main.DTA_ReportName.value = document.main.INP_ReportName.value;
      document.main.DTA_ReportGrpId.value = document.main.INP_ReportGrpId.value;
      document.main.DTA_PriceMdlId.value = document.main.INP_PriceMdlId.value;
      document.main.DTA_MatlAlrtng.value = document.main.INP_MatlAlrtng.value;
      document.main.DTA_AutoMatlUpdate.value = document.main.INP_AutoMatlUpdate.value;
      document.main.DTA_EmailAddress.value = document.main.INP_EmailAddress.value;
      document.main.DTA_Status.value = document.main.INP_Status.value;
      document.main.DTA_CopyTerms.value = document.main.INP_CopyTerms.value;
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
   function selectReportGrpId(objSelect) {
      document.main.INP_ReportGrpId.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectPriceMdlId(objSelect) {
      var strPriceMdlId = objSelect.options[objSelect.selectedIndex].value;
      document.main.INP_PriceMdlId.value = strPriceMdlId;
      if (strPriceMdlId != '') {
         doActivityStart(document.body);
         window.setTimeout('getPriceItems(\''+strPriceMdlId.substring(0,7)+'\');',10);
      }
   }
   function selectMatlAlrtng(strValue) {
      document.main.INP_MatlAlrtng.value = strValue;
   }
   function selectAutoMatlUpdate(strValue) {
      document.main.INP_AutoMatlUpdate.value = strValue;
   }
   function selectStatus(strValue) {
      document.main.INP_Status.value = strValue;
   }
   function selectCopyTerms(strValue) {
      document.main.INP_CopyTerms.value = strValue;
      if (document.main.INP_CopyTerms.value == 'Y') {
         document.getElementById('txtReportTerm').disabled = true;
      } else {
         document.getElementById('txtReportTerm').disabled = false;
      }
   }
   function showItem() {
      var objTableItem = document.getElementById('tabItem');
      var objTableTerm = document.getElementById('tabTerm');
      document.getElementById('pckItem').className = 'clsTabX';
      document.getElementById('pckTerm').className = 'clsTab';
      objTableTerm.style.display = 'none';
      objTableTerm.style.visibility = 'hidden';
      objTableItem.style.display = 'block';
      objTableItem.style.visibility = 'visible';
   }
   function showTerm() {
      var objTableItem = document.getElementById('tabItem');
      var objTableTerm = document.getElementById('tabTerm');
      document.getElementById('pckItem').className = 'clsTab';
      document.getElementById('pckTerm').className = 'clsTabX';
      objTableItem.style.display = 'none';
      objTableItem.style.visibility = 'hidden';
      objTableTerm.style.display = 'block';
      objTableTerm.style.visibility = 'visible';
   }
// -->
</script>
<script language="javascript">
<!--
   //////////////////////////////
   // Report definition script //
   //////////////////////////////
   var cobjPriceItems = new Array();
   var cobjReportData = new Array();
   var cobjReportBreak = new Array();
   var cobjReportOrder = new Array();
   var cobjReportTerm = new Array();
   var cstrReportTerm = '';
   var cintSelectedDataItem = -1;
   function loadPriceItems() {<%if objSelection.ListCount("PRICE_ITEM") <> 0 then%><%for i = objSelection.ListLower("PRICE_ITEM") to objSelection.ListUpper("PRICE_ITEM")%>
      cobjPriceItems[<%=i%>] = new clsPriceItem('<%=objSelection.ListValue01("PRICE_ITEM",i)%>','<%=replace(objSelection.ListValue02("PRICE_ITEM",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue03("PRICE_ITEM",i), "'", "\'", 1, -1, 1)%>');<%next%><%end if%><%if objForm.Fields("DTA_ReportId").Value <> "0" then%><%if objSelection.ListCount("REPORT_DATA") <> 0 then%><%for i = objSelection.ListLower("REPORT_DATA") to objSelection.ListUpper("REPORT_DATA")%>
      cobjReportData[<%=i%>] = new clsReportData('<%=objSelection.ListValue01("REPORT_DATA",i)%>','<%=objSelection.ListValue02("REPORT_DATA",i)%>','<%=replace(objSelection.ListValue03("REPORT_DATA",i), "'", "\'", 1, -1, 1)%>');<%next%><%end if%><%if objSelection.ListCount("REPORT_BREAK") <> 0 then%><%for i = objSelection.ListLower("REPORT_BREAK") to objSelection.ListUpper("REPORT_BREAK")%>
      cobjReportBreak[<%=i%>] = new clsReportBreak('<%=objSelection.ListValue01("REPORT_BREAK",i)%>','<%=objSelection.ListValue02("REPORT_BREAK",i)%>','<%=replace(objSelection.ListValue03("REPORT_BREAK",i), "'", "\'", 1, -1, 1)%>');<%next%><%end if%><%if objSelection.ListCount("REPORT_ORDER") <> 0 then%><%for i = objSelection.ListLower("REPORT_ORDER") to objSelection.ListUpper("REPORT_ORDER")%>
      cobjReportOrder[<%=i%>] = new clsReportOrder('<%=objSelection.ListValue01("REPORT_ORDER",i)%>','<%=objSelection.ListValue02("REPORT_ORDER",i)%>','<%=replace(objSelection.ListValue03("REPORT_ORDER",i), "'", "\'", 1, -1, 1)%>');<%next%><%end if%><%if objSelection.ListCount("REPORT_TERM") <> 0 then%><%for i = objSelection.ListLower("REPORT_TERM") to objSelection.ListUpper("REPORT_TERM")%>
      cstrReportTerm = <%if i > 0 then%>cstrReportTerm+<%end if%>'<%=replace(objSelection.ListValue01("REPORT_TERM",i), "'", "\'", 1, -1, 1)%>'<%if i < objSelection.ListCount("REPORT_TERM")-1 then%>+'\n'<%end if%>;<%next%><%end if%><%end if%>
      var objSltPriceItem = document.getElementById('sltPriceItem');
      objSltPriceItem.options.length = 0;
      objSltPriceItem.selectedIndex = -1;
      for (var i=0;i<cobjPriceItems.length;i++) {
         objSltPriceItem.options[i] = new Option(cobjPriceItems[i].name,cobjPriceItems[i].prcid);
      }
      var objSltReportData = document.getElementById('sltReportData');
      objSltReportData.options.length = 0;
      objSltReportData.selectedIndex = -1;
      for (var i=0;i<cobjReportData.length;i++) {
         objSltReportData.options[i] = new Option(cobjReportData[i].name,cobjReportData[i].repid);
         objSltReportData.options[i].setAttribute('repid',cobjReportData[i].repid);
         objSltReportData.options[i].setAttribute('prcid',cobjReportData[i].prcid);
      }
      var objSltReportBreak = document.getElementById('sltReportBreak');
      objSltReportBreak.options.length = 0;
      objSltReportBreak.selectedIndex = -1;
      for (var i=0;i<cobjReportBreak.length;i++) {
         objSltReportBreak.options[i] = new Option(cobjReportBreak[i].name,cobjReportBreak[i].repid);
         objSltReportBreak.options[i].setAttribute('repid',cobjReportBreak[i].repid);
         objSltReportBreak.options[i].setAttribute('prcid',cobjReportBreak[i].prcid);
      }
      var objSltReportOrder = document.getElementById('sltReportOrder');
      objSltReportOrder.options.length = 0;
      objSltReportOrder.selectedIndex = -1;
      for (var i=0;i<cobjReportOrder.length;i++) {
         objSltReportOrder.options[i] = new Option(cobjReportOrder[i].name,cobjReportOrder[i].repid);
         objSltReportOrder.options[i].setAttribute('repid',cobjReportOrder[i].repid);
         objSltReportOrder.options[i].setAttribute('prcid',cobjReportOrder[i].prcid);
      }
      var objTxtReportTerm = document.getElementById('txtReportTerm');
      objTxtReportTerm.value = cstrReportTerm;
   }
   function getPriceItems(strPriceMdlId) {
      doGetRequest('<%=strBase%>prc_lst_item_lookup.asp?QRY_PriceMdlId='+strPriceMdlId,function(strResponse) {reloadPriceItems(strResponse);},false);
   }
   function reloadPriceItems(strResponse) {
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
   function clsPriceItem(strPrcId,strName,strDesc) {
      this.prcid = strPrcId;
      this.name = strName;
      this.desc = strDesc;
   }
   function clsReportData(strRepId,strPrcId,strName) {
      this.repid = strRepId;
      this.prcid = strPrcId;
      this.name = strName;
   }
   function clsReportBreak(strRepId,strPrcId,strName) {
      this.repid = strRepId;
      this.prcid = strPrcId;
      this.name = strName;
   }
   function clsReportOrder(strRepId,strPrcId,strName) {
      this.repid = strRepId;
      this.prcid = strPrcId;
      this.name = strName;
   }
   function selectDataItems() {
      var objSltPriceItem = document.getElementById('sltPriceItem');
      var objSltReportData = document.getElementById('sltReportData');
      for (var i=0;i<objSltPriceItem.options.length;i++) {
         if (objSltPriceItem.options[i].selected == true) {
            objSltReportData.options[objSltReportData.options.length] = new Option(objSltPriceItem[i].text,objSltPriceItem[i].value);
            objSltReportData.options[objSltReportData.options.length-1].setAttribute('repid','0');
            objSltReportData.options[objSltReportData.options.length-1].setAttribute('prcid',objSltPriceItem[i].value);
         }
      }
   }
   function selectBreakItems() {
      var objSltPriceItem = document.getElementById('sltPriceItem');
      var objSltReportBreak = document.getElementById('sltReportBreak');
      for (var i=0;i<objSltPriceItem.options.length;i++) {
         if (objSltPriceItem.options[i].selected == true) {
            objSltReportBreak.options[objSltReportBreak.options.length] = new Option(objSltPriceItem[i].text,objSltPriceItem[i].value);
            objSltReportBreak.options[objSltReportBreak.options.length-1].setAttribute('repid','0');
            objSltReportBreak.options[objSltReportBreak.options.length-1].setAttribute('prcid',objSltPriceItem[i].value);
         }
      }
   }
   function selectOrderItems() {
      var objSltPriceItem = document.getElementById('sltPriceItem');
      var objSltReportOrder = document.getElementById('sltReportOrder');
      for (var i=0;i<objSltPriceItem.options.length;i++) {
         if (objSltPriceItem.options[i].selected == true) {
            objSltReportOrder.options[objSltReportOrder.options.length] = new Option(objSltPriceItem[i].text,objSltPriceItem[i].value);
            objSltReportOrder.options[objSltReportOrder.options.length-1].setAttribute('repid','0');
            objSltReportOrder.options[objSltReportOrder.options.length-1].setAttribute('prcid',objSltPriceItem[i].value);
         }
      }
   }
   function removeDataItems() {
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
   function removeBreakItems() {
      var objSltPriceItem = document.getElementById('sltPriceItem');
      var objSltReportBreak = document.getElementById('sltReportBreak');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objSltReportBreak.options.length;i++) {
         if (objSltReportBreak.options[i].selected == false) {
            objWork[intIndex] = objSltReportBreak[i];
            intIndex++;
         }
      }
      objSltReportBreak.options.length = 0;
      objSltReportBreak.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSltReportBreak.options[i] = objWork[i];
      }
   }
   function removeOrderItems() {
      var objSltPriceItem = document.getElementById('sltPriceItem');
      var objSltReportOrder = document.getElementById('sltReportOrder');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objSltReportOrder.options.length;i++) {
         if (objSltReportOrder.options[i].selected == false) {
            objWork[intIndex] = objSltReportOrder[i];
            intIndex++;
         }
      }
      objSltReportOrder.options.length = 0;
      objSltReportOrder.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSltReportOrder.options[i] = objWork[i];
      }
   }
   function upDataItems() {
      var intIndex;
      var intSelect;
      var objSltReportData = document.getElementById('sltReportData');
      intSelect = 0;
      for (var i=0;i<objSltReportData.options.length;i++) {
         if (objSltReportData.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one item can be selected to move up');
         return;
      }
      if (intSelect == 1 && intIndex > 0) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objSltReportData.options[intIndex-1].value;
         aryA[1] = objSltReportData.options[intIndex-1].text;
         aryA[2] = objSltReportData.options[intIndex-1].getAttribute('repid');
         aryA[3] = objSltReportData.options[intIndex-1].getAttribute('prcid');
         aryB[0] = objSltReportData.options[intIndex].value;
         aryB[1] = objSltReportData.options[intIndex].text;
         aryB[2] = objSltReportData.options[intIndex].getAttribute('repid');
         aryB[3] = objSltReportData.options[intIndex].getAttribute('prcid');
         objSltReportData.options[intIndex-1].value = aryB[0];
         objSltReportData.options[intIndex-1].text = aryB[1];
         objSltReportData.options[intIndex-1].setAttribute('repid',aryB[2]);
         objSltReportData.options[intIndex-1].setAttribute('prcid',aryB[3]);
         objSltReportData.options[intIndex-1].selected = true;
         objSltReportData.options[intIndex].value = aryA[0];
         objSltReportData.options[intIndex].text = aryA[1];
         objSltReportData.options[intIndex].setAttribute('repid',aryA[2]);
         objSltReportData.options[intIndex].setAttribute('prcid',aryA[3]);
         objSltReportData.options[intIndex].selected = false;
      }
   }
   function upBreakItems() {
      var intIndex;
      var intSelect;
      var objSltReportBreak = document.getElementById('sltReportBreak');
      intSelect = 0;
      for (var i=0;i<objSltReportBreak.options.length;i++) {
         if (objSltReportBreak.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one item can be selected to move up');
         return;
      }
      if (intSelect == 1 && intIndex > 0) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objSltReportBreak.options[intIndex-1].value;
         aryA[1] = objSltReportBreak.options[intIndex-1].text;
         aryA[2] = objSltReportBreak.options[intIndex-1].getAttribute('repid');
         aryA[3] = objSltReportBreak.options[intIndex-1].getAttribute('prcid');
         aryB[0] = objSltReportBreak.options[intIndex].value;
         aryB[1] = objSltReportBreak.options[intIndex].text;
         aryB[2] = objSltReportBreak.options[intIndex].getAttribute('repid');
         aryB[3] = objSltReportBreak.options[intIndex].getAttribute('prcid');
         objSltReportBreak.options[intIndex-1].value = aryB[0];
         objSltReportBreak.options[intIndex-1].text = aryB[1];
         objSltReportBreak.options[intIndex-1].setAttribute('repid',aryB[2]);
         objSltReportBreak.options[intIndex-1].setAttribute('prcid',aryB[3]);
         objSltReportBreak.options[intIndex-1].selected = true;
         objSltReportBreak.options[intIndex].value = aryA[0];
         objSltReportBreak.options[intIndex].text = aryA[1];
         objSltReportBreak.options[intIndex].setAttribute('repid',aryA[2]);
         objSltReportBreak.options[intIndex].setAttribute('prcid',aryA[3]);
         objSltReportBreak.options[intIndex].selected = false;
      }
   }
   function upOrderItems() {
      var intIndex;
      var intSelect;
      var objSltReportOrder = document.getElementById('sltReportOrder');
      intSelect = 0;
      for (var i=0;i<objSltReportOrder.options.length;i++) {
         if (objSltReportOrder.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one item can be selected to move up');
         return;
      }
      if (intSelect == 1 && intIndex > 0) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objSltReportOrder.options[intIndex-1].value;
         aryA[1] = objSltReportOrder.options[intIndex-1].text;
         aryA[2] = objSltReportOrder.options[intIndex-1].getAttribute('repid');
         aryA[3] = objSltReportOrder.options[intIndex-1].getAttribute('prcid');
         aryB[0] = objSltReportOrder.options[intIndex].value;
         aryB[1] = objSltReportOrder.options[intIndex].text;
         aryB[2] = objSltReportOrder.options[intIndex].getAttribute('repid');
         aryB[3] = objSltReportOrder.options[intIndex].getAttribute('prcid');
         objSltReportOrder.options[intIndex-1].value = aryB[0];
         objSltReportOrder.options[intIndex-1].text = aryB[1];
         objSltReportOrder.options[intIndex-1].setAttribute('repid',aryB[2]);
         objSltReportOrder.options[intIndex-1].setAttribute('prcid',aryB[3]);
         objSltReportOrder.options[intIndex-1].selected = true;
         objSltReportOrder.options[intIndex].value = aryA[0];
         objSltReportOrder.options[intIndex].text = aryA[1];
         objSltReportOrder.options[intIndex].setAttribute('repid',aryA[2]);
         objSltReportOrder.options[intIndex].setAttribute('prcid',aryA[3]);
         objSltReportOrder.options[intIndex].selected = false;
      }
   }
   function downDataItems() {
      var intIndex;
      var intSelect;
      var objSltReportData = document.getElementById('sltReportData');
      intSelect = 0;
      for (var i=0;i<objSltReportData.options.length;i++) {
         if (objSltReportData.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one item can be selected to move down');
         return;
      }
      if (intSelect == 1 && intIndex < objSltReportData.options.length-1) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objSltReportData.options[intIndex+1].value;
         aryA[1] = objSltReportData.options[intIndex+1].text;
         aryA[2] = objSltReportData.options[intIndex+1].getAttribute('repid');
         aryA[3] = objSltReportData.options[intIndex+1].getAttribute('prcid');
         aryB[0] = objSltReportData.options[intIndex].value;
         aryB[1] = objSltReportData.options[intIndex].text;
         aryB[2] = objSltReportData.options[intIndex].getAttribute('repid');
         aryB[3] = objSltReportData.options[intIndex].getAttribute('prcid');
         objSltReportData.options[intIndex+1].value = aryB[0];
         objSltReportData.options[intIndex+1].text = aryB[1];
         objSltReportData.options[intIndex+1].setAttribute('repid',aryB[2]);
         objSltReportData.options[intIndex+1].setAttribute('prcid',aryB[3]);
         objSltReportData.options[intIndex+1].selected = true;
         objSltReportData.options[intIndex].value = aryA[0];
         objSltReportData.options[intIndex].text = aryA[1];
         objSltReportData.options[intIndex].setAttribute('repid',aryA[2]);
         objSltReportData.options[intIndex].setAttribute('prcid',aryA[3]);
         objSltReportData.options[intIndex].selected = false;
      }
   }
   function downBreakItems() {
      var intIndex;
      var intSelect;
      var objSltReportBreak = document.getElementById('sltReportBreak');
      intSelect = 0;
      for (var i=0;i<objSltReportBreak.options.length;i++) {
         if (objSltReportBreak.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one item can be selected to move down');
         return;
      }
      if (intSelect == 1 && intIndex < objSltReportBreak.options.length-1) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objSltReportBreak.options[intIndex+1].value;
         aryA[1] = objSltReportBreak.options[intIndex+1].text;
         aryA[2] = objSltReportBreak.options[intIndex+1].getAttribute('repid');
         aryA[3] = objSltReportBreak.options[intIndex+1].getAttribute('prcid');
         aryB[0] = objSltReportBreak.options[intIndex].value;
         aryB[1] = objSltReportBreak.options[intIndex].text;
         aryB[2] = objSltReportBreak.options[intIndex].getAttribute('repid');
         aryB[3] = objSltReportBreak.options[intIndex].getAttribute('prcid');
         objSltReportBreak.options[intIndex+1].value = aryB[0];
         objSltReportBreak.options[intIndex+1].text = aryB[1];
         objSltReportBreak.options[intIndex+1].setAttribute('repid',aryB[2]);
         objSltReportBreak.options[intIndex+1].setAttribute('prcid',aryB[3]);
         objSltReportBreak.options[intIndex+1].selected = true;
         objSltReportBreak.options[intIndex].value = aryA[0];
         objSltReportBreak.options[intIndex].text = aryA[1];
         objSltReportBreak.options[intIndex].setAttribute('repid',aryA[2]);
         objSltReportBreak.options[intIndex].setAttribute('prcid',aryA[3]);
         objSltReportBreak.options[intIndex].selected = false;
      }
   }
   function downOrderItems() {
      var intIndex;
      var intSelect;
      var objSltReportOrder = document.getElementById('sltReportOrder');
      intSelect = 0;
      for (var i=0;i<objSltReportOrder.options.length;i++) {
         if (objSltReportOrder.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one item can be selected to move down');
         return;
      }
      if (intSelect == 1 && intIndex < objSltReportOrder.options.length-1) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objSltReportOrder.options[intIndex+1].value;
         aryA[1] = objSltReportOrder.options[intIndex+1].text;
         aryA[2] = objSltReportOrder.options[intIndex+1].getAttribute('repid');
         aryA[3] = objSltReportOrder.options[intIndex+1].getAttribute('prcid');
         aryB[0] = objSltReportOrder.options[intIndex].value;
         aryB[1] = objSltReportOrder.options[intIndex].text;
         aryB[2] = objSltReportOrder.options[intIndex].getAttribute('repid');
         aryB[3] = objSltReportOrder.options[intIndex].getAttribute('prcid');
         objSltReportOrder.options[intIndex+1].value = aryB[0];
         objSltReportOrder.options[intIndex+1].text = aryB[1];
         objSltReportOrder.options[intIndex+1].setAttribute('repid',aryB[2]);
         objSltReportOrder.options[intIndex+1].setAttribute('prcid',aryB[3]);
         objSltReportOrder.options[intIndex+1].selected = true;
         objSltReportOrder.options[intIndex].value = aryA[0];
         objSltReportOrder.options[intIndex].text = aryA[1];
         objSltReportOrder.options[intIndex].setAttribute('repid',aryA[2]);
         objSltReportOrder.options[intIndex].setAttribute('prcid',aryA[3]);
         objSltReportOrder.options[intIndex].selected = false;
      }
   }
   function checkItems() {
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
         if (document.main.INP_CopyTerms.value == 'Y') {
            document.getElementById('DET_RepTerCount').value = 0;
         } else {
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
      }
      return strReturn;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('prc_lst_configuration_define_help.htm');parent.setHeading('<%=strHeading%> - Report Definition');parent.showContent();loadPriceItems();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Report Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_ReportName" size="100" maxlength="200" value="<%=replace(objForm.Fields("DTA_ReportName").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Report Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltReportGrpId" onChange="selectReportGrpId(this);">
               <option value=""<%if objForm.Fields("DTA_ReportGrpId").Value = "" then%> selected<%end if%>>** select report group **<%for i = 0 to objSelection.ListCount("REPORT_GRP") - 1%>
               <option value="<%=objSelection.ListValue01("REPORT_GRP",i)%>"<%if objForm.Fields("DTA_ReportGrpId").Value = objSelection.ListValue01("REPORT_GRP",i) then%> selected<%end if%>><%=objSelection.ListValue02("REPORT_GRP",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Price Model:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltPriceMdlId" onChange="selectPriceMdlId(this);">
               <option value=""<%if objForm.Fields("DTA_PriceMdlId").Value = "" then%> selected<%end if%>>** select price model **<%for i = 0 to objSelection.ListCount("PRICE_MDL") - 1%>
               <option value="<%=objSelection.ListValue01("PRICE_MDL",i)%>"<%if objForm.Fields("DTA_PriceMdlId").Value = objSelection.ListValue01("PRICE_MDL",i) then%> selected<%end if%>><%=objSelection.ListValue02("PRICE_MDL",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Notification Email Address:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EmailAddress" size="64" maxlength="64" value="<%=replace(objForm.Fields("DTA_EmailAddress").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Email Material Recommendations:&nbsp;
            <input type="radio" name="sltMatlAlrtng"<%if objForm.Fields("DTA_MatlAlrtng").Value = "" or objForm.Fields("DTA_MatlAlrtng").Value = "N" then%> checked<%end if%> value="N" onClick="javascript:selectMatlAlrtng('N');">No&nbsp;
            <input type="radio" name="sltMatlAlrtng"<%if objForm.Fields("DTA_MatlAlrtng").Value = "Y" then%> checked<%end if%> value="Y" onClick="javascript:selectMatlAlrtng('Y');">Yes&nbsp;
         &nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Automatically Apply Recommendations:&nbsp;
            <input type="radio" name="sltAutoMatlUpdate"<%if objForm.Fields("DTA_AutoMatlUpdate").Value = "" or objForm.Fields("DTA_AutoMatlUpdate").Value = "N" then%> checked<%end if%> value="N" onClick="javascript:selectAutoMatlUpdate('N');">No&nbsp;
            <input type="radio" name="sltAutoMatlUpdate"<%if objForm.Fields("DTA_AutoMatlUpdate").Value = "Y" then%> checked<%end if%> value="Y" onClick="javascript:selectAutoMatlUpdate('Y');">Yes&nbsp;
         &nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Available:&nbsp;
            <input type="radio" name="sltStatus"<%if objForm.Fields("DTA_Status").Value = "" or objForm.Fields("DTA_Status").Value = "I" then%> checked<%end if%> value="I" onClick="javascript:selectStatus('I');">No&nbsp;
            <input type="radio" name="sltStatus"<%if objForm.Fields("DTA_Status").Value = "V" then%> checked<%end if%> value="V" onClick="javascript:selectStatus('V');">Yes&nbsp;
         &nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=2 cellpadding="0" cellspacing="2">
               <tr>
                  <td id="pckItem" class="clsTabX" onClick="showItem();" align=center colspan=1 nowrap><nobr>&nbsp;Items&nbsp;</nobr></td>
                  <td id="pckTerm" class="clsTab" onClick="showTerm();" align=center colspan=1 nowrap><nobr>&nbsp;Terms and Conditions&nbsp;</nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table id="tabItem" style="display:block;visibility:visible" class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsTabB" align=center colspan=2 nowrap><nobr>&nbsp;Report Items&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
                     <table align=center border=0 cellpadding=0 cellspacing=2 cols=2>
                        <tr>
                           <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                              <select class="clsInputBN" id="sltPriceItem" name="sltPriceItem" style="width:300px" multiple size=20></select>
                           </nobr></td>
                           <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                              <table align=center border=0 cellpadding=0 cellspacing=2 cols=3>
                                 <tr>
                                    <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                                       <table class="clsTable01" width=100% align=center cols=2 cellpadding="0" cellspacing="0">
                                          <tr><td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Report Data&nbsp;</nobr></td></tr>
                                          <tr><td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_loff.gif" align=absmiddle onClick="removeDataItems();"></nobr></td>
                                              <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_roff.gif" align=absmiddle onClick="selectDataItems();"></nobr></td></tr>
                                       </table>
                                    </nobr></td>
                                    <td class="clsLabelBN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" id="sltReportData" name="sltReportData" style="width:300px" multiple size=8></select></nobr></td>
                                    <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                                       <table class="clsTable01" width=100% align=center cols=1 cellpadding="0" cellspacing="0">
                                          <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="upDataItems();"></nobr></td></tr>
                                          <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="downDataItems();"></nobr></td></tr>
                                       </table>
                                    </nobr></td>
                                 </tr>
                                 <tr>
                                    <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                                       <table class="clsTable01" width=100% align=center cols=2 cellpadding="0" cellspacing="0">
                                          <tr><td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Report Breaks&nbsp;</nobr></td></tr>
                                          <tr><td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_loff.gif" align=absmiddle onClick="removeBreakItems();"></nobr></td>
                                              <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_roff.gif" align=absmiddle onClick="selectBreakItems();"></nobr></td></tr>
                                       </table>
                                    </nobr></td>
                                    <td class="clsLabelBN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" id="sltReportBreak" name="sltReportBreak" style="width:300px" multiple size=5></select></nobr></td>
                                    <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                                       <table class="clsTable01" width=100% align=center cols=1 cellpadding="0" cellspacing="0">
                                          <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="upBreakItems();"></nobr></td></tr>
                                          <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="downBreakItems();"></nobr></td></tr>
                                       </table>
                                    </nobr></td>
                                 </tr>
                                 <tr>
                                    <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                                       <table class="clsTable01" width=100% align=center cols=2 cellpadding="0" cellspacing="0">
                                          <tr><td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Report Order&nbsp;</nobr></td></tr>
                                          <tr><td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_loff.gif" align=absmiddle onClick="removeOrderItems();"></nobr></td>
                                              <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_roff.gif" align=absmiddle onClick="selectOrderItems();"></nobr></td></tr>
                                       </table>
                                    </nobr></td>
                                    <td class="clsLabelBN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" id="sltReportOrder" name="sltReportOrder" style="width:300px" multiple size=5></select></nobr></td>
                                    <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                                       <table class="clsTable01" width=100% align=center cols=1 cellpadding="0" cellspacing="0">
                                          <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="upOrderItems();"></nobr></td></tr>
                                          <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="downOrderItems();"></nobr></td></tr>
                                       </table>
                                    </nobr></td>
                                 </tr>
                              </table>
                           </nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
            <table id="tabTerm" style="display:none;visibility:hidden" class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsTabB" align=center colspan=2 nowrap><nobr>&nbsp;Terms and Conditions&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Copy Report Group Terms and Conditions:&nbsp;
                     <input type="radio" name="sltCopyTerms"<%if objForm.Fields("DTA_CopyTerms").Value = "" or objForm.Fields("DTA_CopyTerms").Value = "N" then%> checked<%end if%> value="I" onClick="javascript:selectCopyTerms('N');">No&nbsp;
                     <input type="radio" name="sltCopyTerms"<%if objForm.Fields("DTA_CopyTerms").Value = "Y" then%> checked<%end if%> value="Y" onClick="javascript:selectCopyTerms('Y');">Yes&nbsp;
                  &nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
                     <textarea class="clsInputNN" id="txtReportTerm" name="txtReportTerm" style="width:700px;" rows="20" wrap="off"<%if objForm.Fields("DTA_CopyTerms").Value = "Y" then%>disabled="disabled"<%end if%>></textarea>
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
   <input type="hidden" name="DTA_ReportName" value="<%=replace(objForm.Fields("DTA_ReportName").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_ReportGrpId" value="<%=objForm.Fields("DTA_ReportGrpId").Value%>">
   <input type="hidden" name="DTA_PriceMdlId" value="<%=objForm.Fields("DTA_PriceMdlId").Value%>">
   <input type="hidden" name="DTA_MatlAlrtng" value="<%=objForm.Fields("DTA_MatlAlrtng").Value%>">
   <input type="hidden" name="DTA_AutoMatlUpdate" value="<%=objForm.Fields("DTA_AutoMatlUpdate").Value%>">
   <input type="hidden" name="DTA_EmailAddress" value="<%=replace(objForm.Fields("DTA_EmailAddress").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_Status" value="<%=objForm.Fields("DTA_Status").Value%>">
   <input type="hidden" name="DTA_CopyTerms" value="<%=objForm.Fields("DTA_CopyTerms").Value%>">
   <input type="hidden" name="INP_ReportGrpId" value="<%=objForm.Fields("DTA_ReportGrpId").Value%>">
   <input type="hidden" name="INP_PriceMdlId" value="<%=objForm.Fields("DTA_PriceMdlId").Value%>">
   <input type="hidden" name="INP_MatlAlrtng" value="<%=objForm.Fields("DTA_MatlAlrtng").Value%>">
   <input type="hidden" name="INP_AutoMatlUpdate" value="<%=objForm.Fields("DTA_AutoMatlUpdate").Value%>">
   <input type="hidden" name="INP_Status" value="<%=objForm.Fields("DTA_Status").Value%>">
   <input type="hidden" name="INP_CopyTerms" value="<%=objForm.Fields("DTA_CopyTerms").Value%>">
   <input type="hidden" name="DET_RepDatCount" value="">
   <input type="hidden" name="DET_RepBrkCount" value="">
   <input type="hidden" name="DET_RepOrdCount" value="">
   <input type="hidden" name="DET_RepTerCount" value="">
</form>
</body>
</html>