<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Masterfoods Japan Planning Reporting               //
'// Script  : default.asp                                        //
'// Author  : Softstep Pty Ltd                                   //
'// Date    : September 2003                                     //
'// Text    : This script executes the default page for the      //
'//           web site                                           //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strBase
   dim strStatus
   dim strReturn
   dim objSecurity

   '//
   '// Get the base
   '//
   strBase = GetBase()

   '//
   '// Get the status
   '//
   strStatus = GetStatus()

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurity()

   '//
   '// Destroy references
   '//
   set objSecurity = nothing
%>
<!--#include file="mfjpln_std_code.inc"-->
<html>
<script language="javascript">
<!--
   function setStatus(strValue) {
      document.all.fntStatus.innerText = strValue;
   }
   function setLocation(strValue) {
      document.location.href = strValue;
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html;charset=Shift-JIS">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="mfjpln_style.css">
   <title>Masterfoods Japan Planning Reporting</title>
</head>
<body scroll="no" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" bgcolor="#40414c">
<table cols=1 width="100%" height="100%" border="4" bordercolor="#40414c" cellpadding="0" cellspacing="0" bgcolor="#40414c">
   <tr>
      <td colspan=1 width=100% valign="bottom">
         <table cols=1 width=100% height=100% border="2" bordercolor="#40414c" cellpadding="0" cellspacing="0" bgcolor="#40414c">
            <tr>
               <td colspan=1 width=100% valign=center nowrap>
                  <nobr><font class="clsTitle">Masterfoods Japan Planning Reports</font>&nbsp;&nbsp;<font class="clsStatus" id="fntStatus"><%=strStatus%></font>&nbsp;</nobr>
               </td>
            </tr>
         </table>
      </td>
   </tr>
   <tr>
      <td colspan=1 width=100% height=100%>
         <iframe id="fraMain" scrolling="no" frameborder="no" noresize bgcolor="#40414c" width="100%" height="100%" src=<%if strReturn = "*OK" then%>"mfjpln_frame.htm"<%else%>"mfjpln_fatal.asp?type=01&error=<%=strReturn%>"<%end if%>></iframe>
      </td>
   </tr>
</table>
</body>
</html>