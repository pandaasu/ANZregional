<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_que_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the question configuration  //
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
   strTarget = "pts_que_config.asp"
   strHeading = "Question Maintenance"

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
   strReturn = GetSecurityCheck("PTS_QUE_CONFIG")
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
      cobjScreens[1] = new clsScreen('dspDefine','hedDefine');
      cobjScreens[2] = new clsScreen('dspResponse','hedResponse');
      cobjScreens[0].hedtxt = 'Question Prompt';
      cobjScreens[1].hedtxt = 'Question Maintenance';
      cobjScreens[2].hedtxt = 'Question Response Maintenance';
      initSearch();
      displayScreen('dspPrompt');
      document.getElementById('PRO_QueCode').focus();
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
      if (document.getElementById('PRO_QueCode').value == '') {
         doPromptCreate();
      } else {
         doPromptUpdate();
      }
   }
   function doPromptUpdate() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_QueCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Question code must be entered for update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+document.getElementById('PRO_QueCode').value+'\');',10);
   }
   function doPromptCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
   }
   function doPromptCopy() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_QueCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Question code must be entered for copy';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+document.getElementById('PRO_QueCode').value+'\');',10);
   }
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*QUESTION','Question','pts_que_search.asp',function() {doPromptQueCancel();},function(strCode,strText) {doPromptQueSelect(strCode,strText);});
   }
   function doPromptQueCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_QueCode').focus();
   }
   function doPromptQueSelect(strCode,strText) {
      document.getElementById('PRO_QueCode').value = strCode;
      displayScreen('dspPrompt');
      document.getElementById('PRO_QueCode').focus();
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDQUE" QUECODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_que_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTQUE" QUECODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_que_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYQUE" QUECODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_que_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[1].hedtxt = 'Update Question ('+cstrDefineCode+')';
         } else {
            cobjScreens[1].hedtxt = 'Create Question (*NEW)';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_QueCode').value = '';
         document.getElementById('DEF_QueText').value = '';
         document.getElementById('DEF_RspSran').value = '';
         document.getElementById('DEF_RspEran').value = '';
         var strQueStat;
         var strQueType;
         var strRspType;
         var objQueStat = document.getElementById('DEF_QueStat');
         var objQueType = document.getElementById('DEF_QueType');
         var objRspType = document.getElementById('DEF_RspType');
         var objResValu = document.getElementById('DEF_ResValu');
         objQueStat.options.length = 0;
         objQueType.options.length = 0;
         objRspType.options.length = 0;
         objResValu.options.length = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'STA_LIST') {
               objQueStat.options[objQueStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'TYP_LIST') {
               objQueType.options[objQueType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'RSP_LIST') {
               objRspType.options[objRspType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'QUESTION') {
               document.getElementById('DEF_QueCode').innerText = objElements[i].getAttribute('QUECODE');
               document.getElementById('DEF_QueText').value = objElements[i].getAttribute('QUETEXT');
               document.getElementById('DEF_RspSran').value = objElements[i].getAttribute('RSPSRAN');
               document.getElementById('DEF_RspEran').value = objElements[i].getAttribute('RSPERAN');
               strQueStat = objElements[i].getAttribute('QUESTAT');
               strQueType = objElements[i].getAttribute('QUETYPE');
               strRspType = objElements[i].getAttribute('RSPTYPE');
            } else if (objElements[i].nodeName == 'QUE_RESPONSE') {
               objResValu.options[objResValu.options.length] = new Option('('+(objResValu.options.length+1)+') '+objElements[i].getAttribute('RESTEXT'),objElements[i].getAttribute('RESTEXT'));
            }
         }
         objQueStat.selectedIndex = -1;
         for (var i=0;i<objQueStat.length;i++) {
            if (objQueStat.options[i].value == strQueStat) {
               objQueStat.options[i].selected = true;
               break;
            }
         }
         objQueType.selectedIndex = -1;
         for (var i=0;i<objQueType.length;i++) {
            if (objQueType.options[i].value == strQueType) {
               objQueType.options[i].selected = true;
               break;
            }
         }
         objRspType.selectedIndex = -1;
         for (var i=0;i<objRspType.length;i++) {
            if (objRspType.options[i].value == strRspType) {
               objRspType.options[i].selected = true;
               break;
            }
         }
         if (strRspType == '1') {
            document.getElementById('dspDiscreet').style.display = 'block';
            document.getElementById('dspRange').style.display = 'none';
         } else {
            document.getElementById('dspDiscreet').style.display = 'none';
            document.getElementById('dspRange').style.display = 'block';
         }
         document.getElementById('DEF_QueText').focus();
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objQueStat = document.getElementById('DEF_QueStat');
      var objQueType = document.getElementById('DEF_QueType');
      var objRspType = document.getElementById('DEF_RspType');
      var objResValu = document.getElementById('DEF_ResValu');
      var objRow;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*DEFQUE"';
      strXML = strXML+' QUECODE="'+fixXML(document.getElementById('DEF_QueCode').value)+'"';
      strXML = strXML+' QUETEXT="'+fixXML(document.getElementById('DEF_QueText').value.toUpperCase())+'"';
      strXML = strXML+' QUESTAT="'+fixXML(objQueStat.options[objQueStat.selectedIndex].value)+'"';
      strXML = strXML+' QUETYPE="'+fixXML(objQueType.options[objQueType.selectedIndex].value)+'"';;
      strXML = strXML+' RSPTYPE="'+fixXML(objRspType.options[objRspType.selectedIndex].value)+'"';
      strXML = strXML+' RSPSRAN="'+fixXML(document.getElementById('DEF_RspSran').value)+'"';
      strXML = strXML+' RSPERAN="'+fixXML(document.getElementById('DEF_RspEran').value)+'"';
      strXML = strXML+'>';
      for (var i=0;i<objResValu.length;i++) {
         strXML = strXML+'<QUE_RESPONSE RESCODE="'+(i+1)+'" RESTEXT="'+fixXML(objResValu.options[i].value)+'"/>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>pts_que_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         document.getElementById('PRO_QueCode').value = '';
         document.getElementById('PRO_QueCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_QueCode').value = '';
      document.getElementById('PRO_QueCode').focus();
   }
   function doResponseTypeSelect(objSelect) {
      var strValue = objSelect.options[objSelect.selectedIndex].value;
      if (strValue == '1') {
         document.getElementById('dspDiscreet').style.display = 'block';
         document.getElementById('dspRange').style.display = 'none';
      } else {
         document.getElementById('dspDiscreet').style.display = 'none';
         document.getElementById('dspRange').style.display = 'block';
      }
   }
   function doResponseAdd() {
      cstrResponseMode = '*ADD';
      var objResText = document.getElementById('RES_ResText');
      var strValue = '';
      objResText.value = strValue;
      displayScreen('dspResponse');
      objResText.focus();
   }
   function doResponseUpdate() {
      if (document.getElementById('DEF_ResValu').selectedIndex == -1) {
         alert('Value must be selected for update');
         return;
      }
      cstrResponseMode = '*UPD';
      var objResValu = document.getElementById('DEF_ResValu');
      var objResText = document.getElementById('RES_ResText');
      cintResponseIndx = objResValu.selectedIndex;
      var strValue = objResValu.options[cintResponseIndx].value;
      objResText.value = strValue;
      displayScreen('dspResponse');
      objResText.focus();
   }
   function doResponseDelete() {
      if (document.getElementById('DEF_ResValu').selectedIndex == -1) {
         alert('Value must be selected for delete');
         return;
      }
      var objResValu = document.getElementById('DEF_ResValu');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objResValu.options.length;i++) {
         if (objResValu.options[i].selected == false) {
            objWork[intIndex] = objResValu[i];
            intIndex++;
         }
      }
      objResValu.options.length = 0;
      objResValu.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objResValu.options[i] = objWork[i];
         objResValu.options[i].text = '('+(i+1)+') '+objResValu.options[i].value;
      }
   }
   function upResponseValues() {
      var intIndex;
      var intSelect;
      var objResValu = document.getElementById('DEF_ResValu');
      intSelect = 0;
      for (var i=0;i<objResValu.options.length;i++) {
         if (objResValu.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one value can be selected to move up');
         return;
      }
      if (intSelect == 1 && intIndex > 0) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objResValu.options[intIndex-1].value;
         aryA[1] = objResValu.options[intIndex-1].text;
         aryB[0] = objResValu.options[intIndex].value;
         aryB[1] = objResValu.options[intIndex].text;
         objResValu.options[intIndex-1].value = aryB[0];
         objResValu.options[intIndex-1].text = aryB[1];
         objResValu.options[intIndex-1].selected = true;
         objResValu.options[intIndex].value = aryA[0];
         objResValu.options[intIndex].text = aryA[1];
         objResValu.options[intIndex].selected = false;
         for (var i=0;i<objResValu.length;i++) {
            objResValu.options[i].text = '('+(i+1)+') '+objResValu.options[i].value;
         }
      }
   }
   function downResponseValues() {
      var intIndex;
      var intSelect;
      var objResValu = document.getElementById('DEF_ResValu');
      intSelect = 0;
      for (var i=0;i<objResValu.options.length;i++) {
         if (objResValu.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one item can be selected to move down');
         return;
      }
      if (intSelect == 1 && intIndex < objResValu.options.length-1) {
         var aryA = new Array();
         var aryB = new Array();
         aryA[0] = objResValu.options[intIndex+1].value;
         aryA[1] = objResValu.options[intIndex+1].text;
         aryB[0] = objResValu.options[intIndex].value;
         aryB[1] = objResValu.options[intIndex].text;
         objResValu.options[intIndex+1].value = aryB[0];
         objResValu.options[intIndex+1].text = aryB[1];
         objResValu.options[intIndex+1].selected = true;
         objResValu.options[intIndex].value = aryA[0];
         objResValu.options[intIndex].text = aryA[1];
         objResValu.options[intIndex].selected = false;
         for (var i=0;i<objResValu.length;i++) {
            objResValu.options[i].text = '('+(i+1)+') '+objResValu.options[i].value;
         }
      }
   }

   ////////////////////////
   // Response Functions //
   ////////////////////////
   var cstrResponseMode;
   var cintResponseIndx;
   function doResponseCancel() {
      displayScreen('dspDefine');
      document.getElementById('DEF_ResValu').focus();
   }
   function doResponseAccept() {
      if (!processForm()) {return;}
      var objResText = document.getElementById('RES_ResText');
      var objResValu = document.getElementById('DEF_ResValu');
      var strMessage = '';
      if (objResText.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Response text must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cstrResponseMode == '*ADD') {
         objResValu.options[objResValu.options.length] = new Option('('+(objResValu.options.length+1)+') '+objResText.value.toUpperCase(),objResText.value.toUpperCase());
      } else if (cstrResponseMode == '*UPD') {
         objResValu.options[cintResponseIndx].value = objResText.value.toUpperCase();
         objResValu.options[cintResponseIndx].text = '('+(cintResponseIndx+1)+') '+objResText.value.toUpperCase();
      }
      displayScreen('dspDefine');
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<!--#include file="pts_search_code.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_que_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPromptEnter();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Question Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Question Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_QueCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=7 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCreate();">&nbsp;Create&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCopy();">&nbsp;Copy&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptSearch();">&nbsp;Search&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Question Maintenance</nobr></td>
         <input type="hidden" name="DEF_QueCode" value="">
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Question Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_QueText" size="120" maxlength="1000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Question Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_QueStat"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Question Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_QueType"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Response Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=2 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=left valign=center colspan=1 nowrap><nobr><select class="clsInputBN" id="DEF_RspType" onChange="doResponseTypeSelect(this);"></select></nobr></td>
                  <td align=left valign=center colspan=1 nowrap><nobr>
                     <table id="dspDiscreet" class="clsGrid02" style="display:none;visibility:visible" align=left valign=top cols=1 cellpadding="0" cellspacing="0">
                        <tr>
                           <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
                              <table align=left border=0 cellpadding=0 cellspacing=2 cols=2>
                                 <tr>
                                    <td class="clsLabelBB" align=left colspan=2 nowrap><nobr>
                                       <table class="clsTable01" align=left cols=5 cellpadding="0" cellspacing="0">
                                          <tr>
                                             <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doResponseAdd();">&nbsp;Add&nbsp;</a></nobr></td>
                                             <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                                             <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doResponseUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                                             <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                                             <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doResponseDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
                                          </tr>
                                       </table>
                                    </nobr></td>
                                 </tr>
                                 <tr>
                                    <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
                                       <select class="clsInputBN" id="DEF_ResValu" name="DEF_ResValu" style="width:400px" multiple size=10></select>
                                    </nobr></td>
                                    <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>
                                       <table class="clsTable01" width=100% align=center cols=1 cellpadding="0" cellspacing="0">
                                          <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_uoff.gif" align=absmiddle onClick="upResponseValues();"></nobr></td></tr>
                                          <tr><td align=center colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_doff.gif" align=absmiddle onClick="downResponseValues();"></nobr></td></tr>
                                       </table>
                                    </nobr></td>
                                 </tr>
                              </table>
                           </nobr></td>
                        </tr>
                     </table>
                     <table id="dspRange" class="clsGrid02" style="display:none;visibility:visible" align=left valign=top cols=4 cellpadding="0" cellspacing="0">
                        <tr>
                           <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;Range Start:&nbsp;</nobr></td>
                           <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
                              <input class="clsInputNN" type="text" name="DEF_RspSran" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
                           </nobr></td>
                           <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;Range End:&nbsp;</nobr></td>
                           <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
                              <input class="clsInputNN" type="text" name="DEF_RspEran" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspResponse" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doResponseAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedResponse" class="clsFunction" align=center colspan=2 nowrap><nobr>Response Value Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Response Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="RES_ResText" size="100" maxlength="120" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doResponseCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doResponseAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
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