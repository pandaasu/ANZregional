<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing)                              //
'// Script  : pts_tab_lookup.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : April 2009                                         //
'// Text    : This script implements the system table lookup     //
'//           functionality                                      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strReturn
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
      GetForm()
      call ProcessLookup
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
'// Process lookup routine //
'////////////////////////////
sub ProcessLookup()

   dim intIndex
   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the table selection lookup
   '//
   strQuery = "select t01.value, t01.text"
   strQuery = strQuery & " from table(pr_app.pts_pet_function.list_classification(" & objForm.Fields("QRY_TabCode").Value & ")) t01"
   strReturn = objSelection.Execute("LIST", strQuery, 0)

   '//
   '// Return the response string
   '//
   if strReturn = "*OK" then
      Response.Buffer = true
      Response.ContentType = "text/xml"
      Response.AddHeader "Cache-Control", "no-cache"
      Response.Write(strReturn)
      for intIndex = 0 to objSelection.ListCount("LIST") - 1
         if intIndex > 0 then
            call Response.Write(chr(10))
         end if
         call Response.Write(objSelection.ListValue01("LIST",intIndex) & chr(9) & objSelection.ListValue02("LIST",intIndex))
      next
   end if

end sub%>
<!--#include file="ics_std_code.inc"-->