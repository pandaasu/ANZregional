<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : mch_fcst_extract_load.asp                          //
'// Author  : Steve Gregan                                       //
'// Date    : March 2008                                         //
'// Text    : This script implements the China forecast          //
'//           extract load functionality                         //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strReturn
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection

   '//
   '// Set the server script timeout to (5 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 300

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurity()
   if strReturn = "*OK" then

      '//
      '// Get the form data
      '//
      GetForm()

      '//
      '// Process the form data
      '//
      call ProcessSelect
      strMode = objForm.Fields("Mode").Value

   end if

   '//
   '// Return the error message
   '//
   if strReturn <> "*OK" then
      Response.Buffer = true
      Response.ContentType = "text/xml"
      Response.AddHeader "Cache-Control", "no-cache"
      Response.Write(strReturn)
   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing

'////////////////////////////
'// Process select routine //
'////////////////////////////
sub ProcessSelect()

   dim strQuery
   dim intIndex

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the forecast load selection
   '//
   strQuery = "select * from table(dw_fcst_maintenance.retrieve_loads('" & objForm.Fields("QRY_ExtractType").Value & "'," & objForm.Fields("QRY_ExtractVersion").Value & "))"
   strReturn = objSelection.Execute("LOADS", strQuery, 0)

   '//
   '// Return the response string
   '//
   if strReturn = "*OK" then
      Response.Buffer = true
      Response.ContentType = "text/xml"
      Response.AddHeader "Cache-Control", "no-cache"
      Response.Write(strReturn)
      for intIndex = 0 to objSelection.ListLower("LOAD") to objSelection.ListUpper("LOAD")
         call Response.Write(objSelection.ListValue01("LOAD",intIndex) & chr(10))
      next
   end if

end sub%>
<!--#include file="ics_std_code.inc"-->