<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PSA (Production Scheduling Application)            //
'// Script  : psa_psc_enquiry.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : December 2009                                      //
'// Text    : This script implements the production schedule     //
'//           enquiry functionality                              //
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
   strTarget = "psa_psc_enquiry.asp"
   strHeading = "Production Schedule Enquiry"

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
   strReturn = GetSecurityCheck("PSA_PSC_ENQUIRY")
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
      cobjScreens[1] = new clsScreen('dspWeeks','hedWeeks');
      cobjScreens[2] = new clsScreen('dspType','hedType');
      cobjScreens[0].hedtxt = '**LOADING**';
      cobjScreens[1].hedtxt = 'Week Selection';
      cobjScreens[2].hedtxt = 'Schedule Enquiry';
      cobjScreens[0].bodsrl = 'no';
      cobjScreens[1].bodsrl = 'no';
      cobjScreens[2].bodsrl = 'no';
      displayScreen('dspLoad');
      doWeekRefresh();
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

   ////////////////////
   // Week Functions //
   ////////////////////
   var cstrWeekProd = '*MASTER';
   function requestWeekList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*WEKLST" SRCCDE="*ACT" PSCCDE="'+fixXML(cstrWeekProd)+'"/>';
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
         cobjScreens[1].hedtxt = 'Production Week Selection - '+cstrWeekProd;
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
               if (objElements[i].getAttribute('SLTTYP') != '*WEEK') {
                  objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doTypeReview(\''+objElements[i].getAttribute('SLTWEK')+'\',\''+objElements[i].getAttribute('SLTCDE')+'\');">Review</a>&nbsp;';
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
   function doTypeReview(strWeek,strCode) {
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
   var cintTypeHsiz = new Array();
   var cintTypeBsiz = new Array();
   var cobjTypeDate = new Array();
   var cobjTypeStck = new Array();
   var cobjTypeLine = new Array();
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
   function requestTypeLoad() {
      cobjTypeLineCell = null;
      cobjTypeSchdCell = null;
      cobjTypeUactCell = null;
      cbolTypePulse = false;
      cstrTypeTind = '0';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*GETTYP" SRCCDE="*ACT" PSCCDE="'+fixXML(cstrTypeProd)+'" WEKCDE="'+fixXML(cstrTypeWeek)+'" PTYCDE="'+fixXML(cstrTypeCode)+'"/>';
      doPostRequest('<%=strBase%>psa_psc_type_retrieve.asp',function(strResponse) {checkTypeLoad(strResponse);},false,streamXML(strXML));
   }
   function requestTypeReload() {
      cobjTypeLineCell = null;
      cobjTypeSchdCell = null;
      cobjTypeUactCell = null;
      cbolTypePulse = false;
      window.clearTimeout(cintTypePulse);
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*GETTYP" SRCCDE="*ACT" PSCCDE="'+fixXML(cstrTypeProd)+'" WEKCDE="'+fixXML(cstrTypeWeek)+'" PTYCDE="'+fixXML(cstrTypeCode)+'"/>';
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
         cobjTypeDate.length = 0;
         cobjTypeStck.length = 0;
         cobjTypeLine.length = 0;
         var objShfAry;
         var objActAry;
         var objInvAry;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PTYDFN') {
               cstrTypePulse = objElements[i].getAttribute('PULVAL');
               cstrTypeHead = 'Actuals Maintenance - '+cstrTypeProd+' - '+objElements[i].getAttribute('WEKNAM')+' - '+objElements[i].getAttribute('PTYNAM');
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
            }
         }
         doTypeSchdPaint();
         doTypeSchdPaintActv();
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
      var objSchHead = document.getElementById('tabHeadSchd');
      var objSchBody = document.getElementById('tabBodySchd');
      for (var i=objSchHead.rows.length-1;i>=0;i--) {
         objSchHead.deleteRow(i);
      }
      for (var i=objSchBody.rows.length-1;i>=0;i--) {
         objSchBody.deleteRow(i);
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
      var objFont;
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
               objDiv.style.cursor = 'pointer';
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
                     if ((objInvAry[k].invqty-0) <= (objInvAry[k].invavl-0)) {
                        objDiv.appendChild(document.createTextNode('Component ('+objInvAry[k].matcde+') '+objInvAry[k].matnam+' Required ('+objInvAry[k].invqty+') Available ('+objInvAry[k].invavl+')'));
                     } else {
                        objFont = document.createElement('font');
                        objFont.style.backgroundColor = '#ffc0c0';
                        objFont.appendChild(document.createTextNode('Component ('+objInvAry[k].matcde+') '+objInvAry[k].matnam+' Required ('+objInvAry[k].invqty+') Available ('+objInvAry[k].invavl+')'));
                        objDiv.appendChild(objFont);
                     }
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
<body id="dspBody" class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('psa_psc_enquiry_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspWeeks" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedWeeks" class="clsFunction" align=center colspan=2 nowrap><nobr>Production Schedule Enquiry Week Selection</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doWeekRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
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
   <table id="dspType" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedType" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Production Schedule Enquiry</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=left colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeBack();">&nbsp;Back&nbsp;</a></nobr></td>
                  <td class="clsTabB" style="font-size:8pt" align=center colspan=1 nowrap><nobr>&nbsp;Reporting&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeSchdReport();">&nbsp;Schedule&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=left colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=2 cellpadding="0" cellspacing="0">
               <tr>
                  <td id="typPulse" class="clsTabB" style="font-size:8pt" align=center colspan=1 nowrap><nobr>&nbsp;Enquiry&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" style="font-size:8pt" onClick="doTypeSchdRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td id="datTypeSchd" align=center colspan=2 width=100% nowrap><nobr>
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
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->