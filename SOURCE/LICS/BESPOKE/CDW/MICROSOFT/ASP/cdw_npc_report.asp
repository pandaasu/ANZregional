<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : CDW (Corporate Data Warehouse)                     //
'// Script  : cdw_npc_report.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : August 2010                                        //
'// Text    : This script implements the NPC reportint           //
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
   strTarget = "cdw_npc_report.asp"
   strHeading = "NPC Report"

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
   strReturn = GetSecurityCheck("CDW_NPC_REPORT")
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
      cobjScreens[1] = new clsScreen('dspSlct','hedSlct');
      cobjScreens[0].hedtxt = '**LOADING**';
      cobjScreens[1].hedtxt = 'NPC Report Selection';
      cobjScreens[0].bodsrl = 'no';
      cobjScreens[1].bodsrl = 'auto';
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

   //////////////////////
   // Select Functions //
   //////////////////////
   function doSlctLoad() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestSlctLoad();',10);
   }
   function requestSlcttLoad() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><ODS_REQUEST ACTION="*SLTRPT"/>';
      doPostRequest('<%=strBase%>cdw_npc_report_select.asp',function(strResponse) {checkSlctLoad(strResponse);},false,streamXML(strXML));
   }
   function checkSlctLoad(strResponse) {
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
         displayScreen('dspSlct');
         var objComCode = document.getElementById('SLT_ComCode');
         var objBusSgmt = document.getElementById('SLT_BusSgmt');
         var objStrMnth = document.getElementById('SLT_StrMnth');
         var objEndMnth = document.getElementById('SLT_EndMnth');
         objComCode.options.length = 0;
         objBusSgmt.options.length = 0;
         objStrMnth.options.length = 0;
         objEndMnth.options.length = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'COMCDE') {
               objComCode.options[objComCode.options.length] = new Option(objElements[i].getAttribute('COMNAM'),objElements[i].getAttribute('COMCDE'));
            } else if (objElements[i].nodeName == 'SEGCDE') {
               objBusSgmt.options[objBusSgmt.options.length] = new Option(objElements[i].getAttribute('SEGNAM'),objElements[i].getAttribute('SEGCDE'));
            } else if (objElements[i].nodeName == 'MTHCDE') {
               objStrMnth.options[objStrMnth.options.length] = new Option(objElements[i].getAttribute('MTHNAM'),objElements[i].getAttribute('MTHCDE'));
               objEndMnth.options[objEndMnth.options.length] = new Option(objElements[i].getAttribute('MTHNAM'),objElements[i].getAttribute('MTHCDE'));
            }
         }
         objComCode.selectedIndex = -1;
         objBusSgmt.selectedIndex = -1;
         objStrMnth.selectedIndex = -1;
         objEndMnth.selectedIndex = -1;
         if (objComCode.options.length > 0) {
            objComCode.selectedIndex = 0;
         }
         if (objBusSgmt.options.length > 0) {
            objBusSgmt.selectedIndex = 0;
         }
         if (objStrMnth.options.length > 0) {
            objStrMnth.selectedIndex = 0;
         }
         if (objEndMnth.options.length > 0) {
            objEndMnth.selectedIndex = 0;
         }
         document.getElementById('SLT_ComCode').focus();
      }
   }
   function doSlctReport() {
      if (!processForm()) {return;}
      var objComCode = document.getElementById('SLT_ComCode');
      var objBusSgmt = document.getElementById('SLT_BusSgmt');
      var objStrMnth = document.getElementById('SLT_StrMnth');
      var objEndMnth = document.getElementById('SLT_EndMnth');
      var strMessage = '';
      if (objComCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Company must be selected';
      }
      if (objBusSgmt.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Business segment must be selected';
      }
      if (objStrMnth.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Start month must be selected';
      }
      if (objEndMnth.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'End month must be selected';
      }
      if (objStrMnth.selectedIndex != -1 && objEndMnth.selectedIndex != -1) {
         if (objStrMnth.options[objStrMnth.selectedIndex].value > objEndMnth.options[objEndMnth.selectedIndex].value) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Start month must not exceed the end month';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (confirm('Please confirm the NPC report\r\npress OK continue (the NPC report will be generated)\r\npress Cancel to cancel and return') == false) {
         return;
      }
      doReportOutput(eval('document.body'),'NPC Report','*SPREADSHEET','select * from table(ods_app.npc_report.report_data(\''+objComCode.options[objComCode.selectedIndex].value+'\',\''+objBusSgmt.options[objBusSgmt.selectedIndex].value+'\','+objStrMnth.options[objStrMnth.selectedIndex].value+','+objEndMnth.options[objEndMnth.selectedIndex].value+'))');
   }

// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<!--#include file="ics_std_report.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body id="dspBody" class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('cdw_npc_enquiry_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspSlct" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSlct" class="clsFunction" align=center colspan=2 nowrap><nobr>NPC Report Selection</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Company:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="SLT_ComCode"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Business Segment:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="SLT_BusSgmt"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Month Range (inclusive):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="SLT_StrMnth"></select>&nbsp;to&nbsp;<select class="clsInputBN" id="SLT_EndMnth"></select>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSlctReport();">&nbsp;Report&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->