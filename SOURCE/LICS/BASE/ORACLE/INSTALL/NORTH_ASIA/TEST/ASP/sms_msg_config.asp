<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : SMS (SMS Reporting System)                         //
'// Script  : sms_msg_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : July 2009                                          //
'// Text    : This script implements the message configuration   //
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
   strTarget = "sms_msg_config.asp"
   strHeading = "Message Maintenance"

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
   strReturn = GetSecurityCheck("SMS_MSG_CONFIG")
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
      cobjScreens[1].hedtxt = 'Message Selection';
      cobjScreens[2].hedtxt = 'Message Maintenance';
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
      window.setTimeout('requestSelectList(\'*SELMSG\');',10);
   }
   function doSelectPrevious() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestSelectList(\'*PRVMSG\');',10);
   }
   function doSelectNext() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestSelectList(\'*NXTMSG\');',10);
   }
   function requestSelectList(strAction) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="'+strAction+'" STRCDE="'+cstrSelectStrCode+'" ENDCDE="'+cstrSelectEndCode+'"/>';
      doPostRequest('<%=strBase%>sms_msg_config_select.asp',function(strResponse) {checkSelectList(strResponse);},false,streamXML(strXML));
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
         objCell.innerHTML = '&nbsp;Message&nbsp;';
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
                  cstrSelectStrCode = objElements[i].getAttribute('MSGCDE');
               }
               cstrSelectEndCode = objElements[i].getAttribute('MSGCDE');
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.innerHTML = '<a class="clsSelect" onClick="doSelectUpdate(\''+objElements[i].getAttribute('MSGCDE')+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectCopy(\''+objElements[i].getAttribute('MSGCDE')+'\');">Copy</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('MSGCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('MSGNAM')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('MSGSTS')+'&nbsp;';
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="*UPDMSG" MSGCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>sms_msg_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="*CRTMSG" MSGCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>sms_msg_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="*CPYMSG" MSGCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>sms_msg_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[2].hedtxt = 'Update Message ('+cstrDefineCode+')';
            document.getElementById('addDefine').style.display = 'none';
         } else {
            cobjScreens[2].hedtxt = 'Create Message';
            document.getElementById('addDefine').style.display = 'block';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_MsgCode').value = '';
         document.getElementById('DEF_MsgName').value = '';
         document.getElementById('DEF_DetTxt1').value = '';
         document.getElementById('DEF_TotTxt1').value = '';
         document.getElementById('DEF_DetTxt2').value = '';
         document.getElementById('DEF_TotTxt2').value = '';
         document.getElementById('DEF_DetTxt3').value = '';
         document.getElementById('DEF_TotTxt3').value = '';
         document.getElementById('DEF_DetTxt4').value = '';
         document.getElementById('DEF_TotTxt4').value = '';
         document.getElementById('DEF_DetTxt5').value = '';
         document.getElementById('DEF_TotTxt5').value = '';
         document.getElementById('DEF_DetTxt6').value = '';
         document.getElementById('DEF_TotTxt6').value = '';
         document.getElementById('DEF_DetTxt7').value = '';
         document.getElementById('DEF_TotTxt7').value = '';
         document.getElementById('DEF_DetTxt8').value = '';
         document.getElementById('DEF_TotTxt8').value = '';
         document.getElementById('DEF_DetTxt9').value = '';
         document.getElementById('DEF_TotTxt9').value = '';
         var strMsgStat = '';
         var strQryCode = '';
         var strTotChd1 = '';
         var strTotChd2 = '';
         var strTotChd3 = '';
         var strTotChd4 = '';
         var strTotChd5 = '';
         var strTotChd6 = '';
         var strTotChd7 = '';
         var strTotChd8 = '';
         var strTotChd9 = '';
         var objMsgStat = document.getElementById('DEF_MsgStat');
         var objQryCode = document.getElementById('DEF_QryCode');
         var objTotChd1 = document.getElementById('DEF_TotChd1');
         var objTotChd2 = document.getElementById('DEF_TotChd2');
         var objTotChd3 = document.getElementById('DEF_TotChd3');
         var objTotChd4 = document.getElementById('DEF_TotChd4');
         var objTotChd5 = document.getElementById('DEF_TotChd5');
         var objTotChd6 = document.getElementById('DEF_TotChd6');
         var objTotChd7 = document.getElementById('DEF_TotChd7');
         var objTotChd8 = document.getElementById('DEF_TotChd8');
         var objTotChd9 = document.getElementById('DEF_TotChd9');
         objQryCode.options.length = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'QRY_LIST') {
               objQryCode.options[objQryCode.options.length] = new Option(objElements[i].getAttribute('QRYNAM'),objElements[i].getAttribute('QRYCDE'));
            } else if (objElements[i].nodeName == 'MESSAGE') {
               document.getElementById('DEF_MsgCode').value = objElements[i].getAttribute('MSGCDE');
               document.getElementById('DEF_MsgName').value = objElements[i].getAttribute('MSGNAM');
               strMsgStat = objElements[i].getAttribute('MSGSTS');
               strQryCode = objElements[i].getAttribute('QRYCDE');
            } else if (objElements[i].nodeName == 'MES_LINE') {
               if (objElements[i].getAttribute('MSGLIN') == '*LVL01') {
                  document.getElementById('DEF_DetTxt1').value = objElements[i].getAttribute('DETTXT');
                  document.getElementById('DEF_TotTxt1').value = objElements[i].getAttribute('TOTTXT');
                  strTotChd1 = objElements[i].getAttribute('TOTCHD');
               } else if (objElements[i].getAttribute('MSGLIN') == '*LVL02') {
                  document.getElementById('DEF_DetTxt2').value = objElements[i].getAttribute('DETTXT');
                  document.getElementById('DEF_TotTxt2').value = objElements[i].getAttribute('TOTTXT');
                  strTotChd2 = objElements[i].getAttribute('TOTCHD');
               } else if (objElements[i].getAttribute('MSGLIN') == '*LVL03') {
                  document.getElementById('DEF_DetTxt3').value = objElements[i].getAttribute('DETTXT');
                  document.getElementById('DEF_TotTxt3').value = objElements[i].getAttribute('TOTTXT');
                  strTotChd3 = objElements[i].getAttribute('TOTCHD');
               } else if (objElements[i].getAttribute('MSGLIN') == '*LVL04') {
                  document.getElementById('DEF_DetTxt4').value = objElements[i].getAttribute('DETTXT');
                  document.getElementById('DEF_TotTxt4').value = objElements[i].getAttribute('TOTTXT');
                  strTotChd4 = objElements[i].getAttribute('TOTCHD');
               } else if (objElements[i].getAttribute('MSGLIN') == '*LVL05') {
                  document.getElementById('DEF_DetTxt5').value = objElements[i].getAttribute('DETTXT');
                  document.getElementById('DEF_TotTxt5').value = objElements[i].getAttribute('TOTTXT');
                  strTotChd5 = objElements[i].getAttribute('TOTCHD');
               } else if (objElements[i].getAttribute('MSGLIN') == '*LVL06') {
                  document.getElementById('DEF_DetTxt6').value = objElements[i].getAttribute('DETTXT');
                  document.getElementById('DEF_TotTxt6').value = objElements[i].getAttribute('TOTTXT');
                  strTotChd6 = objElements[i].getAttribute('TOTCHD');
               } else if (objElements[i].getAttribute('MSGLIN') == '*LVL07') {
                  document.getElementById('DEF_DetTxt7').value = objElements[i].getAttribute('DETTXT');
                  document.getElementById('DEF_TotTxt7').value = objElements[i].getAttribute('TOTTXT');
                  strTotChd7 = objElements[i].getAttribute('TOTCHD');
               } else if (objElements[i].getAttribute('MSGLIN') == '*LVL08') {
                  document.getElementById('DEF_DetTxt8').value = objElements[i].getAttribute('DETTXT');
                  document.getElementById('DEF_TotTxt8').value = objElements[i].getAttribute('TOTTXT');
                  strTotChd8 = objElements[i].getAttribute('TOTCHD');
               } else if (objElements[i].getAttribute('MSGLIN') == '*LVL09') {
                  document.getElementById('DEF_DetTxt9').value = objElements[i].getAttribute('DETTXT');
                  document.getElementById('DEF_TotTxt9').value = objElements[i].getAttribute('TOTTXT');
                  strTotChd9 = objElements[i].getAttribute('TOTCHD');
               }
            }
         }
         objMsgStat.selectedIndex = -1;
         for (var i=0;i<objMsgStat.length;i++) {
            if (objMsgStat.options[i].value == strMsgStat) {
               objMsgStat.options[i].selected = true;
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
         objTotChd1.selectedIndex = -1;
         for (var i=0;i<objTotChd1.length;i++) {
            if (objTotChd1.options[i].value == strTotChd1) {
               objTotChd1.options[i].selected = true;
               break;
            }
         }
         if (objTotChd1.selectedIndex == -1) {
            objTotChd1.selectedIndex = 0;
         }
         objTotChd2.selectedIndex = -1;
         for (var i=0;i<objTotChd2.length;i++) {
            if (objTotChd2.options[i].value == strTotChd2) {
               objTotChd2.options[i].selected = true;
               break;
            }
         }
         if (objTotChd2.selectedIndex == -1) {
            objTotChd2.selectedIndex = 0;
         }
         objTotChd3.selectedIndex = -1;
         for (var i=0;i<objTotChd3.length;i++) {
            if (objTotChd3.options[i].value == strTotChd3) {
               objTotChd3.options[i].selected = true;
               break;
            }
         }
         if (objTotChd3.selectedIndex == -1) {
            objTotChd3.selectedIndex = 0;
         }
         objTotChd4.selectedIndex = -1;
         for (var i=0;i<objTotChd4.length;i++) {
            if (objTotChd4.options[i].value == strTotChd4) {
               objTotChd4.options[i].selected = true;
               break;
            }
         }
         if (objTotChd4.selectedIndex == -1) {
            objTotChd4.selectedIndex = 0;
         }
         objTotChd5.selectedIndex = -1;
         for (var i=0;i<objTotChd5.length;i++) {
            if (objTotChd5.options[i].value == strTotChd5) {
               objTotChd5.options[i].selected = true;
               break;
            }
         }
         if (objTotChd5.selectedIndex == -1) {
            objTotChd5.selectedIndex = 0;
         }
         objTotChd6.selectedIndex = -1;
         for (var i=0;i<objTotChd6.length;i++) {
            if (objTotChd6.options[i].value == strTotChd6) {
               objTotChd6.options[i].selected = true;
               break;
            }
         }
         if (objTotChd6.selectedIndex == -1) {
            objTotChd6.selectedIndex = 0;
         }
         objTotChd7.selectedIndex = -1;
         for (var i=0;i<objTotChd7.length;i++) {
            if (objTotChd7.options[i].value == strTotChd7) {
               objTotChd7.options[i].selected = true;
               break;
            }
         }
         if (objTotChd7.selectedIndex == -1) {
            objTotChd7.selectedIndex = 0;
         }
         objTotChd8.selectedIndex = -1;
         for (var i=0;i<objTotChd8.length;i++) {
            if (objTotChd8.options[i].value == strTotChd8) {
               objTotChd8.options[i].selected = true;
               break;
            }
         }
         if (objTotChd8.selectedIndex == -1) {
            objTotChd8.selectedIndex = 0;
         }
         objTotChd9.selectedIndex = -1;
         for (var i=0;i<objTotChd9.length;i++) {
            if (objTotChd9.options[i].value == strTotChd9) {
               objTotChd9.options[i].selected = true;
               break;
            }
         }
         if (objTotChd9.selectedIndex == -1) {
            objTotChd9.selectedIndex = 0;
         }
         if (cstrDefineMode == '*UPD') {
            document.getElementById('DEF_MsgName').focus();
         } else {
            document.getElementById('DEF_MsgCode').focus();
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objMsgStat = document.getElementById('DEF_MsgStat');
      var objQryCode = document.getElementById('DEF_QryCode');
      var objTotChd1 = document.getElementById('DEF_TotChd1');
      var objTotChd2 = document.getElementById('DEF_TotChd2');
      var objTotChd3 = document.getElementById('DEF_TotChd3');
      var objTotChd4 = document.getElementById('DEF_TotChd4');
      var objTotChd5 = document.getElementById('DEF_TotChd5');
      var objTotChd6 = document.getElementById('DEF_TotChd6');
      var objTotChd7 = document.getElementById('DEF_TotChd7');
      var objTotChd8 = document.getElementById('DEF_TotChd8');
      var objTotChd9 = document.getElementById('DEF_TotChd9');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrDefineMode == '*UPD') {
         strXML = strXML+'<SMS_REQUEST ACTION="*UPDMSG"';
         strXML = strXML+' MSGCDE="'+fixXML(cstrDefineCode)+'"';
      } else {
         strXML = strXML+'<SMS_REQUEST ACTION="*CRTMSG"';
         strXML = strXML+' MSGCDE="'+fixXML(document.getElementById('DEF_MsgCode').value)+'"';
      }
      strXML = strXML+' MSGNAM="'+fixXML(document.getElementById('DEF_MsgName').value)+'"';
      if (objMsgStat.selectedIndex == -1) {
         strXML = strXML+' MSGSTS=""';
      } else {
         strXML = strXML+' MSGSTS="'+fixXML(objMsgStat.options[objMsgStat.selectedIndex].value)+'"';
      }
      if (objQryCode.selectedIndex == -1) {
         strXML = strXML+' QRYCDE=""';
      } else {
         strXML = strXML+' QRYCDE="'+fixXML(objQryCode.options[objQryCode.selectedIndex].value)+'"';
      }
      strXML = strXML+'>';
      strXML = strXML+'<MES_LINE MSGLIN="*LVL01" DETTXT="'+fixXML(document.getElementById('DEF_DetTxt1').value)+'" TOTTXT="'+fixXML(document.getElementById('DEF_TotTxt1').value)+'" TOTCHD="'+fixXML(objTotChd1.options[objTotChd1.selectedIndex].value)+'"/>';
      strXML = strXML+'<MES_LINE MSGLIN="*LVL02" DETTXT="'+fixXML(document.getElementById('DEF_DetTxt2').value)+'" TOTTXT="'+fixXML(document.getElementById('DEF_TotTxt2').value)+'" TOTCHD="'+fixXML(objTotChd2.options[objTotChd2.selectedIndex].value)+'"/>';
      strXML = strXML+'<MES_LINE MSGLIN="*LVL03" DETTXT="'+fixXML(document.getElementById('DEF_DetTxt3').value)+'" TOTTXT="'+fixXML(document.getElementById('DEF_TotTxt3').value)+'" TOTCHD="'+fixXML(objTotChd3.options[objTotChd3.selectedIndex].value)+'"/>';
      strXML = strXML+'<MES_LINE MSGLIN="*LVL04" DETTXT="'+fixXML(document.getElementById('DEF_DetTxt4').value)+'" TOTTXT="'+fixXML(document.getElementById('DEF_TotTxt4').value)+'" TOTCHD="'+fixXML(objTotChd4.options[objTotChd4.selectedIndex].value)+'"/>';
      strXML = strXML+'<MES_LINE MSGLIN="*LVL05" DETTXT="'+fixXML(document.getElementById('DEF_DetTxt5').value)+'" TOTTXT="'+fixXML(document.getElementById('DEF_TotTxt5').value)+'" TOTCHD="'+fixXML(objTotChd5.options[objTotChd5.selectedIndex].value)+'"/>';
      strXML = strXML+'<MES_LINE MSGLIN="*LVL06" DETTXT="'+fixXML(document.getElementById('DEF_DetTxt6').value)+'" TOTTXT="'+fixXML(document.getElementById('DEF_TotTxt6').value)+'" TOTCHD="'+fixXML(objTotChd6.options[objTotChd6.selectedIndex].value)+'"/>';
      strXML = strXML+'<MES_LINE MSGLIN="*LVL07" DETTXT="'+fixXML(document.getElementById('DEF_DetTxt7').value)+'" TOTTXT="'+fixXML(document.getElementById('DEF_TotTxt7').value)+'" TOTCHD="'+fixXML(objTotChd7.options[objTotChd7.selectedIndex].value)+'"/>';
      strXML = strXML+'<MES_LINE MSGLIN="*LVL08" DETTXT="'+fixXML(document.getElementById('DEF_DetTxt8').value)+'" TOTTXT="'+fixXML(document.getElementById('DEF_TotTxt8').value)+'" TOTCHD="'+fixXML(objTotChd8.options[objTotChd8.selectedIndex].value)+'"/>';
      strXML = strXML+'<MES_LINE MSGLIN="*LVL09" DETTXT="'+fixXML(document.getElementById('DEF_DetTxt9').value)+'" TOTTXT="'+fixXML(document.getElementById('DEF_TotTxt9').value)+'" TOTCHD="'+fixXML(objTotChd9.options[objTotChd9.selectedIndex].value)+'"/>';
      strXML = strXML+'</SMS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>sms_msg_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('sms_msg_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspSelect" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSelect" class="clsFunction" align=center colspan=2 nowrap><nobr>Message Selection</nobr></td>
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
                  <td align=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="SEL_SelCode" size="64" maxlength="64" value="" onFocus="setSelect(this);"></nobr></td>
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
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Message Define</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Message Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_MsgCode" size="64" maxlength="64" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Message Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_MsgName" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Message Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_MsgStat">
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
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>Message Line Definitions</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension 1 Detail Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DetTxt1" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Total Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TotTxt1" size="80" maxlength="256" value="" onFocus="setSelect(this);">
            <select class="clsInputBN" id="DEF_TotChd1">
               <option value="1">All totals
               <option value="2">Multiple children totals only
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension 2 Detail Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DetTxt2" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Total Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TotTxt2" size="80" maxlength="256" value="" onFocus="setSelect(this);">
            <select class="clsInputBN" id="DEF_TotChd2">
               <option value="1">All totals
               <option value="2">Multiple children totals only
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension 3 Detail Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DetTxt3" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Total Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TotTxt3" size="80" maxlength="256" value="" onFocus="setSelect(this);">
            <select class="clsInputBN" id="DEF_TotChd3">
               <option value="1">All totals
               <option value="2">Multiple children totals only
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension 4 Detail Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DetTxt4" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Total Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TotTxt4" size="80" maxlength="256" value="" onFocus="setSelect(this);">
            <select class="clsInputBN" id="DEF_TotChd4">
               <option value="1">All totals
               <option value="2">Multiple children totals only
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension 5 Detail Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DetTxt5" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Total Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TotTxt5" size="80" maxlength="256" value="" onFocus="setSelect(this);">
            <select class="clsInputBN" id="DEF_TotChd5">
               <option value="1">All totals
               <option value="2">Multiple children totals only
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension 6 Detail Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DetTxt6" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Total Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TotTxt6" size="80" maxlength="256" value="" onFocus="setSelect(this);">
            <select class="clsInputBN" id="DEF_TotChd6">
               <option value="1">All totals
               <option value="2">Multiple children totals only
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension 7 Detail Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DetTxt7" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Total Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TotTxt7" size="80" maxlength="256" value="" onFocus="setSelect(this);">
            <select class="clsInputBN" id="DEF_TotChd7">
               <option value="1">All totals
               <option value="2">Multiple children totals only
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension 8 Detail Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DetTxt8" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Total Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TotTxt8" size="80" maxlength="256" value="" onFocus="setSelect(this);">
            <select class="clsInputBN" id="DEF_TotChd8">
               <option value="1">All totals
               <option value="2">Multiple children totals only
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension 9 Detail Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DetTxt9" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Total Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TotTxt9" size="80" maxlength="256" value="" onFocus="setSelect(this);">
            <select class="clsInputBN" id="DEF_TotChd9">
               <option value="1">All totals
               <option value="2">Multiple children totals only
            </select>
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
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->