<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : SMS (SMS Reporting System)                         //
'// Script  : sms_prf_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : July 2009                                          //
'// Text    : This script implements the profile configuration   //
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
   strTarget = "sms_prf_config.asp"
   strHeading = "Profile Maintenance"

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
   strReturn = GetSecurityCheck("SMS_PRF_CONFIG")
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
      cobjScreens[1].hedtxt = 'Profile Selection';
      cobjScreens[2].hedtxt = 'Profile Maintenance';
      displayScreen('dspLoad');
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
      window.setTimeout('requestSelectList(\'*SELPRF\');',10);
   }
   function doSelectPrevious() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestSelectList(\'*PRVPRF\');',10);
   }
   function doSelectNext() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestSelectList(\'*NXTPRF\');',10);
   }
   function requestSelectList(strAction) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="'+strAction+'" STRCDE="'+cstrSelectStrCode+'" ENDCDE="'+cstrSelectEndCode+'"/>';
      doPostRequest('<%=strBase%>sms_prf_config_select.asp',function(strResponse) {checkSelectList(strResponse);},false,streamXML(strXML));
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
         objCell.innerHTML = '&nbsp;Profile&nbsp;';
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
                  cstrSelectStrCode = objElements[i].getAttribute('PRFCDE');
               }
               cstrSelectEndCode = objElements[i].getAttribute('PRFCDE');
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.innerHTML = '<a class="clsSelect" onClick="doSelectUpdate(\''+objElements[i].getAttribute('PRFCDE')+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectCopy(\''+objElements[i].getAttribute('PRFCDE')+'\');">Copy</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PRFCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PRFNAM')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PRFSTS')+'&nbsp;';
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
   var cstrDefineMode;
   var cstrDefineCode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="*UPDPRF" PRFCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>sms_prf_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="*CRTPRF" PRFCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>sms_prf_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="*CPYPRF" PRFCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>sms_prf_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[2].hedtxt = 'Update Profile ('+cstrDefineCode+')';
            document.getElementById('addDefine').style.display = 'none';
         } else {
            cobjScreens[2].hedtxt = 'Create Profile';
            document.getElementById('addDefine').style.display = 'block';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_PrfCode').value = '';
         document.getElementById('DEF_PrfName').value = '';
         document.getElementById('DEF_SndDay1').checked = false;
         document.getElementById('DEF_SndDay2').checked = false;
         document.getElementById('DEF_SndDay3').checked = false;
         document.getElementById('DEF_SndDay4').checked = false;
         document.getElementById('DEF_SndDay5').checked = false;
         document.getElementById('DEF_SndDay6').checked = false;
         document.getElementById('DEF_SndDay7').checked = false;
         var strPrfStat = '';
         var strQryCode = '';
         var objPrfStat = document.getElementById('DEF_PrfStat');
         var objQryCode = document.getElementById('DEF_QryCode');
         var objRcpValu = document.getElementById('DEF_RcpValu');
         var objFltValu = document.getElementById('DEF_FltValu');
         var objMsgValu = document.getElementById('DEF_MsgValu');
         var objRcpList = document.getElementById('DEF_RcpList');
         var objFltList = document.getElementById('DEF_FltList');
         var objMsgList = document.getElementById('DEF_MsgList');
         objQryCode.options.length = 0;
         objRcpValu.options.length = 0;
         objFltValu.options.length = 0;
         objMsgValu.options.length = 0;
         objRcpList.options.length = 0;
         objFltList.options.length = 0;
         objMsgList.options.length = 0;
         objRcpValu.selectedIndex = -1;
         objFltValu.selectedIndex = -1;
         objMsgValu.selectedIndex = -1;
         objRcpList.selectedIndex = -1;
         objFltList.selectedIndex = -1;
         objMsgList.selectedIndex = -1;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'QRY_LIST') {
               objQryCode.options[objQryCode.options.length] = new Option(objElements[i].getAttribute('QRYNAM'),objElements[i].getAttribute('QRYCDE'));
            } else if (objElements[i].nodeName == 'PROFILE') {
               document.getElementById('DEF_PrfCode').value = objElements[i].getAttribute('PRFCDE');
               document.getElementById('DEF_PrfName').value = objElements[i].getAttribute('PRFNAM');
               if (objElements[i].getAttribute('SNDD01') == '1') {
                  document.getElementById('DEF_SndDay1').checked = true;
               } 
               if (objElements[i].getAttribute('SNDD02') == '1') {
                  document.getElementById('DEF_SndDay2').checked = true;
               }
               if (objElements[i].getAttribute('SNDD03') == '1') {
                  document.getElementById('DEF_SndDay3').checked = true;
               }
               if (objElements[i].getAttribute('SNDD04') == '1') {
                  document.getElementById('DEF_SndDay4').checked = true;
               }
               if (objElements[i].getAttribute('SNDD05') == '1') {
                  document.getElementById('DEF_SndDay5').checked = true;
               }
               if (objElements[i].getAttribute('SNDD06') == '1') {
                  document.getElementById('DEF_SndDay6').checked = true;
               }
               if (objElements[i].getAttribute('SNDD07') == '1') {
                  document.getElementById('DEF_SndDay7').checked = true;
               }
               strPrfStat = objElements[i].getAttribute('PRFSTS');
               strQryCode = objElements[i].getAttribute('QRYCDE');
            } else if (objElements[i].nodeName == 'RECIPIENT') {
               if (objElements[i].getAttribute('RCPSEL') == '1') {
                  objRcpValu.options[objRcpValu.options.length] = new Option(objElements[i].getAttribute('RCPNAM'),objElements[i].getAttribute('RCPCDE'));
               }
               objRcpList.options[objRcpList.options.length] = new Option(objElements[i].getAttribute('RCPNAM'),objElements[i].getAttribute('RCPCDE'));
            } else if (objElements[i].nodeName == 'FILTER') {
               if (objElements[i].getAttribute('FLTSEL') == '1') {
                  objFltValu.options[objFltValu.options.length] = new Option(objElements[i].getAttribute('FLTNAM'),objElements[i].getAttribute('FLTCDE'));
               }
               objFltList.options[objFltList.options.length] = new Option(objElements[i].getAttribute('FLTNAM'),objElements[i].getAttribute('FLTCDE'));
            } else if (objElements[i].nodeName == 'MESSAGE') {
               if (objElements[i].getAttribute('MSGSEL') == '1') {
                  objMsgValu.options[objMsgValu.options.length] = new Option(objElements[i].getAttribute('MSGNAM'),objElements[i].getAttribute('MSGCDE'));
               }
               objMsgList.options[objMsgList.options.length] = new Option(objElements[i].getAttribute('MSGNAM'),objElements[i].getAttribute('MSGCDE'));
            }
         }
         objPrfStat.selectedIndex = -1;
         for (var i=0;i<objPrfStat.length;i++) {
            if (objPrfStat.options[i].value == strPrfStat) {
               objPrfStat.options[i].selected = true;
               break;
            }
         }
         objQryCode.selectedIndex = -1;
         for (var i=0;i<objQryCode.length;i++) {
            if (objQryCode.options[i].value == strQryCode) {
               objQryCode.options[i].selected = true;
               break;
            }
         }
         if (objQryCode.selectedIndex == -1 && objQryCode.length > 0) {
            objQryCode.selectedIndex = 0;
         }
         if (cstrDefineMode == '*UPD') {
            document.getElementById('DEF_PrfName').focus();
         } else {
            document.getElementById('DEF_PrfCode').focus();
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objPrfStat = document.getElementById('DEF_PrfStat');
      var objQryCode = document.getElementById('DEF_QryCode');
      var objRcpValu = document.getElementById('DEF_RcpValu');
      var objFltValu = document.getElementById('DEF_FltValu');
      var objMsgValu = document.getElementById('DEF_MsgValu');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrDefineMode == '*UPD') {
         strXML = strXML+'<SMS_REQUEST ACTION="*UPDPRF"';
         strXML = strXML+' PRFCDE="'+fixXML(cstrDefineCode)+'"';
      } else {
         strXML = strXML+'<SMS_REQUEST ACTION="*CRTPRF"';
         strXML = strXML+' PRFCDE="'+fixXML(document.getElementById('DEF_PrfCode').value)+'"';
      }
      strXML = strXML+' PRFNAM="'+fixXML(document.getElementById('DEF_PrfName').value)+'"';
      if (objPrfStat.selectedIndex == -1) {
         strXML = strXML+' PRFSTS=""';
      } else {
         strXML = strXML+' PRFSTS="'+fixXML(objPrfStat.options[objPrfStat.selectedIndex].value)+'"';
      }
      if (objQryCode.selectedIndex == -1) {
         strXML = strXML+' QRYCDE=""';
      } else {
         strXML = strXML+' QRYCDE="'+fixXML(objQryCode.options[objQryCode.selectedIndex].value)+'"';
      }
      if (document.getElementById('DEF_SndDay1').checked) {
         strXML = strXML+' SNDD01="1"';
      } else {
         strXML = strXML+' SNDD01="0"';
      }
      if (document.getElementById('DEF_SndDay2').checked) {
         strXML = strXML+' SNDD02="1"';
      } else {
         strXML = strXML+' SNDD02="0"';
      }
      if (document.getElementById('DEF_SndDay3').checked) {
         strXML = strXML+' SNDD03="1"';
      } else {
         strXML = strXML+' SNDD03="0"';
      }
      if (document.getElementById('DEF_SndDay4').checked) {
         strXML = strXML+' SNDD04="1"';
      } else {
         strXML = strXML+' SNDD04="0"';
      }
      if (document.getElementById('DEF_SndDay5').checked) {
         strXML = strXML+' SNDD05="1"';
      } else {
         strXML = strXML+' SNDD05="0"';
      }
      if (document.getElementById('DEF_SndDay6').checked) {
         strXML = strXML+' SNDD06="1"';
      } else {
         strXML = strXML+' SNDD06="0"';
      }
      if (document.getElementById('DEF_SndDay7').checked) {
         strXML = strXML+' SNDD07="1"';
      } else {
         strXML = strXML+' SNDD07="0"';
      }
      strXML = strXML+'>';
      for (var i=0;i<objRcpValu.options.length;i++) {
         strXML = strXML+'<RECIPIENT RCPCDE="'+fixXML(objRcpValu[i].value)+'"/>';
      }
      for (var i=0;i<objFltValu.options.length;i++) {
         strXML = strXML+'<FILTER FLTCDE="'+fixXML(objFltValu[i].value)+'"/>';
      }
      for (var i=0;i<objMsgValu.options.length;i++) {
         strXML = strXML+'<MESSAGE MSGCDE="'+fixXML(objMsgValu[i].value)+'"/>';
      }
      strXML = strXML+'</SMS_REQUEST>'

      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>sms_prf_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
   function selectRcpValues() {
      var objRcpValu = document.getElementById('DEF_RcpValu');
      var objRcpList = document.getElementById('DEF_RcpList');
      var bolFound;
      for (var i=0;i<objRcpList.options.length;i++) {
         if (objRcpList.options[i].selected == true) {
            bolFound = false;
            for (var j=0;j<objRcpValu.options.length;j++) {
               if (objRcpList[i].value == objRcpValu[j].value) {
                  bolFound = true;
                  break;
               }
            }
            if (!bolFound) {
               objRcpValu.options[objRcpValu.options.length] = new Option(objRcpList[i].text,objRcpList[i].value);
            }
         }
      }
   }
   function removeRcpValues() {
      var objRcpValu = document.getElementById('DEF_RcpValu');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objRcpValu.options.length;i++) {
         if (objRcpValu.options[i].selected == false) {
            objWork[intIndex] = objRcpValu[i];
            intIndex++;
         }
      }
      objRcpValu.options.length = 0;
      objRcpValu.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objRcpValu.options[i] = objWork[i];
      }
   }
   function selectFltValues() {
      var objFltValu = document.getElementById('DEF_FltValu');
      var objFltList = document.getElementById('DEF_FltList');
      var bolFound;
      for (var i=0;i<objFltList.options.length;i++) {
         if (objFltList.options[i].selected == true) {
            bolFound = false;
            for (var j=0;j<objFltValu.options.length;j++) {
               if (objFltList[i].value == objFltValu[j].value) {
                  bolFound = true;
                  break;
               }
            }
            if (!bolFound) {
               objFltValu.options[objFltValu.options.length] = new Option(objFltList[i].text,objFltList[i].value);
            }
         }
      }
   }
   function removeFltValues() {
      var objFltValu = document.getElementById('DEF_FltValu');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objFltValu.options.length;i++) {
         if (objFltValu.options[i].selected == false) {
            objWork[intIndex] = objFltValu[i];
            intIndex++;
         }
      }
      objFltValu.options.length = 0;
      objFltValu.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objFltValu.options[i] = objWork[i];
      }
   }
   function selectMsgValues() {
      var objMsgValu = document.getElementById('DEF_MsgValu');
      var objMsgList = document.getElementById('DEF_MsgList');
      var bolFound;
      for (var i=0;i<objMsgList.options.length;i++) {
         if (objMsgList.options[i].selected == true) {
            bolFound = false;
            for (var j=0;j<objMsgValu.options.length;j++) {
               if (objMsgList[i].value == objMsgValu[j].value) {
                  bolFound = true;
                  break;
               }
            }
            if (!bolFound) {
               objMsgValu.options[objMsgValu.options.length] = new Option(objMsgList[i].text,objMsgList[i].value);
            }
         }
      }
   }
   function removeMsgValues() {
      var objMsgValu = document.getElementById('DEF_MsgValu');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objMsgValu.options.length;i++) {
         if (objMsgValu.options[i].selected == false) {
            objWork[intIndex] = objMsgValu[i];
            intIndex++;
         }
      }
      objMsgValu.options.length = 0;
      objMsgValu.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objMsgValu.options[i] = objWork[i];
      }
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('sms_prf_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspSelect" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSelect" class="clsFunction" align=center colspan=2 nowrap><nobr>Profile Selection</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=8 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="SEL_SelCode" size="64" maxlength="64" value="" onFocus="setSelect(this);"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectCreate();">&nbsp;Create&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectPrevious();"><&nbsp;Prev&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
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
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Profile Define</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Profile Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_PrfCode" size="64" maxlength="64" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Profile Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_PrfName" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Profile Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_PrfStat">
               <option value="0">Inactive
               <option value="1">Active
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_QryCode"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Message Send Days:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="checkbox" name="DEF_SndDay2" value="1">Monday&nbsp;
            <input type="checkbox" name="DEF_SndDay3" value="1">Tuesday&nbsp;
            <input type="checkbox" name="DEF_SndDay4" value="1">Wednesday&nbsp;
            <input type="checkbox" name="DEF_SndDay5" value="1">Thursday&nbsp;
            <input type="checkbox" name="DEF_SndDay6" value="1">Friday&nbsp;
            <input type="checkbox" name="DEF_SndDay7" value="1">Saturday&nbsp;
            <input type="checkbox" name="DEF_SndDay1" value="1">Sunday&nbsp;
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
            <table align=center border=0 cellpadding=0 cellspacing=2 cols=3>
               <tr>
                  <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Selected Recipients&nbsp;</nobr></td>
                  <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Selected Filters&nbsp;</nobr></td>
                  <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Selected Messages&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="DEF_RcpValu" name="DEF_RcpValu" style="width:300px" multiple size=5></select>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="DEF_FltValu" name="DEF_FltValu" style="width:300px" multiple size=5></select>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="DEF_MsgValu" name="DEF_MsgValu" style="width:300px" multiple size=5></select>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=2 cellpadding="0" cellspacing="0">
                        <tr>
                           <td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="selectRcpValues();"></nobr></td>
                           <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="removeRcpValues();"></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=2 cellpadding="0" cellspacing="0">
                        <tr>
                           <td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="selectFltValues();"></nobr></td>
                           <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="removeFltValues();"></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" align=center cols=2 cellpadding="0" cellspacing="0">
                        <tr>
                           <td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="selectMsgValues();"></nobr></td>
                           <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="removeMsgValues();"></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="DEF_RcpList" name="DEF_RcpList" style="width:300px" multiple size=15></select>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="DEF_FltList" name="DEF_FltList" style="width:300px" multiple size=15></select>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="DEF_MsgList" name="DEF_MsgList" style="width:300px" multiple size=15></select>
                  </nobr></td>
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