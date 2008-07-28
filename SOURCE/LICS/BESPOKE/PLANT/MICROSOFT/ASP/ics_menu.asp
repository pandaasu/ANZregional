<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS - Interface Control System                     //
'// Script  : ics_menu.asp                                       //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script paints the menu structure from the     //
'//           database security tables                           //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strBase
   dim strStatus
   dim strCharset
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
   '// Get the character set
   '//
   strCharset = GetCharSet()

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurity()
   if strReturn = "*OK" then

      '//
      '// Retrieve the menu information
      '//
      strReturn = objSecurity.GetMenu(GetUser())

   end if

   '//
   '// Paint response
   '//
   call PaintResponse
 
   '//
   '// Destroy references
   '//
   set objSecurity = nothing

'//////////////////////
'// Response routine //
'//////////////////////
sub PaintResponse()

   dim i
   dim j

   if strReturn <> "*OK" then%>
<!--#include file="ics_menu_fatal.inc"-->
   <%else%>
<!--#include file="ics_menu.inc"-->
   <%end if

end sub
%>
<!--#include file="ics_std_code.inc"-->