<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_tes_response.asp                               //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the product test response   //
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
   strTarget = "pts_tes_response.asp"
   strHeading = "Test Response Maintenance"

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
   strReturn = GetSecurityCheck("PTS_TES_RESPONSE")
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
      cobjScreens[1] = new clsScreen('dspResponse','hedResponse');
      cobjScreens[0].hedtxt = 'Test Prompt';
      cobjScreens[1].hedtxt = 'Test Response Entry';
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
      doPromptResponse();
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

   ////////////////////////
   // Response Functions //
   ////////////////////////
   var cstrRespTesCde;
   var cstrRespTesTxt;
   var cstrRespTesTrg;
   var cstrRespTesSam;
   var cstrRespResCde;
   var cintRespResIdx;
   var cobjTesResMeta = new Array();
   function clsTesResMeta() {
      this.daycde = '';
      this.daytxt = '';
      this.quecde = '';
      this.quetxt = '';
      this.quetyp = '';
      this.quenam = '';
      this.samn01 = '';
      this.samn02 = '';
      this.resn00 = '';
      this.resn01 = '';
      this.resn02 = '';
   }
   function requestResponseLoad(strCode) {
      cstrRespTesCde = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LODRES" TESCDE="'+cstrRespTesCde+'"/>';
      doPostRequest('<%=strBase%>pts_tes_response_load.asp',function(strResponse) {checkResponseLoad(strResponse);},false,streamXML(strXML));
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
               cstrRespTesTxt = objElements[i].getAttribute('TESTXT');
               cstrRespTesTrg = objElements[i].getAttribute('TESTRG');
               cstrRespTesSam = objElements[i].getAttribute('TESSAM');
            } else if (objElements[i].nodeName == 'META') {
               objTesResMeta = new clsTesResMeta();
               objTesResMeta.daycde = objElements[i].getAttribute('DAYCDE');
               objTesResMeta.daytxt = objElements[i].getAttribute('DAYTXT');
               objTesResMeta.quecde = objElements[i].getAttribute('QUECDE');
               objTesResMeta.quetxt = objElements[i].getAttribute('QUETXT');
               objTesResMeta.quetyp = objElements[i].getAttribute('QUETYP')
               objTesResMeta.quenam = objElements[i].getAttribute('QUENAM');
               if (cobjTesResMeta.length == 0 || objTesResMeta.daycde != cobjTesResMeta[cobjTesResMeta.length-1].daycde) {
                  if (cstrRespTesSam == '1') {
                     objTesResMeta.samn01 = 'D'+objTesResMeta.daycde+'S1';
                  }
                  if (cstrRespTesSam == '2') {
                     objTesResMeta.samn01 = 'D'+objTesResMeta.daycde+'S1';
                     objTesResMeta.samn02 = 'D'+objTesResMeta.daycde+'S2';
                  }
               } else
                  if (objTesResMeta.quetyp == '1') {
                     objTesResMeta.resn00 = 'D'+objTesResMeta.daycde+'Q'+objTesResMeta.quecde+'R0';
                  } else {
                     if (cstrRespTesSam == '1') {
                        objTesResMeta.resn01 = 'D'+objTesResMeta.daycde+'Q'+objTesResMeta.quecde+'R1';
                     }
                     if (cstrRespTesSam == '2') {
                        objTesResMeta.resn01 = 'D'+objTesResMeta.daycde+'Q'+objTesResMeta.quecde+'R1';
                        objTesResMeta.resn02 = 'D'+objTesResMeta.daycde+'Q'+objTesResMeta.quecde+'R2';
                     }
                  }
               }
               cobjTesResMeta[cobjTesResMeta.length] = objTesResMeta;
            } else if (objElements[i].nodeName == 'PANEL') {
               objRow = objResList.insertRow(-1);
               objRow.setAttribute('pancde',objElements[i].getAttribute('PANCDE'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '<a class="clsSelect" onClick="doResponseSelect(\''+objRow.rowIndex+'\');">Select</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               if (objElements[i].getAttribute('RESSTS') == '1') {
                  objCell.innerHTML = 'Entered';
                  objCell.className = 'clsLabelFB';
               } else {
                  objCell.innerHTML = 'No Data';
                  objCell.className = 'clsLabelFN';
               }
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(2);
               objCell.colSpan = 1;
               objCell.innerHTML = objElements[i].getAttribute('PANSTS');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(3);
               objCell.colSpan = 1;
               objCell.innerHTML = objElements[i].getAttribute('PANTXT');
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
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'right';
         objCell.innerText = cstrRespTesTrg+':';
         objCell.className = 'clsLabelBB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         if (cstrRespTesSam == '1') {
            objCell.colSpan = 2;
         } else {
            objCell.colSpan = 3;
         }
         objCell.align = 'left';
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
            if (cobjTesResMeta[i].samn01 != '' || cobjTesResMeta[i].samn02 != '') {
               objRow = objResData.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+cobjTesResMeta[i].daytxt+'&nbsp;';
               objCell.className = 'clsLabelBB';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
               if (cobjTesResMeta[i].samn01 != '') {
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.innerHTML = '';
                  objCell.className = 'clsLabelBN';
                  objCell.style.whiteSpace = 'nowrap';
                  objInput = document.createElement('input');
                  objInput.type = 'text';
                  objInput.id = cobjTesResMeta[i].samn01;
                  objInput.name = cobjTesResMeta[i].samn01;
                  objInput.className = 'clsInputNN';
                  objInput.onfocus = function() {setSelect(this);};
                  objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
                  objInput.size = 1;
                  objInput.maxLength = 10;
                  objInput.value = '';
                  objCell.appendChild(objInput);
               }
               if (cobjTesResMeta[i].samn02 != '') {
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.innerHTML = '';
                  objCell.className = 'clsLabelBN';
                  objCell.style.whiteSpace = 'nowrap';
                  objInput = document.createElement('input');
                  objInput.type = 'text';
                  objInput.id = cobjTesResMeta[i].samn02;
                  objInput.name = cobjTesResMeta[i].samn02;
                  objInput.className = 'clsInputNN';
                  objInput.onfocus = function() {setSelect(this);};
                  objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
                  objInput.size = 1;
                  objInput.maxLength = 10;
                  objInput.value = '';
                  objCell.appendChild(objInput);
               }
            }
            objRow = objResData.insertRow(-1);
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.align = 'left';
            objCell.innerHTML = '&nbsp;'+cobjTesResMeta[i].quetxt+'&nbsp;';
            objCell.className = 'clsLabelBN';
            objCell.style.whiteSpace = 'nowrap';
            if (cobjTesResMeta[i].resn00 != '') {
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
               objInput = document.createElement('input');
               objInput.type = 'text';
               objInput.id = cobjTesResMeta[i].resn00;
               objInput.name = cobjTesResMeta[i].resn00;
               objInput.className = 'clsInputNN';
               objInput.onfocus = function() {setSelect(this);};
               objInput.onblur = function() {validateNumber(this,0,false);};
               objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
               objInput.size = 10;
               objInput.maxLength = 10;
               objInput.value = '';
               objCell.appendChild(objInput);
               if (cobjTesResMeta[i].resn01 != '') {
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.innerHTML = '&nbsp;';
                  objCell.className = 'clsLabelBN';
                  objCell.style.whiteSpace = 'nowrap';
               }
               if (cobjTesResMeta[i].resn02 != '') {
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.innerHTML = '&nbsp;';
                  objCell.className = 'clsLabelBN';
                  objCell.style.whiteSpace = 'nowrap';
               }
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+cobjTesResMeta[i].quenam+'&nbsp;';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
            } else {
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
               if (cobjTesResMeta[i].resn01 != '') {
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.innerHTML = '';
                  objCell.className = 'clsLabelBN';
                  objCell.style.whiteSpace = 'nowrap';
                  objInput = document.createElement('input');
                  objInput.type = 'text';
                  objInput.id = cobjTesResMeta[i].resn01;
                  objInput.name = cobjTesResMeta[i].resn01;
                  objInput.className = 'clsInputNN';
                  objInput.onfocus = function() {setSelect(this);};
                  objInput.onblur = function() {validateNumber(this,0,false);};
                  objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
                  objInput.size = 10;
                  objInput.maxLength = 10;
                  objInput.value = '';
                  objCell.appendChild(objInput);
               }
               if (cobjTesResMeta[i].resn02 != '') {
                  objCell = objRow.insertCell(-1);
                  objCell.colSpan = 1;
                  objCell.align = 'left';
                  objCell.innerHTML = '';
                  objCell.className = 'clsLabelBN';
                  objCell.style.whiteSpace = 'nowrap';
                  objInput = document.createElement('input');
                  objInput.type = 'text';
                  objInput.id = cobjTesResMeta[i].resn02;
                  objInput.name = cobjTesResMeta[i].resn02;
                  objInput.className = 'clsInputNN';
                  objInput.onfocus = function() {setSelect(this);};
                  objInput.onblur = function() {validateNumber(this,0,false);};
                  objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
                  objInput.size = 10;
                  objInput.maxLength = 10;
                  objInput.value = '';
                  objCell.appendChild(objInput);
               }
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+cobjTesResMeta[i].quenam+'&nbsp;';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         objRow = objResData.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'left';
         objCell.innerText = '';
         objCell.className = 'clsLabelBN';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         if (cstrRespTesSam == '1') {
            objCell.colSpan = 2;
         } else {
            objCell.colSpan = 3;
         }
         objCell.align = 'center';
         objCell.innerHTML = '<a class="clsButton" onfocus="doAcceptFocus();" onblur="doAcceptBlur();" href="javascript:doResponseAccept();">Accept</a>';
         objCell.className = 'clsTable01';
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
         if (cobjTesResMeta[i].samn01 != '') {
            document.getElementById(cobjTesResMeta[i].samn01).value = '';
         }
         if (cobjTesResMeta[i].samn02 != '') {
            document.getElementById(cobjTesResMeta[i].samn02).value = '';
         }
         if (cobjTesResMeta[i].resn00 != '') {
            document.getElementById(cobjTesResMeta[i].resn00).value = '';
         }
         if (cobjTesResMeta[i].resn01 != '') {
            document.getElementById(cobjTesResMeta[i].resn01).value = '';
         }
         if (cobjTesResMeta[i].resn02 != '') {
            document.getElementById(cobjTesResMeta[i].resn02).value = '';
         }
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
      if (objResCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Panel code must be specified';
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
            strMessage = strMessage + 'Panel code does not exist in the panel list';
         } else {
            for (var i=0;i<cobjTesResMeta.length;i++) {
               if (cobjTesResMeta[i].samn01 != '') {
                  if (document.getElementById(cobjTesResMeta[i].samn01).value == '') {
                     if (strMessage != '') {strMessage = strMessage + '\r\n';}
                     strMessage = strMessage + 'Market research code 1 must be entered for '+cobjTesResMeta[i].daytxt;
                  }
               }
               if (document.getElementById(cobjTesResMeta[i].resn01).value == '') {
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
      var strMkt01;
      var strMkt02;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDRES" TESCDE="'+cstrRespTesCde+'" PANCDE="'+document.getElementById('RES_ResCode').value+'">';
      for (var i=0;i<cobjTesResMeta.length;i++) {
         if (cobjTesResMeta[i].samn01 != '' || cobjTesResMeta[i].samn02 != '') {
            strMkt01 = '';
            strMkt02 = '';
            if (cobjTesResMeta[i].samn01 != '') {
               strMkt01 = document.getElementById(cobjTesResMeta[i].samn01).value;
            }
            if (cobjTesResMeta[i].samn02 != '') {
               strMkt02 = document.getElementById(cobjTesResMeta[i].samn02).value;
            }
         } else {
            if (strMkt01 != '') {
               strXML = strXML+'<RESPONSE DAYCDE="'+cobjTesResMeta[i].daycde+'"';
               strXML = strXML+' QUECDE="'+cobjTesResMeta[i].quecde+'"';
               strXML = strXML+' RESSEQ="1"';
               strXML = strXML+' MKTCDE="'+strMkt01+'"';
               strXML = strXML+' RESVAL="'+document.getElementById(cobjTesResMeta[i].resn01).value+'"/>';
            }
            if (strMkt02 != '') {
               strXML = strXML+'<RESPONSE DAYCDE="'+cobjTesResMeta[i].daycde+'"';
               strXML = strXML+' QUECDE="'+cobjTesResMeta[i].quecde+'"';
               strXML = strXML+' RESSEQ="2"';
               strXML = strXML+' MKTCDE="'+strMkt02+'"';
               strXML = strXML+' RESVAL="'+document.getElementById(cobjTesResMeta[i].resn02).value+'"/>';
            }
         }
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestResponseUpdate(\''+strXML+'\');',10);
   }
   function requestResponseUpdate(strXML) {
      doPostRequest('<%=strBase%>pts_tes_response_update.asp',function(strResponse) {checkResponseUpdate(strResponse);},false,streamXML(strXML));
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
      strXML = strXML+'<PTS_REQUEST ACTION="*SELRES" TESCDE="'+cstrRespTesCde+'" PANCDE="'+cstrRespResCde+'"/>';
      doActivityStart(document.body);
      window.setTimeout('requestResponseSelect(\''+strXML+'\');',10);
   }
   function requestResponseSelect(strXML) {
      doPostRequest('<%=strBase%>pts_tes_response_select.asp',function(strResponse) {checkResponseSelect(strResponse);},false,streamXML(strXML));
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
               for (var j=0;j<cobjTesResMeta.length;j++) {
                  if (cobjTesResMeta[j].daycde == objElements[i].getAttribute('DAYCDE') &&
                      cobjTesResMeta[j].quecde == objElements[i].getAttribute('QUECDE') &&
                      cobjTesResMeta[j].samcde == objElements[i].getAttribute('SAMCDE')) {
                     document.getElementById(cobjTesResMeta[j].resnam).value = objElements[i].getAttribute('RESVAL');
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
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_tes_response_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
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
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptResponse();">&nbsp;Response Entry&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptSearch();">&nbsp;Search&nbsp;</a></nobr></td>
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
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->