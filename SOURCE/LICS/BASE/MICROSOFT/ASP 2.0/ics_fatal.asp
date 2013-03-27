<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS - Interface Control System                     //
'// Script  : ics_fatal.asp                                      //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script executes the fatal error               //
'//////////////////////////////////////////////////////////////////
response.write("ics_fatal.asp")
response.end
   '//
   '// Declare the variables
   '//
   dim strReturn

   '//
   '// Retrieve the query data
   '//
   strReturn = Request.QueryString("error")

   '//
   '// Paint response
   '//
   call PaintResponse

'//////////////////////
'// Response routine //
'//////////////////////
sub PaintResponse()%>
<!--#include file="ics_fatal.inc"-->
<%end sub%>