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
   var cstrTduFill;
   var cstrTduPack;
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
         cstrTduFill = '0';
         cstrTduPack = '0';
         var strPrdType = '';
         var intLineCount = 0;
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
               if (cstrDefineUsag == 'TDU') {
                  document.getElementById('TDU_Data').style.display = 'block';
               }
            } else if (objElements[i].nodeName == 'MATPTY') {
               strPrdType = objElements[i].getAttribute('PTYCDE');
               if (objElements[i].getAttribute('PTYCDE') == '*FILL') {
                  document.getElementById('FILL_Data').style.display = 'block';
                  if (cstrDefineUsag == 'TDU') {
                     cstrTduFill = '1';
                     document.getElementById('DEF_TduFill').checked = true;
                  }
                  document.getElementById('FILL_SchPrty').value = objElements[i].getAttribute('MPRSCH');
                  document.getElementById('FILL_BchQnty').value = objElements[i].getAttribute('MPRBQY');
                  document.getElementById('FILL_YldPcnt').value = objElements[i].getAttribute('MPRYPC');
                  document.getElementById('FILL_PckPcnt').value = objElements[i].getAttribute('MPRYVL');
               } else if (objElements[i].getAttribute('PTYCDE') == '*PACK') {
                  document.getElementById('PACK_Data').style.display = 'block';
                  if (cstrDefineUsag == 'TDU') {
                     cstrTduPack = '1';
                     document.getElementById('DEF_TduPack').checked = true;
                  }
               } else if (objElements[i].getAttribute('PTYCDE') == '*FORM') {
                  document.getElementById('FORM_Data').style.display = 'block';
                  document.getElementById('DEF_MatCode').innerHTML = '<p>'+objElements[i].getAttribute('MATCDE')+'</p>';
               }
            } else if (objElements[i].nodeName == 'MATLIN') {
               if (strPrdType == '*FILL') {
                  objRow = objFillLinList.insertRow(-1);
               } else if (strPrdType == '*PACK') {
                  objRow = objPackLinList.insertRow(-1);
               } else if (strPrdType == '*FORM') {
                  objRow = objFormLinList.insertRow(-1);
               }
               intLineCount++;
               objRow.setAttribute('lincde',objElements[i].getAttribute('LINCDE'));
               objRow.setAttribute('lcocde',objElements[i].getAttribute('LCOCDE'));
               objRow.setAttribute('lincnt',intLineCount);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
               try {
                  objInput = document.createElement('<input type="radio" name="FILL_Dflt"/>');
               } catch (objException) {
                  objInput = document.createElement('input');
                  objInput.type = 'radio';
                  objInput.name = 'FILL_Dflt';
               }
               objInput.onfocus = function() {setSelect(this);};
               objInput.onclick = function() {doDefaultClick(this);};
               objInput.checked = false;
               objInput.setAttribute('lincnt',intLineCount);
               objCell.appendChild(objInput);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
               objInput = document.createElement('input');
               objInput.type = 'checkbox';
               objInput.value = '';
               objInput.id = 'LCOCHK_'+intLineCount;
               objInput.onfocus = function() {setSelect(this);};
               objInput.onclick = function() {doLineClick(this);};
               objInput.checked = false;
               objInput.setAttribute('lincnt',intLineCount);
               if (objElements[i].getAttribute('LCORRA') != '*NONE') {
                  objInput.checked = true;
               }
               objCell.appendChild(objInput);
               objCell.appendChild(document.createTextNode(objElements[i].getAttribute('LINNAM')+' - '+objElements[i].getAttribute('LCONAM')));
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
               objSelect = document.createElement('select');
               objSelect.id = 'LCORRA_'+intLineCount;
               objSelect.className = 'clsInputNN';
               objSelect.onchange = function() {doRateChange(this);};
               objSelect.setAttribute('lincnt',intLineCount);
               objSelect.disabled = true;
               if (objElements[i].getAttribute('LCORRA') != '*NONE') {
                  objSelect.disabled = false;
               }
               objCell.appendChild(objSelect);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.vAlign = 'center';
               objCell.id = 'RRAEFF_'+intLineCount;
               objCell.className = 'clsLabelBN';
               objCell.innerHTML = '';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.vAlign = 'center';
               objCell.id = 'RRAWAS_'+intLineCount;
               objCell.className = 'clsLabelBN';
               objCell.innerHTML = '';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.vAlign = 'center';
               objCell.className = 'clsLabelBN';
               objCell.style.whiteSpace = 'nowrap';
               objInput = document.createElement('input');
               objInput.type = 'text';
               objInput.value = objElements[i].getAttribute('LCOEFF');
               objInput.id = 'LCOEFF_'+intLineCount;
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
               objInput.value = objElements[i].getAttribute('LCOWAS');
               objInput.id = 'LCOWAS_'+intLineCount;
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
            } else if (objElements[i].nodeName == 'MATRRA') {
               if (strPrdType == '*FILL') {
                  objSelect.options[objSelect.options.length] = new Option(objElements[i].getAttribute('RRANAM'),objElements[i].getAttribute('RRACDE'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rraeff',objElements[i].getAttribute('RRAEFF'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rrawas',objElements[i].getAttribute('RRAWAS'));
                  document.getElementById('RRAEFF_'+intLineCount).innerHTML = objElements[i].getAttribute('RRAEFF');
                  document.getElementById('RRAWAS_'+intLineCount).innerHTML = objElements[i].getAttribute('RRAWAS');
               } else if (strPrdType == '*PACK') {
                  objSelect.options[objSelect.options.length] = new Option(objElements[i].getAttribute('RRANAM'),objElements[i].getAttribute('RRACDE'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rraeff',objElements[i].getAttribute('RRAEFF'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rrawas',objElements[i].getAttribute('RRAWAS'));
                  document.getElementById('RRAEFF_'+intLineCount).innerHTML = objElements[i].getAttribute('RRAEFF');
                  document.getElementById('RRAWAS_'+intLineCount).innerHTML = objElements[i].getAttribute('RRAWAS');
               } else if (strPrdType == '*FORM') {
                  objSelect.options[objSelect.options.length] = new Option(objElements[i].getAttribute('RRANAM'),objElements[i].getAttribute('RRACDE'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rraeff',objElements[i].getAttribute('RRAEFF'));
                  objSelect.options[objSelect.options.length-1].setAttribute('rrawas',objElements[i].getAttribute('RRAWAS'));
                  document.getElementById('RRAEFF_'+intLineCount).innerHTML = objElements[i].getAttribute('RRAEFF');
                  document.getElementById('RRAWAS_'+intLineCount).innerHTML = objElements[i].getAttribute('RRAWAS');
               }
            } else if (objElements[i].nodeName == 'MATCOM') {
               if (strPrdType == '*FILL') {
               } else if (strPrdType == '*PACK') {
               } else if (strPrdType == '*FORM') {
               }
            }
         }
       //  document.getElementById('DEF_MatName').focus();
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objMatType = document.getElementById('DEF_MatType');
      var objMatStat = document.getElementById('DEF_MatStat');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrDefineMode == '*UPD') {
         strXML = strXML+'<PSA_REQUEST ACTION="*UPDDEF"';
         strXML = strXML+' MATCDE="'+fixXML(cstrDefineCode)+'"';
      } else {
         strXML = strXML+'<PSA_REQUEST ACTION="*CRTDEF"';
         strXML = strXML+' MATCDE="'+fixXML(document.getElementById('DEF_MatCode').value)+'"';
      }
      strXML = strXML+' MATNAM="'+fixXML(document.getElementById('DEF_MatName').value)+'"';
      if (objMatType.selectedIndex == -1) {
         strXML = strXML+' MATTYP=""';
      } else {
         strXML = strXML+' MATTYP="'+fixXML(objMatType.options[objMatType.selectedIndex].value)+'"';
      }
      if (objMatStat.selectedIndex == -1) {
         strXML = strXML+' MATSTS=""';
      } else {
         strXML = strXML+' MATSTS="'+fixXML(objMatStat.options[objMatStat.selectedIndex].value)+'"';
      }
      strXML = strXML+'>';

      for (var i=0;i<objResData.rows.length;i++) {
         objRow = objResData.rows[i];
         strXML = strXML+'<CMORES RESCDE="'+fixXML(objRow.getAttribute('rescod'))+'" RESQTY="'+fixXML(document.getElementById('DEF_'+objRow.getAttribute('rescod')).value)+'"/>';
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
   function doDefaultClick(objRadio) {
      if (objRadio.checked == true) {
         document.getElementById('LCOCHK_'+objRadio.getAttribute('lincnt')).checked = true;
         document.getElementById('LCORRA_'+objRadio.getAttribute('lincnt')).disabled = false;
         document.getElementById('LCOEFF_'+objRadio.getAttribute('lincnt')).disabled = false;
         document.getElementById('LCOWAS_'+objRadio.getAttribute('lincnt')).disabled = false;
      }
   }
   function doLineClick(objCheck) {
      if (objCheck.checked == false) {
         document.getElementById('LCORRA_'+objCheck.getAttribute('lincnt')).disabled = true;
         document.getElementById('LCOEFF_'+objCheck.getAttribute('lincnt')).disabled = true;
         document.getElementById('LCOWAS_'+objCheck.getAttribute('lincnt')).disabled = true;
      } else {
         document.getElementById('LCORRA_'+objCheck.getAttribute('lincnt')).disabled = false;
         document.getElementById('LCOEFF_'+objCheck.getAttribute('lincnt')).disabled = false;
         document.getElementById('LCOWAS_'+objCheck.getAttribute('lincnt')).disabled = false;
      }
   }
   function doRateChange(objSelect) {
      document.getElementById('RRAEFF_'+objSelect.getAttribute('lincnt')).innerHTML = objSelect.options[objSelect.selectedIndex].getAttribute('rraeff');
      document.getElementById('RRAWAS_'+objSelect.getAttribute('lincnt')).innerHTML = objSelect.options[objSelect.selectedIndex].getAttribute('rrawas');
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
            <table class="clsTable01" align=center cols=4 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><input class="clsInputNN" style="text-transform:uppercase;" type="text" name="SEL_SelCode" size="32" maxlength="32" value="" onFocus="setSelect(this);"></nobr></td>
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
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Material Define</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
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
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelHB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Filling&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsGrid02" align=center valign=top cols=5 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Default Production Line</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Scheduling Priority</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Batch Case Quantity</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Yield Percentage</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Pack Weight Percentage</nobr></td>
                        </tr>
                        <tr>
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
                     <table class="clsGrid02" align=center valign=top cols=3 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Yield Value</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Pack Weight Value</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Batch Weight Value</nobr></td>
                        </tr>
                        <tr>
                           <td id="FILL_YldValu" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                           <td id="FILL_PckValu" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                           <td id="FILL_BchValu" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsGrid02" align=center valign=top cols=2 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Filling Components</nobr></td>
                           <td class="clsLabelBB" align=left colspan=1 nowrap><nobr>
                              <table class="clsTable01" align=left cols=5 cellpadding="0" cellspacing="0">
                                 <tr>
                                    <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFillCompAdd();">&nbsp;Add&nbsp;</a></nobr></td>
                                    <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                                    <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFillCompUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                                    <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                                    <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFillCompDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
                                 </tr>
                              </table>
                           </nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" align=left colspan=2 nowrap><nobr>
                              <select class="clsInputBN" id="FILL_ComList" name="FILL_ComList" style="width:400px" multiple size=3></select>
                           </nobr></td>
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
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Default</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="left" valign="center" colspan="1" nowrap><nobr>Line Configuration</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Run Rate</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Efficiency %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Wastage %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Efficiency %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Wastage %</nobr></td>
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
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelHB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Packing&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsGrid02" align=center valign=top cols=4 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Default Production Line</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Scheduling Priority</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Cases Per Pallet</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Yield Value</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><select class="clsInputBN" id="PACK_PrdLine"></select></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="PACK_SchPrty" size="4" maxlength="4" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="PACK_CasPllt" size="5" maxlength="5" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr>1</nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsGrid02" align=center valign=top cols=2 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Packing Components</nobr></td>
                           <td class="clsLabelBB" align=left colspan=1 nowrap><nobr>
                              <table class="clsTable01" align=left cols=5 cellpadding="0" cellspacing="0">
                                 <tr>
                                    <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPackCompAdd();">&nbsp;Add&nbsp;</a></nobr></td>
                                    <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                                    <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPackCompUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                                    <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                                    <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPackCompDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
                                 </tr>
                              </table>
                           </nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" align=left colspan=2 nowrap><nobr>
                              <select class="clsInputBN" id="PACK_ComList" name="PACK_ComList" style="width:400px" multiple size=3></select>
                           </nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table id="PACK_LinList" class="clsGrid02" align=center valign=top cols=7 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="3" nowrap><nobr>Packing Line Configurations</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Run Rate</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Override</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Default</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="left" valign="center" colspan="1" nowrap><nobr>Line Configuration</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Run Rate</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Efficiency %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Wastage %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Efficiency %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Wastage %</nobr></td>
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
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelHB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;Forming&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsGrid02" align=center valign=top cols=4 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Default Production Line</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Scheduling Priority</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Batch Lot Quantity</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Yield Value</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><select class="clsInputBN" id="FORM_PrdLine"></select></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="FORM_SchPrty" size="4" maxlength="4" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                           <td class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="FORM_BchQnty" size="9" maxlength="9" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);"></nobr></td>
                           <td id="FORM_YldValu" class="clsLabelBN" style="padding-left:2px;padding-right:2px;" align="center" valign=center colspan=1 nowrap><nobr>1</nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table class="clsGrid02" align=center valign=top cols=2 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Forming Components</nobr></td>
                           <td class="clsLabelBB" align=left colspan=1 nowrap><nobr>
                              <table class="clsTable01" align=left cols=5 cellpadding="0" cellspacing="0">
                                 <tr>
                                    <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFormCompAdd();">&nbsp;Add&nbsp;</a></nobr></td>
                                    <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                                    <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFormCompUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                                    <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                                    <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFormCompDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
                                 </tr>
                              </table>
                           </nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" align=left colspan=2 nowrap><nobr>
                              <select class="clsInputBN" id="FORM_ComList" name="FORM_ComList" style="width:400px" multiple size=3></select>
                           </nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
                     <table id="FORM_LinList" class="clsGrid02" align=center valign=top cols=7 cellpadding=0 cellspacing=1>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="3" nowrap><nobr>Forming Line Configurations</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Run Rate</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="2" nowrap><nobr>Override</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Default</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="left" valign="center" colspan="1" nowrap><nobr>Line Configuration</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Run Rate</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Efficiency %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Wastage %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Efficiency %</nobr></td>
                           <td class="clsLabelBB" style="background-color:#efefef;color:#000000;border:#708090 1px solid;padding-left:2px;padding-right:2px;" align="center" valign="center" colspan="1" nowrap><nobr>Wastage %</nobr></td>
                        </tr>
                     </table>
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