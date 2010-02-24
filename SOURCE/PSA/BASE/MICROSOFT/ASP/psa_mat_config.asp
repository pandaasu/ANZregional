<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PSA (Production Scheduling Application)            //
'// Script  : psa_mat_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : December 2009                                      //
'// Text    : This script implements the material                //
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
   strTarget = "psa_mat_config.asp"
   strHeading = "Material Maintenance"

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
   strReturn = GetSecurityCheck("PSA_MAT_CONFIG")
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
      if (objElement == null) {return;}
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
      if (objElement == null) {return;}
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
      cobjScreens[1].hedtxt = 'Material Selection';
      cobjScreens[2].hedtxt = 'Update Material';
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
      if (confirm('Please confirm the inactivation\r\npress OK continue (the selected material will be inactivated)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDelete(\''+strCode+'\');',10);
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
      doPostRequest('<%=strBase%>psa_mat_config_select.asp',function(strResponse) {checkSelectList(strResponse);},false,streamXML(strXML));
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
         objCell.innerHTML = '&nbsp;Material&nbsp;';
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
         objCell.innerHTML = '&nbsp;Type&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Usage&nbsp;';
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
                  cstrSelectStrCode = objElements[i].getAttribute('MATCDE');
               }
               cstrSelectEndCode = objElements[i].getAttribute('MATCDE');
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               if (objElements[i].getAttribute('MATSTS') == '*DEL') {
                  objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doSelectDelete(\''+objElements[i].getAttribute('MATCDE')+'\');">Inactivate</a>&nbsp;';
               } else {
                  objCell.innerHTML = '&nbsp;<a class="clsSelect" onClick="doSelectUpdate(\''+objElements[i].getAttribute('MATCDE')+'\');">Update</a>&nbsp;';
               }
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('MATCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('MATNAM')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('MATTYP')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('MATUSG')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('MATSTS')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         if (objTabBody.rows.length == 0) {
            objRow = objTabBody.insertRow(-1);
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 6;
            objCell.innerHTML = '&nbsp;NO DATA FOUND&nbsp;';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
            setScrollable('HeadList','BodyList','horizontal');
            objTabHead.rows(0).cells[6].style.width = 16;
            objTabHead.style.tableLayout = 'auto';
            objTabBody.style.tableLayout = 'auto';
         } else {
            setScrollable('HeadList','BodyList','horizontal');
            objTabHead.rows(0).cells[6].style.width = 16;
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*DLTDEF" MATCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_mat_config_delete.asp',function(strResponse) {checkDelete(strResponse);},false,streamXML(strXML));
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
   var cstrDefineCode;
   var cstrDefineType;
   var cstrDefineUsag;
   var cstrDefineLine;
   var cstrTduFill;
   var cstrTduPack;
   var cintLineCount;
   var cintCompCount;
   var cstrFillLinCode;
   var cstrPackLinCode;
   var cstrFormLinCode;
   var cbolFillDflt;
   var cbolPackDflt;
   var cbolFormDflt;
   var cintUntCase;
   var cintNetWght;
   function requestDefineUpdate(strCode) {
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PSA_REQUEST ACTION="*UPDDEF" MATCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>psa_mat_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
         document.getElementById('FILL_Data').style.display = 'none';
         document.getElementById('PACK_Data').style.display = 'none';
         document.getElementById('FORM_Data').style.display = 'none';
         document.getElementById('TDU_Data').style.display = 'none';
         document.getElementById('DEF_TduFill').checked = false;
         document.getElementById('DEF_TduPack').checked = false;
         cstrDefineType = '';
         cstrDefineUsag = '';
         cstrDefineLine = '';
         cstrTduFill = '0';
         cstrTduPack = '0';
         var strPrdType = '';
         var strLinCode = '';
         cstrFillLinCode = '';
         cstrPackLinCode = '';
         cstrFormLinCode = '';
         cbolFillDflt = false;
         cbolPackDflt = false;
         cbolFormDflt = false;
         cintLineCount = 0;
         cintCompCount = 0;
         cintUntCase = 0;
         cintNetWght = 0;
         var objFillPrdLine = document.getElementById('FILL_PrdLine');
         var objPackPrdLine = document.getElementById('PACK_PrdLine');
         var objFormPrdLine = document.getElementById('FORM_PrdLine');
         objFillPrdLine.options.length = 0;
         objPackPrdLine.options.length = 0;
         objFormPrdLine.options.length = 0;
         objFillPrdLine.options[0] = new Option('** Select Filling Line **','*NONE');
         objPackPrdLine.options[0] = new Option('** Select Packing Line **','*NONE');
         objFormPrdLine.options[0] = new Option('** Select Forming Line **','*NONE');
         objFillPrdLine.selectedIndex = 0;
         objPackPrdLine.selectedIndex = 0;
         objFormPrdLine.selectedIndex = 0;
         var objFillLinList = document.getElementById('FILL_LinList');
         for (var i=objFillLinList.rows.length-1;i>1;i--) {
            objFillLinList.deleteRow(i);
         }
         var objPackLinList = document.getElementById('PACK_LinList');
         for (var i=objPackLinList.rows.length-1;i>1;i--) {
            objPackLinList.deleteRow(i);
         }
         var objFormLinList = document.getElementById('FORM_LinList');
         for (var i=objFormLinList.rows.length-1;i>1;i--) {
            objFormLinList.deleteRow(i);
         }
         var objFillComList = document.getElementById('FILL_ComList');
         for (var i=objFillComList.rows.length-1;i>2;i--) {
            objFillComList.deleteRow(i);
         }
         var objPackComList = document.getElementById('PACK_ComList');
         for (var i=objPackComList.rows.length-1;i>2;i--) {
            objPackComList.deleteRow(i);
         }
         var objFormComList = document.getElementById('FORM_ComList');
         for (var i=objFormComList.rows.length-1;i>2;i--) {
            objFormComList.deleteRow(i);
         }
         var objRow;
         var objCell;
         var objInput;
         var objSelect;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'MATDFN') {
               document.getElementById('DEF_MatCode').innerHTML = '<p>'+objElements[i].getAttribute('MATCDE')+'</p>';
               document.getElementById('DEF_MatName').innerHTML = '<p>'+objElements[i].getAttribute('MATNAM')+'</p>';
               document.getElementById('DEF_MatType').innerHTML = '<p>'+objElements[i].getAttribute('MATTYP')+'</p>';
               document.getElementById('DEF_MatUsag').innerHTML = '<p>'+objElements[i].getAttribute('MATUSG')+'</p>';
               document.getElementById('DEF_MatStat').innerHTML = '<p>'+objElements[i].getAttribute('MATSTS')+'</p>';
               document.getElementById('DEF_MatMuom').innerHTML = '<p>'+objElements[i].getAttribute('MATUOM')+'</p>';
               document.getElementById('DEF_MatGwgt').innerHTML = '<p>'+objElements[i].getAttribute('MATGRW')+'</p>';
               document.getElementById('DEF_MatNwgt').innerHTML = '<p>'+objElements[i].getAttribute('MATNEW')+'</p>';
               document.getElementById('DEF_MatUcas').innerHTML = '<p>'+objElements[i].getAttribute('MATUNC')+'</p>';
               document.getElementById('DEF_SapCode').innerHTML = '<p>'+objElements[i].getAttribute('SAPCDE')+'</p>';
               document.getElementById('DEF_SapLine').innerHTML = '<p>'+objElements[i].getAttribute('SAPLIN')+'</p>';
               document.getElementById('DEF_SysDate').innerHTML = '<p>'+objElements[i].getAttribute('SYSDTE')+'</p>';
               document.getElementById('DEF_UpdDate').innerHTML = '<p>'+objElements[i].getAttribute('UPDDTE')+'</p>';
               cstrDefineType = objElements[i].getAttribute('MATTYP');
               cstrDefineUsag = objElements[i].getAttribute('MATUSG');
               cstrDefineLine = objElements[i].getAttribute('PSALIN');
               cintUntCase = objElements[i].getAttribute('MATUNC');
               cintNetWght = objElements[i].getAttribute('MATNEW');
               if (cstrDefineUsag == 'TDU') {
                  document.getElementById('TDU_Data').style.display = 'block';
               }
            } else if (objElements[i].nodeName == 'MATPTY') {
               strPrdType = objElements[i].getAttribute('PTYCDE');
               strLinCode = '';
               if (objElements[i].getAttribute('PTYCDE') == '*FILL') {
                  if (cstrDefineUsag == 'TDU') {
                     if (objElements[i].getAttribute('MPRMAT') != '*NONE') {
                        document.getElementById('FILL_Data').style.display = 'block';
                        cstrTduFill = '1';
                        document.getElementById('DEF_TduFill').checked = true;
                     }
                  } else {
                     document.getElementById('FILL_Data').style.display = 'block';
                  }
                  cstrFillLinCode = objElements[i].getAttribute('MPRLIN');
                  document.getElementById('FILL_DftLine').innerHTML = objElements[i].getAttribute('MPRLIN');
                  document.getElementById('FILL_SchPrty').value = objElements[i].getAttribute('MPRSCH');
                  document.getElementById('FILL_BchQnty').value = objElements[i].getAttribute('MPRBQY');
                  document.getElementById('FILL_YldPcnt').value = objElements[i].getAttribute('MPRYPC');
                  document.getElementById('FILL_PckPcnt').value = objElements[i].getAttribute('MPRPPC');
                  document.getElementById('FILL_YldValu').innerHTML = objElements[i].getAttribute('MPRYVL');
                  document.getElementById('FILL_PckValu').innerHTML = objElements[i].getAttribute('MPRPWE');
                  document.getElementById('FILL_BchValu').innerHTML = objElements[i].getAttribute('MPRBWE');
                  document.getElementById('FILL_ComMatl').value = '';
                  document.getElementById('FILL_ComQnty').value = '';
                  objFillPrdLine.style.display = 'block';
                  if (cstrDefineLine != '*NONE' && cstrFillLinCode == cstrDefineLine) {
                     cbolFillDflt = true;
                     objFillPrdLine.style.display = 'none';
                  }
               } else if (objElements[i].getAttribute('PTYCDE') == '*PACK') {
                  if (cstrDefineUsag == 'TDU') {
                     if (objElements[i].getAttribute('MPRMAT') != '*NONE') {
                        document.getElementById('PACK_Data').style.display = 'block';
                        cstrTduPack = '1';
                        document.getElementById('DEF_TduPack').checked = true;
                     }
                  } else {
                     document.getElementById('PACK_Data').style.display = 'block';
                  }
                  cstrPackLinCode = objElements[i].getAttribute('MPRLIN');
                  document.getElementById('PACK_DftLine').innerHTML = objElements[i].getAttribute('MPRLIN');
                  document.getElementById('PACK_CasPalt').value = objElements[i].getAttribute('MPRCPL');
                  document.getElementById('PACK_ComMatl').value = '';
                  document.getElementById('PACK_ComQnty').value = '';
                  objPackPrdLine.style.display = 'block';
                  if (cstrDefineLine != '*NONE' && cstrPackLinCode == cstrDefineLine) {
                     cbolPackDflt = true;
                     objPackPrdLine.style.display = 'none';
                  }
               } else if (objElements[i].getAttribute('PTYCDE') == '*FORM') {
                  document.getElementById('FORM_Data').style.display = 'block';
                  cstrFormLinCode = objElements[i].getAttribute('MPRLIN');
                  document.getElementById('FORM_DftLine').innerHTML = objElements[i].getAttribute('MPRLIN');
                  document.getElementById('FORM_BchQnty').value = objElements[i].getAttribute('MPRBQY');
                  document.getElementById('FORM_ComMatl').value = '';
                  document.getElementById('FORM_ComQnty').value = '';
                  objFormPrdLine.style.display = 'block';
                  if (cstrDefineLine != '*NONE' && cstrFormLinCode == cstrDefineLine) {
                     cbolFormDflt = true;
                     objFormPrdLine.style.display = 'none';
                  }
               }
            } else if (objElements[i].nodeName == 'MATLIN') {
               if (strPrdType == '*FILL') {
                  if (strLinCode != objElements[i].getAttribute('LINCDE')) {
                     if (cbolFillDflt == false) {
                        objFillPrdLine.options[objFillPrdLine.options.length] = new Option(objElements[i].getAttribute('LINNAM'),objElements[i].getAttribute('LINCDE'));
                        if (cstrFillLinCode == objElements[i].getAttribute('LINCDE')) {
                           objFillPrdLine.options[objFillPrdLine.options.length-1].selected = true;
                        }
                     }
                     if (strLinCode != '') {
                        objRow = objFillLinList.insertRow(-1);
                        objRow.setAttribute('ptycde',strPrdType);
                        objRow.setAttribute('lincde','*NONE');
                        objCell = objRow.insertCell(-1);
                        objCell.colSpan = 7;
                        objCell.align = 'center';
                        objCell.vAlign = 'center';
                        objCell.className = 'clsLabelHB';
                        objCell.style.whiteSpace = 'nowrap';
                     }
                     strLinCode = objElements[i].getAttribute('LINCDE');
                  }
                  objRow = objFillLinList.insertRow(-1);
               } else if (strPrdType == '*PACK') {
                  if (strLinCode != objElements[i].getAttribute('LINCDE')) {
                     if (cbolPackDflt == false) {
                        objPackPrdLine.options[objPackPrdLine.options.length] = new Option(objElements[i].getAttribute('LINNAM'),objElements[i].getAttribute('LINCDE'));
                        if (cstrPackLinCode == objElements[i].getAttribute('LINCDE')) {
                           objPackPrdLine.options[objPackPrdLine.options.length-1].selected = true;
                        }
                     }
                     if (strLinCode != '') {
                        objRow = objPackLinList.insertRow(-1);
                        objRow.setAttribute('ptycde',strPrdType);
                        objRow.setAttribute('lincde','*NONE');
                        objCell = objRow.insertCell(-1);
                        objCell.colSpan = 7;
                        objCell.align = 'center';
                        objCell.vAlign = 'center';
                        objCell.className = 'clsLabelHB';
                        objCell.style.whiteSpace = 'nowrap';
                     }
                     strLinCode = objElements[i].getAttribute('LINCDE');
                  }
                  objRow = objPackLinList.insertRow(-1);
               } else if (strPrdType == '*FORM') {
                  if (strLinCode != objElements[i].getAttribute('LINCDE')) {
                     if (cbolFormDflt == false) {
                        objFormPrdLine.options[objFormPrdLine.options.length] = new Option(objElements[i].getAttribute('LINNAM'),objElements[i].getAttribute('LINCDE'));
                        if (cstrFormLinCode == objElements[i].getAttribute('LINCDE')) {
                           objFormPrdLine.options[objFormPrdLine.options.length-1].selected = true;
                        }
                     }
                     if (strLinCode != '') {
                        objRow = objFormLinList.insertRow(-1);
                        objRow.setAttribute('ptycde',strPrdType);
                        objRow.setAttribute('lincde','*NONE');
                        objCell = objRow.insertCell(-1);
                        objCell.colSpan = 7;
                        objCell.align = 'center';
                        objCell.vAlign = 'center';
                        objCell.className = 'clsLabelHB';
                        objCell.style.whiteSpace = 'nowrap';
                     }
                     strLinCode = objElements[i].getAttribute('LINCDE');
                  }
                  objRow = objFormLinList.insertRow(-1);
               }
               cintLineCount++;
               objRow.setAttribute('ptycde',strPrdType);
               objRow.setAttribute('lincde',objElements[i].getAttribute('LINCDE'));
               objRow.setAttribute('lcocde',objElements[i].getAttribute('LCOCDE'));
               objRow.setAttribute('lcorra',objElements[i].getAttribute('LCORRA'));
               objRow.setAttribute('lincnt',cintLineCount);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBN';
               objCell.style.paddingLeft = '2px';
               objCell.style.paddingRight = '2px';
               objCell.style.whiteSpace = 'nowrap';
               objInput = document.createElement('input');
               objInput.type = 'checkbox';
               objInput.value = '';
               objInput.id = 'LCOCHK_'+cintLineCount;
               objInput.onfocus = function() {setSelect(this);};
               objInput.onclick = function() {doLineClick(this);};
               objInput.checked = false;
               objCell.appendChild(objInput);
               objCell.appendChild(document.createTextNode(objElements[i].getAttribute('LINNAM')+' - '+objElements[i].getAttribute('LCONAM')));
               if (objElements[i].getAttribute('LCORRA') != '*NONE') {
                  objInput.checked = true;
               }
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
               objInput = document.createElement('input');
               objInput.type = 'checkbox';
               objInput.value = '';
               objInput.id = 'LCODFT_'+cintLineCount;
               objInput.onfocus = function() {setSelect(this);};
               objInput.onclick = function() {doDefaultClick(this);};
               objInput.checked = false;
               objInput.disabled = true;
               if (objElements[i].getAttribute('LCORRA') != '*NONE') {
                  objInput.disabled = false;
               }
               objCell.appendChild(objInput);
               if (objElements[i].getAttribute('LCODFT') == '1') {
                  objInput.checked = true;
               }
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
               objSelect = document.createElement('select');
               objSelect.id = 'LCORRA_'+cintLineCount;
               objSelect.className = 'clsInputNN';
               objSelect.onchange = function() {doRateChange(this);};
               objSelect.selectedIndex = -1;
               objSelect.options[0] = new Option('** Select Run Rate **','*NONE');
               objSelect.options[0].setAttribute('rraeff','');
               objSelect.options[0].setAttribute('rrawas','');
               objSelect.options[0].selected = true;
               objSelect.disabled = true;
               if (objElements[i].getAttribute('LCORRA') != '*NONE') {
                  objSelect.disabled = false;
               }
               objCell.appendChild(objSelect);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.id = 'RRAEFF_'+cintLineCount;
               objCell.className = 'clsLabelBN';
               objCell.innerHTML = '';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.id = 'RRAWAS_'+cintLineCount;
               objCell.className = 'clsLabelBN';
               objCell.innerHTML = '';
               objCell.style.whiteSpace = 'nowrap';
               if (strPrdType == '*FILL') {
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.vAlign = 'center';
                  objCell.className = 'clsLabelBN';
                  objCell.style.whiteSpace = 'nowrap';
                  objInput = document.createElement('input');
                  objInput.type = 'text';
                  objInput.value = '';
                  if (objElements[i].getAttribute('LCORRA') != '*NONE') {
                     objInput.value = objElements[i].getAttribute('LCOEFF');
                  }
                  objInput.id = 'LCOEFF_'+cintLineCount;
                  objInput.size = 9;
                  objInput.maxLength = 9;
                  objInput.align = 'left';
                  objInput.className = 'clsInputNN';
                  objInput.onfocus = function() {setSelect(this);};
                  objInput.onblur = function() {validateNumber(this,2,false);};
                  objInput.disabled = true;
                  if (objElements[i].getAttribute('LCORRA') != '*NONE') {
                     objInput.disabled = false;
                  }
                  objCell.appendChild(objInput);
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.vAlign = 'center';
                  objCell.className = 'clsLabelBN';
                  objCell.style.whiteSpace = 'nowrap';
                  objInput = document.createElement('input');
                  objInput.type = 'text';
                  objInput.value = '';
                  if (objElements[i].getAttribute('LCORRA') != '*NONE') {
                     objInput.value = objElements[i].getAttribute('LCOWAS');
                  }
                  objInput.id = 'LCOWAS_'+cintLineCount;
                  objInput.size = 9;
                  objInput.maxLength = 9;
                  objInput.align = 'left';
                  objInput.className = 'clsInputNN';
                  objInput.onfocus = function() {setSelect(this);};
                  objInput.onblur = function() {validateNumber(this,2,false);};
                  objInput.disabled = true;
                  if (objElements[i].getAttribute('LCORRA') != '*NONE') {
                     objInput.disabled = false;
                  }
                  objCell.appendChild(objInput);
               }
            } else if (objElements[i].nodeName == 'MATRRA') {
               if (strPrdType == '*FILL') {
                  objSelect.options[objSelect.options.length] = new Option(objElements[i].getAttribute('RRANAM'),objElements[i].getAttribute('RRACDE'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rraeff',objElements[i].getAttribute('RRAEFF'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rrawas',objElements[i].getAttribute('RRAWAS'));
                  if (objRow.getAttribute('lcorra') == objElements[i].getAttribute('RRACDE')) {
                     objSelect.options[objSelect.options.length-1].selected = true;
                     document.getElementById('RRAEFF_'+cintLineCount).innerHTML = objElements[i].getAttribute('RRAEFF');
                     document.getElementById('RRAWAS_'+cintLineCount).innerHTML = objElements[i].getAttribute('RRAWAS');
                  }
               } else if (strPrdType == '*PACK') {
                  objSelect.options[objSelect.options.length] = new Option(objElements[i].getAttribute('RRANAM'),objElements[i].getAttribute('RRACDE'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rraeff',objElements[i].getAttribute('RRAEFF'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rrawas',objElements[i].getAttribute('RRAWAS'));
                  if (objRow.getAttribute('lcorra') == objElements[i].getAttribute('RRACDE')) {
                     objSelect.options[objSelect.options.length-1].selected = true;
                     document.getElementById('RRAEFF_'+cintLineCount).innerHTML = objElements[i].getAttribute('RRAEFF');
                     document.getElementById('RRAWAS_'+cintLineCount).innerHTML = objElements[i].getAttribute('RRAWAS');
                  }
               } else if (strPrdType == '*FORM') {
                  objSelect.options[objSelect.options.length] = new Option(objElements[i].getAttribute('RRANAM'),objElements[i].getAttribute('RRACDE'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rraeff',objElements[i].getAttribute('RRAEFF'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rrawas',objElements[i].getAttribute('RRAWAS'));
                  if (objRow.getAttribute('lcorra') == objElements[i].getAttribute('RRACDE')) {
                     objSelect.options[objSelect.options.length-1].selected = true;
                     document.getElementById('RRAEFF_'+cintLineCount).innerHTML = objElements[i].getAttribute('RRAEFF');
                     document.getElementById('RRAWAS_'+cintLineCount).innerHTML = objElements[i].getAttribute('RRAWAS');
                  }
               }
            } else if (objElements[i].nodeName == 'MATCOM') {
               if (strPrdType == '*FILL') {
                  objRow = objFillComList.insertRow(-1);
               } else if (strPrdType == '*PACK') {
                  objRow = objPackComList.insertRow(-1);
               } else if (strPrdType == '*FORM') {
                  objRow = objFormComList.insertRow(-1);
               }
               cintCompCount++;
               objRow.setAttribute('ptycde',strPrdType);
               objRow.setAttribute('comflg','1');
               objRow.setAttribute('comcde',objElements[i].getAttribute('COMCDE'));
               objRow.setAttribute('comcnt',cintCompCount);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBN';
               objCell.style.paddingLeft = '2px';
               objCell.style.paddingRight = '2px';
               objCell.style.whiteSpace = 'nowrap';
               objInput = document.createElement('A');
               objInput.className = 'clsSelect';
               objInput.onclick = function() {doCompDelete(this);};
               objInput.appendChild(document.createTextNode('Delete'));
               objCell.appendChild(objInput);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBN';
               objCell.innerHTML = '<p>('+objElements[i].getAttribute('COMCDE')+') '+objElements[i].getAttribute('COMNAM')+'</p>';
               objCell.style.paddingLeft = '2px';
               objCell.style.paddingRight = '2px';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
               objInput = document.createElement('input');
               objInput.type = 'text';
               objInput.value = objElements[i].getAttribute('COMQTY');
               objInput.id = 'COMQTY_'+cintCompCount;
               objInput.size = 9;
               objInput.maxLength = 9;
               objInput.align = 'left';
               objInput.className = 'clsInputNN';
               objInput.onfocus = function() {setSelect(this);};
               objInput.onblur = function() {validateNumber(this,0,false);};
               objCell.appendChild(objInput);
            }
         }
         var intFillWidth = 0;
         var intPackWidth = 0;
         var intFormWidth = 0;
         for (var i=1;i<=cintLineCount;i++) {
            if (document.getElementById('LCORRA_'+i).parentNode.parentNode.getAttribute('lintyp') == '*FILL') {
               if (document.getElementById('LCORRA_'+i).offsetWidth > intFillWidth) {
                  intFillWidth = document.getElementById('LCORRA_'+i).offsetWidth;
               }
            } else if (document.getElementById('LCORRA_'+i).parentNode.parentNode.getAttribute('lintyp') == '*PACK') {
               if (document.getElementById('LCORRA_'+i).offsetWidth > intPackWidth) {
                  intPackWidth = document.getElementById('LCORRA_'+i).offsetWidth;
               }
            } else if (document.getElementById('LCORRA_'+i).parentNode.parentNode.getAttribute('lintyp') == '*FORM') {
               if (document.getElementById('LCORRA_'+i).offsetWidth > intFormWidth) {
                  intFormWidth = document.getElementById('LCORRA_'+i).offsetWidth;
               }
            }
         }
         for (var i=1;i<=cintLineCount;i++) {
            if (document.getElementById('LCORRA_'+i).parentNode.parentNode.getAttribute('lintyp') == '*FILL') {
               document.getElementById('LCORRA_'+i).style.width = intFillWidth;
            } else if (document.getElementById('LCORRA_'+i).parentNode.parentNode.getAttribute('lintyp') == '*PACK') {
               document.getElementById('LCORRA_'+i).style.width = intPackWidth;
            } else if (document.getElementById('LCORRA_'+i).parentNode.parentNode.getAttribute('lintyp') == '*FORM') {
               document.getElementById('LCORRA_'+i).style.width = intFormWidth;
            }
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objFillPrdLine = document.getElementById('FILL_PrdLine');
      var objPackPrdLine = document.getElementById('PACK_PrdLine');
      var objFormPrdLine = document.getElementById('FORM_PrdLine');
      var objFillLinList = document.getElementById('FILL_LinList');
      var objPackLinList = document.getElementById('PACK_LinList');
      var objFormLinList = document.getElementById('FORM_LinList');
      var objFillComList = document.getElementById('FILL_ComList');
      var objPackComList = document.getElementById('PACK_ComList');
      var objFormComList = document.getElementById('FORM_ComList');
      var bolFill = false;
      var bolPack = false;
      var bolForm = false;
      var bolComp = false;
      var bolLinFound = false;
      var bolDftFound = false;
      var intDftCount;
      var objSelect;
      var objRow;
      var intRowCnt;
      var objLines = new Array();
      var strLinCde = '';
      var strMessage = '';
      if (cstrDefineUsag == 'TDU') {
         if (document.getElementById('DEF_TduFill').checked == false && document.getElementById('DEF_TduPack').checked == false) {
            alert('TDU material must have Filling and/or Packing selected');
            return;
         }
         if (document.getElementById('DEF_TduFill').checked == true) {
            bolFill = true;
         }
         if (document.getElementById('DEF_TduPack').checked == true) {
            bolPack = true;
         }
         bolComp = true;
      } else if (cstrDefineUsag == 'MPO') {
         bolFill = true;
         bolComp = true;
      } else if (cstrDefineUsag == 'PCH') {
         bolForm = true;
         bolComp = true;
      }
      if (bolFill == true) {
         if (cbolFillDflt == true) {
            bolLinFound = false;
            for (var i=0;i<objFillLinList.rows.length;i++) {
               objRow = objFillLinList.rows[i];
               if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
                  intRowCnt = objRow.getAttribute('lincnt');
                  if (objRow.getAttribute('lincde') == cstrDefineLine) {
                     if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                        bolLinFound = true;
                        break;
                     }
                  }
               }
            }
            if (bolLinFound == false) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Default filling line must be a selected filling line configuration';
            }
         } else {
            if (objFillPrdLine.selectedIndex == -1 || objFillPrdLine.options[objFillPrdLine.selectedIndex].value == '*NONE') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Default filling line must be selected';
            } else {
               bolLinFound = false;
               for (var i=0;i<objFillLinList.rows.length;i++) {
                  objRow = objFillLinList.rows[i];
                  if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
                     intRowCnt = objRow.getAttribute('lincnt');
                     if (objRow.getAttribute('lincde') == objFillPrdLine.options[objFillPrdLine.selectedIndex].value) {
                        if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                           bolLinFound = true;
                           break;
                        }
                     }
                  }
               }
               if (bolLinFound == false) {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + 'Default filling line must be a selected filling line configuration';
               }
            }
         }
         if (document.getElementById('FILL_SchPrty').value == '' || document.getElementById('FILL_SchPrty').value < 1 || document.getElementById('FILL_SchPrty').value > 100) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Filling scheduling priority must be range 1 to 100';
         }
         if (document.getElementById('FILL_BchQnty').value == '' || document.getElementById('FILL_BchQnty').value < 1) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Filling batch case quantity must be greater than zero';
         }
         if (document.getElementById('FILL_YldPcnt').value == '' || document.getElementById('FILL_YldPcnt').value < 1 || document.getElementById('FILL_YldPcnt').value > 100) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Filling yield percentage must be in range 1 to 100';
         }
         if (document.getElementById('FILL_PckPcnt').value == '' || document.getElementById('FILL_PckPcnt').value < 1 || document.getElementById('FILL_PckPcnt').value > 100) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Filling pack weight percentage must be in range 1 to 100';
         }
         objLines.length = 0;
         for (var i=0;i<objFillLinList.rows.length;i++) {
            objRow = objFillLinList.rows[i];
            if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
               intRowCnt = objRow.getAttribute('lincnt');
               if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                  bolLinFound = false;
                  for (var j=0;j<objLines.length;j++) {
                     if (objLines[j] == objRow.getAttribute('lincde')) {
                        bolLinFound = true;
                        break;
                     }
                  }
                  if (!bolLinFound) {
                     objLines[objLines.length] = objRow.getAttribute('lincde');
                  }
                  objSelect = document.getElementById('LCORRA_'+intRowCnt);
                  if (objSelect.selectedIndex == -1 || objSelect.options[objSelect.selectedIndex].value == '*NONE') {
                     if (strMessage != '') {strMessage = strMessage + '\r\n';}
                     strMessage = strMessage + 'Filling line configuration ('+objRow.getAttribute('lincde')+' / '+objRow.getAttribute('lcocde')+') run rate must be selected';
                  } else {
                     if (document.getElementById('LCOEFF_'+intRowCnt).value == '' || document.getElementById('LCOEFF_'+intRowCnt).value < 0 || document.getElementById('LCOEFF_'+intRowCnt).value > 100) {
                        if (strMessage != '') {strMessage = strMessage + '\r\n';}
                        strMessage = strMessage + 'Filling line configuration ('+objRow.getAttribute('lincde')+' / '+objRow.getAttribute('lcocde')+') override efficiency percentage must be in range 0 to 100';
                     }
                     if (document.getElementById('LCOWAS_'+intRowCnt).value == '' || document.getElementById('LCOWAS_'+intRowCnt).value < 0 || document.getElementById('LCOWAS_'+intRowCnt).value > 100) {
                        if (strMessage != '') {strMessage = strMessage + '\r\n';}
                        strMessage = strMessage + 'Filling line configuration ('+objRow.getAttribute('lincde')+' / '+objRow.getAttribute('lcocde')+') override wastage percentage must be in range 0 to 100';
                     }
                  }
               }
            }
         }
         for (i=0;i<objLines.length;i++) {
            bolDftFound = false;
            intDftCount = 0;
            for (var j=0;j<objFillLinList.rows.length;j++) {
               objRow = objFillLinList.rows[j];
               if (objRow.getAttribute('lincde') == objLines[i]) {
                  intRowCnt = objRow.getAttribute('lincnt');
                  if (document.getElementById('LCODFT_'+intRowCnt).checked == true) {
                     bolDftFound = true;
                     intDftCount++;
                  }
               }
            }
            if (bolDftFound == false) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Filling line ('+objLines[i]+') must have a default configuration selected';
            } else if (intDftCount > 1) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Filling line ('+objLines[i]+') must only have one default configuration selected';
            }
         }
         for (var i=0;i<objFillComList.rows.length;i++) {
            objRow = objFillComList.rows[i];
            if (objRow.getAttribute('comflg') == '1') {
               intRowCnt = objRow.getAttribute('comcnt');
               if (document.getElementById('COMQTY_'+intRowCnt).value == '' || document.getElementById('COMQTY_'+intRowCnt).value < 1) {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + 'Filling component quantity must be greater than zero';
               }
            }
         }
      }
      if (bolPack == true) {
         if (cbolFillPack == true) {
            bolLinFound = false;
            for (var i=0;i<objPackLinList.rows.length;i++) {
               objRow = objPackLinList.rows[i];
               if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
                  intRowCnt = objRow.getAttribute('lincnt');
                  if (objRow.getAttribute('lincde') == cstrDefineLine) {
                     if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                        bolLinFound = true;
                        break;
                     }
                  }
               }
            }
            if (bolLinFound == false) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Default packing line must be a selected packing line configuration';
            }
         } else {
            if (objPackPrdLine.selectedIndex == -1 || objPackPrdLine.options[objPackPrdLine.selectedIndex].value == '*NONE') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Default packing line must be selected';
            } else {
               bolLinFound = false;
               for (var i=0;i<objPackLinList.rows.length;i++) {
                  objRow = objPackLinList.rows[i];
                  if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
                     intRowCnt = objRow.getAttribute('lincnt');
                     if (objRow.getAttribute('lincde') == objPackPrdLine.options[objPackPrdLine.selectedIndex].value) {
                        if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                           bolLinFound = true;
                           break;
                        }
                     }
                  }
               }
               if (bolLinFound == false) {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + 'Default packing line must be a selected packing line configuration';
               }
            }
         }
         if (document.getElementById('PACK_SchPrty').value == '' || document.getElementById('PACK_SchPrty').value < 1 || document.getElementById('PACK_SchPrty').value > 100) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Packing scheduling priority must be range 1 to 100';
         }
         if (document.getElementById('PACK_CasPalt').value == '' || document.getElementById('PACK_CasPalt').value < 1) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Packing cases per pallet must be greater than zero';
         }
         objLines.length = 0;
         for (var i=0;i<objPackLinList.rows.length;i++) {
            objRow = objPackLinList.rows[i];
            if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
               intRowCnt = objRow.getAttribute('lincnt');
               if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                  bolLinFound = false;
                  for (var j=0;j<objLines.length;j++) {
                     if (objLines[j] == objRow.getAttribute('lincde')) {
                        bolLinFound = true;
                        break;
                     }
                  }
                  if (!bolLinFound) {
                     objLines[objLines.length] = objRow.getAttribute('lincde');
                  }
                  objSelect = document.getElementById('LCORRA_'+intRowCnt);
                  if (objSelect.selectedIndex == -1 || objSelect.options[objSelect.selectedIndex].value == '*NONE') {
                     if (strMessage != '') {strMessage = strMessage + '\r\n';}
                     strMessage = strMessage + 'Packing line configuration ('+objRow.getAttribute('lincde')+' / '+objRow.getAttribute('lcocde')+') run rate must be selected';
                  }
               }
            }
         }
         for (i=0;i<objLines.length;i++) {
            bolDftFound = false;
            intDftCount = 0;
            for (var j=0;j<objPackLinList.rows.length;j++) {
               objRow = objPackLinList.rows[j];
               if (objRow.getAttribute('lincde') == objLines[i]) {
                  intRowCnt = objRow.getAttribute('lincnt');
                  if (document.getElementById('LCODFT_'+intRowCnt).checked == true) {
                     bolDftFound = true;
                     intDftCount++;
                  }
               }
            }
            if (bolDftFound == false) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Packing line ('+objLines[i]+') must have a default configuration selected';
            } else if (intDftCount > 1) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Packing line ('+objLines[i]+') must only have one default configuration selected';
            }
         }
         for (var i=0;i<objPackComList.rows.length;i++) {
            objRow = objPackComList.rows[i];
            if (objRow.getAttribute('comflg') == '1') {
               intRowCnt = objRow.getAttribute('comcnt');
               if (document.getElementById('COMQTY_'+intRowCnt).value == '' || document.getElementById('COMQTY_'+intRowCnt).value < 1) {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + 'Packing component quantity must be greater than zero';
               }
            }
         }
      }
      if (bolForm == true) {
         if (cbolFormDflt == true) {
            bolLinFound = false;
            for (var i=0;i<objFormLinList.rows.length;i++) {
               objRow = objFormLinList.rows[i];
               if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
                  intRowCnt = objRow.getAttribute('lincnt');
                  if (objRow.getAttribute('lincde') == cstrDefineLine) {
                     if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                        bolLinFound = true;
                        break;
                     }
                  }
               }
            }
            if (bolLinFound == false) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Default forming line must be a selected forming line configuration';
            }
         } else {
            if (objFormPrdLine.selectedIndex == -1 || objFormPrdLine.options[objFormPrdLine.selectedIndex].value == '*NONE') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
                strMessage = strMessage + 'Default forming line must be selected';
            } else {
               bolLinFound = false;
               for (var i=0;i<objFormLinList.rows.length;i++) {
                  objRow = objFormLinList.rows[i];
                  if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
                     intRowCnt = objRow.getAttribute('lincnt');
                     if (objRow.getAttribute('lincde') == objFormPrdLine.options[objFormPrdLine.selectedIndex].value) {
                        if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                           bolLinFound = true;
                           break;
                        }
                     }
                  }
               }
               if (bolLinFound == false) {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + 'Default forming line must be a selected forming line configuration';
               }
            }
         }
         if (document.getElementById('FORM_SchPrty').value == '' || document.getElementById('FORM_SchPrty').value < 1 || document.getElementById('FORM_SchPrty').value > 100) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Forming scheduling priority must be range 1 to 100';
         }
         if (document.getElementById('FORM_BchQnty').value == '' || document.getElementById('FORM_BchQnty').value < 1) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Forming batch lot quantity must be greater than zero';
         }
         objLines.length = 0;
         for (var i=0;i<objFormLinList.rows.length;i++) {
            objRow = objFormLinList.rows[i];
            if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
               intRowCnt = objRow.getAttribute('lincnt');
               if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                  bolLinFound = false;
                  for (var j=0;j<objLines.length;j++) {
                     if (objLines[j] == objRow.getAttribute('lincde')) {
                        bolLinFound = true;
                        break;
                     }
                  }
                  if (!bolLinFound) {
                     objLines[objLines.length] = objRow.getAttribute('lincde');
                  }
                  objSelect = document.getElementById('LCORRA_'+intRowCnt);
                  if (objSelect.selectedIndex == -1 || objSelect.options[objSelect.selectedIndex].value == '*NONE') {
                     if (strMessage != '') {strMessage = strMessage + '\r\n';}
                     strMessage = strMessage + 'Forming line configuration ('+objRow.getAttribute('lincde')+' / '+objRow.getAttribute('lcocde')+') run rate must be selected';
                  }
               }
            }
         }
         for (i=0;i<objLines.length;i++) {
            bolDftFound = false;
            intDftCount = 0;
            for (var j=0;j<objFormLinList.rows.length;j++) {
               objRow = objFormLinList.rows[j];
               if (objRow.getAttribute('lincde') == objLines[i]) {
                  intRowCnt = objRow.getAttribute('lincnt');
                  if (document.getElementById('LCODFT_'+intRowCnt).checked == true) {
                     bolDftFound = true;
                     intDftCount++;
                  }
               }
            }
            if (bolDftFound == false) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Forming line ('+objLines[i]+') must have a default configuration selected';
            } else if (intDftCount > 1) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Forming line ('+objLines[i]+') must only have one default configuration selected';
            }
         }
         for (var i=0;i<objFormComList.rows.length;i++) {
            objRow = objFormComList.rows[i];
            if (objRow.getAttribute('comflg') == '1') {
               intRowCnt = objRow.getAttribute('comcnt');
               if (document.getElementById('COMQTY_'+intRowCnt).value == '' || document.getElementById('COMQTY_'+intRowCnt).value < 1) {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + 'Forming component quantity must be greater than zero';
               }
            }
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PSA_REQUEST ACTION="*UPDDEF" MATCDE="'+fixXML(cstrDefineCode)+'">';
      if (bolFill == true) {
         strXML = strXML+'<MATPTY';
         strXML = strXML+' PTYCDE="*FILL"';
         if (cstrDefineLine != '*NONE' && cstrFillLinCode == cstrDefineLine) {
            strXML = strXML+' MPRLIN="'+fixXML(cstrDefineLine)+'"';
         } else {
            strXML = strXML+' MPRLIN="'+fixXML(objFillPrdLine.options[objFillPrdLine.selectedIndex].value)+'"';
         }
         strXML = strXML+' MPRSCH="'+fixXML(document.getElementById('FILL_SchPrty').value)+'"';
         strXML = strXML+' MPRBQY="'+fixXML(document.getElementById('FILL_BchQnty').value)+'"';
         strXML = strXML+' MPRYPC="'+fixXML(document.getElementById('FILL_YldPcnt').value)+'"';
         strXML = strXML+' MPRRPC="'+fixXML(document.getElementById('FILL_PckPcnt').value)+'">';
         for (var i=0;i<objFillLinList.rows.length;i++) {
            objRow = objFillLinList.rows[i];
            if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
               intRowCnt = objRow.getAttribute('lincnt');
               if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                  objSelect = document.getElementById('LCORRA_'+intRowCnt);
                  strXML = strXML+'<MATLIN';
                  strXML = strXML+' LINCDE="'+fixXML(objRow.getAttribute('lincde'))+'"';
                  strXML = strXML+' LCOCDE="'+fixXML(objRow.getAttribute('lcocde'))+'"';
                  if (document.getElementById('LCODFT_'+intRowCnt).checked == true) {
                     strXML = strXML+' LCODFT="'+fixXML('1')+'"';
                  } else {
                     strXML = strXML+' LCODFT="'+fixXML('0')+'"';
                  }
                  strXML = strXML+' LCORRA="'+fixXML(objSelect.options[objSelect.selectedIndex].value)+'"';
                  strXML = strXML+' LCOEFF="'+fixXML(document.getElementById('LCOEFF_'+intRowCnt).value)+'"';
                  strXML = strXML+' LCOWAS="'+fixXML(document.getElementById('LCOWAS_'+intRowCnt).value)+'"';
                  strXML = strXML+'/>';
               }
            }
         }
         for (var i=0;i<objFillComList.rows.length;i++) {
            objRow = objFillComList.rows[i];
            if (objRow.getAttribute('comflg') == '1') {
               intRowCnt = objRow.getAttribute('comcnt');
               strXML = strXML+'<MATCOM';
               strXML = strXML+' COMCDE="'+fixXML(objRow.getAttribute('comcde'))+'"';
               strXML = strXML+' COMQTY="'+fixXML(document.getElementById('COMQTY_'+intRowCnt).value)+'"';
               strXML = strXML+'/>';
            }
         }
         strXML = strXML+'</MATPTY>';
      }
      if (bolPack == true) {
         strXML = strXML+'<MATPTY';
         strXML = strXML+' PTYCDE="*PACK"';
         if (cstrDefineLine != '*NONE' && cstrPackLinCode == cstrDefineLine) {
            strXML = strXML+' MPRLIN="'+fixXML(cstrDefineLine)+'"';
         } else {
            strXML = strXML+' MPRLIN="'+fixXML(objPackPrdLine.options[objPackPrdLine.selectedIndex].value)+'"';
         }
         strXML = strXML+' MPRSCH="'+fixXML(document.getElementById('PACK_SchPrty').value)+'"';
         strXML = strXML+' MPRCPL="'+fixXML(document.getElementById('PACK_CasPalt').value)+'">';
         for (var i=0;i<objPackLinList.rows.length;i++) {
            objRow = objPackLinList.rows[i];
            if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
               intRowCnt = objRow.getAttribute('lincnt');
               if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                  objSelect = document.getElementById('LCORRA_'+intRowCnt);
                  strXML = strXML+'<MATLIN';
                  strXML = strXML+' LINCDE="'+fixXML(objRow.getAttribute('lincde'))+'"';
                  strXML = strXML+' LCOCDE="'+fixXML(objRow.getAttribute('lcocde'))+'"';
                  if (document.getElementById('LCODFT_'+intRowCnt).checked == true) {
                     strXML = strXML+' LCODFT="'+fixXML('1')+'"';
                  } else {
                     strXML = strXML+' LCODFT="'+fixXML('1')+'"';
                  }
                  strXML = strXML+' LCORRA="'+fixXML(objSelect.options[objSelect.selectedIndex].value)+'"';
                  strXML = strXML+'/>';
               }
            }
         }
         for (var i=0;i<objPackComList.rows.length;i++) {
            objRow = objPackComList.rows[i];
            if (objRow.getAttribute('comflg') == '1') {
               intRowCnt = objRow.getAttribute('comcnt');
               strXML = strXML+'<MATCOM';
               strXML = strXML+' COMCDE="'+fixXML(objRow.getAttribute('comcde'))+'"';
               strXML = strXML+' COMQTY="'+fixXML(document.getElementById('COMQTY_'+intRowCnt).value)+'"';
               strXML = strXML+'/>';
            }
         }
         strXML = strXML+'</MATPTY>';
      }
      if (bolForm == true) {
         strXML = strXML+'<MATPTY';
         strXML = strXML+' PTYCDE="*FORM"';
         if (cstrDefineLine != '*NONE' && cstrFormLinCode == cstrDefineLine) {
            strXML = strXML+' MPRLIN="'+fixXML(cstrDefineLine)+'"';
         } else {
            strXML = strXML+' MPRLIN="'+fixXML(objFormPrdLine.options[objFormPrdLine.selectedIndex].value)+'"';
         }
         strXML = strXML+' MPRSCH="'+fixXML(document.getElementById('FORM_SchPrty').value)+'"';
         strXML = strXML+' MPRBQY="'+fixXML(document.getElementById('FORM_BchQnty').value)+'">';
         for (var i=0;i<objFormLinList.rows.length;i++) {
            objRow = objFormLinList.rows[i];
            if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
               intRowCnt = objRow.getAttribute('lincnt');
               if (document.getElementById('LCOCHK_'+intRowCnt).checked == true) {
                  objSelect = document.getElementById('LCORRA_'+intRowCnt);
                  strXML = strXML+'<MATLIN';
                  strXML = strXML+' LINCDE="'+fixXML(objRow.getAttribute('lincde'))+'"';
                  strXML = strXML+' LCOCDE="'+fixXML(objRow.getAttribute('lcocde'))+'"';
                  if (document.getElementById('LCODFT_'+intRowCnt).checked == true) {
                     strXML = strXML+' LCODFT="'+fixXML('1')+'"';
                  } else {
                     strXML = strXML+' LCODFT="'+fixXML('1')+'"';
                  }
                  strXML = strXML+' LCORRA="'+fixXML(objSelect.options[objSelect.selectedIndex].value)+'"';
                  strXML = strXML+'/>';
               }
            }
         }
         for (var i=0;i<objFormComList.rows.length;i++) {
            objRow = objFormComList.rows[i];
            if (objRow.getAttribute('comflg') == '1') {
               intRowCnt = objRow.getAttribute('comcnt');
               strXML = strXML+'<MATCOM';
               strXML = strXML+' COMCDE="'+fixXML(objRow.getAttribute('comcde'))+'"';
               strXML = strXML+' COMQTY="'+fixXML(document.getElementById('COMQTY_'+intRowCnt).value)+'"';
               strXML = strXML+'/>';
            }
         }
         strXML = strXML+'</MATPTY>';
      }
      strXML = strXML+'</PSA_REQUEST>'
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>psa_mat_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
      if (!processForm()) {return;}
      if (checkChange() == false) {return;}
      displayScreen('dspSelect');
      document.getElementById('SEL_SelCode').focus();
   }
   function doTduFillClick(objCheck) {
      if (objCheck.checked == false) {
         cstrTduFill = '0';
         document.getElementById('FILL_Data').style.display = 'none';
      } else {
         cstrTduFill = '1';
         document.getElementById('FILL_Data').style.display = 'block';
      }
   }
   function doTduPackClick(objCheck) {
      if (objCheck.checked == false) {
         cstrTduPack = '0';
         document.getElementById('PACK_Data').style.display = 'none';
      } else {
         cstrTduPack = '1';
         document.getElementById('PACK_Data').style.display = 'block';
      }
   }
   function doDefaultClick(objCheck) {
      var strPtyCde = objCheck.parentNode.parentNode.getAttribute('ptycde');
      var strLinCde = objCheck.parentNode.parentNode.getAttribute('lincde');
      var strLinCnt = objCheck.parentNode.parentNode.getAttribute('lincnt');
      var objTable;
      var objRow;
      var strRowCnt;
      if (strPtyCde == '*FILL') {
         objTable = document.getElementById('FILL_LinList');
      } else if (strPtyCde == '*PACK') {
         objTable = document.getElementById('PACK_LinList');
      }  else if (strPtyCde == '*FORM') {
         objTable = document.getElementById('FORM_LinList');
      }
      if (objCheck.checked == true) {
         for (var i=0;i<objTable.rows.length;i++) {
            objRow = objTable.rows[i];
            if (objRow.getAttribute('lincde') != null && objRow.getAttribute('lincde') != '') {
               strRowCnt = objRow.getAttribute('lincnt');
               if (objRow.getAttribute('lincde') == strLinCde && strRowCnt != strLinCnt) {
                  document.getElementById('LCODFT_'+strRowCnt).checked = false;
               }
            }
         }
      }
   }
   function doLineClick(objCheck) {
      var strPtyCde = objCheck.parentNode.parentNode.getAttribute('ptycde');
      var strLinCnt = objCheck.parentNode.parentNode.getAttribute('lincnt');
      if (objCheck.checked == false) {
         document.getElementById('LCODFT_'+strLinCnt).disabled = true;
         document.getElementById('LCORRA_'+strLinCnt).disabled = true;
         document.getElementById('RRAEFF_'+strLinCnt).disabled = true;
         document.getElementById('RRAWAS_'+strLinCnt).disabled = true;
         if (strPtyCde == '*FILL') {
            document.getElementById('LCOEFF_'+strLinCnt).disabled = true;
            document.getElementById('LCOWAS_'+strLinCnt).disabled = true;
         }
         document.getElementById('LCODFT_'+strLinCnt).checked = false;
         document.getElementById('LCORRA_'+strLinCnt).selectedIndex = 0;
         doRateChange(document.getElementById('LCORRA_'+strLinCnt));
      } else {
         document.getElementById('LCODFT_'+strLinCnt).disabled = false;
         document.getElementById('LCORRA_'+strLinCnt).disabled = false;
         document.getElementById('RRAEFF_'+strLinCnt).disabled = false;
         document.getElementById('RRAWAS_'+strLinCnt).disabled = false;
         if (strPtyCde == '*FILL') {
            document.getElementById('LCOEFF_'+strLinCnt).disabled = false;
            document.getElementById('LCOWAS_'+strLinCnt).disabled = false;
         }
         doRateChange(document.getElementById('LCORRA_'+strLinCnt));
      }
   }
   function doRateChange(objSelect) {
      var strPtyCde = objSelect.parentNode.parentNode.getAttribute('ptycde');
      var strLinCnt = objSelect.parentNode.parentNode.getAttribute('lincnt');
      document.getElementById('RRAEFF_'+strLinCnt).innerHTML = objSelect.options[objSelect.selectedIndex].getAttribute('rraeff');
      document.getElementById('RRAWAS_'+strLinCnt).innerHTML = objSelect.options[objSelect.selectedIndex].getAttribute('rrawas');
      if (strPtyCde == '*FILL') {
         document.getElementById('LCOEFF_'+strLinCnt).value = objSelect.options[objSelect.selectedIndex].getAttribute('rraeff');
         document.getElementById('LCOWAS_'+strLinCnt).value = objSelect.options[objSelect.selectedIndex].getAttribute('rrawas');
      }
   }
   function doCompAdd(strType) {
      if (!processForm()) {return;}
      var objTable;
      var objRow;
      var objCell;
      var objInput;
      var bolFound = false;
      var strComCode = '';
      var strComQnty = '';
      if (strType == '*FILL') {
         if (document.getElementById('FILL_ComMatl').value == '') {
            alert('Filling component must be entered');
            return;
         }
         if (document.getElementById('FILL_ComQnty').value == '') {
            alert('Filling component quantity must be entered');
            return;
         }
         strComCode = document.getElementById('FILL_ComMatl').value;
         strComQnty = document.getElementById('FILL_ComQnty').value;
         objTable = document.getElementById('FILL_ComList');
      } else if (strType == '*PACK') {
         if (document.getElementById('PACK_ComMatl').value == '') {
            alert('Packing component must be entered');
            return;
         }
         if (document.getElementById('PACK_ComQnty').value == '') {
            alert('Packing component quantity must be entered');
            return;
         }
         strComCode = document.getElementById('PACK_ComMatl').value;
         strComQnty = document.getElementById('PACK_ComQnty').value;
         objTable = document.getElementById('PACK_ComList');
      } else if (strType == '*FORM') {
         if (document.getElementById('FORM_ComMatl').value == '') {
            alert('Forming component must be entered');
            return;
         }
         if (document.getElementById('FORM_ComQnty').value == '') {
            alert('Forming component quantity must be entered');
            return;
         }
         strComCode = document.getElementById('FORM_ComMatl').value;
         strComQnty = document.getElementById('FORM_ComQnty').value;
         objTable = document.getElementById('FORM_ComList');
      }
      bolFound = false;
      for (var i=2;i<objTable.rows.length;i++) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('comcde') == strComCode) {
            if (objRow.getAttribute('comflg') == '1') {
               alert('Component already specified');
               return;
            }
            bolFound = true;
            break;
         }
      }
      if (!bolFound) {
         var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
         strXML = strXML+'<PSA_REQUEST ACTION="*CHKCOM"';
         strXML = strXML+' PTYCDE="'+fixXML(strType)+'"';
         strXML = strXML+' COMCDE="'+fixXML(strComCode)+'"';
         strXML = strXML+' COMQTY="'+fixXML(strComQnty)+'"';
         strXML = strXML+'/>';
         doActivityStart(document.body);
         window.setTimeout('requestCompAccept(\''+strXML+'\');',10);
      } else {
         objRow.setAttribute('comflg','1');
         objRow.style.display = 'block';
         document.getElementById('COMQTY_'+objRow.getAttribute('comcnt')).value = strComQnty;
         if (strType == '*FILL') {
            document.getElementById('FILL_ComMatl').value = '';
            document.getElementById('FILL_ComQnty').value = '';
         } else if (strType == '*PACK') {
            document.getElementById('PACK_ComMatl').value = '';
            document.getElementById('PACK_ComQnty').value = '';
         } else if (strType == '*FORM') {
            document.getElementById('FORM_ComMatl').value = '';
            document.getElementById('FORM_ComQnty').value = '';
         }
      }
   }
   function doCompDelete(objInput) {
      var objRow = objInput.parentNode.parentNode;
      objRow.setAttribute('comflg','0');
      objRow.style.display = 'none';
      document.getElementById('COMQTY_'+objRow.getAttribute('comcnt')).value = '0';
   }
   function requestCompAccept(strXML) {
      doPostRequest('<%=strBase%>psa_mat_config_check.asp',function(strResponse) {checkCompAccept(strResponse);},false,streamXML(strXML));
   }
   function checkCompAccept(strResponse) {
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
         var strType = '';
         var strComCode = '';
         var strComText = '';
         var strComQnty = '';
         var objTable;
         var objRow;
         var objCell;
         var objInput;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'COMDFN') {
               strType = objElements[i].getAttribute('PTYCDE');
               strComCode = objElements[i].getAttribute('COMCDE');
               strComText = objElements[i].getAttribute('COMTXT');
               strComQnty = objElements[i].getAttribute('COMQTY');
            }
         }
         if (strType == '*FILL') {
            objTable = document.getElementById('FILL_ComList');
            document.getElementById('FILL_ComMatl').value = '';
            document.getElementById('FILL_ComQnty').value = '';
         } else if (strType == '*PACK') {
            objTable = document.getElementById('PACK_ComList');
            document.getElementById('PACK_ComMatl').value = '';
            document.getElementById('PACK_ComQnty').value = '';
         } else if (strType == '*FORM') {
            objTable = document.getElementById('FORM_ComList');
            document.getElementById('FORM_ComMatl').value = '';
            document.getElementById('FORM_ComQnty').value = '';
         }
         objRow = objTable.insertRow(-1);
         cintCompCount++;
         objRow.setAttribute('comflg','1');
         objRow.setAttribute('comcde',strComCode);
         objRow.setAttribute('comcnt',cintCompCount);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBN';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objInput = document.createElement('A');
         objInput.className = 'clsSelect';
         objInput.onclick = function() {doCompDelete(this);};
         objInput.setAttribute('comcnt',cintCompCount);
         objInput.appendChild(document.createTextNode('Delete'));
         objCell.appendChild(objInput);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBN';
         objCell.innerHTML = '<p>'+strComText+'</p>';
         objCell.style.paddingLeft = '2px';
         objCell.style.paddingRight = '2px';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'left';
         objCell.vAlign = 'center';
         objCell.className = 'clsLabelBN';
         objCell.style.whiteSpace = 'nowrap';
         objInput = document.createElement('input');
         objInput.type = 'text';
         objInput.value = strComQnty;
         objInput.id = 'COMQTY_'+cintCompCount;
         objInput.size = 9;
         objInput.maxLength = 9;
         objInput.align = 'left';
         objInput.className = 'clsInputNN';
         objInput.onfocus = function() {setSelect(this);};
         objInput.onblur = function() {validateNumber(this,0,false);};
         objCell.appendChild(objInput);
      }
   }
   function doRecalculate(strType) {
      if (!processForm()) {return;}
      if (strType == '*FILL') {
         var intBchQnty = document.getElementById('FILL_BchQnty').value;
         var intYldPcnt = document.getElementById('FILL_YldPcnt').value;
         var intPckPcnt = document.getElementById('FILL_PckPcnt').value;
         var intYldValu = Math.round(intBchQnty * cintUntCase * (intYldPcnt / 100));
         var intPckValu = Math.round((cintNetWght / cintUntCase) * 1000) / 1000;
         var intBchValu = Math.round((intYldValu * intPckValu * (intPckPcnt / 100)) * 1000) / 1000;
         document.getElementById('FILL_YldValu').innerHTML = intYldValu;
         document.getElementById('FILL_PckValu').innerHTML = intPckValu;
         document.getElementById('FILL_BchValu').innerHTML = intBchValu;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('psa_mat_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspSelect" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSelect" class="clsFunction" align=center colspan=2 nowrap><nobr>Material Selection</nobr></td>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectPrevious();"><&nbsp;Prev&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectNext();">&nbsp;Next&nbsp;></a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectUpdate();">&nbsp;SAP Update&nbsp;</a></nobr></td>
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
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Material Define</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=5 cellpadding=0 cellspacing=1>
               <tr>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Material Code</nobr></td>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Material Name</nobr></td>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Material Type</nobr></td>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Material Usage</nobr></td>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Material Status</nobr></td>
               </tr>
               <tr>
                  <td id="DEF_MatCode" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                  <td id="DEF_MatName" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                  <td id="DEF_MatType" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                  <td id="DEF_MatUsag" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                  <td id="DEF_MatStat" class="clsLabelBB" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=4 cellpadding=0 cellspacing=1>
               <tr>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Unit Of Measure</nobr></td>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Gross Weight</nobr></td>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Net Weight</nobr></td>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Units/Case</nobr></td>
               </tr>
               <tr>
                  <td id="DEF_MatMuom" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                  <td id="DEF_MatGwgt" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                  <td id="DEF_MatNwgt" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                  <td id="DEF_MatUcas" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=4 cellpadding=0 cellspacing=1>
               <tr>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>SAP Code</nobr></td>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>SAP Production Line</nobr></td>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>SAP Last Updated</nobr></td>
                  <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>PSA Last Updated</nobr></td>
               </tr>
               <tr>
                  <td id="DEF_SapCode" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                  <td id="DEF_SapLine" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                  <td id="DEF_SysDate" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                  <td id="DEF_UpdDate" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr id="TDU_Data" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;<input type="checkbox" name="DEF_TduFill" onClick="doTduFillClick(this);" value="*FILL">Filling&nbsp;<input type="checkbox" name="DEF_TduPack" onClick="doTduPackClick(this);" value="*PACK">Packing&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr id="FILL_Data" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelHB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Filling&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsGrid02" align=center valign=top cols=6 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Default Filling Line</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Scheduling Priority</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Batch Case Quantity</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Yield Percentage</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Pack Weight Percentage</nobr></td>
                        </tr>
                        <tr>
                           <td id="FILL_DftLine" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><select class="clsInputBN" id="FILL_PrdLine"></select></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="FILL_SchPrty" size="4" maxlength="4" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="FILL_BchQnty" size="9" maxlength="9" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="FILL_YldPcnt" size="6" maxlength="6" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,2,false);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="FILL_PckPcnt" size="6" maxlength="6" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,2,false);"></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsGrid02" align=center valign=top cols=4 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><a class="clsSelect" onClick="doRecalculate('*FILL');">Recalculate</a></nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Yield Value</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Pack Weight Value</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Batch Weight Value</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap>&nbsp;</td>
                           <td id="FILL_YldValu" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                           <td id="FILL_PckValu" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                           <td id="FILL_BchValu" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table id="FILL_LinList" class="clsGrid02" align=center valign=top cols=7 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="3" nowrap><nobr>Filling Line Configurations</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Run Rate</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Override</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="left" valign="center" colspan="1" nowrap><nobr>Line Configuration</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Default</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Run Rate</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Efficiency %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Wastage %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Efficiency %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Wastage %</nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table id="FILL_ComList" class="clsGrid02" align=center valign=top cols=3 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="3" nowrap><nobr>Filling Components</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Action</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="left" valign="center" colspan="1" nowrap><nobr>Material</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Quantity</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><a class="clsSelect" onClick="doCompAdd('*FILL');">Add</a></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="FILL_ComMatl" size="18" maxlength="18" value="" onFocus="setSelect(this);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><nobr><input class="clsInputNN" type="text" name="FILL_ComQnty" size="9" maxlength="9" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr id="PACK_Data" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelHB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Packing&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsGrid02" align=center valign=top cols=4 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Default Packing Line</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Scheduling Priority</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Cases Per Pallet</nobr></td>
                        </tr>
                        <tr>
                           <td id="PACK_DftLine" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><select class="clsInputBN" id="PACK_PrdLine"></select></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="PACK_SchPrty" size="4" maxlength="4" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="PACK_CasPalt" size="5" maxlength="5" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table id="PACK_LinList" class="clsGrid02" align=center valign=top cols=5 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="3" nowrap><nobr>Packing Line Configurations</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Run Rate</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="left" valign="center" colspan="1" nowrap><nobr>Line Configuration</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Default</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Run Rate</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Efficiency %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Wastage %</nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table id="PACK_ComList" class="clsGrid02" align=center valign=top cols=3 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="3" nowrap><nobr>Packing Components</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Action</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="left" valign="center" colspan="1" nowrap><nobr>Material</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Quantity</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><a class="clsSelect" onClick="doCompAdd('*PACK');">Add</a></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="PACK_ComMatl" size="18" maxlength="18" value="" onFocus="setSelect(this);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><nobr><input class="clsInputNN" type="text" name="PACK_ComQnty" size="9" maxlength="9" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr id="FORM_Data" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelHB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Forming&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsGrid02" align=center valign=top cols=4 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Default Forming Line</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Scheduling Priority</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Batch Lot Quantity</nobr></td>
                        </tr>
                        <tr>
                           <td id="FORM_DftLine" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><select class="clsInputBN" id="FORM_PrdLine"></select></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="FORM_SchPrty" size="4" maxlength="4" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="FORM_BchQnty" size="9" maxlength="9" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table id="FORM_LinList" class="clsGrid02" align=center valign=top cols=5 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="3" nowrap><nobr>Forming Line Configurations</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Run Rate</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="left" valign="center" colspan="1" nowrap><nobr>Line Configuration</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Default</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Run Rate</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Efficiency %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Wastage %</nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table id="FORM_ComList" class="clsGrid02" align=center valign=top cols=3 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="3" nowrap><nobr>Forming Components</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Action</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="left" valign="center" colspan="1" nowrap><nobr>Material</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Quantity</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><a class="clsSelect" onClick="doCompAdd('*FORM');">Add</a></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="FORM_ComMatl" size="18" maxlength="18" value="" onFocus="setSelect(this);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><nobr><input class="clsInputNN" type="text" name="FORM_ComQnty" size="9" maxlength="9" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr></nobr></td>
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