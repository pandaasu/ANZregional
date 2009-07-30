<script language="javascript">
<!--
   ///////////////////////////
   // Select Rule Functions //
   ///////////////////////////
   var cstrSelectParent;
   var cstrSelectEntity;
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
   var cintSelectGroup = 0;
   function clsSltRule() {
      this.grpcde = '';
      this.grptxt = '';
      this.grppct = '';
      this.tabcde = '';
      this.fldcde = '';
      this.fldtxt = '';
      this.inplen = '';
      this.rultyp = '';
      this.rulcde = '';
      this.valary = new Array();
   }
   function clsSltValue(strValCde,strValTxt,strValPct) {
      this.valcde = strValCde;
      this.valtxt = strValTxt;
      this.valpct = strValPct;
   }
   function initSelect(strParent,strHeading) {
      cstrSelectParent = strParent;
      cobjScreens[cobjScreens.length] = new clsScreen('dspSltGrop','hedSltGrop');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSltFeld','hedSltFeld');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSltList','hedSltList');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSltPcnt','hedSltPcnt');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSltNumb','hedSltNumb');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSltText','hedSltText');
      for (var i=0;i<cobjScreens.length;i++) {
         if (cobjScreens[i].scrnam == 'dspSltGrop') {
            cobjScreens[i].hedtxt = strHeading+' Selection Group';
         } else if (cobjScreens[i].scrnam == 'dspSltFeld') {
            cobjScreens[i].hedtxt = strHeading+' Selection Fields';
         } else if (cobjScreens[i].scrnam == 'dspSltList') {
            cobjScreens[i].hedtxt = strHeading+' Selection List Rule';
         } else if (cobjScreens[i].scrnam == 'dspSltPcnt') {
            cobjScreens[i].hedtxt = strHeading+' Selection List Percent';
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
      var objTable = document.getElementById('tabSltRule');
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      updateSltData();
   }
   function loadSltData() {
      var objTable = document.getElementById('tabSltRule');
      var objFont = document.getElementById('fntSltRule');
      var objRow;
      var objCell;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      for (var i=0;i<cobjSelectData.length;i++) {
         if (cobjSelectData[i].tabcde == '*GROUP') {
            objRow = objTable.insertRow(-1);
            objRow.setAttribute('grpcde',cobjSelectData[i].grpcde);
            objRow.setAttribute('grptxt',cobjSelectData[i].grptxt);
            objRow.setAttribute('grppct',cobjSelectData[i].grppct);
            objRow.setAttribute('tabcde',cobjSelectData[i].tabcde);
            objCell = objRow.insertCell(0);
            objCell.colSpan = 4;
            objCell.innerHTML = '<a class="clsSelect" onClick="doSltRuleAddRule(\''+objRow.rowIndex+'\');">Add Rule</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleUpdGroup(\''+objRow.rowIndex+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleCpyGroup(\''+objRow.rowIndex+'\');">Copy</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleDelGroup(\''+objRow.rowIndex+'\');">Delete</a>&nbsp;-&nbsp;SELECTION GROUP - '+cobjSelectData[i].grptxt+' ('+cobjSelectData[i].grppct+'%)';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
         } else {
            objRow = objTable.insertRow(-1);
            objRow.setAttribute('grpcde',cobjSelectData[i].grpcde);
            objRow.setAttribute('tabcde',cobjSelectData[i].tabcde);
            objRow.setAttribute('fldcde',cobjSelectData[i].fldcde);
            objRow.setAttribute('fldtxt',cobjSelectData[i].fldtxt);
            objRow.setAttribute('inplen',cobjSelectData[i].inplen);
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
                     if (cobjSelectData[i].rulcde == '*SELECT_WHEN_EQUAL_MIX') {
                        strText = strText+' ('+cobjSelectData[i].valary[j].valpct+'%)';
                     }
                  } else {
                     if (cobjSelectData[i].rultyp == '*TEXT') {
                        strText = strText+', "'+cobjSelectData[i].valary[j].valtxt+'"';
                     } else {
                        strText = strText+', '+cobjSelectData[i].valary[j].valtxt;
                     }
                     if (cobjSelectData[i].rulcde == '*SELECT_WHEN_EQUAL_MIX') {
                        strText = strText+' ('+cobjSelectData[i].valary[j].valpct+'%)';
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
            objCell.innerText = cobjSelectData[i].fldtxt;
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(2);
            objCell.colSpan = 1;
            objCell.innerText = cobjSelectData[i].rulcde;
            objCell.className = 'clsLabelFN';
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(3);
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
      cobjSelectData.length = 0;
      for (var i=0;i<objTable.rows.length;i++) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('tabcde') == '*GROUP') {
            objRow.cells[0].innerHTML = '<a class="clsSelect" onClick="doSltRuleAddRule(\''+objRow.rowIndex+'\');">Add Rule</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleUpdGroup(\''+objRow.rowIndex+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleCpyGroup(\''+objRow.rowIndex+'\');">Copy</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleDelGroup(\''+objRow.rowIndex+'\');">Delete</a>&nbsp;-&nbsp;SELECTION GROUP - '+objRow.getAttribute('grptxt')+' ('+objRow.getAttribute('grppct')+'%)';
            objRow.cells[0].colSpan = 4;
            cobjSelectData[i] = new clsSltRule();
            cobjSelectData[i].grpcde = objRow.getAttribute('grpcde');
            cobjSelectData[i].grptxt = objRow.getAttribute('grptxt');
            cobjSelectData[i].grppct = objRow.getAttribute('grppct');
            cobjSelectData[i].tabcde = objRow.getAttribute('tabcde');
         } else {
            objRow.cells[0].innerHTML = '<a class="clsSelect" onClick="doSltRuleUpdRule(\''+objRow.rowIndex+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSltRuleDelRule(\''+objRow.rowIndex+'\');">Delete</a>';
            cobjSelectData[i] = new clsSltRule();
            cobjSelectData[i].grpcde = objRow.getAttribute('grpcde');
            cobjSelectData[i].tabcde = objRow.getAttribute('tabcde');
            cobjSelectData[i].fldcde = objRow.getAttribute('fldcde');
            cobjSelectData[i].fldtxt = objRow.getAttribute('fldtxt');
            cobjSelectData[i].inplen = objRow.getAttribute('inplen');
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
         if (cobjSelectData[i].grpcde != cstrSelectGrpCde) {
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
      cintSelectRow = -1;
      displayScreen('dspSltGrop');
      document.getElementById('SGR_GrpText').value = '';
      document.getElementById('SGR_GrpPcnt').value = '0';
      document.getElementById('SGR_GrpText').focus();
   }
   function doSltRuleUpdGroup(intRow) {
      var objTable = document.getElementById('tabSltRule');
      cintSelectRow = intRow;
      displayScreen('dspSltGrop');
      document.getElementById('SGR_GrpText').value = cobjSelectData[cintSelectRow].grptxt;
      document.getElementById('SGR_GrpPcnt').value = cobjSelectData[cintSelectRow].grppct;
      document.getElementById('SGR_GrpText').focus();
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
   function doSltRuleCpyGroup(intRow) {
      var objTable = document.getElementById('tabSltRule');
      var strGroup = objTable.rows[intRow].getAttribute('grpcde');
      var objValues;
      cintSelectGroup++;
      var strNext = '*GROUP'+cintSelectGroup;
      var intIndex = cobjSelectData.length-1;
      for (var i=0;i<cobjSelectData.length;i++) {
         if (cobjSelectData[i].grpcde == strGroup) {
            if (cobjSelectData[i].tabcde == '*GROUP') {
               intIndex++;
               cobjSelectData[intIndex] = new clsSltRule();
               cobjSelectData[intIndex].grpcde = strNext;
               cobjSelectData[intIndex].grptxt = cobjSelectData[i].grptxt;
               cobjSelectData[intIndex].grppct = cobjSelectData[i].grppct;
               cobjSelectData[intIndex].tabcde = '*GROUP';
            } else {
               intIndex++;
               cobjSelectData[intIndex] = new clsSltRule();
               cobjSelectData[intIndex].grpcde = strNext;
               cobjSelectData[intIndex].tabcde = cobjSelectData[i].tabcde;
               cobjSelectData[intIndex].fldcde = cobjSelectData[i].fldcde;
               cobjSelectData[intIndex].fldtxt = cobjSelectData[i].fldtxt;
               cobjSelectData[intIndex].inplen = cobjSelectData[i].inplen;
               cobjSelectData[intIndex].rultyp = cobjSelectData[i].rultyp;
               cobjSelectData[intIndex].rulcde = cobjSelectData[i].rulcde;
               objValues = cobjSelectData[i].valary;
               for (var j=0;j<objValues.length;j++) {
                  cobjSelectData[intIndex].valary[cobjSelectData[intIndex].valary.length] = new clsSltValue(objValues[j].valcde,objValues[j].valtxt,objValues[j].valpct);
               }
            }
         }
      }
      loadSltData();
   }
   function doSltRuleAddRule(intRow) {
      var objTable = document.getElementById('tabSltRule');
      cstrSelectGrpCde = objTable.rows[intRow].getAttribute('grpcde');
      doActivityStart(document.body);
      window.setTimeout('requestSltFeldList();',10);
   }
   function doSltRuleUpdRule(intRow) {
      var objTable = document.getElementById('tabSltRule');
      cintSelectRow = intRow;
      cstrSelectGrpCde = cobjSelectData[cintSelectRow].grpcde;
      cstrSelectTabCde = cobjSelectData[cintSelectRow].tabcde;
      cstrSelectFldCde = cobjSelectData[cintSelectRow].fldcde;
      cstrSelectFldTxt = cobjSelectData[cintSelectRow].fldtxt;
      cstrSelectInpLen = cobjSelectData[cintSelectRow].inplen;
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
   ////////////////////////////
   // Select Group Functions //
   ////////////////////////////
   function doSltGropCancel() {
      displayScreen(cstrSelectParent);
   }
   function doSltGropAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('SGR_GrpText').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection group text must be entered';
      }
      if (document.getElementById('SGR_GrpPcnt').value < 1 || document.getElementById('SGR_GrpPcnt').value > 100) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection group percentage must be in the range 1 to 100';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      displayScreen(cstrSelectParent);
      var objTable = document.getElementById('tabSltRule');
      var objRow;
      var objCell;
      var strGroup;
      if (cintSelectRow != -1) {
         objTable.rows[cintSelectRow].setAttribute('grptxt',document.getElementById('SGR_GrpText').value);
         objTable.rows[cintSelectRow].setAttribute('grppct',document.getElementById('SGR_GrpPcnt').value);
      } else {
         objRow = objTable.insertRow(-1);
         cintSelectGroup++;
         strGroup = '*GROUP'+cintSelectGroup;
         objRow.setAttribute('grpcde',strGroup);
         objRow.setAttribute('grptxt',document.getElementById('SGR_GrpText').value);
         objRow.setAttribute('grppct',document.getElementById('SGR_GrpPcnt').value);
         objRow.setAttribute('tabcde','*GROUP');
         objCell = objRow.insertCell(0);
         objCell.colSpan = 1;
         objCell.innerHTML = '';
         objCell.className = 'clsLabelFN';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(1);
         objCell.colSpan = 3;
         objCell.innerText = '';
         objCell.className = 'clsLabelFB';
         objCell.style.whiteSpace = 'nowrap';
      }
      updateSltData();
   }
   ////////////////////////////
   // Select Field Functions //
   ////////////////////////////
   function doSltFeldCancel() {
      displayScreen(cstrSelectParent);
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
         alert('Field already selected in selection group');
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTRUL" TESFLG="1" TABCDE="'+cstrSelectTabCde+'" FLDCDE="'+cstrSelectFldCde+'"/>';
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
            var objSllRulCode = document.getElementById('SLL_RulCode');
            var objSllRulValue = document.getElementById('SLL_RulValue');
            var objSllSelValue = document.getElementById('SLL_SelValue');
            objSllRulCode.options.length = 0;
            objSllRulCode.selectedIndex = 1;
            objSllRulValue.options.length = 0;
            objSllRulValue.selectedIndex = -1;
            objSllSelValue.options.length = 0;
            objSllSelValue.selectedIndex = -1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSllRulCode.options[objSllRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSelectRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSllRulCode.options[objSllRulCode.options.length-1].selected = true;
                  }
               } else if (objElements[i].nodeName == 'VALUE') {
                  objSllRulValue.options[objSllRulValue.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
               }
            }
            if (cintSelectRow != -1) {
               var objValues = cobjSelectData[cintSelectRow].valary;
               for (var i=0;i<objValues.length;i++) {
                  if (cstrSelectRulCde == '*SELECT_WHEN_EQUAL_MIX') {
                     objSllSelValue.options[i] = new Option(objValues[i].valtxt+' ('+objValues[i].valpct+'%)',objValues[i].valcde);
                     objSllSelValue.options[i].setAttribute('valtxt',objValues[i].valtxt);
                     objSllSelValue.options[i].setAttribute('valpct',objValues[i].valpct);
                  } else {
                     objSllSelValue.options[i] = new Option(objValues[i].valtxt,objValues[i].valcde);
                     objSllSelValue.options[i].setAttribute('valtxt',objValues[i].valtxt);
                     objSllSelValue.options[i].setAttribute('valpct',objValues[i].valpct);
                  }
               }
            }
            displayScreen('dspSltList');
            objSllRulCode.focus();
         } else if (cstrSelectRulTyp == '*NUMBER') {
            document.getElementById('subSltNumb').innerText = cstrSelectFldTxt;
            var objSlnRulCode = document.getElementById('SLN_RulCode');
            var objSlnSelValue = document.getElementById('SLN_SelValue');
            objSlnRulCode.options.length = 0;
            objSlnRulCode.selectedIndex = 1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSlnRulCode.options[objSlnRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSelectRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSlnRulCode.options[objSlnRulCode.options.length-1].selected = true;
                  }
               }
            }
            objSlnSelValue.size = cstrSelectInpLen;
            objSlnSelValue.maxLength = cstrSelectInpLen;
            objSlnSelValue.value = '';
            if (cintSelectRow != -1) {
               var objValues = cobjSelectData[cintSelectRow].valary;
               if (objValues.length != 0) {
                  objSlnSelValue.value = objValues[0].valtxt;
               }
            }
            displayScreen('dspSltNumb');
            objSlnRulCode.focus();
         } else if (cstrSelectRulTyp == '*TEXT') {
            document.getElementById('subSltText').innerText = cstrSelectFldTxt;
            var objSltRulCode = document.getElementById('SLT_RulCode');
            var objSltSelValue = document.getElementById('SLT_SelValue');
            objSltRulCode.options.length = 0;
            objSltRulCode.selectedIndex = 1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSltRulCode.options[objSltRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSelectRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSltRulCode.options[objSltRulCode.options.length-1].selected = true;
                  }
               }
            }
            objSltSelValue.size = cstrSelectInpLen;
            objSltSelValue.maxLength = cstrSelectInpLen;
            objSltSelValue.value = '';
            if (cintSelectRow != -1) {
               var objValues = cobjSelectData[cintSelectRow].valary;
               if (objValues.length != 0) {
                  objSltSelValue.value = objValues[0].valtxt;
               }
            }
            displayScreen('dspSltText');
            objSltRulCode.focus();
         } else {
            alert('Unknown Rule Type ('+cstrSelectRulTyp+')');
         }
      }
   }
   ///////////////////////////
   // Select List Functions //
   ///////////////////////////
   function doSltListCancel() {
      displayScreen(cstrSelectParent);
   }
   function doSltListAccept() {
      if (!processForm()) {return;}
      var objSllRulCode = document.getElementById('SLL_RulCode');
      var objSllSelValue = document.getElementById('SLL_SelValue');
      var strMessage = '';
      if (objSllRulCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection rule must be selected';
      } else {
         if (objSllRulCode[objSllRulCode.selectedIndex].value == '*SELECT_WHEN_EQUAL_MIX') {
            var intTotal = 0;
            for (var i=0;i<objSllSelValue.options.length;i++) {
               intTotal = intTotal + (objSllSelValue[i].getAttribute('valpct')-0);
            }
            if (intTotal != 100) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Mix percentage must sum to 100';
            }
         }
      }
      if (objSllSelValue.options.length == 0) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'At least one rule value must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintSelectRow != -1) {
         cobjSelectData[cintSelectRow].rulcde = objSllRulCode[objSllRulCode.selectedIndex].value;
         var objValues = cobjSelectData[cintSelectRow].valary;
         objValues.length = 0;
         for (var i=0;i<objSllSelValue.options.length;i++) {
            objValues[i] = new clsSltValue(objSllSelValue[i].value,objSllSelValue[i].getAttribute('valtxt'),objSllSelValue[i].getAttribute('valpct'));
         }
      } else {
         var objRule = new clsSltRule();
         objRule.grpcde = cstrSelectGrpCde;
         objRule.tabcde = cstrSelectTabCde;
         objRule.fldcde = cstrSelectFldCde;
         objRule.fldtxt = cstrSelectFldTxt;
         objRule.inplen = cstrSelectInpLen;
         objRule.rultyp = cstrSelectRulTyp;
         objRule.rulcde = objSllRulCode[objSllRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         for (var i=0;i<objSllSelValue.options.length;i++) {
            objValues[i] = new clsSltValue(objSllSelValue[i].value,objSllSelValue[i].getAttribute('valtxt'),objSllSelValue[i].getAttribute('valpct'));
         }
         addSltData(objRule);
      }
      displayScreen(cstrSelectParent);
      loadSltData();
   }
   function selectSltListValues() {
      var objSllRulCode = document.getElementById('SLL_RulCode');
      var objSllRulValue = document.getElementById('SLL_RulValue');
      var objSllSelValue = document.getElementById('SLL_SelValue');
      var bolFound;
      for (var i=0;i<objSllRulValue.options.length;i++) {
         if (objSllRulValue.options[i].selected == true) {
            bolFound = false;
            for (var j=0;j<objSllSelValue.options.length;j++) {
               if (objSllRulValue[i].value == objSllSelValue[j].value) {
                  bolFound = true;
                  break;
               }
            }
            if (!bolFound) {
               if (objSllRulCode[objSllRulCode.selectedIndex].value == '*SELECT_WHEN_EQUAL_MIX') {
                  objSllSelValue.options[objSllSelValue.options.length] = new Option(objSllRulValue[i].text+' (0%)',objSllRulValue[i].value);
                  objSllSelValue.options[objSllSelValue.options.length-1].setAttribute('valtxt',objSllRulValue[i].text);
                  objSllSelValue.options[objSllSelValue.options.length-1].setAttribute('valpct','0');
               } else {
                  objSllSelValue.options[objSllSelValue.options.length] = new Option(objSllRulValue[i].text,objSllRulValue[i].value);
                  objSllSelValue.options[objSllSelValue.options.length-1].setAttribute('valtxt',objSllRulValue[i].text);
                  objSllSelValue.options[objSllSelValue.options.length-1].setAttribute('valpct','');
               }
            }
         }
      }
      var objWork = new Array();
      var intIndex = 0
      for (var i=0;i<objSllSelValue.options.length;i++) {
         objWork[intIndex] = objSllSelValue[i];
         intIndex++;
      }
      objWork.sort(sortSltListValues);
      objSllSelValue.options.length = 0;
      objSllSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSllSelValue.options[i] = objWork[i];
      }
   }
   function removeSltListValues() {
      var objSllSelValue = document.getElementById('SLL_SelValue');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objSllSelValue.options.length;i++) {
         if (objSllSelValue.options[i].selected == false) {
            objWork[intIndex] = objSllSelValue[i];
            intIndex++;
         }
      }
      objSllSelValue.options.length = 0;
      objSllSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSllSelValue.options[i] = objWork[i];
      }
   }
   function updateSltListValue() {
      if (!processForm()) {return;}
      var objSllSelValue = document.getElementById('SLL_SelValue');
      var intCount = 0;
      for (var i=0;i<objSllSelValue.options.length;i++) {
         if (objSllSelValue.options[i].selected == true) {
            intCount++;
         }
      }
      var strMessage = '';
      if (intCount == 0) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection value must be selected for update';
      } else if (intCount > 1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Only one selection value can be selected for update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      displayScreen('dspSltPcnt');
      document.getElementById('subSltPcnt').innerText = objSllSelValue[objSllSelValue.selectedIndex].getAttribute('valtxt');
      document.getElementById('SLP_ValPcnt').value = objSllSelValue[objSllSelValue.selectedIndex].getAttribute('valpct');
      document.getElementById('SLP_ValPcnt').focus();
   }
   function selectSltListRule(objSelect) {
      var strValue = objSelect.options[objSelect.selectedIndex].value;
      var objSllSelValue = document.getElementById('SLL_SelValue');
      if (strValue == '*SELECT_WHEN_EQUAL_MIX') {
         for (var i=0;i<objSllSelValue.options.length;i++) {
            objSllSelValue.options[i].text = objSllSelValue.options[i].getAttribute('valtxt')+' (0%)';
            objSllSelValue.options[i].setAttribute('valpct','0');
         }
      } else {
         for (var i=0;i<objSllSelValue.options.length;i++) {
            objSllSelValue.options[i].text = objSllSelValue.options[i].getAttribute('valtxt');
            objSllSelValue.options[i].setAttribute('valpct','');
         }
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

   //////////////////////////////
   // Select Percent Functions //
   //////////////////////////////
   function doSltPcntCancel() {
      displayScreen('dspSltList');
   }
   function doSltPcntAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('SLP_ValPcnt').value < 1 || document.getElementById('SLP_ValPcnt').value > 100) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection value percentage must be in the range 1 to 100';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      displayScreen('dspSltList');
      var objSllSelValue = document.getElementById('SLL_SelValue');
      objSllSelValue.options[objSllSelValue.selectedIndex].text = objSllSelValue.options[objSllSelValue.selectedIndex].getAttribute('valtxt')+' ('+document.getElementById('SLP_ValPcnt').value+'%)';
      objSllSelValue.options[objSllSelValue.selectedIndex].setAttribute('valpct',document.getElementById('SLP_ValPcnt').value);
      displayScreen('dspSltList');
   }

   /////////////////////////////
   // Select Number Functions //
   /////////////////////////////
   function doSltNumbCancel() {
      displayScreen(cstrSelectParent);
   }
   function doSltNumbAccept() {
      if (!processForm()) {return;}
      var objSlnRulCode = document.getElementById('SLN_RulCode');
      var objSlnSelValue = document.getElementById('SLN_SelValue');
      var strMessage = '';
      if (objSlnRulCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection rule must be selected';
      }
      if (objSlnSelValue.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection value must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintSelectRow != -1) {
         cobjSelectData[cintSelectRow].rulcde = objSlnRulCode[objSlnRulCode.selectedIndex].value;
         var objValues = cobjSelectData[cintSelectRow].valary;
         objValues.length = 0;
         objValues[0] = new clsSltValue('1',objSlnSelValue.value,'');
      } else {
         var objRule = new clsSltRule();
         objRule.grpcde = cstrSelectGrpCde;
         objRule.tabcde = cstrSelectTabCde;
         objRule.fldcde = cstrSelectFldCde;
         objRule.fldtxt = cstrSelectFldTxt;
         objRule.inplen = cstrSelectInpLen;
         objRule.rultyp = cstrSelectRulTyp;
         objRule.rulcde = objSlnRulCode[objSlnRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         objValues[0] = new clsSltValue('1',objSlnSelValue.value,'');
         addSltData(objRule);
      }
      displayScreen(cstrSelectParent);
      loadSltData();
   }
   ///////////////////////////
   // Select Text Functions //
   ///////////////////////////
   function doSltTextCancel() {
      displayScreen(cstrSelectParent);
   }
   function doSltTextAccept() {
      if (!processForm()) {return;}
      var objSltRulCode = document.getElementById('SLT_RulCode');
      var objSltSelValue = document.getElementById('SLT_SelValue');
      var strMessage = '';
      if (objSltRulCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection rule must be selected';
      }
      if (objSltSelValue.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection value must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintSelectRow != -1) {
         cobjSelectData[cintSelectRow].rulcde = objSltRulCode[objSltRulCode.selectedIndex].value;
         var objValues = cobjSelectData[cintSelectRow].valary;
         objValues.length = 0;
         objValues[0] = new clsSltValue('1',objSltSelValue.value,'');
      } else {
         var objRule = new clsSltRule();
         objRule.grpcde = cstrSelectGrpCde;
         objRule.tabcde = cstrSelectTabCde;
         objRule.fldcde = cstrSelectFldCde;
         objRule.fldtxt = cstrSelectFldTxt;
         objRule.inplen = cstrSelectInpLen;
         objRule.rultyp = cstrSelectRulTyp;
         objRule.rulcde = objSltRulCode[objSltRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         objValues[0] = new clsSltValue('1',objSltSelValue.value,'');
         addSltData(objRule);
      }
      displayScreen(cstrSelectParent);
      loadSltData();
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
            cobjSelectData[intIndex].grptxt = objElements[i].getAttribute('GRPTXT');
            cobjSelectData[intIndex].grppct = objElements[i].getAttribute('GRPPCT');
            cobjSelectData[intIndex].tabcde = '*GROUP';
            cintSelectGroup++;
         } else if (objElements[i].nodeName == 'RULE') {
            intIndex++;
            cobjSelectData[intIndex] = new clsSltRule();
            cobjSelectData[intIndex].grpcde = objElements[i].getAttribute('GRPCDE');
            cobjSelectData[intIndex].tabcde = objElements[i].getAttribute('TABCDE');
            cobjSelectData[intIndex].fldcde = objElements[i].getAttribute('FLDCDE');
            cobjSelectData[intIndex].fldtxt = objElements[i].getAttribute('FLDTXT');
            cobjSelectData[intIndex].inplen = objElements[i].getAttribute('INPLEN');
            cobjSelectData[intIndex].rultyp = objElements[i].getAttribute('RULTYP');
            cobjSelectData[intIndex].rulcde = objElements[i].getAttribute('RULCDE');
         } else if (objElements[i].nodeName == 'VALUE') {
            cobjSelectData[intIndex].valary[cobjSelectData[intIndex].valary.length] = new clsSltValue(objElements[i].getAttribute('VALCDE'),objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALPCT'));
         }
      }
      loadSltData();
      document.getElementById('divSltRule').scrollTop = 0;
      document.getElementById('divSltRule').scrollLeft = 0;
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
            strXML = strXML+'<GROUP GRPCDE="*GROUP'+intGroup+'" GRPTXT="'+cobjSelectData[i].grptxt+'" GRPPCT="'+cobjSelectData[i].grppct+'">';
         } else {
            if (cobjSelectData[i].rulcde != '' && cobjSelectData[i].valary.length != 0) {
               strXML = strXML+'<RULE TABCDE="'+cobjSelectData[i].tabcde+'" FLDCDE="'+cobjSelectData[i].fldcde+'" RULCDE="'+cobjSelectData[i].rulcde+'">';
               objValues = cobjSelectData[i].valary;
               for (var j=0;j<objValues.length;j++) {
                  strXML = strXML+'<VALUE VALCDE="'+objValues[j].valcde+'" VALTXT="'+objValues[j].valtxt+'" VALPCT="'+objValues[j].valpct+'"/>';
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
   function checkSltData() {
      var strMessage = '';
      var bolData = true;
      var bolGroup = false;
      var bolRule = false;
      for (var i=0;i<cobjSelectData.length;i++) {
         if (cobjSelectData[i].tabcde == '*GROUP') {
            if (bolGroup && !bolRule) {
               bolData = false;
            }
            bolGroup = true;
            bolRule = false;
         } else {
            if (cobjSelectData[i].rulcde != '' && cobjSelectData[i].valary.length != 0) {
               bolRule = true;
            }
         }
      }
      if (bolGroup && !bolRule) {
         bolData = false;
      }
      if (!bolGroup) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'At least one group must be specified';
      }
      if (!bolData) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Groups must have at least one rule';
      }
      return strMessage;
   }
// -->
</script>