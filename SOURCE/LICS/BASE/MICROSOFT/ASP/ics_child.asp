<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS - Interface Control System                     //
'// Script  : child.asp                                          //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script executes the child page for the        //
'//           ICS intranet site                                  //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strEnvironment
   dim strInstallation
   dim strBase
   dim strStatus
   dim strCharset
   dim strReturn
   dim strChild

   '//
   '// Get the child script
   '//
   strChild = Request.QueryString("Child")
   if strChild = "" then
      strChild = "ics_menu.asp"
   end if

   '//
   '// Get the environment
   '//
   strEnvironment = GetEnvironment()

   '//
   '// Get the installation
   '//
   strInstallation = GetInstallation()

   '//
   '// Get the base
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
%>
<!--#include file="ics_std_code.inc"-->
<html>
<script language="javascript">
<!--
   var strContentHeading = ' ';
   var strHelpHeading = ' ';
   function closeWindow() {
      window.close();
   }
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
   }
   function setStatus(strValue) {
      document.all.fntStatus.innerText = strValue;
   }
   function setHelp(strValue) {
      fraHelp.document.location.href = strValue;
   }
   function setContent(strValue) {
      fraContent.document.location.href = strValue;
   }
   function showContent() {
      var objLoading = eval('document.all("fntLoading")');
      var objContent = eval('document.all("fraContent")');
      var objHelp = eval('document.all("fraHelp")');
      objLoading.style.display = 'none';
      objLoading.style.visibility = 'hidden';
      objHelp.style.display = 'none';
      objHelp.style.visibility = 'hidden';
      objContent.style.display = 'block';
      objContent.style.visibility = 'visible';
      document.all.fntHeader.innerText = strContentHeading;
   }
   function showHelp() {
      var objLoading = eval('document.all("fntLoading")');
      var objContent = eval('document.all("fraContent")');
      var objHelp = eval('document.all("fraHelp")');
      objLoading.style.display = 'none';
      objLoading.style.visibility = 'hidden';
      objContent.style.display = 'none';
      objContent.style.visibility = 'hidden';
      objHelp.style.display = 'block';
      objHelp.style.visibility = 'visible';
      document.all.fntHeader.innerText = strHelpHeading;
   }
   function setHeading(strValue) {
      strContentHeading = strValue;
   }
   function setHelpHeading(strValue) {
      strHelpHeading = strValue;
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Interface Control System</title>
</head>
<body scroll="no" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" bgcolor="#40414c">
<table cols=1 width="100%" height="100%" border="4" bordercolor="#40414c" cellpadding="0" cellspacing="0" bgcolor="#40414c">
   <tr>
      <td colspan=1 width=100% valign="bottom">
         <table cols=2 width=100% height=100% border="2" bordercolor="#40414c" cellpadding="0" cellspacing="0" bgcolor="#40414c">
            <tr>
               <td colspan=1 width=100% valign=center nowrap>
                  <nobr><font class="clsTitle">Interface Control System </font><font class="cls<%if strEnvironment = "Devp" or strEnvironment = "Test" or strEnvironment = "Prod" or strEnvironment = "Temp" then%><%=strEnvironment%><%else%>Bade<%end if%>"><%=strInstallation%><%if strEnvironment = "Devp" then%> Development<%else if strEnvironment = "Test" then%> Test<%else if strEnvironment = "Prod" then%> Production<%else if strEnvironment = "Temp" then%> Template<%else%> Invalid Environment<%end if%><%end if%><%end if%><%end if%></font>&nbsp;<font class="clsStatus" id="fntStatus"><%=strStatus%></font>&nbsp;</nobr>
               </td>
               <td colspan=1 valign=center nowrap>
                  <nobr><a class="clsButton" href="javascript:showContent();">Content</a>&nbsp;&nbsp;<a class="clsButton" href="javascript:showHelp();">Help</a>&nbsp;&nbsp;<a class="clsButton" href="javascript:closeWindow();">Close</a>&nbsp;</nobr>
               </td>
            </tr>
         </table>
      </td>
   </tr>
   <tr>
      <td colspan=1 width=100% height=100%>
         <table class="clsSite" cols=1 width="100%" height="100%" cellspacing="0">
            <tr>
               <td nowrap colspan=1 class="clsHeader">
                  <table cols=1 width="100%" cellspacing="0">
                     <tr>
                        <td width=100% align=center valign=center nowrap><nobr>&nbsp;<font class="clsHeader" id="fntHeader">&nbsp;</font>&nbsp;</nobr></td>
                     </tr>
                  </table>
               </td>
            </tr>
            <tr><td nowrap colspan=1 height=100% width=100% class="clsInner" align=center valign=center>
               <font class="clsTitle" id="fntLoading" style="display:block;visibility:visible;">** LOADING **</font>
               <iframe id="fraContent" style="display:none;visibility:hidden" scrolling=no frameborder=no bgcolor=#dedfe2 width=100% height=100% src="<%=strBase%><%=strChild%>?<%=Request.QueryString%>"></iframe>
               <iframe id="fraHelp" style="display:none;visibility:hidden" scrolling=no frameborder=no bgcolor=#dedfe2 width=100% height=100% src="ics_help.htm"></iframe>
            </td></tr>
         </table>
      </td>
   </tr>
</table>
</body>
</html>