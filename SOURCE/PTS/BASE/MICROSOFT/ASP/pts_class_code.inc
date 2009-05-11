<script language="javascript">
<!--
   /////////////////////////////
   // Class Control Functions //
   /////////////////////////////
   var cstrClassCancel;
   var cstrClassAccept;
   var cintRowIndex;
   var cstrClassTabCde;
   var cstrClassFldCde;
   var cstrClassFldTxt;
   var cstrClassInpLen;
   var cstrClassSelTyp;
   var cstrClassPetTyp;
   var cobjClassClaVal;
   function clsClaValue(strValCde,strValTxt) {
      this.valcde = strValCde;
      this.valtxt = strValTxt;
   }
   function initClass(strHeading,strCancel,strAccept) {
      cstrClassCancel = strCancel;
      cstrClassAccept = strAccept;
      cobjScreens[cobjScreens.length] = new clsScreen('dspClaList','hedClaList');
      cobjScreens[cobjScreens.length] = new clsScreen('dspClaNumb','hedClaNumb');
      cobjScreens[cobjScreens.length] = new clsScreen('dspClaText','hedClaText');
      for (var i=0;i<cobjScreens.length;i++) {
         if (cobjScreens[i].scrnam == 'dspClaList') {
            cobjScreens[i].hedtxt = strHeading+' List Classification';
         } else if (cobjScreens[i].scrnam == 'dspClaNumb') {
            cobjScreens[i].hedtxt = strHeading+' Number Classification';
         } else if (cobjScreens[i].scrnam == 'dspClaText') {
            cobjScreens[i].hedtxt = strHeading+' Text Classification';
         }
      }
   }
   function doClaUpdate(intRowIndex,strTabCde,strFldCde,strFldTxt,strInpLen,strSelTyp,strPetTyp,objClaVal) {
      cintRowIndex = intRowIndex;
      cstrClassTabCde = strTabCde;
      cstrClassFldCde = strFldCde;
      cstrClassFldTxt = strFldTxt;
      cstrClassInpLen = strInpLen;
      cstrClassSelTyp = strSelTyp;
      cstrClassPetTyp = strPetTyp;
      cobjClassClaVal = objClaVal;
      doActivityStart(document.body);
      window.setTimeout('requestClaUpdate();',10);
   }
   function requestClaUpdate() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTSEL" TABCDE="'+cstrClassTabCde+'" FLDCDE="'+cstrClassFldCde+'" PETTYPE="'+cstrClassPetTyp+'"/>';
      doPostRequest('<%=strBase%>pts_sys_sel_list.asp',function(strResponse) {checkClaUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkClaUpdate(strResponse) {
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
         if (cstrClassSelTyp == '*OPT_SINGLE_LIST' || cstrClassSelTyp == '*OPT_MULTIPLE_LIST') {
            var objCllLstValue = document.getElementById('CLL_LstValue');
            var objCllClaValue = document.getElementById('CLL_ClaValue');
            objCllLstValue.options.length = 0;
            objCllLstValue.selectedIndex = -1;
            objCllClaValue.options.length = 0;
            objCllClaValue.selectedIndex = -1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'VALUE') {
                  objCllLstValue.options[objCllLstValue.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
               }
            }
            if (cobjClassClaVal != '') {
               for (var i=0;i<cobjClassClaVal.length;i++) {
                  objCllClaValue.options[i] = new Option(cobjClassClaVal[i].valtxt,cobjClassClaVal[i].valcde);
               }
            }
            displayScreen('dspClaList');
            objCllLstValue.focus();
         } else if (cstrClassSelTyp == '*NUMBER') {
            var objClnClaValue = document.getElementById('CLN_ClaValue');
            objClnClaValue.size = cstrClassInpLen;
            objClnClaValue.maxLength = cstrClassInpLen;
            objClnClaValue.value = '';
            if (cobjClassClaVal != null) {
               if (cobjClassClaVal.length != 0) {
                  objClnClaValue.value = cobjClassClaVal[0].valtxt;
               }
            }
            displayScreen('dspClaNumb');
            objClnClaValue.focus();
         } else if (cstrClassSelTyp == '*TEXT') {
            var objCltClaValue = document.getElementById('CLT_ClaValue');
            objCltClaValue.size = cstrClassInpLen;
            objCltClaValue.maxLength = cstrClassInpLen;
            objCltClaValue.value = '';
            if (cobjClassClaVal != null) {
               if (cobjClassClaVal.length != 0) {
                  objCltClaValue.value = cobjClassClaVal[0].valtxt;
               }
            }
            displayScreen('dspClaText');
            objCltClaValue.focus();
         } else {
            alert('Unknown Selection Type ('+cstrClassSelTyp+')');
         }
      }
   }

   //////////////////////////
   // Class List Functions //
   //////////////////////////
   function doClaListCancel() {
      cstrClassCancel();
   }
   function doClaListAccept() {
      if (!processForm()) {return;}
      var objCllClaValue = document.getElementById('CLL_ClaValue');
      var strMessage = '';
      if (cstrClassSelTyp == '*OPT_SINGLE_LIST' && objCllClaValue.options.length > 1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Only one selection is allowed';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var objValues = new Array();
      objValues.length = 0;
      if (objCllClaValue.options.length != 0) {
         for (var i=0;i<objCllClaValue.options.length;i++) {
            objValues[i] = new clsClaValue(objCllClaValue[i].value,objCllClaValue[i].text);
         }
      }
      cstrClassAccept(cintRowIndex,objValues);
   }
   function selectClaListValues() {
      var objCllLstValue = document.getElementById('CLL_LstValue');
      var objCllClaValue = document.getElementById('CLL_ClaValue');
      var bolFound;
      for (var i=0;i<objCllLstValue.options.length;i++) {
         if (objCllLstValue.options[i].selected == true) {
            bolFound = false;
            for (var j=0;j<objCllClaValue.options.length;j++) {
               if (objCllLstValue[i].value == objCllClaValue[j].value) {
                  bolFound = true;
                  break;
               }
            }
            if (!bolFound) {
               objCllClaValue.options[objCllClaValue.options.length] = new Option(objCllLstValue[i].text,objCllLstValue[i].value);
            }
         }
      }
      var objWork = new Array();
      var intIndex = 0
      for (var i=0;i<objCllClaValue.options.length;i++) {
         objWork[intIndex] = objCllClaValue[i];
         intIndex++;
      }
      objWork.sort(sortClaListValues);
      objCllClaValue.options.length = 0;
      objCllClaValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objCllClaValue.options[i] = objWork[i];
      }
   }
   function removeClaListValues() {
      var objCllClaValue = document.getElementById('CLL_ClaValue');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objCllClaValue.options.length;i++) {
         if (objCllClaValue.options[i].selected == false) {
            objWork[intIndex] = objCllClaValue[i];
            intIndex++;
         }
      }
      objCllClaValue.options.length = 0;
      objCllClaValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objCllClaValue.options[i] = objWork[i];
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

   ////////////////////////////
   // Class Number Functions //
   /////////////////////////////
   function doClaNumbCancel() {
      cstrClassCancel();
   }
   function doClaNumbAccept() {
      if (!processForm()) {return;}
      var objClnClaValue = document.getElementById('CLN_ClaValue');
      var objValues = new Array();
      objValues.length = 0;
      if (objClnClaValue.value != '') {
         objValues[0] = new clsClaValue('1',objClnClaValue.value);
      }
      cstrClassAccept(cintRowIndex,objValues);
   }

   //////////////////////////
   // Class Text Functions //
   //////////////////////////
   function doClaTextCancel() {
      cstrClassCancel();
   }
   function doClaTextAccept() {
      if (!processForm()) {return;}
      var objCltClaValue = document.getElementById('CLT_ClaValue');
      var objValues = new Array();
      objValues.length = 0;
      if (objCltClaValue.value != '') {
         objValues[0] = new clsClaValue('1',objCltClaValue.value);
      }
      cstrClassAccept(cintRowIndex,objValues);
   }

// -->
</script>