<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_pet_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the pet configuration       //
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
   strTarget = "pts_pet_config.asp"
   strHeading = "Pet Maintenance"

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
   strReturn = GetSecurityCheck("PTS_PET_CONFIG")
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
      cobjScreens[0].hedtxt = 'Pet Prompt';
      cobjScreens[1].hedtxt = 'Pet Maintenance';
      initSearch();
      initClass('Pet',function() {doDefineClaCancel();},function(intRowIndex,objValues) {doDefineClaAccept(intRowIndex,objValues);});
      displayScreen('dspPrompt');
      document.getElementById('PRO_PetCode').focus();
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
      if (document.getElementById('PRO_PetCode').value == '') {
         doPromptCreate();
      } else {
         doPromptUpdate();
      }
   }
   function doPromptUpdate() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_PetCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Pet code must be entered for update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+document.getElementById('PRO_PetCode').value+'\');',10);
   }
   function doPromptCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
   }
   function doPromptCopy() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_PetCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Pet code must be entered for copy';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+document.getElementById('PRO_PetCode').value+'\');',10);
   }
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*PET','Pet','pts_pet_search.asp',function() {doPromptPetCancel();},function(strCode,strText) {doPromptPetSelect(strCode,strText);});
   }
   function doPromptPetCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_PetCode').focus();
   }
   function doPromptPetSelect(strCode,strText) {
      document.getElementById('PRO_PetCode').value = strCode;
      displayScreen('dspPrompt');
      document.getElementById('PRO_PetCode').focus();
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   var cstrHouCode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDPET" PETCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_pet_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTPET" PETCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_pet_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYPET" PETCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_pet_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[1].hedtxt = 'Update Pet ('+cstrDefineCode+')';
         } else {
            cobjScreens[1].hedtxt = 'Create Pet (*NEW)';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_PetCode').value = '';
         document.getElementById('DEF_PetName').value = '';
         document.getElementById('DEF_HouCode').value = '';
         document.getElementById('DEF_HouText').innerText = '';
         document.getElementById('DEF_BthYear').value = '';
         document.getElementById('DEF_FedCmnt').value = '';
         document.getElementById('DEF_HthCmnt').value = '';
         var strPetStat;
         var strPetType;
         var strDelNote;
         var objPetStat = document.getElementById('DEF_PetStat');
         var objPetType = document.getElementById('DEF_PetType');
         var objDelNote = document.getElementById('DEF_DelNote');
         objPetStat.options.length = 0;
         objPetType.options.length = 0;
         objDelNote.options.length = 0;
         document.getElementById('DEF_PetName').focus();
         var objClaData = document.getElementById('DEF_ClaData');
         var objClaFont = document.getElementById('DEF_ClaFont');
         var objRow;
         var objCell;
         var strTabCode;
         var objSavAry;
         var objValAry;
         for (var i=objClaData.rows.length-1;i>=0;i--) {
            objClaData.deleteRow(i);
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'STA_LIST') {
               objPetStat.options[objPetStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'PET_TYPE') {
               objPetType.options[objPetType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'DEL_NOTE') {
               objDelNote.options[objDelNote.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'PET') {
               document.getElementById('DEF_PetCode').value = objElements[i].getAttribute('PETCODE');
               document.getElementById('DEF_PetName').value = objElements[i].getAttribute('PETNAME');
               document.getElementById('DEF_HouCode').value = objElements[i].getAttribute('HOUCODE');
               document.getElementById('DEF_HouText').innerText = objElements[i].getAttribute('HOUTEXT');
               document.getElementById('DEF_BthYear').value = objElements[i].getAttribute('BTHYEAR');
               document.getElementById('DEF_FedCmnt').value = objElements[i].getAttribute('FEDCMNT');
               document.getElementById('DEF_HthCmnt').value = objElements[i].getAttribute('HTHCMNT');
               strPetStat = objElements[i].getAttribute('PETSTAT');
               strPetType = objElements[i].getAttribute('PETTYPE');
               strDelNote = objElements[i].getAttribute('DELNOTE');
               cstrHouCode = objElements[i].getAttribute('HOUCODE');
            } else if (objElements[i].nodeName == 'TABLE') {
               objRow = objClaData.insertRow(-1);
               objRow.setAttribute('tabcde','*HEAD');
               objCell = objRow.insertCell(0);
               objCell.colSpan = 3;
               objCell.innerText = objElements[i].getAttribute('TABTXT');
               objCell.className = 'clsLabelFB';
               objCell.style.whiteSpace = 'nowrap';
               strTabCode = objElements[i].getAttribute('TABCDE');
            } else if (objElements[i].nodeName == 'FIELD') {
               objRow = objClaData.insertRow(-1);
               objRow.setAttribute('tabcde',strTabCode);
               objRow.setAttribute('fldcde',objElements[i].getAttribute('FLDCDE'));
               objRow.setAttribute('fldtxt',objElements[i].getAttribute('FLDTXT'));
               objRow.setAttribute('seltyp',objElements[i].getAttribute('SELTYP'));
               objRow.setAttribute('inplen',objElements[i].getAttribute('INPLEN'));
               objRow.setAttribute('savary',new Array());
               objRow.setAttribute('valary',new Array());
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '<a class="clsSelect" onClick="doDefineClaSelect(\''+objRow.rowIndex+'\');">Select</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('FLDTXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(2);
               objCell.colSpan = 1;
               objCell.innerText = '*NONE';
               objCell.className = 'clsLabelFN';
            } else if (objElements[i].nodeName == 'VALUE') {
               objSavAry = objRow.getAttribute('savary');
               objSavAry[objSavAry.length] = new clsClaValue(objElements[i].getAttribute('VALCDE'),objElements[i].getAttribute('VALTXT'));
               objValAry = objRow.getAttribute('valary');
               objValAry[objValAry.length] = new clsClaValue(objElements[i].getAttribute('VALCDE'),objElements[i].getAttribute('VALTXT'));
               if (objValAry.length == 1) {
                  objCell.innerText = '';
                  if (objRow.getAttribute('seltyp') == '*TEXT') {
                     objCell.innerText = objCell.innerText+'"'+objElements[i].getAttribute('VALTXT')+'"';
                  } else {
                     objCell.innerText = objCell.innerText+objElements[i].getAttribute('VALTXT');
                  }
               } else {
                  if (objRow.getAttribute('seltyp') == '*TEXT') {
                     objCell.innerText = objCell.innerText+', "'+objElements[i].getAttribute('VALTXT')+'"';
                  } else {
                     objCell.innerText = objCell.innerText+', '+objElements[i].getAttribute('VALTXT');
                  }
               }
            }
         }
         objPetStat.selectedIndex = -1;
         for (var i=0;i<objPetStat.length;i++) {
            if (objPetStat.options[i].value == strPetStat) {
               objPetStat.options[i].selected = true;
               break;
            }
         }
         objPetType.selectedIndex = -1;
         for (var i=0;i<objPetType.length;i++) {
            if (objPetType.options[i].value == strPetType) {
               objPetType.options[i].selected = true;
               break;
            }
         }
         objDelNote.selectedIndex = -1;
         for (var i=0;i<objDelNote.length;i++) {
            if (objDelNote.options[i].value == strDelNote) {
               objDelNote.options[i].selected = true;
               break;
            }
         }
         objClaData.style.display = 'block';
         objClaFont.style.display = 'none';
         if (objClaData.rows.length == 0) {
            objClaData.style.display = 'none';
            objClaFont.style.display = 'block';
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objPetStat = document.getElementById('DEF_PetStat');
      var objPetType = document.getElementById('DEF_PetType');
      var objDelNote = document.getElementById('DEF_DelNote');
      var objClaData = document.getElementById('DEF_ClaData');
      var objRow;
      var objValAry;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*DEFPET"';
      strXML = strXML+' PETCODE="'+fixXML(document.getElementById('DEF_PetCode').value)+'"';
      strXML = strXML+' PETNAME="'+fixXML(document.getElementById('DEF_PetName').value)+'"';
      strXML = strXML+' PETSTAT="'+fixXML(objPetStat.options[objPetStat.selectedIndex].value)+'"';
      strXML = strXML+' PETTYPE="'+fixXML(objPetType.options[objPetType.selectedIndex].value)+'"';
      strXML = strXML+' HOUCODE="'+fixXML(document.getElementById('DEF_HouCode').value)+'"';
      strXML = strXML+' DELNOTE="'+fixXML(objDelNote.options[objDelNote.selectedIndex].value)+'"';
      strXML = strXML+' BTHYEAR="'+fixXML(document.getElementById('DEF_BthYear').value)+'"';
      strXML = strXML+' FEDCMNT="'+fixXML(document.getElementById('DEF_FedCmnt').value)+'"';
      strXML = strXML+' HTHCMNT="'+fixXML(document.getElementById('DEF_HthCmnt').value)+'"';
      strXML = strXML+'>';
      for (var i=0;i<objClaData.rows.length;i++) {
         objRow = objClaData.rows[i];
         if (objRow.getAttribute('tabcde') != '*HEAD') {
            objValAry = objRow.getAttribute('valary');
            if (objValAry.length != 0) {
               strXML = strXML+'<CLA_DATA TABCDE="'+objRow.getAttribute('tabcde')+'" FLDCDE="'+objRow.getAttribute('fldcde')+'">';
               for (var j=0;j<objValAry.length;j++) {
                  if (objRow.getAttribute('seltyp') == '*TEXT' || objRow.getAttribute('seltyp') == '*NUMBER') {
                     strXML = strXML+'<VAL_DATA VALCDE="'+objValAry[j].valcde+'" VALTXT="'+fixXML(objValAry[j].valtxt)+'"/>';
                  } else {
                     strXML = strXML+'<VAL_DATA VALCDE="'+objValAry[j].valcde+'" VALTXT=""/>';
                  }
               }
               strXML = strXML+'</CLA_DATA>';
            }
         }
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>pts_pet_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         }
         displayScreen('dspPrompt');
         document.getElementById('PRO_PetCode').value = '';
         document.getElementById('PRO_PetCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_PetCode').value = '';
      document.getElementById('PRO_PetCode').focus();
   }
   function doDefineHousehold() {
      if (!processForm()) {return;}
      startSchInstance('*HOUSEHOLD','Household','pts_hou_search.asp',function() {doDefineHouseholdCancel();},function(strCode,strText) {doDefineHouseholdSelect(strCode,strText);});
   }
   function doBlurHousehold() {
      var objHouCode = document.getElementById('DEF_HouCode');
      var objHouText = document.getElementById('DEF_HouText');
      if (objHouCode.value != cstrHouCode) {
         objHouText.innerText = '** DATA ENTRY **';
      }
      cstrHouCode = objHouCode.value;
   }
   function doDefineHouseholdCancel() {
      displayScreen('dspDefine');
      document.getElementById('DEF_PetName').focus();
   }
   function doDefineHouseholdSelect(strCode,strText) {
      document.getElementById('DEF_HouCode').value = strCode;
      document.getElementById('DEF_HouText').innerText = strText;
      cstrHouCode = strCode;
      displayScreen('dspDefine');
      document.getElementById('DEF_HouCode').focus();
   }
   function doDefineClaSelect(intRow) {
      var objTable = document.getElementById('DEF_ClaData');
      objRow = objTable.rows[intRow];
      var objPetType = document.getElementById('DEF_PetType');
      var strPetType = objPetType.options[objPetType.selectedIndex].value;
      doClaUpdate(intRow,objRow.getAttribute('tabcde'),objRow.getAttribute('fldcde'),objRow.getAttribute('fldtxt'),objRow.getAttribute('inplen'),objRow.getAttribute('seltyp'),strPetType,objRow.getAttribute('valary'));
   }
   function doDefineClaCancel() {
      displayScreen('dspDefine');
      document.getElementById('DEF_ClaData').focus();
   }
   function doDefineClaAccept(intRowIndex,objValues) {
      var objTable = document.getElementById('DEF_ClaData');
      objRow = objTable.rows[intRowIndex];
      objRow.cells[2].innerText = '*NONE';
      var strSelTyp = objRow.getAttribute('seltyp');
      var objSavAry = objRow.getAttribute('savary');
      var objValAry = objRow.getAttribute('valary');
      objValAry.length = 0;
      var bolChange = false;
      var bolFound = false;
      for (var i=0;i<objValues.length;i++) {
         objValAry[i] = new clsClaValue(objValues[i].valcde,objValues[i].valtxt);
         if (i == 0) {
            objRow.cells[2].innerText = '';
            if (objRow.getAttribute('seltyp') == '*TEXT') {
               objRow.cells[2].innerText = objRow.cells[2].innerText+'"'+objValues[i].valtxt+'"';
            } else {
               objRow.cells[2].innerText = objRow.cells[2].innerText+objValues[i].valtxt;
            }
         } else {
            if (objRow.getAttribute('seltyp') == '*TEXT') {
               objRow.cells[2].innerText = objRow.cells[2].innerText+', "'+objValues[i].valtxt+'"';
            } else {
               objRow.cells[2].innerText = objRow.cells[2].innerText+', '+objValues[i].valtxt;
            }
         }
         if (!bolChange) {
            bolFound = false;
            for (var j=0;j<objSavAry.length;j++) {
               if (strSelTyp == '*NUMBER' || strSelTyp == '*TEXT') {
                  if (objValues[i].valtxt == objSavAry[j].valtxt) {
                     bolFound = true;
                     break;
                  }
               } else {
                  if (objValues[i].valcde == objSavAry[j].valcde) {
                     bolFound = true;
                     break;
                  }
               }
            }
            if (!bolFound) {
               bolChange = true;
            }
         }
      }
      if (objValAry.length != objSavAry.length) {
         bolChange = true;
      }
      if (!bolChange) {
         objRow.cells[2].className = 'clsLabelFN';
      } else {
         objRow.cells[2].className = 'clsLabelFG';
      }
      displayScreen('dspDefine');
      document.getElementById('DEF_ClaData').focus();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<!--#include file="pts_search_code.inc"-->
<!--#include file="pts_class_code.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_pet_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPromptEnter();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Pet Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_PetCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCreate();">&nbsp;Create&nbsp;</a></nobr></td>
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
   </table>
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Pet Maintenance</nobr></td>
         <input type="hidden" name="DEF_PetCode" value="">
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_PetName" size="100" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_PetStat"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_PetType"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Household Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="DEF_HouCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);doBlurHousehold();"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=left colspan=1 nowrap><nobr>
                     <table class="clsGrid02" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
                        <tr>
                           <td class="clsLabelBB" align=left colspan=1 nowrap><nobr>
                              <table class="clsTable01" align=left cols=1 cellpadding="0" cellspacing="0">
                                 <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineHousehold();">&nbsp;Select&nbsp;</a></nobr></td></tr>
                              </table>
                           </nobr></td>
                           <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td class="clsLabelBB" id="DEF_HouText" align=left valign=center colspan=1 nowrap></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Delete Notifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_DelNote"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Birth Year:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_BthYear" size="4" maxlength="4" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Feeding Comments:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <textArea class="clsInputNN" name="DEF_FedCmnt" rows="2" cols="100" onFocus="setSelect(this);"></textArea>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Health Comments:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <textArea class="clsInputNN" name="DEF_HthCmnt" rows="2" cols="100" onFocus="setSelect(this);"></textArea>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Pet Classification Data&nbsp;</nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="DEF_ClaData" class="clsTableBody" style="display:block;visibility:visible" cols=1 align=left cellpadding="2" cellspacing="1"></table>
               <font id="DEF_ClaFont" class="clsLabelWB" style="display:none;visibility:visible;font-size:12pt" align=center>NO CLASSIFICATIONS</font>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
<!--#include file="pts_search_html.inc"-->
<!--#include file="pts_class_html.inc"-->
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->