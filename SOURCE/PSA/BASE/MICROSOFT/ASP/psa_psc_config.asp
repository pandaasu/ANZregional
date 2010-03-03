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
      cobjScreens[0].hedtxt = '**LOADING**';
      cobjScreens[1].hedtxt = 'Production Schedule Selection';
      cobjScreens[2].hedtxt = 'Create Production Schedule';
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
   function doSelectDelete(strCode) {
      if (!processForm()) {return;}
      if (confirm('Please confirm the deletion\r\npress OK continue (the selected production schedule will be deleted)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDelete(\''+strCode+'\');',10);
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
               objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doSelectUpdate(\''+objElements[i].getAttribute('PSCCDE')+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectDelete(\''+objElements[i].getAttribute('PSCCDE')+'\');">Delete</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectCopy(\''+objElements[i].getAttribute('PSCCDE')+'\');">Copy</a>&nbsp;';
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
   var cobjWekData = new Array();
   var cobjSmoData = new Array();
   var cobjPtyData = new Array();
   var cobjPscHder = new Array();
   function clsWekData() {
      this.wekcde = '';
      this.weknam = '';
      this.wekslt = '0';
      this.smoidx = -1;
      this.dayary = new Array();
      this.ptyary = new Array();
   }
   function clsDayData() {
      this.daycde = '';
      this.daynam = '';
   }
   function clsSmoData() {
      this.smocde = '';
      this.smonam = '';
      this.shfary = new Array();
   }
   function clsShfData() {
      this.shfcde = '';
      this.shfnam = '';
      this.shfstr = '';
      this.shfdur = '';
   }
   function clsPtyData() {
      this.ptycde = '';
      this.ptynam = '';
      this.cmoary = new Array();
      this.lcoary = new Array();
   }
   function clsCmoData() {
      this.cmocde = '';
      this.cmonam = '';
   }
   function clsLcoData() {
      this.lincde = '';
      this.linnam = '';
      this.linwas = '';
      this.linevt = '';
      this.lcocde = '';
      this.lconam = '';
      this.filnam = '';
   }


   function clsPscHder() {
      this.psccde = '';
      this.pscnam = '';
      this.strwek = '';
      this.endwek = '';
      this.reqcde = '';
      this.wekary = new Array();

   }
   function clsPscWeek() {
      this.wekcde = '';
      this.smocde = '';
      this.shfary = new Array();
    //  this.ptyary = new Array();
   }
   function clsPscShft() {
      this.shfcde = '';
      this.ptyary = new Array();
   }
   function clsPscType() {
      this.ptycde = '';
      this.cmocde = '';
      this.lcoary = new Array();
   }
   function clsPscLine() {
      this.shfcde = '';
      this.cmocde = '';
   }
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
         displayScreen('dspDefine');
         document.getElementById('HEDR_DATA').style.display = 'block';
         document.getElementById('WEEK_DATA').style.display = 'none';
         document.getElementById('TYPE_DATA').style.display = 'none';
         cobjWekData.length = 0;
         cobjSmoData.length = 0;
         cobjPtyData.length = 0;
         var objArray;
         document.getElementById('DEF_PscCode').value = '';
         document.getElementById('DEF_PscName').value = '';
         var objPscSwek = document.getElementById('DEF_PscSwek');
         var objPscEwek = document.getElementById('DEF_PscEwek');
         var objPscPreq = document.getElementById('DEF_PscPreq');
         objPscSwek.options.length = 0;
         objPscEwek.options.length = 0;
         objPscPreq.options.length = 0;
         objPscSwek.options[0] = new Option('** Select Start Week **','*NONE');
         objPscEwek.options[0] = new Option('** Select End Week **','*NONE');
         objPscPreq.options[0] = new Option('** Select Production Requirement **','*NONE');
         objPscSwek.selectedIndex = 0;
         objPscEwek.selectedIndex = 0;
         objPscPreq.selectedIndex = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PSCDFN') {
               if (cstrDefineMode == '*UPD') {
                  document.getElementById('DEF_UpdCode').innerHTML = '<p>'+objElements[i].getAttribute('PSCCDE')+'</p>';
               } else {
                  document.getElementById('DEF_PscCode').value = objElements[i].getAttribute('PSCCDE');
               }
               document.getElementById('DEF_PscName').value = objElements[i].getAttribute('PSCNAM');
               strPscStat = objElements[i].getAttribute('PSCSTS');
            } else if (objElements[i].nodeName == 'WEKDFN') {
               cobjWekData[cobjWekData.length] = new clsWekData();
               cobjWekData[cobjWekData.length-1].wekcde = objElements[i].getAttribute('WEKCDE');
               cobjWekData[cobjWekData.length-1].weknam = objElements[i].getAttribute('WEKNAM');
               objPscSwek.options[objPscSwek.options.length] = new Option(objElements[i].getAttribute('WEKNAM'),objElements[i].getAttribute('WEKCDE'));
               objPscEwek.options[objPscEwek.options.length] = new Option(objElements[i].getAttribute('WEKNAM'),objElements[i].getAttribute('WEKCDE'));
            } else if (objElements[i].nodeName == 'DAYDFN') {
               objArray = cobjWekData[cobjWekData.length-1].dayary;
               objArray[objArray.length] = new clsDayData();
               objArray[objArray.length-1].daycde = objElements[i].getAttribute('DAYCDE');
               objArray[objArray.length-1].daynam = objElements[i].getAttribute('DAYNAM');
            } else if (objElements[i].nodeName == 'REQDFN') {
               objPscPreq.options[objPscPreq.options.length] = new Option(objElements[i].getAttribute('REQNAM'),objElements[i].getAttribute('REQCDE'));
               objPscPreq.options[objPscPreq.options.length-1].setAttribute('reqwek',objElements[i].getAttribute('REQWEK'));
            } else if (objElements[i].nodeName == 'SMODFN') {
               cobjSmoData[cobjSmoData.length] = new clsSmoData();
               cobjSmoData[cobjSmoData.length-1].smocde = objElements[i].getAttribute('SMOCDE');
               cobjSmoData[cobjSmoData.length-1].smonam = objElements[i].getAttribute('SMONAM');
            } else if (objElements[i].nodeName == 'SHFDFN') {
               objArray = cobjSmoData[cobjSmoData.length-1].shfary;
               objArray[objArray.length] = new clsShfData();
               objArray[objArray.length-1].shfcde = objElements[i].getAttribute('SHFCDE');
               objArray[objArray.length-1].shfnam = objElements[i].getAttribute('SHFNAM');
               objArray[objArray.length-1].shfstr = objElements[i].getAttribute('SHFSTR');
               objArray[objArray.length-1].shfdur = objElements[i].getAttribute('SHFDUR');
            } else if (objElements[i].nodeName == 'PTYDFN') {
               cobjPtyData[cobjPtyData.length] = new clsPtyData();
               cobjPtyData[cobjPtyData.length-1].ptycde = objElements[i].getAttribute('PTYCDE');
               cobjPtyData[cobjPtyData.length-1].ptynam = objElements[i].getAttribute('PTYNAM');
            } else if (objElements[i].nodeName == 'CMODFN') {
               objArray = cobjPtyData[cobjPtyData.length-1].cmoary;
               objArray[objArray.length] = new clsCmoData();
               objArray[objArray.length-1].cmocde = objElements[i].getAttribute('CMOCDE');
               objArray[objArray.length-1].cmonam = objElements[i].getAttribute('CMONAM');
            } else if (objElements[i].nodeName == 'LCODFN') {
               objArray = cobjPtyData[cobjPtyData.length-1].lcoary;
               objArray[objArray.length] = new clsLcoData();
               objArray[objArray.length-1].lincde = objElements[i].getAttribute('LINCDE');
               objArray[objArray.length-1].linnam = objElements[i].getAttribute('LINNAM');
               objArray[objArray.length-1].linwas = objElements[i].getAttribute('LINWAS');
               objArray[objArray.length-1].linevt = objElements[i].getAttribute('LINEVT');
               objArray[objArray.length-1].lcocde = objElements[i].getAttribute('LCOCDE');
               objArray[objArray.length-1].lconam = objElements[i].getAttribute('LCONAM');
               objArray[objArray.length-1].filnam = objElements[i].getAttribute('FILNAM');
            }
         }
         document.getElementById('DEF_PscCode').focus();
      }
   }
   function doBackHedr() {
      if (!processForm()) {return;}
      document.getElementById('HEDR_DATA').style.display = 'block';
      document.getElementById('WEEK_DATA').style.display = 'none';
      document.getElementById('TYPE_DATA').style.display = 'none';
   }

   function doDefineWeek() {
      if (!processForm()) {return;}
      var objPscSwek = document.getElementById('DEF_PscSwek');
      var objPscEwek = document.getElementById('DEF_PscEwek');
      var objPscPreq = document.getElementById('DEF_PscPreq');
      var strMessage = '';
      if (document.getElementById('DEF_PscCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Production schedule code must be entered';
      }
      if (document.getElementById('DEF_PscName').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Production schedule name must be entered';
      }
      if (objPscSwek.selectedIndex == -1 || objPscSwek.options[objPscSwek.selectedIndex].value == '*NONE') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Production schedule start MARS week must be selected';
      }
      if (objPscEwek.selectedIndex == -1 || objPscEwek.options[objPscEwek.selectedIndex].value == '*NONE') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Production schedule end MARS week must be selected';
      }
      if (objPscSwek.selectedIndex != -1 && objPscSwek.options[objPscSwek.selectedIndex].value != '*NONE') {
         if (objPscEwek.selectedIndex != -1 && objPscEwek.options[objPscEwek.selectedIndex].value != '*NONE') {
            if (objPscSwek.options[objPscSwek.selectedIndex].value > objPscEwek.options[objPscEwek.selectedIndex].value) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Production schedule end MARS week must be greater tha or equal to start MARS week';
            }
         }
      }
    //  if (objPscPreq.selectedIndex == -1 || objPscPreq.options[objPscPreq.selectedIndex].value == '*NONE') {
    //     if (strMessage != '') {strMessage = strMessage + '\r\n';}
    //     strMessage = strMessage + 'Production requirements must be selected';
    //  }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.getElementById('HEDR_DATA').style.display = 'none';
      document.getElementById('WEEK_DATA').style.display = 'block';
      document.getElementById('TYPE_DATA').style.display = 'none';
      var objPscWeek = document.getElementById('DEF_PscWeek');
      for (var i=objPscWeek.rows.length-1;i>=1;i--) {
         objPscWeek.deleteRow(i);
      }
      var objRow;
      var objCell;
      var objSelect;
      var objArray;
      for (var i=0;i<cobjWekData.length;i++) {
         cobjWekData[i].wekslt = '0';
         cobjWekData[i].smoidx = -1;
         for (var j=0;j<cobjPtyData.length;j++) {
            cobjWekData[i].ptyary[j] = '0';
         }
      }
      for (var i=0;i<cobjWekData.length;i++) {
         if (cobjWekData[i].wekcde >= objPscSwek.options[objPscSwek.selectedIndex].value &&
             cobjWekData[i].wekcde <= objPscEwek.options[objPscEwek.selectedIndex].value) {
            cobjWekData[i].wekslt = '1';
            objRow = objPscWeek.insertRow(-1);
            objRow.setAttribute('wekcde',cobjWekData[i].wekcde);
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.className = 'clsLabelBB';
            objCell.style.paddingLeft = '2px';
            objCell.style.paddingRight = '2px';
            objCell.style.whiteSpace = 'nowrap';
            objCell.appendChild(document.createTextNode(cobjWekData[i].weknam));
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.className = 'clsLabelBN';
            objCell.style.paddingLeft = '2px';
            objCell.style.paddingRight = '2px';
            objCell.style.whiteSpace = 'nowrap';
            objSelect = document.createElement('select');
            objSelect.id = 'WEKSMO_'+cobjWekData[i].wekcde;
            objSelect.className = 'clsInputNN';
            objSelect.selectedIndex = -1;
            objSelect.options[0] = new Option('** Select Shift Model **','*NONE');
            objSelect.options[0].setAttribute('smocde','');
            objSelect.options[0].selected = true;
            for (var j=0;j<cobjSmoData.length;j++) {
               objSelect.options[objSelect.options.length] = new Option(cobjSmoData[j].smonam,cobjSmoData[j].smocde);
               objSelect.options[objSelect.options.length-1].setAttribute('smoidx',j);
            }
            objCell.appendChild(objSelect);
         }
      }
   }
   function doBackWeek() {
      if (!processForm()) {return;}
      document.getElementById('HEDR_DATA').style.display = 'none';
      document.getElementById('WEEK_DATA').style.display = 'block';
      document.getElementById('TYPE_DATA').style.display = 'none';
   }

   function doDefineType() {
      if (!processForm()) {return;}
      var objPscSmod;
      var strMessage = '';
      for (var i=0;i<cobjWekData.length;i++) {
         if (cobjWekData[i].wekslt == '1') {
            objPscSmod = document.getElementById('WEKSMO_'+cobjWekData[i].wekcde);
            cobjWekData[i].smoidx = objPscSmod.options[objPscSmod.selectedIndex].getAttribute('smoidx');
            if (objPscSmod.selectedIndex == -1 || objPscSmod.options[objPscSmod.selectedIndex].value == '*NONE') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Production schedule week ('+cobjWekData[i].weknam+') must have a shift model selected';
            }
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }

      document.getElementById('HEDR_DATA').style.display = 'none';
      document.getElementById('WEEK_DATA').style.display = 'none';
      document.getElementById('TYPE_DATA').style.display = 'block';
      var objPscType = document.getElementById('DEF_PscType');
      for (var i=objPscType.rows.length-1;i>=0;i--) {
         objPscType.deleteRow(i);
      }
      var objTable;
      var objRow;
      var objCell;
      var objImage;
      var objInput;
      var objSelect;
      for (var i=0;i<cobjWekData.length;i++) {
         if (cobjWekData[i].wekslt == '1') {

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
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'center';
            objCell.vAlign = 'center';
            objCell.className = 'clsLabelHB';
            objCell.style.width = '100%';
            objCell.style.paddingLeft = '2px';
            objCell.style.paddingRight = '2px';
            objCell.style.whiteSpace = 'nowrap';
            objCell.appendChild(document.createTextNode(cobjWekData[i].weknam));

            for (var j=0;j<cobjPtyData.length;j++) {

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
               objRow.setAttribute('wekidx',i);
               objRow.setAttribute('ptyidx',j);
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
               objInput.id = 'WEKPTY_'+i+'_'+j;
               objInput.onfocus = function() {setSelect(this);};
               objInput.onclick = function() {doTypeClick(this);};
               objInput.checked = false;
               objCell.appendChild(objInput);
               objCell.appendChild(document.createTextNode(cobjPtyData[j].ptynam));

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
               objTable.id = 'WEKPTYDATA_'+i+'_'+j;
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
               doSmodLoad(objCell,i,j,cobjWekData[i].smoidx);
               objRow = objTable.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBB';
               objCell.style.paddingLeft = '2px';
               objCell.style.paddingRight = '2px';
               objCell.style.whiteSpace = 'nowrap';
               doLconLoad(objCell,i,j);
            }

         }
      }
   }
   function doSmodLoad(objParent, intWekIdx, intPtyIdx, intSmoIdx) {
      var objTable = document.createElement('table');
      var objRow;
      var objCell;
      var objSelect;
      var objShfAry;
      var objCmoAry;
      var intBarDay;
      var intBarCnt;
      var intBarStr;
      var intStrTim;
      var intDurMin;
      var strDayNam;
      objTable.id = 'WEKPTYCMOD_'+intWekIdx+'_'+intPtyIdx;
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
      objShfAry = cobjSmoData[intSmoIdx].shfary;
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
         objSelect.id = 'WEKPTYCMODDATA_'+intWekIdx+'_'+intPtyIdx+'_'+i;
         objSelect.className = 'clsInputNN';
         objSelect.style.fontSize = '8pt';
         objSelect.selectedIndex = -1;
         objSelect.options[0] = new Option('** NONE **','*NONE');
         objSelect.options[0].setAttribute('cmocde','');
         objSelect.options[0].selected = true;
         objCmoAry = cobjPtyData[intPtyIdx].cmoary;
         for (var j=0;j<objCmoAry.length;j++) {
            objSelect.options[objSelect.options.length] = new Option('('+objCmoAry[j].cmocde+') '+objCmoAry[j].cmonam,objCmoAry[j].cmocde);
            objSelect.options[objSelect.options.length-1].setAttribute('cmoidx',j);
         }
         objCell.appendChild(objSelect);
      }
   }
   function doLconLoad(objParent, intWekIdx, intPtyIdx) {
      var objTable = document.createElement('table');
      var objRow;
      var objCell;
      var objInput;
      var objLcoAry;
      objTable.id = 'WEKPTYLCON_'+intWekIdx+'_'+intPtyIdx;
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
      objLcoAry = cobjPtyData[intPtyIdx].lcoary;
      for (var i=0;i<objLcoAry.length;i++) {
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
         objInput = document.createElement('input');
         objInput.type = 'checkbox';
         objInput.value = '';
         objInput.id = 'WEKPTYLCONDATA_'+intWekIdx+'_'+intPtyIdx+'_'+i;
         objInput.onfocus = function() {setSelect(this);};
         objInput.checked = false;
         objCell.appendChild(objInput);
         objCell.appendChild(document.createTextNode('('+objLcoAry[i].lincde+') '+objLcoAry[i].linnam+' - ('+objLcoAry[i].lcocde+') '+objLcoAry[i].lconam+' - '+objLcoAry[i].filnam));
      }
   }
   function doTypeClick(objCheck) {
      var intWekIdx = objCheck.parentNode.parentNode.getAttribute('wekidx');
      var intPtyIdx = objCheck.parentNode.parentNode.getAttribute('ptyidx');
      if (objCheck.checked == false) {
         cobjWekData[intWekIdx].ptyary[intPtyIdx] = '0';
         document.getElementById('WEKPTYDATA_'+intWekIdx+'_'+intPtyIdx).style.display = 'none';
      } else {
         document.getElementById('WEKPTYDATA_'+intWekIdx+'_'+intPtyIdx).style.display = 'block';
         cobjWekData[intWekIdx].ptyary[intPtyIdx] = '1';
      }
   }

   function doDefineAccept() {
      if (!processForm()) {return;}
      var objPscStat = document.getElementById('DEF_PscStat');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrDefineMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDDEF"';
         strXML = strXML+' PSCCDE="'+fixXML(cstrDefineCode)+'"';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTDEF"';
         strXML = strXML+' PSCCDE="'+fixXML(document.getElementById('DEF_PscCode').value)+'"';
      }
      strXML = strXML+' PSCNAM="'+fixXML(document.getElementById('DEF_PscName').value)+'"';
      if (objPscStat.selectedIndex == -1) {
         strXML = strXML+' PSCSTS=""';
      } else {
         strXML = strXML+' PSCSTS="'+fixXML(objPscStat.options[objPscStat.selectedIndex].value)+'"';
      }
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('psa_psc_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
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
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Create Production Schedule</nobr></td>
      </tr>
      </table></nobr></td></tr>

      <tr id="HEDR_Data" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Definition</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Production Schedule Code:&nbsp;</nobr></td>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
                     <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_PscCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Production Schedule Name:&nbsp;</nobr></td>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
                     <input class="clsInputNN" type="text" name="DEF_PscName" size="80" maxlength="120" value="" onFocus="setSelect(this);">
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Production Start MARS Week:&nbsp;</nobr></td>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="DEF_PscSwek"></select>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Production End MARS Week:&nbsp;</nobr></td>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="DEF_PscEwek"></select>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Production Requirement:&nbsp;</nobr></td>
                  <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="DEF_PscPreq"></select>
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
                           <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineWeek();">&nbsp;Next&nbsp;</a></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>

      <tr id="WEEK_Data" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Shift Models</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table id="DEF_PscWeek" class="clsGrid02" align=center valign=top cols=2 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Production Week</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Shift Model</nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsTable01" align=center cols=5 cellpadding="0" cellspacing="0">
                        <tr>
                           <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                           <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doBackHedr();">&nbsp;Back&nbsp;</a></nobr></td>
                           <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineType();">&nbsp;Next&nbsp;</a></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>

      <tr id="TYPE_Data" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Production Types</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table id="DEF_PscType" class="clsGrid02" align=center valign=top cols=1 cellpadding=0 cellspacing=1></table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsTable01" align=center cols=5 cellpadding="0" cellspacing="0">
                        <tr>
                           <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                           <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doBackWeek();">&nbsp;Back&nbsp;</a></nobr></td>
                           <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>

   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->