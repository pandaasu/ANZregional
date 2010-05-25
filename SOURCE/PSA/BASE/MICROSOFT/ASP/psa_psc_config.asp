<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PSA (Production Scheduling Application)            //
'// Script  : psa_psc_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : December 2009                                      //
'// Text    : This script implements the production schedule     //
'//           maintenance functionality                          //
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
   strTarget = "psa_psc_config.asp"
   strHeading = "Production Schedule Maintenance"

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
   strReturn = GetSecurityCheck("PSA_PSC_CONFIG")
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
      cobjScreens[3] = new clsScreen('dspWeeks','hedWeeks');
      cobjScreens[4] = new clsScreen('dspWeekd','hedWeekd');
      cobjScreens[5] = new clsScreen('dspType','hedType');
      cobjScreens[6] = new clsScreen('dspLine','hedLine');
      cobjScreens[7] = new clsScreen('dspTime','hedTime');
      cobjScreens[8] = new clsScreen('dspCProd','hedCProd');
      cobjScreens[9] = new clsScreen('dspUProd','hedUProd');
      cobjScreens[0].hedtxt = '**LOADING**';
      cobjScreens[1].hedtxt = 'Production Schedule Selection';
      cobjScreens[2].hedtxt = 'Production Schedule Definition';
      cobjScreens[3].hedtxt = 'Week Selection';
      cobjScreens[4].hedtxt = 'Week Definition';
      cobjScreens[5].hedtxt = 'Schedule Maintenance';
      cobjScreens[6].hedtxt = 'Line Maintenance';
      cobjScreens[7].hedtxt = 'Time Activity';
      cobjScreens[8].hedtxt = 'Create Production Activity';
      cobjScreens[9].hedtxt = 'Update Production Activity';
      cobjScreens[0].bodsrl = 'no';
      cobjScreens[1].bodsrl = 'no';
      cobjScreens[2].bodsrl = 'auto';
      cobjScreens[3].bodsrl = 'no';
      cobjScreens[4].bodsrl = 'auto';
      cobjScreens[5].bodsrl = 'no';
      cobjScreens[6].bodsrl = 'auto';
      cobjScreens[7].bodsrl = 'auto';
      cobjScreens[8].bodsrl = 'auto';
      cobjScreens[9].bodsrl = 'auto';
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
      this.bodsrl = '';
   }
   function displayScreen(strScreen) {
      var objScreen;
      var objHeading;
      for (var i=0;i<cobjScreens.length;i++) {
         objScreen = document.getElementById(cobjScreens[i].scrnam);
         objHeading = document.getElementById(cobjScreens[i].hednam);
         if (cobjScreens[i].scrnam == strScreen) {
            document.getElementById('dspBody').scroll = cobjScreens[i].bodsrl;
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
   function doSelectDelete(strCode) {
      if (!processForm()) {return;}
      if (confirm('Please confirm the deletion\r\npress OK continue (the selected production schedule will be deleted)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDelete(\''+strCode+'\');',10);
   }
   function doSelectSap(strCode) {
      if (!processForm()) {return;}
      if (confirm('Please confirm the SAP update\r\npress OK continue (the *MASTER production schedule will be interfaced to SAP)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestSap(\''+strCode+'\');',10);
   }
   function doSelectWeek(strCode) {
      if (!processForm()) {return;}
      cstrWeekProd = strCode;
      doActivityStart(document.body);
      window.setTimeout('requestWeekList();',10);
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="'+strAction+'" SRCCDE="*SCH" STRCDE="'+cstrSelectStrCode+'" ENDCDE="'+cstrSelectEndCode+'"/>';
      doPostRequest('<%=strBase%>psa_psc_config_select.asp',function(strResponse) {checkSelectList(strResponse);},false,streamXML(strXML));
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
         objCell.innerHTML = '&nbsp;Schedule&nbsp;';
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
         objCell.innerHTML = '&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         cstrSelectStrCode = '';
         cstrSelectEndCode = '';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'LSTROW') {
               if (cstrSelectStrCode == '') {
                  cstrSelectStrCode = objElements[i].getAttribute('PSCCDE');
               }
               cstrSelectEndCode = objElements[i].getAttribute('PSCCDE');
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               if (objElements[i].getAttribute('PSCCDE') == '*MASTER') {
                  objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doSelectSap(\''+objElements[i].getAttribute('PSCCDE')+'\');">SAP Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectCopy(\''+objElements[i].getAttribute('PSCCDE')+'\');">Copy</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectWeek(\''+objElements[i].getAttribute('PSCCDE')+'\');">Weeks</a>&nbsp;';
               } else {
                  objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doSelectUpdate(\''+objElements[i].getAttribute('PSCCDE')+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectDelete(\''+objElements[i].getAttribute('PSCCDE')+'\');">Delete</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectCopy(\''+objElements[i].getAttribute('PSCCDE')+'\');">Copy</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectWeek(\''+objElements[i].getAttribute('PSCCDE')+'\');">Weeks</a>&nbsp;';
               }
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PSCCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PSCNAM')+'&nbsp;';
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
            setScrollable('HeadList','BodyList','horizontal');
            objTabHead.rows(0).cells[3].style.width = 16;
            objTabHead.style.tableLayout = 'auto';
            objTabBody.style.tableLayout = 'auto';
         } else {
            setScrollable('HeadList','BodyList','horizontal');
            objTabHead.rows(0).cells[3].style.width = 16;
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*DLTDEF" SRCCDE="*SCH" PSCCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_config_delete.asp',function(strResponse) {checkDelete(strResponse);},false,streamXML(strXML));
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

   ///////////////////
   // Sap Functions //
   ///////////////////
   var cstrSapCode;
   function requestSap(strCode) {
      cstrDeleteCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*SAPDEF" SRCCDE="*SCH" PSCCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_config_sap.asp',function(strResponse) {checkSap(strResponse);},false,streamXML(strXML));
   }
   function checkSap(strResponse) {
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDDEF" SRCCDE="*SCH" PSCCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTDEF" SRCCDE="*SCH" PSCCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CPYDEF" SRCCDE="*SCH" PSCCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[2].hedtxt = 'Update Production Schedule';
            document.getElementById('addDefine').style.display = 'none';
            document.getElementById('updDefine').style.display = 'block';
         } else {
            cobjScreens[2].hedtxt = 'Create Production Schedule';
            document.getElementById('addDefine').style.display = 'block';
            document.getElementById('updDefine').style.display = 'none';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_PscCode').value = '';
         document.getElementById('DEF_PscName').value = '';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PSCDFN') {
               if (cstrDefineMode == '*UPD') {
                  document.getElementById('DEF_UpdCode').innerHTML = '<p>'+objElements[i].getAttribute('PSCCDE')+'</p>';
               } else {
                  document.getElementById('DEF_PscCode').value = objElements[i].getAttribute('PSCCDE');
               }
               document.getElementById('DEF_PscName').value = objElements[i].getAttribute('PSCNAM');
            }
         }
         if (cstrDefineMode == '*UPD') {
            document.getElementById('DEF_PscName').focus();
         } else {
            document.getElementById('DEF_PscCode').focus();
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrDefineMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDDEF" SRCCDE="*SCH"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrDefineCode)+'"';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTDEF"';
         strXML = strXML+' PSCCDE="'+fixXML(document.getElementById('DEF_PscCode').value)+'"';
      }
      strXML = strXML+' PSCNAM="'+fixXML(document.getElementById('DEF_PscName').value)+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>psa_psc_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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

   ////////////////////
   // Week Functions //
   ////////////////////
   var cstrWeekMode;
   var cstrWeekProd;
   var cstrWeekCode;
   var cobjWeekData;
   var cobjWeekSmod;
   var cobjWeekPtyp;
   function clsWeekData() {
      this.wekcde = '';
      this.weknam = '';
      this.reqcde = '*NONE';
      this.dayary = new Array();
   }
   function clsWeekDayd() {
      this.daycde = '';
      this.daynam = '';
   }
   function clsWeekSmod() {
      this.smocde = '';
      this.smonam = '';
      this.shfary = new Array();
   }
   function clsWeekShfd() {
      this.shfcde = '';
      this.shfnam = '';
      this.shfstr = '';
      this.shfdur = '';
   }
   function clsWeekPtyp() {
      this.ptycde = '';
      this.ptynam = '';
      this.ptyusd = '0';
      this.cmoary = new Array();
      this.lcoary = new Array();
   }
   function clsWeekCmod() {
      this.cmocde = '';
      this.cmonam = '';
   }
   function clsWeekLcod() {
      this.lincde = '';
      this.linnam = '';
      this.lcocde = '';
      this.lconam = '';
      this.smocde = '*NONE';
      this.filnam = '';
      this.shfary = new Array();
   }
   function clsWeekPshf() {
      this.smoseq = '';
      this.cmocde = '';
   }
   function requestWeekList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*WEKLST" SRCCDE="*SCH" PSCCDE="'+fixXML(cstrWeekProd)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_week_select.asp',function(strResponse) {checkWeekList(strResponse);},false,streamXML(strXML));
   }
   function checkWeekList(strResponse) {
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
         var objPscType = document.getElementById('WEK_PscType');
         for (var i=objPscType.rows.length-1;i>=0;i--) {
            objPscType.deleteRow(i);
         }
         cobjScreens[3].hedtxt = 'Production Week Selection - '+cstrWeekProd;
         displayScreen('dspWeeks');
         var objTabHead = document.getElementById('tabHeadWeeks');
         var objTabBody = document.getElementById('tabBodyWeeks');
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
         objCell.innerHTML = '&nbsp;Week / Production Type&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Last Updated&nbsp;';
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
               objCell.className = 'clsLabelFN';
               if (objElements[i].getAttribute('SLTTYP') == '*WEEK') {
                  objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doWeekUpdate(\''+objElements[i].getAttribute('SLTCDE')+'\');">Update</a>&nbsp;';
               } else {
                  objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doTypeUpdate(\''+objElements[i].getAttribute('SLTWEK')+'\',\''+objElements[i].getAttribute('SLTCDE')+'\');">Update</a>&nbsp;';
               }
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               if (objElements[i].getAttribute('SLTTYP') == '*WEEK') {
                  objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('SLTTXT')+'&nbsp;';
               } else {
                  objCell.innerHTML = '&nbsp;&nbsp;*&nbsp;'+objElements[i].getAttribute('SLTTXT')+'&nbsp;';
               }
               if (objElements[i].getAttribute('SLTTYP') == '*WEEK') {
                  objCell.className = 'clsLabelFB';
               } else {
                  objCell.className = 'clsLabelFN';
               }
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('SLTUPD')+'&nbsp;';
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
            setScrollable('HeadWeeks','BodyWeeks','horizontal');
            objTabHead.rows(0).cells[3].style.width = 16;
            objTabHead.style.tableLayout = 'auto';
            objTabBody.style.tableLayout = 'auto';
         } else {
            setScrollable('HeadWeeks','BodyWeeks','horizontal');
            objTabHead.rows(0).cells[3].style.width = 16;
            objTabHead.style.tableLayout = 'fixed';
            objTabBody.style.tableLayout = 'fixed';
         }
      }
   }
   function doWeekBack() {
      displayScreen('dspSelect');
      document.getElementById('SEL_SelCode').focus();
   }
   function doWeekCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestWeekCreate(\'*NEW\');',10);
   }
   function doWeekUpdate(strCode) {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestWeekUpdate(\''+strCode+'\');',10);
   }
   function doTypeUpdate(strWeek,strCode) {
      if (!processForm()) {return;}
      cstrTypeProd = cstrWeekProd;
      cstrTypeWeek = strWeek;
      cstrTypeCode = strCode;
      doActivityStart(document.body);
      window.setTimeout('requestTypeLoad();',10);
   }
   function doWeekRefresh() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestWeekList();',10);
   }
   function requestWeekCreate(strCode) {
      cstrWeekMode = '*CRT';
      cstrWeekCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTWEK" SRCCDE="*SCH" PSCCDE="'+fixXML(cstrWeekProd)+'" WEKCDE="'+fixXML(cstrWeekCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_week_retrieve.asp',function(strResponse) {checkWeekLoad(strResponse);},false,streamXML(strXML));
   }
   function requestWeekUpdate(strCode) {
      cstrWeekMode = '*UPD';
      cstrWeekCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDWEK" SRCCDE="*SCH" PSCCDE="'+fixXML(cstrWeekProd)+'" WEKCDE="'+fixXML(cstrWeekCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_week_retrieve.asp',function(strResponse) {checkWeekLoad(strResponse);},false,streamXML(strXML));
   }
   function checkWeekLoad(strResponse) {
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
         if (cstrWeekMode == '*UPD') {
            cobjScreens[4].hedtxt = 'Update Production Week - '+cstrWeekProd;
         } else if (cstrWeekMode == '*CRT') {
            cobjScreens[4].hedtxt = 'Create Production Week - '+cstrWeekProd;
         }
         displayScreen('dspWeekd');
         cobjWeekData = new clsWeekData();
         cobjWeekSmod = new Array();
         cobjWeekPtyp = new Array();
         var objArray;
         var objChild;
         var objPscPreq = document.getElementById('WEK_PscPreq');
         objPscPreq.options.length = 0;
         objPscPreq.options[0] = new Option('** Select Production Requirements **','*NONE');
         objPscPreq.selectedIndex = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'WEKDFN') {
               cstrWeekCode = objElements[i].getAttribute('WEKCDE');
               document.getElementById('hedWeekd').innerText = cobjScreens[4].hedtxt+' - '+objElements[i].getAttribute('WEKNAM');
               cobjWeekData.wekcde = objElements[i].getAttribute('WEKCDE');
               cobjWeekData.weknam = objElements[i].getAttribute('WEKNAM');
               cobjWeekData.reqcde = objElements[i].getAttribute('REQCDE');
            } else if (objElements[i].nodeName == 'DAYDFN') {
               objArray = cobjWeekData.dayary;
               objArray[objArray.length] = new clsWeekDayd();
               objArray[objArray.length-1].daycde = objElements[i].getAttribute('DAYCDE');
               objArray[objArray.length-1].daynam = objElements[i].getAttribute('DAYNAM');
            } else if (objElements[i].nodeName == 'REQDFN') {
               objPscPreq.options[objPscPreq.options.length] = new Option('('+objElements[i].getAttribute('REQCDE')+') '+objElements[i].getAttribute('REQNAM'),objElements[i].getAttribute('REQCDE'));
               objPscPreq.options[objPscPreq.options.length-1].setAttribute('reqwek',objElements[i].getAttribute('REQWEK'));
            } else if (objElements[i].nodeName == 'SMODFN') {
               cobjWeekSmod[cobjWeekSmod.length] = new clsWeekSmod();
               cobjWeekSmod[cobjWeekSmod.length-1].smocde = objElements[i].getAttribute('SMOCDE');
               cobjWeekSmod[cobjWeekSmod.length-1].smonam = objElements[i].getAttribute('SMONAM');
            } else if (objElements[i].nodeName == 'SHFDFN') {
               objArray = cobjWeekSmod[cobjWeekSmod.length-1].shfary;
               objArray[objArray.length] = new clsWeekShfd();
               objArray[objArray.length-1].shfcde = objElements[i].getAttribute('SHFCDE');
               objArray[objArray.length-1].shfnam = objElements[i].getAttribute('SHFNAM');
               objArray[objArray.length-1].shfstr = objElements[i].getAttribute('SHFSTR');
               objArray[objArray.length-1].shfdur = objElements[i].getAttribute('SHFDUR');
            } else if (objElements[i].nodeName == 'PTYDFN') {
               cobjWeekPtyp[cobjWeekPtyp.length] = new clsWeekPtyp();
               cobjWeekPtyp[cobjWeekPtyp.length-1].ptycde = objElements[i].getAttribute('PTYCDE');
               cobjWeekPtyp[cobjWeekPtyp.length-1].ptynam = objElements[i].getAttribute('PTYNAM');
               cobjWeekPtyp[cobjWeekPtyp.length-1].ptyusd = objElements[i].getAttribute('PTYUSD');
            } else if (objElements[i].nodeName == 'CMODFN') {
               objArray = cobjWeekPtyp[cobjWeekPtyp.length-1].cmoary;
               objArray[objArray.length] = new clsWeekCmod();
               objArray[objArray.length-1].cmocde = objElements[i].getAttribute('CMOCDE');
               objArray[objArray.length-1].cmonam = objElements[i].getAttribute('CMONAM');
            } else if (objElements[i].nodeName == 'LCODFN') {
               objArray = cobjWeekPtyp[cobjWeekPtyp.length-1].lcoary;
               objArray[objArray.length] = new clsWeekLcod();
               objArray[objArray.length-1].lincde = objElements[i].getAttribute('LINCDE');
               objArray[objArray.length-1].linnam = objElements[i].getAttribute('LINNAM');
               objArray[objArray.length-1].lcocde = objElements[i].getAttribute('LCOCDE');
               objArray[objArray.length-1].lconam = objElements[i].getAttribute('LCONAM');
               objArray[objArray.length-1].smocde = objElements[i].getAttribute('SMOCDE');
               objArray[objArray.length-1].filnam = objElements[i].getAttribute('FILNAM');
            } else if (objElements[i].nodeName == 'SHFLNK') {
               objChild = objArray[objArray.length-1].shfary;
               objChild[objChild.length] = new clsWeekPshf();
               objChild[objChild.length-1].smoseq = objElements[i].getAttribute('SMOSEQ');
               objChild[objChild.length-1].cmocde = objElements[i].getAttribute('CMOCDE');
            }
         }
         for (var i=0;i<objPscPreq.length;i++) {
            if (objPscPreq.options[i].value == cobjWeekData.reqcde) {
               objPscPreq.options[i].selected = true;
               break;
            }
         }
         document.getElementById('WEK_PscPreq').focus();
         doWeekPaint();
      }
   }
   function doWeekPaint() {
      var objPscType = document.getElementById('WEK_PscType');
      for (var i=objPscType.rows.length-1;i>=0;i--) {
         objPscType.deleteRow(i);
      }
      var objTable;
      var objRow;
      var objCell;
      var objInput;
      for (var i=0;i<cobjWeekPtyp.length;i++) {
         objRow = objPscType.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBB';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objRow = objPscType.insertRow(-1);
         objRow.setAttribute('ptyidx',i);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'left';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBB';
         objCell.style.width = '100%';
         objCell.style.fontSize = '8pt';
         objCell.style.backgroundColor = '#ffffc0';
         objCell.style.color = '#000000';
         objCell.style.border = '#708090 1px solid';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objInput = document.createElement('input');
         objInput.type = 'checkbox';
         objInput.value = '';
         objInput.id = 'WEKPTY_'+i;
         objInput.onfocus = function() {setSelect(this);};
         objInput.onclick = function() {doWeekPtypClick(this);};
         objInput.checked = false;
         objCell.appendChild(objInput);
         objCell.appendChild(document.createTextNode(cobjWeekPtyp[i].ptynam));
         if (cobjWeekPtyp[i].ptyusd == '1') {
            objInput.checked = true;
         }
         objRow = objPscType.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBB';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objTable = document.createElement('table');
         objTable.id = 'WEKPTYDATA_'+i;
         objTable.className = 'clsPanel';
         objTable.align = 'center';
         objTable.cellSpacing = '0';
         objTable.style.display = 'none';
         objCell.appendChild(objTable);
         objRow = objTable.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBB';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         doWeekLconLoad(objCell,i);
         doWeekPtypClick(objInput);
      }
   }
   function doWeekLconLoad(objParent, intPtyIdx) {
      var objTable = document.createElement('table');
      var objWork;
      var objRow;
      var objCell;
      var objSelect;
      var objLcoAry;
      objTable.id = 'WEKPTYLCON_'+intPtyIdx;
      objTable.className = 'clsPanel';
      objTable.align = 'center';
      objTable.cellSpacing = '0';
      objParent.appendChild(objTable);
      objRow = objTable.insertRow(-1);
      objCell = objRow.insertCell(-1);
      objCell.colSpan = 1;
      objCell.align = 'center';
      objCell.vAlign = 'center';
      objCell.className = 'clsLabelBB';
      objCell.style.fontSize = '8pt';
      objCell.style.backgroundColor = '#efefef';
      objCell.style.color = '#000000';
      objCell.style.border = '#708090 1px solid';
      objCell.style.paddingLeft = '2px';
      objCell.style.paddingRight = '2px';
      objCell.style.whiteSpace = 'nowrap';
      objCell.appendChild(document.createTextNode('Line Configurations'));
      objLcoAry = cobjWeekPtyp[intPtyIdx].lcoary;
      for (var i=0;i<objLcoAry.length;i++) {
         objRow = objTable.insertRow(-1);
         objRow.setAttribute('ptyidx',intPtyIdx);
         objRow.setAttribute('lcoidx',i);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'left';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBN';
         objCell.style.fontSize = '8pt';
         objCell.style.fontWeight = 'bold';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objSelect = document.createElement('select');
         objSelect.id = 'WEKPTYLCONDATA_'+intPtyIdx+'_'+i;
         objSelect.className = 'clsInputNN';
         objSelect.style.fontSize = '8pt';
         objSelect.onchange = function() {doWeekSmodChange(this,false);};
         objSelect.selectedIndex = -1;
         objSelect.options[0] = new Option('** NONE **','*NONE');
         objSelect.options[0].selected = true;
         for (var j=0;j<cobjWeekSmod.length;j++) {
            objSelect.options[objSelect.options.length] = new Option('('+cobjWeekSmod[j].smocde+') '+cobjWeekSmod[j].smonam,cobjWeekSmod[j].smocde);
            objSelect.options[objSelect.options.length-1].setAttribute('smoidx',j);
            if (objLcoAry[i].smocde == cobjWeekSmod[j].smocde) {
               objSelect.options[objSelect.options.length-1].selected = true;
            }
         }
         objCell.appendChild(objSelect);
         if (objLcoAry[i].filnam != '' && objLcoAry[i].filnam != null) {
            objCell.appendChild(document.createTextNode(' - ('+objLcoAry[i].lincde+') '+objLcoAry[i].linnam+' - ('+objLcoAry[i].lcocde+') '+objLcoAry[i].lconam+' - '+objLcoAry[i].filnam));
         } else {
            objCell.appendChild(document.createTextNode(' - ('+objLcoAry[i].lincde+') '+objLcoAry[i].linnam+' - ('+objLcoAry[i].lcocde+') '+objLcoAry[i].lconam));
         }
         objRow = objTable.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBB';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objWork = document.createElement('table');
         objWork.id = 'WEKPTYLCONSMOD_'+intPtyIdx+'_'+i;
         objWork.className = 'clsPanel';
         objWork.align = 'center';
         objWork.cellSpacing = '0';
         objWork.style.display = 'none';
         objCell.appendChild(objWork);
         doWeekSmodChange(objSelect,true);
      }
   }
   function doWeekSmodChange(objSelect, bolLoad) {
      var objTable;
      var objRow;
      var objCell;
      var objSelect;
      var objShfAry;
      var objCmoAry;
      var objWrkAry;
      var intBarDay;
      var intBarCnt;
      var intBarStr;
      var intStrTim;
      var intDurMin;
      var strDayNam;
      intPtyIdx = objSelect.parentNode.parentNode.getAttribute('ptyidx');
      intLcoIdx = objSelect.parentNode.parentNode.getAttribute('lcoidx');
      objTable = document.getElementById('WEKPTYLCONSMOD_'+intPtyIdx+'_'+intLcoIdx);
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      if (objSelect.selectedIndex == -1 || objSelect.options[objSelect.selectedIndex].value == '*NONE') {
         objTable.style.display = 'none';
         return;
      } else {
         objTable.style.display = 'block';
      }
      objRow = objTable.insertRow(-1);
      objCell = objRow.insertCell(-1);
      objCell.colSpan = 1;
      objCell.align = 'center';
      objCell.vAlign = 'center';
      objCell.className = 'clsLabelBB';
      objCell.style.fontSize = '8pt';
      objCell.style.backgroundColor = '#efefef';
      objCell.style.color = '#000000';
      objCell.style.border = '#708090 1px solid';
      objCell.style.paddingLeft = '2px';
      objCell.style.paddingRight = '2px';
      objCell.style.whiteSpace = 'nowrap';
      objCell.appendChild(document.createTextNode('Shifts'));
      objCell = objRow.insertCell(-1);
      objCell.colSpan = 1;
      objCell.align = 'center';
      objCell.vAlign = 'center';
      objCell.className = 'clsLabelBB';
      objCell.style.fontSize = '8pt';
      objCell.style.backgroundColor = '#efefef';
      objCell.style.color = '#000000';
      objCell.style.border = '#708090 1px solid';
      objCell.style.paddingLeft = '2px';
      objCell.style.paddingRight = '2px';
      objCell.style.whiteSpace = 'nowrap';
      objCell.appendChild(document.createTextNode('Crew Model'));
      objWrkAry = cobjWeekPtyp[intPtyIdx].lcoary[intLcoIdx].shfary;
      objShfAry = cobjWeekSmod[objSelect.options[objSelect.selectedIndex].getAttribute('smoidx')].shfary;
      for (var i=0;i<objShfAry.length;i++) {
         intStrTim = objShfAry[i].shfstr;
         intDurMin = objShfAry[i].shfdur;
         if (i == 0) {
            intBarStr = ((Math.floor(intStrTim / 100) + ((intStrTim % 100) / 60)) * 4) + 1;
         } else {
            intBarStr = intBarStr + intBarCnt;
         }
         intBarCnt = (intDurMin / 60) * 4;
         intBarDay = Math.floor(intBarStr / 96) + 1;
         strDayNam = 'Sunday';
         if (intBarDay == 1) {
            strDayNam = 'Sunday';
         } else if (intBarDay == 2) {
            strDayNam = 'Monday';
         } else if (intBarDay == 3) {
            strDayNam = 'Tuesday';
         } else if (intBarDay == 4) {
            strDayNam = 'Wednesday';
         } else if (intBarDay == 5) {
            strDayNam = 'Thursday';
         } else if (intBarDay == 6) {
            strDayNam = 'Friday';
         } else if (intBarDay == 7) {
            strDayNam = 'Saturday';
         } else if (intBarDay == 8) {
            strDayNam = 'Sunday';
         }
         objRow = objTable.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'left';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBN';
         objCell.style.fontSize = '8pt';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objCell.appendChild(document.createTextNode(strDayNam+' - '+objShfAry[i].shfnam));
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBN';
         objCell.style.fontSize = '8pt';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objSelect = document.createElement('select');
         objSelect.id = 'WEKPTYLCONCMOD_'+intPtyIdx+'_'+intLcoIdx+'_'+i;
         objSelect.className = 'clsInputNN';
         objSelect.style.fontSize = '8pt';
         objSelect.selectedIndex = -1;
         objSelect.options[0] = new Option('** NONE **','*NONE');
         objSelect.options[0].selected = true;
         objCmoAry = cobjWeekPtyp[intPtyIdx].cmoary;
         for (var j=0;j<objCmoAry.length;j++) {
            objSelect.options[objSelect.options.length] = new Option('('+objCmoAry[j].cmocde+') '+objCmoAry[j].cmonam,objCmoAry[j].cmocde);
            if (bolLoad == true && objWrkAry[i] != null && objCmoAry[j].cmocde == objWrkAry[i].cmocde) {
               objSelect.options[objSelect.options.length-1].selected = true;
            }
         }
         objCell.appendChild(objSelect);
      }
   }
   function doWeekCancel() {
      if (checkChange() == false) {return;}
      cobjWeekData = null;
      cobjWeekSmod = null;
      cobjWeekPtyp = null;
      var objPscType = document.getElementById('WEK_PscType');
      for (var i=objPscType.rows.length-1;i>=0;i--) {
         objPscType.deleteRow(i);
      }
      displayScreen('dspWeeks');
   }
   function doWeekAccept() {
      if (!processForm()) {return;}
      var objShfAry;
      var objLcoAry;
      var objElePtyp;
      var objEleLine;
      var objEleShft;
      var bolPtypFound;
      var bolLineFound;
      var bolShftFound;
      var objPscPreq = document.getElementById('WEK_PscPreq');
      var strMessage = '';
      if (objPscPreq.selectedIndex == -1 || objPscPreq.options[objPscPreq.selectedIndex].value == '*NONE') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Production requirements must be selected';
      }
      bolPtypFound = false;
      for (var i=0;i<cobjWeekPtyp.length;i++) {
         objElePtyp = document.getElementById('WEKPTY_'+i);
         if (objElePtyp.checked == true) {
            bolPtypFound = true;
            bolLineFound = false;
            objLcoAry = cobjWeekPtyp[i].lcoary;
            for (var j=0;j<objLcoAry.length;j++) {
               objEleLine = document.getElementById('WEKPTYLCONDATA_'+i+'_'+j);
               if (objEleLine.selectedIndex != -1 && objEleLine.options[objEleLine.selectedIndex].value != '*NONE') {
                  bolLineFound = true;
                  bolShftFound = false;
                  objShfAry = cobjWeekSmod[objEleLine.options[objEleLine.selectedIndex].getAttribute('smoidx')].shfary;
                  for (var k=0;k<objShfAry.length;k++) {
                     objEleShft = document.getElementById('WEKPTYLCONCMOD_'+i+'_'+j+'_'+k);
                     if (objEleShft.selectedIndex != -1 && objEleShft.options[objEleShft.selectedIndex].value != '*NONE') {
                        bolShftFound = true;
                     }
                  }
                  if (bolShftFound == false) {
                     if (strMessage != '') {strMessage = strMessage + '\r\n';}
                     strMessage = strMessage + 'At least one shift must have a crew model selected for the selected production type ('+cobjWeekPtyp[i].ptynam+') and line ('+objLcoAry[j].linnam+' / '+objLcoAry[j].lconam+')';
                  }
               }
            }
            if (bolLineFound == false) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'At least one line configuration must be selected for the selected production type ('+cobjWeekPtyp[i].ptynam+')';
            }
         }
      }
      if (bolPtypFound == false) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'At least one production type (Filling, Packing or Forming must be selected) for for the week';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrWeekMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDWEK" SRCCDE="*SCH"';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTWEK" SRCCDE="*SCH"';
      }
      strXML = strXML+' PSCCDE="'+fixXML(cstrWeekProd)+'"';
      strXML = strXML+' WEKCDE="'+fixXML(cobjWeekData.wekcde)+'"';
      strXML = strXML+' REQCDE="'+fixXML(objPscPreq.options[objPscPreq.selectedIndex].value)+'">';
      for (var i=0;i<cobjWeekPtyp.length;i++) {
         objElePtyp = document.getElementById('WEKPTY_'+i);
         if (objElePtyp.checked == true) {
            strXML = strXML+'<PSCPTY PTYCDE="'+fixXML(cobjWeekPtyp[i].ptycde)+'">';
            objLcoAry = cobjWeekPtyp[i].lcoary;
            for (var j=0;j<objLcoAry.length;j++) {
               objEleLine = document.getElementById('WEKPTYLCONDATA_'+i+'_'+j);
               if (objEleLine.selectedIndex != -1 && objEleLine.options[objEleLine.selectedIndex].value != '*NONE') {
                  strXML = strXML+'<PSCLCO LINCDE="'+fixXML(objLcoAry[j].lincde)+'" LCOCDE="'+fixXML(objLcoAry[j].lcocde)+'" SMOCDE="'+fixXML(objEleLine.options[objEleLine.selectedIndex].value)+'">';
                  objShfAry = cobjWeekSmod[objEleLine.options[objEleLine.selectedIndex].getAttribute('smoidx')].shfary;
                  for (var k=0;k<objShfAry.length;k++) {
                     objEleShft = document.getElementById('WEKPTYLCONCMOD_'+i+'_'+j+'_'+k);
                     if (objEleShft.selectedIndex == -1) {
                        strXML = strXML+'<PSCSHF SHFCDE="'+fixXML(objShfAry[k].shfcde)+'" SHFSTR="'+fixXML(objShfAry[k].shfstr)+'" SHFDUR="'+fixXML(objShfAry[k].shfdur)+'" CMOCDE="'+fixXML('*NONE')+'"/>';
                     } else {
                        strXML = strXML+'<PSCSHF SHFCDE="'+fixXML(objShfAry[k].shfcde)+'" SHFSTR="'+fixXML(objShfAry[k].shfstr)+'" SHFDUR="'+fixXML(objShfAry[k].shfdur)+'" CMOCDE="'+fixXML(objEleShft.options[objEleShft.selectedIndex].value)+'"/>';
                     }
                  }
                  strXML = strXML+'</PSCLCO>';
               }
            }
            strXML = strXML+'</PSCPTY>';
         }
      }
      strXML = strXML+'</PSA_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestWeekAccept(\''+strXML+'\');',10);
   }
   function requestWeekAccept(strXML) {
      doPostRequest('<%=strBase%>psa_psc_week_update.asp',function(strResponse) {checkWeekAccept(strResponse);},false,streamXML(strXML));
   }
   function checkWeekAccept(strResponse) {
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
         cobjWeekData = null;
         cobjWeekSmod = null;
         cobjWeekPtyp = null;
         doWeekRefresh();
      }
   }
   function doWeekPtypClick(objCheck) {
      var intPtyIdx = objCheck.parentNode.parentNode.getAttribute('ptyidx');
      if (objCheck.checked == false) {
         document.getElementById('WEKPTYDATA_'+intPtyIdx).style.display = 'none';
      } else {
         document.getElementById('WEKPTYDATA_'+intPtyIdx).style.display = 'block';
      }
   }

   ////////////////////
   // Type Functions //
   ////////////////////
   var cbolTypePulse;
   var cstrTypePulse;
   var cintTypePulse;
   var cobjTico = new Image();
   var cobjPico = new Image();
   cobjTico.src = 'timIcon.png';
   cobjPico.src = 'prdIcon.png';
   var cstrTypeProd;
   var cstrTypeWeek;
   var cstrTypeCode;
   var cintTypeIndx;
   var cstrTypeType;
   var cstrTypeSind;
   var cstrTypeTind;
   var cintTypeLidx;
   var cintTypeWidx;
   var cintTypeAidx;
   var cstrTypeAcde;
   var cstrTypeAtxt;
   var cstrTypeAtyp;
   var cstrTypeAval;
   var cstrTypeLcde;
   var cstrTypeCcde;
   var cstrTypeWcde;
   var cstrTypeWseq;
   var cintTypeRidx;
   var cstrTypeRcde;
   var cstrTypeRtxt;
   var cstrTypeRtyp;
   var cstrTypeRval;
   var cstrTypeHead;
   var cobjTypeLineCell;
   var cobjTypeSchdCell;
   var cobjTypeUactCell;
   var cintTypeHsiz = new Array();
   var cintTypeBsiz = new Array();
   var cobjTypeDate = new Array();
   var cobjTypeStck = new Array();
   var cobjTypeLine = new Array();
   var cobjTypeUact = new Array();
   function clsTypeDate() {
      this.daycde = '';
      this.daynam = '';
   }
   function clsTypeStck() {
      this.stknam = '';
      this.stkbar = '0';
   }
   function clsTypeLine() {
      this.lincde = '';
      this.linnam = '';
      this.lcocde = '';
      this.lconam = '';
      this.filnam = '';
      this.ovrflw = '';
      this.pntcol = 0;
      this.shfary = new Array();
      this.actary = new Array();
   }
   function clsTypeShft() {
      this.shfcde = '';
      this.shfnam = '';
      this.shfdte = '';
      this.shfstr = '';
      this.shfdur = '';
      this.cmocde = '';
      this.wincde = '';
      this.wintyp = '';
      this.barstr = 0;
      this.barend = 0;
   }
   function clsTypeActv() {
      this.actcde = '';
      this.acttyp = '';
      this.schchg = '';
      this.chgflg = '';
      this.wincde = '';
      this.winseq = '';
      this.winflw = '';
      this.wekflw = '';
      this.strtim = '';
      this.chgtim = '';
      this.endtim = '';
      this.strbar = 0;
      this.chgbar = 0;
      this.endbar = 0;
      this.schdmi = '';
      this.actdmi = '';
      this.schcmi = '';
      this.actcmi = '';
      this.actent = '';
      this.matcde = '';
      this.matnam = '';
      this.schplt = 0;
      this.schcas = 0;
      this.schpch = 0;
      this.schmix = 0;
      this.schton = 0;
      this.actplt = 0;
      this.actcas = 0;
      this.actpch = 0;
      this.actmix = 0;
      this.actton = 0;
      this.invary = new Array();
   }
   function clsTypeInvt() {
      this.matcde = '';
      this.matnam = '';
      this.invqty = '0';
      this.invavl = '0';
   }
   function clsTypeUact() {
      this.actcde = '';
      this.matcde = '';
      this.matnam = '';
      this.actent = '';
      this.lincde = '';
      this.concde = '';
      this.dftflg = '';
      this.sapqty = 0;
      this.reqplt = 0;
      this.reqcas = 0;
      this.reqpch = 0;
      this.reqmix = 0;
      this.reqton = 0;
      this.schplt = 0;
      this.schcas = 0;
      this.schpch = 0;
      this.schmix = 0;
      this.schton = 0;
      this.schdur = 0;
   }
   function requestTypeLoad() {
      cobjTypeLineCell = null;
      cobjTypeSchdCell = null;
      cobjTypeUactCell = null;
      cbolTypePulse = false;
      cstrTypeTind = '0';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*GETTYP" SRCCDE="*SCH" PSCCDE="'+fixXML(cstrTypeProd)+'" WEKCDE="'+fixXML(cstrTypeWeek)+'" PTYCDE="'+fixXML(cstrTypeCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_type_retrieve.asp',function(strResponse) {checkTypeLoad(strResponse);},false,streamXML(strXML));
   }
   function requestTypeReload() {
      cobjTypeLineCell = null;
      cobjTypeSchdCell = null;
      cobjTypeUactCell = null;
      cbolTypePulse = false;
      window.clearTimeout(cintTypePulse);
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*GETTYP" SRCCDE="*SCH" PSCCDE="'+fixXML(cstrTypeProd)+'" WEKCDE="'+fixXML(cstrTypeWeek)+'" PTYCDE="'+fixXML(cstrTypeCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_type_retrieve.asp',function(strResponse) {checkTypeLoad(strResponse);},false,streamXML(strXML));
   }
   function checkTypeLoad(strResponse) {
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
         displayScreen('dspType');
         cobjTypeLineCell = null;
         cobjTypeSchdCell = null;
         cobjTypeUactCell = null;
         cobjTypeDate.length = 0;
         cobjTypeStck.length = 0;
         cobjTypeLine.length = 0;
         cobjTypeUact.length = 0;
         var objShfAry;
         var objActAry;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PTYDFN') {
               cstrTypePulse = objElements[i].getAttribute('PULVAL');
               cstrTypeHead = 'Schedule Maintenance - '+cstrTypeProd+' - '+objElements[i].getAttribute('WEKNAM')+' - '+objElements[i].getAttribute('PTYNAM');
               document.getElementById('hedType').innerText = cstrTypeHead;
            } else if (objElements[i].nodeName == 'DAYDFN') {
               cobjTypeDate[cobjTypeDate.length] = new clsTypeDate();
               cobjTypeDate[cobjTypeDate.length-1].daycde = objElements[i].getAttribute('DAYCDE');
               cobjTypeDate[cobjTypeDate.length-1].daynam = objElements[i].getAttribute('DAYNAM');
            } else if (objElements[i].nodeName == 'STKDFN') {
               cobjTypeStck[cobjTypeStck.length] = new clsTypeStck();
               cobjTypeStck[cobjTypeStck.length-1].stknam = objElements[i].getAttribute('STKNAM');
               cobjTypeStck[cobjTypeStck.length-1].stkbar = objElements[i].getAttribute('STKBAR');
            } else if (objElements[i].nodeName == 'LINDFN') {
               cobjTypeLine[cobjTypeLine.length] = new clsTypeLine();
               cobjTypeLine[cobjTypeLine.length-1].lincde = objElements[i].getAttribute('LINCDE');
               cobjTypeLine[cobjTypeLine.length-1].linnam = objElements[i].getAttribute('LINNAM');
               cobjTypeLine[cobjTypeLine.length-1].lcocde = objElements[i].getAttribute('LCOCDE');
               cobjTypeLine[cobjTypeLine.length-1].lconam = objElements[i].getAttribute('LCONAM');
               cobjTypeLine[cobjTypeLine.length-1].filnam = objElements[i].getAttribute('FILNAM');
               cobjTypeLine[cobjTypeLine.length-1].ovrflw = objElements[i].getAttribute('OVRFLW');
            } else if (objElements[i].nodeName == 'SHFDFN') {
               objShfAry = cobjTypeLine[cobjTypeLine.length-1].shfary;
               objShfAry[objShfAry.length] = new clsTypeShft();
               objShfAry[objShfAry.length-1].smoseq = objElements[i].getAttribute('SMOSEQ');
               objShfAry[objShfAry.length-1].shfcde = objElements[i].getAttribute('SHFCDE');
               objShfAry[objShfAry.length-1].shfnam = objElements[i].getAttribute('SHFNAM');
               objShfAry[objShfAry.length-1].shfdte = objElements[i].getAttribute('SHFDTE');
               objShfAry[objShfAry.length-1].shfstr = objElements[i].getAttribute('SHFSTR');
               objShfAry[objShfAry.length-1].shfdur = objElements[i].getAttribute('SHFDUR');
               objShfAry[objShfAry.length-1].cmocde = objElements[i].getAttribute('CMOCDE');
               objShfAry[objShfAry.length-1].wincde = objElements[i].getAttribute('WINCDE');
               objShfAry[objShfAry.length-1].wintyp = objElements[i].getAttribute('WINTYP');
               objShfAry[objShfAry.length-1].barstr = objElements[i].getAttribute('STRBAR');
               objShfAry[objShfAry.length-1].barend = objElements[i].getAttribute('ENDBAR');
            } else if (objElements[i].nodeName == 'LINACT') {
               objActAry = cobjTypeLine[cobjTypeLine.length-1].actary;
               objActAry[objActAry.length] = new clsTypeActv();
               objActAry[objActAry.length-1].actcde = objElements[i].getAttribute('ACTCDE');
               objActAry[objActAry.length-1].acttyp = objElements[i].getAttribute('ACTTYP');
               objActAry[objActAry.length-1].schchg = objElements[i].getAttribute('SCHCHG');
               objActAry[objActAry.length-1].chgflg = objElements[i].getAttribute('CHGFLG');
               objActAry[objActAry.length-1].wincde = objElements[i].getAttribute('WINCDE');
               objActAry[objActAry.length-1].winseq = objElements[i].getAttribute('WINSEQ');
               objActAry[objActAry.length-1].winflw = objElements[i].getAttribute('WINFLW');
               objActAry[objActAry.length-1].wekflw = objElements[i].getAttribute('WEKFLW');
               objActAry[objActAry.length-1].strtim = objElements[i].getAttribute('STRTIM');
               objActAry[objActAry.length-1].chgtim = objElements[i].getAttribute('CHGTIM');
               objActAry[objActAry.length-1].endtim = objElements[i].getAttribute('ENDTIM');
               objActAry[objActAry.length-1].strbar = objElements[i].getAttribute('STRBAR');
               objActAry[objActAry.length-1].chgbar = objElements[i].getAttribute('CHGBAR');
               objActAry[objActAry.length-1].endbar = objElements[i].getAttribute('ENDBAR');
               objActAry[objActAry.length-1].schdmi = objElements[i].getAttribute('SCHDMI');
               objActAry[objActAry.length-1].actdmi = objElements[i].getAttribute('ACTDMI');
               objActAry[objActAry.length-1].schcmi = objElements[i].getAttribute('SCHCMI');
               objActAry[objActAry.length-1].actcmi = objElements[i].getAttribute('ACTCMI');
               objActAry[objActAry.length-1].actent = objElements[i].getAttribute('ACTENT');
               objActAry[objActAry.length-1].matcde = objElements[i].getAttribute('MATCDE');
               objActAry[objActAry.length-1].matnam = objElements[i].getAttribute('MATNAM');
               objActAry[objActAry.length-1].schplt = objElements[i].getAttribute('SCHPLT');
               objActAry[objActAry.length-1].schcas = objElements[i].getAttribute('SCHCAS');
               objActAry[objActAry.length-1].schpch = objElements[i].getAttribute('SCHPCH');
               objActAry[objActAry.length-1].schmix = objElements[i].getAttribute('SCHMIX');
               objActAry[objActAry.length-1].schton = objElements[i].getAttribute('SCHTON');
               objActAry[objActAry.length-1].actplt = objElements[i].getAttribute('ACTPLT');
               objActAry[objActAry.length-1].actcas = objElements[i].getAttribute('ACTCAS');
               objActAry[objActAry.length-1].actpch = objElements[i].getAttribute('ACTPCH');
               objActAry[objActAry.length-1].actmix = objElements[i].getAttribute('ACTMIX');
               objActAry[objActAry.length-1].actton = objElements[i].getAttribute('ACTTON');
            } else if (objElements[i].nodeName == 'LININV') {
               objInvAry = objActAry[objActAry.length-1].invary;
               objInvAry[objInvAry.length] = new clsTypeInvt();
               objInvAry[objInvAry.length-1].matcde = objElements[i].getAttribute('MATCDE');
               objInvAry[objInvAry.length-1].matnam = objElements[i].getAttribute('MATNAM');
               objInvAry[objInvAry.length-1].invqty = objElements[i].getAttribute('INVQTY');
               objInvAry[objInvAry.length-1].invavl = objElements[i].getAttribute('INVAVL');
            } else if (objElements[i].nodeName == 'UNSACT') {
               cobjTypeUact[cobjTypeUact.length] = new clsTypeUact();
               cobjTypeUact[cobjTypeUact.length-1].actcde = objElements[i].getAttribute('ACTCDE');
               cobjTypeUact[cobjTypeUact.length-1].acttyp = objElements[i].getAttribute('ACTTYP');
               cobjTypeUact[cobjTypeUact.length-1].matcde = objElements[i].getAttribute('MATCDE');
               cobjTypeUact[cobjTypeUact.length-1].matnam = objElements[i].getAttribute('MATNAM');
               cobjTypeUact[cobjTypeUact.length-1].actent = objElements[i].getAttribute('ACTENT');
               cobjTypeUact[cobjTypeUact.length-1].lincde = objElements[i].getAttribute('LINCDE');
               cobjTypeUact[cobjTypeUact.length-1].concde = objElements[i].getAttribute('CONCDE');
               cobjTypeUact[cobjTypeUact.length-1].dftflg = objElements[i].getAttribute('DFTFLG');
               cobjTypeUact[cobjTypeUact.length-1].sapqty = objElements[i].getAttribute('SAPQTY');
               cobjTypeUact[cobjTypeUact.length-1].reqplt = objElements[i].getAttribute('REQPLT');
               cobjTypeUact[cobjTypeUact.length-1].reqcas = objElements[i].getAttribute('REQCAS');
               cobjTypeUact[cobjTypeUact.length-1].reqpch = objElements[i].getAttribute('REQPCH');
               cobjTypeUact[cobjTypeUact.length-1].reqmix = objElements[i].getAttribute('REQMIX');
               cobjTypeUact[cobjTypeUact.length-1].reqton = objElements[i].getAttribute('REQTON');
               cobjTypeUact[cobjTypeUact.length-1].schplt = objElements[i].getAttribute('SCHPLT');
               cobjTypeUact[cobjTypeUact.length-1].schcas = objElements[i].getAttribute('SCHCAS');
               cobjTypeUact[cobjTypeUact.length-1].schpch = objElements[i].getAttribute('SCHPCH');
               cobjTypeUact[cobjTypeUact.length-1].schmix = objElements[i].getAttribute('SCHMIX');
               cobjTypeUact[cobjTypeUact.length-1].schton = objElements[i].getAttribute('SCHTON');
               cobjTypeUact[cobjTypeUact.length-1].schdur = objElements[i].getAttribute('SCHDUR');
            }
         }
         doTypeSchdPaint();
         doTypeSchdPaintActv();
         document.getElementById('datTypeUact').style.display = 'block';
         doTypeUactPaint();
         document.getElementById('datTypeUact').style.display = 'none';
         if (cstrTypeTind == '1') {
            document.getElementById('datTypeSchd').style.width = '75%';
            document.getElementById('datTypeUact').style.display = 'block';
         } else {
            document.getElementById('datTypeSchd').style.width = '100%';
            document.getElementById('datTypeUact').style.display = 'none';
         }
         document.getElementById('typPulse').style.backgroundColor = '#b0e0e6';
      }
      if (cbolTypePulse == false) {
         cbolTypePulse = true;
         cintTypePulse = window.setTimeout('doTypePulseRequest();',30*1000);
      }
   }
   function doTypePulseRequest() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*GETPUL" PSCCDE="'+fixXML(cstrTypeProd)+'" WEKCDE="'+fixXML(cstrTypeWeek)+'" PTYCDE="'+fixXML(cstrTypeCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_pulse_retrieve.asp',function(strResponse) {checkPulseLoad(strResponse);},true,streamXML(strXML));
   }
   function checkPulseLoad(strResponse) {
      if (cbolTypePulse == false) {
         return;
      }
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
         } else {
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'PTYPUL') {
                  if (cstrTypePulse != objElements[i].getAttribute('PULVAL')) {
                     document.getElementById('typPulse').style.backgroundColor = '#e8baba';
                  } else {
                     document.getElementById('typPulse').style.backgroundColor = '#b0e0e6';
                  }
               }
            }
         }
      }
      if (cbolTypePulse == true) {
         cintTypePulse = window.setTimeout('doTypePulseRequest();',30*1000);
      }
   }
   function doTypeBack() {
      cbolTypePulse = false;
      window.clearTimeout(cintTypePulse);
      cobjTypeDate.length = 0;
      cobjTypeStck.length = 0;
      cobjTypeLine.length = 0;
      cobjTypeUact.length = 0;
      var objSchHead = document.getElementById('tabHeadSchd');
      var objSchBody = document.getElementById('tabBodySchd');
      for (var i=objSchHead.rows.length-1;i>=0;i--) {
         objSchHead.deleteRow(i);
      }
      for (var i=objSchBody.rows.length-1;i>=0;i--) {
         objSchBody.deleteRow(i);
      }
      var objUacBody = document.getElementById('tabBodyUact');
      for (var i=objUacBody.rows.length-1;i>=0;i--) {
         objUacBody.deleteRow(i);
      }
      displayScreen('dspWeeks');
   }

   function doTypeSchdReport() {
      if (!processForm()) {return;}
      if (confirm('Please confirm the schedule report\r\npress OK continue (the schedule report will be generated)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      doReportOutput(eval('document.body'),'Production Schedule Report','*SPREADSHEET','select * from table(psa_app.psa_rpt_function.report_schedule(\''+cstrTypeProd+'\',\''+cstrTypeWeek+'\',\''+cstrTypeCode+'\'))');
   }

   function doTypeStckUpdate() {
      if (!processForm()) {return;}
      if (confirm('Please confirm the stock update\r\npress OK continue (the stock inventory will be updated for this week forward)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestStckUpdate();',10);
   }
   function doTypeLineSelect(objSelect) {
      if (cobjTypeSchdCell != null) {
         if (cobjTypeSchdCell.getAttribute('acttyp') == '+') {
            cobjTypeSchdCell.style.backgroundColor = '#ffd9ff';
         } else if (cobjTypeSchdCell.getAttribute('acttyp') == 'T') {
            cobjTypeSchdCell.style.backgroundColor = '#dddfff';
         } else {
            cobjTypeSchdCell.style.backgroundColor = '#ffffe0';
         }
         cobjTypeSchdCell = null;
      }
      if (cobjTypeUactCell != null) {
         if (cobjTypeUactCell.getAttribute('acttyp') == 'T') {
            cobjTypeUactCell.style.backgroundColor = '#dddfff';
         } else {
            cobjTypeUactCell.style.backgroundColor = '#ffffe0';
         }
         cobjTypeUactCell = null;
      }
      if (cobjTypeLineCell != null) {
         cobjTypeLineCell.style.backgroundColor = '#40414c';
      }
      cobjTypeLineCell = objSelect;
      cobjTypeLineCell.style.backgroundColor = '#C000C0';
   }
   function doTypeLineAdd() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestLineCreate();',10);
   }
   function doTypeLineUpdate() {
      if (cobjTypeLineCell == null) {
         alert('Line must be selected for update');
         return;
      }
      if (!processForm()) {return;}
      cstrTypeLcde = cobjTypeLineCell.getAttribute('lincde');
      cstrTypeCcde = cobjTypeLineCell.getAttribute('concde');
      doActivityStart(document.body);
      window.setTimeout('requestLineUpdate();',10);
   }
   function doTypeLineDelete() {
      if (cobjTypeLineCell == null) {
         alert('Line must be selected for deletion');
         return;
      }
      if (!processForm()) {return;}
      if (confirm('Please confirm the deletion\r\npress OK continue (the selected line and all attached activities will be deleted)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      cstrTypeLcde = cobjTypeLineCell.getAttribute('lincde');
      cstrTypeCcde = cobjTypeLineCell.getAttribute('concde');
      doActivityStart(document.body);
      window.setTimeout('requestLineDelete();',10);
   }
   function doTypeSchdSelect(objSelect) {
      if (cobjTypeLineCell != null) {
         cobjTypeLineCell.style.backgroundColor = '#40414c';
         cobjTypeLineCell = null;
      }
      if (cobjTypeSchdCell != null) {
         if (cobjTypeSchdCell.getAttribute('acttyp') == '+') {
            cobjTypeSchdCell.style.backgroundColor = '#ffd9ff';
         } else if (cobjTypeSchdCell.getAttribute('acttyp') == 'T') {
            cobjTypeSchdCell.style.backgroundColor = '#dddfff';
         } else {
            cobjTypeSchdCell.style.backgroundColor = '#ffffe0';
         }
      }
      cobjTypeSchdCell = objSelect;
      if (cobjTypeSchdCell.getAttribute('acttyp') == '+') {
         cobjTypeSchdCell.style.backgroundColor = '#fe9fff';
      } else if (cobjTypeSchdCell.getAttribute('acttyp') == 'T') {
         cobjTypeSchdCell.style.backgroundColor = '#c0c0ff';
      } else {
         cobjTypeSchdCell.style.backgroundColor = '#ffff80';
      }
   }
   function doTypeSchdPaint() {
      var objShfAry;
      var objTable;
      var objRow;
      var objCell;
      var strTime;
      var intWrkCnt;
      var bolStrDay;

      cintTypeHsiz.length = 0;
      cintTypeBsiz.length = 0;
      var objTypHead = document.getElementById('tabHeadSchd');
      var objTypBody = document.getElementById('tabBodySchd');
      objTypHead.style.tableLayout = 'auto';
      objTypBody.style.tableLayout = 'auto';
      for (var i=objTypHead.rows.length-1;i>=0;i--) {
         objTypHead.deleteRow(i);
      }
      for (var i=objTypBody.rows.length-1;i>=0;i--) {
         objTypBody.deleteRow(i);
      }

      objRow = objTypHead.insertRow(-1);

      objCell = objRow.insertCell(-1);
      objCell.colSpan = 1;
      objCell.align = 'center';
      objCell.vAlign = 'center';
      objCell.className = 'clsLabelBB';
      objCell.style.fontSize = '8pt';
      objCell.style.fontWeight = 'bold';
      objCell.style.backgroundColor = '#40414c';
      objCell.style.color = '#ffffff';
      objCell.style.border = '#c0c0c0 1px solid';
      objCell.style.paddingLeft = '2px';
      objCell.style.paddingRight = '2px';
      objCell.style.whiteSpace = 'nowrap';
      objCell.appendChild(document.createTextNode('Date'));

      objCell = objRow.insertCell(-1);
      objCell.colSpan = 1;
      objCell.align = 'center';
      objCell.vAlign = 'center';
      objCell.className = 'clsLabelBB';
      objCell.style.fontSize = '8pt';
      objCell.style.fontWeight = 'bold';
      objCell.style.backgroundColor = '#40414c';
      objCell.style.color = '#ffffff';
      objCell.style.border = '#c0c0c0 1px solid';
      objCell.style.paddingLeft = '2px';
      objCell.style.paddingRight = '2px';
      objCell.style.whiteSpace = 'nowrap';
      objCell.appendChild(document.createTextNode('Time'));

      for (var i=0;i<cobjTypeLine.length;i++) {
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBB';
         objCell.style.fontSize = '8pt';
         if (cobjTypeLine[i].ovrflw == '0') {
            objCell.style.backgroundColor = '#04aa04';
         } else {
            objCell.style.backgroundColor = '#c00000';
         }
         objCell.style.color = '#ffffff';
         objCell.style.border = '#c0c0c0 1px solid';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objCell.innerHTML = '&nbsp;';

         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBB';
         objCell.style.fontSize = '8pt';
         objCell.style.fontWeight = 'bold';
         if (cobjTypeLine[i].ovrflw == '0') {
            objCell.style.backgroundColor = '#40414c';
         } else {
            objCell.style.backgroundColor = '#c00000';
         }
         objCell.style.color = '#ffffff';
         objCell.style.border = '#c0c0c0 1px solid';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         if (cobjTypeLine[i].ovrflw == '0') {
            objCell.style.cursor = 'pointer';
            objCell.onclick = function() {doTypeLineSelect(this);};
         }
         objCell.setAttribute('linidx',i);
         objCell.setAttribute('lincde',cobjTypeLine[i].lincde);
         objCell.setAttribute('concde',cobjTypeLine[i].lcocde);
         if (cobjTypeLine[i].filnam != '' && cobjTypeLine[i].filnam != null) {
            objCell.appendChild(document.createTextNode('('+cobjTypeLine[i].lincde+') '+cobjTypeLine[i].linnam+' - ('+cobjTypeLine[i].lcocde+') '+cobjTypeLine[i].lconam+' - '+cobjTypeLine[i].filnam));
         } else {
            objCell.appendChild(document.createTextNode('('+cobjTypeLine[i].lincde+') '+cobjTypeLine[i].linnam+' - ('+cobjTypeLine[i].lcocde+') '+cobjTypeLine[i].lconam));
         }
         cobjTypeLine[i].pntcol = objCell.cellIndex;
      }

      objCell = objRow.insertCell(-1);
      objCell.colSpan = 1;
      objCell.align = 'center';
      objCell.vAlign = 'center';
      objCell.className = 'clsLabelBB';
      objCell.style.fontSize = '8pt';
      objCell.style.backgroundColor = '#40414c';
      objCell.style.color = '#000000';
      objCell.style.border = 'none';
      objCell.style.paddingLeft = '4px';
      objCell.style.paddingRight = '4px';
      objCell.style.width = 16;
      objCell.style.whiteSpace = 'nowrap';
      objCell.innerHTML = '&nbsp;';

      intWrkCnt = 0;
      for (var i=0;i<cobjTypeDate.length;i++) {

         bolStrDay = true;

         for (var j=0;j<=23;j++) {

            if (j < 10) {
               strTime = '0'+j;
            } else {
               strTime = j;
            }

            objRow = objTypBody.insertRow(-1);
            intWrkCnt++;
            objCell = objRow.insertCell(-1);
            objCell.rowSpan = 4;
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.style.fontSize = '8pt';
            if (bolStrDay == true) {
               objCell.style.fontWeight = 'bold';
               objCell.style.backgroundColor = '#c0c0ff';
            } else {
               objCell.style.fontWeight = 'normal';
               objCell.style.backgroundColor = '#dddfff';
            }
            objCell.style.color = '#000000';
            objCell.style.border = '#000000 1px solid';
            objCell.style.paddingLeft = '2px';
            objCell.style.paddingRight = '2px';
            objCell.appendChild(document.createTextNode(cobjTypeDate[i].daynam));
            objCell.appendChild(document.createElement('br'));
            objCell.appendChild(document.createTextNode(cobjTypeDate[i].daycde));
            bolStrDay = false;
            doTypeSchdPaintTime(objRow, strTime, '00', intWrkCnt);

            objRow = objTypBody.insertRow(-1);
            intWrkCnt++;
            doTypeSchdPaintTime(objRow, strTime, '15', intWrkCnt);

            objRow = objTypBody.insertRow(-1);
            intWrkCnt++;
            doTypeSchdPaintTime(objRow, strTime, '30', intWrkCnt);

            objRow = objTypBody.insertRow(-1);
            intWrkCnt++;
            doTypeSchdPaintTime(objRow, strTime, '45', intWrkCnt);

         }

      }

      var objHeadCells = objTypHead.rows(0).cells;
      var objBodyCells = objTypBody.rows(0).cells;
      for (i=0;i<objHeadCells.length-1;i++) {
         if (objHeadCells[i].offsetWidth > objBodyCells[i].offsetWidth) {
            objBodyCells[i].style.width = objHeadCells[i].offsetWidth;
            objHeadCells[i].style.width = objHeadCells[i].offsetWidth;
         } else {
            objHeadCells[i].style.width = objBodyCells[i].offsetWidth;
            objBodyCells[i].style.width = objBodyCells[i].offsetWidth;
         }
         cintTypeHsiz[i] = objHeadCells[i].offsetWidth;
         cintTypeBsiz[i] = objBodyCells[i].offsetWidth;
      }
      addScrollSync(document.getElementById('conHeadSchd'),document.getElementById('conBodySchd'),'horizontal');
      objTypHead.style.tableLayout = 'fixed';
      objTypBody.style.tableLayout = 'fixed';

   }

   function doTypeSchdPaintTime(objRow, strTime, strMins, intWrkCnt) {

      var objShfAry;
      var objCell;
      var objTable;
      var objTabRow;
      var objTabCell;
      var objTabDiv;
      var intLinIdx;
      var strWrkInd;
      var intWrkStr;
      var intWrkEnd;
      var strWrkNam;

      strWrkNam = '';
      for (var s=0;s<cobjTypeStck.length;s++) {
         if ((cobjTypeStck[s].stkbar-0) == intWrkCnt) {
            if (strWrkNam != '') {
               strWrkNam = strWrkNam+' AND ';
            }
            strWrkNam = strWrkNam+cobjTypeStck[s].stknam;
         }
      }

      objCell = objRow.insertCell(-1);
      objCell.colSpan = 1;
      objCell.align = 'center';
      objCell.vAlign = 'center';
      objCell.style.fontSize = '8pt';
      if (strMins == '00') {
         objCell.style.fontWeight = 'bold';
      } else {
         objCell.style.fontWeight = 'normal';
      }
      if (strWrkNam == '') {
         objCell.style.backgroundColor = '#dddfff';
      } else {
         objCell.style.backgroundColor = '#c0c000';
         objCell.style.cursor = 'pointer';
         objCell.title = strWrkNam;
      }
      objCell.style.color = '#000000';
      objCell.style.border = '#000000 1px solid';
      objCell.style.paddingLeft = '2px';
      objCell.style.paddingRight = '2px';
      objCell.style.whiteSpace = 'nowrap';
      objCell.appendChild(document.createTextNode(strTime+':'+strMins));

      for (var k=0;k<cobjTypeLine.length;k++) {

         intLinIdx = k;
         strWrkInd = 'N';
         objShfAry = cobjTypeLine[k].shfary;
         for (var w=0;w<objShfAry.length;w++) {
            if (objShfAry[w].cmocde != '*NONE' && (intWrkCnt >= objShfAry[w].barstr && intWrkCnt <= objShfAry[w].barend)) {
               strWrkInd = 'X';
               if (intWrkCnt == objShfAry[w].barstr) {
                  strWrkInd = 'S';
                  intWrkStr = objShfAry[w].barstr;
                  intWrkEnd = objShfAry[w].barend;
                  strWrkNam = '('+objShfAry[w].shfcde+') '+objShfAry[w].shfnam;
               }
               break;
            }
         }

         if (strWrkInd == 'N') {

            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.style.fontSize = '8pt';
            objCell.style.backgroundColor = '#f7f7f7';
            objCell.style.color = '#000000';
            objCell.style.borderRight = '#c7c7c7 1px solid';
            objCell.style.paddingLeft = '2px';
            objCell.style.paddingRight = '2px';
            objCell.style.whiteSpace = 'nowrap';

            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'top';
            objCell.style.fontSize = '8pt';
            objCell.style.backgroundColor = '#f7f7f7';
            objCell.style.color = '#000000';
            objCell.style.border = '#c7c7c7 1px solid';
            objCell.style.padding = '0px';
            objCell.style.height = '100%';
            objCell.style.whiteSpace = 'nowrap';
            objCell.setAttribute('linidx',intLinIdx);
            objCell.setAttribute('baridx',intWrkCnt);

            objTable = document.createElement('table');
            objTable.id = 'TABBAR_'+intLinIdx+'_'+intWrkCnt;
            objTable.align = 'left';
            objTable.vAlign = 'center';
            objTable.style.fontSize = '8pt';
            objTable.style.fontWeight = 'normal';
            objTable.style.backgroundColor = 'transparent';
            objTable.style.color = '#000000';
            objTable.style.border = 'transparent 2px solid';
            objTable.style.padding = '2px';
            objTable.style.height = '100%';
            objTable.cellSpacing = '2px';
            objCell.appendChild(objTable);

         } else {

            if (strWrkInd == 'S') {

               objCell = objRow.insertCell(-1);
               objCell.rowSpan = (intWrkEnd - intWrkStr) + 1;
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.style.fontSize = '8pt';
               objCell.style.backgroundColor = '#04aa04';
               objCell.style.color = '#000000';
               objCell.style.borderTop = '#c7c7c7 1px solid';
               objCell.style.borderBottom = '#c7c7c7 1px solid';
               objCell.style.padding = '0px';
               objCell.style.height = '100%';
               objCell.style.whiteSpace = 'nowrap';

               objDiv = document.createElement('div');
               objDiv.align = 'center';
               objDiv.vAlign = 'center';
               objDiv.style.fontSize = '8pt';
               objDiv.style.fontWeight = 'normal';
               objDiv.style.backgroundColor = '#c0ffc0';
               objDiv.style.color = '#000000';
               objDiv.style.border = '#04aa04 2px solid';
               objDiv.style.paddingLeft = '2px';
               objDiv.style.paddingRight = '2px';
               objDiv.style.height = '100%';
               objDiv.style.width = '100%';
               objDiv.style.cursor = 'pointer';
               objDiv.innerHTML = '&nbsp;';
               objDiv.title = strWrkNam;
               objCell.appendChild(objDiv);

            }

            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'top';
            objCell.style.fontSize = '8pt';
            objCell.style.backgroundColor = 'transparent';
            objCell.style.color = '#000000';
            objCell.style.border = '#c7c7c7 1px solid';
            objCell.style.padding = '0px';
            objCell.style.height = '100%';
            objCell.style.whiteSpace = 'nowrap';
            objCell.setAttribute('linidx',intLinIdx);
            objCell.setAttribute('baridx',intWrkCnt);

            objTable = document.createElement('table');
            objTable.id = 'TABBAR_'+intLinIdx+'_'+intWrkCnt;
            objTable.align = 'left';
            objTable.vAlign = 'center';
            objTable.style.fontSize = '8pt';
            objTable.style.fontWeight = 'normal';
            objTable.style.backgroundColor = 'transparent';
            objTable.style.color = '#000000';
            objTable.style.border = 'transparent 2px solid';
            objTable.style.padding = '2px';
            objTable.style.height = '100%';
            objTable.cellSpacing = '2px';
            objCell.appendChild(objTable);

         }

      }

   }

   function doTypeSchdPaintActv() {
      for (var i=0;i<cobjTypeLine.length;i++) {
         doTypeWindPaint(i)
      }
   }


   function doTypeWindPaint(intLinIdx) {

      //
      // definitions
      //
      var objTypBody = document.getElementById('tabBodySchd');
      var objShfAry = cobjTypeLine[intLinIdx].shfary;
      var objActAry = cobjTypeLine[intLinIdx].actary;
      var objInvAry;
      var objTable;
      var objRow;
      var objCell;
      var objDiv;
      var objImg;
      var objWork;
      var intStrBar;
      var intEndBar;
      var intChgBar;

      //
      // delete the existing paint activity rows for the line window
      //
      for (var i=1;i<=768;i++) {
         objTable = document.getElementById('TABBAR_'+intLinIdx+'_'+i);
         for (var j=objTable.rows.length-1;j>=0;j--) {
            objTable.deleteRow(j);
         }
      }

      //
      // paint the line window start when required
      //
      for (var i=0;i<objShfAry.length;i++) {
         if (objShfAry[i].wintyp == '1') {
            objTable = document.getElementById('TABBAR_'+intLinIdx+'_'+objShfAry[i].barstr);
            objRow = objTable.insertRow(-1);
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'left';
            objCell.vAlign = 'top';
            objCell.style.fontSize = '8pt';
            objCell.style.fontWeight = 'normal';
            objCell.style.backgroundColor = 'transparent';
            objCell.style.color = '#000000';
            objCell.style.border = 'none';
            objCell.style.padding = '0px';
            objCell.style.whiteSpace = 'nowrap';
            objDiv = document.createElement('div');
            objDiv.align = 'left';
            objDiv.vAlign = 'top';
            objDiv.style.cursor = 'pointer';
            objDiv.style.fontSize = '10pt';
            objDiv.style.fontWeight = 'bold';
            objDiv.style.backgroundColor = '#ffd9ff';
            objDiv.style.color = '#000000';
            objDiv.style.border = '#c7c7c7 1px solid';
            objDiv.style.paddingLeft = '4px';
            objDiv.style.paddingRight = '4px';
            objDiv.style.whiteSpace = 'nowrap';
            objDiv.style.width = '1%';
            objDiv.setAttribute('actidx',-1);
            objDiv.setAttribute('wincde',objShfAry[i].wincde);
            objDiv.setAttribute('actcde','');
            objDiv.setAttribute('acttyp','+');
            objDiv.onclick = function() {doTypeSchdSelect(this);};
            objDiv.appendChild(document.createTextNode('+'));
            objCell.appendChild(objDiv);
         }
      }

      //
      // paint the line activities
      //
      for (var i=0;i<objActAry.length;i++) {
         objWork = objActAry[i];
         objInvAry = objWork.invary;
         intStrBar = objWork.strbar-0;
         intEndBar = objWork.endbar-0;
         intChgBar = 0;
         if (objWork.chgflg == '1') {
            intChgBar = objWork.chgbar-0;
         }
         for (var j=intStrBar;j<=intEndBar;j++) {
            objTable = document.getElementById('TABBAR_'+intLinIdx+'_'+j);
            if (j == intStrBar) {
               objRow = objTable.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.vAlign = 'top';
               objCell.style.fontSize = '8pt';
               objCell.style.fontWeight = 'normal';
               objCell.style.backgroundColor = 'transparent';
               objCell.style.color = '#000000';
               objCell.style.border = 'none';
               objCell.style.padding = '0px';
               objCell.style.height = '100%';
               objCell.style.whiteSpace = 'nowrap';
               objDiv = document.createElement('div');
               objDiv.align = 'left';
               objDiv.vAlign = 'top';
               objDiv.style.fontSize = '8pt';
               objDiv.style.fontWeight = 'normal';
               if (objWork.acttyp == 'T') {
                  objDiv.style.backgroundColor = '#dddfff';
               } else {
                  objDiv.style.backgroundColor = '#ffffe0';
               }
               objDiv.style.color = '#000000';
               if (objWork.winflw == '0') {
                  objDiv.style.border = '#000000 2px solid';
                  if (objWork.wekflw == '1') {
                     objDiv.style.border = '#c00000 2px solid';
                  }
               } else {
                  objDiv.style.border = '#c000c0 2px solid';
                  if (objWork.wekflw == '1') {
                     objDiv.style.border = '#c00000 2px solid';
                  }
               }
               objDiv.style.whiteSpace = 'nowrap';
               objDiv.style.width = '1%';
               objDiv.style.height = '100%';
               objDiv.style.padding = '2px';
               if (objWork.actent == '0') {
                  objDiv.style.cursor = 'pointer';
                  objDiv.onclick = function() {doTypeSchdSelect(this);};
               }
               objDiv.setAttribute('actidx',i);
               objDiv.setAttribute('wincde',objWork.wincde);
               objDiv.setAttribute('actcde',objWork.actcde);
               objDiv.setAttribute('acttyp',objWork.acttyp);
               if (objWork.acttyp == 'T') {
                  objDiv.appendChild(document.createTextNode('Activity ('+objWork.matcde+') '+objWork.matnam));
                  objDiv.appendChild(document.createElement('br'));
                  objDiv.appendChild(document.createTextNode('Start ('+objWork.strtim+') End ('+objWork.endtim+')'));
                  objDiv.appendChild(document.createElement('br'));
                  if (objWork.actent == '0') {
                     objDiv.appendChild(document.createTextNode('Scheduled Duration ('+objWork.schdmi+')'));
                  } else {
                     objDiv.appendChild(document.createTextNode('Scheduled Duration ('+objWork.schdmi+')'));
                     objDiv.appendChild(document.createElement('br'));
                     objDiv.appendChild(document.createTextNode('Actual Duration ('+objWork.actdmi+')'));
                  }
               } else {
                  objDiv.appendChild(document.createTextNode('Material ('+objWork.matcde+') '+objWork.matnam));
                  objDiv.appendChild(document.createElement('br'));
                  objDiv.appendChild(document.createTextNode('Start ('+objWork.strtim+') End ('+objWork.endtim+')'));
                  objDiv.appendChild(document.createElement('br'));
                  if (objWork.actent == '0') {
                     if (objWork.schchg == '0') {
                        objDiv.appendChild(document.createTextNode('Scheduled Production ('+objWork.schdmi+')'));
                     } else {
                        objDiv.appendChild(document.createTextNode('Scheduled Production ('+objWork.schdmi+') Change ('+objWork.schcmi+')'));
                     }
                     objDiv.appendChild(document.createElement('br'));
                     if (cstrTypeCode == '*FILL') {
                        objDiv.appendChild(document.createTextNode('Scheduled Cases ('+objWork.schcas+') Pouches ('+objWork.schpch+') Mixes ('+objWork.schmix+')'));
                     } else if (cstrTypeCode == '*PACK') {
                        objDiv.appendChild(document.createTextNode('Scheduled Cases ('+objWork.schcas+') Pallets ('+objWork.schplt+')'));
                     } else if (cstrTypeCode == '*FORM') {
                        objDiv.appendChild(document.createTextNode('Scheduled Pouches ('+objWork.schpch+')'));
                     }
                  } else {
                     if (objWork.schchg == '0') {
                        objDiv.appendChild(document.createTextNode('Scheduled Production ('+objWork.schdmi+')'));
                        objDiv.appendChild(document.createElement('br'));
                     } else {
                        objDiv.appendChild(document.createTextNode('Scheduled Production ('+objWork.schdmi+') Change ('+objWork.schcmi+')'));
                        objDiv.appendChild(document.createElement('br'));
                     }
                     if (objWork.chgflg == '0') {
                        objDiv.appendChild(document.createTextNode('Actual Production ('+objWork.actdmi+')'));
                     } else {
                        objDiv.appendChild(document.createTextNode('Actual Production ('+objWork.actdmi+') Change ('+objWork.actcmi+')'));
                     }
                     objDiv.appendChild(document.createElement('br'));
                     if (cstrTypeCode == '*FILL') {
                        objDiv.appendChild(document.createTextNode('Scheduled Cases ('+objWork.schcas+') Pouches ('+objWork.schpch+') Mixes ('+objWork.schmix+')'));
                        objDiv.appendChild(document.createElement('br'));
                        objDiv.appendChild(document.createTextNode('Actual Cases ('+objWork.actcas+') Pouches ('+objWork.actpch+') Mixes ('+objWork.actmix+')'));
                     } else if (cstrTypeCode == '*PACK') {
                        objDiv.appendChild(document.createTextNode('Scheduled Cases ('+objWork.schcas+') Pallets ('+objWork.schplt+')'));
                        objDiv.appendChild(document.createElement('br'));
                        objDiv.appendChild(document.createTextNode('Actual Cases ('+objWork.actcas+') Pallets ('+objWork.actplt+')'));
                     } else if (cstrTypeCode == '*FORM') {
                        objDiv.appendChild(document.createTextNode('Scheduled Pouches ('+objWork.schpch+')'));
                        objDiv.appendChild(document.createElement('br'));
                        objDiv.appendChild(document.createTextNode('Actual Pouches ('+objWork.actpch+')'));
                     }
                  }
                  for (var k=0;k<objInvAry.length;k++) {
                     objDiv.appendChild(document.createElement('br'));
                     objDiv.appendChild(document.createTextNode('Component ('+objInvAry[k].matcde+') '+objInvAry[k].matnam+' Required ('+objInvAry[k].invqty+') Available ('+objInvAry[k].invavl+')'));
                  }
               }
               objCell.appendChild(objDiv);
            }
            if (objWork.acttyp == 'T' || (objWork.acttyp == 'P' && objWork.chgflg == '0')) {
               if (j != intStrBar && j != intEndBar) {
                  objRow = objTable.insertRow(-1);
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.vAlign = 'top';
                  objCell.style.fontSize = '8pt';
                  objCell.style.fontWeight = 'normal';
                  objCell.style.backgroundColor = 'transparent';
                  objCell.style.color = '#000000';
                  objCell.style.border = 'none';
                  objCell.style.padding = '0px';
                  objCell.style.whiteSpace = 'nowrap';
                  objImg = document.createElement('img');
                  if (objWork.acttyp == 'T') {
                     objImg.src = cobjTico.src;
                     objImg.style.height = '15px';
                     objImg.style.width = '15px';
                  } else {
                     objImg.src = cobjPico.src;
                     objImg.style.height = '15px';
                     objImg.style.width = '23px';
                  }
                  objImg.align = 'absmiddle';
                  objCell.appendChild(objImg);
               }
            } else {
               if (j == intChgBar) {
                  objRow = objTable.insertRow(-1);
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.vAlign = 'top';
                  objCell.style.fontSize = '8pt';
                  objCell.style.fontWeight = 'normal';
                  objCell.style.backgroundColor = 'transparent';
                  objCell.style.color = '#000000';
                  objCell.style.border = 'none';
                  objCell.style.padding = '0px';
                  objCell.style.height = '100%';
                  objCell.style.whiteSpace = 'nowrap';
                  objImg = document.createElement('img');
                  objImg.src = cobjPico.src;
                  objImg.style.height = '15px';
                  objImg.style.width = '23px';
                  objImg.align = 'absmiddle';
                  objCell.appendChild(objImg);
                  objCell.appendChild(document.createTextNode(' '));
                  objDiv = document.createElement('div');
                  objDiv.align = 'left';
                  objDiv.vAlign = 'top';
                  objDiv.style.display = 'inline';
                  objDiv.style.fontSize = '8pt';
                  objDiv.style.fontWeight = 'normal';
                  objDiv.style.backgroundColor = '#ffffe0';
                  objDiv.style.color = '#000000';
                  if (objWork.winflw == '0') {
                     objDiv.style.border = '#c7c7c7 1px solid';
                     if (objWork.wekflw == '1') {
                        objDiv.style.border = '#c00000 1px solid';
                     }
                  } else {
                     objDiv.style.border = '#c000c0 1px solid';
                     if (objWork.wekflw == '1') {
                        objDiv.style.border = '#c00000 1px solid';
                     }
                  }
                  objDiv.style.whiteSpace = 'nowrap';
                  objDiv.style.width = '1%';
                  objDiv.style.padding = '2px';
                  objDiv.appendChild(document.createTextNode('Material change ('+objWork.chgtim+')'));
                  objCell.appendChild(objDiv);
               }
               if (j != intStrBar && j != intChgBar && j != intEndBar) {
                  objRow = objTable.insertRow(-1);
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.vAlign = 'top';
                  objCell.style.fontSize = '8pt';
                  objCell.style.fontWeight = 'normal';
                  objCell.style.backgroundColor = 'transparent';
                  objCell.style.color = '#000000';
                  objCell.style.border = 'none';
                  objCell.style.padding = '0px';
                  objCell.style.whiteSpace = 'nowrap';
                  objImg = document.createElement('img');
                  objImg.src = cobjPico.src;
                  objImg.style.height = '15px';
                  objImg.style.width = '23px';
                  objImg.align = 'absmiddle';
                  objCell.appendChild(objImg);
               }
            }
            if (j == intEndBar) {
               objRow = objTable.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.vAlign = 'top';
               objCell.style.fontSize = '8pt';
               objCell.style.fontWeight = 'normal';
               objCell.style.backgroundColor = 'transparent';
               objCell.style.color = '#000000';
               objCell.style.border = 'none';
               objCell.style.padding = '0px';
               objCell.style.whiteSpace = 'nowrap';
               objImg = document.createElement('img');
               if (objWork.acttyp == 'T') {
                  objImg.src = cobjTico.src;
                  objImg.style.height = '15px';
                  objImg.style.width = '15px';
               } else {
                  objImg.src = cobjPico.src;
                  objImg.style.height = '15px';
                  objImg.style.width = '23px';
               }
               objImg.align = 'absmiddle';
               objCell.appendChild(objImg);
               objCell.appendChild(document.createTextNode(' '));
               objDiv = document.createElement('div');
               objDiv.align = 'left';
               objDiv.vAlign = 'top';
               objDiv.style.display = 'inline';
               objDiv.style.fontSize = '8pt';
               objDiv.style.fontWeight = 'normal';
               if (objWork.acttyp == 'T') {
                  objDiv.style.backgroundColor = '#dddfff';
               } else {
                  objDiv.style.backgroundColor = '#ffffe0';
               }
               objDiv.style.color = '#000000';
               if (objWork.winflw == '0') {
                  objDiv.style.border = '#c7c7c7 1px solid';
                  if (objWork.wekflw == '1') {
                     objDiv.style.border = '#c00000 1px solid';
                  }
               } else {
                  objDiv.style.border = '#c000c0 1px solid';
                  if (objWork.wekflw == '1') {
                     objDiv.style.border = '#c00000 1px solid';
                  }
               }
               objDiv.style.whiteSpace = 'nowrap';
               objDiv.style.width = '1%';
               objDiv.style.padding = '2px';
               objDiv.appendChild(document.createTextNode('End ('+objWork.endtim+')'));
               objCell.appendChild(objDiv);
            }
         }
      }

      //
      // resize the line column
      //
      doTypeSchdReSize(intLinIdx);

   }

   function doTypeSchdReSize(intLinIdx) {
      var objSchHead = document.getElementById('tabHeadSchd');
      var objSchBody = document.getElementById('tabBodySchd');
      var intPntIdx = cobjTypeLine[intLinIdx].pntcol;
      var intWork;
      cintTypeBsiz[intPntIdx] = 0;
      for (var i=1;i<=768;i++) {
         intWork = document.getElementById('TABBAR_'+intLinIdx+'_'+i).offsetWidth;
         if (intWork > cintTypeBsiz[intPntIdx]) {
            cintTypeBsiz[intPntIdx] = intWork;
         }
      }
      if (cintTypeHsiz[intPntIdx] > cintTypeBsiz[intPntIdx]) {
         objSchHead.rows(0).cells[intPntIdx].style.width = cintTypeHsiz[intPntIdx];
         objSchBody.rows(0).cells[intPntIdx].style.width = cintTypeHsiz[intPntIdx];
      } else {
         objSchHead.rows(0).cells[intPntIdx].style.width = cintTypeBsiz[intPntIdx];
         objSchBody.rows(0).cells[intPntIdx].style.width = cintTypeBsiz[intPntIdx];
      }
   }




   function doTypeSchdRefresh() {
      doActivityStart(document.body);
      window.setTimeout('requestTypeReload();',10);
   }
   function doTypeSchdUpdate() {
      if (cobjTypeSchdCell == null) {
         alert('Scheduled activity must be selected for update');
         return;
      }
      if (cobjTypeSchdCell.getAttribute('acttyp') == '+') {
         alert('Unable to update shift window marker');
         return;
      }
      if (!processForm()) {return;}
      var objTime = cobjTypeSchdCell.parentNode.parentNode.parentNode.parentNode.parentNode;
      cintTypeLidx = objTime.getAttribute('linidx');
      cintTypeAidx = cobjTypeSchdCell.getAttribute('actidx');
      cstrTypeWcde = cobjTypeSchdCell.getAttribute('wincde');
      cstrTypeAcde = cobjTypeSchdCell.getAttribute('actcde')
      cstrTypeAtyp = cobjTypeSchdCell.getAttribute('acttyp');
      cstrTypeLcde = cobjTypeLine[cintTypeLidx].lincde;
      cstrTypeCcde = cobjTypeLine[cintTypeLidx].lcocde;
      cstrTypeWseq = cobjTypeLine[cintTypeLidx].actary[cintTypeAidx].winseq;
      if (cstrTypeAtyp == 'T') {
         doActivityStart(document.body);
         window.setTimeout('requestTimeUpdate();',10);
      } else {
         doActivityStart(document.body);
         window.setTimeout('requestProdUpdate();',10);
      }
   }
   function doTypeSchdTime() {
      if (cobjTypeSchdCell == null) {
         alert('Scheduled activity must be selected for add time after');
         return;
      }
      if (!processForm()) {return;}
      var objTime = cobjTypeSchdCell.parentNode.parentNode.parentNode.parentNode.parentNode;
      cintTypeLidx = objTime.getAttribute('linidx');
      cintTypeAidx = cobjTypeSchdCell.getAttribute('actidx');
      cstrTypeWcde = cobjTypeSchdCell.getAttribute('wincde');
      cstrTypeAcde = '0'
      cstrTypeAtyp = 'T';
      cstrTypeLcde = cobjTypeLine[cintTypeLidx].lincde;
      cstrTypeCcde = cobjTypeLine[cintTypeLidx].lcocde;
      if (cintTypeAidx == -1) {
         cstrTypeWseq = '0';
      } else {
         cstrTypeWseq = cobjTypeLine[cintTypeLidx].actary[cintTypeAidx].winseq;
      }
      doActivityStart(document.body);
      window.setTimeout('requestTimeAdd();',10);
   }
   function doTypeSchdProd() {
      if (cobjTypeSchdCell == null) {
         alert('Scheduled activity must be selected for add production after');
         return;
      }
      if (!processForm()) {return;}
      var objTime = cobjTypeSchdCell.parentNode.parentNode.parentNode.parentNode.parentNode;
      cintTypeLidx = objTime.getAttribute('linidx');
      cintTypeAidx = cobjTypeSchdCell.getAttribute('actidx');
      cstrTypeWcde = cobjTypeSchdCell.getAttribute('wincde');
      cstrTypeAcde = '0';
      cstrTypeAtyp = 'P';
      cstrTypeLcde = cobjTypeLine[cintTypeLidx].lincde;
      cstrTypeCcde = cobjTypeLine[cintTypeLidx].lcocde;
      if (cintTypeAidx == -1) {
         cstrTypeWseq = '0';
      } else {
         cstrTypeWseq = cobjTypeLine[cintTypeLidx].actary[cintTypeAidx].winseq;
      }
      doActivityStart(document.body);
      window.setTimeout('requestProdAdd();',10);
   }

   function doTypeUactSelect(objSelect) {
      if (cobjTypeLineCell != null) {
         cobjTypeLineCell.style.backgroundColor = '#40414c';
         cobjTypeLineCell = null;
      }
      if (cobjTypeUactCell != null) {
         if (cobjTypeUactCell.getAttribute('acttyp') == 'T') {
            cobjTypeUactCell.style.backgroundColor = '#dddfff';
         } else {
            cobjTypeUactCell.style.backgroundColor = '#ffffe0';
         }
      }
      cobjTypeUactCell = objSelect;
      if (cobjTypeUactCell.getAttribute('acttyp') == 'T') {
         cobjTypeUactCell.style.backgroundColor = '#c0c0ff';
      } else {
         cobjTypeUactCell.style.backgroundColor = '#ffff80';
      }
   }
   function doTypeUactToggle() {
      if (cstrTypeTind == '0') {
         cstrTypeTind = '1';
         document.getElementById('datTypeSchd').style.width = '75%';
         document.getElementById('datTypeUact').style.display = 'block';
      } else {
         cstrTypeTind = '0';
         document.getElementById('datTypeSchd').style.width = '100%';
         document.getElementById('datTypeUact').style.display = 'none';
      }
   }
   function doTypeUactDetach() {
      if (cobjTypeSchdCell == null) {
         alert('Scheduled activity must be selected for detach activity');
         return;
      }
      if (cobjTypeSchdCell.getAttribute('acttyp') == '+') {
         alert('Unable to detach shift window marker');
         return;
      }
      if (!processForm()) {return;}
      var objTime = cobjTypeSchdCell.parentNode.parentNode.parentNode.parentNode.parentNode;
      cintTypeLidx = objTime.getAttribute('linidx');
      cintTypeAidx = cobjTypeSchdCell.getAttribute('actidx');
      cstrTypeWcde = cobjTypeSchdCell.getAttribute('wincde');
      cstrTypeAcde = cobjTypeSchdCell.getAttribute('actcde')
      cstrTypeAtyp = cobjTypeSchdCell.getAttribute('acttyp');
      cstrTypeLcde = cobjTypeLine[cintTypeLidx].lincde;
      cstrTypeCcde = cobjTypeLine[cintTypeLidx].lcocde;
      doActivityStart(document.body);
      window.setTimeout('requestActvDetach();',10);
   }
   function doTypeUactAttach() {
      if (cobjTypeSchdCell == null) {
         alert('Scheduled activity must be selected for attach activity after');
         return;
      }
      if (cobjTypeUactCell == null) {
         alert('Activity must be selected for attach activity after');
         return;
      }
      if (!processForm()) {return;}
      var objTime = cobjTypeSchdCell.parentNode.parentNode.parentNode.parentNode.parentNode;
      cintTypeLidx = objTime.getAttribute('linidx');
      cintTypeAidx = cobjTypeSchdCell.getAttribute('actidx');
      cstrTypeWcde = cobjTypeSchdCell.getAttribute('wincde');
      cstrTypeLcde = cobjTypeLine[cintTypeLidx].lincde;
      cstrTypeCcde = cobjTypeLine[cintTypeLidx].lcocde;
      if (cintTypeAidx == -1) {
         cstrTypeWseq = '0';
      } else {
         cstrTypeWseq = cobjTypeLine[cintTypeLidx].actary[cintTypeAidx].winseq;
      }
      cstrTypeAcde = cobjTypeUactCell.getAttribute('actcde');
      doActivityStart(document.body);
      window.setTimeout('requestActvAttach();',10);
   }
   function doTypeUactDelete() {
      if (cobjTypeUactCell == null) {
         alert('Activity must be selected for deletion');
         return;
      }
      if (!processForm()) {return;}
      if (confirm('Please confirm the deletion\r\npress OK continue (the selected activity will be deleted)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      cstrTypeAcde = cobjTypeUactCell.getAttribute('actcde');
      doActivityStart(document.body);
      window.setTimeout('requestActvDelete();',10);
   }
   function doTypeUactPaint() {
      var objRow;
      var objCell;
      var objWork;
      var objUacBody = document.getElementById('tabBodyUact');
      objUacBody.style.tableLayout = 'auto';
      for (var i=objUacBody.rows.length-1;i>=0;i--) {
         objUacBody.deleteRow(i);
      }
      for (var i=0;i<cobjTypeUact.length;i++) {
         objWork = cobjTypeUact[i];
         objRow = objUacBody.insertRow(-1);
         var objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'left';
         objCell.vAlign = 'center';
         objCell.style.cursor = 'pointer';
         objCell.style.fontSize = '8pt';
         objCell.style.fontWeight = 'normal';
         if (objWork.acttyp == 'T') {
            objCell.style.backgroundColor = '#dddfff';
         } else {
            objCell.style.backgroundColor = '#ffffe0';
         }
         objCell.style.color = '#000000';
         objCell.style.border = '#c7c7c7 1px solid';
         objCell.style.padding = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objCell.onclick = function() {doTypeUactSelect(this);};
         objCell.setAttribute('reqidx',i);
         objCell.setAttribute('actcde',cobjTypeUact[i].actcde);
         objCell.setAttribute('acttyp',cobjTypeUact[i].acttyp);
         if (objWork.acttyp == 'T') {
            objCell.appendChild(document.createTextNode('Activity ('+objWork.matcde+') '+objWork.matnam+')'));
            objCell.appendChild(document.createElement('br'));
            objCell.appendChild(document.createTextNode('Line ('+objWork.lincde+') '+objWork.concde));
            objCell.appendChild(document.createElement('br'));
            objCell.appendChild(document.createTextNode('Scheduled Duration ('+objWork.schdur+')'));
         } else {
            objCell.appendChild(document.createTextNode('Material ('+objWork.matcde+') '+objWork.matnam+')'));
            objCell.appendChild(document.createElement('br'));
            objCell.appendChild(document.createTextNode('Line ('+objWork.lincde+') '+objWork.concde));
            objCell.appendChild(document.createElement('br'));
            if (cstrTypeCode == '*FILL') {
               objCell.appendChild(document.createTextNode('Cases SAP('+objWork.sapqty+') Requested('+objWork.reqcas+') Scheduled('+objWork.schcas+')'));
               objCell.appendChild(document.createElement('br'));
               objCell.appendChild(document.createTextNode('Pouches Requested('+objWork.reqpch+') Scheduled('+objWork.schpch+')'));
               objCell.appendChild(document.createElement('br'));
               objCell.appendChild(document.createTextNode('Mixes Requested('+objWork.reqmix+') Scheduled('+objWork.schmix+')'));
            } else if (cstrTypeCode == '*PACK') {
               objCell.appendChild(document.createTextNode('Cases SAP('+objWork.sapqty+') Requested('+objWork.reqcas+') Scheduled('+objWork.schcas+')'));
               objCell.appendChild(document.createElement('br'));
               objCell.appendChild(document.createTextNode('Pallets Requested('+objWork.reqplt+') Scheduled('+objWork.schplt+')'));
            } else if (cstrTypeCode == '*FORM') {
               objCell.appendChild(document.createTextNode('Pouches SAP('+objWork.sapqty+') Requested('+objWork.reqpch+') Scheduled('+objWork.schpch+')'));
            }
            objCell.appendChild(document.createElement('br'));
            objCell.appendChild(document.createTextNode('Scheduled Duration ('+objWork.schdur+')'));
         }
      }
   }

   /////////////////////
   // Stock Functions //
   /////////////////////
   function requestStckUpdate() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDSTK" SRCCDE="*SCH"';
      strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'" WEKCDE="'+fixXML(cstrTypeWeek)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_stck_update.asp',function(strResponse) {checkStckLoad(strResponse);},false,streamXML(strXML));
   }
   function checkStckLoad(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         doActivityStop();
         alert(strResponse);
      } else {
         if (strResponse.length <= 3) {
            requestTypeReload();
            return;
         }
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
            doActivityStop();
            alert(strMessage);
            return;
         }
         requestTypeReload();
      }
   }

   ////////////////////
   // Line Functions //
   ////////////////////
   var cstrLineMode;
   var cintLineIndx;
   var cobjLineLcod = new Array();
   var cobjLineSmod = new Array();
   var cobjLineCmod = new Array();
   function clsLineLcod() {
      this.lincde = '';
      this.linnam = '';
      this.lcocde = '';
      this.lconam = '';
      this.smocde = '*NONE';
      this.filnam = '';
      this.shfary = new Array();
   }
   function clsLineLlnk() {
      this.smoseq = '';
      this.cmocde = '';
   }
   function clsLineSmod() {
      this.smocde = '';
      this.smonam = '';
      this.shfary = new Array();
   }
   function clsLineShfd() {
      this.shfcde = '';
      this.shfnam = '';
      this.shfstr = '';
      this.shfdur = '';
   }
   function clsLineCmod() {
      this.cmocde = '';
      this.cmonam = '';
   }
   function requestLineCreate() {
      cstrLineMode = '*CRT';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTLIN" SRCCDE="*SCH"';
      strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
      strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
      strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_line_retrieve.asp',function(strResponse) {checkLineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestLineUpdate() {
      cstrLineMode = '*UPD';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDLIN" SRCCDE="*SCH"';
      strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
      strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
      strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
      strXML = strXML+' LINCDE="'+fixXML(cstrTypeLcde)+'"';
      strXML = strXML+' CONCDE="'+fixXML(cstrTypeCcde)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_line_retrieve.asp',function(strResponse) {checkLineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestLineDelete() {
      cstrLineMode = '*DLT';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*DLTLIN" SRCCDE="*SCH"';
      strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
      strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
      strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
      strXML = strXML+' LINCDE="'+fixXML(cstrTypeLcde)+'"';
      strXML = strXML+' CONCDE="'+fixXML(cstrTypeCcde)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_line_delete.asp',function(strResponse) {checkLineLoad(strResponse);},false,streamXML(strXML));
   }
   function checkLineLoad(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         doActivityStop();
         alert(strResponse);
      } else {
         if (strResponse.length <= 3) {
            requestTypeReload();
            return;
         }
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
            doActivityStop();
            alert(strMessage);
            return;
         }
         if (cstrLineMode == '*DLT') {
            requestTypeReload();
            return;
         } else {
            doActivityStop();
         }
         if (cstrLineMode == '*UPD') {
            cobjScreens[6].hedtxt = 'Update Line Configuration';
            document.getElementById('addLine').style.display = 'none';
            document.getElementById('updLine').style.display = 'block';
         } else if (cstrLineMode == '*CRT') {
            cobjScreens[6].hedtxt = 'Add Line Configuration';
            document.getElementById('addLine').style.display = 'block';
            document.getElementById('updLine').style.display = 'none';
         }
         displayScreen('dspLine');
         cintLineIndx = -1;
         cobjLineLcod.length = 0;
         cobjLineSmod.length = 0;
         cobjLineCmod.length = 0;
         var objLinList;
         if (cstrLineMode == '*CRT') {
            objLinList = document.getElementById('LIN_LinList');
            objLinList.options.length = 0;
            objLinList.options[0] = new Option('** Select Line Configuration **','*NONE');
            objLinList.selectedIndex = 0;
         }
         var strSmoCode = '*NONE';
         var objSmoList = document.getElementById('LIN_SmoList');
         objSmoList.options.length = 0;
         objSmoList.options[0] = new Option('** Select Shift Model **','*NONE');
         objSmoList.selectedIndex = 0;
         var objArray;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'SMODFN') {
               objSmoList.options[objSmoList.options.length] = new Option('('+objElements[i].getAttribute('SMOCDE')+') '+objElements[i].getAttribute('SMONAM'),objElements[i].getAttribute('SMOCDE'));
               cobjLineSmod[cobjLineSmod.length] = new clsLineSmod();
               cobjLineSmod[cobjLineSmod.length-1].smocde = objElements[i].getAttribute('SMOCDE');
               cobjLineSmod[cobjLineSmod.length-1].smonam = objElements[i].getAttribute('SMONAM');
            } else if (objElements[i].nodeName == 'SHFDFN') {
               objArray = cobjLineSmod[cobjLineSmod.length-1].shfary;
               objArray[objArray.length] = new clsLineShfd();
               objArray[objArray.length-1].shfcde = objElements[i].getAttribute('SHFCDE');
               objArray[objArray.length-1].shfnam = objElements[i].getAttribute('SHFNAM');
               objArray[objArray.length-1].shfstr = objElements[i].getAttribute('SHFSTR');
               objArray[objArray.length-1].shfdur = objElements[i].getAttribute('SHFDUR');
            } else if (objElements[i].nodeName == 'CMODFN') {
               cobjLineCmod[cobjLineCmod.length] = new clsLineCmod();
               cobjLineCmod[cobjLineCmod.length-1].cmocde = objElements[i].getAttribute('CMOCDE');
               cobjLineCmod[cobjLineCmod.length-1].cmonam = objElements[i].getAttribute('CMONAM');
            } else if (objElements[i].nodeName == 'LCODFN') {
               cobjLineLcod[cobjLineLcod.length] = new clsLineLcod();
               cobjLineLcod[cobjLineLcod.length-1].lincde = objElements[i].getAttribute('LINCDE');
               cobjLineLcod[cobjLineLcod.length-1].linnam = objElements[i].getAttribute('LINNAM');
               cobjLineLcod[cobjLineLcod.length-1].lcocde = objElements[i].getAttribute('LCOCDE');
               cobjLineLcod[cobjLineLcod.length-1].lconam = objElements[i].getAttribute('LCONAM');
               cobjLineLcod[cobjLineLcod.length-1].smocde = objElements[i].getAttribute('SMOCDE');
               cobjLineLcod[cobjLineLcod.length-1].filnam = objElements[i].getAttribute('FILNAM');
               if (cstrLineMode == '*UPD') {
                  cintLineIndx = 0;
                  strSmoCode = objElements[i].getAttribute('SMOCDE');
                  if (objElements[i].getAttribute('FILNAM') != '' && objElements[i].getAttribute('FILNAM') != null) {
                     document.getElementById('LIN_UpdLine').innerHTML = '<p>'+'('+objElements[i].getAttribute('LINCDE')+') '+objElements[i].getAttribute('LINNAM')+' - ('+objElements[i].getAttribute('LCOCDE')+') '+objElements[i].getAttribute('LCONAM')+' - '+objElements[i].getAttribute('FILNAM')+'</p>';
                  } else {
                     document.getElementById('LIN_UpdLine').innerHTML = '<p>'+'('+objElements[i].getAttribute('LINCDE')+') '+objElements[i].getAttribute('LINNAM')+' - ('+objElements[i].getAttribute('LCOCDE')+') '+objElements[i].getAttribute('LCONAM')+'</p>';
                  }
               } else {
                  if (objElements[i].getAttribute('FILNAM') != '' && objElements[i].getAttribute('FILNAM') != null) {
                     objLinList.options[objLinList.options.length] = new Option('('+objElements[i].getAttribute('LINCDE')+') '+objElements[i].getAttribute('LINNAM')+' - ('+objElements[i].getAttribute('LCOCDE')+') '+objElements[i].getAttribute('LCONAM')+' - '+objElements[i].getAttribute('FILNAM'),objElements[i].getAttribute('LINCDE')+'_'+objElements[i].getAttribute('LCOCDE'));
                  } else {
                     objLinList.options[objLinList.options.length] = new Option('('+objElements[i].getAttribute('LINCDE')+') '+objElements[i].getAttribute('LINNAM')+' - ('+objElements[i].getAttribute('LCOCDE')+') '+objElements[i].getAttribute('LCONAM'),objElements[i].getAttribute('LINCDE')+'_'+objElements[i].getAttribute('LCOCDE'));
                  }
               }
            } else if (objElements[i].nodeName == 'SHFLNK') {
               objArray = cobjLineLcod[cobjLineLcod.length-1].shfary;
               objArray[objArray.length] = new clsLineLlnk();
               objArray[objArray.length-1].smoseq = objElements[i].getAttribute('SMOSEQ');
               objArray[objArray.length-1].cmocde = objElements[i].getAttribute('CMOCDE');
            }
         }
         for (var i=0;i<objSmoList.length;i++) {
            if (objSmoList.options[i].value == strSmoCode) {
               objSmoList.options[i].selected = true;
               break;
            }
         }
         if (cstrLineMode == '*UPD') {
            document.getElementById('LIN_SmoList').focus();
         } else {
            document.getElementById('LIN_LinList').focus();
         }
         doLineSmodChange(objSmoList,true);
      }
   }
   function doLineLconChange(objLinLst) {
      cintLineIndx = objLinLst.selectedIndex-1;
      var objSmoList = document.getElementById('LIN_SmoList');
      objSmoList.selectedIndex = 0;
      doLineSmodChange(objSmoList,false);
   }
   function doLineSmodChange(objSmoLst,bolLoad) {
      var objRow;
      var objCell;
      var objCmoLst;
      var objShfAry;
      var objWrkAry;
      var intBarDay;
      var intBarCnt;
      var intBarStr;
      var intStrTim;
      var intDurMin;
      var strDayNam;
      var objLinData = document.getElementById('LIN_LinData');
      for (var i=objLinData.rows.length-1;i>=0;i--) {
         objLinData.deleteRow(i);
      }
      if (cintLineIndx < 0) {
         objLinData.style.display = 'none';
         return;
      } else if (objSmoLst.selectedIndex == -1 || objSmoLst.options[objSmoLst.selectedIndex].value == '*NONE') {
         objLinData.style.display = 'none';
         return;
      } else {
         objLinData.style.display = 'block';
      }
      objRow = objLinData.insertRow(-1);
      objCell = objRow.insertCell(-1);
      objCell.colSpan = 1;
      objCell.align = 'center';
      objCell.vAlign = 'center';
      objCell.className = 'clsLabelBB';
      objCell.style.fontSize = '8pt';
      objCell.style.backgroundColor = '#efefef';
      objCell.style.color = '#000000';
      objCell.style.border = '#708090 1px solid';
      objCell.style.paddingLeft = '2px';
      objCell.style.paddingRight = '2px';
      objCell.style.whiteSpace = 'nowrap';
      objCell.appendChild(document.createTextNode('Shifts'));
      objCell = objRow.insertCell(-1);
      objCell.colSpan = 1;
      objCell.align = 'center';
      objCell.vAlign = 'center';
      objCell.className = 'clsLabelBB';
      objCell.style.fontSize = '8pt';
      objCell.style.backgroundColor = '#efefef';
      objCell.style.color = '#000000';
      objCell.style.border = '#708090 1px solid';
      objCell.style.paddingLeft = '2px';
      objCell.style.paddingRight = '2px';
      objCell.style.whiteSpace = 'nowrap';
      objCell.appendChild(document.createTextNode('Crew Model'));
      objWrkAry = cobjLineLcod[cintLineIndx].shfary;
      objShfAry = cobjLineSmod[objSmoLst.selectedIndex-1].shfary;
      for (var i=0;i<objShfAry.length;i++) {
         intStrTim = objShfAry[i].shfstr;
         intDurMin = objShfAry[i].shfdur;
         if (i == 0) {
            intBarStr = ((Math.floor(intStrTim / 100) + ((intStrTim % 100) / 60)) * 4) + 1;
         } else {
            intBarStr = intBarStr + intBarCnt;
         }
         intBarCnt = (intDurMin / 60) * 4;
         intBarDay = Math.floor(intBarStr / 96) + 1;
         strDayNam = 'Sunday';
         if (intBarDay == 1) {
            strDayNam = 'Sunday';
         } else if (intBarDay == 2) {
            strDayNam = 'Monday';
         } else if (intBarDay == 3) {
            strDayNam = 'Tuesday';
         } else if (intBarDay == 4) {
            strDayNam = 'Wednesday';
         } else if (intBarDay == 5) {
            strDayNam = 'Thursday';
         } else if (intBarDay == 6) {
            strDayNam = 'Friday';
         } else if (intBarDay == 7) {
            strDayNam = 'Saturday';
         } else if (intBarDay == 8) {
            strDayNam = 'Sunday';
         }
         objRow = objLinData.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'left';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBN';
         objCell.style.fontSize = '8pt';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objCell.appendChild(document.createTextNode(strDayNam+' - '+objShfAry[i].shfnam));
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBN';
         objCell.style.fontSize = '8pt';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objCmoLst = document.createElement('select');
         objCmoLst.id = 'LCONCMOD_'+i;
         objCmoLst.className = 'clsInputNN';
         objCmoLst.style.fontSize = '8pt';
         objCmoLst.selectedIndex = 0;
         objCmoLst.options[0] = new Option('** NONE **','*NONE');
         objCmoLst.options[0].selected = true;
         for (var j=0;j<cobjLineCmod.length;j++) {
            objCmoLst.options[objCmoLst.options.length] = new Option('('+cobjLineCmod[j].cmocde+') '+cobjLineCmod[j].cmonam,cobjLineCmod[j].cmocde);
            if (bolLoad == true && objWrkAry[i] != null && cobjLineCmod[j].cmocde == objWrkAry[i].cmocde) {
               objCmoLst.options[objCmoLst.options.length-1].selected = true;
            }
         }
         objCell.appendChild(objCmoLst);
      }
   }
   function doLineCancel() {
      if (cobjTypeLineCell != null) {
         cobjTypeLineCell.style.backgroundColor = '#40414c';
         cobjTypeLineCell = null;
      }
      cobjLineLcod.length = 0;
      cobjLineSmod.length = 0;
      cobjLineCmod.length = 0;
      displayScreen('dspType');
      document.getElementById('hedType').innerText = cstrTypeHead;
   }
   function doLineAccept() {
      if (!processForm()) {return;}
      var objLinList;
      if (cstrLineMode == '*CRT') {
         objLinList = document.getElementById('LIN_LinList');
      }
      var objSmoList = document.getElementById('LIN_SmoList');
      var objShfAry;
      var bolShftFound;
      var objCmoList;
      var strMessage = '';
      if (cstrLineMode == '*CRT') {
         if (objLinList.selectedIndex == -1 || objLinList.options[objLinList.selectedIndex].value == '*NONE') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Line configuration must be selected';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (objSmoList.selectedIndex == -1 || objSmoList.options[objSmoList.selectedIndex].value == '*NONE') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Shift model must be selected';
      } else {
         bolShftFound = false;
         objShfAry = cobjLineSmod[objSmoList.selectedIndex-1].shfary;
         for (var i=0;i<objShfAry.length;i++) {
            objCmoList = document.getElementById('LCONCMOD_'+i);
            if (objCmoList.selectedIndex != -1 && objCmoList.options[objCmoList.selectedIndex].value != '*NONE') {
               bolShftFound = true;
            }
         }
         if (bolShftFound == false) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'At least one shift must have a crew model selected for the line configuration';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrLineMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDLIN" SRCCDE="*SCH"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
         strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
         strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
         strXML = strXML+' LINCDE="'+fixXML(cobjLineLcod[0].lincde)+'"';
         strXML = strXML+' CONCDE="'+fixXML(cobjLineLcod[0].lcocde)+'"';
         strXML = strXML+' SMOCDE="'+fixXML(cobjLineSmod[objSmoList.selectedIndex-1].smocde)+'">';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTLIN" SRCCDE="*SCH"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
         strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
         strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
         strXML = strXML+' LINCDE="'+fixXML(cobjLineLcod[objLinList.selectedIndex-1].lincde)+'"';
         strXML = strXML+' CONCDE="'+fixXML(cobjLineLcod[objLinList.selectedIndex-1].lcocde)+'"';
         strXML = strXML+' SMOCDE="'+fixXML(cobjLineSmod[objSmoList.selectedIndex-1].smocde)+'">';
      }
      objShfAry = cobjLineSmod[objSmoList.selectedIndex-1].shfary;
      for (var i=0;i<objShfAry.length;i++) {
         objCmoList = document.getElementById('LCONCMOD_'+i);
         if (objCmoList.selectedIndex == -1) {
            strXML = strXML+'<LINSHF SHFCDE="'+fixXML(objShfAry[i].shfcde)+'" SHFSTR="'+fixXML(objShfAry[i].shfstr)+'" SHFDUR="'+fixXML(objShfAry[i].shfdur)+'" CMOCDE="'+fixXML('*NONE')+'"/>';
         } else {
            strXML = strXML+'<LINSHF SHFCDE="'+fixXML(objShfAry[i].shfcde)+'" SHFSTR="'+fixXML(objShfAry[i].shfstr)+'" SHFDUR="'+fixXML(objShfAry[i].shfdur)+'" CMOCDE="'+fixXML(objCmoList.options[objCmoList.selectedIndex].value)+'"/>';
         }
      }
      strXML = strXML+'</PSA_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestLineAccept(\''+strXML+'\');',10);
   }
   function requestLineAccept(strXML) {
      doPostRequest('<%=strBase%>psa_psc_line_update.asp',function(strResponse) {checkLineAccept(strResponse);},false,streamXML(strXML));
   }
   function checkLineAccept(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         doActivityStop();
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
               doActivityStop();
               alert(strMessage);
               return;
            }
         }
         cobjLineLcod.length = 0;
         cobjLineSmod.length = 0;
         cobjLineCmod.length = 0;
         requestTypeReload();
      }
   }

   ////////////////////////
   // Activity Functions //
   ////////////////////////
   var cstrActvMode;
   function requestActvLoad() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+' <PSA_REQUEST ACTION="'+cstrActvMode+'" SRCCDE="*SCH"';
      if (cstrActvMode == '*RTVSCH') {
         strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
         strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
         strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
         strXML = strXML+' LINCDE="'+fixXML(cstrTypeLcde)+'"';
         strXML = strXML+' CONCDE="'+fixXML(cstrTypeCcde)+'"/>';
      } else {
         strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
         strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
         strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"/>';
      }
      doPostRequest('<%=strBase%>psa_psc_actv_retrieve.asp',function(strResponse) {checkActvLoad(strResponse);},false,streamXML(strXML));
   }
   function checkActvLoad(strResponse) {
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
         displayScreen('dspType');
         document.getElementById('hedType').innerText = cstrTypeHead;
         var objActAry;
         if (cstrActvMode == '*RTVSCH') {
            objActAry = cobjTypeLine[cintTypeLidx].actary;
            objActAry.length = 0;
         }
         cobjTypeUact.length = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PTYDFN') {
               if (cstrActvMode == '*RTVSCH') {
                  cstrTypePulse = objElements[i].getAttribute('PULVAL');
               }
            } else if (objElements[i].nodeName == 'LINACT') {
               if (cstrActvMode == '*RTVSCH') {
                  objActAry[objActAry.length] = new clsTypeActv();
                  objActAry[objActAry.length-1].actcde = objElements[i].getAttribute('ACTCDE');
                  objActAry[objActAry.length-1].acttyp = objElements[i].getAttribute('ACTTYP');
                  objActAry[objActAry.length-1].chgflg = objElements[i].getAttribute('CHGFLG');
                  objActAry[objActAry.length-1].wincde = objElements[i].getAttribute('WINCDE');
                  objActAry[objActAry.length-1].winseq = objElements[i].getAttribute('WINSEQ');
                  objActAry[objActAry.length-1].winflw = objElements[i].getAttribute('WINFLW');
                  objActAry[objActAry.length-1].wekflw = objElements[i].getAttribute('WEKFLW');
                  objActAry[objActAry.length-1].strtim = objElements[i].getAttribute('STRTIM');
                  objActAry[objActAry.length-1].chgtim = objElements[i].getAttribute('CHGTIM');
                  objActAry[objActAry.length-1].endtim = objElements[i].getAttribute('ENDTIM');
                  objActAry[objActAry.length-1].strbar = objElements[i].getAttribute('STRBAR');
                  objActAry[objActAry.length-1].chgbar = objElements[i].getAttribute('CHGBAR');
                  objActAry[objActAry.length-1].endbar = objElements[i].getAttribute('ENDBAR');
                  objActAry[objActAry.length-1].schdmi = objElements[i].getAttribute('SCHDMI');
                  objActAry[objActAry.length-1].actdmi = objElements[i].getAttribute('ACTDMI');
                  objActAry[objActAry.length-1].schcmi = objElements[i].getAttribute('SCHCMI');
                  objActAry[objActAry.length-1].actcmi = objElements[i].getAttribute('ACTCMI');
                  objActAry[objActAry.length-1].actent = objElements[i].getAttribute('ACTENT');
                  objActAry[objActAry.length-1].matcde = objElements[i].getAttribute('MATCDE');
                  objActAry[objActAry.length-1].matnam = objElements[i].getAttribute('MATNAM');
                  objActAry[objActAry.length-1].schplt = objElements[i].getAttribute('SCHPLT');
                  objActAry[objActAry.length-1].schcas = objElements[i].getAttribute('SCHCAS');
                  objActAry[objActAry.length-1].schpch = objElements[i].getAttribute('SCHPCH');
                  objActAry[objActAry.length-1].schmix = objElements[i].getAttribute('SCHMIX');
                  objActAry[objActAry.length-1].schton = objElements[i].getAttribute('SCHTON');
                  objActAry[objActAry.length-1].actplt = objElements[i].getAttribute('ACTPLT');
                  objActAry[objActAry.length-1].actcas = objElements[i].getAttribute('ACTCAS');
                  objActAry[objActAry.length-1].actpch = objElements[i].getAttribute('ACTPCH');
                  objActAry[objActAry.length-1].actmix = objElements[i].getAttribute('ACTMIX');
                  objActAry[objActAry.length-1].actton = objElements[i].getAttribute('ACTTON');
               }
            } else if (objElements[i].nodeName == 'UNSACT') {
               cobjTypeUact[cobjTypeUact.length] = new clsTypeUact();
               cobjTypeUact[cobjTypeUact.length-1].actcde = objElements[i].getAttribute('ACTCDE');
               cobjTypeUact[cobjTypeUact.length-1].acttyp = objElements[i].getAttribute('ACTTYP');
               cobjTypeUact[cobjTypeUact.length-1].matcde = objElements[i].getAttribute('MATCDE');
               cobjTypeUact[cobjTypeUact.length-1].matnam = objElements[i].getAttribute('MATNAM');
               cobjTypeUact[cobjTypeUact.length-1].lincde = objElements[i].getAttribute('LINCDE');
               cobjTypeUact[cobjTypeUact.length-1].concde = objElements[i].getAttribute('CONCDE');
               cobjTypeUact[cobjTypeUact.length-1].dftflg = objElements[i].getAttribute('DFTFLG');
               cobjTypeUact[cobjTypeUact.length-1].sapqty = objElements[i].getAttribute('SAPQTY');
               cobjTypeUact[cobjTypeUact.length-1].reqplt = objElements[i].getAttribute('REQPLT');
               cobjTypeUact[cobjTypeUact.length-1].reqcas = objElements[i].getAttribute('REQCAS');
               cobjTypeUact[cobjTypeUact.length-1].reqpch = objElements[i].getAttribute('REQPCH');
               cobjTypeUact[cobjTypeUact.length-1].reqmix = objElements[i].getAttribute('REQMIX');
               cobjTypeUact[cobjTypeUact.length-1].reqton = objElements[i].getAttribute('REQTON');
               cobjTypeUact[cobjTypeUact.length-1].schplt = objElements[i].getAttribute('SCHPLT');
               cobjTypeUact[cobjTypeUact.length-1].schcas = objElements[i].getAttribute('SCHCAS');
               cobjTypeUact[cobjTypeUact.length-1].schpch = objElements[i].getAttribute('SCHPCH');
               cobjTypeUact[cobjTypeUact.length-1].schmix = objElements[i].getAttribute('SCHMIX');
               cobjTypeUact[cobjTypeUact.length-1].schton = objElements[i].getAttribute('SCHTON');
               cobjTypeUact[cobjTypeUact.length-1].schdur = objElements[i].getAttribute('SCHDUR');
            }
         }
         if (cstrActvMode == '*RTVSCH') {
            cobjTypeSchdCell = null;
            doTypeWindPaint(cintTypeLidx);
         }
         cobjTypeUactCell = null;
         if (cstrTypeTind == '0') {
            document.getElementById('datTypeUact').style.display = 'block';
         }
         doTypeUactPaint();
         if (cstrTypeTind == '0') {
            document.getElementById('datTypeUact').style.display = 'none';
         }
      }
   }
   function requestActvAttach() {
      cstrActvMode = '*RTVSCH';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+' <PSA_REQUEST ACTION="*ATTACT" SRCCDE="*SCH"';
      strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
      strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
      strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
      strXML = strXML+' LINCDE="'+fixXML(cstrTypeLcde)+'"';
      strXML = strXML+' CONCDE="'+fixXML(cstrTypeCcde)+'"';
      strXML = strXML+' WINCDE="'+fixXML(cstrTypeWcde)+'"';
      strXML = strXML+' WINSEQ="'+fixXML(cstrTypeWseq)+'"';
      strXML = strXML+' ACTCDE="'+fixXML(cstrTypeAcde)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_actv_attach.asp',function(strResponse) {checkActvResponse(strResponse);},false,streamXML(strXML));
   }
   function requestActvDetach() {
      cstrActvMode = '*RTVSCH';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+' <PSA_REQUEST ACTION="*DETACT" SRCCDE="*SCH"';
      strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
      strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
      strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
      strXML = strXML+' ACTCDE="'+fixXML(cstrTypeAcde)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_actv_detach.asp',function(strResponse) {checkActvResponse(strResponse);},false,streamXML(strXML));
   }
   function requestActvDelete() {
      cstrActvMode = '*RTVACT';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+' <PSA_REQUEST ACTION="*DLTACT" SRCCDE="*SCH"';
      strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
      strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
      strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
      strXML = strXML+' ACTCDE="'+fixXML(cstrTypeAcde)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_actv_delete.asp',function(strResponse) {checkActvResponse(strResponse);},false,streamXML(strXML));
   }
   function checkActvResponse(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         doActivityStop();
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
               doActivityStop();
               alert(strMessage);
               return;
            }
         }
         requestActvLoad();
      }
   }

   ////////////////////
   // Time Functions //
   ////////////////////
   var cstrTimeMode;
   function requestTimeAdd() {
      cstrTimeMode = '*CRT';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTACT" SRCCDE="*SCH" ACTCDE="'+fixXML(cstrTypeAcde)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_time_retrieve.asp',function(strResponse) {checkTimeLoad(strResponse);},false,streamXML(strXML));
   }
   function requestTimeUpdate() {
      cstrTimeMode = '*UPD';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDACT" SRCCDE="*SCH" ACTCDE="'+fixXML(cstrTypeAcde)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_time_retrieve.asp',function(strResponse) {checkTimeLoad(strResponse);},false,streamXML(strXML));
   }
   function checkTimeLoad(strResponse) {
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
         if (cstrTimeMode == '*UPD') {
            cobjScreens[7].hedtxt = 'Update Scheduled Time Activity';
            document.getElementById('addTime').style.display = 'none';
            document.getElementById('updTime').style.display = 'block';
         } else if (cstrTimeMode == '*CRT') {
            cobjScreens[7].hedtxt = 'Create Scheduled Time Activity';
            document.getElementById('addTime').style.display = 'block';
            document.getElementById('updTime').style.display = 'none';
         }
         displayScreen('dspTime');
         var strSacCode;
         var objSacCode;
         if (cstrTimeMode == '*CRT') {
            strSacCode = '';
            objSacCode = document.getElementById('TIM_SacCode');
            objSacCode.options.length = 0;
            objSacCode.options[0] = new Option('** Select Time Activity **','*NONE');
            objSacCode.selectedIndex = 0;
         } else {
            document.getElementById('TIM_UpdTime').innerHTML = '';
         }
         document.getElementById('TIM_DurMins').value = '0';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'ACTDFN') {
               if (cstrTimeMode == '*UPD') {
                  document.getElementById('TIM_UpdTime').innerHTML = '<p>'+'('+objElements[i].getAttribute('SACCDE')+') '+objElements[i].getAttribute('SACNAM')+'</p>';
               } else {
                  strSacCode = objElements[i].getAttribute('SACCDE');
               }
               document.getElementById('TIM_DurMins').value = objElements[i].getAttribute('DURMIN');
            } else if (objElements[i].nodeName == 'SACDFN') {
               if (cstrTimeMode == '*CRT') {
                  objSacCode.options[objSacCode.options.length] = new Option(objElements[i].getAttribute('SACNAM'),objElements[i].getAttribute('SACCDE'));
               }
            }
         }
         if (cstrTimeMode == '*CRT') {
            document.getElementById('TIM_SacCode').focus();
         } else {
            document.getElementById('TIM_DurMins').focus();
         }
      }
   }
   function doTimeCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspType');
      document.getElementById('hedType').innerText = cstrTypeHead;
   }
   function doTimeAccept() {
      if (!processForm()) {return;}
      var objSacCode;
      var strMessage = '';
      if (cstrTimeMode == '*CRT') {
         objSacCode = document.getElementById('TIM_SacCode');
         if (objSacCode.selectedIndex == -1 || objSacCode.options[objSacCode.selectedIndex].value == '*NONE') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Time activity must be selected';
         }
      }
      if (document.getElementById('TIM_DurMins').value == '' || document.getElementById('TIM_DurMins').value <= '0') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Duration minutes must be greater than zero';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrTimeMode == '*UPD') {
         strXML = strXML+' <PSA_REQUEST ACTION="*UPDACT" SRCCDE="*SCH"';
      } else {
         strXML = strXML+' <PSA_REQUEST ACTION="*CRTACT" SRCCDE="*SCH"';
      }
      strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
      strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
      strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
      strXML = strXML+' LINCDE="'+fixXML(cstrTypeLcde)+'"';
      strXML = strXML+' CONCDE="'+fixXML(cstrTypeCcde)+'"';
      strXML = strXML+' WINCDE="'+fixXML(cstrTypeWcde)+'"';
      strXML = strXML+' WINSEQ="'+fixXML(cstrTypeWseq)+'"';
      strXML = strXML+' ACTCDE="'+fixXML(cstrTypeAcde)+'"';
      if (cstrTimeMode == '*CRT') {
         strXML = strXML+' SACCDE="'+fixXML(objSacCode.options[objSacCode.selectedIndex].value)+'"';
      }
      strXML = strXML+' DURMIN="'+fixXML(document.getElementById('TIM_DurMins').value)+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestTimeAccept(\''+strXML+'\');',10);
   }
   function requestTimeAccept(strXML) {
      doPostRequest('<%=strBase%>psa_psc_time_update.asp',function(strResponse) {checkTimeAccept(strResponse);},false,streamXML(strXML));
   }
   function checkTimeAccept(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         doActivityStop();
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
               doActivityStop();
               alert(strMessage);
               return;
            }
         }
         cstrActvMode = '*RTVSCH';
         requestActvLoad();
      }
   }

   //////////////////////////
   // Production Functions //
   //////////////////////////
   var cstrProdMode;
   function requestProdAdd() {
      cstrProdMode = '*CRT';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTACT" SRCCDE="*SCH" ACTCDE="'+fixXML(cstrTypeAcde)+'"';
      strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
      strXML = strXML+' LINCDE="'+fixXML(cstrTypeLcde)+'"';
      strXML = strXML+' CONCDE="'+fixXML(cstrTypeCcde)+'"/>'
      doPostRequest('<%=strBase%>psa_psc_prod_retrieve.asp',function(strResponse) {checkProdLoad(strResponse);},false,streamXML(strXML));
   }
   function requestProdUpdate() {
      cstrProdMode = '*UPD';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDACT" SRCCDE="*SCH" ACTCDE="'+fixXML(cstrTypeAcde)+'"';
      strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
      strXML = strXML+' LINCDE="'+fixXML(cstrTypeLcde)+'"';
      strXML = strXML+' CONCDE="'+fixXML(cstrTypeCcde)+'"/>'
      doPostRequest('<%=strBase%>psa_psc_prod_retrieve.asp',function(strResponse) {checkProdLoad(strResponse);},false,streamXML(strXML));
   }
   function checkProdLoad(strResponse) {
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
         if (cstrProdMode == '*UPD') {
            if (cstrTypeCode == '*FILL') {
               cobjScreens[9].hedtxt = 'Update Scheduled Filling Activity';
               document.getElementById('wrkUProd').innerHTML = '&nbsp;Requested Cases:&nbsp;';
            } else if (cstrTypeCode == '*PACK') {
               cobjScreens[9].hedtxt = 'Update Scheduled Packing Activity';
               document.getElementById('wrkUProd').innerHTML = '&nbsp;Requested Cases:&nbsp;';
            } else if (cstrTypeCode == '*FORM') {
               cobjScreens[9].hedtxt = 'Update Scheduled Forming Activity';
               document.getElementById('wrkUProd').innerHTML = '&nbsp;Requested Pouches:&nbsp;';
            }
            displayScreen('dspUProd');
         } else if (cstrProdMode == '*CRT') {
            if (cstrTypeCode == '*FILL') {
               cobjScreens[8].hedtxt = 'Create Scheduled Filling Activity';
               document.getElementById('wrkCProd').innerHTML = '&nbsp;Requested Cases:&nbsp;';
            } else if (cstrTypeCode == '*PACK') {
               cobjScreens[8].hedtxt = 'Create Scheduled Packing Activity';
               document.getElementById('wrkCProd').innerHTML = '&nbsp;Requested Cases:&nbsp;';
            } else if (cstrTypeCode == '*FORM') {
               cobjScreens[8].hedtxt = 'Create Scheduled Forming Activity';
               document.getElementById('wrkCProd').innerHTML = '&nbsp;Requested Pouches:&nbsp;';
            }
            displayScreen('dspCProd');
         }
         var objMatData;
         var objChgFlag;
         var strChgFlag = '';
         if (cstrProdMode == '*UPD') {
            objChgFlag = document.getElementById('UPRD_ChgFlag');
            document.getElementById('UPRD_MatData').innerHTML = '';
            document.getElementById('UPRD_ReqData').innerHTML = '';
            document.getElementById('UPRD_SchData').innerHTML = '';
            document.getElementById('UPRD_ReqQnty').value = '0';
            document.getElementById('UPRD_ChgMins').value = '0';
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'ACTDFN') {
                  if (cstrTypeCode == '*FILL') {
                     document.getElementById('UPRD_MatData').innerHTML = '<p><font style="FONT-WEIGHT:bold">Material:</font> ('+objElements[i].getAttribute('MATCDE')+') '+objElements[i].getAttribute('MATNAM')+'</p>';
                     document.getElementById('UPRD_ReqData').innerHTML = '<p><font style="FONT-WEIGHT:bold">Requested Cases</font> ('+objElements[i].getAttribute('REQCAS')+') <font style="FONT-WEIGHT:bold">Pouches</font> ('+objElements[i].getAttribute('REQPCH')+') <font style="FONT-WEIGHT:bold">Mixes</font> ('+objElements[i].getAttribute('REQMIX')+') <font style="FONT-WEIGHT:bold">Tonnes</font> ('+objElements[i].getAttribute('REQTON')+')</p>';
                     document.getElementById('UPRD_SchData').innerHTML = '<p><font style="FONT-WEIGHT:bold">Scheduled Cases</font> ('+objElements[i].getAttribute('SCHCAS')+') <font style="FONT-WEIGHT:bold">Pouches</font> ('+objElements[i].getAttribute('SCHPCH')+') <font style="FONT-WEIGHT:bold">Mixes</font> ('+objElements[i].getAttribute('SCHMIX')+') <font style="FONT-WEIGHT:bold">Tonnes</font> ('+objElements[i].getAttribute('SCHTON')+')</p>';
                     document.getElementById('UPRD_ReqQnty').value = objElements[i].getAttribute('REQCAS');
                  } else if (cstrTypeCode == '*PACK') {
                     document.getElementById('UPRD_MatData').innerHTML = '<p><font style="FONT-WEIGHT:bold">Material:</font> ('+objElements[i].getAttribute('MATCDE')+') '+objElements[i].getAttribute('MATNAM')+'</p>';
                     document.getElementById('UPRD_ReqData').innerHTML = '<p><font style="FONT-WEIGHT:bold">Requested Cases</font> ('+objElements[i].getAttribute('REQCAS')+') <font style="FONT-WEIGHT:bold">Pallets</font> ('+objElements[i].getAttribute('REQPLT')+')</p>';
                     document.getElementById('UPRD_SchData').innerHTML = '<p><font style="FONT-WEIGHT:bold">Scheduled Cases</font> ('+objElements[i].getAttribute('SCHCAS')+') <font style="FONT-WEIGHT:bold">Pallets</font> ('+objElements[i].getAttribute('SCHPLT')+')</p>';
                     document.getElementById('UPRD_ReqQnty').value = objElements[i].getAttribute('REQCAS');
                  } else if (cstrTypeCode == '*FORM') {
                     document.getElementById('UPRD_MatData').innerHTML = '<p><font style="FONT-WEIGHT:bold">Material:</font> ('+objElements[i].getAttribute('MATCDE')+') '+objElements[i].getAttribute('MATNAM')+'</p>';
                     document.getElementById('UPRD_ReqData').innerHTML = '<p><font style="FONT-WEIGHT:bold">Requested Pouches</font> ('+objElements[i].getAttribute('REQPCH')+')</p>';
                     document.getElementById('UPRD_SchData').innerHTML = '<p><font style="FONT-WEIGHT:bold">Scheduled Pouches</font> ('+objElements[i].getAttribute('SCHPCH')+')</p>';
                     document.getElementById('UPRD_ReqQnty').value = objElements[i].getAttribute('REQPCH');
                  }
                  strChgFlag = objElements[i].getAttribute('CHGFLG');
                  document.getElementById('UPRD_ChgMins').value = objElements[i].getAttribute('CHGMIN');
               }
            }
            objChgFlag.selectedIndex = -1;
            for (var i=0;i<objChgFlag.length;i++) {
               if (objChgFlag.options[i].value == strChgFlag) {
                  objChgFlag.options[i].selected = true;
                  break;
               }
            }
            document.getElementById('UPRD_ReqQnty').focus();
         } else {
            objMatData = document.getElementById('CPRD_MatData');
            objMatData.options.length = 0;
            objMatData.options[0] = new Option('** Select Material **','*NONE');
            objMatData.selectedIndex = 0;
            objChgFlag = document.getElementById('CPRD_ChgFlag');
            document.getElementById('CPRD_ReqQnty').value = '0';
            document.getElementById('CPRD_ChgMins').value = '0';
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'ACTDFN') {
                  if (cstrTypeCode == '*FILL') {
                     document.getElementById('CPRD_ReqQnty').value = objElements[i].getAttribute('REQCAS');
                  } else if (cstrTypeCode == '*PACK') {
                     document.getElementById('CPRD_ReqQnty').value = objElements[i].getAttribute('REQCAS');
                  } else if (cstrTypeCode == '*FORM') {
                     document.getElementById('CPRD_ReqQnty').value = objElements[i].getAttribute('REQPCH');
                  }
                  strChgFlag = objElements[i].getAttribute('CHGFLG');
                  document.getElementById('CPRD_ChgMins').value = objElements[i].getAttribute('CHGMIN');
               } else if (objElements[i].nodeName == 'MATDFN') {
                  objMatData.options[objMatData.options.length] = new Option('('+objElements[i].getAttribute('MATCDE')+') '+objElements[i].getAttribute('MATNAM'),objElements[i].getAttribute('MATCDE'));
               }
            }
            objChgFlag.selectedIndex = -1;
            for (var i=0;i<objChgFlag.length;i++) {
               if (objChgFlag.options[i].value == strChgFlag) {
                  objChgFlag.options[i].selected = true;
                  break;
               }
            }
            document.getElementById('CPRD_MatData').focus();
         }
      }
   }
   function doProdCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspType');
      document.getElementById('hedType').innerText = cstrTypeHead;
   }
   function doProdAccept() {
      if (!processForm()) {return;}
      var objMatData;
      var objChgFlag;
      var strMessage = '';
      if (cstrProdMode == '*UPD') {
         objChgFlag = document.getElementById('UPRD_ChgFlag');
         if (document.getElementById('UPRD_ReqQnty').value == '' || document.getElementById('UPRD_ReqQnty').value <= '0') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            if (cstrTypeCode == '*FILL') {
               strMessage = strMessage + 'Requested cases must be greater than zero';
            } else if (cstrTypeCode == '*PACK') {
               strMessage = strMessage + 'Requested cases must be greater than zero';
            } else if (cstrTypeCode == '*FORM') {
               strMessage = strMessage + 'Requested pouches must be greater than zero';
            }
         }
         if (objChgFlag.selectedIndex == -1) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Material change time must be selected';
         }
         if (objChgFlag.options[objChgFlag.selectedIndex].value == '0') {
            if (document.getElementById('UPRD_ChgMins').value != '' && document.getElementById('UPRD_ChgMins').value != '0') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Material change minutes must be zero';
            }
         } else {
            if (document.getElementById('UPRD_ChgMins').value == '' || document.getElementById('UPRD_ChgMins').value <= '0') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Material change minutes must be greater than zero';
            }
         }
      } else {
         objMatData = document.getElementById('CPRD_MatData');
         objChgFlag = document.getElementById('CPRD_ChgFlag');
         if (objMatData.selectedIndex == -1 || objMatData.options[objMatData.selectedIndex].value == '*NONE') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Material must be selected';
         }
         if (document.getElementById('CPRD_ReqQnty').value == '' || document.getElementById('CPRD_ReqQnty').value <= '0') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            if (cstrTypeCode == '*FILL') {
               strMessage = strMessage + 'Requested cases must be greater than zero';
            } else if (cstrTypeCode == '*PACK') {
               strMessage = strMessage + 'Requested cases must be greater than zero';
            } else if (cstrTypeCode == '*FORM') {
               strMessage = strMessage + 'Requested pouches must be greater than zero';
            }
         }
         if (objChgFlag.selectedIndex == -1) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Material change time must be selected';
         }
         if (objChgFlag.options[objChgFlag.selectedIndex].value == '0') {
            if (document.getElementById('CPRD_ChgMins').value != '' && document.getElementById('CPRD_ChgMins').value != '0') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Material change minutes must be zero';
            }
         } else {
            if (document.getElementById('CPRD_ChgMins').value == '' || document.getElementById('CPRD_ChgMins').value <= '0') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Material change minutes must be greater than zero';
            }
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrProdMode == '*UPD') {
         strXML = strXML+' <PSA_REQUEST ACTION="*UPDACT" SRCCDE="*SCH"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
         strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
         strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
         strXML = strXML+' LINCDE="'+fixXML(cstrTypeLcde)+'"';
         strXML = strXML+' CONCDE="'+fixXML(cstrTypeCcde)+'"';
         strXML = strXML+' WINCDE="'+fixXML(cstrTypeWcde)+'"';
         strXML = strXML+' WINSEQ="'+fixXML(cstrTypeWseq)+'"';
         strXML = strXML+' ACTCDE="'+fixXML(cstrTypeAcde)+'"';
         strXML = strXML+' REQQTY="'+fixXML(document.getElementById('UPRD_ReqQnty').value)+'"';
         strXML = strXML+' CHGFLG="'+fixXML(objChgFlag.options[objChgFlag.selectedIndex].value)+'"';
         strXML = strXML+' CHGMIN="'+fixXML(document.getElementById('UPRD_ChgMins').value)+'"';
         strXML = strXML+'/>';
      } else {
         strXML = strXML+' <PSA_REQUEST ACTION="*CRTACT" SRCCDE="*SCH"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrTypeProd)+'"';
         strXML = strXML+' WEKCDE="'+fixXML(cstrTypeWeek)+'"';
         strXML = strXML+' PTYCDE="'+fixXML(cstrTypeCode)+'"';
         strXML = strXML+' LINCDE="'+fixXML(cstrTypeLcde)+'"';
         strXML = strXML+' CONCDE="'+fixXML(cstrTypeCcde)+'"';
         strXML = strXML+' WINCDE="'+fixXML(cstrTypeWcde)+'"';
         strXML = strXML+' WINSEQ="'+fixXML(cstrTypeWseq)+'"';
         strXML = strXML+' ACTCDE="'+fixXML(cstrTypeAcde)+'"';
         strXML = strXML+' MATCDE="'+fixXML(objMatData.options[objMatData.selectedIndex].value)+'"';
         strXML = strXML+' REQQTY="'+fixXML(document.getElementById('CPRD_ReqQnty').value)+'"';
         strXML = strXML+' CHGFLG="'+fixXML(objChgFlag.options[objChgFlag.selectedIndex].value)+'"';
         strXML = strXML+' CHGMIN="'+fixXML(document.getElementById('CPRD_ChgMins').value)+'"';
         strXML = strXML+'/>';
      }
      doActivityStart(document.body);
      window.setTimeout('requestProdAccept(\''+strXML+'\');',10);
   }
   function requestProdAccept(strXML) {
      doPostRequest('<%=strBase%>psa_psc_prod_update.asp',function(strResponse) {checkProdAccept(strResponse);},false,streamXML(strXML));
   }
   function checkProdAccept(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         doActivityStop();
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
               doActivityStop();
               alert(strMessage);
               return;
            }
         }
         cstrActvMode = '*RTVSCH';
         requestActvLoad();
      }
   }

// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<!--#include file="ics_std_report.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body id="dspBody" class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('psa_psc_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspSelect" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSelect" class="clsFunction" align=center colspan=2 nowrap><nobr>Production Schedule Selection</nobr></td>
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
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Create Production Schedule</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Production Schedule Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_PscCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr id="updDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align="right" valign="center" colspan="1" nowrap><nobr>&nbsp;Production Schedule Code:&nbsp;</nobr></td>
         <td id="DEF_UpdCode" class="clsLabelBB" align="left" valign="center" colspan="1" nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Production Schedule Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_PscName" size="80" maxlength="120" value="" onFocus="setSelect(this);">
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
   <table id="dspWeeks" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedWeeks" class="clsFunction" align=center colspan=2 nowrap><nobr>Production Schedule Week Selection</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=2 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doWeekBack();">&nbsp;Back&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doWeekRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doWeekCreate();">&nbsp;Create&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHeadWeeks">
                     <table class="clsTableHead" id="tabHeadWeeks" align=left cols=1 cellpadding="0" cellspacing="1">
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBodyWeeks">
                     <table class="clsTableBody" id="tabBodyWeeks" align=left cols=1 cellpadding="0" cellspacing="1"></table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspWeekd" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=1 cellspacing=1 cellpadding=0>
      <tr><td align=center colspan=1 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedWeekd" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Maintenance - Week Definition</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Production Requirements:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="WEK_PscPreq"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table id="WEK_PscType" class="clsGrid02" align=center valign=top cols=1 cellpadding=0 cellspacing=1></table>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doWeekCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doWeekAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspType" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedType" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Maintenance</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=left colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=6 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeBack();">&nbsp;Back&nbsp;</a></nobr></td>
                  <td class="clsTabB" style="font-size:8pt" align=center colspan=1 nowrap><nobr>&nbsp;Reporting&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeSchdReport();">&nbsp;Schedule&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeShftReport();">&nbsp;Shift&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeResoReport();">&nbsp;Resource&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeProdReport();">&nbsp;Production&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=left colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=16 cellpadding="0" cellspacing="0">
               <tr>
                  <td class="clsTabB" style="font-size:8pt" align=center colspan=1 nowrap><nobr>&nbsp;Stock&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeStckUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td class="clsTabB" style="font-size:8pt" align=center colspan=1 nowrap><nobr>&nbsp;Line&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeLineAdd();">&nbsp;Add&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeLineUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeLineDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
                  <td id="typPulse" class="clsTabB" style="font-size:8pt" align=center colspan=1 nowrap><nobr>&nbsp;Schedule&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeSchdRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeSchdUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeSchdTime();">&nbsp;Add Time&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeSchdProd();">&nbsp;Add Production&nbsp;</a></nobr></td>
                  <td class="clsTabB" style="font-size:8pt" align=center colspan=1 nowrap><nobr>&nbsp;Activities&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeUactToggle();">&nbsp;Show/Hide&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeUactDetach();">&nbsp;Detach&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeUactAttach();">&nbsp;Attach&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeUactDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td id="datTypeSchd" align=center colspan=1 width=100% nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center width=100% colspan=1 nowrap><nobr>
                     <div id="conHeadSchd" style="width:100%;overflow:hidden;background-color:#40414c;border:#40414c 1px solid;">
                     <table class="clsPanel" id="tabHeadSchd" style="background-color:#f7f7f7;border-collapse:collapse;border:none;" align=left cols=1 cellpadding="0" cellspacing="0">
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center width=100% colspan=1 nowrap><nobr>
                     <div id="conBodySchd" style="width:100%;height:100%;overflow:scroll;background-color:#ffffff;border:#40414c 1px solid;">
                     <table class="clsPanel" id="tabBodySchd" style="background-color:transparent;border-collapse:collapse;border:none;" align=left cols=1 cellpadding="0" cellspacing="0"></table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
         <td id="datTypeUact" align=center width=25% colspan=1 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr height=100%>
                  <td align=center width=100% colspan=1 nowrap><nobr>
                     <div id="conBodyUact" style="width:100%;height:100%;overflow:scroll;background-color:#ffffff;border:#40414c 1px solid;">
                     <table class="clsPanel" id="tabBodyUact" style="background-color:transparent;border-collapse:collapse;border:none;" align=left cols=1 cellpadding="0" cellspacing="2"></table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspLine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=1 cellspacing=1 cellpadding=0>
      <tr><td align=center colspan=1 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedLine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Update Line Configuration</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addLine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Line Configuration:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="LIN_LinList" onChange="doLineLconChange(this);"></select>
         </nobr></td>
      </tr>
      <tr id="updLine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Line Configuration:&nbsp;</nobr></td>
         <td id="LIN_UpdLine" class="clsLabelBB" align="left" valign="center" colspan="1" nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Shift Model:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="LIN_SmoList" onChange="doLineSmodChange(this,false);"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table id="LIN_LinData" class="clsGrid02" align=center valign=top cols=1 cellpadding=0 cellspacing=1></table>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doLineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doLineAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspTime" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=1 cellspacing=1 cellpadding=0>
      <tr><td align=center colspan=1 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedTime" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Create Scheduled Time Activity</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addTime">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Time Activity:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="TIM_SacCode"></select>
         </nobr></td>
      </tr>
      <tr id="updTime">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Time Activity:&nbsp;</nobr></td>
         <td id="TIM_UpdTime" class="clsLabelBB" align="left" valign="center" colspan="1" nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Duration Minutes:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="TIM_DurMins" size="7" maxlength="7" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTimeCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTimeAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspCProd" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=1 cellspacing=1 cellpadding=0>
      <tr><td align=center colspan=1 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedCProd" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Create Production Activity</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Material:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="CPRD_MatData"></select>
         </nobr></td>
      </tr>
      <tr>
         <td id="wrkCProd" class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Requested Cases:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="CPRD_ReqQnty" size="9" maxlength="9" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Material Change Time:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="CPRD_ChgFlag">
               <option value="0">No
               <option value="1">Yes
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Material Change Minutes:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="CPRD_ChgMins" size="7" maxlength="7" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doProdCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doProdAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspUProd" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=1 cellspacing=1 cellpadding=0>
      <tr><td align=center colspan=1 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedUProd" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Update Production Activity</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td id="UPRD_MatData" class="clsLabelBN" align=center valign=center colspan=2 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td id="UPRD_ReqData" class="clsLabelBN" align=center valign=center colspan=2 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td id="UPRD_SchData" class="clsLabelBN" align=center valign=center colspan=2 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td id="wrkUProd" class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Requested Cases:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="UPRD_ReqQnty" size="9" maxlength="9" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Material Change Time:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="UPRD_ChgFlag">
               <option value="0">No
               <option value="1">Yes
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Material Change Minutes:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="UPRD_ChgMins" size="7" maxlength="7" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doProdCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doProdAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->