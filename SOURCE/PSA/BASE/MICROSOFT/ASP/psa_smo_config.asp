<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PSA (Production Scheduling Application)            //
'// Script  : psa_smo_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : December 2009                                      //
'// Text    : This script implements the shift model             //
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
   strTarget = "psa_smo_config.asp"
   strHeading = "Shift Model Maintenance"

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
   strReturn = GetSecurityCheck("PSA_SMO_CONFIG")
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
      cobjScreens[0] = new clsScreen('dspLoad','hedLoad');
      cobjScreens[1] = new clsScreen('dspSelect','hedSelect');
      cobjScreens[2] = new clsScreen('dspDefine','hedDefine');
      cobjScreens[0].hedtxt = '**LOADING**';
      cobjScreens[1].hedtxt = 'Shift Model Selection';
      cobjScreens[2].hedtxt = 'Shift Model Maintenance';
      displayScreen('dspLoad');
      doSelectRefresh();
      doSelectRefresh();
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
   // Select Functions //
   //////////////////////
   var cstrSelectStrCode;
   var cstrSelectEndCode;
   function doSelectUpdate(strCode) {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+strCode+'\');',10);
   }
   function doSelectCopy(strCode) {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+strCode+'\');',10);
   }
   function doSelectCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
   }
   function doSelectRefresh() {
      if (!processForm()) {return;}
      cstrSelectStrCode = document.getElementById('SEL_SelCode').value;
      doActivityStart(document.body);
      window.setTimeout('requestSelectList(\'*SELDEF\');',10);
   }
   function doSelectPrevious() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestSelectList(\'*PRVDEF\');',10);
   }
   function doSelectNext() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestSelectList(\'*NXTDEF\');',10);
   }
   function requestSelectList(strAction) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="'+strAction+'" STRCDE="'+cstrSelectStrCode+'" ENDCDE="'+cstrSelectEndCode+'"/>';
      doPostRequest('<%=strBase%>psa_smo_config_select.asp',function(strResponse) {checkSelectList(strResponse);},false,streamXML(strXML));
   }
   function checkSelectList(strResponse) {
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
         displayScreen('dspSelect');
         var objSelCode = document.getElementById('SEL_SelCode');
         var objTabHead = document.getElementById('tabHeadList');
         var objTabBody = document.getElementById('tabBodyList');
         objTabHead.style.tableLayout = 'auto';
         objTabBody.style.tableLayout = 'auto';
         var objRow;
         var objCell;
         for (var i=objTabHead.rows.length-1;i>=0;i--) {
            objTabHead.deleteRow(i);
         }
         for (var i=objTabBody.rows.length-1;i>=0;i--) {
            objTabBody.deleteRow(i);
         }
         objRow = objTabHead.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Action&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Shift&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Name&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Status&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         cstrSelectStrCode = '';
         cstrSelectEndCode = '';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'LSTROW') {
               if (cstrSelectStrCode == '') {
                  cstrSelectStrCode = objElements[i].getAttribute('SMOCDE');
               }
               cstrSelectEndCode = objElements[i].getAttribute('SMOCDE');
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doSelectUpdate(\''+objElements[i].getAttribute('SMOCDE')+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectCopy(\''+objElements[i].getAttribute('SMOCDE')+'\');">Copy</a>&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('SMOCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('SMONAM')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('SMOSTS')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         if (objTabBody.rows.length == 0) {
            objRow = objTabBody.insertRow(-1);
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 4;
            objCell.innerHTML = '&nbsp;NO DATA FOUND&nbsp;';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
            setScrollable('HeadList','BodyList','horizontal');
            objTabHead.rows(0).cells[4].style.width = 16;
            objTabHead.style.tableLayout = 'auto';
            objTabBody.style.tableLayout = 'auto';
         } else {
            setScrollable('HeadList','BodyList','horizontal');
            objTabHead.rows(0).cells[4].style.width = 16;
            objTabHead.style.tableLayout = 'fixed';
            objTabBody.style.tableLayout = 'fixed';
         }
         objSelCode.value = cstrSelectStrCode;
         objSelCode.focus();
      }
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cobjBar0 = new Image();
   var cobjBar1 = new Image();
   cobjBar0.src = 'barBof.png';
   cobjBar1.src = 'barBon.png';
   var cstrDefineMode;
   var cstrDefineCode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDDEF" SMOCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_smo_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTDEF" SMOCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_smo_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CPYDEF" SMOCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_smo_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[2].hedtxt = 'Update Shift';
            document.getElementById('addDefine').style.display = 'none';
            document.getElementById('updDefine').style.display = 'block';
         } else {
            cobjScreens[2].hedtxt = 'Create Shift';
            document.getElementById('addDefine').style.display = 'block';
            document.getElementById('updDefine').style.display = 'none';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_SmoCode').value = '';
         document.getElementById('DEF_SmoName').value = '';
         var strSmoStat = '';
         var objSmoStat = document.getElementById('DEF_SmoStat');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'SHIFT') {
               if (cstrDefineMode == '*UPD') {
                  document.getElementById('DEF_UpdCode').innerHTML = '<p>'+objElements[i].getAttribute('SMOCDE')+'</p>';
               } else {
                  document.getElementById('DEF_SmoCode').value = objElements[i].getAttribute('SMOCDE');
               }
               document.getElementById('DEF_SmoName').value = objElements[i].getAttribute('SMONAM');
               document.getElementById('DEF_SmoStrt').value = objElements[i].getAttribute('SMOSTR');
               document.getElementById('DEF_SmoDura').value = objElements[i].getAttribute('SMODUR');
               strSmoStat = objElements[i].getAttribute('SMOSTS');
            }
         }
         objSmoStat.selectedIndex = -1;
         for (var i=0;i<objSmoStat.length;i++) {
            if (objSmoStat.options[i].value == strSmoStat) {
               objSmoStat.options[i].selected = true;
               break;
            }
         }
         doDefineLoad();
         if (cstrDefineMode == '*UPD') {
            document.getElementById('DEF_SmoName').focus();
         } else {
            document.getElementById('DEF_SmoCode').focus();
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objSmoStat = document.getElementById('DEF_SmoStat');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrDefineMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDDEF"';
         strXML = strXML+' SMOCDE="'+fixXML(cstrDefineCode)+'"';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTDEF"';
         strXML = strXML+' SMOCDE="'+fixXML(document.getElementById('DEF_SmoCode').value)+'"';
      }
      strXML = strXML+' SMONAM="'+fixXML(document.getElementById('DEF_SmoName').value)+'"';
      strXML = strXML+' SMOSTR="'+fixXML(document.getElementById('DEF_SmoStrt').value)+'"';
      strXML = strXML+' SMODUR="'+fixXML(document.getElementById('DEF_SmoDura').value)+'"';
      if (objSmoStat.selectedIndex == -1) {
         strXML = strXML+' SMOSTS=""';
      } else {
         strXML = strXML+' SMOSTS="'+fixXML(objSmoStat.options[objSmoStat.selectedIndex].value)+'"';
      }
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>psa_smo_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         doSelectRefresh();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspSelect');
      document.getElementById('SEL_SelCode').focus();
   }
   function doDefineLoad() {
      var intWidth = document.getElementById('DEF_D04').offsetWidth;
      document.getElementById('DEF_D01').style.width = intWidth;
      document.getElementById('DEF_D02').style.width = intWidth;
      document.getElementById('DEF_D03').style.width = intWidth;
      document.getElementById('DEF_D05').style.width = intWidth;
      document.getElementById('DEF_D06').style.width = intWidth;
      document.getElementById('DEF_D07').style.width = intWidth;
      var intBarIdx = 0;
      var objTabShift = document.getElementById('DEF_DspTable');
      var objRow;
      var objCell;
      var objImage;
      var strTime;
      for (var i=objTabShift.rows.length-1;i>=1;i--) {
         objTabShift.deleteRow(i);
      }
      for (var i=0;i<=23;i++) {
         if ( i < 10) {
            strTime = '0'+i+':00';
         } else {
            strTime = i+':00';
         }
         objRow = objTabShift.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.rowSpan = 4;
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.innerHTML = strTime;
         objCell.className = 'clsLabelBB';
         objCell.style.whiteSpace = 'nowrap';
         objCell.style.border = '#c0c0c0 1px solid';
         objCell.style.padding = '1px';

         for (var j=1;j<=7;j++) {
            intBarIdx++;
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.className = 'clsLabelBN';
            objCell.style.whiteSpace = 'nowrap';
            objCell.style.borderTop = '#c0c0c0 1px solid';
            objCell.style.borderRight = '#c0c0c0 1px solid';
            objCell.style.paddingTop = '1px';
            objImage = document.createElement('img');
            objImage.id = 'DEF_B'+intBarIdx;
            objImage.src = cobjBar0.src;
            objImage.align = 'absmiddle';
            objImage.style.height = '5px';
            objImage.style.width = '16px';
            objCell.appendChild(objImage);
         }
         objRow = objTabShift.insertRow(-1);
         for (var j=1;j<=7;j++) {
            intBarIdx++;
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.className = 'clsLabelBN';
            objCell.style.whiteSpace = 'nowrap';
            objCell.style.borderRight = '#c0c0c0 1px solid';
            objImage = document.createElement('img');
            objImage.id = 'DEF_B'+intBarIdx;
            objImage.src = cobjBar0.src;
            objImage.align = 'absmiddle';
            objImage.style.height = '5px';
            objImage.style.width = '16px';
            objCell.appendChild(objImage);
         }
         objRow = objTabShift.insertRow(-1);
         for (var j=1;j<=7;j++) {
            intBarIdx++;
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.className = 'clsLabelBN';
            objCell.style.whiteSpace = 'nowrap';
            objCell.style.borderRight = '#c0c0c0 1px solid';
            objImage = document.createElement('img');
            objImage.id = 'DEF_B'+intBarIdx;
            objImage.src = cobjBar0.src;
            objImage.align = 'absmiddle';
            objImage.style.height = '5px';
            objImage.style.width = '16px';
            objCell.appendChild(objImage);
         }
         objRow = objTabShift.insertRow(-1);
         for (var j=1;j<=7;j++) {
            intBarIdx++;
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.className = 'clsLabelBN';
            objCell.style.whiteSpace = 'nowrap';
            objCell.style.borderRight = '#c0c0c0 1px solid';
            objImage = document.createElement('img');
            objImage.id = 'DEF_B'+intBarIdx;
            objImage.src = cobjBar0.src;
            objImage.align = 'absmiddle';
            objImage.style.height = '5px';
            objImage.style.width = '16px';
            objCell.appendChild(objImage);
         }
      }
      doDefinePaint();
   }
   function doDefinePaint() {
      var objSelCode = document.getElementById('DEF_SelCode');
      for (var i=1;i<=672;i++) {
         document.getElementById('DEF_B'+i).src = cobjBarBof;
      }
      var intStrTim = 0;
      var intDurMin = 0;
      var intBarCnt = 0;
      var intBarIdx = 0;
      for (var i=0;i<objSelCode.options.length;i++) {
         intStrTim = objSelCode[i].getAttribute('strtim');
         intDurMin = objSelCode[i].getAttribute('durmin');
         intBarCnt = (intDurMin / 60) * 4;
         if (i == 0) {
            intBarIdx = (Math.floor(intStrTim / 100) + ((intStrTim % 100) / 60)) * 4;
         }
         if ((intBarIdx + intBarCnt) > 673) {
            alert('The weekly shift cycle has been exceeded - the last ('+(objSelCode.options.length-i)+') shift(s) have not been used');
         }
         for (var j=1;j<=intBarCnt;j++) {
            document.getElementById('DEF_B'+intBarIdx).src = cobjBarBon;
            intBarIdx++;
         }
      }
   }
   function selectShiftCodes() {
      var objShiCode = document.getElementById('DEF_ShiCode');
      var objSelCode = document.getElementById('DEF_SelCode');
      for (var i=0;i<objShiCode.options.length;i++) {
         if (objShiCode.options[i].selected == true) {
            objSelCode.options[objSelCode.options.length] = new Option(objShiCode[i].text,objShiCode[i].value);
         }
      }
      doDefinePaint();
   }
   function removeShiftCodes() {
      var objSelCode = document.getElementById('DEF_SelCode');
      var objYarra = new Array();
      var intYindx = 0;
      for (var i=0;i<objSelCode.options.length;i++) {
         if (objSelCode.options[i].selected == false) {
            objYarra[intYindx] = objSelCode[i];
            intYindx++;
         }
      }
      objSelCode.options.length = 0;
      objSelCode.selectedIndex = -1;
      for (var i=0;i<objYarra.length;i++) {
         objSelCode.options[i] = objYarra[i];
      }
      doDefinePaint();
   }
   function upShiftCode() {
      var intIndex;
      var intSelect;
      var objSelCode = document.getElementById('DEF_SelCode');
      intSelect = 0;
      for (var i=0;i<objSelCode.options.length;i++) {
         if (objSelCode.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one shift can be selected to move up');
         return;
      }
      if (intSelect == 1 && intIndex > 0) {
         var objYarra = new Array();
         var intYindx = 0;
         for (var i=0;i<objSelCode.options.length;i++) {
            if (i == intIndex-1) {
               objYarra[intYindx] = objList[intIndex];
               intYindx++;
            } else if (i == intIndex) {
               objYarra[intYindx] = objSelCode[intIndex-1];
               intYindx++;
            } else {
               objYarra[intYindx] = objSelCode[i];
               intYindx++;
            }
         }
         objSelCode.options.length = 0;
         objSelCode.selectedIndex = -1;
         for (var i=0;i<objYarra.length;i++) {
            objSelCode.options[i] = objYarra[i];
         }
         objSelCode.options[intIndex-1].selected = true;
         objSelCode.options[intIndex].selected = false;
      }
      doDefinePaint();
   }
   function downShiftCode() {
      var intIndex;
      var intSelect;
      var objSelCode = document.getElementById('DEF_SelCode');
      intSelect = 0;
      for (var i=0;i<objSelCode.options.length;i++) {
         if (objSelCode.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one shift can be selected to move down');
         return;
      }
      if (intSelect == 1 && intIndex < objSelCode.options.length-1) {
         var objYarra = new Array();
         var intYindx = 0;
         for (var i=0;iobjSelCode.options.length;i++) {
            if (i == intIndex+1) {
               objYarra[intYindx] = objSelCode[intIndex];
               intYindx++;
            } else if (i == intIndex) {
               objYarra[intYindx] = objSelCode[intIndex+1];
               intYindx++;
            } else {
               objYarra[intYindx] = objSelCode[i];
               intYindx++;
            }
         }
         objSelCode.options.length = 0;
         objSelCode.selectedIndex = -1;
         for (var i=0;i<objYarra.length;i++) {
            objSelCode.options[i] = objYarra[i];
         }
         objSelCode.options[intIndex+1].selected = true;
         objSelCode.options[intIndex].selected = false;
      }
      doDefinePaint();
   }

// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('psa_smo_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspSelect" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSelect" class="clsFunction" align=center colspan=2 nowrap><nobr>Shift Model Selection</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=5 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><input class="clsInputNN" style="text-transform:uppercase;" type="text" name="SEL_SelCode" size="32" maxlength="32" value="" onFocus="setSelect(this);"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectCreate();">&nbsp;Create&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectPrevious();"><&nbsp;Prev&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectNext();">&nbsp;Next&nbsp;></a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHeadList">
                     <table class="clsTableHead" id="tabHeadList" align=left cols=1 cellpadding="0" cellspacing="1">
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBodyList">
                     <table class="clsTableBody" id="tabBodyList" align=left cols=1 cellpadding="0" cellspacing="1"></table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Shift Model Define</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Shift Model Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_SmoCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="updDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align="right" valign="center" colspan="1" nowrap><nobr>&nbsp;Shift Model Code:&nbsp;</nobr></td>
         <td id="DEF_UpdCode" class="clsLabelBB" align="left" valign="center" colspan="1" nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Shift Model Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_SmoName" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Shift Model Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_SmoStat">
               <option value="0">Inactive
               <option value="1">Active
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 width=100% cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
                     <table align=center border=0 cellpadding=0 cellspacing=2 cols=4>
                        <tr>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Available Shifts&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Selected Shifts&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                              <select class="clsInputBN" id="DEF_ShiCode" name="DEF_ShiCode" style="width:300px" multiple size=20></select>
                           </nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                              <table class="clsTable01" width=100% align=center cols=2 cellpadding="0" cellspacing="0">
                                 <tr>
                                    <td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_loff.gif" align=absmiddle onClick="removeShiftCodes();"></nobr></td>
                                    <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_roff.gif" align=absmiddle onClick="selectShiftCodes();"></nobr></td>
                                 </tr>
                              </table>
                           </nobr></td>
                           <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                              <select class="clsInputBN" id="DEF_SelCode" name="DEF_SelCode" style="width:300px" multiple size=20></select>
                           </nobr></td>

                           <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>
                              <table class="clsTable01" width=100% align=center cols=1 cellpadding="0" cellspacing="0">
                                 <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="upShiftCode();"></nobr></td></tr>
                                 <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="downShiftCode();"></nobr></td></tr>
                              </table>
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
         <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
            <table id="DEF_DspTable" class="clsPanel" style="border-collapse:collapse;border:#40414c 2px solid;" align=center cols=8 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsLabelBB" style="border:#c0c0c0 1px solid;" align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td id="DEF_D01" class="clsLabelBB" style="border:#c0c0c0 1px solid;padding:1px;" align=center colspan=1 nowrap><nobr>Sunday</nobr></td>
                  <td id="DEF_D02" class="clsLabelBB" style="border:#c0c0c0 1px solid;padding:1px;" align=center colspan=1 nowrap><nobr>Monday</nobr></td>
                  <td id="DEF_D03" class="clsLabelBB" style="border:#c0c0c0 1px solid;padding:1px;" align=center colspan=1 nowrap><nobr>Tuesday</nobr></td>
                  <td id="DEF_D04" class="clsLabelBB" style="border:#c0c0c0 1px solid;padding:1px;" align=center colspan=1 nowrap><nobr>Wednesday</nobr></td>
                  <td id="DEF_D05" class="clsLabelBB" style="border:#c0c0c0 1px solid;padding:1px;" align=center colspan=1 nowrap><nobr>Thursday</nobr></td>
                  <td id="DEF_D06" class="clsLabelBB" style="border:#c0c0c0 1px solid;padding:1px;" align=center colspan=1 nowrap><nobr>Friday</nobr></td>
                  <td id="DEF_D07" class="clsLabelBB" style="border:#c0c0c0 1px solid;padding:1px;" align=center colspan=1 nowrap><nobr>Saturday</nobr></td>
               </tr>
            </table>
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
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->