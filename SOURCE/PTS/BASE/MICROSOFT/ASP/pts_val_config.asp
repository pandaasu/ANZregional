<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_val_config.asp                                 //
'// Author  : Peter Tylee                                        //
'// Date    : October 2011                                       //
'// Text    : Modified from pts_pet_config.asp. This script      //
'//           implements the product test configuration          //
'//           functionality                                      //
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
   strTarget = "pts_val_config.asp"
   strHeading = "Pet Validation Maintenance"

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
   strReturn = GetSecurityCheck("PTS_VAL_CONFIG")
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
      cobjScreens[2] = new clsScreen('dspPreview','hedPreview');
      cobjScreens[3] = new clsScreen('dspTest','hedTest');
      cobjScreens[4] = new clsScreen('dspTestDetail','hedTestDetail');
      cobjScreens[5] = new clsScreen('dspPet','hedPet');
      cobjScreens[6] = new clsScreen('dspPetDetail','hedPetDetail');
      cobjScreens[7] = new clsScreen('dspAllocation','hedAllocation');
      cobjScreens[8] = new clsScreen('dspAllocationReport','hedAllocationReport');
      cobjScreens[9] = new clsScreen('dspQuestionnaireReport','hedQuestionnaireReport');
      cobjScreens[10] = new clsScreen('dspSelectionReport','hedSelectionReport');
      cobjScreens[11] = new clsScreen('dspCandidatesReport','hedCandidatesReport');
      cobjScreens[0].hedtxt = 'Pet Validation Prompt';
      cobjScreens[1].hedtxt = 'Pet Validation Maintenance';
      cobjScreens[2].hedtxt = 'Pet Validation Preview';
      cobjScreens[3].hedtxt = 'Pet Validation Test Review';
      cobjScreens[4].hedtxt = 'Pet Validation Test Maintenance';
      cobjScreens[5].hedtxt = 'Pet Validation Pet Review';
      cobjScreens[6].hedtxt = 'Pet Validation Pet Maintenance';
      cobjScreens[7].hedtxt = 'Pet Validation Allocation';
      cobjScreens[8].hedtxt = 'Pet Validation Allocation Report';
      cobjScreens[9].hedtxt = 'Pet Validation Questionnaire Report';
      cobjScreens[10].hedtxt = 'Pet Validation Selection Report';
      cobjScreens[11].hedtxt = 'Pet Validation Candidates Report';
      initSearch();
      initSelect('dspTest','Validation');
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
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
         if (!objScreen)
            alert(cobjScreens[i].scrnam);
         if (!objHeading)
            alert(cobjScreens[i].hednam);
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
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+document.getElementById('PRO_ValCode').value+'\');',10);
   }
   function doPromptCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
   }
   function doPromptCopy() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for copy';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+document.getElementById('PRO_ValCode').value+'\');',10);
   }
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*VALIDATION','Validation','pts_val_search.asp',function() {doPromptValCancel();},function(strCode,strText) {doPromptValSelect(strCode,strText);});
   }
   function doPromptValCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   function doPromptValSelect(strCode,strText) {
      document.getElementById('PRO_ValCode').value = strCode;
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   function doPromptPreview() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for preview';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestPreview(\''+document.getElementById('PRO_ValCode').value+'\');',10);
   }
   function doPromptTest() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for test maintenance';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestTestUpdate(\''+document.getElementById('PRO_ValCode').value+'\');',10);
   }
   function doPromptPet() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for pet maintenance';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestPetUpdate(\''+document.getElementById('PRO_ValCode').value+'\');',10);
   }
   function doPromptAllocation() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for allocation';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestAllocationUpdate(\''+document.getElementById('PRO_ValCode').value+'\');',10);
   }
   function doReportAllocation() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for allocation reporting';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestAllocationReportUpdate(\''+document.getElementById('PRO_ValCode').value+'\');',10);
   }
   function doReportQuestionnaire() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for questionnaire reporting';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestQuestionnaireReportUpdate(\''+document.getElementById('PRO_ValCode').value+'\');',10);
   }
   function doReportSelection() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for selection reporting';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestSelectionReportUpdate(\''+document.getElementById('PRO_ValCode').value+'\');',10);
   }
   function doReportResults() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for results reporting';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      requestResultsReport(document.getElementById('PRO_ValCode').value);
   }
   function doReportCandidates() {
      document.getElementById('PRO_CanRepSDate').value = '';
      displayScreen('dspCandidatesReport');
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   var cstrDefineStatus;
   var cstrDefineType;
   var cstrDefinePetType;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDVAL" VALCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_val_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTVAL" VALCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_val_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYVAL" VALCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_val_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
         var strValStat;
         var strPetType;
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
         var objPetType = document.getElementById('DEF_PetType');
         objPetType.selectedIndex = -1;
         objPetType.options.length = 0;
         if (cstrDefineMode == '*UPD') {
            cobjScreens[1].hedtxt = 'Update Validation ('+cstrDefineCode+')';
            objPetType.disabled=true;
         } else {
            cobjScreens[1].hedtxt = 'Create Validation (*NEW)';
            objPetType.disabled=false;
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_ValCode').value = '';
         document.getElementById('DEF_ValText').value = '';
         document.getElementById('DEF_ValCtxt').value = '';
         document.getElementById('DEF_ValSdat').value = '';
         document.getElementById('DEF_ValFwek').value = '';
         var objValStat = document.getElementById('DEF_ValStat');
         objValStat.options.length = 0;
         document.getElementById('DEF_ValText').focus();
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'STA_LIST') {
               objValStat.options[objValStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'PET_TYPE') {
               objPetType.options[objPetType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'VAL') {
               document.getElementById('DEF_ValCode').value = objElements[i].getAttribute('VALCDE');
               document.getElementById('DEF_ValText').value = objElements[i].getAttribute('VALTIT');
               document.getElementById('DEF_ValCtxt').value = objElements[i].getAttribute('COMTXT');
               document.getElementById('DEF_ValSdat').value = objElements[i].getAttribute('STRDAT');
               document.getElementById('DEF_ValFwek').value = objElements[i].getAttribute('FLDWEK');
               strValStat = objElements[i].getAttribute('VALSTA');
               strPetType = objElements[i].getAttribute('PETTYP');
            }
         }
         cstrDefineStatus = strValStat;
         objValStat.selectedIndex = -1;
         for (var i=0;i<objValStat.length;i++) {
            if (objValStat.options[i].value == strValStat) {
               objValStat.options[i].selected = true;
               break;
            }
         }
         cstrDefinePetType = strPetType;
         objPetType.selectedIndex = -1;
         for (var i=0;i<objPetType.length;i++) {
            if (objPetType.options[i].value == strPetType) {
               objPetType.options[i].selected = true;
               break;
            }
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objValStat = document.getElementById('DEF_ValStat');
      var objPetType = document.getElementById('DEF_PetType');
      if (cstrDefineMode == '*UPD') {
         if (objValStat.options[objValStat.selectedIndex].value == '1' && (cstrDefineStatus == '3' || cstrDefineStatus == '4')) {
            if (confirm('The validation status has been set to Raised from Results Entered or Closed - Please confirm\r\npress OK continue (any existing response data will be deleted)\r\npress Cancel to cancel update and return') == false) {
               return;
            }
         }
         if (objPetType.options[objPetType.selectedIndex].value != cstrDefinePetType) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Pet type cannot be changed after creation';
         }
      }
      if (document.getElementById('DEF_PetType').selectedIndex == -1 || document.getElementById('DEF_PetType').selectedIndex == 0) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Pet type must be selected';
      }
      var strMessage = '';
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*DEFVAL"';
      if (cstrDefineMode == '*CPY') {
         strXML = strXML+' CPYCDE="'+fixXML(cstrDefineCode)+'"';
      }
      strXML = strXML+' VALCDE="'+fixXML(document.getElementById('DEF_ValCode').value)+'"';
      strXML = strXML+' VALTIT="'+fixXML(document.getElementById('DEF_ValText').value.toUpperCase())+'"';
      strXML = strXML+' VALSTA="'+fixXML(objValStat.options[objValStat.selectedIndex].value)+'"';
      strXML = strXML+' COMTXT="'+fixXML(document.getElementById('DEF_ValCtxt').value.toUpperCase())+'"';
      strXML = strXML+' STRDAT="'+fixXML(document.getElementById('DEF_ValSdat').value)+'"';
      strXML = strXML+' FLDWEK="'+fixXML(document.getElementById('DEF_ValFwek').value)+'"';
      strXML = strXML+' PETTYP="'+fixXML(objPetType.options[objPetType.selectedIndex].value)+'"';
      strXML = strXML+'>';
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>pts_val_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         document.getElementById('PRO_ValCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }

   ///////////////////////
   // Preview Functions //
   ///////////////////////
   function requestPreview(strCode) {
      cstrTestValidationCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVPVW" VALCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_val_config_preview_retrieve.asp',function(strResponse) {checkPreview(strResponse);},false,streamXML(strXML));
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
         document.getElementById('PRE_TesDta').innerHTML = 'No';
         document.getElementById('PRE_AlcDta').innerHTML = 'No';
         document.getElementById('PRE_ResDta').innerHTML = 'No';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'VAL') {
               document.getElementById('subPreview').innerHTML = objElements[i].getAttribute('VALTXT');
               if (objElements[i].getAttribute('TESDTA') == '1') {
                  document.getElementById('PRE_TesDta').innerHTML = 'YES';
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
      document.getElementById('PRO_ValCode').focus();
   }

   ////////////////////////
   //   Test Functions   //
   ////////////////////////
   var cstrTestValidationCode;
   var cstrTestValidationText;
   var cstrTestValidationStatus;
   var cstrTestTarget;
   var cintTestRow;
   var cobjTest;
   var cstrTestResponse;
   function clsTesData(strTesCde,strValTyp,strTesTxt,strTesSta) {
      this.tescde = strTesCde;
      this.valtyp = strValTyp;
      this.testxt = strTesTxt;
      this.tessta = strTesSta
   }
   function requestTestUpdate(strCode) {
      cstrTestValidationCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVTES" VALCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_val_config_test_retrieve.asp',function(strResponse) {checkTestUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkTestUpdate(strResponse) {
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
         cstrTestResponse = '0';
         cobjTest = new Array();
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'VAL') {
               cstrTestValidationText = objElements[i].getAttribute('VALTXT');
               cstrTestValidationStatus = objElements[i].getAttribute('VALSTA');
               cstrTestResponse = objElements[i].getAttribute('RESDTA');
            } else if (objElements[i].nodeName == 'TEST') {
               cobjTest[cobjTest.length] = new clsTesData(objElements[i].getAttribute('TESCDE'),objElements[i].getAttribute('VALTYP'),objElements[i].getAttribute('TESTIT'),objElements[i].getAttribute('TESSTA'));
            }
         }
         loadTestData();
         document.getElementById('subTest').innerHTML = cstrTestValidationText;
         displayScreen('dspTest');
         document.getElementById('divTest').scrollTop = 0;
         document.getElementById('divTest').scrollLeft = 0;
      }
   }
   function loadTestData() {
      var objTable = document.getElementById('tabTest');
      var objRow;
      var objCell;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      objRow = objTable.insertRow(-1);
      objCell = objRow.insertCell(0);
      objCell.colSpan = 3;
      objCell.innerHTML = '<a class="clsSelect" onClick="doTestUpdate();">Update</a>';
      objCell.className = 'clsLabelFB';
      objCell.style.whiteSpace = 'nowrap';
      for (var j=0;j<cobjTest.length;j++) {
         objRow = objTable.insertRow(-1);
         objCell = objRow.insertCell(0);
         objCell.colSpan = 1;
         objCell.innerText = cobjTest[j].valtyp;
         objCell.className = 'clsLabelFB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(1);
         objCell.colSpan = 1;
         objCell.innerText = cobjTest[j].testxt;
         objCell.className = 'clsLabelFN';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(2);
         objCell.colSpan = 1;
         objCell.innerText = cobjTest[j].tessta;
         objCell.className = 'clsLabelFN';
         objCell.style.whiteSpace = 'nowrap';
      }
   }
   function doTestAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (cstrTestValidationStatus == '9') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation cannot be cancelled for test update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cstrTestResponse == '1') {
         if (confirm('Response data exists for this validation - Please confirm the validation update\r\npress OK continue (the existing response data will be removed)\r\npress Cancel to cancel the request') == false) {
            return;
         }
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDTES"';
      strXML = strXML+' VALCDE="'+fixXML(cstrTestValidationCode)+'"';
      strXML = strXML+'>';
      for (var j=0;j<cobjTest.length;j++) {
         strXML = strXML+'<TEST TESCDE="'+fixXML(cobjTest[j].tescde)+'"/>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestTestAccept(\''+strXML+'\');',10);
   }
   function requestTestAccept(strXML) {
      doPostRequest('<%=strBase%>pts_val_config_test_update.asp',function(strResponse) {checkTestAccept(strResponse);},false,streamXML(strXML));
   }
   function checkTestAccept(strResponse) {
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
         document.getElementById('PRO_ValCode').focus();
      }
   }
   function doTestCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   function doTestSelect(strTarget) {
      if (!processForm()) {return;}
      cstrTestTarget = strTarget;
      startSchInstance('*TEST','Test','pts_que_search.asp',function() {doTestSelectCancel();},function(strCode,strText) {doTestSelectAccept(strCode,strText);});
   }
   function doTestSelectCancel() {
      displayScreen('dspTest');
      document.getElementById('tabTest').focus();
   }
   function doTestSelectAccept(strCode,strText) {
      displayScreen('dspTest');
   }
   function doTestUpdate() {
      document.getElementById('subTesDetail').innerHTML = cstrTestValidationText;
      displayScreen('dspTestDetail');
      document.getElementById('TES_TesCode').value = '';
      var objTesList = document.getElementById('TES_TesList');
      objTesList.options.length = 0;
      objTesList.selectedIndex = 0;
      var strText;
      for (var i=0;i<cobjTest.length;i++) {
         strText = cobjTest[i].testxt + ' - ' + cobjTest[i].valtyp;
         objTesList.options[objTesList.options.length] = new Option(strText,cobjTest[i].quecde);
         objTesList.options[objTesList.options.length-1].setAttribute('tescde',cobjTest[i].tescde);
         objTesList.options[objTesList.options.length-1].setAttribute('valtyp',cobjTest[i].valtyp);
         objTesList.options[objTesList.options.length-1].setAttribute('testxt',cobjTest[i].testxt);
         objTesList.options[objTesList.options.length-1].setAttribute('tessta',cobjTest[i].tessta);
      }
      objTesList.focus();
   }
   function doTestCopy() {
      if (confirm('Please confirm the test copy\r\npress OK continue\r\npress Cancel to cancel the request') == false) {
         return;
      }
      var objSrcAry = cobjTest[0].queary;
      var objTarAry;
      for (var i=1;i<cobjTest.length;i++) {
         objTarAry = cobjTest[i].queary;
         objTarAry.length = 0;
         for (var j=0;j<objSrcAry.length;j++) {
            objTarAry[j] = new clsTesData(objSrcAry[j].tescde,objSrcAry[j].valtyp,objSrcAry[j].testxt,objSrcAry[j].tessta);
         }
      }
      loadTestData();
   }
   ///////////////////////////////
   // Test Detail Functions     //
   ///////////////////////////////
   function doTesDetailAdd() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('TES_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered';
      }
      var objTesList = document.getElementById('TES_TesList');
      for (var i=0;i<objTesList.options.length;i++) {
         if (objTesList.options[i].getAttribute('tescde') == document.getElementById('TES_TesCode').value) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Test code already exists';
            break;
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var objTesCode = document.getElementById('TES_TesCode');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*SELTES"';
      strXML = strXML+' TESCDE="'+fixXML(objTesCode.value)+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestTesDetailSelect(\''+strXML+'\');',10);
   }
   function requestTesDetailSelect(strXML) {
      doPostRequest('<%=strBase%>pts_val_config_test_select.asp',function(strResponse) {checkTesDetailSelect(strResponse);},false,streamXML(strXML));
   }
   function checkTesDetailSelect(strResponse) {
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
         var strTesCode;
         var strValType;
         var strTesText;
         var strTesStat;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
               strTesCode = objElements[i].getAttribute('TESCDE');
               strValType = objElements[i].getAttribute('VALTYP');
               strTesText = objElements[i].getAttribute('TESTXT');
               strTesStat = objElements[i].getAttribute('TESSTA');
            }
         }
         var strText = strTesText + ' - ' + strValType;
         var objTesList = document.getElementById('TES_TesList');
         objTesList.options[objTesList.options.length] = new Option(strText,strTesCode);
         objTesList.options[objTesList.options.length-1].setAttribute('tescde',strTesCode);
         objTesList.options[objTesList.options.length-1].setAttribute('valtyp',strValType);
         objTesList.options[objTesList.options.length-1].setAttribute('testxt',strTesText);
         objTesList.options[objTesList.options.length-1].setAttribute('tessta',strTesText);
         objTesList.focus();
         document.getElementById('TES_TesCode').value = '';
      }
   }
   function doTesDetailDelete() {
      if (document.getElementById('TES_TesList').selectedIndex == -1) {
         alert('Test must be selected for delete');
         return;
      }
      var objTesList = document.getElementById('TES_TesList');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objTesList.options.length;i++) {
         if (objTesList.options[i].selected == false) {
            objWork[intIndex] = objTesList[i];
            intIndex++;
         }
      }
      objTesList.options.length = 0;
      objTesList.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objTesList.options[i] = objWork[i];
      }
   }
   function doTesDetailSortUp() {
      var intIndex;
      var intSelect;
      var objTesList = document.getElementById('TES_TesList');
      intSelect = 0;
      for (var i=0;i<objTesList.options.length;i++) {
         if (objTesList.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one test can be selected to move up');
         return;
      }
      if (intSelect == 1 && intIndex > 0) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objTesList.options[intIndex-1].value;
         aryA[1] = objTesList.options[intIndex-1].text;
         aryA[2] = objTesList.options[intIndex-1].getAttribute('tescde');
         aryA[3] = objTesList.options[intIndex-1].getAttribute('valtyp');
         aryA[4] = objTesList.options[intIndex-1].getAttribute('testxt');
         aryA[5] = objTesList.options[intIndex-1].getAttribute('tessta');
         aryB[0] = objTesList.options[intIndex].value;
         aryB[1] = objTesList.options[intIndex].text;
         aryB[2] = objTesList.options[intIndex].getAttribute('tescde');
         aryB[3] = objTesList.options[intIndex].getAttribute('valtyp');
         aryB[4] = objTesList.options[intIndex].getAttribute('testxt');
         aryB[5] = objTesList.options[intIndex].getAttribute('tessta');
         objTesList.options[intIndex-1].value = aryB[0];
         objTesList.options[intIndex-1].text = aryB[1];
         objTesList.options[intIndex-1].setAttribute('tescde',aryB[2]);
         objTesList.options[intIndex-1].setAttribute('valtyp',aryB[3]);
         objTesList.options[intIndex-1].setAttribute('testxt',aryB[4]);
         objTesList.options[intIndex-1].setAttribute('tessta',aryB[5]);
         objTesList.options[intIndex-1].selected = true;
         objTesList.options[intIndex].value = aryA[0];
         objTesList.options[intIndex].text = aryA[1];
         objTesList.options[intIndex].setAttribute('tescde',aryA[2]);
         objTesList.options[intIndex].setAttribute('valtyp',aryA[3]);
         objTesList.options[intIndex].setAttribute('testxt',aryA[4]);
         objTesList.options[intIndex].setAttribute('tessta',aryA[5]);
         objTesList.options[intIndex].selected = false;
      }
   }
   function doTesDetailSortDown() {
      var intIndex;
      var intSelect;
      var objTesList = document.getElementById('TES_TesList');
      intSelect = 0;
      for (var i=0;i<objTesList.options.length;i++) {
         if (objTesList.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one test can be selected to move down');
         return;
      }
      if (intSelect == 1 && intIndex < objTesList.options.length-1) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objTesList.options[intIndex+1].value;
         aryA[1] = objTesList.options[intIndex+1].text;
         aryA[2] = objTesList.options[intIndex+1].getAttribute('tescde');
         aryA[3] = objTesList.options[intIndex+1].getAttribute('valtyp');
         aryA[4] = objTesList.options[intIndex+1].getAttribute('testxt');
         aryA[5] = objTesList.options[intIndex+1].getAttribute('tessta');
         aryB[0] = objTesList.options[intIndex].value;
         aryB[1] = objTesList.options[intIndex].text;
         aryB[2] = objTesList.options[intIndex].getAttribute('tescde');
         aryB[3] = objTesList.options[intIndex].getAttribute('valtyp');
         aryB[4] = objTesList.options[intIndex].getAttribute('testxt');
         aryB[5] = objTesList.options[intIndex].getAttribute('tessta');
         objTesList.options[intIndex+1].value = aryB[0];
         objTesList.options[intIndex+1].text = aryB[1];
         objTesList.options[intIndex+1].setAttribute('tescde',aryB[2]);
         objTesList.options[intIndex+1].setAttribute('valtyp',aryB[3]);
         objTesList.options[intIndex+1].setAttribute('testxt',aryB[4]);
         objTesList.options[intIndex+1].setAttribute('tessta',aryB[5]);
         objTesList.options[intIndex+1].selected = true;
         objTesList.options[intIndex].value = aryA[0];
         objTesList.options[intIndex].text = aryA[1];
         objTesList.options[intIndex].setAttribute('tescde',aryA[2]);
         objTesList.options[intIndex].setAttribute('valtyp',aryA[3]);
         objTesList.options[intIndex].setAttribute('testxt',aryA[4]);
         objTesList.options[intIndex].setAttribute('tessta',aryA[5]);
         objTesList.options[intIndex].selected = false;
      }
   }
   function doTesDetailSelect() {
      if (!processForm()) {return;}
      startSchInstance('*TEST','Test','pts_tes_search.asp?VAL=1',function() {doTesDetailSelectCancel();},function(strCode,strText) {doTesDetailSelectAccept(strCode,strText);});
   }
   function doTesDetailSelectCancel() {
      displayScreen('dspTestDetail');
      document.getElementById('TES_TesCode').focus();
   }
   function doTesDetailSelectAccept(strCode,strText) {
      displayScreen('dspTestDetail');
      document.getElementById('TES_TesCode').value = strCode;
      document.getElementById('TES_TesCode').focus();
   }
   function doTesDetailCancel() {
      displayScreen('dspTest');
   }
   function doTesDetailAccept() {
      if (!processForm()) {return;}
      var objTesList = document.getElementById('TES_TesList');
      cobjTest.length = 0;
      var intIndex = 0;
      for (var i=0;i<objTesList.options.length;i++) {
         cobjTest[intIndex] = new clsTesData(objTesList.options[i].getAttribute('tescde'),objTesList.options[i].getAttribute('valtyp'),objTesList.options[i].getAttribute('testxt'));
         intIndex++;
      }
      loadTestData();
      displayScreen('dspTest');
   }

   //////////////////////
   // Pet Functions    //
   //////////////////////
   var cstrPetValidationCode;
   var cstrPetValidationText;
   var cstrPetValidationStatus;
   var cintPetRow;
   var cstrPetCode;
   var cobjPetData;
   function clsPetData(strPetCde,strPetNam) {
      this.petcde = strPetCde;
      this.petnam = strPetNam;
   }
   function requestPetUpdate(strCode) {
      cstrPetValidationCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVPET" VALCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_val_config_pet_retrieve.asp',function(strResponse) {checkPetUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkPetUpdate(strResponse) {
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
         cobjPetData = new Array();
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'VAL') {
               cstrPetValidationText = objElements[i].getAttribute('VALTXT');
               cstrPetValidationStatus = objElements[i].getAttribute('VALSTA');
            } else if (objElements[i].nodeName == 'PET') {
               cobjPetData[cobjPetData.length] = new clsPetData(objElements[i].getAttribute('PETCDE'),objElements[i].getAttribute('PETNAM'));
            }
         }
         loadPetData();
         document.getElementById('subPet').innerHTML = cstrPetValidationText;
         displayScreen('dspPet');
         document.getElementById('tabPet').focus();
         document.getElementById('divPet').scrollTop = 0;
         document.getElementById('divPet').scrollLeft = 0;
      }
   }
   function loadPetData() {
      var objTable = document.getElementById('tabPet');
      var objRow;
      var objCell;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      for (var i=0;i<cobjPetData.length;i++) {
         objRow = objTable.insertRow(-1);
         objRow.setAttribute('petcde',cobjPetData[i].petcde);
         objCell = objRow.insertCell(0);
         objCell.colSpan = 1;
         objCell.innerHTML = cobjPetData[i].petnam;
         objCell.className = 'clsLabelFB';
         objCell.style.whiteSpace = 'nowrap';
      }
   }
   function doPetAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (cstrPetValidationStatus != '1' && cstrPetValidationStatus != '2' && cstrPetValidationStatus != '3') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation must be status Raised, Allocation Complete, or Results Entered for pet update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDPET"';
      strXML = strXML+' VALCDE="'+fixXML(cstrPetValidationCode)+'"';
      strXML = strXML+'>';
      for (var i=0;i<cobjPetData.length;i++) {
         strXML = strXML+'<PET PETCDE="'+fixXML(cobjPetData[i].petcde)+'"/>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestPetAccept(\''+strXML+'\');',10);
   }
   function requestPetAccept(strXML) {
      doPostRequest('<%=strBase%>pts_val_config_pet_update.asp',function(strResponse) {checkPetAccept(strResponse);},false,streamXML(strXML));
   }
   function checkPetAccept(strResponse) {
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
         document.getElementById('PRO_ValCode').focus();
      }
   }
   function doPetCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   function doPetAdd() {
      cintPetRow = -1;
      cstrPetCode = '';
      document.getElementById('subPetDetail').innerHTML = cstrPetValidationText;
      document.getElementById('addPetDetail').style.display = 'block';
      displayScreen('dspPetDetail');
      document.getElementById('PET_PetCode').value = '';
      document.getElementById('PET_PetCode').focus();
   }
   /////////////////////////////
   // Pet Detail Functions    //
   /////////////////////////////
   function doPetDetailSelect() {
      if (!processForm()) {return;}
      startSchInstance('*PET','Pet','pts_pet_search.asp?VAL=1',function() {doPetDetailSelectCancel();},function(strCode,strText) {doPetDetailSelectAccept(strCode,strText);});
   }
   function doPetDetailSelectCancel() {
      displayScreen('dspPetDetail');
      document.getElementById('PET_PetCode').focus();
   }
   function doPetDetailSelectAccept(strCode,strText) {
      displayScreen('dspPetDetail');
      document.getElementById('PET_PetCode').value = strCode;
      document.getElementById('PET_PetCode').focus();
   }
   function doSamDetailCancel() {
      displayScreen('dspPet');
   }
   function doSamDetailAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (cintPetRow == -1) {
         if (document.getElementById('PET_PetCode').value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Pet code must be specified';
         }
         for (var i=0;i<cobjPetData.length;i++) {
            if (cobjPetData[i].petcde == document.getElementById('PET_PetCode').value) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Pet code already exists in the list';
               break;
            }
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strPetCode = cstrPetCode;
      if (cintPetRow == -1) {
         strPetCode = document.getElementById('PET_PetCode').value;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*SELPET"';
      strXML = strXML+' VALCDE="'+fixXML(cstrPetValidationCode)+'"';
      strXML = strXML+' PETCDE="'+fixXML(strPetCode)+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestPetDetailAccept(\''+strXML+'\');',10);
   }
   function requestPetDetailAccept(strXML) {
      doPostRequest('<%=strBase%>pts_val_config_pet_select.asp',function(strResponse) {checkPetDetailAccept(strResponse);},false,streamXML(strXML));
   }
   function checkPetDetailAccept(strResponse) {
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
         var intIndex = cintPetRow;
         if (cintPetRow == -1) {
            intIndex = cobjPetData.length;
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PET') {
               if (cintPetRow == -1) {
                  cobjPetData[intIndex] = new clsPetData();
               }
               cobjPetData[intIndex].petcde = objElements[i].getAttribute('PETCDE');
               cobjPetData[intIndex].petnam = objElements[i].getAttribute('PETNAM');
            }
         }
         cobjPetData.sort(sortPetDetailData);
         loadPetData();
         displayScreen('dspPet');
      }
   }
   function sortPetDetailData(obj01, obj02) {
      if ((obj01.petcde-0) < (obj02.petcde-0)) {
         return -1;
      } else if ((obj01.petcde-0) > (obj02.petcde-0)) {
         return 1;
      }
      return 0;
   }
   
   //////////////////////////
   // Allocation Functions //
   //////////////////////////
   var cstrAllocationValidationCode;
   var cstrAllocationValidationText;
   var cstrAllocationValidationStatus;
   var cstrAllocationDone;
   function requestAllocationUpdate(strCode) {
      cstrAllocationValidationCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVALC" VALCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_val_config_allocation_retrieve.asp',function(strResponse) {checkAllocationUpdate(strResponse);},false,streamXML(strXML));
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
            if (objElements[i].nodeName == 'VAL') {
               cstrAllocationValidationText = objElements[i].getAttribute('VALTXT');
               cstrAllocationValidationStatus = objElements[i].getAttribute('VALSTA');
               cstrAllocationDone = objElements[i].getAttribute('ALCDON');
            }
         }
         document.getElementById('subAllocation').innerHTML = cstrAllocationValidationText;
         displayScreen('dspAllocation');
      }
   }
   function doAllocationAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (cstrAllocationValidationStatus != '1' && cstrAllocationValidationStatus != '2' && cstrAllocationValidationStatus != '3') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation must be status Raised, Allocation Complete, or Results Entered for allocation update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDALC" VALCDE="'+fixXML(cstrAllocationValidationCode)+'"/>';
      doActivityStart(document.body);
      window.setTimeout('requestAllocationAccept(\''+strXML+'\');',10);
   }
   function requestAllocationAccept(strXML) {
      doPostRequest('<%=strBase%>pts_val_config_allocation_update.asp',function(strResponse) {checkAllocationAccept(strResponse);},false,streamXML(strXML));
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
         document.getElementById('PRO_ValCode').focus();
      }
   }
   function doAllocationCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }

   /////////////////////////////////
   // Allocation Report Functions //
   /////////////////////////////////
   var cstrAllocationReportCode;
   var cstrAllocationReportText;
   var cstrAllocationReportStatus;
   var cstrAllocationReportDone;
   function requestAllocationReportUpdate(strCode) {
      cstrAllocationReportCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVALC" VALCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_val_config_allocation_retrieve.asp',function(strResponse) {checkAllocationReport(strResponse);},false,streamXML(strXML));
   }
   function checkAllocationReport(strResponse) {
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
         var objValType = document.getElementById('PRO_AllRepType');
         objValType.selectedIndex = -1;
         objValType.options.length = 0;
         objValType.options[objValType.options.length] = new Option('** Select **','');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'VAL') {
               cstrAllocationReportText = objElements[i].getAttribute('VALTXT');
               cstrAllocationReportStatus = objElements[i].getAttribute('VALSTA');
               cstrAllocationReportDone = objElements[i].getAttribute('ALCDON');
            } else if (objElements[i].nodeName == 'VAL_TYPE') {
               objValType.options[objValType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            }
         }
         document.getElementById('subAllocationReport').innerHTML = cstrAllocationReportText;
         document.getElementById('PRO_AllRepSDate').value = '';
         displayScreen('dspAllocationReport');
      }
   }
   function doAllocationReportAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      var objValType = document.getElementById('PRO_AllRepType');
      if (cstrAllocationReportDone == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation must have had pets allocated';
      }
      if (objValType.selectedIndex == -1 || objValType.options[objValType.selectedIndex].value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation type must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strValType = objValType.options[objValType.selectedIndex].value;
      var strDate = document.getElementById('PRO_AllRepSDate').value;
      doReportOutput(eval('document.body'),'Pet Validation Allocation Report','*SPREADSHEET','select * from table(pts_app.pts_val_function.report_allocation(' + cstrAllocationReportCode + ',' + strValType + ',\'' + strDate + '\'))');
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   function doAllocationReportCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   
   ////////////////////////////////////
   // Questionnaire Report Functions //
   ////////////////////////////////////
   var cstrQuestionnaireReportCode;
   var cstrQuestionnaireReportText;
   var cstrQuestionnaireReportStatus;
   var cstrQuestionnaireReportDone;
   function requestQuestionnaireReportUpdate(strCode) {
      cstrQuestionnaireReportCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVALC" VALCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_val_config_allocation_retrieve.asp',function(strResponse) {checkQuestionnaireReport(strResponse);},false,streamXML(strXML));
   }
   function checkQuestionnaireReport(strResponse) {
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
         var objValType = document.getElementById('PRO_QueRepType');
         objValType.selectedIndex = -1;
         objValType.options.length = 0;
         objValType.options[objValType.options.length] = new Option('** Select **','');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'VAL') {
               cstrQuestionnaireReportText = objElements[i].getAttribute('VALTXT');
               cstrQuestionnaireReportStatus = objElements[i].getAttribute('VALSTA');
               cstrQuestionnaireReportDone = objElements[i].getAttribute('ALCDON');
            } else if (objElements[i].nodeName == 'VAL_TYPE') {
               objValType.options[objValType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            }
         }
         document.getElementById('subQuestionnaireReport').innerHTML = cstrQuestionnaireReportText;
         document.getElementById('PRO_QueRepSDate').value = '';
         displayScreen('dspQuestionnaireReport');
      }
   }
   function doQuestionnaireReportAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      var objValType = document.getElementById('PRO_QueRepType');
      if (cstrQuestionnaireReportDone == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation must have had pets allocated';
      }
      if (objValType.selectedIndex == -1 || objValType.options[objValType.selectedIndex].value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation type must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strValType = objValType.options[objValType.selectedIndex].value;
      var strDate = document.getElementById('PRO_QueRepSDate').value;
      doReportOutput(eval('document.body'),'Pet Validation Questionnaire Report','*CSV','select * from table(pts_app.pts_val_function.report_questionnaire(' + cstrQuestionnaireReportCode + ',' + strValType + ',\'' + strDate + '\'))');
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   function doQuestionnaireReportCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   
   ////////////////////////////////
   // Selection Report Functions //
   ////////////////////////////////
   var cstrSelectionReportCode;
   var cstrSelectionReportText;
   var cstrSelectionReportStatus;
   var cstrSelectionReportDone;
   function requestSelectionReportUpdate(strCode) {
      cstrSelectionReportCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVALC" VALCDE="'+strCode+'"/>';
      doPostRequest('<%=strBase%>pts_val_config_allocation_retrieve.asp',function(strResponse) {checkSelectionReport(strResponse);},false,streamXML(strXML));
   }
   function checkSelectionReport(strResponse) {
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
         var objValType = document.getElementById('PRO_SelRepType');
         objValType.selectedIndex = -1;
         objValType.options.length = 0;
         objValType.options[objValType.options.length] = new Option('** Select **','');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'VAL') {
               cstrSelectionReportText = objElements[i].getAttribute('VALTXT');
               cstrSelectionReportStatus = objElements[i].getAttribute('VALSTA');
               cstrSelectionReportDone = objElements[i].getAttribute('ALCDON');
            } else if (objElements[i].nodeName == 'VAL_TYPE') {
               objValType.options[objValType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            }
         }
         document.getElementById('subSelectionReport').innerHTML = cstrSelectionReportText;
         document.getElementById('PRO_SelRepSDate').value = '';
         displayScreen('dspSelectionReport');
      }
   }
   function doSelectionReportAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      var objValType = document.getElementById('PRO_SelRepType');
      if (cstrSelectionReportDone == '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation must have had pets allocated';
      }
      if (objValType.selectedIndex == -1 || objValType.options[objValType.selectedIndex].value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation type must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strValType = objValType.options[objValType.selectedIndex].value;
      var strDate = document.getElementById('PRO_SelRepSDate').value;
      doReportOutput(eval('document.body'),'Pet Validation Selection Report','*SPREADSHEET','select * from table(pts_app.pts_val_function.report_selection(' + cstrSelectionReportCode + ',' + strValType + ',\'' + strDate + '\'))');
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   function doSelectionReportCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }

   //////////////////////
   // Report Functions //
   //////////////////////
   function requestResultsReport(strCode) {
      doReportOutput(eval('document.body'),'Validation Results Report','*CSV','select * from table(pts_app.pts_val_function.report_results(' + strCode + '))');
      document.getElementById('PRO_ValCode').focus();
   }
   
   /////////////////////////////////
   // Candidates Report Functions //
   /////////////////////////////////
   function doCandidatesReportAccept() {
      var strDate = document.getElementById('PRO_CanRepSDate').value;
      doReportOutput(eval('document.body'),'Pet Validation Candidates Report','*CSV','select * from table(pts_app.pts_val_function.report_candidates(\'' + strDate + '\'))');
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   function doCandidatesReportCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
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
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_val_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Pet Validation Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Validation Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_ValCode" id="PRO_ValCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptPreview();">&nbsp;Preview&nbsp;</a></nobr></td>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptTest();">&nbsp;Tests&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptPet();">&nbsp;Pets&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptAllocation();">&nbsp;Allocation&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=11 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsHeader" align=center colspan=1 nowrap><nobr>Reporting</nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReportAllocation();">&nbsp;Allocation&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReportQuestionnaire();">&nbsp;Questionnaire&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReportSelection();">&nbsp;Pet Selection&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReportResults();">&nbsp;Results&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doReportCandidates();">&nbsp;Candidates&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Validation Maintenance</nobr></td>
         <input type="hidden" name="DEF_ValCode" id="DEF_ValCode" value="">
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Title:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_ValText" id="DEF_ValText" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_ValStat"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_PetType"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Comment:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_ValCtxt" id="DEF_ValCtxt" size="80" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Start Date (DD/MM/YYYY):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_ValSdat" id="DEF_ValSdat" size="10" maxlength="10" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Field Work Week (YYYYWW):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_ValFwek" id="DEF_ValFwek" size="6" maxlength="6" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
   <table id="dspPreview" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPreview" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Preview</nobr></td>
      </tr>
      <tr>
         <td id="subPreview" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Validation Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Tests Created:&nbsp;</nobr></td>
         <td id="PRE_TesDta" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
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
   <table id="dspTest" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doTestAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedTest" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Tests</nobr></td>
      </tr>
      <tr>
         <td id="subTest" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Validation Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div id="divTest" class="clsScroll01" style="display:block;visibility:visible">
               <table id="tabTest" class="clsTableBody" style="display:block;visibility:visible" align=left cellpadding="2" cellspacing="1"></table>
            </div>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTestCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTestAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspTestDetail" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doTesDetailAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedTestDetail" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Test Detail</nobr></td>
      </tr>
      <tr>
         <td id="subTesDetail" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Validation Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Test Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="TES_TesCode" id="TES_TesCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=left colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=left cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTesDetailSelect();">&nbsp;Select&nbsp;</a></nobr></td></tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=left colspan=2 nowrap><nobr>
            <table class="clsTable01" align=left cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTesDetailAdd();">&nbsp;Add&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTesDetailDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=left colspan=2 nowrap><nobr>
            <table align=left cols=2 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="TES_TesList" name="TES_TesList" style="width:600px" multiple size=20></select>
                  </nobr></td>
                  <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" width=100% align=center cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="doTesDetailSortUp();"></nobr></td></tr>
                        <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="doTesDetailSortDown();"></nobr></td></tr>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTesDetailCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTesDetailAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspPet" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPetAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPet" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Pet</nobr></td>
      </tr>
      <tr>
         <td id="subPet" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Validation Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=2 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPetAdd();">&nbsp;Add Pet&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div id="divPet" class="clsScroll01" style="display:block;visibility:visible">
               <table id="tabPet" class="clsTableBody" style="display:block;visibility:visible" align=left cellpadding="2" cellspacing="1"></table>
            </div>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPetCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPetAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspPetDetail" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSamDetailAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPetDetail" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Pet Detail</nobr></td>
      </tr>
      <tr>
         <td id="subPetDetail" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Validation Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addPetDetail" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="PET_PetCode" id="PET_PetCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=left colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=left cols=1 cellpadding="0" cellspacing="0">
                        <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPetDetailSelect();">&nbsp;Select&nbsp;</a></nobr></td></tr>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSamDetailCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSamDetailAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspAllocation" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doAllocationAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedAllocation" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Allocation</nobr></td>
      </tr>
      <tr>
         <td id="subAllocation" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Validation Name</nobr></td>
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
   <table id="dspAllocationReport" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doAllocationReportAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedAllocationReport" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Allocation Report</nobr></td>
      </tr>
      <tr>
         <td id="subAllocationReport" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Validation Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Validation Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="PRO_AllRepType"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Start Date (DD/MM/YYYY):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_AllRepSDate" id="PRO_AllRepSDate" size="10" maxlength="10" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doAllocationReportCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doAllocationReportAccept();">&nbsp;Generate&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspQuestionnaireReport" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doQuestionnaireReportAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedQuestionnaireReport" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Questionnaire Report</nobr></td>
      </tr>
      <tr>
         <td id="subQuestionnaireReport" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Validation Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Validation Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="PRO_QueRepType"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Start Date (DD/MM/YYYY):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_QueRepSDate" id="PRO_QueRepSDate" size="10" maxlength="10" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQuestionnaireReportCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doQuestionnaireReportAccept();">&nbsp;Generate&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspSelectionReport" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doQuestionnaireReportAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSelectionReport" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Selection Report</nobr></td>
      </tr>
      <tr>
         <td id="subSelectionReport" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Validation Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Validation Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="PRO_SelRepType"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Start Date (DD/MM/YYYY):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_SelRepSDate" id="PRO_SelRepSDate" size="10" maxlength="10" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectionReportCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectionReportAccept();">&nbsp;Generate&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspCandidatesReport" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doQuestionnaireReportAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedCandidatesReport" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Candidates Report</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Start Date (DD/MM/YYYY):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_CanRepSDate" id="PRO_CanRepSDate" size="10" maxlength="10" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doCandidatesReportCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doCandidatesReportAccept();">&nbsp;Generate&nbsp;</a></nobr></td>
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