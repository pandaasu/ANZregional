<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : QVI (QlikView Interfacing Application)             //
'// Script  : qvi_das_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : April 2012                                         //
'// Text    : This script implements the dashboard definition    //
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
   strTarget = "qvi_das_config.asp"
   strHeading = "Dashboard Maintenance"

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
   strReturn = GetSecurityCheck("QVI_DAS_CONFIG")
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
      cobjScreens[3] = new clsScreen('dspFactSelect','hedFactSelect');
      cobjScreens[4] = new clsScreen('dspFactDefine','hedFactDefine');
      cobjScreens[5] = new clsScreen('dspPartSelect','hedPartSelect');
      cobjScreens[6] = new clsScreen('dspPartDefine','hedPartDefine');
      cobjScreens[7] = new clsScreen('dspTimeSelect','hedTimeSelect');
      cobjScreens[8] = new clsScreen('dspTimeDefine','hedTimeDefine');
      cobjScreens[0].hedtxt = '**LOADING**';
      cobjScreens[1].hedtxt = 'Dashboard Selection';
      cobjScreens[2].hedtxt = 'Dashboard Maintenance';
      cobjScreens[3].hedtxt = 'Dashboard Fact Selection';
      cobjScreens[4].hedtxt = 'Dashboard Fact Maintenance';
      cobjScreens[5].hedtxt = 'Dashboard Fact Part Selection';
      cobjScreens[6].hedtxt = 'Dashboard Fact Part Maintenance';
      cobjScreens[7].hedtxt = 'Dashboard Fact Time Selection';
      cobjScreens[8].hedtxt = 'Dashboard Fact Time Maintenance';
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
   var cstrSelectDasCode;
   function doSelectUpdate(strCode) {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+strCode+'\');',10);
   }
   function doSelectDelete(strCode) {
      if (!processForm()) {return;}
      if (confirm('Please confirm the deletion\r\npress OK continue (the selected dashboard information will be deleted)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDelete(\''+strCode+'\');',10);
   }
   function doSelectCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
   }
   function doSelectFact(strCode) {
      if (!processForm()) {return;}
      cstrSelectDasCode = strCode;
      doActivityStart(document.body);
      window.setTimeout('requestFactSelectList();',10);
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="'+strAction+'" STRCDE="'+cstrSelectStrCode+'" ENDCDE="'+cstrSelectEndCode+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_select.asp',function(strResponse) {checkSelectList(strResponse);},false,streamXML(strXML));
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
         objCell.innerHTML = '&nbsp;Dashboard&nbsp;';
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
                  cstrSelectStrCode = objElements[i].getAttribute('DASCDE');
               }
               cstrSelectEndCode = objElements[i].getAttribute('DASCDE');
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doSelectUpdate(\''+objElements[i].getAttribute('DASCDE')+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectDelete(\''+objElements[i].getAttribute('DASCDE')+'\');">Delete</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectFact(\''+objElements[i].getAttribute('DASCDE')+'\');">Fact Maintenance</a>&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('DASCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('DASNAM')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('DASSTS')+'&nbsp;';
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
   // Delete Functions //
   //////////////////////
   var cstrDeleteCode;
   function requestDelete(strCode) {
      cstrDeleteCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="*DLTDEF" DASCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_delete.asp',function(strResponse) {checkDelete(strResponse);},false,streamXML(strXML));
   }
   function checkDelete(strResponse) {
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

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="*UPDDEF" DASCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="*CRTDEF" DASCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[2].hedtxt = 'Update Dashboard';
            document.getElementById('addDefine').style.display = 'none';
            document.getElementById('updDefine').style.display = 'block';
         } else {
            cobjScreens[2].hedtxt = 'Create Dashboard';
            document.getElementById('addDefine').style.display = 'block';
            document.getElementById('updDefine').style.display = 'none';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_DasCode').value = '';
         document.getElementById('DEF_DasName').value = '';
         var strDasStat = '';
         var objDasStat = document.getElementById('DEF_DasStat');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'DASDFN') {
               if (cstrDefineMode == '*UPD') {
                  document.getElementById('DEF_UpdCode').innerHTML = '<p>'+objElements[i].getAttribute('DASCDE')+'</p>';
               } else {
                  document.getElementById('DEF_DasCode').value = objElements[i].getAttribute('DASCDE');
               }
               document.getElementById('DEF_DasName').value = objElements[i].getAttribute('DASNAM');
               strDasStat = objElements[i].getAttribute('DASSTS');
            }
         }
         objDasStat.selectedIndex = -1;
         for (var i=0;i<objDasStat.length;i++) {
            if (objDasStat.options[i].value == strDasStat) {
               objDasStat.options[i].selected = true;
               break;
            }
         }
         if (cstrDefineMode == '*UPD') {
            document.getElementById('DEF_DasName').focus();
         } else {
            document.getElementById('DEF_DasCode').focus();
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objDasStat = document.getElementById('DEF_DasStat');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrDefineMode == '*UPD') {
         strXML = strXML+'<QVI_REQUEST ACTION="*UPDDEF"';
         strXML = strXML+' DASCDE="'+fixXML(cstrDefineCode)+'"';
      } else {
         strXML = strXML+'<QVI_REQUEST ACTION="*CRTDEF"';
         strXML = strXML+' DASCDE="'+fixXML(document.getElementById('DEF_DasCode').value)+'"';
      }
      strXML = strXML+' DASNAM="'+fixXML(document.getElementById('DEF_DasName').value)+'"';
      if (objDasStat.selectedIndex == -1) {
         strXML = strXML+' DASSTS=""';
      } else {
         strXML = strXML+' DASSTS="'+fixXML(objDasStat.options[objDasStat.selectedIndex].value)+'"';
      }
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>qvi_das_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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

   ///////////////////////////
   // Fact Select Functions //
   ///////////////////////////
   var cstrSelectFacCode;
   function doFactSelectUpdate(strCode) {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestFactDefineUpdate(\''+strCode+'\');',10);
   }
   function doFactSelectDelete(strCode) {
      if (!processForm()) {return;}
      if (confirm('Please confirm the deletion\r\npress OK continue (the selected fact will be deleted)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestFactDelete(\''+strCode+'\');',10);
   }
   function doFactSelectCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestFactDefineCreate(\'*NEW\');',10);
   }
   function doFactSelectPart(strCode) {
      if (!processForm()) {return;}
      cstrSelectFacCode = strCode;
      doActivityStart(document.body);
      window.setTimeout('requestPartSelectList();',10);
   }
   function doFactSelectTime(strCode) {
      if (!processForm()) {return;}
      cstrSelectFacCode = strCode;
      doActivityStart(document.body);
      window.setTimeout('requestTimeSelectList();',10);
   }
   function doFactSelectRefresh() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestFactSelectList();',10);
   }
   function requestFactSelectList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST DASCDE="'+cstrSelectDasCode+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_fact_select.asp',function(strResponse) {checkFactSelectList(strResponse);},false,streamXML(strXML));
   }
   function checkFactSelectList(strResponse) {
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
         displayScreen('dspFactSelect');
         document.getElementById('hedFactSelectData').innerHTML = '<p>Dashboard ('+cstrSelectDasCode+')</p>';
         var objTabHead = document.getElementById('tabFactHeadList');
         var objTabBody = document.getElementById('tabFactBodyList');
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
         objCell.innerHTML = '&nbsp;Fact&nbsp;';
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
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'LSTROW') {
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doFactSelectUpdate(\''+objElements[i].getAttribute('FACCDE')+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doFactSelectDelete(\''+objElements[i].getAttribute('FACCDE')+'\');">Delete</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doFactSelectPart(\''+objElements[i].getAttribute('FACCDE')+'\');">\Fact Part Maintenance</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doFactSelectTime(\''+objElements[i].getAttribute('FACCDE')+'\');">\Fact Time Reprocessing</a>&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('FACCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('FACNAM')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('FACSTS')+'&nbsp;';
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
            setScrollable('FactHeadList','FactBodyList','horizontal');
            objTabHead.rows(0).cells[4].style.width = 16;
            objTabHead.style.tableLayout = 'auto';
            objTabBody.style.tableLayout = 'auto';
         } else {
            setScrollable('FactHeadList','FactBodyList','horizontal');
            objTabHead.rows(0).cells[4].style.width = 16;
            objTabHead.style.tableLayout = 'fixed';
            objTabBody.style.tableLayout = 'fixed';
         }
      }
   }

   ///////////////////////////
   // Fact Delete Functions //
   ///////////////////////////
   var cstrFactDeleteCode;
   function requestFactDelete(strCode) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="*DLTDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'" FACCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_fact_delete.asp',function(strResponse) {checkFactDelete(strResponse);},false,streamXML(strXML));
   }
   function checkFactDelete(strResponse) {
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
         doFactSelectRefresh();
      }
   }

   ///////////////////////////
   // Fact Define Functions //
   ///////////////////////////
   var cstrFactDefineMode;
   var cstrFactDefineCode;
   function requestFactDefineUpdate(strCode) {
      cstrFactDefineMode = '*UPD';
      cstrFactDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="*UPDDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'" FACCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_fact_retrieve.asp',function(strResponse) {checkFactDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestFactDefineCreate(strCode) {
      cstrFactDefineMode = '*CRT';
      cstrFactDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="*CRTDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'" FACCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_fact_retrieve.asp',function(strResponse) {checkFactDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function checkFactDefineLoad(strResponse) {
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
         if (cstrFactDefineMode == '*UPD') {
            cobjScreens[4].hedtxt = 'Update Dashboard Fact';
            document.getElementById('addFactDefine').style.display = 'none';
            document.getElementById('updFactDefine').style.display = 'block';
         } else {
            cobjScreens[4].hedtxt = 'Create Dashboard Fact';
            document.getElementById('addFactDefine').style.display = 'block';
            document.getElementById('updFactDefine').style.display = 'none';
         }
         displayScreen('dspFactDefine');
         document.getElementById('hedFactDefineData').innerHTML = '<p>Dashboard ('+cstrSelectDasCode+')</p>';
         document.getElementById('FAC_FacCode').value = '';
         document.getElementById('FAC_FacName').value = '';
         document.getElementById('FAC_FacBuild').value = '';
         document.getElementById('FAC_JobGroup').value = '';
         document.getElementById('FAC_EmaGroup').value = '';
         document.getElementById('FAC_FacTable').value = '';
         document.getElementById('FAC_FacType').value = '';
         document.getElementById('FAC_FlgIface').value = '';
         document.getElementById('FAC_FlgMname').value = '';
         var strFacStat = '';
         var objFacStat = document.getElementById('FAC_FacStat');
         var strRtvType = '';
         var objRtvType = document.getElementById('FAC_RtvType');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'FACDFN') {
               if (cstrFactDefineMode == '*UPD') {
                  document.getElementById('FAC_UpdCode').innerHTML = '<p>'+objElements[i].getAttribute('FACCDE')+'</p>';
               } else {
                  document.getElementById('FAC_FacCode').value = objElements[i].getAttribute('FACCDE');
               }
               document.getElementById('FAC_FacName').value = objElements[i].getAttribute('FACNAM');
               document.getElementById('FAC_FacBuild').value = objElements[i].getAttribute('FACBLD');
               document.getElementById('FAC_JobGroup').value = objElements[i].getAttribute('JOBGRP');
               document.getElementById('FAC_EmaGroup').value = objElements[i].getAttribute('EMAGRP');
               document.getElementById('FAC_FacTable').value = objElements[i].getAttribute('FACTAB');
               document.getElementById('FAC_FacType').value = objElements[i].getAttribute('FACTYP');
               document.getElementById('FAC_FlgIface').value = objElements[i].getAttribute('FLGINT');
               document.getElementById('FAC_FlgMname').value = objElements[i].getAttribute('FLGMSG');
               strFacStat = objElements[i].getAttribute('FACSTS');
               strRtvType = objElements[i].getAttribute('POLFLG');
            }
         }
         objFacStat.selectedIndex = -1;
         for (var i=0;i<objFacStat.length;i++) {
            if (objFacStat.options[i].value == strFacStat) {
               objFacStat.options[i].selected = true;
               break;
            }
         }
         objRtvType.selectedIndex = -1;
         for (var i=0;i<objRtvType.length;i++) {
            if (objRtvType.options[i].value == strRtvType) {
               objRtvType.options[i].selected = true;
               break;
            }
         }
         if (cstrFactDefineMode == '*UPD') {
            document.getElementById('FAC_FacName').focus();
         } else {
            document.getElementById('FAC_FacCode').focus();
         }
      }
   }
   function doFactDefineAccept() {
      if (!processForm()) {return;}
      var objFacStat = document.getElementById('FAC_FacStat');
      var objRtvType = document.getElementById('FAC_RtvType');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrFactDefineMode == '*UPD') {
         strXML = strXML+'<QVI_REQUEST ACTION="*UPDDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'"';
         strXML = strXML+' FACCDE="'+fixXML(cstrFactDefineCode)+'"';
      } else {
         strXML = strXML+'<QVI_REQUEST ACTION="*CRTDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'"';
         strXML = strXML+' FACCDE="'+fixXML(document.getElementById('FAC_FacCode').value)+'"';
      }
      strXML = strXML+' FACNAM="'+fixXML(document.getElementById('FAC_FacName').value)+'"';
      if (objFacStat.selectedIndex == -1) {
         strXML = strXML+' FACSTS=""';
      } else {
         strXML = strXML+' FACSTS="'+fixXML(objFacStat.options[objFacStat.selectedIndex].value)+'"';
      }
      strXML = strXML+' FACBLD="'+fixXML(document.getElementById('FAC_FacBuild').value)+'"';
      strXML = strXML+' FACTAB="'+fixXML(document.getElementById('FAC_FacTable').value)+'"';
      strXML = strXML+' FACTYP="'+fixXML(document.getElementById('FAC_FacType').value)+'"';
      strXML = strXML+' JOBGRP="'+fixXML(document.getElementById('FAC_JobGroup').value)+'"';
      strXML = strXML+' EMAGRP="'+fixXML(document.getElementById('FAC_EmaGroup').value)+'"';
      if (objRtvType.selectedIndex == -1) {
         strXML = strXML+' POLFLG=""';
      } else {
         strXML = strXML+' POLFLG="'+fixXML(objRtvType.options[objRtvType.selectedIndex].value)+'"';
      }
      strXML = strXML+' FLGINT="'+fixXML(document.getElementById('FAC_FlgIface').value)+'"';
      strXML = strXML+' FLGMSG="'+fixXML(document.getElementById('FAC_FlgMname').value)+'"';

      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestFactDefineAccept(\''+strXML+'\');',10);
   }
   function requestFactDefineAccept(strXML) {
      doPostRequest('<%=strBase%>qvi_das_config_fact_update.asp',function(strResponse) {checkFactDefineAccept(strResponse);},false,streamXML(strXML));
   }
   function checkFactDefineAccept(strResponse) {
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
         doFactSelectRefresh();
      }
   }
   function doFactDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspFactSelect');
   }

   ///////////////////////////
   // Part Select Functions //
   ///////////////////////////
   function doPartSelectUpdate(strCode) {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestPartDefineUpdate(\''+strCode+'\');',10);
   }
   function doPartSelectDelete(strCode) {
      if (!processForm()) {return;}
      if (confirm('Please confirm the deletion\r\npress OK continue (the selected part and all related information will be deleted)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestPartDelete(\''+strCode+'\');',10);
   }
   function doPartSelectCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestPartDefineCreate(\'*NEW\');',10);
   }
   function doPartSelectRefresh() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestPartSelectList();',10);
   }
   function requestPartSelectList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST DASCDE="'+cstrSelectDasCode+'" FACCDE="'+cstrSelectFacCode+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_part_select.asp',function(strResponse) {checkPartSelectList(strResponse);},false,streamXML(strXML));
   }
   function checkPartSelectList(strResponse) {
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
         displayScreen('dspPartSelect');
         document.getElementById('hedPartSelectData').innerHTML = '<p>Dashboard ('+cstrSelectDasCode+') Fact ('+cstrSelectFacCode+')</p>';
         var objTabHead = document.getElementById('tabPartHeadList');
         var objTabBody = document.getElementById('tabPartBodyList');
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
         objCell.innerHTML = '&nbsp;Part&nbsp;';
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
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'LSTROW') {
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doPartSelectUpdate(\''+objElements[i].getAttribute('PARCDE')+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doPartSelectDelete(\''+objElements[i].getAttribute('PARCDE')+'\');">Delete</a>&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PARCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PARNAM')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PARSTS')+'&nbsp;';
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
            setScrollable('PartHeadList','PartBodyList','horizontal');
            objTabHead.rows(0).cells[4].style.width = 16;
            objTabHead.style.tableLayout = 'auto';
            objTabBody.style.tableLayout = 'auto';
         } else {
            setScrollable('PartHeadList','PartBodyList','horizontal');
            objTabHead.rows(0).cells[4].style.width = 16;
            objTabHead.style.tableLayout = 'fixed';
            objTabBody.style.tableLayout = 'fixed';
         }
      }
   }

   ///////////////////////////
   // Part Delete Functions //
   ///////////////////////////
   var cstrPartDeleteCode;
   function requestPartDelete(strCode) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="*DLTDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'" FACCDE="'+fixXML(cstrSelectFacCode)+'" PARCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_part_delete.asp',function(strResponse) {checkPartDelete(strResponse);},false,streamXML(strXML));
   }
   function checkPartDelete(strResponse) {
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
         doPartSelectRefresh();
      }
   }

   ///////////////////////////
   // Part Define Functions //
   ///////////////////////////
   var cstrPartDefineMode;
   var cstrPartDefineCode;
   function requestPartDefineUpdate(strCode) {
      cstrPartDefineMode = '*UPD';
      cstrPartDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="*UPDDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'" FACCDE="'+fixXML(cstrSelectFacCode)+'" PARCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_part_retrieve.asp',function(strResponse) {checkPartDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestPartDefineCreate(strCode) {
      cstrPartDefineMode = '*CRT';
      cstrPartDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="*CRTDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'" FACCDE="'+fixXML(cstrSelectFacCode)+'" PARCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_part_retrieve.asp',function(strResponse) {checkPartDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function checkPartDefineLoad(strResponse) {
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
         if (cstrPartDefineMode == '*UPD') {
            cobjScreens[6].hedtxt = 'Update Dashboard Fact Part';
            document.getElementById('addPartDefine').style.display = 'none';
            document.getElementById('updPartDefine').style.display = 'block';
         } else {
            cobjScreens[6].hedtxt = 'Create Dashboard Fact Part';
            document.getElementById('addPartDefine').style.display = 'block';
            document.getElementById('updPartDefine').style.display = 'none';
         }
         displayScreen('dspPartDefine');
         document.getElementById('hedPartDefineData').innerHTML = '<p>Dashboard ('+cstrSelectDasCode+') Fact ('+cstrSelectFacCode+')</p>';
         document.getElementById('PAR_ParCode').value = '';
         document.getElementById('PAR_ParName').value = '';
         document.getElementById('PAR_SrcTable').value = '';
         document.getElementById('PAR_SrcType').value = '';
         var strParStat = '';
         var objParStat = document.getElementById('PAR_ParStat');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PARDFN') {
               if (cstrPartDefineMode == '*UPD') {
                  document.getElementById('PAR_UpdCode').innerHTML = '<p>'+objElements[i].getAttribute('PARCDE')+'</p>';
               } else {
                  document.getElementById('PAR_ParCode').value = objElements[i].getAttribute('PARCDE');
               }
               document.getElementById('PAR_ParName').value = objElements[i].getAttribute('PARNAM');
               document.getElementById('PAR_SrcTable').value = objElements[i].getAttribute('SRCTAB');
               document.getElementById('PAR_SrcType').value = objElements[i].getAttribute('SRCTYP');
               strParStat = objElements[i].getAttribute('PARSTS');
            }
         }
         objParStat.selectedIndex = -1;
         for (var i=0;i<objParStat.length;i++) {
            if (objParStat.options[i].value == strParStat) {
               objParStat.options[i].selected = true;
               break;
            }
         }
         if (cstrPartDefineMode == '*UPD') {
            document.getElementById('PAR_ParName').focus();
         } else {
            document.getElementById('PAR_ParCode').focus();
         }
      }
   }
   function doPartDefineAccept() {
      if (!processForm()) {return;}
      var objParStat = document.getElementById('PAR_ParStat');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrPartDefineMode == '*UPD') {
         strXML = strXML+'<QVI_REQUEST ACTION="*UPDDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'" FACCDE="'+fixXML(cstrSelectFacCode)+'"';
         strXML = strXML+' PARCDE="'+fixXML(cstrPartDefineCode)+'"';
      } else {
         strXML = strXML+'<QVI_REQUEST ACTION="*CRTDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'" FACCDE="'+fixXML(cstrSelectFacCode)+'"';
         strXML = strXML+' PARCDE="'+fixXML(document.getElementById('PAR_ParCode').value)+'"';
      }
      strXML = strXML+' PARNAM="'+fixXML(document.getElementById('PAR_ParName').value)+'"';
      strXML = strXML+' SRCTAB="'+fixXML(document.getElementById('PAR_SrcTable').value)+'"';
      strXML = strXML+' SRCTYP="'+fixXML(document.getElementById('PAR_SrcType').value)+'"';
      if (objParStat.selectedIndex == -1) {
         strXML = strXML+' PARSTS=""';
      } else {
         strXML = strXML+' PARSTS="'+fixXML(objParStat.options[objParStat.selectedIndex].value)+'"';
      }
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestPartDefineAccept(\''+strXML+'\');',10);
   }
   function requestPartDefineAccept(strXML) {
      doPostRequest('<%=strBase%>qvi_das_config_part_update.asp',function(strResponse) {checkPartDefineAccept(strResponse);},false,streamXML(strXML));
   }
   function checkPartDefineAccept(strResponse) {
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
         doPartSelectRefresh();
      }
   }
   function doPartDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPartSelect');
   }

   ///////////////////////////
   // Time Select Functions //
   ///////////////////////////
   function doTimeSelectUpdate(strCode) {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestTimeDefineUpdate(\''+strCode+'\');',10);
   }
   function doTimeSelectRefresh() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestTimeSelectList();',10);
   }
   function requestTimeSelectList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST DASCDE="'+cstrSelectDasCode+'" FACCDE="'+cstrSelectFacCode+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_time_select.asp',function(strResponse) {checkTimeSelectList(strResponse);},false,streamXML(strXML));
   }
   function checkTimeSelectList(strResponse) {
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
         displayScreen('dspTimeSelect');
         document.getElementById('hedTimeSelectData').innerHTML = '<p>Dashboard ('+cstrSelectDasCode+') Fact ('+cstrSelectFacCode+')</p>';
         var objTabHead = document.getElementById('tabTimeHeadList');
         var objTabBody = document.getElementById('tabTimeBodyList');
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
         objCell.innerHTML = '&nbsp;Time&nbsp;';
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
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'LSTROW') {
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doTimeSelectUpdate(\''+objElements[i].getAttribute('TIMCDE')+'\');">Reprocess</a>&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('TIMCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('TIMSTS')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         if (objTabBody.rows.length == 0) {
            objRow = objTabBody.insertRow(-1);
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 3;
            objCell.innerHTML = '&nbsp;NO DATA FOUND&nbsp;';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
            setScrollable('TimeHeadList','TimeBodyList','horizontal');
            objTabHead.rows(0).cells[3].style.width = 16;
            objTabHead.style.tableLayout = 'auto';
            objTabBody.style.tableLayout = 'auto';
         } else {
            setScrollable('TimeHeadList','TimeBodyList','horizontal');
            objTabHead.rows(0).cells[3].style.width = 16;
            objTabHead.style.tableLayout = 'fixed';
            objTabBody.style.tableLayout = 'fixed';
         }
      }
   }

   ///////////////////////////
   // Time Define Functions //
   ///////////////////////////
   var cstrTimeDefineCode;
   function requestTimeDefineUpdate(strCode) {
      cstrTimeDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><QVI_REQUEST ACTION="*UPDDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'" FACCDE="'+fixXML(cstrSelectFacCode)+'" TIMCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>qvi_das_config_time_retrieve.asp',function(strResponse) {checkTimeDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function checkTimeDefineLoad(strResponse) {
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
         cobjScreens[8].hedtxt = 'Dashboard Fact Time Reprocessing';
         displayScreen('dspTimeDefine');
         document.getElementById('hedTimeDefineData').innerHTML = '<p>Dashboard ('+cstrSelectDasCode+') Fact ('+cstrSelectFacCode+') Time ('+cstrTimeDefineCode+')</p>';

         var objTabHead = document.getElementById('tabTimePartHeadList');
         var objTabBody = document.getElementById('tabTimePartBodyList');
         objTabHead.style.tableLayout = 'auto';
         objTabBody.style.tableLayout = 'auto';
         var objRow;
         var objCell;
         var intCount = 0;
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
         objCell.innerHTML = '&nbsp;Reprocess/Include&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Remove&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Current&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Part Code&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Part Name&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Part Status&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Load Status&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Load Start Time&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Load End Time&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TIMPAR') {
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.innerHTML = '&nbsp;<input type="checkbox" name="TIM_AddParCode'+intCount+'" value="'+objElements[i].getAttribute('PARCDE')+'">&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               if (objElements[i].getAttribute('PARFLG') == '1') {
                  objCell.innerHTML = '&nbsp;<input type="checkbox" name="TIM_RemParCode'+intCount+'" value="'+objElements[i].getAttribute('PARCDE')+'">&nbsp;';
               } else {
                  objCell.innerHTML = '&nbsp;';
               }
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               if (objElements[i].getAttribute('PARFLG') == '1') {
                  objCell.innerHTML = '&nbsp;Yes&nbsp;';
               } else {
                  objCell.innerHTML = '&nbsp;';
               }
               intCount++;
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PARCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PARNAM')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PARSTS')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('LODSTS')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('LODSTR')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('LODEND')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         if (objTabBody.rows.length == 0) {
            objRow = objTabBody.insertRow(-1);
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 9;
            objCell.innerHTML = '&nbsp;NO DATA FOUND&nbsp;';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
            setScrollable('TimePartHeadList','TimePartBodyList','horizontal');
            objTabHead.rows(0).cells[9].style.width = 16;
            objTabHead.style.tableLayout = 'auto';
            objTabBody.style.tableLayout = 'auto';
         } else {
            setScrollable('TimePartHeadList','TimePartBodyList','horizontal');
            objTabHead.rows(0).cells[9].style.width = 16;
            objTabHead.style.tableLayout = 'fixed';
            objTabBody.style.tableLayout = 'fixed';
         }
      }
   }
   function doTimeDefineAccept() {
      if (!processForm()) {return;}
      var objTabBody = document.getElementById('tabTimePartBodyList');
      var objWork = null;
      var strParCode = null;
      var strAddFlag = null;
      var strRemFlag = null;
      var intCount = 0;
      var strMessage = '';
      for (var i=0;i<objTabBody.rows.length;i++) {
         strParCode = '';
         strAddFlag = '0';
         strRemFlag = '0';
         objWork = document.getElementById('TIM_AddParCode'+i);
         strParCode = objWork.value;
         if (objWork.checked) {
            strAddFlag = '1';
         }
         objWork = document.getElementById('TIM_RemParCode'+i);
         if (objWork != null) {
            if (objWork.checked) {
               strRemFlag = '1';
            }
         }
         if (strAddFlag == '1' && strRemFlag == '1') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Part ('+strParCode+') cannot be both reprocessed and removed';
         }
         if (strAddFlag == '1' || strRemFlag == '1') {
            intCount++;
         }
      }
      if (intCount == 0) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'At least one part must be reprocessed/included or removed to accept';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<QVI_REQUEST ACTION="*UPDDEF" DASCDE="'+fixXML(cstrSelectDasCode)+'" FACCDE="'+fixXML(cstrSelectFacCode)+'" TIMCDE="'+fixXML(cstrTimeDefineCode)+'"';
      for (var i=0;i<objTabBody.rows.length;i++) {
         strParCode = '';
         strAddFlag = '0';
         strRemFlag = '0';
         objWork = document.getElementById('TIM_AddParCode'+i);
         strParCode = objWork.value;
         if (objWork.checked) {
            strAddFlag = '1';
         }
         objWork = document.getElementById('TIM_RemParCode'+i);
         if (objWork != null) {
            if (objWork.checked) {
               strRemFlag = '1';
            }
         }
         if (strAddFlag == '1' || strRemFlag == '1') {
            strXML = strXML+'<PARLST ADDFLG="'+strAddFlag+'" REMFLG="'+strRemFla+'" PARCDE="'+fixXML(strParCode)+'"/>';
         }
      }
      doActivityStart(document.body);
      window.setTimeout('requestTimeDefineAccept(\''+strXML+'\');',10);
   }
   function requestTimeDefineAccept(strXML) {
      doPostRequest('<%=strBase%>qvi_das_config_time_update.asp',function(strResponse) {checkTimeDefineAccept(strResponse);},false,streamXML(strXML));
   }
   function checkTimeDefineAccept(strResponse) {
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
         doTimeSelectRefresh();
      }
   }
   function doTimeDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspTimeSelect');
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('qvi_das_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspSelect" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSelect" class="clsFunction" align=center colspan=2 nowrap><nobr>Dashboard Selection</nobr></td>
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
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Dashboard Define</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dashboard Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_DasCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="updDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align="right" valign="center" colspan="1" nowrap><nobr>&nbsp;Dashboard Code:&nbsp;</nobr></td>
         <td id="DEF_UpdCode" class="clsLabelBB" align="left" valign="center" colspan="1" nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dashboard Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DasName" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dashboard Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_DasStat">
               <option value="0">Inactive
               <option value="1">Active
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
   <table id="dspFactSelect" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedFactSelect" class="clsFunction" align=center colspan=2 nowrap><nobr>Dashboard Fact Selection</nobr></td>
      </tr>
      <tr>
         <td id="hedFactSelectData" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Fact</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectRefresh();">&nbsp;Back&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFactSelectRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFactSelectCreate();">&nbsp;Create&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conFactHeadList">
                     <table class="clsTableHead" id="tabFactHeadList" align=left cols=1 cellpadding="0" cellspacing="1">
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conFactBodyList">
                     <table class="clsTableBody" id="tabFactBodyList" align=left cols=1 cellpadding="0" cellspacing="1"></table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspFactDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doFactDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedFactDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Dashboard Fact Define</nobr></td>
      </tr>
      <tr>
         <td id="hedFactDefineData" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Fact</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addFactDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Fact Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="FAC_FacCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="updFactDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align="right" valign="center" colspan="1" nowrap><nobr>&nbsp;Fact Code:&nbsp;</nobr></td>
         <td id="FAC_UpdCode" class="clsLabelBB" align="left" valign="center" colspan="1" nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Fact Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="FAC_FacName" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Fact Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="FAC_FacStat">
               <option value="0">Inactive
               <option value="1">Active
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Fact Build Procedure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="FAC_FacBuild" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Fact Build Job Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase; type="text" name="FAC_JobGroup" size="10" maxlength="10" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Fact Build Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="FAC_EmaGroup" size="64" maxlength="64" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Fact Retrieve Table Function:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="FAC_FacTable" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Fact Storage Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="FAC_FacType" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Fact Retrieval Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="FAC_RtvType">
               <option value="0">Flag
               <option value="1">Batch
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Flag Retrieval Interface:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase; type="text" name="FAC_FlgIface" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Flag Retrieval Message Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="FAC_FlgMname" size="64" maxlength="64" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFactDefineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFactDefineAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspPartSelect" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPartSelect" class="clsFunction" align=center colspan=2 nowrap><nobr>Dashboard Part Selection</nobr></td>
      </tr>
      <tr>
         <td id="hedPartSelectData" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Part</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFactSelectRefresh();">&nbsp;Back&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPartSelectRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPartSelectCreate();">&nbsp;Create&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conPartHeadList">
                     <table class="clsTableHead" id="tabPartHeadList" align=left cols=1 cellpadding="0" cellspacing="1">
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conPartBodyList">
                     <table class="clsTableBody" id="tabPartBodyList" align=left cols=1 cellpadding="0" cellspacing="1"></table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspPartDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPartDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPartDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Dashboard Part Define</nobr></td>
      </tr>
      <tr>
         <td id="hedPartDefineData" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Part</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addPartDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Part Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="PAR_ParCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="updPartDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align="right" valign="center" colspan="1" nowrap><nobr>&nbsp;Part Code:&nbsp;</nobr></td>
         <td id="PAR_UpdCode" class="clsLabelBB" align="left" valign="center" colspan="1" nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Part Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PAR_ParName" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Part Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="PAR_ParStat">
               <option value="0">Inactive
               <option value="1">Active
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Source Retrieve Table Function:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PAR_SrcTable" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Source Storage Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PAR_SrcType" size="80" maxlength="120" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPartDefineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPartDefineAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspTimeSelect" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedTimeSelect" class="clsFunction" align=center colspan=2 nowrap><nobr>Dashboard Time Selection</nobr></td>
      </tr>
      <tr>
         <td id="hedTimeSelectData" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Time</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPartSelectRefresh();">&nbsp;Back&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTimeSelectRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conTimeHeadList">
                     <table class="clsTableHead" id="tabTimeHeadList" align=left cols=1 cellpadding="0" cellspacing="1">
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conTimeBodyList">
                     <table class="clsTableBody" id="tabTimeBodyList" align=left cols=1 cellpadding="0" cellspacing="1"></table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspTimeDefine" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doTimeDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedTimeDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Dashboard Time Define</nobr></td>
      </tr>
      <tr>
         <td id="hedTimeDefineData" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Time</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conTimePartHeadList">
                     <table class="clsTableHead" id="tabTimePartHeadList" align=left cols=1 cellpadding="0" cellspacing="1">
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conTimePartBodyList">
                     <table class="clsTableBody" id="tabTimePartBodyList" align=left cols=1 cellpadding="0" cellspacing="1"></table>
                     </div>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTimeDefineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTimeDefineAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->