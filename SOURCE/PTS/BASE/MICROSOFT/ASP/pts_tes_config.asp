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
      cobjScreens[2].hedtxt = 'Test Response';
      initSearch();
      initSelect('dspDefine','Selection Template');
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
   function doPromptTest() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_TesCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Test code must be entered for test';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      cobjScreens[2].hedtxt = 'Test Selection Template ('+document.getElementById('PRO_TesCode').value+')';
      displayScreen('dspTest');
      document.getElementById('TES_TesCode').value = document.getElementById('PRO_TesCode').value;
      document.getElementById('TES_MemCount').value = '0';
      document.getElementById('TES_ResCount').value = '0';
      document.getElementById('TES_MemCount').focus();
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
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDTES" TesCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTTES" TesCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_tes_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYTES" TesCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_Tes_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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


    tde_tes_text                    varchar2(120 char)            not null,
    tde_tes_status                  number                        not null,
    tde_upd_user                    varchar2(30 char)             not null,
    tde_upd_date                    date                          not null,
    tde_uni_code                    number                        null,
    tde_Tes_code                    number                        null,
    tde_glo_status                  number                        null,
    tde_tes_type                    number                        null,
    tde_tes_target                  number                        null,
    tde_tes_requestor               varchar2(30 char)             null,
    tde_tes_aim                     varchar2(2000 char)           null,
    tde_tes_reason                  varchar2(2000 char)           null,
    tde_tes_prediction              varchar2(2000 char)           null,
    tde_tes_comment                 varchar2(2000 char)           null,
    tde_day_count                   number                        null,
    tde_req_mem_count               number                        null,
    tde_req_res_count               number                        null,
    tde_hou_pet_multiple            varchar2(1 char)              null,
    tde_tes_error                   varchar2(2000 char)           null



         displayScreen('dspDefine');
         document.getElementById('DEF_TesCode').value = '';
         document.getElementById('DEF_TesText').value = '';
         var strTesStat;
         var strTesTarg;
         var strTesEnty;
         var objTesStat = document.getElementById('DEF_TesStat');
         var objTesTarg = document.getElementById('DEF_TesTarg');
         objTesStat.options.length = 0;
         objTesTarg.options.length = 0;
         document.getElementById('DEF_TesText').focus();
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'STA_LIST') {
               objTesStat.options[objTesStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'TAR_LIST') {
               objTesTarg.options[objTesTarg.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'TEST') {
               document.getElementById('DEF_TesCode').value = objElements[i].getAttribute('TesCODE');
               document.getElementById('DEF_TesText').value = objElements[i].getAttribute('TesTEXT');
               strTesStat = objElements[i].getAttribute('TesSTAT');
               strTesTarg = objElements[i].getAttribute('TesTARG');
            }
         }
         objTesStat.selectedIndex = -1;
         for (var i=0;i<objTesStat.length;i++) {
            if (objTesStat.options[i].value == strTesStat) {
               objTesStat.options[i].selected = true;
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
      strXML = strXML+' TesCODE="'+fixXML(document.getElementById('DEF_TesCode').value)+'"';
      strXML = strXML+' TesTEXT="'+fixXML(document.getElementById('DEF_TesText').value)+'"';
      strXML = strXML+' TesSTAT="'+fixXML(objTesStat.options[objTesStat.selectedIndex].value)+'"';
      strXML = strXML+' TesTARG="'+fixXML(objTesTarg.options[objTesTarg.selectedIndex].value)+'"';
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
   ////////////////////
   // Test Functions //
   ////////////////////
   function doTestAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('TES_MemCount').value < 1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Member count must be entered';
      }
      if (document.getElementById('TES_ResCount').value < 1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Reserve count must be entered';
      }

      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var objPetMult = document.getElementById('TES_PetMult');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*TESTes"';
      strXML = strXML+' TesCODE="'+fixXML(document.getElementById('TES_TesCode').value)+'"';
      strXML = strXML+' MEMCNT="'+fixXML(document.getElementById('TES_MemCount').value)+'"';
      strXML = strXML+' RESCNT="'+fixXML(document.getElementById('TES_RESCount').value)+'"';
      strXML = strXML+' PETMLT="'+fixXML(document.getElementById('TES_PetMult').options[document.getElementById('TES_PetMult').selectedIndex].value)+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestTestAccept(\''+strXML+'\');',10);
   }
   function requestTestAccept(strXML) {
      doPostRequest('<%=strBase%>pts_Tes_config_test.asp',function(strResponse) {checkTestAccept(strResponse);},false,streamXML(strXML));
   }
   function checkTestAccept(strResponse) {
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
         doReportOutput(eval('document.body'),'Selection Template Test Panel','*SPREADSHEET','select * from table(pts_app.pts_Tes_function.report_panel(' + document.getElementById('TES_TesCode').value + '))');
      }
   }
   function doTestCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_TesCode').value = '';
      document.getElementById('PRO_TesCode').focus();
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptTest();">&nbsp;Test&nbsp;</a></nobr></td>
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
   <table id="dspTest" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedTest" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Test Selection Test</nobr></td>
         <input type="hidden" name="TES_TesCode" value="">
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Member Count:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="TES_MemCount" size="5" maxlength="5" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Reserve Count:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="TES_ResCount" size="5" maxlength="5" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Allow Multiple Household Pets:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="TES_PetMult">
               <option value="0" selected>No
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTestCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doTestAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
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