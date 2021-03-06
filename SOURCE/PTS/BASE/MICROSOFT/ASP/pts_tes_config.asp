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
   dim strValidation

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Check the querystring for variables
   '//
   strValidation = Request.QueryString("VAL")
   
   '//
   '// Initialise the script
   '//
   strTarget = "pts_tes_config.asp"
   strHeading = "Pet Test Maintenance"
   
   if strValidation = "1" then
    strHeading = "Pet Validation Test Maintenance"
   end if

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
<script type="text/javascript">
<!--

   ///////////////////////
   // Page Variables    //
   ///////////////////////
   var isValidation = <%if strValidation = "1" then%> true <%else%> false <%end if%>;

   ///////////////////////
   // Generic Functions //
   ///////////////////////
   document.onmouseover = function(evt) {
      var evt = evt || window.event;
      var objElement = evt.target || evt.srcElement;
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
   document.onmouseout = function(evt) {
      var evt = evt || window.event;
      var objElement = evt.target || evt.srcElement;
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
      cobjScreens[3] = new clsScreen('dspPreview','hedPreview');
      cobjScreens[4] = new clsScreen('dspQuestion','hedQuestion');
      cobjScreens[5] = new clsScreen('dspQueDetail','hedQueDetail');
      cobjScreens[6] = new clsScreen('dspSample','hedSample');
      cobjScreens[7] = new clsScreen('dspSamDetail','hedSamDetail');
      cobjScreens[8] = new clsScreen('dspSamSize','hedSamSize');
      cobjScreens[9] = new clsScreen('dspPanel','hedPanel');
      cobjScreens[10] = new clsScreen('dspAllocation','hedAllocation');
      cobjScreens[11] = new clsScreen('dspRelease','hedRelease');
      cobjScreens[12] = new clsScreen('dspResReport','hedResReport');
      cobjScreens[0].hedtxt = 'Pet ' + ((isValidation) ? ' Validation' : '') + 'Test Prompt';
      cobjScreens[1].hedtxt = 'Pet ' + ((isValidation) ? ' Validation' : '') + 'Test Maintenance';
      cobjScreens[2].hedtxt = 'Pet ' + ((isValidation) ? ' Validation' : '') + 'Test Keyword Maintenance';
      cobjScreens[3].hedtxt = 'Pet ' + ((isValidation) ? ' Validation' : '') + 'Test Preview';
      cobjScreens[4].hedtxt = 'Pet ' + ((isValidation) ? ' Validation' : '') + 'Test Question Review';
      cobjScreens[5].hedtxt = 'Pet ' + ((isValidation) ? ' Validation' : '') + 'Test Question Maintenance';
      cobjScreens[6].hedtxt = 'Pet ' + ((isValidation) ? ' Validation' : '') + 'Test Sample Review';
      cobjScreens[7].hedtxt = 'Pet ' + ((isValidation) ? ' Validation' : '') + 'Test Sample Maintenance';
      cobjScreens[8].hedtxt = 'Pet ' + ((isValidation) ? ' Validation' : '') + 'Test Sample Size';
      cobjScreens[9].hedtxt = 'Pet Test Panel Selection';
      cobjScreens[10].hedtxt = 'Pet Test Allocation';
      cobjScreens[11].hedtxt = 'Pet Test Release';
      cobjScreens[12].hedtxt = 'Pet Test Results Report';
      initSearch();
      initSelect('dspPanel','Test');
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
      
      // Check if this is a validation
      if (isValidation) {
        document.getElementById("notVal1").style.display = "none";
        document.getElementById("notVal2").style.display = "none";
        document.getElementById("notVal3").style.display = "none";
        document.getElementById("notVal4").style.display = "none";
        document.getElementById("notVal5").style.display = "none";
        document.getElementById("notVal6").style.display = "none";
        document.getElementById("notVal7").style.display = "none";
        document.getElementById("notVal8").style.display = "none";
        document.getElementById("notVal9").style.display = "none";
        document.getElementById("notVal10").style.display = "none";
        document.getElementById("notVal11").style.display = "none";
        document.getElementById("notVal12").style.display = "none";
        document.getElementById("notVal13").style.display = "none";
        document.getElementById("notVal14").style.display = "none";
        document.getElementById("notVal15").style.display = "none";
        document.getElementById("notVal16").style.display = "none";
        document.getElementById("notVal17").style.display = "none";
        document.getElementById("notVal18").style.display = "none";
        document.getElementById("notVal19").style.display = "none";
        document.getElementById("Val1").style.display = "block";
      }
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
   function doPromptCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
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
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*TEST','Test' + ((isValidation) ? ' Validation' : ''),'pts_tes_search.asp' + ((isValidation) ? '?VAL=1' : ''),function() {doPromptTesCancel();},function(strCode,strText) {doPromptTesSelect(strCode,strText);});
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
   function doPromptPreview() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for preview';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestPreview(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doPromptQuestion() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for question maintenance';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestQuestionUpdate(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doPromptSample() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for sample maintenance';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestSampleUpdate(\''+document.getElementById('PRO_TesCode').value+'\');',10);
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
   function doPromptAllocation() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for allocation';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestAllocationUpdate(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doPromptRelease() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for release';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestReleaseUpdate(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doReportPanel() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for panel reporting';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      requestPanelReport(document.getElementById('PRO_TesCode').value);
   }
   function doReportAllocation() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for allocation reporting';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      requestAllocationReport(document.getElementById('PRO_TesCode').value);
   }
   function doReportQuestionnaire() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for questionnaire reporting';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      requestQuestionnaireReport(document.getElementById('PRO_TesCode').value);
   }
   function doReportSelection() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for selection reporting';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      requestSelectionReport(document.getElementById('PRO_TesCode').value);
   }
   function doReportResults() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for results reporting';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestResReport(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   var cstrDefineStatus;
   var cstrDefineType;
   var cstrDefineVal;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDTES" TESCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTTES" TESCDE="'+fixXML(strCode)+'"/>';
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
         var strValType;
         var objTesComp = document.getElementById('DEF_TesComp');
         var objTesStat = document.getElementById('DEF_TesStat');
         var objTesGlop = document.getElementById('DEF_TesGlop');
         var objTesType = document.getElementById('DEF_TesType');
         var objValType = document.getElementById('DEF_ValType');
         var objTesKwrd = document.getElementById('DEF_TesKwrd');
         objTesComp.options.length = 0;
         objTesStat.options.length = 0;
         objTesGlop.options.length = 0;
         objTesType.options.length = 0;
         objValType.options.length = 0;
         objValType.options[objValType.options.length] = new Option('** Select **','');
         objTesKwrd.options.length = 0;
         document.getElementById('DEF_TesText').focus();
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'COM_LIST') {
               objTesComp.options[objTesComp.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'STA_LIST') {
               objTesStat.options[objTesStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'TYP_LIST') {
               objTesType.options[objTesType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'VAL_LIST') {
               objValType.options[objValType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
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
               strValType = objElements[i].getAttribute('VALTYP');
            }
         }
         objTesComp.selectedIndex = -1;
         for (var i=0;i<objTesComp.length;i++) {
            if (objTesComp.options[i].value == strTesComp) {
               objTesComp.options[i].selected = true;
               break;
            }
         }
         cstrDefineStatus = strTesStat;
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
         cstrDefineType = strTesType;
         objTesType.selectedIndex = -1;
         for (var i=0;i<objTesType.length;i++) {
            if (objTesType.options[i].value == strTesType) {
               objTesType.options[i].selected = true;
               break;
            }
         }
         cstrDefineVal = strValType;
         objValType.selectedIndex = -1;
         for (var i=0;i<objValType.length;i++) {
            if (objValType.options[i].value == strValType) {
               objValType.options[i].selected = true;
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
      var objValType = document.getElementById('DEF_ValType');
      var objTesKwrd = document.getElementById('DEF_TesKwrd');
      var strMessage = '';
      if (isValidation && (objValType.selectedIndex == -1 || objValType.options[objValType.selectedIndex].value == '')) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation type must be selected';
      }
      else if (cstrDefineMode == '*UPD') {
         if (!isValidation && objTesType.options[objTesType.selectedIndex].value != cstrDefineType) {
            if (confirm('The test type has been changed - Please confirm\r\npress OK continue (any existing allocation and response data will be deleted)\r\npress Cancel to cancel update and return') == false) {
               return;
            }
         }
         if (isValidation && objValType.options[objValType.selectedIndex].value != cstrDefineVal) {
            if (confirm('The validation type has been changed - Please confirm\r\npress OK continue (any existing response data will be deleted)\r\npress Cancel to cancel update and return') == false) {
               return;
            }
         }
         if (objTesStat.options[objTesStat.selectedIndex].value == '1' && (cstrDefineStatus == '3' || cstrDefineStatus == '4')) {
            if (confirm('The test status has been set to Raised from Results Entered or Closed - Please confirm\r\npress OK continue (any existing response data will be deleted)\r\npress Cancel to cancel update and return') == false) {
               return;
            }
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*DEFTES"';
      if (cstrDefineMode == '*CPY') {
         strXML = strXML+' CPYCDE="'+fixXML(cstrDefineCode)+'"';
      }
      strXML = strXML+' ISVAL="'+((isValidation)?'1':'0')+'"';
      strXML = strXML+' TESCDE="'+fixXML(document.getElementById('DEF_TesCode').value)+'"';
      strXML = strXML+' TESTIT="'+fixXML(document.getElementById('DEF_TesText').value.toUpperCase())+'"';
      strXML = strXML+' TESCOM="'+fixXML(objTesComp.options[objTesComp.selectedIndex].value)+'"';
      strXML = strXML+' TESSTA="'+fixXML(objTesStat.options[objTesStat.selectedIndex].value)+'"';
      strXML = strXML+' TESGLO="'+fixXML(objTesGlop.options[objTesGlop.selectedIndex].value)+'"';
      strXML = strXML+' TESTYP="'+fixXML(objTesType.options[objTesType.selectedIndex].value)+'"';
      strXML = strXML+' VALTYP="'+((isValidation)?fixXML(objValType.options[objValType.selectedIndex].value):"")+'"';
      strXML = strXML+' REQNAM="'+fixXML(document.getElementById('DEF_TesRnam').value.toUpperCase())+'"';
      strXML = strXML+' REQMID="'+fixXML(document.getElementById('DEF_TesRmid').value.toUpperCase())+'"';
      strXML = strXML+' AIMTXT="'+fixXML(document.getElementById('DEF_TesAtxt').value.toUpperCase())+'"';
      strXML = strXML+' REATXT="'+fixXML(document.getElementById('DEF_TesRtxt').value.toUpperCase())+'"';
      strXML = strXML+' PRETXT="'+fixXML(document.getElementById('DEF_TesPtxt').value.toUpperCase())+'"';
      strXML = strXML+' COMTXT="'+fixXML(document.getElementById('DEF_TesCtxt').value.toUpperCase())+'"';
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
         document.getElementById('PRO_TesCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
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

   ///////////////////////
   // Preview Functions //
   ///////////////////////
   var cstrPreviewTestCode;
   function requestPreview(strCode) {
      cstrQuestionTestCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVPVW" TESCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_preview_retrieve.asp',function(strResponse) {checkPreview(strResponse);},false,streamXML(strXML));
   }
   function checkPreview(strResponse) {
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
         document.getElementById('PRE_QueDta').innerHTML = 'No';
         document.getElementById('PRE_SamDta').innerHTML = 'No';
         document.getElementById('PRE_PanDta').innerHTML = 'No';
         document.getElementById('PRE_AlcDta').innerHTML = 'No';
         document.getElementById('PRE_ResDta').innerHTML = 'No';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
               document.getElementById('subPreview').innerHTML = objElements[i].getAttribute('TESTXT');
               if (objElements[i].getAttribute('QUEDTA') == '1') {
                  document.getElementById('PRE_QueDta').innerHTML = 'YES';
               }
               if (objElements[i].getAttribute('SAMDTA') == '1') {
                  document.getElementById('PRE_SamDta').innerHTML = 'YES';
               }
               if (objElements[i].getAttribute('PANDTA') == '1') {
                  document.getElementById('PRE_PanDta').innerHTML = 'YES';
               }
               if (objElements[i].getAttribute('ALCDTA') == '1') {
                  document.getElementById('PRE_AlcDta').innerHTML = 'YES';
               }
               if (objElements[i].getAttribute('RESDTA') == '1') {
                  document.getElementById('PRE_ResDta').innerHTML = 'YES';
               }
            }
         }
         displayScreen('dspPreview');
      }
   }
   function doPreviewCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }

   ////////////////////////
   // Question Functions //
   ////////////////////////
   var cstrQuestionTestCode;
   var cstrQuestionTestText;
   var cstrQuestionTestStatus;
   var cstrQuestionTarget;
   var cintQuestionRow;
   var cobjQuestionDay;
   var cstrQuestionResponse;
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
      cstrQuestionTestCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVQUE" TESCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_question_retrieve.asp',function(strResponse) {checkQuestionUpdate(strResponse);},false,streamXML(strXML));
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
         cstrQuestionResponse = '0';
         cobjQuestionDay = new Array();
         var intIndex = -1;
         var strWeiCalc;
         var objWeiCalc = document.getElementById('QUE_WeiCalc');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
               cstrQuestionTestText = objElements[i].getAttribute('TESTXT');
               cstrQuestionTestStatus = objElements[i].getAttribute('TESSTA');
               cstrQuestionResponse = objElements[i].getAttribute('RESDTA');
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
         loadQuestionData();
         document.getElementById('subQuestion').innerText = cstrQuestionTestText;
         displayScreen('dspQuestion');
         document.getElementById('QUE_WeiCalc').focus();
         document.getElementById('divQuestion').scrollTop = 0;
         document.getElementById('divQuestion').scrollLeft = 0;
      }
   }
   function loadQuestionData() {
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
         objCell.colSpan = 2;
         if (i == 0 && cobjQuestionDay.length > 1) {
            objCell.innerHTML = '<a class="clsSelect" onClick="doQuestionUpdate(\''+i+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doQuestionCopy();">Copy</a>&nbsp;-&nbsp;DAY '+cobjQuestionDay[i].daycde;
         } else {
            objCell.innerHTML = '<a class="clsSelect" onClick="doQuestionUpdate(\''+i+'\');">Update</a>&nbsp;-&nbsp;DAY '+cobjQuestionDay[i].daycde;
         }
         objCell.className = 'clsLabelFB';
         objCell.style.whiteSpace = 'nowrap';
         for (var j=0;j<cobjQuestionDay[i].queary.length;j++) {
            objRow = objTable.insertRow(-1);
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            if (cobjQuestionDay[i].queary[j].quetyp == '1') {
               objCell.innerText = 'General Question';
               objCell.className = 'clsLabelFB';
            } else {
               objCell.innerText = 'Sample Question';
               objCell.className = 'clsLabelFN';
            }
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(1);
            objCell.colSpan = 1;
            objCell.innerText = cobjQuestionDay[i].queary[j].quetxt;
            objCell.className = 'clsLabelFN';
            objCell.style.whiteSpace = 'nowrap';
         }
      }
   }
   function doQuestionAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (cstrQuestionTestStatus != '1') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test must be status Raised for question update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cstrQuestionResponse == '1') {
         if (confirm('Response data exists for this test - Please confirm the question update\r\npress OK continue (the existing response data will be removed)\r\npress Cancel to cancel the request') == false) {
            return;
         }
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDQUE"';
      strXML = strXML+' TESCDE="'+fixXML(cstrQuestionTestCode)+'"';
      strXML = strXML+' WEICAL="'+fixXML(document.getElementById('QUE_WeiCalc').options[document.getElementById('QUE_WeiCalc').selectedIndex].value)+'"';
      strXML = strXML+' WEIBOL="'+fixXML(document.getElementById('QUE_WeiBowl').value)+'"';
      strXML = strXML+' WEIOFF="'+fixXML(document.getElementById('QUE_WeiOffr').value)+'"';
      strXML = strXML+' WEIREM="'+fixXML(document.getElementById('QUE_WeiRemn').value)+'"';
      strXML = strXML+'>';
      for (var i=0;i<cobjQuestionDay.length;i++) {
         strXML = strXML+'<DAY DAYCDE="'+cobjQuestionDay[i].daycde+'">';
         for (var j=0;j<cobjQuestionDay[i].queary.length;j++) {
            strXML = strXML+'<QUESTION QUECDE="'+fixXML(cobjQuestionDay[i].queary[j].quecde)+'" QUETYP="'+fixXML(cobjQuestionDay[i].queary[j].quetyp)+'"/>';
         }
         strXML = strXML+'</DAY>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestQuestionAccept(\''+strXML+'\');',10);
   }
   function requestQuestionAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_question_update.asp',function(strResponse) {checkQuestionAccept(strResponse);},false,streamXML(strXML));
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
         displayScreen('dspPrompt');
         document.getElementById('PRO_TesCode').focus();
      }
   }
   function doQuestionCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
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
      displayScreen('dspQuestion');
      if (cstrQuestionTarget == 'W01') {
         document.getElementById('QUE_WeiBowl').value = strCode;
         document.getElementById('QUE_WeiBowl').focus();
      } else if (cstrQuestionTarget == 'W02') {
         document.getElementById('QUE_WeiOffr').value = strCode;
         document.getElementById('QUE_WeiOffr').focus();
      } else if (cstrQuestionTarget == 'W03') {
         document.getElementById('WeiRemn').value = strCode;
         document.getElementById('WeiRemn').focus();
      }
   }
   function doQuestionUpdate(intRow) {
      cintQuestionRow = intRow;
      document.getElementById('subQueDetail').innerText = cstrQuestionTestText+' - Day '+cobjQuestionDay[cintQuestionRow].daycde;
      displayScreen('dspQueDetail');
      document.getElementById('QUE_QueCode').value = '';
      document.getElementById('QUE_QueType').selectedIndex = 1;
      var objQueList = document.getElementById('QUE_QueList');
      objQueList.options.length = 0;
      objQueList.selectedIndex = 0;
      var strText;
      var objQueAry = cobjQuestionDay[cintQuestionRow].queary;
      for (var i=0;i<objQueAry.length;i++) {
         if (objQueAry[i].quetyp == '1') {
            strText = 'General - '+objQueAry[i].quetxt;
         } else {
            strText = 'Sample - '+objQueAry[i].quetxt;
         }
         objQueList.options[objQueList.options.length] = new Option(strText,objQueAry[i].quecde);
         objQueList.options[objQueList.options.length-1].setAttribute('quecde',objQueAry[i].quecde);
         objQueList.options[objQueList.options.length-1].setAttribute('quetyp',objQueAry[i].quetyp);
         objQueList.options[objQueList.options.length-1].setAttribute('quetxt',objQueAry[i].quetxt);
      }
      objQueList.focus();
   }
   function doQuestionCopy() {
      if (confirm('Please confirm the question copy\r\npress OK continue (all Day 1 questions will be copied to all other days and replace existing questions for these days)\r\npress Cancel to cancel the request') == false) {
         return;
      }
      var objSrcAry = cobjQuestionDay[0].queary;
      var objTarAry;
      for (var i=1;i<cobjQuestionDay.length;i++) {
         objTarAry = cobjQuestionDay[i].queary;
         objTarAry.length = 0;
         for (var j=0;j<objSrcAry.length;j++) {
            objTarAry[j] = new clsQueData(objSrcAry[j].quecde,objSrcAry[j].quetyp,objSrcAry[j].quetxt);
         }
      }
      loadQuestionData();
   }
   ///////////////////////////////
   // Question Detail Functions //
   ///////////////////////////////
   function doQueDetailAdd() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('QUE_QueCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Question code must be entered';
      }
      if (document.getElementById('QUE_QueType').selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Question type must be selected';
      }
      var objQueList = document.getElementById('QUE_QueList');
      for (var i=0;i<objQueList.options.length;i++) {
         if (objQueList.options[i].getAttribute('quecde') == document.getElementById('QUE_QueCode').value) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Question code already exists in the day';
            break;
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var objQueCode = document.getElementById('QUE_QueCode');
      var objQueType = document.getElementById('QUE_QueType');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*SELQUE"';
      strXML = strXML+' QUECDE="'+fixXML(objQueCode.value)+'"';
      strXML = strXML+' QUETYP="'+fixXML(objQueType[objQueType.selectedIndex].value)+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestQueDetailSelect(\''+strXML+'\');',10);
   }
   function requestQueDetailSelect(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_question_select.asp',function(strResponse) {checkQueDetailSelect(strResponse);},false,streamXML(strXML));
   }
   function checkQueDetailSelect(strResponse) {
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
         var strQueCode;
         var strQueType;
         var strQueText;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'QUESTION') {
               strQueCode = objElements[i].getAttribute('QUECDE');
               strQueType = objElements[i].getAttribute('QUETYP');
               strQueText = objElements[i].getAttribute('QUETXT');
            }
         }
         var strText
         if (strQueType == '1') {
            strText = 'General - '+strQueText;
         } else {
            strText = 'Sample - '+strQueText;
         }
         var objQueList = document.getElementById('QUE_QueList');
         objQueList.options[objQueList.options.length] = new Option(strText,strQueCode);
         objQueList.options[objQueList.options.length-1].setAttribute('quecde',strQueCode);
         objQueList.options[objQueList.options.length-1].setAttribute('quetyp',strQueType);
         objQueList.options[objQueList.options.length-1].setAttribute('quetxt',strQueText);
         objQueList.focus();
         document.getElementById('QUE_QueCode').value = '';
         document.getElementById('QUE_QueType').selectedIndex = 1;
      }
   }
   function doQueDetailDelete() {
      if (document.getElementById('QUE_QueList').selectedIndex == -1) {
         alert('Question must be selected for delete');
         return;
      }
      var objQueList = document.getElementById('QUE_QueList');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objQueList.options.length;i++) {
         if (objQueList.options[i].selected == false) {
            objWork[intIndex] = objQueList[i];
            intIndex++;
         }
      }
      objQueList.options.length = 0;
      objQueList.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objQueList.options[i] = objWork[i];
      }
   }
   function doQueDetailSortUp() {
      var intIndex;
      var intSelect;
      var objQueList = document.getElementById('QUE_QueList');
      intSelect = 0;
      for (var i=0;i<objQueList.options.length;i++) {
         if (objQueList.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one question can be selected to move up');
         return;
      }
      if (intSelect == 1 && intIndex > 0) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objQueList.options[intIndex-1].value;
         aryA[1] = objQueList.options[intIndex-1].text;
         aryA[2] = objQueList.options[intIndex-1].getAttribute('quecde');
         aryA[3] = objQueList.options[intIndex-1].getAttribute('quetyp');
         aryA[4] = objQueList.options[intIndex-1].getAttribute('quetxt');
         aryB[0] = objQueList.options[intIndex].value;
         aryB[1] = objQueList.options[intIndex].text;
         aryB[2] = objQueList.options[intIndex].getAttribute('quecde');
         aryB[3] = objQueList.options[intIndex].getAttribute('quetyp');
         aryB[4] = objQueList.options[intIndex].getAttribute('quetxt');
         objQueList.options[intIndex-1].value = aryB[0];
         objQueList.options[intIndex-1].text = aryB[1];
         objQueList.options[intIndex-1].setAttribute('quecde',aryB[2]);
         objQueList.options[intIndex-1].setAttribute('quetyp',aryB[3]);
         objQueList.options[intIndex-1].setAttribute('quetxt',aryB[4]);
         objQueList.options[intIndex-1].selected = true;
         objQueList.options[intIndex].value = aryA[0];
         objQueList.options[intIndex].text = aryA[1];
         objQueList.options[intIndex].setAttribute('quecde',aryA[2]);
         objQueList.options[intIndex].setAttribute('quetyp',aryA[3]);
         objQueList.options[intIndex].setAttribute('quetxt',aryA[4]);
         objQueList.options[intIndex].selected = false;
      }
   }
   function doQueDetailSortDown() {
      var intIndex;
      var intSelect;
      var objQueList = document.getElementById('QUE_QueList');
      intSelect = 0;
      for (var i=0;i<objQueList.options.length;i++) {
         if (objQueList.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one question can be selected to move down');
         return;
      }
      if (intSelect == 1 && intIndex < objQueList.options.length-1) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objQueList.options[intIndex+1].value;
         aryA[1] = objQueList.options[intIndex+1].text;
         aryA[2] = objQueList.options[intIndex+1].getAttribute('quecde');
         aryA[3] = objQueList.options[intIndex+1].getAttribute('quetyp');
         aryA[4] = objQueList.options[intIndex+1].getAttribute('quetxt');
         aryB[0] = objQueList.options[intIndex].value;
         aryB[1] = objQueList.options[intIndex].text;
         aryB[2] = objQueList.options[intIndex].getAttribute('quecde');
         aryB[3] = objQueList.options[intIndex].getAttribute('quetyp');
         aryB[4] = objQueList.options[intIndex].getAttribute('quetxt');
         objQueList.options[intIndex+1].value = aryB[0];
         objQueList.options[intIndex+1].text = aryB[1];
         objQueList.options[intIndex+1].setAttribute('quecde',aryB[2]);
         objQueList.options[intIndex+1].setAttribute('quetyp',aryB[3]);
         objQueList.options[intIndex+1].setAttribute('quetxt',aryB[4]);
         objQueList.options[intIndex+1].selected = true;
         objQueList.options[intIndex].value = aryA[0];
         objQueList.options[intIndex].text = aryA[1];
         objQueList.options[intIndex].setAttribute('quecde',aryA[2]);
         objQueList.options[intIndex].setAttribute('quetyp',aryA[3]);
         objQueList.options[intIndex].setAttribute('quetxt',aryA[4]);
         objQueList.options[intIndex].selected = false;
      }
   }
   function doQueDetailSelect() {
      if (!processForm()) {return;}
      startSchInstance('*QUESTION','Question','pts_que_search.asp',function() {doQueDetailSelectCancel();},function(strCode,strText) {doQueDetailSelectAccept(strCode,strText);});
   }
   function doQueDetailSelectCancel() {
      displayScreen('dspQueDetail');
      document.getElementById('QUE_QueCode').focus();
   }
   function doQueDetailSelectAccept(strCode,strText) {
      displayScreen('dspQueDetail');
      document.getElementById('QUE_QueCode').value = strCode;
      document.getElementById('QUE_QueCode').focus();
   }
   function doQueDetailCancel() {
      displayScreen('dspQuestion');
   }
   function doQueDetailAccept() {
      if (!processForm()) {return;}
      var objQueList = document.getElementById('QUE_QueList');
      var objQueAry = cobjQuestionDay[cintQuestionRow].queary;
      objQueAry.length = 0;
      var intIndex = 0;
      for (var i=0;i<objQueList.options.length;i++) {
         objQueAry[intIndex] = new clsQueData(objQueList.options[i].getAttribute('quecde'),objQueList.options[i].getAttribute('quetyp'),objQueList.options[i].getAttribute('quetxt'));
         intIndex++;
      }
      loadQuestionData();
      displayScreen('dspQuestion');
   }

   //////////////////////
   // Sample Functions //
   //////////////////////
   var cstrSampleTestCode;
   var cstrSampleTestText;
   var cstrSampleTestStatus;
   var cintSampleRow;
   var cintSampleSize;
   var cstrSampleCode;
   var cobjSampleData;
   var cstrSampleAllocation;
   var cstrSampleResponse;
   function clsSamData() {
      this.samcde = '';
      this.samtxt = '';
      this.rptcde = '';
      this.mktcde = '';
      this.alscde = '';
      this.sizary = new Array();
   }
   function clsSamSize(strSizCde,strSizTxt,strFedQty,strFedTxt) {
      this.sizcde = strSizCde;
      this.siztxt = strSizTxt;
      this.fedqty = strFedQty;
      this.fedtxt = strFedTxt;
   }
   function requestSampleUpdate(strCode) {
      cstrSampleTestCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVSAM" TESCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_sample_retrieve.asp',function(strResponse) {checkSampleUpdate(strResponse);},false,streamXML(strXML));
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
         cstrSampleAllocation = '0';
         cstrSampleResponse = '0';
         cobjSampleData = new Array();
         var intIndex = -1;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
               cstrSampleTestText = objElements[i].getAttribute('TESTXT');
               cstrSampleTestStatus = objElements[i].getAttribute('TESSTA');
               cstrSampleAllocation = objElements[i].getAttribute('ALCDTA');
               cstrSampleResponse = objElements[i].getAttribute('RESDTA');
            } else if (objElements[i].nodeName == 'SAMPLE') {
               intIndex++;
               cobjSampleData[intIndex] = new clsSamData();
               cobjSampleData[intIndex].samcde = objElements[i].getAttribute('SAMCDE');
               cobjSampleData[intIndex].samtxt = objElements[i].getAttribute('SAMTXT');
               cobjSampleData[intIndex].rptcde = objElements[i].getAttribute('RPTCDE');
               cobjSampleData[intIndex].mktcde = objElements[i].getAttribute('MKTCDE');
               cobjSampleData[intIndex].alscde = objElements[i].getAttribute('ALSCDE');
            } else if (objElements[i].nodeName == 'FEEDING') {
               cobjSampleData[intIndex].sizary[cobjSampleData[intIndex].sizary.length] = new clsSamSize(objElements[i].getAttribute('SIZCDE'),objElements[i].getAttribute('SIZTXT'),objElements[i].getAttribute('FEDQTY'),objElements[i].getAttribute('FEDTXT'));
            }
         }
         loadSampleData();
         document.getElementById('subSample').innerText = cstrSampleTestText;
         displayScreen('dspSample');
         document.getElementById('tabSample').focus();
         document.getElementById('divSample').scrollTop = 0;
         document.getElementById('divSample').scrollLeft = 0;
      }
   }
   function loadSampleData() {
      var objTable = document.getElementById('tabSample');
      var objRow;
      var objCell;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      for (var i=0;i<cobjSampleData.length;i++) {
         objRow = objTable.insertRow(-1);
         objRow.setAttribute('samcde',cobjSampleData[i].samcde);
         objCell = objRow.insertCell(0);
         objCell.colSpan = 1;
         objCell.innerHTML = '<a class="clsSelect" onClick="doSampleUpdate(\''+i+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSampleDelete(\''+i+'\');">Delete</a>&nbsp;-&nbsp;'+cobjSampleData[i].samtxt;
         objCell.className = 'clsLabelFB';
         objCell.style.whiteSpace = 'nowrap';
         for (var j=0;j<cobjSampleData[i].sizary.length;j++) {
            objRow = objTable.insertRow(-1);
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            objCell.innerHTML = '<a class="clsSelect" onClick="doSampleSizeUpdate(\''+i+'\',\''+j+'\');">Update</a>&nbsp;-&nbsp;'+cobjSampleData[i].sizary[j].siztxt;
            if (cobjSampleData[i].sizary[j].fedqty != '') {
               objCell.innerHTML = objCell.innerHTML+' - Unit Quantity ('+cobjSampleData[i].sizary[j].fedqty+')';
            }
            if (cobjSampleData[i].sizary[j].fedtxt != '') {
               objCell.innerHTML = objCell.innerHTML+' - '+cobjSampleData[i].sizary[j].fedtxt;
            }
            objCell.className = 'clsLabelFN';
            objCell.style.whiteSpace = 'nowrap';
         }
      }
   }
   function doSampleAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (cstrSampleTestStatus != '1') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test must be status Raised for sample update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cstrSampleAllocation == '1' || cstrSampleResponse == '1') {
         if (confirm('Allocation and or response data exists for this test - Please confirm the sample update\r\npress OK continue (the existing allocation and response data will be removed)\r\npress Cancel to cancel the request') == false) {
            return;
         }
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDSAM"';
      strXML = strXML+' TESCDE="'+fixXML(cstrSampleTestCode)+'"';
      strXML = strXML+'>';
      for (var i=0;i<cobjSampleData.length;i++) {
         strXML = strXML+'<SAMPLE SAMCDE="'+fixXML(cobjSampleData[i].samcde)+'"';
         strXML = strXML+' RPTCDE="'+fixXML(cobjSampleData[i].rptcde)+'"';
         strXML = strXML+' MKTCDE="'+fixXML(cobjSampleData[i].mktcde)+'"';
         strXML = strXML+' ALSCDE="'+fixXML(cobjSampleData[i].alscde)+'">';
         for (var j=0;j<cobjSampleData[i].sizary.length;j++) {
            strXML = strXML+'<FEEDING SIZCDE="'+fixXML(cobjSampleData[i].sizary[j].sizcde)+'" FEDQTY="'+fixXML(cobjSampleData[i].sizary[j].fedqty)+'" FEDTXT="'+fixXML(cobjSampleData[i].sizary[j].fedtxt)+'"/>';
         }
         strXML = strXML+'</SAMPLE>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestSampleAccept(\''+strXML+'\');',10);
   }
   function requestSampleAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_sample_update.asp',function(strResponse) {checkSampleAccept(strResponse);},false,streamXML(strXML));
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
         displayScreen('dspPrompt');
         document.getElementById('PRO_TesCode').focus();
      }
   }
   function doSampleCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }
   function doSampleAdd() {
      cintSampleRow = -1;
      cstrSampleCode = '';
      document.getElementById('subSamDetail').innerText = cstrSampleTestText;
      document.getElementById('addSamDetail').style.display = 'block';
      displayScreen('dspSamDetail');
      document.getElementById('SAM_SamCode').value = '';
      document.getElementById('SAM_RptCode').value = '';
      document.getElementById('SAM_MktCode').value = '';
      document.getElementById('SAM_AlsCode').value = '';
      document.getElementById('SAM_SamCode').focus();
   }
   function doSampleUpdate(intRow) {
      cintSampleRow = intRow;
      cstrSampleCode = cobjSampleData[cintSampleRow].samcde;
      document.getElementById('addSamDetail').style.display = 'none';
      document.getElementById('subSamDetail').innerText = cstrSampleTestText+' - Sample '+cobjSampleData[cintSampleRow].samcde;
      displayScreen('dspSamDetail');
      document.getElementById('SAM_RptCode').value = cobjSampleData[cintSampleRow].rptcde;
      document.getElementById('SAM_MktCode').value = cobjSampleData[cintSampleRow].mktcde;
      document.getElementById('SAM_AlsCode').value = cobjSampleData[cintSampleRow].alscde;
      document.getElementById('SAM_RptCode').focus();
   }
   function doSampleDelete(intRow) {
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<cobjSampleData.length;i++) {
         if (i != intRow) {
            objWork[intIndex] = cobjSampleData[i];
            intIndex++;
         }
      }
      cobjSampleData.length = 0;
      for (var i=0;i<objWork.length;i++) {
         cobjSampleData[i] = objWork[i];
      }
      loadSampleData();
   }
   function doSampleSizeUpdate(intRow,intSize) {
      cintSampleRow = intRow;
      cintSampleSize = intSize;
      document.getElementById('subSamSize').innerText = cstrSampleTestText+' - Sample '+cobjSampleData[cintSampleRow].samcde+' - Size '+cobjSampleData[cintSampleRow].sizary[cintSampleSize].siztxt;
      displayScreen('dspSamSize');
      document.getElementById('SAM_FedQnty').value = cobjSampleData[cintSampleRow].sizary[cintSampleSize].fedqty;
      document.getElementById('SAM_FedText').value = cobjSampleData[cintSampleRow].sizary[cintSampleSize].fedtxt;
      document.getElementById('SAM_FedQnty').focus();
   }
   /////////////////////////////
   // Sample Detail Functions //
   /////////////////////////////
   function doSamDetailSelect() {
      if (!processForm()) {return;}
      startSchInstance('*SAMPLE','Sample','pts_sam_search.asp',function() {doSamDetailSelectCancel();},function(strCode,strText) {doSamDetailSelectAccept(strCode,strText);});
   }
   function doSamDetailSelectCancel() {
      displayScreen('dspSamDetail');
      document.getElementById('SAM_SamCode').focus();
   }
   function doSamDetailSelectAccept(strCode,strText) {
      displayScreen('dspSamDetail');
      document.getElementById('SAM_SamCode').value = strCode;
      document.getElementById('SAM_SamCode').focus();
   }
   function doSamDetailCancel() {
      displayScreen('dspSample');
   }
   function doSamDetailAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (cintSampleRow == -1) {
         if (document.getElementById('SAM_SamCode').value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Sample code must be specified';
         }
         for (var i=0;i<cobjSampleData.length;i++) {
            if (cobjSampleData[i].samcde == document.getElementById('SAM_SamCode').value) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Sample code already exists in the test';
               break;
            }
         }
      }
      if (document.getElementById('SAM_RptCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Report code must be specified';
      }
      if (document.getElementById('SAM_MktCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Market research code must be specified';
      }
      if (strMessage != '') {
         for (var i=0;i<cobjSampleData.length;i++) {
            if (cintSampleRow != i && cobjSampleData[i].rptcde.toUpperCase() == document.getElementById('SAM_RptCode').value.toUpperCase()) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Report code already exists in the test';
            }
            if (cintSampleRow != i && cobjSampleData[i].mktcde.toUpperCase() == document.getElementById('SAM_MktCode').value.toUpperCase()) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Market research already exists in the test';
            }
            if (document.getElementById('SAM_AlsCode').value != '') {
               if (cintSampleRow != i && cobjSampleData[i].alscde.toUpperCase() == document.getElementById('SAM_AlsCode').value.toUpperCase()) {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + 'Market research alias already exists in the test';
               }
            }
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strSamCode = cstrSampleCode;
      if (cintSampleRow == -1) {
         strSamCode = document.getElementById('SAM_SamCode').value;
      }
      var objRptCode = document.getElementById('SAM_RptCode');
      var objMktCode = document.getElementById('SAM_MktCode');
      var objAlsCode = document.getElementById('SAM_AlsCode');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*SELSAM"';
      strXML = strXML+' SAMCDE="'+fixXML(strSamCode)+'"';
      strXML = strXML+' RPTCDE="'+fixXML(objRptCode.value.toUpperCase())+'"';
      strXML = strXML+' MKTCDE="'+fixXML(objMktCode.value.toUpperCase())+'"';
      strXML = strXML+' ALSCDE="'+fixXML(objAlsCode.value.toUpperCase())+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestSamDetailAccept(\''+strXML+'\');',10);
   }
   function requestSamDetailAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_sample_select.asp',function(strResponse) {checkSamDetailAccept(strResponse);},false,streamXML(strXML));
   }
   function checkSamDetailAccept(strResponse) {
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
         var intIndex = cintSampleRow;
         if (cintSampleRow == -1) {
            intIndex = cobjSampleData.length;
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'SAMPLE') {
               if (cintSampleRow == -1) {
                  cobjSampleData[intIndex] = new clsSamData();
               }
               cobjSampleData[intIndex].samcde = objElements[i].getAttribute('SAMCDE');
               cobjSampleData[intIndex].samtxt = objElements[i].getAttribute('SAMTXT');
               cobjSampleData[intIndex].rptcde = objElements[i].getAttribute('RPTCDE');
               cobjSampleData[intIndex].mktcde = objElements[i].getAttribute('MKTCDE');
               cobjSampleData[intIndex].alscde = objElements[i].getAttribute('ALSCDE');
            } else if (objElements[i].nodeName == 'FEEDING') {
               if (cintSampleRow == -1) {
                  cobjSampleData[intIndex].sizary[cobjSampleData[intIndex].sizary.length] = new clsSamSize(objElements[i].getAttribute('SIZCDE'),objElements[i].getAttribute('SIZTXT'),objElements[i].getAttribute('FEDQTY'),objElements[i].getAttribute('FEDTXT'));
               }
            }
         }
         cobjSampleData.sort(sortSamDetailData);
         loadSampleData();
         displayScreen('dspSample');
      }
   }
   function sortSamDetailData(obj01, obj02) {
      if ((obj01.samcde-0) < (obj02.samcde-0)) {
         return -1;
      } else if ((obj01.samcde-0) > (obj02.samcde-0)) {
         return 1;
      }
      return 0;
   }
   ///////////////////////////
   // Sample Size Functions //
   ///////////////////////////
   function doSamSizeCancel() {
      displayScreen('dspSample');
   }
   function doSamSizeAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('SAM_FedQnty').value == '' && document.getElementById('SAM_FedText').value != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Unit comment must not be entered when no unit quantity';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      cobjSampleData[cintSampleRow].sizary[cintSampleSize].fedqty = document.getElementById('SAM_FedQnty').value;
      cobjSampleData[cintSampleRow].sizary[cintSampleSize].fedtxt = document.getElementById('SAM_FedText').value.toUpperCase();
      loadSampleData();
      displayScreen('dspSample');
   }

   /////////////////////
   // Panel Functions //
   /////////////////////
   var cstrPanelTestCode;
   var cstrPanelTestText;
   var cstrPanelTestStatus;
   var cstrPanelDone;
   var cstrPanelTarget = '*PET';
   function requestPanelUpdate(strCode) {
      cstrPanelTestCode = strCode;
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
         var strSelType;
         var strSelTemp;
         var duplicatePanelCode;
         var objPetMult = document.getElementById('PAN_PetMult');
         var objSelType = document.getElementById('PAN_SelType');
         var objSelTemp = document.getElementById('PAN_SelTemp');
         objSelTemp.options.length = 0;
         objSelTemp.selectedIndex = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
               cstrPanelTestText = objElements[i].getAttribute('TESTXT');
               cstrPanelTestStatus = objElements[i].getAttribute('TESSTA');
               document.getElementById('subPanel').innerText = objElements[i].getAttribute('TESTXT');
               document.getElementById('PAN_MemCount').value = objElements[i].getAttribute('MEMCNT');
               document.getElementById('PAN_ResCount').value = objElements[i].getAttribute('RESCNT');
               strPetMult = objElements[i].getAttribute('PETMLT');
               strSelType = objElements[i].getAttribute('SELTYP');
               cstrPanelDone = objElements[i].getAttribute('PANDON');
               duplicatePanelCode = objElements[i].getAttribute('PANELCODE');
               $(".panelDuplicate").removeAttr("checked");
               if (duplicatePanelCode === null || duplicatePanelCode === "") {
                   $("#panelDuplicateNo").attr("checked", "checked");
                   $(".panelItemNormal").show();
                   $(".panelItemDuplicate").hide();
               }
               else {
                   $("#panelDuplicateYes").attr("checked", "checked");
                   $(".panelItemNormal").hide();
                   $(".panelItemDuplicate").show();
               }
               $("#panelDuplicateCode").val(duplicatePanelCode);
            } else if (objElements[i].nodeName == 'TEM_LIST') {
               objSelTemp.options[objSelTemp.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            }
         }
         startSltInstance(cstrPanelTarget);
         putSltData(objElements);
         objPetMult.selectedIndex = 0;
         for (var i=0;i<objPetMult.length;i++) {
            if (objPetMult.options[i].value == strPetMult) {
               objPetMult.options[i].selected = true;
               break;
            }
         }
         objSelType.selectedIndex = 0;
         for (var i=0;i<objSelType.length;i++) {
            if (objSelType.options[i].value == strSelType) {
               objSelType.options[i].selected = true;
               break;
            }
         }
         displayScreen('dspPanel');
         
         if (duplicatePanelCode === null || duplicatePanelCode === "") {
             document.getElementById('PAN_MemCount').focus();
         }
         else {
             document.getElementById('panelDuplicateCode').focus();
         }
      }
   }
   function doPanelAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (cstrPanelTestStatus != '1') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test must be status Raised for panel update';
      }
      if ($("#panelDuplicateYes").is(":checked")) {
          if ($("#panelDuplicateCode").val() == "" || isNaN($("#panelDuplicateCode").val())) {
              if (strMessage != '') {strMessage = strMessage + '\r\n';}
              strMessage = strMessage + 'A valid test number is required to duplicate the panel selection.';
          }
      }
      else {
          if (document.getElementById('PAN_MemCount').value < 1) {
              if (strMessage != '') {strMessage = strMessage + '\r\n';}
              strMessage = strMessage + 'Member count must be entered';
          }
          strMessage = checkSltData();
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cstrPanelDone == '1') {
         if (confirm('Panel already exists for this test - Please confirm the panel update\r\npress OK continue (the existing panel will be replaced)\r\npress Cancel to cancel the request') == false) {
            return;
         }
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDPAN"';
      strXML = strXML+' TESCDE="'+fixXML(cstrPanelTestCode)+'"';
      strXML = strXML+' PANELCODE="'+fixXML($("#panelDuplicateCode").val())+'"';
      strXML = strXML+' MEMCNT="'+fixXML(document.getElementById('PAN_MemCount').value)+'"';
      strXML = strXML+' RESCNT="'+fixXML(document.getElementById('PAN_RESCount').value)+'"';
      strXML = strXML+' PETMLT="'+fixXML(document.getElementById('PAN_PetMult').options[document.getElementById('PAN_PetMult').selectedIndex].value)+'"';
      strXML = strXML+' SELTYP="'+fixXML(document.getElementById('PAN_SelType').options[document.getElementById('PAN_SelType').selectedIndex].value)+'"';
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
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }
   function doPanelTemplate() {
      if (!processForm()) {return;}
      var objSelTemp = document.getElementById('PAN_SelTemp');
      var strMessage = '';
      if (objSelTemp.selectedIndex == -1 || objSelTemp.selectedIndex == 0) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection template must be selected for copy';
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
         var strSelType;
         var objSelType = document.getElementById('PAN_SelType');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEMPLATE') {
               strSelType = objElements[i].getAttribute('SELTYP');
            }
         }
         startSltInstance(cstrPanelTarget);
         putSltData(objElements);
         objSelType.selectedIndex = 0;
         for (var i=0;i<objSelType.length;i++) {
            if (objSelType.options[i].value == strSelType) {
               objSelType.options[i].selected = true;
               break;
            }
         }
         document.getElementById('tabSltRule').focus();
      }
   }

   //////////////////////////
   // Allocation Functions //
   //////////////////////////
   var cstrAllocationTestCode;
   var cstrAllocationTestText;
   var cstrAllocationTestStatus;
   var cstrAllocationDone;
   function requestAllocationUpdate(strCode) {
      cstrAllocationTestCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVALC" TESCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_allocation_retrieve.asp',function(strResponse) {checkAllocationUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkAllocationUpdate(strResponse) {
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
               cstrAllocationTestText = objElements[i].getAttribute('TESTXT');
               cstrAllocationTestStatus = objElements[i].getAttribute('TESSTA');
               cstrAllocationDone = objElements[i].getAttribute('ALCDON');
            }
         }
         document.getElementById('subAllocation').innerText = cstrAllocationTestText;
         displayScreen('dspAllocation');
      }
   }
   function doAllocationAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (cstrAllocationTestStatus != '1') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test must be status Raised for allocation update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cstrAllocationDone == '1') {
         if (confirm('Allocation already exists for this test - Please confirm the allocation update\r\npress OK continue (the existing allocation will be replaced)\r\npress Cancel to cancel the request') == false) {
            return;
         }
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDALC" TESCDE="'+fixXML(cstrAllocationTestCode)+'"/>';
      doActivityStart(document.body);
      window.setTimeout('requestAllocationAccept(\''+strXML+'\');',10);
   }
   function requestAllocationAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_allocation_update.asp',function(strResponse) {checkAllocationAccept(strResponse);},false,streamXML(strXML));
   }
   function checkAllocationAccept(strResponse) {
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
         document.getElementById('PRO_TesCode').focus();
      }
   }
   function doAllocationCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }

   ///////////////////////
   // Release Functions //
   ///////////////////////
   var cstrReleaseTestCode;
   var cstrReleaseTestText;
   var cstrReleaseTestStatus;
   function requestReleaseUpdate(strCode) {
      cstrReleaseTestCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVREL" TESCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_release_retrieve.asp',function(strResponse) {checkReleaseUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkReleaseUpdate(strResponse) {
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
               cstrReleaseTestText = objElements[i].getAttribute('TESTXT');
               cstrReleaseTestStatus = objElements[i].getAttribute('TESSTA');
            }
         }
         document.getElementById('subRelease').innerText = cstrReleaseTestText;
         displayScreen('dspRelease');
      }
   }
   function doReleaseAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (cstrReleaseTestStatus != '2' && cstrReleaseTestStatus != '3') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test must be status Allocation Completed or Results Entered for release update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDREL" TESCDE="'+fixXML(cstrReleaseTestCode)+'"/>';
      doActivityStart(document.body);
      window.setTimeout('requestReleaseAccept(\''+strXML+'\');',10);
   }
   function requestReleaseAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_release_update.asp',function(strResponse) {checkReleaseAccept(strResponse);},false,streamXML(strXML));
   }
   function checkReleaseAccept(strResponse) {
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
         document.getElementById('PRO_TesCode').focus();
      }
   }
   function doReleaseCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }

   //////////////////////
   // Report Functions //
   //////////////////////
   function requestPanelReport(strCode) {
      doReportOutput(eval('document.body'),'Pet Test Panel Report','*SPREADSHEET','select * from table(pts_app.pts_tes_function.report_panel(' + strCode + '))');
      document.getElementById('PRO_TesCode').focus();
   }
   function requestAllocationReport(strCode) {
      doReportOutput(eval('document.body'),'Pet Test Allocation Report','*SPREADSHEET','select * from table(pts_app.pts_tes_function.report_allocation(' + strCode + '))');
      document.getElementById('PRO_TesCode').focus();
   }
   function requestQuestionnaireReport(strCode) {
      doReportOutput(eval('document.body'),'Pet Test Questionnaire Report','*CSV','select * from table(pts_app.pts_tes_function.report_questionnaire(' + strCode + '))');
      document.getElementById('PRO_TesCode').focus();
   }
   function requestSelectionReport(strCode) {
      doReportOutput(eval('document.body'),'Pet Test Selection Report','*SPREADSHEET','select * from table(pts_app.pts_tes_function.report_selection(' + strCode + '))');
      document.getElementById('PRO_TesCode').focus();
   }

   /////////////////////////////
   // Result Report Functions //
   /////////////////////////////
   var cstrResReportTestCode;
   function requestResReport(strCode) {
      cstrResReportTestCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*GETFLD" TESCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_field_retrieve.asp',function(strResponse) {checkResReport(strResponse);},false,streamXML(strXML));
   }
   function checkResReport(strResponse) {
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
         var objPetValue = document.getElementById('RRP_PetValue');
         var objSelValue = document.getElementById('RRP_SelValue');
         objPetValue.options.length = 0;
         objSelValue.options.length = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
               document.getElementById('subResReport').innerText = objElements[i].getAttribute('TESTXT');
            } else if (objElements[i].nodeName == 'FIELD') {
               objPetValue.options[objPetValue.options.length] = new Option(objElements[i].getAttribute('FLDTXT'),objElements[i].getAttribute('FLDCDE'));
               objPetValue.options[objPetValue.options.length-1].setAttribute('tabcde',objElements[i].getAttribute('TABCDE'));
               objPetValue.options[objPetValue.options.length-1].setAttribute('fldcde',objElements[i].getAttribute('FLDCDE'));
            }
         }
         displayScreen('dspResReport');
         objPetValue.focus();
      }
   }
   function doResReportAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var objSelValue = document.getElementById('RRP_SelValue');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*SETFLD">';
      for (var i=0;i<objSelValue.options.length;i++) {
         strXML = strXML+'<FIELD TABCDE="'+fixXML(objSelValue[i].getAttribute('tabcde'))+'"';
         strXML = strXML+' FLDCDE="'+fixXML(objSelValue[i].getAttribute('fldcde'))+'"/>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestResReportAccept(\''+strXML+'\');',10);
   }
   function requestResReportAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_field_update.asp',function(strResponse) {checkResReportAccept(strResponse);},false,streamXML(strXML));
   }
   function checkResReportAccept(strResponse) {
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
         doReportOutput(eval('document.body'),'Pet Test Results Report','*CSV','select * from table(pts_app.pts_tes_function.report_results(' + cstrResReportTestCode + '))');
         displayScreen('dspPrompt');
         document.getElementById('PRO_TesCode').focus();
      }
   }
   function doResReportCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }
   function selectResReportValues() {
      var objPetValue = document.getElementById('RRP_PetValue');
      var objSelValue = document.getElementById('RRP_SelValue');
      var bolFound;
      for (var i=0;i<objPetValue.options.length;i++) {
         if (objPetValue.options[i].selected == true) {
            bolFound = false;
            for (var j=0;j<objSelValue.options.length;j++) {
               if (objPetValue[i].value == objSelValue[j].value) {
                  bolFound = true;
                  break;
               }
            }
            if (!bolFound) {
               objSelValue.options[objSelValue.options.length] = new Option(objPetValue[i].text,objPetValue[i].value);
               objSelValue.options[objSelValue.options.length-1].setAttribute('tabcde',objPetValue[i].getAttribute('tabcde'));
               objSelValue.options[objSelValue.options.length-1].setAttribute('fldcde',objPetValue[i].getAttribute('fldcde'));
            }
         }
      }
      var objWork = new Array();
      var intIndex = 0
      for (var i=0;i<objSelValue.options.length;i++) {
         objWork[intIndex] = objSelValue[i];
         intIndex++;
      }
      objWork.sort(sortResReportValues);
      objSelValue.options.length = 0;
      objSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSelValue.options[i] = objWork[i];
      }
   }
   function removeResReportValues() {
      var objSelValue = document.getElementById('RRP_SelValue');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objSelValue.options.length;i++) {
         if (objSelValue.options[i].selected == false) {
            objWork[intIndex] = objSelValue[i];
            intIndex++;
         }
      }
      objSelValue.options.length = 0;
      objSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSelValue.options[i] = objWork[i];
      }
   }
   function sortResReportValues(obj01, obj02) {
      if (obj01.text < obj02.text) {
         return -1;
      } else if (obj01.text > obj02.text) {
         return 1;
      }
      return 0;
   }

// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<!--#include file="ics_std_report.inc"-->
<!--#include file="ics_std_export.inc"-->
<!--#include file="pts_search_code.inc"-->
<!--#include file="pts_select_code.inc"-->
<head>
   <script src="/scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
   <script type="text/javascript">
       $(document).ready(function () {
           $(".panelDuplicate").change(function () {
               if ($("#panelDuplicateYes").is(":checked")) {
                   $(".panelItemNormal").hide();
                   $(".panelItemDuplicate").show();
               }
               else {
                   $(".panelItemNormal").show();
                   $(".panelItemDuplicate").hide();
                   $("#panelDuplicateCode").val("");
               }
           });
       });
   </script>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_tes_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Pet Test Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Test Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_TesCode" id="PRO_TesCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=9 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCreate();">&nbsp;Create&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCopy();">&nbsp;Copy&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap id="notVal18"><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap id="notVal19"><nobr><a class="clsButton" onClick="doPromptPreview();">&nbsp;Preview&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptSearch();">&nbsp;Search&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=10 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsHeader" align=center colspan=1 nowrap><nobr>Maintenance</nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptQuestion();">&nbsp;Questions&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptSample();">&nbsp;Samples&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap id="notVal1"><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap id="notVal2"><nobr><a class="clsButton" onClick="doPromptPanel();">&nbsp;Panel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap id="notVal3"><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap id="notVal4"><nobr><a class="clsButton" onClick="doPromptAllocation();">&nbsp;Allocation&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap id="notVal5"><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap id="notVal6"><nobr><a class="clsButton" onClick="doPromptRelease();">&nbsp;Release&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="notVal7">
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=11 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsHeader" align=center colspan=1 nowrap><nobr>Reporting</nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReportPanel();">&nbsp;Panel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReportAllocation();">&nbsp;Allocation&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReportQuestionnaire();">&nbsp;Questionnaire&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReportSelection();">&nbsp;Pet Selection&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReportResults();">&nbsp;Results&nbsp;</a></nobr></td>
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
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_TesText" size="80" maxlength="120" value="" onFocus="setSelect(this);">
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
      <tr id="notVal8">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;GloPal:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_TesGlop"></select>
         </nobr></td>
      </tr>
      <tr id="notVal15">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_TesType"></select>
         </nobr></td>
      </tr>
      <tr id="Val1" style="display:none;">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_ValType"></select>
         </nobr></td>
      </tr>
      <tr id="notVal9">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Requestor Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_TesRnam" size="60" maxlength="60" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="notVal10">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Requestor Mars Id:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_TesRmid" size="30" maxlength="30" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="notVal11">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Aim:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_TesAtxt" size="80" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="notVal12">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Reason:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_TesRtxt" size="80" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="notVal13">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Prediction:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_TesPtxt" size="80" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Comment:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_TesCtxt" size="80" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="notVal16">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Start Date (DD/MM/YYYY):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesSdat" size="10" maxlength="10" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="notVal17">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Field Work Week (YYYYWW):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesFwek" size="6" maxlength="6" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Meal Length (minutes):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesMlen" size="4" maxlength="4" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr id="notVal14">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Average Temperature:&nbsp;</nobr></td>
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
                     <select class="clsInputBN" id="DEF_TesKwrd" name="DEF_TesKwrd" style="width:200px" size=5></select>
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
   <table id="dspPreview" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPreview" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Preview</nobr></td>
      </tr>
      <tr>
         <td id="subPreview" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Questions Created:&nbsp;</nobr></td>
         <td id="PRE_QueDta" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Samples Created:&nbsp;</nobr></td>
         <td id="PRE_SamDta" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Panel Selected:&nbsp;</nobr></td>
         <td id="PRE_PanDta" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Allocation Created:&nbsp;</nobr></td>
         <td id="PRE_AlcDta" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Response Entered:&nbsp;</nobr></td>
         <td id="PRE_ResDta" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPreviewCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
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
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="QUE_WeiBowl" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
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
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="QUE_WeiOffr" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
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
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="QUE_WeiRemn" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
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
            <div id="divQuestion" class="clsScroll01" style="display:block;visibility:visible">
               <table id="tabQuestion" class="clsTableBody" style="display:block;visibility:visible" align=left cellpadding="2" cellspacing="1"></table>
            </div>
         </nobr></td>
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
   <table id="dspQueDetail" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doQueDetailAccept();}">
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
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Question Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="QUE_QueCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=left colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=left cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQueDetailSelect();">&nbsp;Select&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Question Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="QUE_QueType">
               <option value="1" selected>General
               <option value="2">Sample
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=left colspan=2 nowrap><nobr>
            <table class="clsTable01" align=left cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQueDetailAdd();">&nbsp;Add&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQueDetailDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=left colspan=2 nowrap><nobr>
            <table align=left cols=2 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="QUE_QueList" name="QUE_QueList" style="width:600px" multiple size=20></select>
                  </nobr></td>
                  <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" width=100% align=center cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="doQueDetailSortUp();"></nobr></td></tr>
                        <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="doQueDetailSortDown();"></nobr></td></tr>
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
            <div id="divSample" class="clsScroll01" style="display:block;visibility:visible">
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
   <table id="dspSamDetail" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSamDetailAccept();}">
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
      <tr id="addSamDetail" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Sample Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="SAM_SamCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=left colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=left cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSamDetailSelect();">&nbsp;Select&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Report Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="SAM_RptCode" size="3" maxlength="3" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Market Research Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="SAM_MktCode" size="3" maxlength="3" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Market Research Alias:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="SAM_AlsCode" size="3" maxlength="3" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSamDetailCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSamDetailAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspSamSize" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSamSizeAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSamSize" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Sample Detail</nobr></td>
      </tr>
      <tr>
         <td id="subSamSize" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Unit Quantity:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SAM_FedQnty" size="5" maxlength="5" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Unit Comment:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="SAM_FedText" size="80" maxlength="120" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSamSizeCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSamSizeAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspPanel" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPanelAccept();}">
      <tr valign="top"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=4 cellpadding="0" cellspacing="0">
      <tr valign="top">
         <td id="hedPanel" class="clsFunction" align=center valign=center colspan=4 nowrap><nobr>Test Panel Selection</nobr></td>
      </tr>
      <tr valign="top">
         <td id="subPanel" class="clsLabelBB" align=center colspan=4 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr valign="top">
         <td class="clsLabelBB" align=center colspan=4 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
          <tr valign="top">
              <td class="clsLabelBB" align=right valign=center >
                  Duplicate Panel:
              </td>
              <td>
                  <input type="radio" name="panelDuplicate" id="panelDuplicateNo" value="0" class="panelDuplicate" />
                  <label for="panelDuplicateNo" class="clsLabelBB">No</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              </td>
              <td align="right">
                  &nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="panelDuplicate" id="panelDuplicateYes" value="1" class="panelDuplicate" />
                  <label for="panelDuplicateYes" class="clsLabelBB">Yes</label>&nbsp;&nbsp;
              </td>
              <td class="panelItemDuplicate">
                  <input type="text" id="panelDuplicateCode" maxlength="10" size="4" class="clsInputNN" />
              </td>
          </tr>
      <tr class="panelItemNormal" valign="top">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Member Count:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PAN_MemCount" id="PAN_MemCount" size="4" maxlength="5" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Reserve Count:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PAN_ResCount" id="PAN_ResCount" size="4" maxlength="5" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr class="panelItemNormal" valign="top">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Allow Multiple Household Pets:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="PAN_PetMult" id="PAN_PetMult">
               <option value="0" selected>No
               <option value="1">Yes
            </select>
         </nobr></td>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Selection Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="PAN_SelType" id="PAN_SelType">
               <option value="*PERCENT" selected>Percentage selection
               <option value="*TOTAL">Total selection
            </select>
         </nobr></td>
      </tr>
      <tr class="panelItemNormal" valign="top">
         <td class="clsLabelBB" align=center colspan=4 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr class="panelItemNormal" valign="top">
         <td class="clsLabelBB" align=center valign=center colspan=4 nowrap><nobr>
            <table class="clsTable01" align=right cols=2 cellpadding="0" cellspacing="0">
               <tr><td align=right colspan=1 nowrap><nobr><select class="clsInputBN" id="PAN_SelTemp" id="PAN_SelTemp"></select></nobr></td><td align=left colspan=1 nowrap><nobr><a class="clsButton" onClick="doPanelTemplate();">&nbsp;Retrieve Selection Template&nbsp;</a></nobr></td></tr>
            </table>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr height=100%  class="panelItemNormal" valign="top">
         <td align=center colspan=2 nowrap><nobr>
<!--#include file="pts_select_disp.inc"-->
         </nobr></td>
      </tr>
      <tr valign="top">
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
   <table id="dspAllocation" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doAllocationAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedAllocation" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Allocation</nobr></td>
      </tr>
      <tr>
         <td id="subAllocation" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
       <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doAllocationCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doAllocationAccept();">&nbsp;Allocate&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspRelease" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doReleaseAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedRelease" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Release</nobr></td>
      </tr>
      <tr>
         <td id="subRelease" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
       <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReleaseCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReleaseAccept();">&nbsp;Release&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspResReport" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSchListAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedResReport" class="clsFunction" align=center colspan=2 nowrap><nobr>Results Report</nobr></td>
      </tr>
      <tr>
         <td id="subResReport" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 width=100% cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
                     <table align=center border=0 cellpadding=0 cellspacing=2 cols=3>
                        <tr>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Available Reporting Fields&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Selected Reporting Fields&nbsp;</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                              <select class="clsInputBN" id="RRP_PetValue" name="RRP_PetValue" style="width:300px" multiple size=20></select>
                           </nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                              <table class="clsTable01" width=100% align=center cols=2 cellpadding="0" cellspacing="0">
                                 <tr>
                                    <td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_loff.gif" align=absmiddle onClick="removeResReportValues();"></nobr></td>
                                    <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_roff.gif" align=absmiddle onClick="selectResReportValues();"></nobr></td>
                                 </tr>
                              </table>
                           </nobr></td>
                           <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                              <select class="clsInputBN" id="RRP_SelValue" name="RRP_SelValue" style="width:300px" multiple size=20></select>
                           </nobr></td>
                        </tr>
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
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doResReportCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doResReportAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
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