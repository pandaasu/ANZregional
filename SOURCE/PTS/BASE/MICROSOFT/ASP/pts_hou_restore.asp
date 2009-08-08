<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_hou_restore.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the household restore       //
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
   strTarget = "pts_hou_restore.asp"
   strHeading = "Household Restore"

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
   strReturn = GetSecurityCheck("PTS_HOU_RESTORE")
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
      cobjScreens[0].hedtxt = 'Household Prompt';
      cobjScreens[1].hedtxt = 'Household Restore';
      initSearch();
      displayScreen('dspPrompt');
      document.getElementById('PRO_HouCode').focus();
   }

   ///////////////////////
   // Control Functions //
   ///////////////////////
   var cobjScreens = new Array();
   function clsScreen(strScrName,strHedName) {
      this.scrnam = strScrName;
      this.hednam= strHedName;
      this.hedtxt= '';
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
   function doPromptRestore() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_HouCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Household code must be entered for restore';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineRestore(\''+document.getElementById('PRO_HouCode').value+'\');',10);
   }
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*HOUSEHOLD','Household','pts_hou_search.asp',function() {doPromptHouCancel();},function(strCode,strText) {doPromptHouSelect(strCode,strText);});
   }
   function doPromptHouCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_HouCode').focus();
   }
   function doPromptHouSelect(strCode,strText) {
      document.getElementById('PRO_HouCode').value = strCode;
      displayScreen('dspPrompt');
      document.getElementById('PRO_HouCode').focus();
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineCode;
   function requestDefineRestore(strCode) {
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*RTVRES" HOUCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_hou_restore_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
         cobjScreens[1].hedtxt ='Restore Household ('+cstrDefineCode+')';
         displayScreen('dspDefine');
         document.getElementById('DEF_LocStrt').innerHTML = '';
         document.getElementById('DEF_LocTown').innerHTML = '';
         document.getElementById('DEF_LocPcde').innerHTML = '';
         document.getElementById('DEF_LocCnty').innerHTML = '';
         document.getElementById('DEF_ConFnam').innerHTML = '';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'HOUSEHOLD') {
               document.getElementById('DEF_LocStrt').innerHTML = objElements[i].getAttribute('LOCSTRT');
               document.getElementById('DEF_LocTown').innerHTML = objElements[i].getAttribute('LOCTOWN');
               document.getElementById('DEF_LocPcde').innerHTML = objElements[i].getAttribute('LOCPCDE');
               document.getElementById('DEF_LocCnty').innerHTML = objElements[i].getAttribute('LOCCNTY');
               document.getElementById('DEF_ConFnam').innerHTML = objElements[i].getAttribute('CONFNAM');
            }
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*UPDRES" HOUCODE="'+fixXML(cstrDefineCode)+'"/>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>pts_hou_restore_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         document.getElementById('PRO_HouCode').value = '';
         document.getElementById('PRO_HouCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_HouCode').value = '';
      document.getElementById('PRO_HouCode').focus();
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_hou_restore_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Household Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Household Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_HouCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptRestore();">&nbsp;Restore&nbsp;</a></nobr></td>
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
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Household Restore</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Location Street:&nbsp;</nobr></td>
         <td id="DEF_LocStrt" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Location Town:&nbsp;</nobr></td>
         <td id="DEF_LocTown" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Location Postcode:&nbsp;</nobr></td>
         <td id="DEF_LocPcde" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Location Country:&nbsp;</nobr></td>
         <td id="DEF_LocCnty" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Contact Full Name:&nbsp;</nobr></td>
         <td id="DEF_ConFnam" class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr></nobr></td>
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
<!--#include file="pts_search_html.inc"-->
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->