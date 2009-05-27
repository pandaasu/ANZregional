<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_fld_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the system field            //
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
   dim objSelection

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "pts_fld_config.asp"
   strHeading = "System Field Maintenance"

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
   strReturn = GetSecurityCheck("PTS_FLD_CONFIG")
   if strReturn <> "*OK" then
      call PaintFatal
   else
      call PaintFunction
   end if

   '//
   '// Destroy references
   '//
   set objSecurity = nothing
   set objSelection = nothing

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
      cobjScreens[0] = new clsScreen('dspMenu','hedMenu');
      cobjScreens[1] = new clsScreen('dspSort','hedSort');
      cobjScreens[2] = new clsScreen('dspField','hedField');
      cobjScreens[3] = new clsScreen('dspFldUpd','hedFldUpd');
      cobjScreens[4] = new clsScreen('dspValue','hedValue');
      cobjScreens[5] = new clsScreen('dspValUpd','hedValUpd');
      cobjScreens[0].hedtxt = 'System Table Maintenance';
      cobjScreens[1].hedtxt = 'System Field Sort';
      cobjScreens[2].hedtxt = 'System Field Maintenance';
      cobjScreens[3].hedtxt = 'System Field Update';
      cobjScreens[4].hedtxt = 'System Value Maintenance';
      cobjScreens[5].hedtxt = 'System Value Update';
      displayScreen('dspMenu');
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
   // Select Functions ///
   /////////////////////
   function doSortField(strTabCde,strTabTxt) {
      if (!processForm()) {return;}
      cstrSortTabCde = strTabCde;
      cstrSortTabTxt = strTabTxt;
      doActivityStart(document.body);
      window.setTimeout('requestSortField();',10);
   }
   function doFieldList(strTabCde,strTabTxt) {
      if (!processForm()) {return;}
      cstrFieldTabCde = strTabCde;
      cstrFieldTabTxt = strTabTxt;
      doActivityStart(document.body);
      window.setTimeout('requestFieldList();',10);
   }

   ////////////////////
   // Sort Functions //
   ////////////////////
   var cstrSortTabCde;
   var cstrSortTabTxt;
   function requestSortField() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVSRT" TABCDE="'+cstrSortTabCde+'"/>';
      doPostRequest('<%=strBase%>pts_fld_config_sort_retrieve.asp',function(strResponse) {checkSortField(strResponse);},false,streamXML(strXML));
   }
   function checkSortField(strResponse) {
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
         document.getElementById('subSort').innerText = cstrSortTabTxt;
         var objFldList = document.getElementById('SRT_FldList');
         objFldList.options.length = 0;
         objFldList.selectedIndex = -1;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'FIELD') {
               objFldList.options[objFldList.options.length] = new Option(objElements[i].getAttribute('FLDTXT'),objElements[i].getAttribute('FLDCDE'));
            }
         }
         displayScreen('dspSort');
         objFldList.focus();
      }
   }
   function upSortField() {
      var intIndex;
      var intSelect;
      var objFldList = document.getElementById('SRT_FldList');
      intSelect = 0;
      for (var i=0;i<objFldList.options.length;i++) {
         if (objFldList.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one field can be selected to move up');
         return;
      }
      if (intSelect == 1 && intIndex > 0) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objFldList.options[intIndex-1].value;
         aryA[1] = objFldList.options[intIndex-1].text;
         aryB[0] = objFldList.options[intIndex].value;
         aryB[1] = objFldList.options[intIndex].text;
         objFldList.options[intIndex-1].value = aryB[0];
         objFldList.options[intIndex-1].text = aryB[1];
         objFldList.options[intIndex-1].selected = true;
         objFldList.options[intIndex].value = aryA[0];
         objFldList.options[intIndex].text = aryA[1];
         objFldList.options[intIndex].selected = false;
      }
   }
   function downSortField() {
      var intIndex;
      var intSelect;
      var objFldList = document.getElementById('SRT_FldList');
      intSelect = 0;
      for (var i=0;i<objFldList.options.length;i++) {
         if (objFldList.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one field can be selected to move down');
         return;
      }
      if (intSelect == 1 && intIndex < objFldList.options.length-1) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objFldList.options[intIndex+1].value;
         aryA[1] = objFldList.options[intIndex+1].text;
         aryB[0] = objFldList.options[intIndex].value;
         aryB[1] = objFldList.options[intIndex].text;
         objFldList.options[intIndex+1].value = aryB[0];
         objFldList.options[intIndex+1].text = aryB[1];
         objFldList.options[intIndex+1].selected = true;
         objFldList.options[intIndex].value = aryA[0];
         objFldList.options[intIndex].text = aryA[1];
         objFldList.options[intIndex].selected = false;
      }
   }
   function doSortCancel() {
      displayScreen('dspMenu');
   }
   function doSortAccept() {
      if (!processForm()) {return;}
      var objFldList = document.getElementById('SRT_FldList');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDSRT"';
      strXML = strXML+' TABCDE="'+fixXML(cstrSortTabCde)+'"';
      strXML = strXML+'>';
      for (var i=0;i<objFldList.length;i++) {
         strXML = strXML+'<FIELD FLDCDE="'+fixXML(objFldList.options[i].value)+'"/>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestSortUpdate(\''+strXML+'\');',10);
   }
   function requestSortUpdate(strXML) {
      doPostRequest('<%=strBase%>pts_fld_config_sort_update.asp',function(strResponse) {checkSortUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkSortUpdate(strResponse) {
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
         displayScreen('dspMenu');
      }
   }

   /////////////////////
   // Field Functions //
   /////////////////////
   var cstrFieldTabCde;
   var cstrFieldTabTxt;
   var cstrFieldFldCde;
   var cstrFieldFldTxt;
   var cstrFieldValCde;
   var cstrFieldValTxt;
   function requestFieldList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVFLD" TABCDE="'+cstrFieldTabCde+'"/>';
      doPostRequest('<%=strBase%>pts_fld_config_field_retrieve.asp',function(strResponse) {checkFieldList(strResponse);},false,streamXML(strXML));
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
         document.getElementById('subField').innerText = cstrFieldTabTxt;
         var objFldList = document.getElementById('FLD_FldList');
         var objRow;
         var objCell;
         for (var i=objFldList.rows.length-1;i>=0;i--) {
            objFldList.deleteRow(i);
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'FIELD') {
               objRow = objFldList.insertRow(-1);
               objRow.setAttribute('fldcde',objElements[i].getAttribute('FLDCDE'));
               objRow.setAttribute('fldtxt',objElements[i].getAttribute('FLDTXT'));
               objRow.setAttribute('fldtyp',objElements[i].getAttribute('FLDTYP'));
               objRow.setAttribute('fldupd',objElements[i].getAttribute('FLDUPD'));
               objRow.setAttribute('fldsts',objElements[i].getAttribute('FLDSTS'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               if (objElements[i].getAttribute('FLDTYP') == '*LIST' && objElements[i].getAttribute('FLDUPD') == '1') {
                  objCell.innerHTML = '<a class="clsSelect" onClick="doFieldUpdate(\''+objRow.rowIndex+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doValueList(\''+objRow.rowIndex+'\');">Values</a>';
               } else {
                  objCell.innerHTML = '<a class="clsSelect" onClick="doFieldUpdate(\''+objRow.rowIndex+'\');">Update</a>';
               }
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('FLDTXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(2);
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
         displayScreen('dspField');
         objFldList.focus();
      }
   }
   function doFieldUpdate(intRow) {
      var objTable = document.getElementById('FLD_FldList');
      objRow = objTable.rows[intRow];
      cstrFieldFldCde = objRow.getAttribute('fldcde');
      cstrFieldFldTxt = objRow.getAttribute('fldtxt');
      document.getElementById('subFldUpd').innerText = cstrFieldTabTxt;
      document.getElementById('minFldUpd').innerText = cstrFieldFldTxt;
      var objFldStat = document.getElementById('FUP_FldStat');
      objFldStat.selectedIndex = -1;
      for (var i=0;i<objFldStat.length;i++) {
         if (objFldStat.options[i].value == objRow.getAttribute('fldsts')) {
            objFldStat.options[i].selected = true;
            break;
         }
      }
      displayScreen('dspFldUpd');
      objFldStat.focus();
   }
   function doValueList(intRow) {
      var objTable = document.getElementById('FLD_FldList');
      objRow = objTable.rows[intRow];
      cstrFieldFldCde = objRow.getAttribute('fldcde');
      cstrFieldFldTxt = objRow.getAttribute('fldtxt');
      doActivityStart(document.body);
      window.setTimeout('requestValueList();',10);
   }
   function doFieldBack() {
      displayScreen('dspMenu');
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
      var objFldStat = document.getElementById('FUP_FldStat');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDFLD"';
      strXML = strXML+' TABCDE="'+cstrFieldTabCde+'"';
      strXML = strXML+' FLDCDE="'+cstrFieldFldCde+'"';
      strXML = strXML+' FLDSTS="'+objFldStat.options[objFldStat.selectedIndex].value+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestFldUpdUpdate(\''+strXML+'\');',10);
   }
   function requestFldUpdUpdate(strXML) {
      doPostRequest('<%=strBase%>pts_fld_config_field_update.asp',function(strResponse) {checkFldUpdUpdate(strResponse);},false,streamXML(strXML));
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVVAL" TABCDE="'+cstrFieldTabCde+'" FLDCDE="'+cstrFieldFldCde+'"/>';
      doPostRequest('<%=strBase%>pts_fld_config_value_retrieve.asp',function(strResponse) {checkValueList(strResponse);},false,streamXML(strXML));
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
         document.getElementById('subValue').innerText = cstrFieldTabTxt;
         document.getElementById('minValue').innerText = cstrFieldFldTxt;
         var objValList = document.getElementById('VAL_ValList');
         var objRow;
         var objCell;
         for (var i=objValList.rows.length-1;i>=0;i--) {
            objValList.deleteRow(i);
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'VALUE') {
               objValList.options[objValList.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
               objValList.options[objValList.options.length-1].setAttribute('valcde',objElements[i].getAttribute('VALCDE'));
               objValList.options[objValList.options.length-1].setAttribute('valtxt',objElements[i].getAttribute('VALTXT'));
               objRow = objValList.insertRow(-1);
               objRow.setAttribute('valcde',objElements[i].getAttribute('VALCDE'));
               objRow.setAttribute('valtxt',objElements[i].getAttribute('VALTXT'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '<a class="clsSelect" onClick="doValueUpdate(\''+objRow.rowIndex+'\');">Update</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('VALTXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         displayScreen('dspValue');
         objValList.focus();
      }
   }
   function doValueAdd() {
      cstrFieldValCde = '';
      cstrFieldValTxt = '';
      document.getElementById('subValUpd').innerText = cstrFieldTabTxt;
      document.getElementById('minValUpd').innerText = cstrFieldFldTxt;
      document.getElementById('VUP_ValText').value = cstrFieldValTxt;
      displayScreen('dspValUpd');
      objValText.focus();
   }
   function doValueUpdate(intRow) {
      var objTable = document.getElementById('VAL_ValList');
      objRow = objTable.rows[intRow];
      cstrFieldValCde = objRow.getAttribute('valcde');
      cstrFieldValTxt = objRow.getAttribute('valtxt');
      document.getElementById('subValUpd').innerText = cstrFieldTabTxt;
      document.getElementById('minValUpd').innerText = cstrFieldFldTxt;
      document.getElementById('VUP_ValText').value = cstrFieldValTxt;
      displayScreen('dspValUpd');
      objValText.focus();
   }
   function doValueBack() {
      displayScreen('dspField');
   }

   ////////////////////////////
   // Value Update Functions //
   ////////////////////////////
   function doValUpdCancel() {
      displayScreen('dspValue');
      document.getElementById('VAL_ValList').focus();
   }
   function doValUpdAccept() {
      if (!processForm()) {return;}
      var objValText = document.getElementById('VAL_ValText');
      var strMessage = '';
      if (objValText.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Value text must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDVAL"';
      strXML = strXML+' TABCDE="'+cstrFieldTabCde+'"';
      strXML = strXML+' FLDCDE="'+cstrFieldFldCde+'"';
      strXML = strXML+' VALCDE="'+cstrFieldValCde+'"';
      strXML = strXML+' VALTXT="'+fixXML(objValText.value)+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestValUpdUpdate(\''+strXML+'\');',10);
   }
   function requestValUpdUpdate(strXML) {
      doPostRequest('<%=strBase%>pts_fld_config_value_update.asp',function(strResponse) {checkValUpdUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkValUpdUpdate(strResponse) {
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
         requestValueList();
      }
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_fld_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspMenu" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=3 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedMenu" class="clsFunction" align=center colspan=2 nowrap><nobr>System Table Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center valign=center colspan=1 nowrap><nobr><a class="clsSelect" onClick="doSortField('*HOU_CLA','Household Classification Data');">Sort Fields</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doFieldList('*HOU_CLA','Household Classification Data');">Update Fields</a></nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;Household Classification Data&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center valign=center colspan=1 nowrap><nobr><a class="clsSelect" onClick="doSortField('*HOU_SAM','Household Sample Data');">Sort Fields</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doFieldList('*HOU_SAM','Household Sample Data');">Update Fields</a></nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;Household Sample Data&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center valign=center colspan=1 nowrap><nobr><a class="clsSelect" onClick="doSortField('*PET_CLA','Pet Classification Data');">Sort Fields</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doFieldList('*PET_CLA','Pet Classification Data');">Update Fields</a></nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;Pet Classification Data&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center valign=center colspan=1 nowrap><nobr><a class="clsSelect" onClick="doSortField('*PET_SAM','Pet Sample Data');">Sort Fields</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doFieldList('*PET_SAM','Pet Sample Data');">Update Fields</a></nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;Pet Sample Data&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
   </table>
   <table id="dspSort" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSortAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSort" class="clsFunction" align=center colspan=2 nowrap><nobr>System Field Sort</nobr></td>
      </tr>
      <tr>
         <td id="subSort" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Table Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
      <tr>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="SRT_FldList" name="SRT_FldList" style="width:600px" multiple size=20></select>
         </nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsTable01" width=100% align=center cols=1 cellpadding="0" cellspacing="0">
               <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="upSortField();"></nobr></td></tr>
               <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="downSortField();"></nobr></td></tr>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSortCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSortAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspField" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedField" class="clsFunction" align=center colspan=2 nowrap><nobr>System Field Maintenance</nobr></td>
      </tr>
      <tr>
         <td id="subField" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Table Name</nobr></td>
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
         <td id="hedFldUpd" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>System Field Update</nobr></td>
      </tr>
      <tr>
         <td id="subFldUpd" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Table Name</nobr></td>
      <tr>
         <td id="minFldUpd" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Field Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Field Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="FUP_FldStat">
               <option value="0">Inactive
               <option value="1">Active
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
   <table id="dspValue" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedValue" class="clsFunction" align=center colspan=2 nowrap><nobr>System Value Maintenance</nobr></td>
      </tr>
      <tr>
         <td id="subValue" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Table Name</nobr></td>
      <tr>
         <td id="minValue" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Field Name</nobr></td>
      </tr>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="VAL_ValList" class="clsTableBody" cols=1 align=left cellpadding="2" cellspacing="1"></table>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doValueBack();">&nbsp;Back&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspValUpd" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doValUpdAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedValUpd" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>System Value Update</nobr></td>
      </tr>
      <tr>
         <td id="subValUpd" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Table Name</nobr></td>
      <tr>
         <td id="minValUpd" class="clsLabelBB" align=center colspan=2 nowrap><nobr>Field Name</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Value Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="VUP_ValText" size="100" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doValUpdCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doValUpdAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->