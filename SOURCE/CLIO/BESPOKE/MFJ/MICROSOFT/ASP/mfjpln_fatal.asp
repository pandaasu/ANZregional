<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Masterfoods Japan Planning Reporting               //
'// Script  : mfjpln_fatal.asp                                   //
'// Author  : Softstep Pty Ltd                                   //
'// Date    : September 2003                                     //
'// Text    : This script executes the fatal error               //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strType
   dim strReturn

   '//
   '// Retrieve the query data
   '//
   strType = Request.QueryString("type")
   strReturn = Request.QueryString("error")

   '//
   '// Paint response
   '//
   if strType = "01" then
      call PaintResponse01
   else
      call PaintResponse02
   end if

'/////////////////////////
'// Response 01 routine //
'/////////////////////////
sub PaintResponse01()%>
<!--#include file="mfjpln_fatal01.inc"-->
<%end sub

'/////////////////////////
'// Response 02 routine //
'/////////////////////////
sub PaintResponse02()%>
<!--#include file="mfjpln_fatal02.inc"-->
<%end sub%>