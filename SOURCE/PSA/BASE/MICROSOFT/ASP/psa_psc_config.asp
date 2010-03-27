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
      cobjScreens[6] = new clsScreen('dspEvnt','hedEvnt');
      cobjScreens[7] = new clsScreen('dspFill','hedFill');
      cobjScreens[8] = new clsScreen('dspPack','hedPack');
      cobjScreens[9] = new clsScreen('dspForm','hedForm');
      cobjScreens[0].hedtxt = '**LOADING**';
      cobjScreens[1].hedtxt = 'Production Schedule Selection';
      cobjScreens[2].hedtxt = 'Production Schedule Definition';
      cobjScreens[3].hedtxt = 'Production Schedule Maintenance - Week Selection';
      cobjScreens[4].hedtxt = 'Production Schedule Maintenance - Week Definition';
      cobjScreens[5].hedtxt = 'Production Schedule Maintenance';
      cobjScreens[6].hedtxt = 'Production Schedule Maintenance - Event Activity';
      cobjScreens[7].hedtxt = 'Production Schedule Maintenance - Filling Activity';
      cobjScreens[8].hedtxt = 'Production Schedule Maintenance - Packing Activity';
      cobjScreens[9].hedtxt = 'Production Schedule Maintenance - Forming Activity';
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="'+strAction+'" STRCDE="'+cstrSelectStrCode+'" ENDCDE="'+cstrSelectEndCode+'"/>';
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
                  cstrSelectStrCode = objElements[i].getAttribute('PSCCDE');
               }
               cstrSelectEndCode = objElements[i].getAttribute('PSCCDE');
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doSelectUpdate(\''+objElements[i].getAttribute('PSCCDE')+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectDelete(\''+objElements[i].getAttribute('PSCCDE')+'\');">Delete</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectCopy(\''+objElements[i].getAttribute('PSCCDE')+'\');">Copy</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectWeek(\''+objElements[i].getAttribute('PSCCDE')+'\');">Weeks</a>&nbsp;';
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
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('PSCSTS')+'&nbsp;';
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*DLTDEF" PSCCDE="'+fixXML(strCode)+'"/>';
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

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDDEF" PSCCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTDEF" PSCCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CPYDEF" PSCCDE="'+fixXML(strCode)+'"/>';
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
            document.getElementById('DEF_pscCode').focus();
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrDefineMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDDEF"';
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
      this.smocde = '*NONE';
      this.reqidx = 0;
      this.smoidx = 0;
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
      this.shfary = new Array();
      this.lcoary = new Array();
   }
   function clsWeekCmod() {
      this.cmocde = '';
      this.cmonam = '';
   }
   function clsWeekPshf() {
      this.smoseq = '';
      this.cmocde = '';
   }
   function clsWeekLcod() {
      this.lincde = '';
      this.linnam = '';
      this.lcocde = '';
      this.lconam = '';
      this.lcousd = '0';
      this.filnam = '';
   }
   function requestWeekList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*WEKLST" PSCCDE="'+fixXML(cstrWeekProd)+'"/>';
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
               if (objElements[i].getAttribute('SLTSTS') == '0') {
                  objCell.innerHTML = '&nbsp;';
               } else {
                  if (objElements[i].getAttribute('SLTTYP') == '*WEEK') {
                     objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doWeekUpdate(\''+objElements[i].getAttribute('SLTCDE')+'\');">Update</a>&nbsp;';
                  } else {
                     objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doTypeUpdate(\''+objElements[i].getAttribute('SLTWEK')+'\',\''+objElements[i].getAttribute('SLTCDE')+'\');">Update</a>&nbsp;';
                  }
               }
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('SLTTXT')+'&nbsp;';
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
      doActivityStart(document.body);
      window.setTimeout('requestTypeLoad(\''+strCode+'\');',10);
   }
   function doWeekRefresh() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestWeekList();',10);
   }
   function requestWeekCreate(strCode) {
      cstrWeekMode = '*CRT';
      cstrWeekCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTWEK" PSCCDE="'+fixXML(cstrWeekProd)+'" WEKCDE="'+fixXML(cstrWeekCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_week_retrieve.asp',function(strResponse) {checkWeekLoad(strResponse);},false,streamXML(strXML));
   }
   function requestWeekUpdate(strCode) {
      cstrWeekMode = '*UPD';
      cstrWeekCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDWEK" PSCCDE="'+fixXML(cstrWeekProd)+'" WEKCDE="'+fixXML(cstrWeekCode)+'"/>';
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
            cobjScreens[4].hedtxt = 'Update Production Schedule Week';
         } else if (cstrWeekMode == '*CRT') {
            cobjScreens[4].hedtxt = 'Create Production Schedule Week';
         }
         displayScreen('dspWeekd');
         cobjWeekData = new clsWeekData();
         cobjWeekSmod = new Array();
         cobjWeekPtyp = new Array();
         var objArray;
         var objPscPreq = document.getElementById('WEK_PscPreq');
         objPscPreq.options.length = 0;
         objPscPreq.options[0] = new Option('** Select Production Requirements **','*NONE');
         objPscPreq.selectedIndex = 0;
         var objPscSmod = document.getElementById('WEK_PscSmod');
         objPscSmod.options.length = 0;
         objPscSmod.options[0] = new Option('** Select Shift Model **','*NONE');
         objPscSmod.selectedIndex = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'WEKDFN') {
               cstrWeekCode = objElements[i].getAttribute('WEKCDE');
               document.getElementById('hedWeekd').innerText = cobjScreens[4].hedtxt+' - '+objElements[i].getAttribute('WEKNAM');
               cobjWeekData.wekcde = objElements[i].getAttribute('WEKCDE');
               cobjWeekData.weknam = objElements[i].getAttribute('WEKNAM');
               cobjWeekData.reqcde = objElements[i].getAttribute('REQCDE');
               cobjWeekData.smocde = objElements[i].getAttribute('SMOCDE');
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
               objPscSmod.options[objPscSmod.options.length] = new Option('('+objElements[i].getAttribute('SMOCDE')+') '+objElements[i].getAttribute('SMONAM'),objElements[i].getAttribute('SMOCDE'));
               objPscSmod.options[objPscSmod.options.length-1].setAttribute('smoidx',cobjWeekSmod.length-1);
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
            } else if (objElements[i].nodeName == 'SHFLNK') {
               objArray = cobjWeekPtyp[cobjWeekPtyp.length-1].shfary;
               objArray[objArray.length] = new clsWeekPshf();
               objArray[objArray.length-1].smoseq = objElements[i].getAttribute('SMOSEQ');
               objArray[objArray.length-1].cmocde = objElements[i].getAttribute('CMOCDE');
            } else if (objElements[i].nodeName == 'LCODFN') {
               objArray = cobjWeekPtyp[cobjWeekPtyp.length-1].lcoary;
               objArray[objArray.length] = new clsWeekLcod();
               objArray[objArray.length-1].lincde = objElements[i].getAttribute('LINCDE');
               objArray[objArray.length-1].linnam = objElements[i].getAttribute('LINNAM');
               objArray[objArray.length-1].lcocde = objElements[i].getAttribute('LCOCDE');
               objArray[objArray.length-1].lconam = objElements[i].getAttribute('LCONAM');
               objArray[objArray.length-1].lcousd = objElements[i].getAttribute('LCOUSD');
               objArray[objArray.length-1].filnam = objElements[i].getAttribute('FILNAM');
            }
         }
         for (var i=0;i<objPscPreq.length;i++) {
            if (objPscPreq.options[i].value == cobjWeekData.reqcde) {
               objPscPreq.options[i].selected = true;
               break;
            }
         }
         for (var i=0;i<objPscSmod.length;i++) {
            if (objPscSmod.options[i].value == cobjWeekData.smocde) {
               objPscSmod.options[i].selected = true;
               break;
            }
         }
         document.getElementById('WEK_PscPreq').focus();
         doWeekSmodChange(objPscSmod,true);
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
      var objEleShft;
      var objEleLine;
      var bolPtypFound;
      var bolShftFound;
      var bolLineFound;
      var objPscPreq = document.getElementById('WEK_PscPreq');
      var objPscSmod = document.getElementById('WEK_PscSmod');
      var strMessage = '';
      if (objPscPreq.selectedIndex == -1 || objPscPreq.options[objPscPreq.selectedIndex].value == '*NONE') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Production requirements must be selected';
      }
      if (objPscSmod.selectedIndex == -1 || objPscSmod.options[objPscSmod.selectedIndex].value == '*NONE') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Shift model must be selected';
      } else {
         bolPtypFound = false;
         for (var i=0;i<cobjWeekPtyp.length;i++) {
            objElePtyp = document.getElementById('WEKPTY_'+i);
            if (objElePtyp.checked == true) {
               bolPtypFound = true;
               bolShftFound = false;
               objShfAry = cobjWeekSmod[cobjWeekData.smoidx].shfary;
               for (var j=0;j<objShfAry.length;j++) {
                  objEleShft = document.getElementById('WEKPTYCMODDATA_'+i+'_'+j);
                  if (objEleShft.selectedIndex != -1 && objEleShft.options[objEleShft.selectedIndex].value != '*NONE') {
                     bolShftFound = true;
                  }
               }
               if (bolShftFound == false) {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + 'At least one shift must have a crew model selected for the selected production type ('+cobjWeekPtyp[i].ptynam+')';
               }
               bolLineFound = false;
               objLcoAry = cobjWeekPtyp[i].lcoary;
               for (var j=0;j<objLcoAry.length;j++) {
                  objEleLine = document.getElementById('WEKPTYLCONDATA_'+i+'_'+j);
                  if (objEleLine.checked == true) {
                     bolLineFound = true;
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
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrWeekMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDWEK"';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTWEK"';
      }
      strXML = strXML+' PSCCDE="'+fixXML(cstrWeekProd)+'"';
      strXML = strXML+' WEKCDE="'+fixXML(cobjWeekData.wekcde)+'"';
      strXML = strXML+' REQCDE="'+fixXML(objPscPreq.options[objPscPreq.selectedIndex].value)+'"';
      strXML = strXML+' SMOCDE="'+fixXML(objPscSmod.options[objPscSmod.selectedIndex].value)+'">';
      for (var i=0;i<cobjWeekPtyp.length;i++) {
         objElePtyp = document.getElementById('WEKPTY_'+i);
         if (objElePtyp.checked == true) {
            strXML = strXML+'<PSCPTY PTYCDE="'+fixXML(cobjWeekPtyp[i].ptycde)+'">';
            objShfAry = cobjWeekSmod[cobjWeekData.smoidx].shfary;
            for (var j=0;j<objShfAry.length;j++) {
               objEleShft = document.getElementById('WEKPTYCMODDATA_'+i+'_'+j);
               if (objEleShft.selectedIndex == -1) {
                  strXML = strXML+'<PSCSHF SHFCDE="'+fixXML(objShfAry[j].shfcde)+'" SHFSTR="'+fixXML(objShfAry[j].shfstr)+'" SHFDUR="'+fixXML(objShfAry[j].shfdur)+'" CMOCDE="'+fixXML('*NONE')+'"/>';
               } else {
                  strXML = strXML+'<PSCSHF SHFCDE="'+fixXML(objShfAry[j].shfcde)+'" SHFSTR="'+fixXML(objShfAry[j].shfstr)+'" SHFDUR="'+fixXML(objShfAry[j].shfdur)+'" CMOCDE="'+fixXML(objEleShft.options[objEleShft.selectedIndex].value)+'"/>';
               }
            }
            objLcoAry = cobjWeekPtyp[i].lcoary;
            for (var j=0;j<objLcoAry.length;j++) {
               objEleLine = document.getElementById('WEKPTYLCONDATA_'+i+'_'+j);
               if (objEleLine.checked == true) {
                  strXML = strXML+'<PSCLCO LINCDE="'+fixXML(objLcoAry[j].lincde)+'" LCOCDE="'+fixXML(objLcoAry[j].lcocde)+'"/>';
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
         var objPscType = document.getElementById('WEK_PscType');
         for (var i=objPscType.rows.length-1;i>=0;i--) {
            objPscType.deleteRow(i);
         }
         doWeekRefresh();
      }
   }
   function doWeekSmodChange(objSelect, bolLoad) {
      if (objSelect.selectedIndex == -1) {
         return;
      }
      var objPscType = document.getElementById('WEK_PscType');
      for (var i=objPscType.rows.length-1;i>=0;i--) {
         objPscType.deleteRow(i);
      }
      cobjWeekData.smoidx = objSelect.options[objSelect.selectedIndex].getAttribute('smoidx');
      if (objSelect.options[objSelect.selectedIndex].value == '*NONE') {
         return;
      }
      var objTable;
      var objRow;
      var objCell;
      var objInput;
      var objSelect;
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
         if (bolLoad == true && cobjWeekPtyp[i].ptyusd == '1') {
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
         objCell.className = 'clsLabelBN';
         objCell.style.whiteSpace = 'nowrap';
         doWeekSmodLoad(objCell,i,cobjWeekData.smoidx,bolLoad);
         objRow = objTable.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBB';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         doWeekLconLoad(objCell,i,bolLoad);
         if (bolLoad == true) {
            doWeekPtypClick(objInput);
         }
      }
   }
   function doWeekSmodLoad(objParent, intPtyIdx, intSmoIdx, bolLoad) {
      var objTable = document.createElement('table');
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
      objTable.id = 'WEKPTYCMOD_'+intPtyIdx;
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
      objWrkAry = cobjWeekPtyp[intPtyIdx].shfary;
      objShfAry = cobjWeekSmod[intSmoIdx].shfary;
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
         objSelect.id = 'WEKPTYCMODDATA_'+intPtyIdx+'_'+i;
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
   function doWeekLconLoad(objParent, intPtyIdx, bolLoad) {
      var objTable = document.createElement('table');
      var objRow;
      var objCell;
      var objInput;
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
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objInput = document.createElement('input');
         objInput.type = 'checkbox';
         objInput.value = '';
         objInput.id = 'WEKPTYLCONDATA_'+intPtyIdx+'_'+i;
         objInput.onfocus = function() {setSelect(this);};
         objInput.checked = false;
         objCell.appendChild(objInput);
         if (objLcoAry[i].filnam != '' && objLcoAry[i].filnam != null) {
            objCell.appendChild(document.createTextNode('('+objLcoAry[i].lincde+') '+objLcoAry[i].linnam+' - ('+objLcoAry[i].lcocde+') '+objLcoAry[i].lconam+' - '+objLcoAry[i].filnam));
         } else {
            objCell.appendChild(document.createTextNode('('+objLcoAry[i].lincde+') '+objLcoAry[i].linnam+' - ('+objLcoAry[i].lcocde+') '+objLcoAry[i].lconam));
         }
         if (bolLoad == true && objLcoAry[i].lcousd == '1') {
            objInput.checked = true;
         }
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
   var cstrTypeProd;
   var cstrTypeWeek;
   var cstrTypeCode;
   var cobjTypeCell;
   var cintTypeIndx;
   var cstrTypeType;
   var cobjTypeDate = new Array();
   var cobjTypeShft = new Array();
   var cobjTypeLine = new Array();
   function clsTypeDate() {
      this.daycde = '';
      this.daynam = '';
   }
   function clsTypeShft() {
      this.shfcde = '';
      this.shfnam = '';
      this.shfstr = '';
      this.shfdur = '';
      this.cmocde = '';
      this.barstr = 0;
      this.barend = 0;
   }
   function clsTypeLine() {
      this.lincde = '';
      this.linnam = '';
      this.lcocde = '';
      this.lconam = '';
      this.filnam = '';
      this.actary = new Array();
   }
   function requestTypeLoad(strCode) {
      cstrTypeCode = strCode;
      cobjTypeCell = null;
      cintTypeIndx = -1;
      cstrTypeType = '*NONE';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*GETTYP" PSCCDE="'+fixXML(cstrTypeProd)+'" WEKCDE="'+fixXML(cstrTypeWeek)+'" PTYCDE="'+fixXML(cstrTypeCode)+'"/>';
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
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PTYDFN') {
               document.getElementById('hedType').innerText = cobjScreens[5].hedtxt+' - '+objElements[i].getAttribute('PTYNAM')+' - '+objElements[i].getAttribute('WEKNAM');
            } else if (objElements[i].nodeName == 'DAYDFN') {
               cobjTypeDate[cobjTypeDate.length] = new clsTypeDate();
               cobjTypeDate[cobjTypeDate.length-1].daycde = objElements[i].getAttribute('DAYCDE');
               cobjTypeDate[cobjTypeDate.length-1].daynam = objElements[i].getAttribute('DAYNAM');
            } else if (objElements[i].nodeName == 'SHFDFN') {
               cobjTypeShft[cobjTypeShft.length] = new clsTypeShft();
               cobjTypeShft[cobjTypeShft.length-1].smoseq = objElements[i].getAttribute('SMOSEQ');
               cobjTypeShft[cobjTypeShft.length-1].shfcde = objElements[i].getAttribute('SHFCDE');
               cobjTypeShft[cobjTypeShft.length-1].shfnam = objElements[i].getAttribute('SHFNAM');
               cobjTypeShft[cobjTypeShft.length-1].shfstr = objElements[i].getAttribute('SHFSTR');
               cobjTypeShft[cobjTypeShft.length-1].shfdur = objElements[i].getAttribute('SHFDUR');
               cobjTypeShft[cobjTypeShft.length-1].cmocde = objElements[i].getAttribute('CMOCDE');
            } else if (objElements[i].nodeName == 'LINDFN') {
               cobjTypeLine[cobjTypeLine.length] = new clsTypeLine();
               cobjTypeLine[cobjTypeLine.length-1].lincde = objElements[i].getAttribute('LINCDE');
               cobjTypeLine[cobjTypeLine.length-1].linnam = objElements[i].getAttribute('LINNAM');
               cobjTypeLine[cobjTypeLine.length-1].lcocde = objElements[i].getAttribute('LCOCDE');
               cobjTypeLine[cobjTypeLine.length-1].lconam = objElements[i].getAttribute('LCONAM');
               cobjTypeLine[cobjTypeLine.length-1].filnam = objElements[i].getAttribute('FILNAM');
            }
         }
         doTypePaint();
      }
   }
   function doTypeSelect(objSelect) {
      if (cobTypeCell != null) {
         if (cobjTypeCell.className == 'clsFloCntx') {
            cobjTypeCell.className = 'clsFloCntl';
         } else if (cobjTypeCell.className == 'clsFloNodx') {
            cobjTypeCell.className = 'clsFloNode';
         }
      }
      cobjTypeCell = objSelect;
      cintTypeIndx = objSelect.getAttribute('schidx');
      cstrTypeType = objSelect.getAttribute('schtyp');
      if (cobjTypeCell.className == 'clsFloCntl') {
         cobjTypeCell.className = 'clsFloCntx';
      } else if (cobjTypeCell.className == 'clsFloNode') {
         cobjTypeCell.className = 'clsFloNodx';
      }
   }
   function doTypePaint() {
      var objTable;
      var objRow;
      var objCell;
      var strTime;
      var intBarCnt;
      var intWrkCnt;
      var bolStrDay;

     // for (var i=0;i<cobjTypeLine.length;i++) {

         for (var j=0;j<cobjTypeShft.length;j++) {
            intBarCnt = (cobjTypeShft[j].shfdur / 60) * 4;
            if (j == 0) {
               cobjTypeShft[j].barstr = ((Math.floor(cobjTypeShft[j].shfstr / 100) + ((cobjTypeShft[j].shfstr % 100) / 60)) * 4) + 1;
               cobjTypeShft[j].barend = cobjTypeShft[j].barstr + intBarCnt - 1;
            } else {
               cobjTypeShft[j].barstr = cobjTypeShft[j-1].barend + 1;
               cobjTypeShft[j].barend = cobjTypeShft[j].barstr + intBarCnt - 1;
            }
         }

     // }

      var objTypHead = document.getElementById('tabHeadType');
      var objTypBody = document.getElementById('tabBodyType');
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
         objCell.style.backgroundColor = '#04aa04';
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
         objCell.style.backgroundColor = '#40414c';
         objCell.style.color = '#ffffff';
         objCell.style.border = '#c0c0c0 1px solid';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         if (cobjTypeLine[i].filnam != '' && cobjTypeLine[i].filnam != null) {
            objCell.appendChild(document.createTextNode('('+cobjTypeLine[i].lincde+') '+cobjTypeLine[i].linnam+' - ('+cobjTypeLine[i].lcocde+') '+cobjTypeLine[i].lconam+' - '+cobjTypeLine[i].filnam));
         } else {
            objCell.appendChild(document.createTextNode('('+cobjTypeLine[i].lincde+') '+cobjTypeLine[i].linnam+' - ('+cobjTypeLine[i].lcocde+') '+cobjTypeLine[i].lconam));
         }

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
               objCell.style.backgroundColor = '#ffffc0';
            } else {
               objCell.style.fontWeight = 'normal';
               objCell.style.backgroundColor = '#ffffe0';
            }
            objCell.style.color = '#000000';
            objCell.style.border = '#000000 1px solid';
            objCell.style.paddingLeft = '2px';
            objCell.style.paddingRight = '2px';
            objCell.appendChild(document.createTextNode(cobjTypeDate[i].daynam));
            objCell.appendChild(document.createElement('br'));
            objCell.appendChild(document.createTextNode(cobjTypeDate[i].daycde));
            bolStrDay = false;
            doTypePaintTime(objRow, strTime, '00', intWrkCnt);

            objRow = objTypBody.insertRow(-1);
            intWrkCnt++;
            doTypePaintTime(objRow, strTime, '15', intWrkCnt);

            objRow = objTypBody.insertRow(-1);
            intWrkCnt++;
            doTypePaintTime(objRow, strTime, '30', intWrkCnt);

            objRow = objTypBody.insertRow(-1);
            intWrkCnt++;
            doTypePaintTime(objRow, strTime, '45', intWrkCnt);

         }

      }

      if (objTypBody.rows.length == 0) {
         setScrollable('HeadType','BodyType','horizontal');
         objTypHead.rows(0).cells[objTypHead.rows(0).cells.length-1].style.width = 16;
         objTypHead.style.tableLayout = 'auto';
         objTypBody.style.tableLayout = 'auto';
      } else {
         setScrollable('HeadType','BodyType','horizontal');
         objTypHead.rows(0).cells[objTypHead.rows(0).cells.length-1].style.width = 16;
         objTypHead.style.tableLayout = 'fixed';
         objTypBody.style.tableLayout = 'fixed';
      }

   }

   function doTypePaintTime(objRow, strTime, strMins, intWrkCnt) {

      var objTable;
      var objCell;
      var strWrkInd;
      var intWrkStr;
      var intWrkEnd;
      var strWrkNam;

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
      objCell.style.backgroundColor = '#ffffe0';
      objCell.style.color = '#000000';
      objCell.style.border = '#000000 1px solid';
      objCell.style.paddingLeft = '2px';
      objCell.style.paddingRight = '2px';
      objCell.style.whiteSpace = 'nowrap';
      objCell.appendChild(document.createTextNode(strTime+':'+strMins));

      for (var k=0;k<cobjTypeLine.length;k++) {

         intWrkInd = 'N';
         for (var w=0;w<cobjTypeShft.length;w++) {
            if (cobjTypeShft[w].cmocde != '*NONE' && (intWrkCnt >= cobjTypeShft[w].barstr && intWrkCnt <= cobjTypeShft[w].barend)) {
               intWrkInd = 'X';
               if (intWrkCnt == cobjTypeShft[w].barstr) {
                  intWrkInd = 'S';
                  strWrkNam = '('+cobjTypeShft[w].shfcde+') '+cobjTypeShft[w].shfnam;
               } else if (intWrkCnt == cobjTypeShft[w].barend) {
                  intWrkInd = 'E';
                  strWrkNam = '('+cobjTypeShft[w].shfcde+') '+cobjTypeShft[w].shfnam;
               } else if (intWrkCnt == cobjTypeShft[w].barstr + 1) {
                  intWrkInd = 'B';
                  intWrkStr = cobjTypeShft[w].barstr + 1;
                  intWrkEnd = cobjTypeShft[w].barend - 1;
                  strWrkNam = '('+cobjTypeShft[w].shfcde+') '+cobjTypeShft[w].shfnam;
               }
               break;
            }
         }

         if (intWrkInd == 'N') {

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
            objCell.vAlign = 'center';
            objCell.style.fontSize = '8pt';
            objCell.style.backgroundColor = '#f7f7f7';
            objCell.style.color = '#000000';
            objCell.style.borderRight = '#c7c7c7 1px solid';
            objCell.style.padding = '0px';
            objCell.style.whiteSpace = 'nowrap';

         } else {

            if (intWrkInd == 'S') {

               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.style.fontSize = '8pt';
               objCell.style.backgroundColor = '#04aa04';
               objCell.style.color = '#000000';
               objCell.style.borderTop = '#000000 1px solid';
               objCell.style.paddingLeft = '2px';
               objCell.style.paddingRight = '2px';
               objCell.style.whiteSpace = 'nowrap';
               objCell.title = strWrkNam;

            } else if (intWrkInd == 'E') {

               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.style.fontSize = '8pt';
               objCell.style.backgroundColor = '#BC0000';
               objCell.style.color = '#000000';
               objCell.style.borderBottom = '#000000 1px solid';
               objCell.style.paddingLeft = '2px';
               objCell.style.paddingRight = '2px';
               objCell.style.whiteSpace = 'nowrap';
               objCell.title = strWrkNam;

            } else if (intWrkInd == 'B') {

               objCell = objRow.insertCell(-1);
               objCell.rowSpan = (intWrkEnd - intWrkStr) + 1;
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.style.fontSize = '8pt';
               objCell.style.backgroundColor = '#c0ffc0';
               objCell.style.color = '#000000';
               objCell.style.border = 'none';
               objCell.style.paddingLeft = '2px';
               objCell.style.paddingRight = '2px';
               objCell.style.whiteSpace = 'nowrap';
               objCell.title = strWrkNam;

            }

            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.style.fontSize = '8pt';
            objCell.style.backgroundColor = 'transparent';
            objCell.style.color = '#000000';
            objCell.style.border = '#c7c7c7 1px solid';
            objCell.style.padding = '0px';
            objCell.style.height = '100%';
            objCell.style.whiteSpace = 'nowrap';

            objTable = document.createElement('table');
            objTable.id = 'TYPACT_'+intWrkCnt+'_'+k+'_'+strMins;
            objTable.className = 'clsPanel';
            objTable.align = 'center';
            objTable.cellSpacing = '0';
            objTable.style.border = 'none';
            objTable.style.padding = '0px';
            objTable.style.height = '100%';
            objCell.appendChild(objTable);


            var objActRow = objTable.insertRow(-1);

            objCell = objActRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.style.fontSize = '8pt';
            objCell.style.fontWeight = 'bold';
            objCell.style.backgroundColor = 'transparent';
            objCell.style.color = '#000000';
            objCell.style.border = 'none';
            objCell.style.padding = '0px';
            objCell.style.whiteSpace = 'nowrap';
            objCell.appendChild(document.createTextNode('START WEEK'));

         }

      }

   }


   function doTypeBack() {
      cobjTypeDate.length = 0;
      cobjTypeShft.length = 0;
      cobjTypeLine.length = 0;
      var objTypHead = document.getElementById('tabHeadType');
      var objTypBody = document.getElementById('tabBodyType');
      for (var i=objTypHead.rows.length-1;i>=0;i--) {
         objTypHead.deleteRow(i);
      }
      for (var i=objTypBody.rows.length-1;i>=0;i--) {
         objTypBody.deleteRow(i);
      }
      displayScreen('dspWeeks');
   }





   function doTypeActvDelete() {
      if (cobTypeCell == null) {
         return;
      }
      if (cstrTypeType == '*EVNT') {
         if (!processForm()) {return;}
         if (confirm('Please confirm the deletion\r\npress OK continue (the selected production schedule event activity will be deleted)\r\npress Cancel to cancel and return') == false) {
            return;
         }
         doActivityStart(document.body);
         window.setTimeout('requestEvntDelete(\''+strCode+'\');',10);
      } else if (cstrTypeType == '*FILL') {
         if (!processForm()) {return;}
         if (confirm('Please confirm the deletion\r\npress OK continue (the selected production schedule filling activity will be deleted)\r\npress Cancel to cancel and return') == false) {
            return;
         }
         doActivityStart(document.body);
         window.setTimeout('requestFillDelete(\''+strCode+'\');',10);
      } else if (cstrTypeType == '*PACK') {
         if (!processForm()) {return;}
         if (confirm('Please confirm the deletion\r\npress OK continue (the selected production schedule packing activity will be deleted)\r\npress Cancel to cancel and return') == false) {
            return;
         }
         doActivityStart(document.body);
         window.setTimeout('requestPackDelete(\''+strCode+'\');',10);
      } else if (cstrTypeType == '*FORM') {
         if (!processForm()) {return;}
         if (confirm('Please confirm the deletion\r\npress OK continue (the selected production schedule forming activity will be deleted)\r\npress Cancel to cancel and return') == false) {
            return;
         }
         doActivityStart(document.body);
         window.setTimeout('requestFormDelete(\''+strCode+'\');',10);
      }
   }
   function doTypeActvUpdate() {
      if (cobjTypeCell == null) {
         return;
      }
      if (cstrTypeType == '*EVNT') {
         if (!processForm()) {return;}
         doActivityStart(document.body);
         window.setTimeout('requestEvntUpdate(\''+strCode+'\');',10);
      } else if (cstrTypeType == '*FILL') {
         if (!processForm()) {return;}
         doActivityStart(document.body);
         window.setTimeout('requestFillUpdate(\''+strCode+'\');',10);
      } else if (cstrTypeType == '*PACK') {
         if (!processForm()) {return;}
         doActivityStart(document.body);
         window.setTimeout('requestPackUpdate(\''+strCode+'\');',10);
      } else if (cstrTypeType == '*FORM') {
         if (!processForm()) {return;}
         doActivityStart(document.body);
         window.setTimeout('requestFormUpdate(\''+strCode+'\');',10);
      }
   }
   function doTypeAddEvnt() {
      if (cobTypeCell == null) {
         return;
      }
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestEvntAdd();',10);
   }
   function doTypeAddFill() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestFillAdd();',10);
   }
   function doTypeAddPack() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestPackAdd();',10);
   }
   function doTypeAddForm() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestFormAdd();',10);
   }

   /////////////////////
   // Event Functions //
   /////////////////////
   var cstrEvntMode;
   var cstrEvntCode;
   function requestEvntAdd() {
      cstrEvntMode = '*ADD';
      cstrEvntCode = '';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrEvntCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_evnt_retrieve.asp',function(strResponse) {checkEvntLoad(strResponse);},false,streamXML(strXML));
   }
   function requestEvntUpdate(strCode) {
      cstrEvntMode = '*UPD';
      cstrEvntCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrEvntCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_evnt_retrieve.asp',function(strResponse) {checkEvntLoad(strResponse);},false,streamXML(strXML));
   }
   function requestEvntDelete(strCode) {
      cstrEvntMode = '*DLT';
      cstrEvntCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*DLTACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrEvntCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_evnt_delete.asp',function(strResponse) {checkEvntLoad(strResponse);},false,streamXML(strXML));
   }
   function checkEvntLoad(strResponse) {
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
         if (cstrDefineMode == '*DLT') {
            doDetailRefresh();
            return;
         } else if (cstrDefineMode == '*UPD') {
            cobjScreens[2].hedtxt = 'Update Production Schedule';
            document.getElementById('addEvnt').style.display = 'none';
            document.getElementById('updEvnt').style.display = 'block';
         } else if (cstrDefineMode == '*CRT') {
            cobjScreens[2].hedtxt = 'Create Production Schedule';
            document.getElementById('addEvnt').style.display = 'block';
            document.getElementById('updEvnt').style.display = 'none';
         }
         displayScreen('dspEvnt');
         document.getElementById('EVT_MatCode').value = '';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'EVTDFN') {
               if (cstrEvntMode == '*UPD') {
                  document.getElementById('EVT_UpdCode').innerHTML = '<p>'+objElements[i].getAttribute('EVTCDE')+'</p>';
               } else {
                  document.getElementById('EVT_EvtCode').value = objElements[i].getAttribute('EVTCDE');
               }
               document.getElementById('EVT_EvtName').value = objElements[i].getAttribute('EVTNAM');
            }
         }
         if (cstrEvntMode == '*UPD') {
            document.getElementById('EVT_EvtName').focus();
         } else {
            document.getElementById('EVT_EvtCode').focus();
         }
      }
   }
   function doEvntCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspDetail');
   }
   function doEvntAccept() {
      if (!processForm()) {return;}
      var objEvtCode = document.getElementById('EVT_EvtCode');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      if (cstrEvntMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDEVT"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTEVT"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      }
      strXML = strXML+' PSCNAM="'+fixXML(document.getElementById('DEF_PscName').value)+'"';
      if (objEvtCode.selectedIndex == -1) {
         strXML = strXML+' EVTCDE=""';
      } else {
         strXML = strXML+' EVTCDE="'+fixXML(objEvtCode.options[objEvtCode.selectedIndex].value)+'"';
      }
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestEvntAccept(\''+strXML+'\');',10);
   }
   function requestEvntAccept(strXML) {
      doPostRequest('<%=strBase%>psa_psc_evnt_update.asp',function(strResponse) {checkEvntAccept(strResponse);},false,streamXML(strXML));
   }
   function checkEvntAccept(strResponse) {
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
         doDetailRefresh();
      }
   }

   ///////////////////////
   // Filling Functions //
   ///////////////////////
   var cstrFillMode;
   var cstrFillCode;
   function requestFillAdd() {
      cstrFillMode = '*ADD';
      cstrFillCode = '';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrFillCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_fill_retrieve.asp',function(strResponse) {checkFillLoad(strResponse);},false,streamXML(strXML));
   }
   function requestFillUpdate(strCode) {
      cstrFillMode = '*UPD';
      cstrFillCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrFillCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_fill_retrieve.asp',function(strResponse) {checkFillLoad(strResponse);},false,streamXML(strXML));
   }
   function requestFillDelete(strCode) {
      cstrFillMode = '*DLT';
      cstrFillCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*DLTACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrFillCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_fill_delete.asp',function(strResponse) {checkFillLoad(strResponse);},false,streamXML(strXML));
   }
   function checkFillLoad(strResponse) {
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
         if (cstrDefineMode == '*DLT') {
            doDetailRefresh();
            return;
         } else if (cstrDefineMode == '*UPD') {
            cobjScreens[2].hedtxt = 'Update Production Schedule';
            document.getElementById('addFill').style.display = 'none';
            document.getElementById('updFill').style.display = 'block';
         } else if (cstrDefineMode == '*CRT') {
            cobjScreens[2].hedtxt = 'Create Production Schedule';
            document.getElementById('addFill').style.display = 'block';
            document.getElementById('updFill').style.display = 'none';
         }
         displayScreen('dspFill');
         document.getElementById('EVT_MatCode').value = '';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'EVTDFN') {
               if (cstrFillMode == '*UPD') {
                  document.getElementById('EVT_UpdCode').innerHTML = '<p>'+objElements[i].getAttribute('EVTCDE')+'</p>';
               } else {
                  document.getElementById('EVT_EvtCode').value = objElements[i].getAttribute('EVTCDE');
               }
               document.getElementById('EVT_EvtName').value = objElements[i].getAttribute('EVTNAM');
            }
         }
         if (cstrFillMode == '*UPD') {
            document.getElementById('EVT_EvtName').focus();
         } else {
            document.getElementById('EVT_EvtCode').focus();
         }
      }
   }
   function doFillCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspDetail');
   }
   function doFillAccept() {
      if (!processForm()) {return;}
      var objEvtCode = document.getElementById('EVT_EvtCode');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      if (cstrFillMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDACT"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTACT"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      }
      strXML = strXML+' PSCNAM="'+fixXML(document.getElementById('DEF_PscName').value)+'"';
      if (objEvtCode.selectedIndex == -1) {
         strXML = strXML+' EVTCDE=""';
      } else {
         strXML = strXML+' EVTCDE="'+fixXML(objEvtCode.options[objEvtCode.selectedIndex].value)+'"';
      }
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestFillAccept(\''+strXML+'\');',10);
   }
   function requestFillAccept(strXML) {
      doPostRequest('<%=strBase%>psa_psc_fill_update.asp',function(strResponse) {checkFillAccept(strResponse);},false,streamXML(strXML));
   }
   function checkFillAccept(strResponse) {
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
         doDetailRefresh();
      }
   }

   ///////////////////////
   // Packing Functions //
   ///////////////////////
   var cstrPackMode;
   var cstrPackCode;
   function requestPackAdd() {
      cstrPackMode = '*ADD';
      cstrPackCode = '';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrPackCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_pack_retrieve.asp',function(strResponse) {checkPackLoad(strResponse);},false,streamXML(strXML));
   }
   function requestPackUpdate(strCode) {
      cstrPackMode = '*UPD';
      cstrPackCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrPackCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_pack_retrieve.asp',function(strResponse) {checkPackLoad(strResponse);},false,streamXML(strXML));
   }
   function requestPackDelete(strCode) {
      cstrPackMode = '*DLT';
      cstrPackCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*DLTACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrPackCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_pack_delete.asp',function(strResponse) {checkPackLoad(strResponse);},false,streamXML(strXML));
   }
   function checkPackLoad(strResponse) {
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
         if (cstrDefineMode == '*DLT') {
            doDetailRefresh();
            return;
         } else if (cstrDefineMode == '*UPD') {
            cobjScreens[2].hedtxt = 'Update Production Schedule';
            document.getElementById('addPack').style.display = 'none';
            document.getElementById('updPack').style.display = 'block';
         } else if (cstrDefineMode == '*CRT') {
            cobjScreens[2].hedtxt = 'Create Production Schedule';
            document.getElementById('addPack').style.display = 'block';
            document.getElementById('updPack').style.display = 'none';
         }
         displayScreen('dspPack');
         document.getElementById('EVT_MatCode').value = '';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'EVTDFN') {
               if (cstrPackMode == '*UPD') {
                  document.getElementById('EVT_UpdCode').innerHTML = '<p>'+objElements[i].getAttribute('EVTCDE')+'</p>';
               } else {
                  document.getElementById('EVT_EvtCode').value = objElements[i].getAttribute('EVTCDE');
               }
               document.getElementById('EVT_EvtName').value = objElements[i].getAttribute('EVTNAM');
            }
         }
         if (cstrPackMode == '*UPD') {
            document.getElementById('EVT_EvtName').focus();
         } else {
            document.getElementById('EVT_EvtCode').focus();
         }
      }
   }
   function doPackCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspDetail');
   }
   function doPackAccept() {
      if (!processForm()) {return;}
      var objEvtCode = document.getElementById('EVT_EvtCode');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      if (cstrPackMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDACT"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTACT"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      }
      strXML = strXML+' PSCNAM="'+fixXML(document.getElementById('DEF_PscName').value)+'"';
      if (objEvtCode.selectedIndex == -1) {
         strXML = strXML+' EVTCDE=""';
      } else {
         strXML = strXML+' EVTCDE="'+fixXML(objEvtCode.options[objEvtCode.selectedIndex].value)+'"';
      }
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestPackAccept(\''+strXML+'\');',10);
   }
   function requestPackAccept(strXML) {
      doPostRequest('<%=strBase%>psa_psc_pack_update.asp',function(strResponse) {checkPackAccept(strResponse);},false,streamXML(strXML));
   }
   function checkPackAccept(strResponse) {
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
         doDetailRefresh();
      }
   }

   ///////////////////////
   // Forming Functions //
   ///////////////////////
   var cstrFormMode;
   var cstrFormCode;
   function requestFormAdd() {
      cstrFormMode = '*ADD';
      cstrFormCode = '';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*CRTACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrFormCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_form_retrieve.asp',function(strResponse) {checkFormLoad(strResponse);},false,streamXML(strXML));
   }
   function requestFormUpdate(strCode) {
      cstrFormMode = '*UPD';
      cstrFormCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrFormCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_form_retrieve.asp',function(strResponse) {checkFormLoad(strResponse);},false,streamXML(strXML));
   }
   function requestFormDelete(strCode) {
      cstrFormMode = '*DLT';
      cstrFormCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*DLTACT" PSCCDE="'+fixXML(cstrDetailCode)+'" ACTCDE="'+fixXML(cstrFormCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_form_delete.asp',function(strResponse) {checkFormLoad(strResponse);},false,streamXML(strXML));
   }
   function checkFormLoad(strResponse) {
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
         if (cstrDefineMode == '*DLT') {
            doDetailRefresh();
            return;
         } else if (cstrDefineMode == '*UPD') {
            cobjScreens[2].hedtxt = 'Update Production Schedule';
            document.getElementById('addForm').style.display = 'none';
            document.getElementById('updForm').style.display = 'block';
         } else if (cstrDefineMode == '*CRT') {
            cobjScreens[2].hedtxt = 'Create Production Schedule';
            document.getElementById('addForm').style.display = 'block';
            document.getElementById('updForm').style.display = 'none';
         }
         displayScreen('dspForm');
         document.getElementById('EVT_MatCode').value = '';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'EVTDFN') {
               if (cstrFormMode == '*UPD') {
                  document.getElementById('EVT_UpdCode').innerHTML = '<p>'+objElements[i].getAttribute('EVTCDE')+'</p>';
               } else {
                  document.getElementById('EVT_EvtCode').value = objElements[i].getAttribute('EVTCDE');
               }
               document.getElementById('EVT_EvtName').value = objElements[i].getAttribute('EVTNAM');
            }
         }
         if (cstrFormMode == '*UPD') {
            document.getElementById('EVT_EvtName').focus();
         } else {
            document.getElementById('EVT_EvtCode').focus();
         }
      }
   }
   function doFormCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspDetail');
   }
   function doFormAccept() {
      if (!processForm()) {return;}
      var objEvtCode = document.getElementById('EVT_EvtCode');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      if (cstrFormMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDACT"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTACT"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrDetailCode)+'"';
      }
      strXML = strXML+' PSCNAM="'+fixXML(document.getElementById('DEF_PscName').value)+'"';
      if (objEvtCode.selectedIndex == -1) {
         strXML = strXML+' EVTCDE=""';
      } else {
         strXML = strXML+' EVTCDE="'+fixXML(objEvtCode.options[objEvtCode.selectedIndex].value)+'"';
      }
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestFormAccept(\''+strXML+'\');',10);
   }
   function requestFormAccept(strXML) {
      doPostRequest('<%=strBase%>psa_psc_form_update.asp',function(strResponse) {checkFormAccept(strResponse);},false,streamXML(strXML));
   }
   function checkFormAccept(strResponse) {
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
         doDetailRefresh();
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
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Shift Model:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="WEK_PscSmod" onChange="doWeekSmodChange(this,false);"></select>
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
   <table id="dspType" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=1 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=1 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedType" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Maintenance</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=left colspan=1 nowrap><nobr>
            <table class="clsTable01" align=center cols=7 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTypeBack();">&nbsp;Back&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTypeActvDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTypeActvUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTypeAddEvnt();">&nbsp;Add Event&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTypeAddFill();">&nbsp;Add Filling&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTypeAddPack();">&nbsp;Add Packing&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTypeAddForm();">&nbsp;Add Forming&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=1 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center width=100% colspan=1 nowrap><nobr>
                     <div id="conHeadType" style="width:100%;overflow:hidden;background-color:#40414c;border:#40414c 1px solid;">
                     <table class="clsPanel" id="tabHeadType" style="background-color:#f7f7f7;border-collapse:collapse;border:none;" align=left cols=1 cellpadding="0" cellspacing="0">
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center width=100% colspan=1 nowrap><nobr>
                     <div id="conBodyType" style="width:100%;height:100%;overflow:scroll;background-color:#ffffff;border:#40414c 1px solid;">
                     <table class="clsPanel" id="tabBodyType" style="background-color:transparent;border-collapse:collapse;border:none;" align=left cols=1 cellpadding="0" cellspacing="0"></table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspEvnt" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=1 cellspacing=1 cellpadding=0>
      <tr><td align=center colspan=1 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedEvnt" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Maintenance - Event Activity</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Activity:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="EVT_ActCode"></select>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doEventCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doEventAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspFill" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=1 cellspacing=1 cellpadding=0>
      <tr><td align=center colspan=1 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedFill" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Maintenance - Filling Activity</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Start Time:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="FIL_StrTime" size="6" maxlength="6" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Material:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="FIL_MatCode"></select>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFillingCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFillingAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspPack" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=1 cellspacing=1 cellpadding=0>
      <tr><td align=center colspan=1 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPack" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Maintenance - Packing Activity</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Start Time:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PAC_StrTime" size="6" maxlength="6" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Material:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="PAC_MatCode"></select>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPackingCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPackingAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspForm" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=1 cellspacing=1 cellpadding=0>
      <tr><td align=center colspan=1 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedForm" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Maintenance - Forming Activity</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Start Time:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="FOR_StrTime" size="6" maxlength="6" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Material:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="FOR_MatCode"></select>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFormingCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFormingAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->