<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_val_response.asp                               //
'// Author  : Peter Tylee                                        //
'// Date    : November 2011                                      //
'// Text    : This script implements the val. test response      //
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
   strTarget = "pts_val_response.asp"
   strHeading = "Pet Validation Test Response Maintenance"

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
   strReturn = GetSecurityCheck("PTS_VAL_RESPONSE")
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
   document.onmouseover = function(evt) {
      var evt = evt || window.event;
      var objElement = evt.target || evt.srcElement;
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
   document.onmouseout = function(evt) {
      var evt = evt || window.event;
      var objElement = evt.target || evt.srcElement;
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
      cobjScreens[0].hedtxt = 'Validation Prompt';
      cobjScreens[1].hedtxt = 'Validation Response Entry';
      initSearch();
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
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
      if (document.getElementById('PRO_ValCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Validation code must be entered for response';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestResponseLoad(\''+document.getElementById('PRO_ValCode').value+'\');',10);
   }
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*VALIDATION','Validation','pts_val_search.asp',function() {doPromptValCancel();},function(strCode,strText) {doPromptValSelect(strCode,strText);});
   }
   function doPromptValCancel() {
      objInputs = new Array(); // Clear any input errors
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   function doPromptValSelect(strCode,strText) {
      document.getElementById('PRO_ValCode').value = strCode;
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }

   ////////////////////////
   // Response Functions //
   ////////////////////////
   var cstrRespValCde;
   var cstrRespValTxt;
   var cstrRespResCde; // Pet code
   var cobjTesResMeta = new Array();
   function clsTesMeta() {
      this.tescde = '';
      this.testxt = '';
      this.tessam = '';
      this.responses = new Array();
   }
   function clsResMeta() {
      this.mettyp = '';
      this.daycde = '';
      this.daytxt = '';
      this.quecde = '';
      this.quetxt = '';
      this.quetyp = '';
      this.quenam = '';
      this.name01 = '';
      this.name02 = '';
   }
   function requestResponseLoad(strCode) {
      cstrRespValCde = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LODRES" VALCDE="'+cstrRespValCde+'"/>';
      doPostRequest('<%=strBase%>pts_val_response_load.asp',function(strResponse) {checkResponseLoad(strResponse,true);},false,streamXML(strXML));
   }
   function checkResponseLoad(strResponse,bResponses) {
      objInputs = new Array(); // Clear any input errors
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
         cstrRespValTxt = '';
         cobjTesResMeta.length = 0;
         var objTesMeta;
         var objResMeta;
         var objRow;
         var objCell;
         var objInput;
         if (bResponses) {
             var objResList = document.getElementById('RES_ResList');
             for (var i=objResList.rows.length-1;i>=0;i--) {
                objResList.deleteRow(i);
             }
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'VAL') {
               cstrRespValTxt = objElements[i].getAttribute('VALTXT');
            } else if (objElements[i].nodeName == 'TEST') {
               objTesMeta = new clsTesMeta();
               objTesMeta.tescde = objElements[i].getAttribute('TESCDE');
               objTesMeta.testxt = objElements[i].getAttribute('TESTXT');
               objTesMeta.tessam = objElements[i].getAttribute('TESSAM');
               cobjTesResMeta[cobjTesResMeta.length] = objTesMeta;
            } else if (objElements[i].nodeName == 'METD') {
               objResMeta = new clsResMeta();
               objResMeta.mettyp = 'D';
               objResMeta.daycde = objElements[i].getAttribute('DAYCDE');
               objResMeta.daytxt = objElements[i].getAttribute('DAYTXT');
               objResMeta.name01 = 'T'+objTesMeta.tescde+'D'+objResMeta.daycde+'S1';
               if (objTesMeta.tessam== '2') {
                  objResMeta.name02 = 'T'+objTesMeta.tescde+'D'+objResMeta.daycde+'S2';
               }
               cobjTesResMeta[cobjTesResMeta.length-1].responses[cobjTesResMeta[cobjTesResMeta.length-1].responses.length] = objResMeta;
            } else if (objElements[i].nodeName == 'METQ') {
               objResMeta = new clsResMeta();
               objResMeta.mettyp = 'Q';
               objResMeta.daycde = objElements[i].getAttribute('DAYCDE');
               objResMeta.quecde = objElements[i].getAttribute('QUECDE');
               objResMeta.quetxt = objElements[i].getAttribute('QUETXT');
               objResMeta.quetyp = objElements[i].getAttribute('QUETYP')
               objResMeta.quenam = objElements[i].getAttribute('QUENAM');
               if (objResMeta.quetyp == '1') {
                  objResMeta.name01 = 'T'+objTesMeta.tescde+'D'+objResMeta.daycde+'Q'+objResMeta.quecde+'R1';
               } else {
                  objResMeta.name01 = 'T'+objTesMeta.tescde+'D'+objResMeta.daycde+'Q'+objResMeta.quecde+'R1';
                  if (objTesMeta.tessam == '2') {
                     objResMeta.name02 = 'T'+objTesMeta.tescde+'D'+objResMeta.daycde+'Q'+objResMeta.quecde+'R2';
                  }
               }
               cobjTesResMeta[cobjTesResMeta.length-1].responses[cobjTesResMeta[cobjTesResMeta.length-1].responses.length] = objResMeta;
            } else if (bResponses && objElements[i].nodeName == 'PET') {
               objRow = objResList.insertRow(-1);
               objRow.setAttribute('petcde',objElements[i].getAttribute('PETCDE'));
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
               objCell.innerHTML = objElements[i].getAttribute('PETTXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         document.getElementById('SCR_ResList').scrollTop = 0;
         document.getElementById('SCR_ResList').scrollLeft = 0;
         if (bResponses)
            document.getElementById('subResponse').innerText = cstrRespValTxt;
         var objResData = document.getElementById('RES_ResData');
         for (var i=objResData.rows.length-1;i>=0;i--) {
            objResData.deleteRow(i);
         }
         objRow = objResData.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'right';
         objCell.innerHTML = '&nbsp;Pet Code:&nbsp;';
         objCell.className = 'clsLabelBB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 2;
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

         for (var x=0;x<cobjTesResMeta.length;x++) {
            // Test header
            objRow = objResData.insertRow(-1);
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 4;
            objCell.innerHTML = '&nbsp;';
            objRow = objResData.insertRow(-1);
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 1;
            objCell.innerHTML = '&nbsp;';
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 3;
            objCell.align = 'left';
            objCell.innerHTML = '<b>' + cobjTesResMeta[x].testxt + '</b>';
            objCell.className = 'clsLabelBN';
            objCell.style.whiteSpace = 'nowrap';
            
            for (var i=0;i<cobjTesResMeta[x].responses.length;i++) {
                if (cobjTesResMeta[x].responses[i].mettyp == 'D') {
                   objRow = objResData.insertRow(-1);
                   objCell = objRow.insertCell(-1);
                   objCell.colSpan = 1;
                   objCell.align = 'left';
                   objCell.innerHTML = '&nbsp;'+cobjTesResMeta[x].responses[i].daytxt+'&nbsp;';
                   objCell.className = 'clsLabelBB';
                   objCell.style.whiteSpace = 'nowrap';
                   if (cobjTesResMeta[x].responses[i].name01 != '') {
                      objCell = objRow.insertCell(-1);
                      objCell.colSpan = 1;
                      objCell.align = 'center';
                      objCell.innerHTML = '';
                      objCell.className = 'clsLabelBN';
                      objCell.style.whiteSpace = 'nowrap';
                      objInput = document.createElement('input');
                      objInput.type = 'text';
                      objInput.id = cobjTesResMeta[x].responses[i].name01;
                      objInput.name = cobjTesResMeta[x].responses[i].name01;
                      objInput.className = 'clsInputNN';
                      objInput.style.textTransform = 'uppercase';
                      objInput.onfocus = function() {setSelect(this);};
                      objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
                      objInput.size = 2;
                      objInput.maxLength = 1;
                      objInput.value = '';
                      objCell.appendChild(objInput);
                   }
                   if (cobjTesResMeta[x].responses[i].name02 != '') {
                      objCell = objRow.insertCell(-1);
                      objCell.colSpan = 1;
                      objCell.align = 'center';
                      objCell.innerHTML = '';
                      objCell.className = 'clsLabelBN';
                      objCell.style.whiteSpace = 'nowrap';
                      objInput = document.createElement('input');
                      objInput.type = 'text';
                      objInput.id = cobjTesResMeta[x].responses[i].name02;
                      objInput.name = cobjTesResMeta[x].responses[i].name02;
                      objInput.className = 'clsInputNN';
                      objInput.style.textTransform = 'uppercase';
                      objInput.onfocus = function() {setSelect(this);};
                      objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
                      objInput.size = 2;
                      objInput.maxLength = 1;
                      objInput.value = '';
                      objCell.appendChild(objInput);
                   }
                } else {
                   objRow = objResData.insertRow(-1);
                   objCell = objRow.insertCell(-1);
                   objCell.colSpan = 1;
                   objCell.align = 'left';
                   objCell.innerHTML = '&nbsp;'+cobjTesResMeta[x].responses[i].quetxt+'&nbsp;';
                   objCell.className = 'clsLabelBN';
                   objCell.style.whiteSpace = 'nowrap';
                   if (cobjTesResMeta[x].responses[i].quetyp == '1') {
                      objCell = objRow.insertCell(-1);
                      objCell.colSpan = 1;
                      objCell.align = 'left';
                      if (cobjTesResMeta[x].tessam == '2') {
                         objCell.colSpan = 2;
                         objCell.align = 'center';
                      }
                      objCell.innerHTML = '';
                      objCell.className = 'clsLabelBN';
                      objCell.style.whiteSpace = 'nowrap';
                      objInput = document.createElement('input');
                      objInput.type = 'text';
                      objInput.id = cobjTesResMeta[x].responses[i].name01;
                      objInput.name = cobjTesResMeta[x].responses[i].name01;
                      objInput.className = 'clsInputNN';
                      objInput.onfocus = function() {setSelect(this);};
                      objInput.onblur = function() {validateNumber(this,0,false);};
                      objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
                      objInput.size = 10;
                      objInput.maxLength = 10;
                      objInput.value = '';
                      objCell.appendChild(objInput);
                      objCell = objRow.insertCell(-1);
                      objCell.colSpan = 2;
                      if (cobjTesResMeta[x].tessam == '2')
                         objCell.colSpan = 1;
                      objCell.align = 'left';
                      objCell.innerHTML = '&nbsp;'+cobjTesResMeta[x].responses[i].quenam+'&nbsp;';
                      objCell.className = 'clsLabelBN';
                      objCell.style.whiteSpace = 'nowrap';
                   } else {
                      objCell = objRow.insertCell(-1);
                      objCell.colSpan = 1;
                      objCell.align = 'left';
                      objCell.innerHTML = '';
                      objCell.className = 'clsLabelBN';
                      objCell.style.whiteSpace = 'nowrap';
                      objInput = document.createElement('input');
                      objInput.type = 'text';
                      objInput.id = cobjTesResMeta[x].responses[i].name01;
                      objInput.name = cobjTesResMeta[x].responses[i].name01;
                      objInput.className = 'clsInputNN';
                      objInput.onfocus = function() {setSelect(this);};
                      objInput.onblur = function() {validateNumber(this,0,false);};
                      objInput.onkeydown = function() {if (event.keyCode == 13) {event.keyCode = 9;}};
                      objInput.size = 10;
                      objInput.maxLength = 10;
                      objInput.value = '';
                      objCell.appendChild(objInput);
                      if (cobjTesResMeta[x].responses[i].name02 != '') {
                         objCell = objRow.insertCell(-1);
                         objCell.colSpan = 1;
                         objCell.align = 'left';
                         objCell.innerHTML = '';
                         objCell.className = 'clsLabelBN';
                         objCell.style.whiteSpace = 'nowrap';
                         objInput = document.createElement('input');
                         objInput.type = 'text';
                         objInput.id = cobjTesResMeta[x].responses[i].name02;
                         objInput.name = cobjTesResMeta[x].responses[i].name02;
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
                      if (cobjTesResMeta[x].responses[i].name02 == '')
                        objCell.colSpan = 2;
                      objCell.align = 'left';
                      objCell.innerHTML = '&nbsp;'+cobjTesResMeta[x].responses[i].quenam+'&nbsp;';
                      objCell.className = 'clsLabelBN';
                      objCell.style.whiteSpace = 'nowrap';
                   }
                }
             }
             // Accept divider
             objRow = objResData.insertRow(-1);
             objCell = objRow.insertCell(-1);
             objCell.colSpan = 1;
             objCell.colSpan = 4;
             objCell.align = 'center';
             objCell.innerHTML = '<a class="clsButton" onfocus="doAcceptFocus(event);" onblur="doAcceptBlur(event);" href="javascript:doResponseAccept();">Accept</a>';
             objCell.className = 'clsTable01';
             objCell.style.whiteSpace = 'nowrap';
         }
         document.getElementById('SCR_ResData').scrollTop = 0;
         document.getElementById('SCR_ResData').scrollLeft = 0;
         displayScreen('dspResponse');
         document.getElementById('RES_ResCode').focus();
      }
   }
   function doAcceptFocus(evt) {
      var evt = evt || window.event;
      var objElement = evt.target || evt.srcElement;
      objElement.className = 'clsButtonX';
      window.status = '';
   }
   function doAcceptBlur(evt) {
      var evt = evt || window.event;
      var objElement = evt.target || evt.srcElement;
      objElement.className = 'clsButton';
   }
   function doResponseBack() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_ValCode').focus();
   }
   function doResponseAccept() {
      if (!processForm()) {return;}
      var objResList = document.getElementById('RES_ResList');
      var objResCode = document.getElementById('RES_ResCode');
      var strMessage = '';
      if (objResCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Pet code must be specified';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strMkt01;
      var strMkt02;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDRES" VALCDE="'+cstrRespValCde+'" PETCDE="'+document.getElementById('RES_ResCode').value+'">';
      for (var i=0;i<cobjTesResMeta.length;i++) {
         strXML = strXML+'<TEST TESCDE="'+cobjTesResMeta[i].tescde+'">';
         for (var j=0;j<cobjTesResMeta[i].responses.length;j++) {
             if (cobjTesResMeta[i].responses[j].mettyp == 'D') {
                strMkt01 = '';
                strMkt02 = '';
                if (cobjTesResMeta[i].responses[j].name01 != '') {
                   strMkt01 = document.getElementById(cobjTesResMeta[i].responses[j].name01).value;
                }
                if (cobjTesResMeta[i].responses[j].name02 != '') {
                   strMkt02 = document.getElementById(cobjTesResMeta[i].responses[j].name02).value;
                }
                strXML = strXML+'<RESP TYPCDE="D" DAYCDE="'+cobjTesResMeta[i].responses[j].daycde+'"';
                strXML = strXML+' MKTCD1="'+strMkt01+'"';
                strXML = strXML+' MKTCD2="'+strMkt02+'"/>';
             } else {
                if (cobjTesResMeta[i].responses[j].name01 != '') {
                   strXML = strXML+'<RESP TYPCDE="Q" QUECDE="'+cobjTesResMeta[i].responses[j].quecde+'"';
                   strXML = strXML+' RESSEQ="1"';
                   strXML = strXML+' RESVAL="'+document.getElementById(cobjTesResMeta[i].responses[j].name01).value+'"/>';
                }
                if (cobjTesResMeta[i].responses[j].name02 != '') {
                   strXML = strXML+'<RESP TYPCDE="Q" QUECDE="'+cobjTesResMeta[i].responses[j].quecde+'"';
                   strXML = strXML+' RESSEQ="2"';
                   strXML = strXML+' RESVAL="'+document.getElementById(cobjTesResMeta[i].responses[j].name02).value+'"/>';
                }
             }
         }
         strXML = strXML+'</TEST>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestResponseUpdate(\''+strXML+'\');',10);
   }
   function requestResponseUpdate(strXML) {
      doPostRequest('<%=strBase%>pts_val_response_update.asp',function(strResponse) {checkResponseUpdate(strResponse);},false,streamXML(strXML));
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
         // The next pet might have a different set of assigned tests, so rebiuld the response table
         requestResponseLoad(cstrRespValCde);
      }
   }
   function doResponseSelect(intRow) {
      var objTable = document.getElementById('RES_ResList');
      objRow = objTable.rows[intRow];
      cstrRespResCde = objRow.getAttribute('petcde');
      cstrRespResIdx = intRow;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*SELRES" VALCDE="'+cstrRespValCde+'" PETCDE="'+cstrRespResCde+'"/>';
      doActivityStart(document.body);
      window.setTimeout('requestResponseSelect(\''+strXML+'\');',10);
   }
   function requestResponseSelect(strXML) {
      doPostRequest('<%=strBase%>pts_val_response_retrieve.asp',function(strResponse) {checkResponseSelect(strResponse);},false,streamXML(strXML));
   }
   function checkResponseSelect(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         checkResponseLoad(strResponse,false); // The test table needs to be re-built
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
         document.getElementById('RES_ResCode').value = cstrRespResCde;
         var cobjTest;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TEST') {
                cobjTest = null;
                var tescde = objElements[i].getAttribute('TESCDE');
                for (var j=0;j<cobjTesResMeta.length;j++) {
                    if (cobjTesResMeta[j].tescde == tescde) {
                        cobjTest = cobjTesResMeta[j];
                    }
                }
            } else if (objElements[i].nodeName == 'RESD') {
                if (cobjTest) {
                  for (var k=0;k<cobjTest.responses.length;k++) {
                      if (cobjTest.responses[k].mettyp == 'D' &&
                          cobjTest.responses[k].daycde == objElements[i].getAttribute('DAYCDE')) {
                         if (objElements[i].getAttribute('RESSEQ') == '1') {
                            document.getElementById(cobjTest.responses[k].name01).value = objElements[i].getAttribute('MKTCDE');
                         }
                         if (objElements[i].getAttribute('RESSEQ') == '2') {
                            document.getElementById(cobjTest.responses[k].name02).value = objElements[i].getAttribute('MKTCDE');
                         }
                         break;
                      }
                  }
               }
            } else if (objElements[i].nodeName == 'RESQ') {
               if (cobjTest) {
                  for (var k=0;k<cobjTest.responses.length;k++) {
                      if (cobjTest.responses[k].mettyp == 'Q' &&
                          cobjTest.responses[k].daycde == objElements[i].getAttribute('DAYCDE') &&
                          cobjTest.responses[k].quecde == objElements[i].getAttribute('QUECDE')) {
                         if (objElements[i].getAttribute('RESSEQ') == '1') {
                            document.getElementById(cobjTest.responses[k].name01).value = objElements[i].getAttribute('RESVAL');
                         }
                         if (objElements[i].getAttribute('RESSEQ') == '2') {
                            document.getElementById(cobjTest.responses[k].name02).value = objElements[i].getAttribute('RESVAL');
                         }
                         break;
                      }
                  }
               }
            }
         }
         document.getElementById('RES_ResCode').focus();
      }
   }
   function doResponseList() {
      if (!processForm()) {return;}
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*LSTRES" VALCDE="'+cstrRespValCde+'"/>';
      doActivityStart(document.body);
      window.setTimeout('requestResponseList(\''+strXML+'\');',10);
   }
   function requestResponseList(strXML) {
      doPostRequest('<%=strBase%>pts_val_response_list.asp',function(strResponse) {checkResponseList(strResponse);},false,streamXML(strXML));
   }
   function checkResponseList(strResponse) {
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
         var objResList = document.getElementById('RES_ResList');
         var objRow;
         var objCell;
         var objInput;
         var objResList = document.getElementById('RES_ResList');
         for (var i=objResList.rows.length-1;i>=0;i--) {
            objResList.deleteRow(i);
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PET') {
               objRow = objResList.insertRow(-1);
               objRow.setAttribute('petcde',objElements[i].getAttribute('PETCDE'));
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
               objCell.innerHTML = objElements[i].getAttribute('PETTXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         document.getElementById('SCR_ResList').scrollTop = 0;
         document.getElementById('SCR_ResList').scrollLeft = 0;
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
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Validation Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_ValCode" id="PRO_ValCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptResponse();">&nbsp;Update&nbsp;</a></nobr></td>
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
         <td id="hedResponse" class="clsFunction" align=center colspan=2 nowrap><nobr>Validation Response Entry</nobr></td>
      </tr>
      <tr>
         <td id="subResponse" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Validation Text</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>Response Data Entry</nobr></td>
      </tr>
      <tr height=100%>
         <td width=75% align=left colspan=1 nowrap><nobr>
            <div id="SCR_ResData" class="clsScroll01" style="display:block;visibility:visible;background-color:transparent;">
               <table id="RES_ResData" class="clsPanel" cols=1 align=left cellpadding="0" cellspacing="0"></table>
            </div>
         </nobr></td>
         <td width=25% align=left colspan=1 nowrap><nobr>
            <table class="clsPanel" align=center cols=1 height=100% width=100% cellpadding="0" cellspacing="0">
               <tr><td><nobr>
                  <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
                     <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doResponseList();">&nbsp;Refresh&nbsp;</a></nobr></td></tr>
                  </table>
               </nobr></td></tr>
               <tr height=100%><td><nobr>
                  <div id="SCR_ResList" class="clsScroll01" style="display:block;visibility:visible;">
                     <table id="RES_ResList" class="clsTableBody" cols=1 align=left cellpadding="2" cellspacing="1"></table>
                  </div>
               </nobr></td></tr>
            </table>
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
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
<!--#include file="pts_search_html.inc"-->
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->