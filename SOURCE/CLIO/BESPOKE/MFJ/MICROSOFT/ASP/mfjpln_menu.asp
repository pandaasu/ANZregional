<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Masterfoods Japan Planning Reporting               //
'// Script  : mfjpln_menu.asp                                    //
'// Author  : Softstep Pty Ltd                                   //
'// Date    : September 2003                                     //
'// Text    : This script paints the menu structure from the     //
'//           menu XML file                                      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strBase
   dim strReturn
   dim objMenu

   '//
   '// Get the base
   '//
   strBase = GetBase()

   '//
   '// Retrieve the menu information
   '//
   set objMenu = Server.CreateObject("XL_MENU.Object")
   strReturn = objMenu.Initialise(GetMenu())

   '//
   '// Paint response
   '//
   call PaintResponse
 
   '//
   '// Destroy references
   '//
   set objMenu = nothing

'//////////////////////
'// Response routine //
'//////////////////////
sub PaintResponse()

   dim i
   dim j

   if strReturn <> "*OK" then%>
<!--#include file="mfjpln_fatal02.inc"-->
   <%else%>
<!--#include file="mfjpln_menu.inc"-->
   <%end if

end sub
%>
<!--#include file="mfjpln_std_code.inc"-->