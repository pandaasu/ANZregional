<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_hou_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the household configuration //
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
   strTarget = "pts_hou_config.asp"
   strHeading = "Household Maintenance"

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
   strReturn = GetSecurityCheck("PTS_HOU_CONFIG")
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
      cobjScreens[0].hedtxt = 'Household Prompt';
      cobjScreens[1].hedtxt = 'Household Maintenance';
      initSearch();
      initClass('Household',function() {doDefineClaCancel();},function(intRowIndex,objValues) {doDefineClaAccept(intRowIndex,objValues);});
      displayScreen('dspPrompt');
      document.getElementById('PRO_HouCode').focus();
   }

   ///////////////////////
   // Control Functions //
   ///////////////////////
   var cobjScreens = new Array();
   function clsScreen(strScrName,strHedName) {
      this.scrnam = strScrName;
      this.hednam= strHedName;
      this.hedtxt= '';
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
      if (document.getElementById('PRO_HouCode').value == '') {
         doPromptCreate();
      } else {
         doPromptUpdate();
      }
   }
   function doPromptUpdate() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_HouCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Household code must be entered for update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+document.getElementById('PRO_HouCode').value+'\');',10);
   }
   function doPromptCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
   }
   function doPromptCopy() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_HouCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Household code must be entered for copy';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+document.getElementById('PRO_HouCode').value+'\');',10);
   }
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*HOUSEHOLD','Household','pts_hou_search.asp',function() {doPromptHouCancel();},function(strCode,strText) {doPromptHouSelect(strCode,strText);});
   }
   function doPromptHouCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_HouCode').focus();
   }
   function doPromptHouSelect(strCode,strText) {
      document.getElementById('PRO_HouCode').value = strCode;
      displayScreen('dspPrompt');
      document.getElementById('PRO_HouCode').focus();
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDHOU" HOUCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_hou_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTHOU" HOUCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_hou_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYHOU" HOUCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_hou_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[1].hedtxt ='Update Household ('+cstrDefineCode+')';
         } else {
            cobjScreens[1].hedtxt ='Create Household (*NEW)';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_HouCode').value = '';
         document.getElementById('DEF_LocStrt').value = '';
         document.getElementById('DEF_LocTown').value = '';
         document.getElementById('DEF_LocPcde').value = '';
         document.getElementById('DEF_LocCnty').value = '';
         document.getElementById('DEF_TelAcde').value = '';
         document.getElementById('DEF_TelNumb').value = '';
         document.getElementById('DEF_ConSnam').value = '';
         document.getElementById('DEF_ConFnam').value = '';
         document.getElementById('DEF_ConByer').value = '';
         document.getElementById('DEF_HouNote').value = '';
         var strHouStat;
         var strGeoZone;
         var strDelNote;
         var objHouStat = document.getElementById('DEF_HouStat');
         var objGeoZone = document.getElementById('DEF_GeoZone');
         var objDelNote = document.getElementById('DEF_DelNote');
         objHouStat.options.length = 0;
         objGeoZone.options.length = 0;
         objDelNote.options.length = 0;
         document.getElementById('DEF_HouStat').focus();
         var objClaData = document.getElementById('DEF_ClaData');
         var objClaFont = document.getElementById('DEF_ClaFont');
         var objPetData = document.getElementById('DEF_PetData');
         var objPetFont = document.getElementById('DEF_PetFont');
         var objRow;
         var objCell;
         var strTabCode;
         var objSavAry;
         var objValAry;
         for (var i=objClaData.rows.length-1;i>=0;i--) {
            objClaData.deleteRow(i);
         }
         for (var i=objPetData.rows.length-1;i>=0;i--) {
            objPetData.deleteRow(i);
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'STA_LIST') {
               objHouStat.options[objHouStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'GEO_ZONE') {
               objGeoZone.options[objGeoZone.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'DEL_NOTE') {
               objDelNote.options[objDelNote.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'HOUSEHOLD') {
               document.getElementById('DEF_HouCode').value = objElements[i].getAttribute('HOUCODE');
               document.getElementById('DEF_LocStrt').value = objElements[i].getAttribute('LOCSTRT');
               document.getElementById('DEF_LocTown').value = objElements[i].getAttribute('LOCTOWN');
               document.getElementById('DEF_LocPcde').value = objElements[i].getAttribute('LOCPCDE');
               document.getElementById('DEF_LocCnty').value = objElements[i].getAttribute('LOCCNTY');
               document.getElementById('DEF_TelAcde').value = objElements[i].getAttribute('TELACDE');
               document.getElementById('DEF_TelNumb').value = objElements[i].getAttribute('TELNUMB');
               document.getElementById('DEF_ConSnam').value = objElements[i].getAttribute('CONSNAM');
               document.getElementById('DEF_ConFnam').value = objElements[i].getAttribute('CONFNAM');
               document.getElementById('DEF_ConByer').value = objElements[i].getAttribute('CONBYER');
               document.getElementById('DEF_HouNote').value = objElements[i].getAttribute('HOUNOTE');
               strHouStat = objElements[i].getAttribute('HOUSTAT');
               strGeoZone = objElements[i].getAttribute('GEOZONE');
               strDelNote = objElements[i].getAttribute('DELNOTE');
            } else if (objElements[i].nodeName == 'PET') {
               objRow = objPetData.insertRow(-1);
               objRow.setAttribute('petcde','PETCODE');
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('PETNAME');
               objCell.className = 'clsLabelFB';
               objCell.style.whiteSpace = 'nowrap';
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
         objHouStat.selectedIndex = -1;
         for (var i=0;i<objHouStat.length;i++) {
            if (objHouStat.options[i].value == strHouStat) {
               objHouStat.options[i].selected = true;
               break;
            }
         }
         objGeoZone.selectedIndex = -1;
         for (var i=0;i<objGeoZone.length;i++) {
            if (objGeoZone.options[i].value == strGeoZone) {
               objGeoZone.options[i].selected = true;
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
         objPetData.style.display = 'block';
         objPetFont.style.display = 'none';
         if (objPetData.rows.length == 0) {
            objPetData.style.display = 'none';
            objPetFont.style.display = 'block';
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objHouStat = document.getElementById('DEF_HouStat');
      var objGeoZone = document.getElementById('DEF_GeoZone');
      var objDelNote = document.getElementById('DEF_DelNote');
      var objClaData = document.getElementById('DEF_ClaData');
      var objRow;
      var objValAry;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*DEFHOU"';
      strXML = strXML+' HOUCODE="'+fixXML(document.getElementById('DEF_HouCode').value)+'"';
      strXML = strXML+' HOUSTAT="'+fixXML(objHouStat.options[objHouStat.selectedIndex].value)+'"';
      strXML = strXML+' GEOZONE="'+fixXML(objGeoZone.options[objGeoZone.selectedIndex].value)+'"';
      strXML = strXML+' DELNOTE="'+fixXML(objDelNote.options[objDelNote.selectedIndex].value)+'"';
      strXML = strXML+' LOCSTRT="'+fixXML(document.getElementById('DEF_LocStrt').value)+'"';
      strXML = strXML+' LOCTOWN="'+fixXML(document.getElementById('DEF_LocTown').value)+'"';
      strXML = strXML+' LOCPCDE="'+fixXML(document.getElementById('DEF_LocPcde').value)+'"';
      strXML = strXML+' LOCCNTY="'+fixXML(document.getElementById('DEF_LocCnty').value)+'"';
      strXML = strXML+' TELACDE="'+fixXML(document.getElementById('DEF_TelAcde').value)+'"';
      strXML = strXML+' TELNUMB="'+fixXML(document.getElementById('DEF_TelNumb').value)+'"';
      strXML = strXML+' CONSNAM="'+fixXML(document.getElementById('DEF_ConSnam').value)+'"';
      strXML = strXML+' CONFNAM="'+fixXML(document.getElementById('DEF_ConFnam').value)+'"';
      strXML = strXML+' CONBYER="'+fixXML(document.getElementById('DEF_ConByer').value)+'"';
      strXML = strXML+' HOUNOTE="'+fixXML(document.getElementById('DEF_HouNote').value)+'"';
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
      doPostRequest('<%=strBase%>pts_hou_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         document.getElementById('PRO_HouCode').value = '';
         document.getElementById('PRO_HouCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_HouCode').value = '';
      document.getElementById('PRO_HouCode').focus();
   }
   function doDefineClaSelect(intRow) {
      var objTable = document.getElementById('DEF_ClaData');
      objRow = objTable.rows[intRow];
      doClaUpdate(intRow,objRow.getAttribute('tabcde'),objRow.getAttribute('fldcde'),objRow.getAttribute('fldtxt'),objRow.getAttribute('inplen'),objRow.getAttribute('seltyp'),'',objRow.getAttribute('valary'));
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_hou_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPromptEnter();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Household Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Household Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_HouCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Household Maintenance</nobr></td>
         <input type="hidden" name="DEF_HouCode" value="">
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Household Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_HouStat"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Geographic Zone:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_GeoZone"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Delete Notifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_DelNote"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Location Street:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_LocStrt" size="120" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Location Town:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_LocTown" size="120" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Location Postcode:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_LocPcde" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Location Country:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_LocCnty" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Telephone Areacode:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TelAcde" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Telephone Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TelNumb" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Contact Surname:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_ConSnam" size="120" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Contact Full Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_ConFnam" size="120" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Contact Birth Year:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_ConByer" size="4" maxlength="4" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Household Notes:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <textArea class="clsInputNN" name="DEF_HouNote" rows="4" cols="100" value="" onFocus="setSelect(this);"></textArea>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Household Classification Data&nbsp;</nobr></td>
         <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Household Pets&nbsp;</nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=1 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="DEF_ClaData" class="clsTableBody" style="display:block;visibility:visible" cols=1 align=left cellpadding="2" cellspacing="1"></table>
               <font id="DEF_ClaFont" class="clsLabelWB" style="display:none;visibility:visible;font-size:12pt" align=center>NO CLASSIFICATIONS</font>
            </div>
         </nobr></td>
         <td align=center colspan=1 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="DEF_PetData" class="clsTableBody" style="display:block;visibility:visible" cols=1 align=left cellpadding="2" cellspacing="1"></table>
               <font id="DEF_PetFont" class="clsLabelWB" style="display:none;visibility:visible;font-size:12pt" align=center>NO PETS</font>
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