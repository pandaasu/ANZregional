<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_int_process.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the interface process       //
'//           functionality                                      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strReturn
   dim objSecurity

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 600
   set objSecurity = Server.CreateObject("ICS_SECURITY.Object")
   strReturn = objSecurity.PasswordEncrypt("licsgold")
   PaintResponse
 
   '//
   '// Destroy references
   '//
   set objSecurity = nothing

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintResponse()%>
<html>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
</head>
<body>
<%=strReturn%>
</body>
</html>
<%end sub%>