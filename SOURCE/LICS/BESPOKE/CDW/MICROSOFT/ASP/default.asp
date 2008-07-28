<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS - Interface Control System                     //
'// Script  : default.asp                                        //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script executes the default page for the      //
'//           ICS intranet site                                  //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim strReturn
   dim strBase
   dim strStatus
   dim strCharset
   dim strSite
   dim intIndex
   dim objSecurity

   '//
   '// Get the site value
   '//
   strSite = Request.QueryString("Site")

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

   '//
   '// Retrieve the site information
   '//
   strReturn = GetSites()
   if strReturn <> "*OK" then
      call PaintFatal
   else
      intIndex = 0
      for i = 0 to objSecurity.SiteCount
         if objSecurity.SiteCode(i) = strSite then
            intIndex = i
         end if
      next
      session("ics_site_code") = objSecurity.SiteCode(intIndex)
      session("ics_site_class") = objSecurity.SiteEnvironment(intIndex)
      session("ics_site_install") = objSecurity.SiteInstallation(intIndex)
      call PaintSite
   end if
 
   '//
   '// Destroy references
   '//
   set objSecurity = nothing

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<html>
<head>
   <meta http-equiv="content-type" content="text/html">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" >                   
   <table align=center valign=center border=0 cellpadding=0 cellspacing=0 cols=1 width=100%>
      <tr>
         <td class="clsLabelBB" align=center>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center>&nbsp;<%=strReturn%>&nbsp;</td>
      </tr>
   </table>
</body>
</html>
<%end sub

'////////////////////////
'// Paint site routine //
'////////////////////////
sub PaintSite()%>
<html>
<script language="javascript">
<!--
   var strMenuHeading = ' ';
   var strContentHeading = ' ';
   var strHelpHeading = ' ';
   var objTimer;
   var strSite = '<%=objSecurity.SiteCode(intIndex)%>';
   var strClass = '<%=objSecurity.SiteEnvironment(intIndex)%>';
   var strInstall = '<%=objSecurity.SiteInstallation(intIndex)%>';
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
   var intSiteIndex = <%=intIndex%>
   var objSites = new Array();<%for i = 0 to objSecurity.SiteCount%>
   objSites[<%=i%>] = new clsSite('<%=objSecurity.SiteCode(i)%>','<%=replace(objSecurity.SiteText(i), "'", "\'", 1, -1, 1)%>','<%=objSecurity.SiteEnvironment(i)%>','<%=objSecurity.SiteInstallation(i)%>');<%next%>
   function clsSite(strCode,strText,strEnvironment,strInstallation) {
      this.code = strCode;
      this.text = strText;
      this.environment = strEnvironment;
      this.installation = strInstallation;
   }
   function selectSite(objSelect) {
      loadSite(objSelect.selectedIndex);
   }
   function loadSite(intSite) {
      if (intSite < 0 || intSite >= objSites.length) {
         return;
      }
      window.clearTimeout(objTimer);
      document.all.fntHeader.innerHTML = '&nbsp;';
      strSite = objSites[intSite].code;
      strClass = objSites[intSite].environment;
      strInstall = objSites[intSite].installation;
      document.all.fntInstall.className = 'cls' + strClass;
      document.all.fntInstall.innerText = strInstall;
      doGetRequest('<%=strBase%>ics_site.asp?Site='+strSite+'&Class='+strClass+'&Install='+strInstall,function(strResponse) {refreshMenu(strResponse);},false);
   }
   function waitSession() {
      objTimer = setTimeout('refreshSession()',600000);
   }
   function refreshSession() {
      doGetRequest('<%=strBase%>ics_site.asp?Site='+strSite+'&Class='+strClass+'&Install='+strInstall,function(strResponse) {waitSession(strResponse);},false);
   }
   function refreshMenu() {
      document.all.fntHeader.innerHTML = '&nbsp;';
      var objLoading = eval('document.all("fntLoading")');
      var objContent = eval('document.all("fraContent")');
      var objMenu = eval('document.all("fraMenu")');
      var objHelp = eval('document.all("fraHelp")');
      objLoading.style.display = 'block';
      objLoading.style.visibility = 'visible';
      objContent.style.display = 'none';
      objContent.style.visibility = 'hidden';
      objHelp.style.display = 'none';
      objHelp.style.visibility = 'hidden';
      objMenu.style.display = 'none';
      objMenu.style.visibility = 'hidden';
      fraMenu.document.location.href = "ics_menu.asp";
      waitSession();
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
   function showMenu() {
      var objLoading = eval('document.all("fntLoading")');
      var objContent = eval('document.all("fraContent")');
      var objMenu = eval('document.all("fraMenu")');
      var objHelp = eval('document.all("fraHelp")');
      objLoading.style.display = 'none';
      objLoading.style.visibility = 'hidden';
      objContent.style.display = 'none';
      objContent.style.visibility = 'hidden';
      objHelp.style.display = 'none';
      objHelp.style.visibility = 'hidden';
      objMenu.style.display = 'block';
      objMenu.style.visibility = 'visible';
      document.all.fntHeader.innerHTML = strMenuHeading;
   }
   function showContent() {
      var objLoading = eval('document.all("fntLoading")');
      var objContent = eval('document.all("fraContent")');
      var objMenu = eval('document.all("fraMenu")');
      var objHelp = eval('document.all("fraHelp")');
      objLoading.style.display = 'none';
      objLoading.style.visibility = 'hidden';
      objMenu.style.display = 'none';
      objMenu.style.visibility = 'hidden';
      objHelp.style.display = 'none';
      objHelp.style.visibility = 'hidden';
      objContent.style.display = 'block';
      objContent.style.visibility = 'visible';
      document.all.fntHeader.innerText = strContentHeading;
   }
   function showHelp() {
      var objLoading = eval('document.all("fntLoading")');
      var objContent = eval('document.all("fraContent")');
      var objMenu = eval('document.all("fraMenu")');
      var objHelp = eval('document.all("fraHelp")');
      objLoading.style.display = 'none';
      objLoading.style.visibility = 'hidden';
      objContent.style.display = 'none';
      objContent.style.visibility = 'hidden';
      objMenu.style.display = 'none';
      objMenu.style.visibility = 'hidden';
      objHelp.style.display = 'block';
      objHelp.style.visibility = 'visible';
      document.all.fntHeader.innerText = strHelpHeading;
   }
   function setMenuHeading(strValue) {
      strMenuHeading = strValue;
   }
   function setHeading(strValue) {
      strContentHeading = strValue;
   }
   function setHelpHeading(strValue) {
      strHelpHeading = strValue;
   }
   function doAction(strAction) {
      var objFrame = eval('fraMenu');
      objFrame.doAction(strAction);
      objFrame = null;
   }
// -->
</script>
<!--#include file="ics_std_request.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Interface Control System</title>
</head>
<body scroll="no" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" bgcolor="#40414c" onLoad="waitSession();">
<table cols=1 width="100%" height="100%" border="4" bordercolor="#40414c" cellpadding="0" cellspacing="0" bgcolor="#40414c">
   <tr>
      <td colspan=1 width=100% valign="bottom"><%if objSecurity.SiteCount = 0 then%>
         <table cols=2 width=100% height=100% border="2" bordercolor="#40414c" cellpadding="0" cellspacing="0" bgcolor="#40414c">
            <tr>
               <td colspan=1 width=100% valign=center nowrap>
                  <nobr><font class="clsTitle"><%=objSecurity.SiteText(intIndex)%>&nbsp;</font><font class="cls<%=objSecurity.SiteEnvironment(intIndex)%>" id="fntInstall"><%=objSecurity.SiteInstallation(intIndex)%></font>&nbsp;<font class="clsStatus" id="fntStatus"><%=strStatus%></font>&nbsp;</nobr>
               </td>
               <td colspan=1 valign=center nowrap>
                  <nobr>&nbsp;<a class="clsButton" href="javascript:showMenu();">Menu</a>&nbsp;&nbsp;<a class="clsButton" href="javascript:showContent();">Content</a>&nbsp;&nbsp;<a class="clsButton" href="javascript:showHelp();">Help</a>&nbsp;</nobr>
               </td>
            </tr>
         </table><%else%>
         <table cols=3 width=100% height=100% border="2" bordercolor="#40414c" cellpadding="0" cellspacing="0" bgcolor="#40414c">
            <tr>
               <td colspan=1 valign=center nowrap>
                  <select name="sltSite" class="clsPick" onChange="selectSite(this);"><%for i = 0 to objSecurity.SiteCount%>
                     <option value="<%=objSecurity.SiteCode(i)%>"<%if i = intIndex then%> selected<%end if%>><%=objSecurity.SiteText(i)%></option><%next%>
                  </select>&nbsp;
               </td>
               <td colspan=1 width=100% valign=center nowrap>
                  <nobr><font class="clsTitle">Interface Control System </font><font class="cls<%=objSecurity.SiteEnvironment(intIndex)%>" id="fntInstall"><%=objSecurity.SiteInstallation(intIndex)%></font>&nbsp;<font class="clsStatus" id="fntStatus"><%=strStatus%></font>&nbsp;</nobr>
               </td>
               <td colspan=1 valign=center nowrap>
                  <nobr>&nbsp;<a class="clsButton" href="javascript:showMenu();">Menu</a>&nbsp;&nbsp;<a class="clsButton" href="javascript:showContent();">Content</a>&nbsp;&nbsp;<a class="clsButton" href="javascript:showHelp();">Help</a>&nbsp;</nobr>
               </td>
            </tr>
         </table><%end if%>
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
               <iframe id="fraMenu" style="display:none;visibility:hidden" scrolling=no frameborder=no bgcolor=#dedfe2 width=100% height=100% src="ics_menu.asp"></iframe>
               <iframe id="fraContent" style="display:none;visibility:hidden" scrolling=no frameborder=no bgcolor=#dedfe2 width=100% height=100% src="ics_content.htm"></iframe>
               <iframe id="fraHelp" style="display:none;visibility:hidden" scrolling=no frameborder=no bgcolor=#dedfe2 width=100% height=100% src="ics_help.htm"></iframe>
            </td></tr>
         </table>
      </td>
   </tr>
</table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->