<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_StreamCode.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_StreamCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Stream code must be entered';
      }
      if (document.main.INP_StreamText.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Stream text must be entered';
      }
      strDetail = checkTasks();
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
   //////////////////////////////
   // Stream definition script //
   //////////////////////////////
   var cobjRuleTypes = new Array();
   var cobjRules = new Array();
   var cobjSelected = null;
   var cstrSelected = '';
   var cintSelected = 0;
   var cobjRow = null;
   var cstrMode = '';
   var cintInsert = -1;
   var cintNewId = 999000000;
   function loadTasks() {<%if objSelection.ListCount("RULE_TYPE") <> 0 then%><%for i = objSelection.ListLower("RULE_TYPE") to objSelection.ListUpper("RULE_TYPE")%>
      cobjRuleTypes[<%=i%>] = new clsRuleType('<%=objSelection.ListValue01("RULE_TYPE",i)%>','<%=replace(objSelection.ListValue02("RULE_TYPE",i), "'", "\'", 1, -1, 1)%>');<%next%><%end if%><%if objSelection.ListCount("RULE") <> 0 then%><%for i = objSelection.ListLower("RULE") to objSelection.ListUpper("RULE")%>
      cobjRules[<%=i%>] = new clsRule('<%=objSelection.ListValue01("RULE",i)%>','<%=replace(objSelection.ListValue02("RULE",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue03("RULE",i)%>','<%=replace(objSelection.ListValue04("RULE",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue05("RULE",i)%>','<%=objSelection.ListValue06("RULE",i)%>');<%next%><%end if%>
      var objTable = document.getElementById('tabRule');
      var objRow;
      var objCell;
      var strSavId = 'STR';
      for (var i=0;i<cobjRules.length;i++) {
         if (cobjRules[i].rulid != strSavId) {
            objRow = objTable.insertRow(-1);
            objRow.setAttribute('rultyp','RH');
            objRow.setAttribute('rulid',cobjRules[i].rulid);
            objRow.setAttribute('rulnam',cobjRules[i].rulnam);
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            objCell.innerText = 'Rule';
            objCell.onclick = function() {selectRule(this);};
            objCell.className = 'clsListB';
            objCell = objRow.insertCell(1);
            objCell.colSpan = 1;
            objCell.innerText = cobjRules[i].rulnam;
            objCell.className = 'clsLabelFB';
            strSavId = cobjRules[i].rulid;
         }
         if (cobjRules[i].typid != '') {
            objRow = objTable.insertRow(-1);
            objRow.setAttribute('rultyp','RD');
            objRow.setAttribute('rulid',cobjRules[i].rulid);
            objRow.setAttribute('typid',cobjRules[i].typid);
            objRow.setAttribute('rulval',cobjRules[i].rulval);
            objRow.setAttribute('rulnot',cobjRules[i].rulnot);
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            objCell.innerText = 'Detail';
            objCell.onclick = function() {selectDetail(this);};
            objCell.className = 'clsList';
            objCell = objRow.insertCell(1);
            objCell.colSpan = 1;
            objCell.innerText = cobjRules[i].typnam+' ('+cobjRules[i].rulval+') - ';
            if (cobjRules[i].rulnot == 'F') {
               objCell.innerText = objCell.innerText+'Standard rule';
            } else {
               objCell.innerText = objCell.innerText+'Rule NOT test applied';
            }
            objCell.className = 'clsLabelFN';
         }
      }
      var objSltRuleType = document.getElementById('sltRuleType');
      objSltRuleType.options.length = 0;
      objSltRuleType.selectedIndex = -1;
      for (var i=0;i<cobjRuleTypes.length;i++) {
         objSltRuleType.options[i] = new Option(cobjRuleTypes[i].typnam,cobjRuleTypes[i].typid);
         objSltRuleType.options[i].setAttribute('typid',cobjRuleTypes[i].typid);
         objSltRuleType.options[i].setAttribute('typnam',cobjRuleTypes[i].typnam);
      }
   }
   function clsRuleType(strTypId,strTypNam) {
      this.typid = strTypId;
      this.typnam = strTypNam;
   }
   function clsRule(strRulId,strRulNam,strTypId,strTypNam,strRulVal,strRulNot) {
      this.rulid = strRulId;
      this.rulnam = strRulNam;
      this.typid = strTypId;
      this.typnam = strTypNam;
      this.rulval = strRulVal;
      this.rulnot = strRulNot;
   }
   function selectTask(objSelected) {
      if (cobjSelected) {
         if (cobjSelected.className == 'clsListX') {
            cobjSelected.className = 'clsList';
         } else {
            cobjSelected.className = 'clsListB';
         }
      }
      cobjSelected = objSelected;
      cobjSelected.className = 'clsListBX';
      cstrSelected = 'RH';
      cintSelected = cobjSelected.parentNode.rowIndex;
      cobjRow = document.getElementById('tabRule').rows[cintSelected];
   }
   function selectEvent(objSelected) {
      if (cobjSelected) {
         if (cobjSelected.className == 'clsListX') {
            cobjSelected.className = 'clsList';
         } else {
            cobjSelected.className = 'clsListB';
         }
      }
      cobjSelected = objSelected;
      cobjSelected.className = 'clsListX';
      cstrSelected = 'RD';
      cintSelected = cobjSelected.parentNode.rowIndex;
      cobjRow = document.getElementById('tabRule').rows[cintSelected];
   }
   function updateTask() {
      if (cobjSelected == null) {
         return;
      }
      cstrMode = 'UPD';
      if (cstrSelected == 'RH') {
         document.getElementById('inpRuleName').value = cobjRow.getAttribute('rulnam');
         var objDspList = document.getElementById('dspList');
         var objDspRule = document.getElementById('dspRule');
         var objDspDetail = document.getElementById('dspDetail');
         objDspList.style.display = 'none';
         objDspList.style.visibility = 'hidden';
         objDspRule.style.display = 'block';
         objDspRule.style.visibility = 'visible'
         objDspDetail.style.display = 'none';
         objDspDetail.style.visibility = 'hidden';
         document.getElementById('inpRuleName').focus();
      }
      if (cstrSelected == 'RD') {
         var objSltRuleType = document.getElementById('sltRuleType');
         objSltRuleType.selectedIndex = -1;
         for (var i=0;i<objSltRuleType.length;i++) {
            if (objSltRuleType.options[i].getAttribute('typid') == cobjRow.getAttribute('typid')) {
               objSltRuleType.selectedIndex = i;
            }
         }
         document.getElementById('sltRuleValue').selectedIndex = -1;
         if (cobjRow.getAttribute('rulnot') == 'F') {
            document.getElementById('sltRuleNot').selectedIndex = 0;
         } else {
            document.getElementById('sltRuleNot').selectedIndex = 1;
         }
         doActivityStart(document.body);
         getRuleValues(cobjRow.getAttribute('typid'));
         for (var i=0;i<document.getElementById('sltRuleValue').options.length;i++) {
            if (document.getElementById('sltRuleValue').options[i].value == cobjRow.getAttribute('rulval')) {
               document.getElementById('sltRuleValue').selectedIndex = i;
               break;
            }
         }
         var objDspList = document.getElementById('dspList');
         var objDspRule = document.getElementById('dspRule');
         var objDspDetail = document.getElementById('dspDetail');
         objDspList.style.display = 'none';
         objDspList.style.visibility = 'hidden';
         objDspRule.style.display = 'none';
         objDspRule.style.visibility = 'hidden'
         objDspDetail.style.display = 'block';
         objDspDetail.style.visibility = 'visible';
         document.getElementById('sltRuleType').focus();
      }
   }
   function deleteTask() {
      if (cobjSelected == null) {
         return;
      }
      var objTable = document.getElementById('tabRule');
      if (cstrSelected == 'RH') {
         for (var i=objTable.rows.length-1;i>=0;i--) {
            if (objTable.rows[i].getAttribute('rulid') == cobjRow.getAttribute('rulid')) {
               objTable.deleteRow(i);
            }
         }
      } else {
         objTable.deleteRow(cintSelected);
      }
   }
   function cancelTask() {
      var objDspList = document.getElementById('dspList');
      var objDspRule = document.getElementById('dspRule');
      var objDspDetail = document.getElementById('dspDetail');
      objDspList.style.display = 'block';
      objDspList.style.visibility = 'visible';
      objDspRule.style.display = 'none';
      objDspRule.style.visibility = 'hidden'
      objDspDetail.style.display = 'none';
      objDspDetail.style.visibility = 'hidden';
   }
   function addTask() {
      cstrMode = 'ADD';
      document.getElementById('inpRuleName').value = '';
      var objDspList = document.getElementById('dspList');
      var objDspRule = document.getElementById('dspRule');
      var objDspDetail = document.getElementById('dspDetail');
      objDspList.style.display = 'none';
      objDspList.style.visibility = 'hidden';
      objDspRule.style.display = 'block';
      objDspRule.style.visibility = 'visible'
      objDspDetail.style.display = 'none';
      objDspDetail.style.visibility = 'hidden';
      document.getElementById('inpRuleName').focus();
   }
   function acceptTask() {
      var objTable;
      var objRow;
      var objCell;
      objTable = document.getElementById('tabRule');
      if (cstrMode == 'ADD') {
         cintNewId++;
         objRow = objTable.insertRow(-1);
         objRow.setAttribute('rultyp','RH');
         objRow.setAttribute('rulid',cintNewId);
         objRow.setAttribute('rulnam',document.getElementById('inpRuleName').value);
         objCell = objRow.insertCell(0);
         objCell.colSpan = 1;
         objCell.innerText = 'Rule';
         objCell.onclick = function() {selectRule(this);};
         objCell.className = 'clsListB';
         objCell = objRow.insertCell(1);
         objCell.colSpan = 3;
         objCell.innerText = document.getElementById('inpRuleName').value;
         objCell.className = 'clsLabelFB';
      } else {
         objRow = objTable.rows[cintSelected];
         objRow.setAttribute('rulnam',document.getElementById('inpRuleName').value);
         objRow.cells(1).innerText = document.getElementById('inpRuleName').value;
      }
      var objDspList = document.getElementById('dspList');
      var objDspRule = document.getElementById('dspRule');
      var objDspDetail = document.getElementById('dspDetail');
      objDspList.style.display = 'block';
      objDspList.style.visibility = 'visible';
      objDspRule.style.display = 'none';
      objDspRule.style.visibility = 'hidden'
      objDspDetail.style.display = 'none';
      objDspDetail.style.visibility = 'hidden';
   }
   function addEvent() {
      if (cobjSelected == null) {
         return;
      }
      if (cstrSelected != 'RH') {
         return;
      }
      cstrMode = 'ADD';
      var objWork = new Array();
      var intIndex = 0;
      var bolFound = false;
      var objTable = document.getElementById('tabRule');
      if (cintSelected == objTable.rows.length-1) {
         cintInsert = -1;
      } else {
         cintInsert = cintSelected;
         for (var i=cintSelected+1;i<objTable.rows.length;i++) {
            if (objTable.rows[i].getAttribute('rulid') == cobjRow.getAttribute('rulid')) {
               cintInsert = i;
            }
         }
         cintInsert++;
      }
      document.getElementById('sltRuleType').selectedIndex = -1;
      document.getElementById('sltRuleValue').selectedIndex = -1;
      document.getElementById('sltRuleNot').selectedIndex = 0;
      var objDspList = document.getElementById('dspList');
      var objDspRule = document.getElementById('dspRule');
      var objDspDetail = document.getElementById('dspDetail');
      objDspList.style.display = 'none';
      objDspList.style.visibility = 'hidden';
      objDspRule.style.display = 'none';
      objDspRule.style.visibility = 'hidden'
      objDspDetail.style.display = 'block';
      objDspDetail.style.visibility = 'visible';
      document.getElementById('sltRuleType').focus();
   }
   function acceptEvent() {
      var objTable;
      var objRow;
      var objCell;
      objTable = document.getElementById('tabRule');
      if (document.getElementById('sltRuleType').selectedIndex == -1) {
         alert('Rule type must be selected');
         return;
      }
      if (document.getElementById('sltRuleValue').selectedIndex == -1) {
         alert('Rule value be selected');
         return;
      }
      if (document.getElementById('sltRuleNot').selectedIndex == -1) {
         alert('Rule not be selected');
         return;
      }
      var bolFound = false;
      for (var i=0;i<objTable.rows.length;i++) {
         if (objTable.rows[i].getAttribute('rultyp') == 'RD' && objTable.rows[i].getAttribute('rulid') == cobjRow.getAttribute('rulid')) {
            if ((cstrMode == 'ADD' || cintSelected != i) && objTable.rows[i].getAttribute('typid') == document.getElementById('sltRuleType').options[document.getElementById('sltRuleType').selectedIndex].getAttribute('typid')) {
               bolFound = true;
               break;
            }
         }
      }
      if (bolFound == true) {
         alert('Rule type has already been selected for this rule');
         return;
      }
      if (cstrMode == 'ADD') {
         objRow = objTable.insertRow(cintInsert);
         objRow.setAttribute('rultyp','RD');
         objRow.setAttribute('rulid',objTable.rows[cintSelected].getAttribute('rulid'));
         objRow.setAttribute('typid',document.getElementById('sltRuleType').options[document.getElementById('sltRuleType').selectedIndex].getAttribute('typid'));
         objRow.setAttribute('rulval',document.getElementById('sltRuleValue').options[document.getElementById('sltRuleValue').selectedIndex].value);
         objRow.setAttribute('rulnot',document.getElementById('sltRuleNot').options[document.getElementById('sltRuleNot').selectedIndex].value);
         objCell = objRow.insertCell(0);
         objCell.colSpan = 1;
         objCell.innerText = 'Detail';
         objCell.onclick = function() {selectDetail(this);};
         objCell.className = 'clsList';
         objCell = objRow.insertCell(1);
         objCell.colSpan = 1;
         objCell.innerText = document.getElementById('sltRuleType').options[document.getElementById('sltRuleType').selectedIndex].getAttribute('typnam')+' ('+document.getElementById('sltRuleValue').options[document.getElementById('sltRuleValue').selectedIndex].value+') - ';
         if (document.getElementById('sltRuleNot').selectedIndex == 0) {
            objCell.innerText = objCell.innerText+'Standard rule';
         } else {
            objCell.innerText = objCell.innerText+'Rule NOT test applied';
         }
         objCell.className = 'clsLabelFN';
      } else {
         objRow = objTable.rows[cintSelected];
         objRow.setAttribute('typid',document.getElementById('sltRuleType').options[document.getElementById('sltRuleType').selectedIndex].getAttribute('typid'));
         objRow.setAttribute('rulval',document.getElementById('sltRuleValue').options[document.getElementById('sltRuleValue').selectedIndex].value);
         objRow.setAttribute('rulnot',document.getElementById('sltRuleNot').options[document.getElementById('sltRuleNot').selectedIndex].value);
         objRow.cells(1).innerText = document.getElementById('sltRuleType').options[document.getElementById('sltRuleType').selectedIndex].getAttribute('typnam')+' ('+document.getElementById('sltRuleValue').options[document.getElementById('sltRuleValue').selectedIndex].value+') - ';
         if (document.getElementById('sltRuleNot').selectedIndex == 0) {
            objRow.cells(1).innerText = objRow.cells(1).innerText+'Standard rule';
         } else {
            objRow.cells(1).innerText = objRow.cells(1).innerText+'Rule NOT test applied';
         }
      }
      var objDspList = document.getElementById('dspList');
      var objDspRule = document.getElementById('dspRule');
      var objDspDetail = document.getElementById('dspDetail');
      objDspList.style.display = 'block';
      objDspList.style.visibility = 'visible';
      objDspRule.style.display = 'none';
      objDspRule.style.visibility = 'hidden'
      objDspDetail.style.display = 'none';
      objDspDetail.style.visibility = 'hidden';
   }
   function checkTasks() {
      var strReturn = '';
      var objHidden = null;
      var bolFirst = true;
      var bolFound = false;
      var intCount = 0;
      var objTable = document.getElementById('tabRule');
      for (var i=0;i<objTable.rows.length;i++) {
         if (objTable.rows[i].getAttribute('rultyp') == 'RH') {
            if (!bolFirst) {
               if (intCount == 0) {
                  bolFound = true;
               }
            }
            bolFirst = false;
            intCount = 0;
         } else if (objTable.rows[i].getAttribute('rultyp') == 'RD') {
            intCount++
         }
      }
      if (!bolFirst) {
         if (intCount == 0) {
            bolFound = true;
         }
      }
      if (bolFound) {
         strReturn = 'All rules must have at least one detail defined';
      }
      for (var i=0;i<objTable.rows.length;i++) {
         if (objTable.rows[i].getAttribute('rultyp') == 'RH') {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepRulTyp'+(i+1));
            objHidden.setAttribute('value',objTable.rows[i].getAttribute('rultyp'));
            document.forms['main'].appendChild(objHidden);
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepRulNam'+(i+1));
            objHidden.setAttribute('value',objTable.rows[i].getAttribute('rulnam'));
            document.forms['main'].appendChild(objHidden);
         } else if (objTable.rows[i].getAttribute('rultyp') == 'RD') {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepRulTyp'+(i+1));
            objHidden.setAttribute('value',objTable.rows[i].getAttribute('rultyp'));
            document.forms['main'].appendChild(objHidden);
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepTypId'+(i+1));
            objHidden.setAttribute('value',objTable.rows[i].getAttribute('typid'));
            document.forms['main'].appendChild(objHidden);
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepRulVal'+(i+1));
            objHidden.setAttribute('value',objTable.rows[i].getAttribute('rulval'));
            document.forms['main'].appendChild(objHidden);
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepRulNot'+(i+1));
            objHidden.setAttribute('value',objTable.rows[i].getAttribute('rulnot'));
            document.forms['main'].appendChild(objHidden);
         }
      }
      document.getElementById('DET_RepRulCount').value = objTable.rows.length;
      return strReturn;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_stream_configuration_define_help.htm');parent.setHeading('<%=strHeading%> - Define Stream');parent.showContent();loadTasks();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table id="dspList" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_StreamCode" size="32" maxlength="32" value="<%=objForm.Fields("DTA_StreamCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_StreamText" size="128" maxlength="128" value="<%=replace(objForm.Fields("DTA_StreamText").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltJStreamStatus" onChange="selectStatus(this);">
               <option value="0"<%if objForm.Fields("DTA_StreamStatus").Value = "0" or objForm.Fields("DTA_StreamStatus").Value = "" then%> selected<%end if%>>Inactive
               <option value="1"<%if objForm.Fields("DTA_StreamStatus").Value = "1" then%> selected<%end if%>>Active
            </select>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addRule();">&nbsp;Add Rule&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addDetail();">&nbsp;Add Detail&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:updateRule();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:deleteRule();">&nbsp;Delete&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="tabRule" class="clsTableBody" cols=2 align=left cellpadding="2" cellspacing="1"></table>
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
   <table id="dspRule" class="clsGrid02" style="display:none;visibility:hidden" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Rule Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input id="inpRuleName" class="clsInputNN" type="text" size="100" maxlength="200" value="" onFocus="setSelect(this);">
         </nobr></td>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:cancelRule();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:acceptRule();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspDetail" class="clsGrid02" style="display:none;visibility:hidden" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Rule Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="sltRuleType" onChange="selectRuleType(this);"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Rule Value:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="sltRuleValue"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Rule Value:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="sltRuleNot">
               <option value="F">Standard Rule
               <option value="T">Rule NOT test applied
            </select>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:cancelRule();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:acceptDetail();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_StreamCode" value="<%=objForm.Fields("DTA_StreamCode").Value%>">
   <input type="hidden" name="DTA_StreamName" value="<%=replace(objForm.Fields("DTA_StreamName").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_StreamStatus" value="<%=objForm.Fields("DTA_StreamStatus").Value%>">
   <input type="hidden" name="INP_StreamStatus" value="<%=objForm.Fields("DTA_StreamStatus").Value%>">
   <input type="hidden" name="DET_StreamCount" value="">
</form>
</body>
</html>