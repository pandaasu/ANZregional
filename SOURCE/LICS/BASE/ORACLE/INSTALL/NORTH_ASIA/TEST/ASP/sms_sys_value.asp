<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : SMS (SMS Reporting System)                         //
'// Script  : sms_sys_value.asp                                  //
'// Author  : Steve Gregan                                       //
'// Date    : July 2009                                          //
'// Text    : This script implements the system value            //
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
   strTarget = "sms_sys_value.asp"
   strHeading = "System Maintenance"

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
   strReturn = GetSecurityCheck("SMS_SYS_VALUE")
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
      cobjScreens[1] = new clsScreen('dspDefine','hedDefine');
      cobjScreens[0].hedtxt = '**LOADING**';
      cobjScreens[1].hedtxt = 'System Maintenance';
      displayScreen('dspLoad');
      doDefineRefresh();
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
   // Define Functions //
   //////////////////////
   function doDefineRefresh() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineRefresh();',10);
   }
   function requestDefineRefresh() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="*GETVAL"/>';
      doPostRequest('<%=strBase%>sms_sys_value_select.asp',function(strResponse) {checkDefineRefresh(strResponse);},false,streamXML(strXML));
   }
   function checkDefineRefresh(strResponse) {
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
         document.getElementById('DEF_StpTarg').value = '';
         document.getElementById('DEF_StpHost').value = '';
         document.getElementById('DEF_StpPort').value = '';
         document.getElementById('DEF_RptAlrt').value = '';
         document.getElementById('DEF_RptEgrp').value = '';
         document.getElementById('DEF_QryAlrt').value = '';
         document.getElementById('DEF_QryEgrp').value = '';
         document.getElementById('DEF_QryHDay').value = '';
         document.getElementById('DEF_AbrEgrp').value = '';
         document.getElementById('DEF_RcpEgrp').value = '';
         document.getElementById('DEF_SmsBtim').value = '';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'SYSTEM') {
               if (objElements[i].getAttribute('SYSCDE') == 'SMTP_TARGET') {
                  document.getElementById('DEF_StpTarg').value = objElements[i].getAttribute('SYSVAL');
               } else if (objElements[i].getAttribute('SYSCDE') == 'SMTP_HOST') {
                  document.getElementById('DEF_StpHost').value = objElements[i].getAttribute('SYSVAL');
               } else if (objElements[i].getAttribute('SYSCDE') == 'SMTP_PORT') {
                  document.getElementById('DEF_StpPort').value = objElements[i].getAttribute('SYSVAL');
               } else if (objElements[i].getAttribute('SYSCDE') == 'REPORT_GENERATION_ALERT') {
                  document.getElementById('DEF_RptAlrt').value = objElements[i].getAttribute('SYSVAL');
               } else if (objElements[i].getAttribute('SYSCDE') == 'REPORT_GENERATION_EMAIL_GROUP') {
                  document.getElementById('DEF_RptEgrp').value = objElements[i].getAttribute('SYSVAL');
               } else if (objElements[i].getAttribute('SYSCDE') == 'QUERY_CHECKER_ALERT') {
                  document.getElementById('DEF_QryAlrt').value = objElements[i].getAttribute('SYSVAL');
               } else if (objElements[i].getAttribute('SYSCDE') == 'QUERY_CHECKER_EMAIL_GROUP') {
                  document.getElementById('DEF_QryEgrp').value = objElements[i].getAttribute('SYSVAL');
               } else if (objElements[i].getAttribute('SYSCDE') == 'QUERY_HISTORY_DAYS') {
                  document.getElementById('DEF_QryHDay').value = objElements[i].getAttribute('SYSVAL');
               } else if (objElements[i].getAttribute('SYSCDE') == 'ABBREVIATION_EMAIL_GROUP') {
                  document.getElementById('DEF_AbrEgrp').value = objElements[i].getAttribute('SYSVAL');
               } else if (objElements[i].getAttribute('SYSCDE') == 'RECIPIENT_EMAIL_GROUP') {
                  document.getElementById('DEF_RcpEgrp').value = objElements[i].getAttribute('SYSVAL');
               } else if (objElements[i].getAttribute('SYSCDE') == 'SMS_BROADCAST_TIME') {
                  document.getElementById('DEF_SmsBtim').value = objElements[i].getAttribute('SYSVAL');
               }
            }
         }
         document.getElementById('DEF_StpTarg').focus();
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      if (confirm('Please confirm the system update\r\npress OK continue (The system values will be updated)\r\npress Cancel to cancel the request') == false) {
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<SMS_REQUEST ACTION="*UPDVAL">';
      strXML = strXML+'<SYSTEM SYSCDE="SMTP_TARGET" SYSVAL="'+fixXML(document.getElementById('DEF_StpTarg').value)+'"/>';
      strXML = strXML+'<SYSTEM SYSCDE="SMTP_HOST" SYSVAL="'+fixXML(document.getElementById('DEF_StpHost').value)+'"/>';
      strXML = strXML+'<SYSTEM SYSCDE="SMTP_PORT" SYSVAL="'+fixXML(document.getElementById('DEF_StpPort').value)+'"/>';
      strXML = strXML+'<SYSTEM SYSCDE="REPORT_GENERATION_ALERT" SYSVAL="'+fixXML(document.getElementById('DEF_RptAlrt').value)+'"/>';
      strXML = strXML+'<SYSTEM SYSCDE="REPORT_GENERATION_EMAIL_GROUP" SYSVAL="'+fixXML(document.getElementById('DEF_RptEgrp').value)+'"/>';
      strXML = strXML+'<SYSTEM SYSCDE="QUERY_CHECKER_ALERT" SYSVAL="'+fixXML(document.getElementById('DEF_QryAlrt').value)+'"/>';
      strXML = strXML+'<SYSTEM SYSCDE="QUERY_CHECKER_EMAIL_GROUP" SYSVAL="'+fixXML(document.getElementById('DEF_QryEgrp').value)+'"/>';
      strXML = strXML+'<SYSTEM SYSCDE="QUERY_HISTORY_DAYS" SYSVAL="'+fixXML(document.getElementById('DEF_QryHDay').value)+'"/>';
      strXML = strXML+'<SYSTEM SYSCDE="ABBREVIATION_EMAIL_GROUP" SYSVAL="'+fixXML(document.getElementById('DEF_AbrEgrp').value)+'"/>';
      strXML = strXML+'<SYSTEM SYSCDE="RECIPIENT_EMAIL_GROUP" SYSVAL="'+fixXML(document.getElementById('DEF_RcpEgrp').value)+'"/>';
      strXML = strXML+'<SYSTEM SYSCDE="SMS_BROADCAST_TIME" SYSVAL="'+fixXML(document.getElementById('DEF_SmsBtim').value)+'"/>';
      strXML = strXML+'</SMS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>sms_sys_value_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         doDefineRefresh();
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('sms_rcp_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>System Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SMTP Target:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_StpTarg" size="64" maxlength="64" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SMTP Host:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_StpHost" size="64" maxlength="64" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SMTP Port:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_StpPort" size="4" maxlength="4" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Report Generation Alert:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_RptAlrt" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Report Generation Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_RptEgrp" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query Daily Checker Alert:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_QryAlrt" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query Daily Checker Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_QryEgrp" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query Daily Checker History Days:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_QryHDay" size="3" maxlength="3" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Abbreviation Report Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_AbrEgrp" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Recipient Audit Report Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_RcpEgrp" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SMS Broadcast Time (HH24MISS):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_SmsBtim" size="6" maxlength="6" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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