<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_tes_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the product test            //
'//           configuration functionality                        //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strBase
   dim strTarget
   dim strStatus
   dim strCharset
   dim strReturn
   dim strHeading
   dim objSecurity

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "pts_tes_config.asp"
   strHeading = "Test Maintenance"

   '//
   '// Get the base string
   '//
   strBase = GetBase()

   '//
   '// Get the status
   '//
   strStatus = GetStatus()

   '//
   '// Get the character set
   '//
   strCharset = GetCharSet()

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurityCheck("PTS_TES_CONFIG")
   if strReturn <> "*OK" then
      call PaintFatal
   else
      call PaintFunction
   end if

   '//
   '// Destroy references
   '//
   set objSecurity = nothing

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'////////////////////////////
'// Paint function routine //
'////////////////////////////
sub PaintFunction()%>
<html>
<script language="javascript">
<!--

   ///////////////////////
   // Generic Functions //
   ///////////////////////
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
         return '';
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

   ////////////////////
   // Load Functions //
   ////////////////////
   function loadFunction() {
      cobjScreens[0] = new clsScreen('dspPrompt','hedPrompt');
      cobjScreens[1] = new clsScreen('dspDefine','hedDefine');
      cobjScreens[2] = new clsScreen('dspKeyword','hedKeyword');
      cobjScreens[3] = new clsScreen('dspQuestion','hedQuestion');
      cobjScreens[4] = new clsScreen('dspQueDetail','hedQueDetail');
      cobjScreens[5] = new clsScreen('dspSample','hedSample');
      cobjScreens[6] = new clsScreen('dspSamDetail','hedSamDetail');
      cobjScreens[7] = new clsScreen('dspPanel','hedPanel');
    //  cobjScreens[8] = new clsScreen('dspAllocation','hedAllocation');
      cobjScreens[0].hedtxt = 'Test Prompt';
      cobjScreens[1].hedtxt = 'Test Maintenance';
      cobjScreens[2].hedtxt = 'Test Keyword Maintenance';
      cobjScreens[3].hedtxt = 'Test Question Maintenance';
      cobjScreens[4].hedtxt = 'Test Question Detail';
      cobjScreens[5].hedtxt = 'Test Sample Maintenance';
      cobjScreens[6].hedtxt = 'Test Sample Detail';
      cobjScreens[7].hedtxt = 'Test Panel Selection';
    //  cobjScreens[8].hedtxt = 'Test Allocation';
      initSearch();
      initSelect('dspPanel','Test');
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }

   ///////////////////////
   // Control Functions //
   ///////////////////////
   var cobjScreens = new Array();
   function clsScreen(strScrName,strHedName) {
      this.scrnam = strScrName;
      this.hednam = strHedName;
      this.hedtxt = '';
   }
   function displayScreen(strScreen) {
      var objScreen;
      var objHeading;
      for (var i=0;i<cobjScreens.length;i++) {
         objScreen = document.getElementById(cobjScreens[i].scrnam);
         objHeading = document.getElementById(cobjScreens[i].hednam);
         if (cobjScreens[i].scrnam == strScreen) {
            objScreen.style.display = 'block';
            objHeading.innerText = cobjScreens[i].hedtxt;
            objScreen.focus();
         } else {
            objScreen.style.display = 'none';
            objHeading.innerText = cobjScreens[i].hedtxt;
         }
      }
   }

   //////////////////////
   // Prompt Functions //
   //////////////////////
   function doPromptEnter() {
      if (!processForm()) {return;}
      if (document.getElementById('PRO_TesCode').value == '') {
         doPromptCreate('*PET');
      } else {
         doPromptUpdate();
      }
   }
   function doPromptUpdate() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doPromptCreate(strTarget) {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\',\''+strTarget+'\');',10);
   }
   function doPromptCopy() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for copy';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doPromptQuestion() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for question selection';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestQuestionUpdate(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doPromptPanel() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for panel selection';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestPanelUpdate(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*TEST','Test','pts_tes_search.asp',function() {doPromptTesCancel();},function(strCode,strText) {doPromptTesSelect(strCode,strText);});
   }
   function doPromptTesCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }
   function doPromptTesSelect(strCode,strText) {
      document.getElementById('PRO_TesCode').value = strCode;
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   var cintDefineType;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDTES" TESCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode,strTarget) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTTES" TESTAR="'+strTarget+'" TESCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYTES" TESCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function checkDefineLoad(strResponse) {
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
         if (cstrDefineMode == '*UPD') {
            cobjScreens[1].hedtxt = 'Update Test ('+cstrDefineCode+')';
         } else {
            cobjScreens[1].hedtxt = 'Create Test (*NEW)';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_TesCode').value = '';
         document.getElementById('DEF_TesText').value = '';
         document.getElementById('DEF_TesRnam').value = '';
         document.getElementById('DEF_TesRmid').value = '';
         document.getElementById('DEF_TesAtxt').value = '';
         document.getElementById('DEF_TesRtxt').value = '';
         document.getElementById('DEF_TesPtxt').value = '';
         document.getElementById('DEF_TesCtxt').value = '';
         document.getElementById('DEF_TesSdat').value = '';
         document.getElementById('DEF_TesFwek').value = '';
         document.getElementById('DEF_TesMlen').value = '';
         document.getElementById('DEF_TesMtem').value = '';
         document.getElementById('DEF_TesDcnt').value = '';
         var strTesComp;
         var strTesStat;
         var strTesGlop;
         var strTesType;
         var objTesComp = document.getElementById('DEF_TesComp');
         var objTesStat = document.getElementById('DEF_TesStat');
         var objTesGlop = document.getElementById('DEF_TesGlop');
         var objTesType = document.getElementById('DEF_TesType');
         var objTesKwrd = document.getElementById('DEF_TesKwrd');
         objTesComp.options.length = 0;
         objTesStat.options.length = 0;
         objTesGlop.options.length = 0;
         objTesType.options.length = 0;
         objTesKwrd.options.length = 0;
         document.getElementById('DEF_TesText').focus();
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'COM_LIST') {
               objTesComp.options[objTesComp.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'STA_LIST') {
               objTesStat.options[objTesStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'TYP_LIST') {
               objTesType.options[objTesType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'GLO_LIST') {
               objTesGlop.options[objTesGlop.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'KEYWORD') {
               objTesKwrd.options[objTesKwrd.options.length] = new Option(objElements[i].getAttribute('KEYWRD'),objElements[i].getAttribute('KEYWRD'));
            } else if (objElements[i].nodeName == 'TEST') {
               document.getElementById('DEF_TesCode').value = objElements[i].getAttribute('TESCDE');
               document.getElementById('DEF_TesText').value = objElements[i].getAttribute('TESTIT');
               document.getElementById('DEF_TesRnam').value = objElements[i].getAttribute('REQNAM');
               document.getElementById('DEF_TesRmid').value = objElements[i].getAttribute('REQMID');
               document.getElementById('DEF_TesAtxt').value = objElements[i].getAttribute('AIMTXT');
               document.getElementById('DEF_TesRtxt').value = objElements[i].getAttribute('REATXT');
               document.getElementById('DEF_TesPtxt').value = objElements[i].getAttribute('PRETXT');
               document.getElementById('DEF_TesCtxt').value = objElements[i].getAttribute('COMTXT');
               document.getElementById('DEF_TesSdat').value = objElements[i].getAttribute('STRDAT');
               document.getElementById('DEF_TesFwek').value = objElements[i].getAttribute('FLDWEK');
               document.getElementById('DEF_TesMlen').value = objElements[i].getAttribute('MEALEN');
               document.getElementById('DEF_TesMtem').value = objElements[i].getAttribute('MAXTEM');
               document.getElementById('DEF_TesDcnt').value = objElements[i].getAttribute('DAYCNT');
               strTesComp = objElements[i].getAttribute('TESCOM');
               strTesStat = objElements[i].getAttribute('TESSTA');
               strTesGlop = objElements[i].getAttribute('TESGLO');
               strTesType = objElements[i].getAttribute('TESTYP');
            }
         }
         objTesComp.selectedIndex = -1;
         for (var i=0;i<objTesComp.length;i++) {
            if (objTesComp.options[i].value == strTesComp) {
               objTesComp.options[i].selected = true;
               break;
            }
         }
         objTesStat.selectedIndex = -1;
         for (var i=0;i<objTesStat.length;i++) {
            if (objTesStat.options[i].value == strTesStat) {
               objTesStat.options[i].selected = true;
               break;
            }
         }
         objTesGlop.selectedIndex = -1;
         for (var i=0;i<objTesGlop.length;i++) {
            if (objTesGlop.options[i].value == strTesGlop) {
               objTesGlop.options[i].selected = true;
               break;
            }
         }
         cintDefineType = -1;
         objTesType.selectedIndex = -1;
         for (var i=0;i<objTesType.length;i++) {
            if (objTesType.options[i].value == strTesType) {
               objTesType.options[i].selected = true;
               cintDefineType = i;
               break;
            }
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objTesComp = document.getElementById('DEF_TesComp');
      var objTesStat = document.getElementById('DEF_TesStat');
      var objTesGlop = document.getElementById('DEF_TesGlop');
      var objTesType = document.getElementById('DEF_TesType');
      var objTesKwrd = document.getElementById('DEF_TesKwrd');
      if (cstrDefineMode == '*UPD' && objTesType.selectedIndex != cintDefineType) {
         if (confirm('The test type has been changed - Please confirm\r\npress OK continue (the existing allocation will be deleted)\r\npress Cancel to cancel update and return') == false) {
            return;
         }
      }
      var strMessage = '';
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*DEFTES"';
      strXML = strXML+' TESCDE="'+fixXML(document.getElementById('DEF_TesCode').value)+'"';
      strXML = strXML+' TESTIT="'+fixXML(document.getElementById('DEF_TesText').value)+'"';
      strXML = strXML+' TESCOM="'+fixXML(objTesComp.options[objTesComp.selectedIndex].value)+'"';
      strXML = strXML+' TESSTA="'+fixXML(objTesStat.options[objTesStat.selectedIndex].value)+'"';
      strXML = strXML+' TESGLO="'+fixXML(objTesGlop.options[objTesGlop.selectedIndex].value)+'"';
      strXML = strXML+' TESTYP="'+fixXML(objTesType.options[objTesType.selectedIndex].value)+'"';
      strXML = strXML+' REQNAM="'+fixXML(document.getElementById('DEF_TesRnam').value)+'"';
      strXML = strXML+' REQMID="'+fixXML(document.getElementById('DEF_TesRmid').value)+'"';
      strXML = strXML+' AIMTXT="'+fixXML(document.getElementById('DEF_TesAtxt').value)+'"';
      strXML = strXML+' REATXT="'+fixXML(document.getElementById('DEF_TesRtxt').value)+'"';
      strXML = strXML+' PRETXT="'+fixXML(document.getElementById('DEF_TesPtxt').value)+'"';
      strXML = strXML+' COMTXT="'+fixXML(document.getElementById('DEF_TesCtxt').value)+'"';
      strXML = strXML+' STRDAT="'+fixXML(document.getElementById('DEF_TesSdat').value)+'"';
      strXML = strXML+' FLDWEK="'+fixXML(document.getElementById('DEF_TesFwek').value)+'"';
      strXML = strXML+' MEALEN="'+fixXML(document.getElementById('DEF_TesMlen').value)+'"';
      strXML = strXML+' MAXTEM="'+fixXML(document.getElementById('DEF_TesMtem').value)+'"';
      strXML = strXML+' DAYCNT="'+fixXML(document.getElementById('DEF_TesDcnt').value)+'"';
      strXML = strXML+'>';
      for (var i=0;i<objTesKwrd.length;i++) {
         strXML = strXML+'<KEYWORD KEYWRD="'+fixXML(objTesKwrd.options[i].value)+'"/>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
   }
   function checkDefineAccept(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         if (strResponse.length > 3) {
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
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'CONFIRM') {
                  alert(objElements[i].getAttribute('CONTXT'));
               }
            }
         }
         displayScreen('dspPrompt');
         document.getElementById('PRO_TesCode').value = '';
         document.getElementById('PRO_TesCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').value = '';
      document.getElementById('PRO_TesCode').focus();
   }
   function doKeywordAdd() {
      cstrKeywordMode = '*ADD';
      var objKeyText = document.getElementById('KEY_KeyText');
      var strValue = '';
      objKeyText.value = strValue;
      displayScreen('dspKeyword');
      objKeyText.focus();
   }
   function doKeywordUpdate() {
      if (document.getElementById('DEF_TesKwrd').selectedIndex == -1) {
         alert('Keyword must be selected for update');
         return;
      }
      cstrKeywordMode = '*UPD';
      var objTesKwrd = document.getElementById('DEF_TesKwrd');
      var objKeyText = document.getElementById('KEY_KeyText');
      cintKeywordIndx = objTesKwrd.selectedIndex;
      var strValue = objTesKwrd.options[cintKeywordIndx].value;
      objKeyText.value = strValue;
      displayScreen('dspKeyword');
      objKeyText.focus();
   }
   function doKeywordDelete() {
      if (document.getElementById('DEF_TesKwrd').selectedIndex == -1) {
         alert('Keyword must be selected for delete');
         return;
      }
      var objTesKwrd = document.getElementById('DEF_TesKwrd');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objTesKwrd.options.length;i++) {
         if (objTesKwrd.options[i].selected == false) {
            objWork[intIndex] = objTesKwrd[i];
            intIndex++;
         }
      }
      objTesKwrd.options.length = 0;
      objTesKwrd.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objTesKwrd.options[i] = objWork[i];
      }
   }
   ///////////////////////
   // Keyword Functions //
   ///////////////////////
   var cstrKeywordMode;
   var cintKeywordIndx;
   function doKeywordCancel() {
      displayScreen('dspDefine');
      document.getElementById('DEF_TesKwrd').focus();
   }
   function doKeywordAccept() {
      if (!processForm()) {return;}
      var objTesKwrd = document.getElementById('DEF_TesKwrd');
      var objKeyText = document.getElementById('KEY_KeyText');
      var strMessage = '';
      if (objKeyText.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Keyword must be entered';
      }
      var bolFound = false;
      for (var i=0;i<objTesKwrd.options.length;i++) {
         if (objTesKwrd.options[i].value.toUpperCase() == objKeyText.value.toUpperCase()) {
            bolFound = true;
            break;
         }
      }
      if (bolFound) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Keyword already exists';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cstrKeywordMode == '*ADD') {
         objTesKwrd.options[objTesKwrd.options.length] = new Option(objKeyText.value.toUpperCase(),objKeyText.value.toUpperCase());
      } else if (cstrKeywordMode == '*UPD') {
         objTesKwrd.options[cintKeywordIndx].value = objKeyText.value.toUpperCase();
         objTesKwrd.options[cintKeywordIndx].text = objKeyText.value.toUpperCase();
      }
      displayScreen('dspDefine');
   }

   /////////////////////
   // Panel Functions //
   /////////////////////
   var cstrPanelTest;
   var cstrPanelTarget;
   function requestPanelUpdate(strCode) {
      cstrPanelTest = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVPAN" TESCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_panel_retrieve.asp',function(strResponse) {checkPanelUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkPanelUpdate(strResponse) {
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
         var strPetMult;
         var strSelTemp;
         var objPetMult = document.getElementById('PAN_PetMult');
         var objSelTemp = document.getElementById('PAN_SelTemp');
         objSelTemp.options.length = 0;
         objSelTemp.selectedIndex = -1;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
               document.getElementById('subPanel').innerText = objElements[i].getAttribute('TESTXT');
               cstrPanelTarget = objElements[i].getAttribute('TESTAR');
            } else if (objElements[i].nodeName == 'TEM_LIST') {
               objSelTemp.options[objSelTemp.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'PANEL') {
               document.getElementById('PAN_MemCount').value = objElements[i].getAttribute('MEMCNT');
               document.getElementById('PAN_ResCount').value = objElements[i].getAttribute('RESCNT');
               strPetMult = objElements[i].getAttribute('PETMLT');
            }
         }
         startSltInstance(cstrPanelTarget);
         putSltData(objElements);
         objPetMult.selectedIndex = -1;
         for (var i=0;i<objPetMult.length;i++) {
            if (objPetMult.options[i].value == strPetMult) {
               objPetMult.options[i].selected = true;
               break;
            }
         }
         displayScreen('dspPanel');
         document.getElementById('PAN_MemCount').focus();
      }
   }
   function doPanelAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PAN_MemCount').value < 1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Member count must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDPAN"';
      strXML = strXML+' TESCDE="'+fixXML(cstrPanelTest)+'"';
      strXML = strXML+' MEMCNT="'+fixXML(document.getElementById('PAN_MemCount').value)+'"';
      strXML = strXML+' RESCNT="'+fixXML(document.getElementById('PAN_RESCount').value)+'"';
      strXML = strXML+' PETMLT="'+fixXML(document.getElementById('PAN_PetMult').options[document.getElementById('PAN_PetMult').selectedIndex].value)+'"';
      strXML = strXML+'>';
      strXML = strXML + getSltData();
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestPanelAccept(\''+strXML+'\');',10);
   }
   function requestPanelAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_panel_update.asp',function(strResponse) {checkPanelAccept(strResponse);},false,streamXML(strXML));
   }
   function checkPanelAccept(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         if (strResponse.length > 3) {
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
         }
         displayScreen('dspPrompt');
         document.getElementById('PRO_TesCode').focus();
      }
   }
   function doPanelCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }
   function doPanelTemplate() {
      if (!processForm()) {return;}
      var objSelTemp = document.getElementById('PAN_SelTemp');
      var strMessage = '';
      if (objSelTemp.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection template must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (confirm('Please confirm the template selection\r\npress OK continue (all existing selection rules will be replaced by the selection template rules)\r\npress Cancel to cancel the request') == false) {
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*RTVTEM"';
      strXML = strXML+' STMCDE="'+fixXML(objSelTemp.options[objSelTemp.selectedIndex].value)+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestPanelTemplate(\''+strXML+'\');',10);
   }
   function requestPanelTemplate(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_panel_template.asp',function(strResponse) {checkPanelTemplate(strResponse);},false,streamXML(strXML));
   }
   function checkPanelTemplate(strResponse) {
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
         startSltInstance(cstrPanelTarget);
         putSltData(objElements);
         document.getElementById('tabSltRule').focus();
      }
   }

   ////////////////////////
   // Question Functions //
   ////////////////////////
   var cstrQuestionTest;
   var cstrQuestionTarget;
   var cintQuestionRow;
   var cobjQuestionDay;
   function clsQueDay() {
      this.daycde = '';
      this.queary = new Array();
   }
   function clsQueData(strQueCde,strQueTyp,strQueTxt) {
      this.quecde = strQueCde;
      this.quetyp = strQueTyp;
      this.quetxt = strQueTxt;
   }
   function requestQuestionUpdate(strCode) {
      cstrQuestionTest = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVQUE" TESCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_question.asp',function(strResponse) {checkQuestionUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkQuestionUpdate(strResponse) {
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
         cobjQuestionDay = new Array();
         var intIndex = -1;
         var strWeiCalc;
         var objWeiCalc = document.getElementById('QUE_WeiCalc');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
               document.getElementById('subQuestion').innerText = objElements[i].getAttribute('TESTXT');
               strWeiCalc = objElements[i].getAttribute('WEICAL');
               document.getElementById('QUE_WeiBowl').value = objElements[i].getAttribute('WEIBOL');
               document.getElementById('QUE_WeiOffr').value = objElements[i].getAttribute('WEIOFF');
               document.getElementById('QUE_WeiRemn').value = objElements[i].getAttribute('WEIREM');
            } else if (objElements[i].nodeName == 'DAY') {
               intIndex++;
               cobjQuestionDay[intIndex] = new clsQueDay();
               cobjQuestionDay[intIndex].daycde = objElements[i].getAttribute('DAYCDE');
            } else if (objElements[i].nodeName == 'QUESTION') {
               cobjQuestionDay[intIndex].queary[cobjQuestionDay[intIndex].queary.length] = new clsQueData(objElements[i].getAttribute('QUECDE'),objElements[i].getAttribute('QUETYP'),objElements[i].getAttribute('QUETXT'));
            }
         }
         objWeiCalc.selectedIndex = -1;
         for (var i=0;i<objWeiCalc.length;i++) {
            if (objWeiCalc.options[i].value == strWeiCalc) {
               objWeiCalc.options[i].selected = true;
               break;
            }
         }
         var objTable = document.getElementById('tabQuestion');
         var objRow;
         var objCell;
         for (var i=objTable.rows.length-1;i>=0;i--) {
            objTable.deleteRow(i);
         }
         for (var i=0;i<cobjQuestionDay.length;i++) {
            objRow = objTable.insertRow(-1);
            objRow.setAttribute('daycde',cobjQuestionDay[i].daycde);
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            objCell.innerHTML = '<a class="clsSelect" onClick="doQuestionUpdate(\''+objRow.rowIndex+'\');">Update</a>';
            objCell.className = 'clsLabelFN';
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(1);
            objCell.colSpan = 2;
            objCell.innerText = 'DAY '+cobjQuestionDay[i].daycde;
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
            for (var j=0;j<cobjQuestionDay[i].queary.length;j++) {
               objRow = objTable.insertRow(-1);
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               if (cobjQuestionDay[i].queary[j].quetyp == '1') {
                  objCell.innerText = 'General Question';
               } else {
                  objCell.innerText = 'Sample Question';
               }
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(2);
               objCell.colSpan = 1;
               objCell.innerText = cobjQuestionDay[i].queary[j].quetxt;
               objCell.className = 'clsLabelFN';
            }
         }
         displayScreen('dspQuestion');
         document.getElementById('QUE_WeiCalc').focus();
      }
   }
   function doQuestionAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
         //check for C1,C2.C3 duplicates
         //check c1,c2,c3 exist
      if (document.getElementById('PAN_MemCount').value < 1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Member count must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDQUE"';
      strXML = strXML+' TESCDE="'+fixXML(cstrQuestionTest)+'"';
      strXML = strXML+' WEICAL="'+fixXML(document.getElementById('QUE_WeiCalc').options[document.getElementById('QUE_WeiCalc').selectedIndex].value)+'"';
      strXML = strXML+' WEIBOL="'+fixXML(document.getElementById('QUE_WeiBowl').value)+'"';
      strXML = strXML+' WEIOFF="'+fixXML(document.getElementById('QUE_WeiOffr').value)+'"';
      strXML = strXML+' WEIREM="'+fixXML(document.getElementById('QUE_WeiRemn').value)+'"';
      strXML = strXML+'>';
      for (var i=0;i<cobjQuestionDay.length;i++) {
         strXML = strXML+'<DAY DAYCDE="'+cobjQuestionDay[i].daycde+'">';
         for (var j=0;j<cobjQuestionDay[i].queary.length;j++) {
            strXML = strXML+'<QUESTION QUECDE="'+cobjQuestionDay[i].queary[j].quecde+'" QUETYP="'+cobjQuestionDay[i].queary[j].quetyp+'"/>';
         }
         strXML = strXML+'</DAY>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestQuestionAccept(\''+strXML+'\');',10);
   }
   function requestQuestionAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_question.asp',function(strResponse) {checkQuestionAccept(strResponse);},false,streamXML(strXML));
   }
   function checkQuestionAccept(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         if (strResponse.length > 3) {
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
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_TesText').focus();
      }
   }
   function doQuestionCancel() {
      displayScreen('dspDefine');
      document.getElementById('DEF_TesText').focus();
   }
   function doQuestionSelect(strTarget) {
      if (!processForm()) {return;}
      cstrQuestionTarget = strTarget;
      startSchInstance('*QUESTION','Question','pts_que_search.asp',function() {doQuestionSelectCancel();},function(strCode,strText) {doQuestionSelectAccept(strCode,strText);});
   }
   function doQuestionSelectCancel() {
      displayScreen('dspQuestion');
      if (cstrQuestionTarget == 'W01') {
         document.getElementById('QUE_WeiBowl').focus();
      } else if (cstrQuestionTarget == 'W02') {
         document.getElementById('QUE_WeiOffr').focus();
      } else if (cstrQuestionTarget == 'W03') {
         document.getElementById('QUE_WeiRemn').focus();
      } else {
         document.getElementById('tabQuestion').focus();
      }
   }
   function doQuestionSelectAccept(strCode,strText) {
      if (cstrQuestionTarget == 'W01') {
         document.getElementById('QUE_WeiBowl').value = strCode;
         document.getElementById('QUE_WeiBowl').focus();
      } else if (cstrQuestionTarget == 'W02') {
         document.getElementById('QUE_WeiOffr').value = strCode;
         document.getElementById('QUE_WeiOffr').focus();
      } else if (cstrQuestionTarget == 'W03') {
         document.getElementById('WeiRemn').value = strCode;
         document.getElementById('WeiRemn').focus();
      } else {
         //find the row and insert
         //check for duplicates
         document.getElementById('tabQuestion').focus();
      }
      displayScreen('dspQuestion');
   }
   function doQuestionCopy() {
      //copy the questions to all other days
   }
   function doQuestionUpdate(intRow) {
      var objTable = document.getElementById('tabQuestion');
      cintQuestionRow = intRow;
      displayScreen('dspQueDetail');
    //  document.getElementById('QDT_GrpText').value = cobjSelectData[cintSelectRow].grptxt;
    //  document.getElementById('QDT_GrpPcnt').value = cobjSelectData[cintSelectRow].grppct;
    //  document.getElementById('QDT_GrpText').focus();
   }
   ///////////////////////////////
   // Question Detail Functions //
   ///////////////////////////////
   function doQueDetailCancel() {
      displayScreen('dspQuestion');
   }
   function doQueDetailAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
     // if (document.getElementById('SGR_GrpText').value == '') {
     //    if (strMessage != '') {strMessage = strMessage + '\r\n';}
     //    strMessage = strMessage + 'Selection group text must be entered';
     // }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      displayScreen('dspQuestion');
   }


   //////////////////////
   // Sample Functions //
   //////////////////////
   var cstrSampleTest;
   function requestSampleUpdate(strCode) {
      cstrSampleTest = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*GETSAM" TESCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_sample.asp',function(strResponse) {checkSampleUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkSampleUpdate(strResponse) {
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
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
               document.getElementById('subQuestion').innerText = objElements[i].getAttribute('TESTXT');
            } else if (objElements[i].nodeName == 'SAMPLE') {
               document.getElementById('SAM_MemCount').value = objElements[i].getAttribute('MEMCNT');
               document.getElementById('SAM_ResCount').value = objElements[i].getAttribute('RESCNT');
            }
         }
         displayScreen('dspSample');
         document.getElementById('tabSample').focus();
      }
   }
   function doSampleAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PAN_MemCount').value < 1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Member count must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDSAM"';
      strXML = strXML+' TESCDE="'+fixXML(cstrSampleTest)+'"';
      strXML = strXML+' MEMCNT="'+fixXML(document.getElementById('PAN_MemCount').value)+'"';
      strXML = strXML+' RESCNT="'+fixXML(document.getElementById('PAN_RESCount').value)+'"';
      strXML = strXML+' PETMLT="'+fixXML(document.getElementById('PAN_PetMult').options[document.getElementById('PAN_PetMult').selectedIndex].value)+'"';
      strXML = strXML+'>';
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestSampleAccept(\''+strXML+'\');',10);
   }
   function requestSampleAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_sample.asp',function(strResponse) {checkSampleAccept(strResponse);},false,streamXML(strXML));
   }
   function checkSampleAccept(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         if (strResponse.length > 3) {
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
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_TesText').focus();
      }
   }
   function doSampleCancel() {
      displayScreen('dspDefine');
      document.getElementById('DEF_TesText').focus();
   }
   function doQuestionSelect(strTarget) {
      if (!processForm()) {return;}
      cstrQuestionTarget = strTarget;
      startSchInstance('*QUESTION','Question','pts_que_search.asp',function() {doQuestionSelectCancel();},function(strCode,strText) {doQuestionSelectAccept(strCode,strText);});
   }
   function doSampleSelectCancel() {
      displayScreen('dspDefine');
      document.getElementById('tabSample').focus();
   }
   function doSampleSelectAccept(strCode,strText) {
      //find the row and insert
      //check for duplicates
      document.getElementById('tabSample').focus();
      displayScreen('dspSample');
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<!--#include file="ics_std_report.inc"-->
<!--#include file="pts_search_code.inc"-->
<!--#include file="pts_select_code.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_tes_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPromptEnter();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Test Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_TesCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=7 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCreate('*PET');">&nbsp;Create Pet Test&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCopy();">&nbsp;Copy&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptSearch();">&nbsp;Search&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=7 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptQuestion();">&nbsp;Questions&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptSample();">&nbsp;Samples&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptPanel();">&nbsp;Panel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptAllocation();">&nbsp;Allocation&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=7 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptQuestionnaire();">&nbsp;Questionnaire&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptClose();">&nbsp;Close Test&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCancel();">&nbsp;Cancel Test&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptDownload();">&nbsp;Download Results&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>

   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Test Maintenance</nobr></td>
         <input type="hidden" name="DEF_TesCode" value="">
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Title:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesText" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Company:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_TesComp"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_TesStat"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;GloPal:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_TesGlop"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_TesType"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Requestor Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesRnam" size="60" maxlength="60" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Requestor Mars Id:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesRmid" size="30" maxlength="30" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Aim:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesAtxt" size="80" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Reason:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesRtxt" size="80" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Prediction:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesPtxt" size="80" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Comment:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesCtxt" size="80" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Start Date (DD/MM/YYYY):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesSdat" size="10" maxlength="10" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Field Work Week (YYYYWW):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesFwek" size="6" maxlength="6" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Meal Length (minutes):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesMlen" size="3" maxlength="3" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Maximum Temperature:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesMtem" size="3" maxlength="3" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Number of Days:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesDcnt" size="3" maxlength="3" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=top colspan=1 nowrap><nobr>&nbsp;Keywords:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <table align=left border=0 cellpadding=0 cellspacing=2 cols=2>
               <tr>
                  <td class="clsLabelBB" align=left colspan=2 nowrap><nobr>
                     <table class="clsTable01" align=left cols=5 cellpadding="0" cellspacing="0">
                        <tr>
                           <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doKeywordAdd();">&nbsp;Add&nbsp;</a></nobr></td>
                           <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doKeywordUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                           <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td> 
                           <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doKeywordDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="DEF_TesKwrd" name="DEF_TesKwrd" style="width:200px" multiple size=5></select>
                  </nobr></td>
               </tr>
            </table>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspKeyword" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doKeywordAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedKeyword" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Keyword Maintenance</nobr></td>
      </tr>
      <tr>
         <td id="subKeyword" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Keyword:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="KEY_KeyText" size="32" maxlength="32" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doKeywordCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doKeywordAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>

   <table id="dspQuestion" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doQuestionAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedQuestion" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Questions</nobr></td>
      </tr>
      <tr>
         <td id="subQuestion" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Perform Weight Calculations:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="QUE_WeiCalc">
               <option value="0" selected>No
               <option value="1">Yes
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Weight Bowl Question:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="QUE_WeiBowl" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);doBlurQuestion('W01');"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=left colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=left cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQuestionSelect('W01');">&nbsp;Select&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Weight Offered Question:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="QUE_WeiOffr" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);doBlurQuestion('W02');"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=left colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=left cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQuestionSelect('W02');">&nbsp;Select&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Weight Remaining Question:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="QUE_WeiRemn" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);doBlurQuestion('W03');"></select></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=left colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=left cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQuestionSelect('W02');">&nbsp;Select&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="tabQuestion" class="clsTableBody" style="display:block;visibility:visible" align=left cellpadding="2" cellspacing="1"></table>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQuestionCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQuestionAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspQueDetail" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSampleAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedQueDetail" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Question Detail</nobr></td>
      </tr>
      <tr>
         <td id="subQueDetail" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQueDetailCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQueDetailAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>

   <table id="dspSample" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSampleAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSample" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Samples</nobr></td>
      </tr>
      <tr>
         <td id="subSample" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=2 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSampleAdd();">&nbsp;Add Sample&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="tabSample" class="clsTableBody" style="display:block;visibility:visible" align=left cellpadding="2" cellspacing="1"></table>
            </div>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSampleCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSampleAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspSamDetail" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSampleAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSamDetail" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Sample Detail</nobr></td>
      </tr>
      <tr>
         <td id="subSamDetail" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSamDetailCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSamDetailAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>

   <table id="dspPanel" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPanelAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPanel" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Test Panel Selection</nobr></td>
      </tr>
      <tr>
         <td id="subPanel" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Member Count:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PAN_MemCount" size="5" maxlength="5" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Reserve Count:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PAN_ResCount" size="5" maxlength="5" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Allow Multiple Household Pets:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="PAN_PetMult">
               <option value="0" selected>No
               <option value="1">Yes
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Selection Template:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><select class="clsInputBN" id="PAN_SelTemp"></select></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=left colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=left cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPanelTemplate();">&nbsp;Select&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
<!--#include file="pts_select_disp.inc"-->
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPanelCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPanelAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
<!--#include file="pts_search_html.inc"-->
<!--#include file="pts_select_html.inc"-->
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->