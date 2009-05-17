<script language="javascript">
<!--
   ///////////////////////////
   // Select Rule Functions //
   ///////////////////////////
   var cstrSearchEntity;
   var cobjSelectData;
   var cstrSelectMode;
   var cstrSelectGrpCde;
   var cstrSelectTabCde;
   var cstrSelectFldCde;
   var cstrSelectFldTxt;
   var cstrSelectInpLen;
   var cstrSelectRulTyp;
   var cstrSelectRulCde;
   var cintSelectRow;
   function clsSltRule() {
      this.grpcde = '';
      this.tabcde = '';
      this.fldcde = '';
      this.fldtxt = '';
      this.rultyp = '';
      this.rulcde = '';
      this.mixpct = '';
      this.valary = new Array();
   }
   function clsSltValue(strValCde,strValTxt,strValPct) {
      this.valcde = strValCde;
      this.valtxt = strValTxt;
      this.valpct = strValPct;
   }
   function initSelect(strHeading) {
      cobjScreens[cobjScreens.length] = new clsScreen('dspSltFeld','hedSltFeld');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSltList','hedSltList');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSltNumb','hedSltNumb');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSltText','hedSltText');
      for (var i=0;i<cobjScreens.length;i++) {
         if (cobjScreens[i].scrnam == 'dspSltFeld') {
            cobjScreens[i].hedtxt = strHeading+' Selection Fields';
         } else if (cobjScreens[i].scrnam == 'dspSltList') {
            cobjScreens[i].hedtxt = strHeading+' Selection List Rule';
         } else if (cobjScreens[i].scrnam == 'dspSltNumb') {
            cobjScreens[i].hedtxt = strHeading+' Selection Number Rule';
         } else if (cobjScreens[i].scrnam == 'dspSltText') {
            cobjScreens[i].hedtxt = strHeading+' Selection Text Rule';
         }
      }
      cobjSelectData = new Array();
   }
   function startSltInstance(strEntity) {
      cstrSelectEntity = strEntity;
   }
   function loadSltData() {
      var objTable = document.getElementById('tabSltRule');
      var objFont = document.getElementById('fntSltRule');
      var objRow;
      var objCell;
      var bolFound = false;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      for (var i=0;i<cobjSelectData.length;i++) {
         if (cobjSelectData[i].tabcde == '*GROUP') {
            objRow = objTable.insertRow(-1);
            objRow.setAttribute('grpcde',cobjSelectData[i].grpcde);
            objRow.setAttribute('tabcde',cobjSelectData[i].tabcde);
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            objCell.innerHTML = '<a class="clsSelect" onClick="doSltRuleAddRule(\''+objRow.rowIndex+'\');">Add Rule</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleDelGroup(\''+objRow.rowIndex+'\');">Delete</a>';
            objCell.className = 'clsLabelFN';
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(1);
            objCell.colSpan = 2;
            objCell.innerText = '';
            if (!bolFound) {
               objCell.innerText = 'SELECTION GROUP - WHERE';
            } else {
               objCell.innerText = 'SELECTION GROUP - OR';
            }
            bolFound = true;
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
         } else {
            objRow = objTable.insertRow(-1);
            objRow.setAttribute('grpcde',cobjSelectData[i].grpcde);
            objRow.setAttribute('tabcde',cobjSelectData[i].tabcde);
            objRow.setAttribute('fldcde',cobjSelectData[i].fldcde);
            objRow.setAttribute('fldtxt',cobjSelectData[i].fldtxt);
            objRow.setAttribute('rultyp',cobjSelectData[i].rultyp);
            objRow.setAttribute('rulcde',cobjSelectData[i].rulcde);
            var strText = '*NONE';
            if (cobjSelectData[i].rulcde != '') {
               strText = '';
               var objValues = new Array();
               for (var j=0;j<cobjSelectData[i].valary.length;j++) {
                  objValues[j] = new clsSltValue(cobjSelectData[i].valary[j].valcde,cobjSelectData[i].valary[j].valtxt,cobjSelectData[i].valary[j].valpct);
                  if (j == 0) {
                     if (cobjSelectData[i].rultyp == '*TEXT') {
                        strText = strText+'"'+cobjSelectData[i].valary[j].valtxt+'"';
                     } else {
                        strText = strText+cobjSelectData[i].valary[j].valtxt;
                     }
                  } else {
                     if (cobjSelectData[i].rultyp == '*TEXT') {
                        strText = strText+', "'+cobjSelectData[i].valary[j].valtxt+'"';
                     } else {
                        strText = strText+', '+cobjSelectData[i].valary[j].valtxt;
                     }
                  }
               }
               objRow.setAttribute('valary',objValues);
            }
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            objCell.innerHTML = '<a class="clsSelect" onClick="doSltRuleUpdRule(\''+objRow.rowIndex+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleDelRule(\''+objRow.rowIndex+'\');">Delete</a>';
            objCell.className = 'clsLabelFN';
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(1);
            objCell.colSpan = 1;
            objCell.innerText = cobjSelectData[i].fldtxt+' ('+cobjSelectData[i].rulcde+')';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(2);
            objCell.colSpan = 1;
            objCell.innerText = strText;
            objCell.className = 'clsLabelFN';
         }
      }
      objTable.style.display = 'block';
      objFont.style.display = 'none';
      if (objTable.rows.length == 0) {
         objTable.style.display = 'none';
         objFont.style.display = 'block';
      }
   }
   function updateSltData() {
      var objTable = document.getElementById('tabSltRule');
      var objFont = document.getElementById('fntSltRule');
      var objValues;
      var bolFound = false;
      cobjSelectData.length = 0;
      for (var i=0;i<objTable.rows.length;i++) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('tabcde') == '*GROUP') {
            objRow.cells[0].innerHTML = '<a class="clsSelect" onClick="doSltRuleAddRule(\''+objRow.rowIndex+'\');">Add Rule</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleDelGroup(\''+objRow.rowIndex+'\');">Delete</a>';
            if (!bolFound) {
               objRow.cells[1].innerText = 'SELECTION GROUP - WHERE';
            } else {
               objRow.cells[1].innerText = 'SELECTION GROUP - OR';
            }
            bolFound = true;
            cobjSelectData[i] = new clsSltRule();
            cobjSelectData[i].grpcde = objRow.getAttribute('grpcde');
            cobjSelectData[i].tabcde = objRow.getAttribute('tabcde');
         } else {
            objRow.cells[0].innerHTML = '<a class="clsSelect" onClick="doSltRuleUpdRule(\''+objRow.rowIndex+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleDelRule(\''+objRow.rowIndex+'\');">Delete</a>';
            cobjSelectData[i] = new clsSltRule();
            cobjSelectData[i].grpcde = objRow.getAttribute('grpcde');
            cobjSelectData[i].tabcde = objRow.getAttribute('tabcde');
            cobjSelectData[i].fldcde = objRow.getAttribute('fldcde');
            cobjSelectData[i].fldtxt = objRow.getAttribute('fldtxt');
            cobjSelectData[i].rultyp = objRow.getAttribute('rultyp');
            cobjSelectData[i].rulcde = objRow.getAttribute('rulcde');
            if (cobjSelectData[i].rulcde != '') {
               cobjSelectData[i].valary.length = 0;
               objValues = objRow.getAttribute('valary');
               for (var j=0;j<objValues.length;j++) {
                  cobjSelectData[i].valary[j] = new clsSltValue(objValues[j].valcde,objValues[j].valtxt,objValues[j].valpct);
               }
            }
         }
      }
      objTable.style.display = 'block';
      objFont.style.display = 'none';
      if (objTable.rows.length == 0) {
         objTable.style.display = 'none';
         objFont.style.display = 'block';
      }
   }
   function addSltData(objRule) {
      var objWork = new Array();
      var bolGroup = false;
      var bolInsert = false;
      var intIndex = 0
      for (var i=0;i<cobjSelectData.length;i++) {
         if (cobjSelectData[i].grpnam != cstrSelectGrpCde) {
            if (bolGroup && !bolInsert) {
               bolInsert = true;
               objWork[intIndex] = objRule;
               intIndex++;
            }
            objWork[intIndex] = cobjSelectData[i];
            intIndex++;
         } else {
            bolGroup = true;
            objWork[intIndex] = cobjSelectData[i];
            intIndex++;
         }
      }
      if (!bolInsert) {
         objWork[intIndex] = objRule;
      }
      cobjSelectData.length = 0;
      for (var i=0;i<objWork.length;i++) {
         cobjSelectData[i] = objWork[i];
      }
   }
   function doSltRuleAddGroup() {
      var objTable = document.getElementById('tabSltRule');
      var objRow;
      var objCell;
      var strGroup;
      objRow = objTable.insertRow(-1);
      strGroup = '*GROUP'+objRow.rowIndex;
      objRow.setAttribute('grpcde',strGroup);
      objRow.setAttribute('tabcde','*GROUP');
      objCell = objRow.insertCell(0);
      objCell.colSpan = 1;
      objCell.innerHTML = '';
      objCell.className = 'clsLabelFN';
      objCell.style.whiteSpace = 'nowrap';
      objCell = objRow.insertCell(1);
      objCell.colSpan = 1;
      objCell.innerText = '';
      objCell.className = 'clsLabelFB';
      objCell.style.whiteSpace = 'nowrap';
      updateSltData();


      displayScreen('dspSltGrop');
      document.getElementById('SGR_MixPcnt').focus();


   }
   function doSltRuleAddRule(intRow) {
      var objTable = document.getElementById('tabSltRule');
      cstrSelectGrpCde = objTable.rows[intRow].getAttribute('grpcde');
      doActivityStart(document.body);
      window.setTimeout('requestSltFeldList();',10);
   }
   function doSltRuleDelGroup(intRow) {
      var objTable = document.getElementById('tabSltRule');
      var strGroup = objTable.rows[intRow].getAttribute('grpcde');
      var objRow;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('grpcde') == strGroup) {
            objTable.deleteRow(i);
         }
      }
      updateSltData();
   }
   function doSltRuleUpdRule(intRow) {
      var objTable = document.getElementById('tabSltRule');
      cintSelectRow = intRow;
      cstrSelectGrpCde = cobjSelectData[cintSelectRow].grpcde;
      cstrSelectTabCde = cobjSelectData[cintSelectRow].tabcde;
      cstrSelectFldCde = cobjSelectData[cintSelectRow].fldcde;
      cstrSelectRulTyp = cobjSelectData[cintSelectRow].rultyp;
      cstrSelectRulCde = cobjSelectData[cintSelectRow].rulcde;
      doActivityStart(document.body);
      window.setTimeout('requestSltFeldUpdate();',10);
   }
   function doSltRuleDelRule(intRow) {
      var objTable = document.getElementById('tabSltRule');
      objTable.deleteRow(intRow);
      updateSltData();
   }
   function doSltRuleSelect() {
      doSltSlctSelect();
   }
   ////////////////////////////
   // Select Group Functions //
   ////////////////////////////
   function doSltGropCancel() {
      displayScreen('dspSltRule');
   }
   function doSltGropAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('SGR_MixPcnt').value <= 0 || document.getElementById('SGR_MixPcnt').value > 100) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection group percentage must be in the range 1 to 100';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      displayScreen('dspSltRule');
      var objTable = document.getElementById('tabSltRule');
      var objRow;
      var objCell;
      var strGroup;
      objRow = objTable.insertRow(-1);
      strGroup = '*GROUP'+objRow.rowIndex;
      objRow.setAttribute('grpcde',strGroup);
      objRow.setAttribute('tabcde','*GROUP');
      objRow.setAttribute('mixpct',document.getElementById('SGR_MixPcnt').value);
      objCell = objRow.insertCell(0);
      objCell.colSpan = 1;
      objCell.innerHTML = '';
      objCell.className = 'clsLabelFN';
      objCell.style.whiteSpace = 'nowrap';
      objCell = objRow.insertCell(1);
      objCell.colSpan = 1;
      objCell.innerText = '';
      objCell.className = 'clsLabelFB';
      objCell.style.whiteSpace = 'nowrap';
      updateSltData();
   }
   ////////////////////////////
   // Select Field Functions //
   ////////////////////////////
   function doSltFeldCancel() {
      displayScreen('dspSltRule');
   }
   function doSltFeldSelect(intRow) {
      var objTable = document.getElementById('tabSltFeld');
      objFieldRow = objTable.rows[intRow];
      var bolFound = false;
      for (var i=0;i<cobjSelectData.length;i++) {
         if (cobjSelectData[i].grpcde == cstrSelectGrpCde && 
             cobjSelectData[i].tabcde == objFieldRow.getAttribute('tabcde') && 
             cobjSelectData[i].fldcde == objFieldRow.getAttribute('fldcde')) {
            bolFound = true;
            break;
         }
      }
      if (bolFound) {
         alert('Field already selected in rule group');
         return;
      }
      cintSelectRow = -1;
      cstrSelectTabCde = objFieldRow.getAttribute('tabcde');
      cstrSelectFldCde = objFieldRow.getAttribute('fldcde');
      cstrSelectFldTxt = objFieldRow.getAttribute('fldtxt');
      cstrSelectInpLen = objFieldRow.getAttribute('inplen');
      cstrSelectRulTyp = objFieldRow.getAttribute('rultyp');
      cstrSelectRulCde = '';
      doActivityStart(document.body);
      window.setTimeout('requestSltFeldUpdate();',10);
   }
   function requestSltFeldList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTFLD" ENTCDE="'+cstrSelectEntity+'" TESFLG="1"/>';
      doPostRequest('<%=strBase%>pts_sys_fld_list.asp',function(strResponse) {checkSltFeldList(strResponse);},false,streamXML(strXML));
   }
   function checkSltFeldList(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var objDocument = loadXML(strResponse.substring(3,strResponse.length));
         if (objDocument == null) {return;}
         var strMessage = '';
         var objElements = objDocument.documentElement.childNodes;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'ERROR') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + objElements[i].getAttribute('ERRTXT');
            }
         }
         if (strMessage != '') {
            alert(strMessage);
            return;
         }
         displayScreen('dspSltFeld');
         var objTable = document.getElementById('tabSltFeld');
         for (var i=objTable.rows.length-1;i>=0;i--) {
            objTable.deleteRow(i);
         }
         var objRow;
         var objCell;
         var strTabCode;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TABLE') {
               objRow = objTable.insertRow(-1);
               objCell = objRow.insertCell(0);
               objCell.colSpan = 2;
               objCell.innerText = objElements[i].getAttribute('TABTXT');
               objCell.className = 'clsLabelFB';
               objCell.style.whiteSpace = 'nowrap';
               strTabCode = objElements[i].getAttribute('TABCDE');
            } else if (objElements[i].nodeName == 'FIELD') {
               objRow = objTable.insertRow(-1);
               objRow.setAttribute('tabcde',strTabCode);
               objRow.setAttribute('fldcde',objElements[i].getAttribute('FLDCDE'));
               objRow.setAttribute('fldtxt',objElements[i].getAttribute('FLDTXT'));
               objRow.setAttribute('inplen',objElements[i].getAttribute('INPLEN'));
               objRow.setAttribute('rultyp',objElements[i].getAttribute('RULTYP'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '<a class="clsSelect" onClick="doSltFeldSelect(\''+objRow.rowIndex+'\');">Select</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('FLDTXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
      }
   }
   function requestSltFeldUpdate() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTRUL"'+' TESFLG="1" TABCDE="'+cstrSelectTabCde+'" FLDCDE="'+cstrSelectFldCde+'"/>';
      doPostRequest('<%=strBase%>pts_sys_rul_list.asp',function(strResponse) {checkSltFeldUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkSltFeldUpdate(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var objDocument = loadXML(strResponse.substring(3,strResponse.length));
         if (objDocument == null) {return;}
         var strMessage = '';
         var objElements = objDocument.documentElement.childNodes;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'ERROR') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + objElements[i].getAttribute('ERRTXT');
            }
         }
         if (strMessage != '') {
            alert(strMessage);
            return;
         }
         if (cstrSelectRulTyp != '*NUMBER' && cstrSelectRulTyp != '*TEXT') {
            document.getElementById('subSltList').innerText = cstrSelectFldTxt;
            var objSelRulCode = document.getElementById('SEL_RulCode');
            var objSelRulValue = document.getElementById('SEL_RulValue');
            var objSelSelValue = document.getElementById('SEL_SelValue');
            objSelRulCode.options.length = 0;
            objSelRulCode.selectedIndex = 1;
            objSelRulValue.options.length = 0;
            objSelRulValue.selectedIndex = -1;
            objSelSelValue.options.length = 0;
            objSelSelValue.selectedIndex = -1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSelRulCode.options[objSelRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSelectRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSelRulCode.options[objSelRulCode.options.length-1].selected = true;
                  }
               } else if (objElements[i].nodeName == 'VALUE') {
                  objSelRulValue.options[objSelRulValue.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
               }
            }
            if (cintSelectRow != -1) {
               var objValues = cobjSelectData[cintSelectRow].valary;
               for (var i=0;i<objValues.length;i++) {
                  objSelSelValue.options[i] = new Option(objValues[i].valtxt,objValues[i].valcde);
               }
            }
            displayScreen('dspSltList');
            objSelRulCode.focus();
         } else if (cstrSelectRulTyp == '*NUMBER') {
            document.getElementById('subSltNumb').innerText = cstrSelectFldTxt;
            var objSenRulCode = document.getElementById('SEN_RulCode');
            var objSenSelValue = document.getElementById('SEN_SelValue');
            objSenRulCode.options.length = 0;
            objSenRulCode.selectedIndex = 1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSenRulCode.options[objSenRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSelectRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSenRulCode.options[objSenRulCode.options.length-1].selected = true;
                  }
               }
            }
            objSenSelValue.size = cstrSelectInpLen;
            objSenSelValue.maxLength = cstrSelectInpLen;
            objSenSelValue.value = '';
            if (cintSelectRow != -1) {
               var objValues = cobjSelectData[cintSelectRow].valary;
               if (objValues.length != 0) {
                  objSenSelValue.value = objValues[0].valtxt;
               }
            }
            displayScreen('dspSltNumb');
            objSenRulCode.focus();
         } else if (cstrSelectRulTyp == '*TEXT') {
            document.getElementById('subSltText').innerText = cstrSelectFldTxt;
            var objSetRulCode = document.getElementById('SET_RulCode');
            var objSetSelValue = document.getElementById('SET_SelValue');
            objSetRulCode.options.length = 0;
            objSetRulCode.selectedIndex = 1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSetRulCode.options[objSetRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSelectRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSetRulCode.options[objSetRulCode.options.length-1].selected = true;
                  }
               }
            }
            objSetSelValue.size = cstrSelectInpLen;
            objSetSelValue.maxLength = cstrSelectInpLen;
            objSetSelValue.value = '';
            if (cintSelectRow != -1) {
               var objValues = cobjSelectData[cintSelectRow].valary;
               if (objValues.length != 0) {
                  objSetSelValue.value = objValues[0].valtxt;
               }
            }
            displayScreen('dspSltText');
            objSetRulCode.focus();
         } else {
            alert('Unknown Rule Type ('+cstrSelectRulTyp+')');
         }
      }
   }
   ///////////////////////////
   // Select List Functions //
   ///////////////////////////
   function doSltListCancel() {
      displayScreen('dspSltRule');
   }
   function doSltListAccept() {
      if (!processForm()) {return;}
      var objSelRulCode = document.getElementById('SEL_RulCode');
      var objSelSelValue = document.getElementById('SEL_SelValue');
      var strMessage = '';
      if (objSelRulCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection rule must be selected';
      }
      if (objSelSelValue.options.length == 0) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'At least one rule value must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintSelectRow != -1) {
         cobjSelectData[cintSelectRow].rulcde = objSelRulCode[objSelRulCode.selectedIndex].value;
         var objValues = cobjSelectData[cintSelectRow].valary;
         objValues.length = 0;
         for (var i=0;i<objSelSelValue.options.length;i++) {
            objValues[i] = new clsSltValue(objSelSelValue[i].value,objSelSelValue[i].text,'');
         }
      } else {
         var objRule = new clsSltRule();
         objRule.grpcde = cstrSelectGrpCde;
         objRule.tabcde = cstrSelectTabCde;
         objRule.fldcde = cstrSelectFldCde;
         objRule.fldtxt = cstrSelectFldTxt;
         objRule.rultyp = cstrSelectRulTyp;
         objRule.rulcde = objSelRulCode[objSelRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         for (var i=0;i<objSelSelValue.options.length;i++) {
            objValues[i] = new clsSltValue(objSelSelValue[i].value,objSelSelValue[i].text,'');
         }
         addSltData(objRule);
      }
      displayScreen('dspSltRule');
      loadSltData();
   }
   function selectSltListValues() {
      var objSelRulValue = document.getElementById('SEL_RulValue');
      var objSelSelValue = document.getElementById('SEL_SelValue');
      var bolFound;
      for (var i=0;i<objSelRulValue.options.length;i++) {
         if (objSelRulValue.options[i].selected == true) {
            bolFound = false;
            for (var j=0;j<objSelSelValue.options.length;j++) {
               if (objSelRulValue[i].value == objSelSelValue[j].value) {
                  bolFound = true;
                  break;
               }
            }
            if (!bolFound) {
               objSelSelValue.options[objSelSelValue.options.length] = new Option(objSelRulValue[i].text,objSelRulValue[i].value);
            }
         }
      }
      var objWork = new Array();
      var intIndex = 0
      for (var i=0;i<objSelSelValue.options.length;i++) {
         objWork[intIndex] = objSelSelValue[i];
         intIndex++;
      }
      objWork.sort(sortSltListValues);
      objSelSelValue.options.length = 0;
      objSelSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSelSelValue.options[i] = objWork[i];
      }
   }
   function removeSltListValues() {
      var objSelSelValue = document.getElementById('SEL_SelValue');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objSelSelValue.options.length;i++) {
         if (objSelSelValue.options[i].selected == false) {
            objWork[intIndex] = objSelSelValue[i];
            intIndex++;
         }
      }
      objSelSelValue.options.length = 0;
      objSelSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSelSelValue.options[i] = objWork[i];
      }
   }
   function sortSltListValues(obj01, obj02) {
      if ((obj01.value-0) < (obj02.value-0)) {
         return -1;
      } else if ((obj01.value-0) > (obj02.value-0)) {
         return 1;
      }
      return 0;
   }
   /////////////////////////////
   // Select Number Functions //
   /////////////////////////////
   function doSltNumbCancel() {
      displayScreen('dspSltRule');
   }
   function doSltNumbAccept() {
      if (!processForm()) {return;}
      var objSenRulCode = document.getElementById('SEN_RulCode');
      var objSenSelValue = document.getElementById('SEN_SelValue');
      var strMessage = '';
      if (objSenRulCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection rule must be selected';
      }
      if (objSenSelValue.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection value must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintSelectRow != -1) {
         cobjSelectData[cintSelectRow].rulcde = objSenRulCode[objSenRulCode.selectedIndex].value;
         var objValues = cobjSelectData[cintSelectRow].valary;
         objValues.length = 0;
         objValues[0] = new clsSltValue('1',objSenSelValue.value,'');
      } else {
         var objRule = new clsSltRule();
         objRule.grpcde = cstrSelectGrpCde;
         objRule.tabcde = cstrSelectTabCde;
         objRule.fldcde = cstrSelectFldCde;
         objRule.fldtxt = cstrSelectFldTxt;
         objRule.rultyp = cstrSelectRulTyp;
         objRule.rulcde = objSenRulCode[objSenRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         objValues[0] = new clsSltValue('1',objSenSelValue.value,'');
         addSltData(objRule);
      }
      displayScreen('dspSltRule');
      loadSltData();
   }
   ///////////////////////////
   // Select Text Functions //
   ///////////////////////////
   function doSltTextCancel() {
      displayScreen('dspSltRule');
   }
   function doSltTextAccept() {
      if (!processForm()) {return;}
      var objSetRulCode = document.getElementById('SET_RulCode');
      var objSetSelValue = document.getElementById('SET_SelValue');
      var strMessage = '';
      if (objSetRulCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection rule must be selected';
      }
      if (objSetSelValue.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection value must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintSelectRow != -1) {
         cobjSelectData[cintSelectRow].rulcde = objSetRulCode[objSetRulCode.selectedIndex].value;
         var objValues = cobjSelectData[cintSelectRow].valary;
         objValues.length = 0;
         objValues[0] = new clsSltValue('1',objSetSelValue.value,'');
      } else {
         var objRule = new clsSltRule();
         objRule.grpcde = cstrSelectGrpCde;
         objRule.tabcde = cstrSelectTabCde;
         objRule.fldcde = cstrSelectFldCde;
         objRule.fldtxt = cstrSelectFldTxt;
         objRule.rultyp = cstrSelectRulTyp;
         objRule.rulcde = objSetRulCode[objSetRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         objValues[0] = new clsSltValue('1',objSetSelValue.value,'');
         addSltData(objRule);
      }
      displayScreen('dspSltRule');
      loadSltData();
   }
   /////////////////////////////
   // Select Review Functions //
   /////////////////////////////
   function doSltSlctSelect() {
      cstrSelectMode = '*SLT';
      var strEndCode = '0';
      doActivityStart(document.body);
      window.setTimeout('requestSltSlct(\''+strEndCode+'\');',10);
   }
   function doSltSlctMore() {
      if (!processForm()) {return;}
      cstrSelectMode = '*MOR';
      var strEndCode = '0';
      var objList = document.getElementById('SEL_SelList');
      if (objList.rows.length != 0) {
         strEndCode = objList.rows[objList.rows.length-1].getAttribute('selcde');
      }
      doActivityStart(document.body);
      window.setTimeout('requestSltSlct(\''+strEndCode+'\');',10);
   }
   function requestSltSlct(strEndCode) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*SELDTA" ENDCDE="'+strEndCode+'">';
      var intGroup = 0;
      var objValues;
      for (var i=0;i<cobjSelectData.length;i++) {
         if (cobjSelectData[i].tabcde == '*GROUP') {
            if (intGroup > 0) {
               strXML = strXML+'</GROUP>';
            }
            intGroup++;
            strXML = strXML+'<GROUP GRPCDE="*GROUP'+intGroup+'">';
         } else {
            if (cobjSelectData[i].rulcde != '' && cobjSelectData[i].valary.length != 0) {
               strXML = strXML+'<RULE TABCDE="'+cobjSelectData[i].tabcde+'" FLDCDE="'+cobjSelectData[i].fldcde+'" RULCDE="'+cobjSelectData[i].rulcde+'">';
               objValues = cobjSelectData[i].valary;
               for (var j=0;j<objValues.length;j++) {
                  strXML = strXML+'<VALUE VALCDE="'+objValues[j].valcde+'" VALTXT="'+objValues[j].valtxt+'"/>';
               }
               strXML = strXML+'</RULE>';
            }
         }
      }
      if (intGroup > 0) {
         strXML = strXML+'</GROUP>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doPostRequest('<%=strBase%>'+cstrSelectScript,function(strResponse) {checkSltSlct(strResponse);},false,streamXML(strXML));
   }
   function checkSltSlct(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var objDocument = loadXML(strResponse.substring(3,strResponse.length));
         if (objDocument == null) {return;}
         var strMessage = '';
         var objElements = objDocument.documentElement.childNodes;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'ERROR') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + objElements[i].getAttribute('ERRTXT');
            }
         }
         if (strMessage != '') {
            alert(strMessage);
            return;
         }
         displayScreen('dspSltSlct');
         var objTable = document.getElementById('SEL_SelList');
         var objRow;
         var objCell;
         if (cstrSelectMode == '*SLT') {
            for (var i=objTable.rows.length-1;i>=0;i--) {
               objTable.deleteRow(i);
            }
         }
         var intColCount = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'LSTCTL') {
               intColCount = objElements[i].getAttribute('COLCNT');
            } else if (objElements[i].nodeName == 'LSTROW') {
               objRow = objTable.insertRow(-1);
               objRow.setAttribute('selcde',objElements[i].getAttribute('SELCDE'));
               objRow.setAttribute('seltxt',objElements[i].getAttribute('SELTXT'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '<a class="clsSelect" onClick="doSltSlctAccept(\''+objRow.rowIndex+'\');">Select</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               for (var j=1;j<=intColCount;j++) {
                  objCell = objRow.insertCell(j);
                  objCell.colSpan = 1;
                  objCell.innerText = objElements[i].getAttribute('COL'+j);
                  objCell.className = 'clsLabelFN';
                  objCell.style.whiteSpace = 'nowrap';
               }
            }
         }
         if (objTable.rows.length == 0) {
            objRow = objTable.insertRow(-1);
            objCell = objRow.insertCell(0);
            objCell.colSpan = intColCount+1;
            objCell.innerText = 'NO DATA FOUND';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
         }
      }
   }
   function doSltSlctAccept(intRow) {
      var objTable = document.getElementById('SEL_SelList');
      cstrSelectAccept(objTable.rows[intRow].getAttribute('selcde'),objTable.rows[intRow].getAttribute('seltxt'));
   }
   function doSltSlctCancel() {
      cstrSelectCancel();
   }
   ///////////////////////////
   // Select Data Functions //
   ///////////////////////////
   function putSltData(objElements) {
      var intIndex = -1;
      for (var i=0;i<objElements.length;i++) {
         if (objElements[i].nodeName == 'GROUP') {
            intIndex++;
            cobjSelectData[intIndex] = new clsSltRule();
            cobjSelectData[intIndex].grpcde = objElements[i].getAttribute('GRPCDE');
            cobjSelectData[intIndex].tabcde = '*GROUP';
         } else if (objElements[i].nodeName == 'RULE') {
            intIndex++;
            cobjSelectData[intIndex] = new clsSltRule();
            cobjSelectData[intIndex].grpcde = objElements[i].getAttribute('GRPCDE');
            cobjSelectData[intIndex].tabcde = objElements[i].getAttribute('TABCDE');
            cobjSelectData[intIndex].fldcde = objElements[i].getAttribute('FLDCDE');
            cobjSelectData[intIndex].fldtxt = objElements[i].getAttribute('FLDTXT');
            cobjSelectData[intIndex].rultyp = objElements[i].getAttribute('RULTYP');
            cobjSelectData[intIndex].rulcde = objElements[i].getAttribute('RULCDE');
         } else if (objElements[i].nodeName == 'VALUE') {
            cobjSelectData[intIndex].valary = new clsSltValue(objElements[i].getAttribute('VALCDE'),objElements[i].getAttribute('VALTXT'));
         }
      }
      loadSltData();
   }
   function getSltData() {
      var strXML = '';
      var intGroup = 0;
      var objValues;
      for (var i=0;i<cobjSelectData.length;i++) {
         if (cobjSelectData[i].tabcde == '*GROUP') {
            if (intGroup > 0) {
               strXML = strXML+'</GROUP>';
            }
            intGroup++;
            strXML = strXML+'<GROUP GRPCDE="*GROUP'+intGroup+'">';
         } else {
            if (cobjSelectData[i].rulcde != '' && cobjSelectData[i].valary.length != 0) {
               strXML = strXML+'<RULE TABCDE="'+cobjSelectData[i].tabcde+'" FLDCDE="'+cobjSelectData[i].fldcde+'" RULCDE="'+cobjSelectData[i].rulcde+'">';
               objValues = cobjSelectData[i].valary;
               for (var j=0;j<objValues.length;j++) {
                  strXML = strXML+'<VALUE VALCDE="'+objValues[j].valcde+'" VALTXT="'+objValues[j].valtxt+'"/>';
               }
               strXML = strXML+'</RULE>';
            }
         }
      }
      if (intGroup > 0) {
         strXML = strXML+'</GROUP>';
      }
      return strXML;
   }
// -->
</script>