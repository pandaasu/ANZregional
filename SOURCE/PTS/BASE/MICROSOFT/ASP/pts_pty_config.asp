<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_pty_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the pet type maintenance    //
'//           functionality                                      //
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
   strTarget = "pts_pty_config.asp"
   strHeading = "Pet Type Maintenance"

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
   strReturn = GetSecurityCheck("PTS_PTY_CONFIG")
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
      cobjScreens[0] = new clsScreen('dspPrompt','hedPrompt');
      cobjScreens[1] = new clsScreen('dspDefine','hedDefine');
      cobjScreens[2] = new clsScreen('dspList','hedList');
      cobjScreens[3] = new clsScreen('dspField','hedField');
      cobjScreens[4] = new clsScreen('dspFldUpd','hedFldUpd');
      cobjScreens[5] = new clsScreen('dspValue','hedValue');
      cobjScreens[0].hedtxt = 'Pet Type Prompt';
      cobjScreens[1].hedtxt = 'Pet Type Maintenance';
      cobjScreens[2].hedtxt = 'Pet Type List';
      cobjScreens[3].hedtxt = 'Pet Type Field Maintenance';
      cobjScreens[4].hedtxt = 'Pet Type Field Update';
      cobjScreens[5].hedtxt = 'Pet Type Value Update';
      displayScreen('dspPrompt');
      document.getElementById('PRO_PtyCode').focus();
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
      if (document.getElementById('PRO_PtyCode').value == '') {
         doPromptCreate();
      } else {
         doPromptUpdate();
      }
   }
   function doPromptUpdate() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_PtyCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Pet Type code must be entered for update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+document.getElementById('PRO_PtyCode').value+'\');',10);
   }
   function doPromptCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
   }
   function doPromptCopy() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_PtyCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Pet Type code must be entered for copy';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+document.getElementById('PRO_PtyCode').value+'\');',10);
   }
   function doPromptField() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_PtyCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Pet Type code must be entered for field maintenance';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      cstrFieldTypCde = document.getElementById('PRO_PtyCode').value;
      doActivityStart(document.body);
      window.setTimeout('requestFieldList();',10);
   }
   function doPromptList() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestList();',10);
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDPTY" PTYCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_pty_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTPTY" PTYCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_pty_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYPTY" PTYCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_pty_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[1].hedtxt = 'Update Pet Type ('+cstrDefineCode+')';
         } else {
            cobjScreens[1].hedtxt = 'Create Pet Type (*NEW)';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_PtyCode').value = '';
         document.getElementById('DEF_PtyText').value = '';
         var strPtyStat;
         var objPtyStat = document.getElementById('DEF_PtyStat');
         objPtyStat.options.length = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'STA_LIST') {
               objPtyStat.options[objPtyStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'PET_TYPE') {
               document.getElementById('DEF_PtyCode').value = objElements[i].getAttribute('PTYCODE');
               document.getElementById('DEF_PtyText').value = objElements[i].getAttribute('PTYTEXT');
               strPtyStat = objElements[i].getAttribute('PTYSTAT');
            }
         }
         objPtyStat.selectedIndex = -1;
         for (var i=0;i<objPtyStat.length;i++) {
            if (objPtyStat.options[i].value == strPtyStat) {
               objPtyStat.options[i].selected = true;
               break;
            }
         }
         document.getElementById('DEF_PtyText').focus();
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objPtyStat = document.getElementById('DEF_PtyStat');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*DEFPTY"';
      strXML = strXML+' PTYCODE="'+fixXML(document.getElementById('DEF_PtyCode').value)+'"';
      strXML = strXML+' PTYTEXT="'+fixXML(document.getElementById('DEF_PtyText').value)+'"';
      strXML = strXML+' PTYSTAT="'+fixXML(objPtyStat.options[objPtyStat.selectedIndex].value)+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>pts_pty_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         document.getElementById('PRO_PtyCode').value = '';
         document.getElementById('PRO_PtyCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_PtyCode').value = '';
      document.getElementById('PRO_PtyCode').focus();
   }

   ////////////////////
   // List Functions //
   ////////////////////
   function requestList() {
      doPostRequest('<%=strBase%>pts_pty_list.asp',function(strResponse) {checkList(strResponse);},false,'<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTPTY"/>');
   }
   function checkList(strResponse) {
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
         displayScreen('dspList');
         var objTable = document.getElementById('LST_List');
         var objRow;
         var objCell;
         for (var i=objTable.rows.length-1;i>=0;i--) {
            objTable.deleteRow(i);
         }
         var intColCount = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'LSTCTL') {
               intColCount = objElements[i].getAttribute('COLCNT');
            } else if (objElements[i].nodeName == 'LSTROW') {
               objRow = objTable.insertRow(-1);
               objRow.setAttribute('selcde',objElements[i].getAttribute('SELCDE'));
               objRow.setAttribute('seltxt',objElements[i].getAttribute('SELTXT'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '<a class="clsSelect" onClick="doListAccept(\''+objRow.rowIndex+'\');">Select</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               for (var j=1;j<=intColCount;j++) {
                  objCell = objRow.insertCell(j);
                  objCell.colSpan = 1;
                  objCell.innerText = objElements[i].getAttribute('COL'+j);
                  objCell.className = 'clsLabelFN';
                  objCell.style.whiteSpace = 'nowrap';
               }
            }
         }
         if (objTable.rows.length == 0) {
            objRow = objTable.insertRow(-1);
            objCell = objRow.insertCell(0);
            objCell.colSpan = intColCount+1;
            objCell.innerText = 'NO DATA FOUND';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
         }
      }
   }
   function doListAccept(intRow) {
      document.getElementById('PRO_PtyCode').value = document.getElementById('LST_List').rows[intRow].getAttribute('selcde');
      displayScreen('dspPrompt');
      document.getElementById('PRO_PtyCode').focus();
   }
   function doListCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_PtyCode').focus();
   }

   /////////////////////
   // Field Functions //
   /////////////////////
   var cstrFieldTypCde;
   var cstrFieldTypTxt;
   var cstrFieldTabCde;
   var cstrFieldTabTxt;
   var cstrFieldFldCde;
   var cstrFieldFldTxt;
   function requestFieldList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVFLD" PTYCDE="'+cstrFieldTypCde+'"/>';
      doPostRequest('<%=strBase%>pts_pty_config_field_retrieve.asp',function(strResponse) {checkFieldList(strResponse);},false,streamXML(strXML));
   }
   function checkFieldList(strResponse) {
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
         cstrFieldTypTxt = '';
         var objFldList = document.getElementById('FLD_FldList');
         var objRow;
         var objCell;
         var strTabCode;
         for (var i=objFldList.rows.length-1;i>=0;i--) {
            objFldList.deleteRow(i);
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PET_TYPE') {
               cstrFieldTypTxt = objElements[i].getAttribute('PTYTEXT');
            } else if (objElements[i].nodeName == 'TABLE') {
               objRow = objFldList.insertRow(-1);
               objRow.setAttribute('tabcde',objElements[i].getAttribute('TABCDE'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 4;
               objCell.innerText = objElements[i].getAttribute('TABTXT');
               objCell.className = 'clsLabelFB';
               objCell.style.whiteSpace = 'nowrap';
               strTabCode = objElements[i].getAttribute('TABCDE');
            } else if (objElements[i].nodeName == 'FIELD') {
               objRow = objFldList.insertRow(-1);
               objRow.setAttribute('tabcde',strTabCode);
               objRow.setAttribute('fldcde',objElements[i].getAttribute('FLDCDE'));
               objRow.setAttribute('fldtxt',objElements[i].getAttribute('FLDTXT'));
               objRow.setAttribute('ptysts',objElements[i].getAttribute('PTYSTS'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               if (objElements[i].getAttribute('VALTYP') == '*SELECT') {
                  objCell.innerHTML = '<a class="clsSelect" onClick="doFieldSelect(\''+objRow.rowIndex+'\');">Select Field</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doValueSelect(\''+objRow.rowIndex+'\');">Select Values</a>';
               } else {
                  objCell.innerHTML = '<a class="clsSelect" onClick="doFieldSelect(\''+objRow.rowIndex+'\');">Select Field</a>';
               }
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               if (objElements[i].getAttribute('PTYSTS') == '1') {
                  objCell.innerText = 'Selected';
                  objCell.className = 'clsLabelFB';
               } else {
                  objCell.innerText = 'Not Selected';
                  objCell.className = 'clsLabelFN';
               }
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(2);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('FLDTXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(3);
               objCell.colSpan = 1;
               if (objElements[i].getAttribute('FLDSTS') == '1') {
                  objCell.innerText = 'Active';
               } else {
                  objCell.innerText = 'Inactive';
               }
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         document.getElementById('subField').innerText = cstrFieldTypTxt;
         displayScreen('dspField');
         objFldList.focus();
      }
   }
   function doFieldSelect(intRow) {
      var objTable = document.getElementById('FLD_FldList');
      objRow = objTable.rows[intRow];
      cstrFieldTabCde = objRow.getAttribute('tabcde');
      cstrFieldFldCde = objRow.getAttribute('fldcde');
      cstrFieldFldTxt = objRow.getAttribute('fldtxt');
      document.getElementById('subFldUpd').innerText = cstrFieldTypTxt;
      document.getElementById('minFldUpd').innerText = cstrFieldFldTxt;
      var objFldSlct = document.getElementById('FUP_FldSlct');
      objFldSlct.selectedIndex = -1;
      for (var i=0;i<objFldSlct.length;i++) {
         if (objFldSlct.options[i].value == objRow.getAttribute('ptysts')) {
            objFldSlct.options[i].selected = true;
            break;
         }
      }
      displayScreen('dspFldUpd');
      objFldSlct.focus();
   }
   function doValueSelect(intRow) {
      var objTable = document.getElementById('FLD_FldList');
      objRow = objTable.rows[intRow];
      cstrFieldTabCde = objRow.getAttribute('tabcde');
      cstrFieldFldCde = objRow.getAttribute('fldcde');
      cstrFieldFldTxt = objRow.getAttribute('fldtxt');
      doActivityStart(document.body);
      window.setTimeout('requestValueList();',10);
   }
   function doFieldBack() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_PtyCode').value = '';
      document.getElementById('PRO_PtyCode').focus();
   }

   ////////////////////////////
   // Field Update Functions //
   ////////////////////////////
   function doFldUpdCancel() {
      displayScreen('dspField');
      document.getElementById('FLD_FldList').focus();
   }
   function doFldUpdAccept() {
      if (!processForm()) {return;}
      var objFldSlct = document.getElementById('FUP_FldSlct');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDFLD"';
      strXML = strXML+' PTYCDE="'+cstrFieldTypCde+'"';
      strXML = strXML+' TABCDE="'+cstrFieldTabCde+'"';
      strXML = strXML+' FLDCDE="'+cstrFieldFldCde+'"';
      strXML = strXML+' PTYSTS="'+objFldSlct.options[objFldSlct.selectedIndex].value+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestFldUpdUpdate(\''+strXML+'\');',10);
   }
   function requestFldUpdUpdate(strXML) {
      doPostRequest('<%=strBase%>pts_pty_config_field_update.asp',function(strResponse) {checkFldUpdUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkFldUpdUpdate(strResponse) {
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
         requestFieldList();
      }
   }

   /////////////////////
   // Value Functions //
   /////////////////////
   function requestValueList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVVAL" PTYCDE="'+cstrFieldTypCde+'" TABCDE="'+cstrFieldTabCde+'" FLDCDE="'+cstrFieldFldCde+'"/>';
      doPostRequest('<%=strBase%>pts_pty_config_value_retrieve.asp',function(strResponse) {checkValueList(strResponse);},false,streamXML(strXML));
   }
   function checkValueList(strResponse) {
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
         document.getElementById('subValue').innerText = cstrFieldTypTxt;
         document.getElementById('minValue').innerText = cstrFieldFldTxt;
         var objAvlValue = document.getElementById('VAL_AvlValue');
         var objSelValue = document.getElementById('VAL_SelValue');
         objAvlValue.options.length = 0;
         objAvlValue.selectedIndex = -1;
         objSelValue.options.length = 0;
         objSelValue.selectedIndex = -1;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'VALUE') {
               objAvlValue.options[objAvlValue.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
               if (objElements[i].getAttribute('PTYSTS') == '1') {
                  objSelValue.options[objSelValue.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
               }
            }
         }
         displayScreen('dspValue');
         objAvlValue.focus();
      }
   }
   function doValueCancel() {
      displayScreen('dspField');
      document.getElementById('FLD_FldList').focus();
   }
   function doValueAccept() {
      if (!processForm()) {return;}
      var objSelValue = document.getElementById('VAL_SelValue');
      var strMessage = '';
      if (objSelValue.options.length == 0) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'At least one value must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (confirm('Please confirm the update\r\npress OK continue (all existing non-selected data values for this field will be deleted from all pets of this pet type)\r\npress Cancel to return ignore') == false) {
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDVAL"';
      strXML = strXML+' PTYCDE="'+cstrFieldTypCde+'"';
      strXML = strXML+' TABCDE="'+cstrFieldTabCde+'"';
      strXML = strXML+' FLDCDE="'+cstrFieldFldCde+'"';
      strXML = strXML+'/>';
      for (var i=0;i<objSelValue.options.length;i++) {
         strXML = strXML+'<VALUE VALCDE="'+objSelValue[i].value+'"/>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestValueUpdate(\''+strXML+'\');',10);
   }
   function requestValueUpdate(strXML) {
      doPostRequest('<%=strBase%>pts_pty_config_value_update.asp',function(strResponse) {checkValueUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkValueUpdate(strResponse) {
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
         requestFieldList();
      }
   }
   function selectValueValues() {
      var objAvlValue = document.getElementById('VAL_AvlValue');
      var objSelValue = document.getElementById('VAL_SelValue');
      var bolFound;
      for (var i=0;i<objAvlValue.options.length;i++) {
         if (objAvlValue.options[i].selected == true) {
            bolFound = false;
            for (var j=0;j<objSelValue.options.length;j++) {
               if (objAvlValue[i].value == objSelValue[j].value) {
                  bolFound = true;
                  break;
               }
            }
            if (!bolFound) {
               objSelValue.options[objSelValue.options.length] = new Option(objAvlValue[i].text,objAvlValue[i].value);
            }
         }
      }
      var objWork = new Array();
      var intIndex = 0
      for (var i=0;i<objSelValue.options.length;i++) {
         objWork[intIndex] = objSelValue[i];
         intIndex++;
      }
      objWork.sort(sortValueValues);
      objSelValue.options.length = 0;
      objSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSelValue.options[i] = objWork[i];
      }
   }
   function removeValueValues() {
      var objSelValue = document.getElementById('VAL_SelValue');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objSelValue.options.length;i++) {
         if (objSelValue.options[i].selected == false) {
            objWork[intIndex] = objSelValue[i];
            intIndex++;
         }
      }
      objSelValue.options.length = 0;
      objSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSelValue.options[i] = objWork[i];
      }
   }
   function sortValueValues(obj01, obj02) {
      if ((obj01.value-0) < (obj02.value-0)) {
         return -1;
      } else if ((obj01.value-0) > (obj02.value-0)) {
         return 1;
      }
      return 0;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_pty_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPromptEnter();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Pet Type Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Type Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_PtyCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptField();">&nbsp;Fields&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptList();">&nbsp;List&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Pet Type Maintenance</nobr></td>
         <input type="hidden" name="DEF_PtyCode" value="">
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_PtyText" size="100" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_PtyStat"></select>
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
   <table id="dspList" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedList" class="clsFunction" align=center colspan=2 nowrap><nobr>Pet Type List</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="LST_List" class="clsTableBody" cols=1 align=left cellpadding="2" cellspacing="1"></table>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doListCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspField" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedField" class="clsFunction" align=center colspan=2 nowrap><nobr>Pet Type Field Maintenance</nobr></td>
      </tr>
      <tr>
         <td id="subField" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Pet Type Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="FLD_FldList" class="clsTableBody" cols=1 align=left cellpadding="2" cellspacing="1"></table>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFieldBack();">&nbsp;Back&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspFldUpd" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doFldUpdAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedFldUpd" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Pet Type Field Update</nobr></td>
      </tr>
      <tr>
         <td id="subFldUpd" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Pet Type Name</nobr></td>
      <tr>
         <td id="minFldUpd" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Field Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Field Selected:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="FUP_FldSlct">
               <option value="0">No
               <option value="1">Yes
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFldUpdCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doFldUpdAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspValue" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doValueAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedValue" class="clsFunction" align=center colspan=2 nowrap><nobr>Pet Type Value Update</nobr></td>
      </tr>
      <tr>
         <td id="subValue" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Pet Type Name</nobr></td>
      <tr>
         <td id="minValue" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Field Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 width=100% cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
                     <table align=center border=0 cellpadding=0 cellspacing=2 cols=3>
                        <tr>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Available Values&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Selected Values&nbsp;</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                              <select class="clsInputBN" id="VAL_AvlValue" name="VAL_AvlValue" style="width:300px" multiple size=20></select>
                           </nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                              <table class="clsTable01" width=100% align=center cols=2 cellpadding="0" cellspacing="0">
                                 <tr>
                                    <td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_loff.gif" align=absmiddle onClick="removeValueValues();"></nobr></td>
                                    <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_roff.gif" align=absmiddle onClick="selectValueValues();"></nobr></td>
                                 </tr>
                              </table>
                           </nobr></td>
                           <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                              <select class="clsInputBN" id="VAL_SelValue" name="VAL_SelValue" style="width:300px" multiple size=20></select>
                           </nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doValueCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doValueAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->