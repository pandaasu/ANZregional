<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_site.asp                                       //
'// Author  : Steve Gregan                                       //
'// Date    : October 2007                                       //
'// Text    : This script implements the site functionality      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Set the server script timeout to (5 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 300

   '//
   '// Set the session variables
   '//
   session("ics_site_code") = Request.QueryString("Site")
   session("ics_site_class") = Request.QueryString("Class")
   session("ics_site_install") = Request.QueryString("Install")

   '//
   '// Return 
   '//
   Response.Buffer = true
   Response.ContentType = "text/xml"
   Response.AddHeader "Cache-Control", "no-cache"
   Response.Write("*OK")
 %>