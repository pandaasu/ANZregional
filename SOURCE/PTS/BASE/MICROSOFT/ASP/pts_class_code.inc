<script language="javascript">
<!--
   ///////////////////////////
   // Search Rule Functions //
   ///////////////////////////
   var cstrSearchEntity;
   var cstrSearchHeading;
   var cstrSearchScript;
   var cobjSearchData;
   var cstrSearchTest;
   var cstrSearchCancel;
   var cobjSearchAccept;
   var cstrSearchMode;
   var cstrSearchGrpCde;
   var cstrSearchTabCde;
   var cstrSearchFldCde;
   var cstrSearchFldTxt;
   var cstrSearchInpLen;
   var cstrSearchRulTyp;
   var cstrSearchRulCde;
   var cintSearchRow;
   var cobjSearchArray;
   var cintSearchInstance;
   function clsClaInstance() {
      this.entnam = '';
      this.hedtxt = '';
      this.srvnam = '';
      this.schdat = new Array();
   }
   function clsClaRule() {
      this.grpcde = '';
      this.tabcde = '';
      this.fldcde = '';
      this.fldtxt = '';
      this.rultyp = '';
      this.rulcde = '';
      this.valary = new Array();
   }
   function clsClaValue(strValCde,strValTxt) {
      this.valcde = strValCde;
      this.valtxt = strValTxt;
   }
   function initSearch() {
      cobjScreens[cobjScreens.length] = new clsScreen('dspClaRule','hedClaRule');
      cobjScreens[cobjScreens.length] = new clsScreen('dspClaFeld','hedClaFeld');
      cobjScreens[cobjScreens.length] = new clsScreen('dspClaList','hedClaList');
      cobjScreens[cobjScreens.length] = new clsScreen('dspClaNumb','hedClaNumb');
      cobjScreens[cobjScreens.length] = new clsScreen('dspClaText','hedClaText');
      cobjScreens[cobjScreens.length] = new clsScreen('dspClaSlct','hedClaSlct');
      cintSearchInstance = -1;
      cobjSearchArray = new Array();
   }
   function startClaInstance(strEntity,strHeading,strScript,strTest,strCancel,strAccept) {
      cstrSearchTest = strTest;
      cstrSearchCancel = strCancel;
      cstrSearchAccept = strAccept;
      var intSearchInstance = -1;
      for (var i=0;i<cobjSearchArray.length;i++) {
         if (cobjSearchArray[i].entnam == strEntity) {
            intSearchInstance = i;
         }
      }
      if (intSearchInstance == -1) {
         var objInstance = new clsClaInstance();
         objInstance.entnam = strEntity;
         objInstance.hedtxt = strHeading;
         objInstance.srvnam = strScript;
         cobjSearchArray[cobjSearchArray.length] = objInstance;
         intSearchInstance = cobjSearchArray.length-1;
      }
      if (cintSearchInstance != intSearchInstance) {
         cintSearchInstance = intSearchInstance;
         cstrSearchEntity = cobjSearchArray[cintSearchInstance].entnam;
         cstrSearchHeading = cobjSearchArray[cintSearchInstance].hedtxt;
         cstrSearchScript = cobjSearchArray[cintSearchInstance].srvnam;
         cobjSearchData = cobjSearchArray[cintSearchInstance].schdat;
         var objScreen;
         var objHeading;
         for (var i=0;i<cobjScreens.length;i++) {
            if (cobjScreens[i].scrnam == 'dspClaRule') {
              cobjScreens[i].hedtxt = cstrSearchHeading+' Search Rules';
            } else if (cobjScreens[i].scrnam == 'dspClaFeld') {
               cobjScreens[i].hedtxt = cstrSearchHeading+' Search Fields';
            } else if (cobjScreens[i].scrnam == 'dspClaList') {
               cobjScreens[i].hedtxt = cstrSearchHeading+' Search List Rule';
            } else if (cobjScreens[i].scrnam == 'dspClaNumb') {
               cobjScreens[i].hedtxt = cstrSearchHeading+' Search Number Rule';
            } else if (cobjScreens[i].scrnam == 'dspClaText') {
               cobjScreens[i].hedtxt = cstrSearchHeading+' Search Text Rule';
            } else if (cobjScreens[i].scrnam == 'dspClaSlct') {
               cobjScreens[i].hedtxt = cstrSearchHeading+' Selection';
            }
         }
         loadClaData();
      }
      displayScreen('dspClaRule');
   }
   function loadClaData() {
      var objTable = document.getElementById('tabClaRule');
      var objFont = document.getElementById('fntClaRule');
      var objRow;
      var objCell;
      var bolFound = false;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      for (var i=0;i<cobjSearchData.length;i++) {
         if (cobjSearchData[i].tabcde == '*GROUP') {
            objRow = objTable.insertRow(-1);
            objRow.setAttribute('grpcde',cobjSearchData[i].grpcde);
            objRow.setAttribute('tabcde',cobjSearchData[i].tabcde);
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            objCell.innerHTML = '<a class="clsSelect" onClick="doClaRuleAddRule(\''+objRow.rowIndex+'\');">Add Rule</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doClaRuleDelGroup(\''+objRow.rowIndex+'\');">Delete</a>';
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
            objRow.setAttribute('grpcde',cobjSearchData[i].grpcde);
            objRow.setAttribute('tabcde',cobjSearchData[i].tabcde);
            objRow.setAttribute('fldcde',cobjSearchData[i].fldcde);
            objRow.setAttribute('fldtxt',cobjSearchData[i].fldtxt);
            objRow.setAttribute('rultyp',cobjSearchData[i].rultyp);
            objRow.setAttribute('rulcde',cobjSearchData[i].rulcde);
            var strText = 'NO VALUES';
            if (cobjSearchData[i].rulcde != '') {
               strText = '';
               var objValues = new Array();
               for (var j=0;j<cobjSearchData[i].valary.length;j++) {
                  objValues[j] = new clsClaValue(cobjSearchData[i].valary[j].valcde,cobjSearchData[i].valary[j].valtxt);
                  if (j == 0) {
                     if (cobjSearchData[i].rultyp == '*TEXT') {
                        strText = strText+'"'+cobjSearchData[i].valary[j].valtxt+'"';
                     } else {
                        strText = strText+cobjSearchData[i].valary[j].valtxt;
                     }
                  } else {
                     if (cobjSearchData[i].rultyp == '*TEXT') {
                        strText = strText+', "'+cobjSearchData[i].valary[j].valtxt+'"';
                     } else {
                        strText = strText+', '+cobjSearchData[i].valary[j].valtxt;
                     }
                  }
               }
               objRow.setAttribute('valary',objValues);
            }
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            objCell.innerHTML = '<a class="clsSelect" onClick="doClaRuleUpdRule(\''+objRow.rowIndex+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doClaRuleDelRule(\''+objRow.rowIndex+'\');">Delete</a>';
            objCell.className = 'clsLabelFN';
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(1);
            objCell.colSpan = 1;
            objCell.innerText = cobjSearchData[i].fldtxt+' ('+cobjSearchData[i].rulcde+')';
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
   function updateClaData() {
      var objTable = document.getElementById('tabClaRule');
      var objFont = document.getElementById('fntClaRule');
      var objValues;
      var bolFound = false;
      cobjSearchData.length = 0;
      for (var i=0;i<objTable.rows.length;i++) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('tabcde') == '*GROUP') {
            objRow.cells[0].innerHTML = '<a class="clsSelect" onClick="doClaRuleAddRule(\''+objRow.rowIndex+'\');">Add Rule</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doClaRuleDelGroup(\''+objRow.rowIndex+'\');">Delete</a>';
            if (!bolFound) {
               objRow.cells[1].innerText = 'SELECTION GROUP - WHERE';
            } else {
               objRow.cells[1].innerText = 'SELECTION GROUP - OR';
            }
            bolFound = true;
            cobjSearchData[i] = new clsClaRule();
            cobjSearchData[i].grpcde = objRow.getAttribute('grpcde');
            cobjSearchData[i].tabcde = objRow.getAttribute('tabcde');
         } else {
            objRow.cells[0].innerHTML = '<a class="clsSelect" onClick="doClaRuleUpdRule(\''+objRow.rowIndex+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doClaRuleDelRule(\''+objRow.rowIndex+'\');">Delete</a>';
            cobjSearchData[i] = new clsClaRule();
            cobjSearchData[i].grpcde = objRow.getAttribute('grpcde');
            cobjSearchData[i].tabcde = objRow.getAttribute('tabcde');
            cobjSearchData[i].fldcde = objRow.getAttribute('fldcde');
            cobjSearchData[i].fldtxt = objRow.getAttribute('fldtxt');
            cobjSearchData[i].rultyp = objRow.getAttribute('rultyp');
            cobjSearchData[i].rulcde = objRow.getAttribute('rulcde');
            if (cobjSearchData[i].rulcde != '') {
               cobjSearchData[i].valary.length = 0;
               objValues = objRow.getAttribute('valary');
               for (var j=0;j<objValues.length;j++) {
                  cobjSearchData[i].valary[j] = new clsClaValue(objValues[j].valcde,objValues[j].valtxt);
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
   function addClaData(objRule) {
      var objWork = new Array();
      var bolGroup = false;
      var bolInsert = false;
      var intIndex = 0
      for (var i=0;i<cobjSearchData.length;i++) {
         if (cobjSearchData[i].grpnam != cstrSearchGrpCde) {
            if (bolGroup && !bolInsert) {
               bolInsert = true;
               objWork[intIndex] = objRule;
               intIndex++;
            }
            objWork[intIndex] = cobjSearchData[i];
            intIndex++;
         } else {
            bolGroup = true;
            objWork[intIndex] = cobjSearchData[i];
            intIndex++;
         }
      }
      if (!bolInsert) {
         objWork[intIndex] = objRule;
      }
      cobjSearchData.length = 0;
      for (var i=0;i<objWork.length;i++) {
         cobjSearchData[i] = objWork[i];
      }
   }
   function doClaRuleAddGroup() {
      var objTable = document.getElementById('tabClaRule');
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
      updateClaData();
   }
   function doClaRuleAddRule(intRow) {
      var objTable = document.getElementById('tabClaRule');
      cstrSearchGrpCde = objTable.rows[intRow].getAttribute('grpcde');
      doActivityStart(document.body);
      window.setTimeout('requestClaFeldList();',10);
   }
   function doClaRuleDelGroup(intRow) {
      var objTable = document.getElementById('tabClaRule');
      var strGroup = objTable.rows[intRow].getAttribute('grpcde');
      var objRow;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('grpcde') == strGroup) {
            objTable.deleteRow(i);
         }
      }
      updateClaData();
   }
   function doClaRuleUpdRule(intRow) {
      var objTable = document.getElementById('tabClaRule');
      cintSearchRow = intRow;
      cstrSearchGrpCde = cobjSearchData[cintSearchRow].grpcde;
      cstrSearchTabCde = cobjSearchData[cintSearchRow].tabcde;
      cstrSearchFldCde = cobjSearchData[cintSearchRow].fldcde;
      cstrSearchRulTyp = cobjSearchData[cintSearchRow].rultyp;
      cstrSearchRulCde = cobjSearchData[cintSearchRow].rulcde;
      doActivityStart(document.body);
      window.setTimeout('requestClaFeldUpdate();',10);
   }
   function doClaRuleDelRule(intRow) {
      var objTable = document.getElementById('tabClaRule');
      objTable.deleteRow(intRow);
      updateClaData();
   }
   function doClaRuleSelect() {
      doClaSlctSelect();
   }
   function doClaRuleCancel() {
      cstrSearchCancel();
   }

   ////////////////////////////
   // Search Field Functions //
   ////////////////////////////
   function doClaFeldCancel() {
      displayScreen('dspClaRule');
   }
   function doClaFeldSelect(intRow) {
      var objTable = document.getElementById('tabClaFeld');
      objFieldRow = objTable.rows[intRow];
      var bolFound = false;
      for (var i=0;i<cobjSearchData.length;i++) {
         if (cobjSearchData[i].grpcde == cstrSearchGrpCde && 
             cobjSearchData[i].tabcde == objFieldRow.getAttribute('tabcde') && 
             cobjSearchData[i].fldcde == objFieldRow.getAttribute('fldcde')) {
            bolFound = true;
            break;
         }
      }
      if (bolFound) {
         alert('Field already selected in rule group');
         return;
      }
      cintSearchRow = -1;
      cstrSearchTabCde = objFieldRow.getAttribute('tabcde');
      cstrSearchFldCde = objFieldRow.getAttribute('fldcde');
      cstrSearchFldTxt = objFieldRow.getAttribute('fldtxt');
      cstrSearchInpLen = objFieldRow.getAttribute('inplen');
      cstrSearchRulTyp = objFieldRow.getAttribute('rultyp');
      cstrSearchRulCde = '';
      doActivityStart(document.body);
      window.setTimeout('requestClaFeldUpdate();',10);
   }
   function requestClaFeldList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTFLD" ENTCDE="'+cstrSearchEntity+'" TESFLG="'+cstrSearchTest+'"/>';
      doPostRequest('<%=strBase%>pts_sys_fld_list.asp',function(strResponse) {checkClaFeldList(strResponse);},false,streamXML(strXML));
   }
   function checkClaFeldList(strResponse) {
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
         displayScreen('dspClaFeld');
         var objTable = document.getElementById('tabClaFeld');
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
               objCell.innerHTML = '<a class="clsSelect" onClick="doClaFeldSelect(\''+objRow.rowIndex+'\');">Select</a>';
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
   function requestClaFeldUpdate(strXML) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTRUL" TABCDE="'+cstrSearchTabCde+'" FLDCDE="'+cstrSearchFldCde+'"/>';
      doPostRequest('<%=strBase%>pts_sys_rul_list.asp',function(strResponse) {checkClaFeldUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkClaFeldUpdate(strResponse) {
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
         if (cstrSearchRulTyp == '*LIST') {
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
                  if (cstrSearchRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSelRulCode.options[objSelRulCode.options.length-1].selected = true;
                  }
               } else if (objElements[i].nodeName == 'VALUE') {
                  objSelRulValue.options[objSelRulValue.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
               }
            }
            if (cintSearchRow != -1) {
               var objValues = cobjSearchData[cintSearchRow].valary;
               for (var i=0;i<objValues.length;i++) {
                  objSelSelValue.options[i] = new Option(objValues[i].valtxt,objValues[i].valcde);
               }
            }
            displayScreen('dspClaList');
            objSelRulCode.focus();
         } else if (cstrSearchRulTyp == '*NUMBER') {
            var objSenRulCode = document.getElementById('SEN_RulCode');
            var objSenSelValue = document.getElementById('SEN_SelValue');
            objSenRulCode.options.length = 0;
            objSenRulCode.selectedIndex = 1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSenRulCode.options[objSenRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSearchRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSenRulCode.options[objSenRulCode.options.length-1].selected = true;
                  }
               }
            }
            objSenSelValue.size = cstrSearchInpLen;
            objSenSelValue.maxLength = cstrSearchInpLen;
            objSenSelValue.value = '';
            if (cintSearchRow != -1) {
               var objValues = cobjSearchData[cintSearchRow].valary;
               if (objValues.length != 0) {
                  objSenSelValue.value = objValues[0].valtxt;
               }
            }
            displayScreen('dspClaNumb');
            objSenRulCode.focus();
         } else if (cstrSearchRulTyp == '*TEXT') {
            var objSetRulCode = document.getElementById('SET_RulCode');
            var objSetSelValue = document.getElementById('SET_SelValue');
            objSetRulCode.options.length = 0;
            objSetRulCode.selectedIndex = 1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSetRulCode.options[objSetRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSearchRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSetRulCode.options[objSetRulCode.options.length-1].selected = true;
                  }
               }
            }
            objSetSelValue.size = cstrSearchInpLen;
            objSetSelValue.maxLength = cstrSearchInpLen;
            objSetSelValue.value = '';
            if (cintSearchRow != -1) {
               var objValues = cobjSearchData[cintSearchRow].valary;
               if (objValues.length != 0) {
                  objSetSelValue.value = objValues[0].valtxt;
               }
            }
            displayScreen('dspClaText');
            objSetRulCode.focus();
         } else {
            alert('Unknown Rule Type ('+cstrSearchRulCde+')');
         }
      }
   }

   ///////////////////////////
   // Search List Functions //
   ///////////////////////////
   function doClaListCancel() {
      displayScreen('dspClaRule');
   }
   function doClaListAccept() {
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
      if (cintSearchRow != -1) {
         cobjSearchData[cintSearchRow].rulcde = objSelRulCode[objSelRulCode.selectedIndex].value;
         var objValues = cobjSearchData[cintSearchRow].valary;
         objValues.length = 0;
         for (var i=0;i<objSelSelValue.options.length;i++) {
            objValues[i] = new clsClaValue(objSelSelValue[i].value,objSelSelValue[i].text);
         }
      } else {
         var objRule = new clsClaRule();
         objRule.grpcde = cstrSearchGrpCde;
         objRule.tabcde = cstrSearchTabCde;
         objRule.fldcde = cstrSearchFldCde;
         objRule.fldtxt = cstrSearchFldTxt;
         objRule.rultyp = cstrSearchRulTyp;
         objRule.rulcde = objSelRulCode[objSelRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         for (var i=0;i<objSelSelValue.options.length;i++) {
            objValues[i] = new clsClaValue(objSelSelValue[i].value,objSelSelValue[i].text);
         }
         addClaData(objRule);
      }
      displayScreen('dspClaRule');
      loadClaData();
   }
   function selectClaListValues() {
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
      objWork.sort(sortClaListValues);
      objSelSelValue.options.length = 0;
      objSelSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSelSelValue.options[i] = objWork[i];
      }
   }
   function removeClaListValues() {
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
   function sortClaListValues(obj01, obj02) {
      if ((obj01.value-0) < (obj02.value-0)) {
         return -1;
      } else if ((obj01.value-0) > (obj02.value-0)) {
         return 1;
      }
      return 0;
   }

   /////////////////////////////
   // Search Number Functions //
   /////////////////////////////
   function doClaNumbCancel() {
      displayScreen('dspClaRule');
   }
   function doClaNumbAccept() {
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
      if (cintSearchRow != -1) {
         cobjSearchData[cintSearchRow].rulcde = objSenRulCode[objSenRulCode.selectedIndex].value;
         var objValues = cobjSearchData[cintSearchRow].valary;
         objValues.length = 0;
         objValues[0] = new clsClaValue('1',objSenSelValue.value);
      } else {
         var objRule = new clsClaRule();
         objRule.grpcde = cstrSearchGrpCde;
         objRule.tabcde = cstrSearchTabCde;
         objRule.fldcde = cstrSearchFldCde;
         objRule.fldtxt = cstrSearchFldTxt;
         objRule.rultyp = cstrSearchRulTyp;
         objRule.rulcde = objSenRulCode[objSenRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         objValues[0] = new clsClaValue('1',objSenSelValue.value);
         addClaData(objRule);
      }
      displayScreen('dspClaRule');
      loadClaData();
   }

   ///////////////////////////
   // Search Text Functions //
   ///////////////////////////
   function doClaTextCancel() {
      displayScreen('dspClaRule');
   }
   function doClaTextAccept() {
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
      if (cintSearchRow != -1) {
         cobjSearchData[cintSearchRow].rulcde = objSetRulCode[objSetRulCode.selectedIndex].value;
         var objValues = cobjSearchData[cintSearchRow].valary;
         objValues.length = 0;
         objValues[0] = new clsClaValue('1',objSetSelValue.value);
      } else {
         var objRule = new clsClaRule();
         objRule.grpcde = cstrSearchGrpCde;
         objRule.tabcde = cstrSearchTabCde;
         objRule.fldcde = cstrSearchFldCde;
         objRule.fldtxt = cstrSearchFldTxt;
         objRule.rultyp = cstrSearchRulTyp;
         objRule.rulcde = objSetRulCode[objSetRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         objValues[0] = new clsClaValue('1',objSetSelValue.value);
         addClaData(objRule);
      }
      displayScreen('dspClaRule');
      loadClaData();
   }

   /////////////////////////////
   // Search Select Functions //
   /////////////////////////////
   function doClaSlctSelect() {
      cstrSearchMode = '*SLT';
      var strEndCode = '0';
      doActivityStart(document.body);
      window.setTimeout('requestClaSlct(\''+strEndCode+'\');',10);
   }
   function doClaSlctMore() {
      if (!processForm()) {return;}
      cstrSearchMode = '*MOR';
      var strEndCode = '0';
      var objList = document.getElementById('SEL_SelList');
      if (objList.rows.length != 0) {
         strEndCode = objList.rows[objList.rows.length-1].getAttribute('selcde');
      }
      doActivityStart(document.body);
      window.setTimeout('requestClaSlct(\''+strEndCode+'\');',10);
   }
   function requestClaSlct(strEndCode) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*SELDTA" ENDCDE="'+strEndCode+'">';
      var intGroup = 0;
      var objValues;
      for (var i=0;i<cobjSearchData.length;i++) {
         if (cobjSearchData[i].tabcde == '*GROUP') {
            if (intGroup > 0) {
               strXML = strXML+'</GROUP>';
            }
            intGroup++;
            strXML = strXML+'<GROUP GRPCDE="*GROUP'+intGroup+'">';
         } else {
            if (cobjSearchData[i].rulcde != '' && cobjSearchData[i].valary.length != 0) {
               strXML = strXML+'<RULE TABCDE="'+cobjSearchData[i].tabcde+'" FLDCDE="'+cobjSearchData[i].fldcde+'" RULCDE="'+cobjSearchData[i].rulcde+'">';
               objValues = cobjSearchData[i].valary;
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
      doPostRequest('<%=strBase%>'+cstrSearchScript,function(strResponse) {checkClaSlct(strResponse);},false,streamXML(strXML));
   }
   function checkClaSlct(strResponse) {
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
         displayScreen('dspClaSlct');
         var objTable = document.getElementById('SEL_SelList');
         var objRow;
         var objCell;
         if (cstrSearchMode == '*SLT') {
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
               objCell.innerHTML = '<a class="clsSelect" onClick="doClaSlctAccept(\''+objRow.rowIndex+'\');">Select</a>';
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
   function doClaSlctAccept(intRow) {
      var objTable = document.getElementById('SEL_SelList');
      cstrSearchAccept(objTable.rows[intRow].getAttribute('selcde'),objTable.rows[intRow].getAttribute('seltxt'));
   }
   function doClaSlctCancel() {
      cstrSearchCancel();
   }

   ///////////////////////////
   // Search Save Functions //
   ///////////////////////////
   function getClaSaveData() {
      var strXML = '';
      var intGroup = 0;
      var objValues;
      for (var i=0;i<cobjSearchData.length;i++) {
         if (cobjSearchData[i].tabcde == '*GROUP') {
            if (intGroup > 0) {
               strXML = strXML+'</GROUP>';
            }
            intGroup++;
            strXML = strXML+'<GROUP GRPCDE="*GROUP'+intGroup+'">';
         } else {
            if (cobjSearchData[i].rulcde != '' && cobjSearchData[i].valary.length != 0) {
               strXML = strXML+'<RULE TABCDE="'+cobjSearchData[i].tabcde+'" FLDCDE="'+cobjSearchData[i].fldcde+'" RULCDE="'+cobjSearchData[i].rulcde+'">';
               objValues = cobjSearchData[i].valary;
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