<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_tes_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the product test            //
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
   strTarget = "pts_tes_config.asp"
   strHeading = "Test Maintenance"

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
   strReturn = GetSecurityCheck("PTS_TES_CONFIG")
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
         return '';
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
      cobjScreens[2] = new clsScreen('dspResponse','hedResponse');
      cobjScreens[0].hedtxt = 'Test Prompt';
      cobjScreens[1].hedtxt = 'Test Maintenance';
      cobjScreens[2].hedtxt = 'Test Response Entry';
      initSearch();
      initSelect('dspDefine','Product Test');
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
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
   // Prompt Functions //
   //////////////////////
   function doPromptEnter() {
      if (!processForm()) {return;}
      if (document.getElementById('PRO_TesCode').value == '') {
         doPromptCreate();
      } else {
         doPromptUpdate();
      }
   }
   function doPromptUpdate() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doPromptCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
   }
   function doPromptCopy() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for copy';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doPromptResponse() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for response';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestResponseLoad(\''+document.getElementById('PRO_TesCode').value+'\');',10);
   }
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*TEST','Test','pts_tes_search.asp',function() {doPromptTesCancel();},function(strCode,strText) {doPromptTesSelect(strCode,strText);});
   }
   function doPromptTesCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }
   function doPromptTesSelect(strCode,strText) {
      document.getElementById('PRO_TesCode').value = strCode;
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   var cintDefineTarget;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDTES" TESCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTTES" TESCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYTES" TESCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[1].hedtxt = 'Update Test ('+cstrDefineCode+')';
         } else {
            cobjScreens[1].hedtxt = 'Create Test (*NEW)';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_TesCode').value = '';
         document.getElementById('DEF_TesText').value = '';
         document.getElementById('DEF_TesAtxt').value = '';
         document.getElementById('DEF_TesRtxt').value = '';
         document.getElementById('DEF_TesPtxt').value = '';
         document.getElementById('DEF_TesCtxt').value = '';
         document.getElementById('DEF_TesDcnt').value = '0';
         document.getElementById('DEF_TesMcnt').value = '0';
         document.getElementById('DEF_TesRcnt').value = '0';
         var strTesStat;
         var strTesType;
         var strTesGsts;
         var strTesTarg;
         var strTesPmlt;
         var strTesEnty;
         var objTesStat = document.getElementById('DEF_TesStat');
         var objTesType = document.getElementById('DEF_TesType');
         var objTesGsts = document.getElementById('DEF_TesGsts');
         var objTesPmlt = document.getElementById('DEF_TesPmlt');
         var objTesTarg = document.getElementById('DEF_TesTarg');
         objTesStat.options.length = 0;
         objTesType.options.length = 0;
         objTesGsts.options.length = 0;
         objTesTarg.options.length = 0;
         document.getElementById('DEF_TesText').focus();
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'STA_LIST') {
               objTesStat.options[objTesStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'TYP_LIST') {
               objTesType.options[objTesType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'GLO_LIST') {
               objTesGsts.options[objTesGsts.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'TAR_LIST') {
               objTesTarg.options[objTesTarg.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'TEST') {
               document.getElementById('DEF_TesCode').value = objElements[i].getAttribute('TESCODE');
               document.getElementById('DEF_TesText').value = objElements[i].getAttribute('TESTEXT');
               document.getElementById('DEF_TesAtxt').value = objElements[i].getAttribute('TESATXT');
               document.getElementById('DEF_TesRtxt').value = objElements[i].getAttribute('TESRTXT');
               document.getElementById('DEF_TesPtxt').value = objElements[i].getAttribute('TESPTXT');
               document.getElementById('DEF_TesCtxt').value = objElements[i].getAttribute('TESCTCT');
               document.getElementById('DEF_TesDcnt').value = objElements[i].getAttribute('TESDCNT');
               document.getElementById('DEF_TesMcnt').value = objElements[i].getAttribute('TESMCNT');
               document.getElementById('DEF_TesRcnt').value = objElements[i].getAttribute('TESRCNT');
               strTesStat = objElements[i].getAttribute('TESSTAT');
               strTesType = objElements[i].getAttribute('TESTYPE');
               strTesGsts = objElements[i].getAttribute('TESGSTS');
               strTesPmlt = objElements[i].getAttribute('TESPMLT');
               strTesTarg = objElements[i].getAttribute('TESTARG');
            }
         }
         objTesStat.selectedIndex = -1;
         for (var i=0;i<objTesStat.length;i++) {
            if (objTesStat.options[i].value == strTesStat) {
               objTesStat.options[i].selected = true;
               break;
            }
         }
         objTesType.selectedIndex = -1;
         for (var i=0;i<objTesType.length;i++) {
            if (objTesType.options[i].value == strTesType) {
               objTesType.options[i].selected = true;
               break;
            }
         }
         objTesGsts.selectedIndex = -1;
         for (var i=0;i<objTesGsts.length;i++) {
            if (objTesGsts.options[i].value == strTesGsts) {
               objTesGsts.options[i].selected = true;
               break;
            }
         }
         objTesPmlt.selectedIndex = -1;
         for (var i=0;i<objTesPmlt.length;i++) {
            if (objTesPmlt.options[i].value == strTesPmlt) {
               objTesPmlt.options[i].selected = true;
               break;
            }
         }
         strTesEnty = '';
         cintDefineTarget = -1;
         objTesTarg.selectedIndex = -1;
         for (var i=0;i<objTesTarg.length;i++) {
            if (objTesTarg.options[i].value == strTesTarg) {
               objTesTarg.options[i].selected = true;
               cintDefineTarget = i;
               strTesEnty = objTesTarg.options[i].text.substring(objTesTarg.options[i].value.length+3);
               break;
            }
         }
         if (strTesEnty != '') {
            startSltInstance(strTesEnty);
            putSltData(objElements);
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var strMessage = checkSltData();
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var objTesStat = document.getElementById('DEF_TesStat');
      var objTesTarg = document.getElementById('DEF_TesTarg');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*DEFTES"';
      strXML = strXML+' TESCODE="'+fixXML(document.getElementById('DEF_TesCode').value)+'"';
      strXML = strXML+' TESTEXT="'+fixXML(document.getElementById('DEF_TesText').value)+'"';
      strXML = strXML+' TESATXT="'+fixXML(document.getElementById('DEF_TesAtxt').value)+'"';
      strXML = strXML+' TESRTXT="'+fixXML(document.getElementById('DEF_TesRtxt').value)+'"';
      strXML = strXML+' TESPTXT="'+fixXML(document.getElementById('DEF_TesPtxt').value)+'"';
      strXML = strXML+' TESCTXT="'+fixXML(document.getElementById('DEF_TesCtxt').value)+'"';
      strXML = strXML+' TESDCNT="'+fixXML(document.getElementById('DEF_TesDcnt').value)+'"';
      strXML = strXML+' TESMCNT="'+fixXML(document.getElementById('DEF_TesMcnt').value)+'"';
      strXML = strXML+' TESRCNT="'+fixXML(document.getElementById('DEF_TesRcnt').value)+'"';
      strXML = strXML+' TESPMLT="'+fixXML(document.getElementById('TES_PetMult').options[document.getElementById('TES_PetMult').selectedIndex].value)+'"';
      strXML = strXML+' TESSTAT="'+fixXML(objTesStat.options[objTesStat.selectedIndex].value)+'"';
      strXML = strXML+' TESTYPE="'+fixXML(objTesType.options[objTesType.selectedIndex].value)+'"';
      strXML = strXML+' TESGSTS="'+fixXML(objTesGsts.options[objTesGsts.selectedIndex].value)+'"';
      strXML = strXML+' TESPMLT="'+fixXML(objTesPmlt.options[objTesPmlt.selectedIndex].value)+'"';
      strXML = strXML+' TESTARG="'+fixXML(objTesTarg.options[objTesTarg.selectedIndex].value)+'"';
      strXML = strXML+'>';
      strXML = strXML + getSltData();
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         document.getElementById('PRO_TesCode').value = '';
         document.getElementById('PRO_TesCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').value = '';
      document.getElementById('PRO_TesCode').focus();
   }
   function doDefineTarget(objSelect) {
      if (confirm('Please confirm the target change\r\npress OK continue (all existing selection rules will be deleted)\r\npress Cancel to return ignore') == false) {
         objSelect.selectedIndex = cintDefineTarget;
         return;
      }
      cintDefineTarget = objSelect.selectedIndex;
      var strValue = objSelect.options[objSelect.selectedIndex].text.substring(objSelect.options[objSelect.selectedIndex].value.length+3);
      startSltInstance(strValue);
   }

   ////////////////////////
   // Response Functions //
   ////////////////////////
   var cstrRespTesCde;
   var cstrRespTesTxt;
   var cstrRespResCde;
   var cintRespResIdx;
   var cobjTesResMeta = new Array();
   function clsTesResMeta() {
      this.daycde = '';
      this.daytxt = '';
      this.daybgn = '';
      this.quecde = '';
      this.quetxt = '';
      this.inpnam = '';
   }
   function requestResponseLoad(strCode) {
      cstrRespTesCde = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LODRES" TESCDE="'+cstrRespTesCde+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_resp_load.asp',function(strResponse) {checkResponseLoad(strResponse);},false,streamXML(strXML));
   }
   function checkResponseLoad(strResponse) {
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
         cstrRespTesTxt = '';
         cobjTesResMeta.length = 0;
         var objTesResMeta;
         var objRow;
         var objCell;
         var objInput;
         var objResList = document.getElementById('RES_ResList');
         for (var i=objResList.rows.length-1;i>=0;i--) {
            objResList.deleteRow(i);
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
               cstrRespTesTxt = objElements[i].getAttribute('TESTEXT');
            } else if (objElements[i].nodeName == 'QUESTION') {
               objTesResMeta = new clsTesResMeta();
               objTesResMeta.daycde = objElements[i].getAttribute('DAYCDE');
               objTesResMeta.daytxt = objElements[i].getAttribute('DAYTXT');
               objTesResMeta.daybgn = objElements[i].getAttribute('DAYBGN');
               objTesResMeta.quecde = objElements[i].getAttribute('QUECDE');
               objTesResMeta.quetxt = objElements[i].getAttribute('QUETXT');
               objTesResMeta.inpnam = 'D'+objTesResMeta.daycde+'Q'+objTesResMeta.quecde;
               cobjTesResMeta[cobjTesResMeta.length] = objTesResMeta;
            } else if (objElements[i].nodeName == 'RESPONSE') {
               objRow = objResList.insertRow(-1);
               objRow.setAttribute('rescde',objElements[i].getAttribute('RESCDE'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '<a class="clsSelect" onClick="doResponseSelect(\''+objRow.rowIndex+'\');">Select</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               if (objElements[i].getAttribute('RESSTS') == '1') {
                  objCell.innerText = 'Entered';
                  objCell.className = 'clsLabelFB';
               } else {
                  objCell.innerText = 'No Data';
                  objCell.className = 'clsLabelFN';
               }
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(2);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('RESTXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         document.getElementById('subResponse').innerText = cstrRespTesTxt;
         var objResData = document.getElementById('RES_ResData');
         for (var i=objResData.rows.length-1;i>=0;i--) {
            objResData.deleteRow(i);
         }
         objRow = objResData.insertRow(-1);
         objCell = objRow.insertCell(0);
         objCell.colSpan = 2;
         objCell.align = 'right';
         objCell.innerText = 'Pet Code:';
         objCell.className = 'clsLabelBB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(1);
         objCell.colSpan = 1;
         objCell.innerText = '';
         objCell.className = 'clsLabelBN';
         objCell.style.whiteSpace = 'nowrap';
         objInput = document.createElement('input');
         objInput.type = 'text';
         objInput.id = 'RES_ResCode';
         objInput.name = 'RES_ResCode';
         objInput.className = 'clsInputNN';
         objInput.onfocus = function() {setSelect(this);};
         objInput.onblur = function() {validateNumber(this,0,false);};
         objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
         objInput.size = 10;
         objInput.maxLength = 10;
         objInput.value = '';
         objCell.appendChild(objInput);
         for (var i=0;i<cobjTesResMeta.length;i++) {
            objRow = objResData.insertRow(-1);
            if (cobjTesResMeta[i].daybgn == '1') {
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = cobjTesResMeta[i].daytxt+'&nbsp;-&nbsp;';
               objCell.className = 'clsLabelBB';
               objCell.style.whiteSpace = 'nowrap';
            } else {
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerText = '';
               objCell.className = 'clsLabelBB';
               objCell.style.whiteSpace = 'nowrap';
            }
            objCell = objRow.insertCell(1);
            objCell.colSpan = 1;
            objCell.innerHTML = cobjTesResMeta[i].quetxt+'&nbsp;-&nbsp;';
            objCell.className = 'clsLabelBN';
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(2);
            objCell.colSpan = 1;
            objCell.innerText = '';
            objCell.className = 'clsLabelBN';
            objCell.style.whiteSpace = 'nowrap';
            objInput = document.createElement('input');
            objInput.type = 'text';
            objInput.id = cobjTesResMeta[i].inpnam;
            objInput.name = cobjTesResMeta[i].inpnam;
            objInput.className = 'clsInputNN';
            objInput.onfocus = function() {setSelect(this);};
            objInput.onblur = function() {validateNumber(this,0,false);};
            objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
            objInput.size = 10;
            objInput.maxLength = 10;
            objInput.value = '';
            objCell.appendChild(objInput);
         }
         objRow = objResData.insertRow(-1);
         objCell = objRow.insertCell(0);
         objCell.colSpan = 2;
         objCell.innerText = '';
         objCell.className = 'clsLabelBN';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(1);
         objCell.colSpan = 1;
         objCell.innerHTML = '<a class="clsButton" onfocus="doAcceptFocus();" onblur="doAcceptBlur();" href="javascript:doResponseAccept();">Accept</a>';
         objCell.className = 'clsTable01';
         objCell.align = 'center';
         objCell.style.whiteSpace = 'nowrap';
         displayScreen('dspResponse');
         document.getElementById('RES_ResCode').focus();
      }
   }
   function doAcceptFocus() {
      var objElement = window.event.srcElement;
      objElement.className = 'clsButtonX';
      window.status = '';
   }
   function doAcceptBlur() {
      var objElement = window.event.srcElement;
      objElement.className = 'clsButton';
   }
   function clearResponseData() {
      document.getElementById('RES_ResCode').value = '';
      for (var i=0;i<cobjTesResMeta.length;i++) {
         document.getElementById(cobjTesResMeta[i].inpnam).value = '';
      }
      document.getElementById('RES_ResCode').focus();
   }
   function doResponseBack() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').focus();
   }
   function doResponseAccept() {
      if (!processForm()) {return;}
      var objResList = document.getElementById('RES_ResList');
      var objResCode = document.getElementById('RES_ResCode');
      var strMessage = '';
      if (objResCode == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Response code must be specified';
      } else {
         cstrRespResIdx = -1;
         for (var i=0;i<objResList.rows.length;i++) {
            if (objResList.rows[i].getAttribute('rescde') == objResCode.value) {
               cstrRespResIdx = i;
               break;
            }
         }
         if (cstrRespResIdx == -1) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Response code does not exist in the response list';
         } else {
            for (var i=0;i<cobjTesResMeta.length;i++) {
               strName = 'D'+cobjTesResMeta[i].daycde+'Q'+cobjTesResMeta[i].quecde;
               if (document.getElementById(strName).value == '') {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + 'Response must be entered for '+cobjTesResMeta[i].daytxt+' - '+cobjTesResMeta[i].quetxt;
               }
            }
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDRES" TESCDE="'+cstrRespTesCde+'" RESCDE="'+document.getElementById('RES_ResCode').value+'">';
      for (var i=0;i<cobjTesResMeta.length;i++) {
         strXML = strXML+'<RESPONSE DAYCDE="'+cobjTesResMeta[i].daycde+'"';
         strXML = strXML+' QUECDE="'+cobjTesResMeta[i].quecde+'"';
         strXML = strXML+' RESVAL="'+document.getElementById(cobjTesResMeta[i].inpnam).value+'"/>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestResponseUpdate(\''+strXML+'\');',10);
   }
   function requestResponseUpdate(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_resp_update.asp',function(strResponse) {checkResponseUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkResponseUpdate(strResponse) {
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
         }
         var objResList = document.getElementById('RES_ResList');
         var objRow = objResList.rows[cstrRespResIdx];
         objRow.cells[1].innerText = 'Entered';
         objRow.cells[1].className = 'clsLabelFB';
         clearResponseData();
      }
   }
   function doResponseSelect(intRow) {
      var objTable = document.getElementById('RES_ResList');
      objRow = objTable.rows[intRow];
      cstrRespResCde = objRow.getAttribute('rescde');
      cstrRespResIdx = intRow;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*SELRES" TESCDE="'+cstrRespTesCde+'" RESCDE="'+cstrRespResCde+'"/>';
      doActivityStart(document.body);
      window.setTimeout('requestResponseSelect(\''+strXML+'\');',10);
   }
   function requestResponseSelect(strXML) {
      doPostRequest('<%=strBase%>pts_tes_config_resp_select.asp',function(strResponse) {checkResponseSelect(strResponse);},false,streamXML(strXML));
   }
   function checkResponseSelect(strResponse) {
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
         var objResData = document.getElementById('RES_ResData');
         var strName;
         document.getElementById('RES_ResCode').value = cstrRespResCde;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'RESPONSE') {
               strName = 'D'+objElements[i].getAttribute('DAYCDE')+'Q'+objElements[i].getAttribute('QUECDE');
               for (var j=0;j<cobjTesResMeta.length;j++) {
                  if (cobjTesResMeta[j].inpnam == strName) {
                     document.getElementById(cobjTesResMeta[j].inpnam).value = objElements[i].getAttribute('RESVAL');
                     break;
                  }
               }
            }
         }
         document.getElementById('RES_ResCode').focus();
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
<!--#include file="pts_search_code.inc"-->
<!--#include file="pts_select_code.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_tes_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPromptEnter();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Test Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_TesCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=9 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCreate();">&nbsp;Create&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCopy();">&nbsp;Copy&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptTest();">&nbsp;Panel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptResponse();">&nbsp;Response&nbsp;</a></nobr></td>
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
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Test Maintenance</nobr></td>
         <input type="hidden" name="DEF_TesCode" value="">
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_TesText" size="100" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_TesStat"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Target:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_TesTarg" onChange="doDefineTarget(this);"></select>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
<!--#include file="pts_select_disp.inc"-->
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

   <table id="dspResponse" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedResponse" class="clsFunction" align=center colspan=2 nowrap><nobr>Test Response Entry</nobr></td>
      </tr>
      <tr>
         <td id="subResponse" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Test Text</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>Response Data Entry</nobr></td>
         <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>Response Panel</nobr></td>
      </tr>
      <tr height=100%>
         <td width=75% align=left colspan=1 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible;background-color:transparent;">
               <table id="RES_ResData" class="clsPanel" cols=1 align=left cellpadding="0" cellspacing="0"></table>
            </div>
         </nobr></td>
         <td width=25% align=left colspan=1 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible;">
               <table id="RES_ResList" class="clsTableBody" cols=1 align=left cellpadding="2" cellspacing="1"></table>
            </div>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doResponseBack();">&nbsp;Back&nbsp;</a></nobr></td>
            </table>
         </nobr></td>
      </tr>
   </table>



<!--#include file="pts_search_html.inc"-->
<!--#include file="pts_select_html.inc"-->
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->