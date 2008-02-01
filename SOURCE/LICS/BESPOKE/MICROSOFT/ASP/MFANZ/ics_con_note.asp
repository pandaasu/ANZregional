<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_con_note.asp                                   //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the Consignment Note        //
'//           enquiry functionality                              //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim strBase
   dim strTarget
   dim strStatus
   dim strReturn
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objFunction

   '//
   '// Set the server script timeout to (5 minutes)
   '//
   server.scriptTimeout = 300

   '//
   '// Initialise the script
   '//
   strTarget = "ics_con_note.asp"
   strHeading = "Consignment Note Enquiry"

   '//
   '// Get the base string
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
   if strReturn = "*OK" then

      '//
      '// Get the form data
      '//
      GetForm()
      strMode = objForm.Fields("Mode").Value

      '//
      '// Process the request
      '//
      call ProcessRequest

   end if

   '//
   '// Paint response
   '//
   call PaintResponse
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objFunction = nothing

'/////////////////////////////
'// Process request routine //
'/////////////////////////////
sub ProcessRequest()

   dim strStatement

   '//
   '// Exit when not required
   '//
   strReturn = ""
   if objForm.Fields("SLT_Invoice").Value = "" and objForm.Fields("SLT_Delivery").Value = "" then
      exit sub
   end if

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Execute the Consignment Note enquiry
   '//
   strStatement = "ics_con_note.retrieve("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("SLT_Invoice").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("SLT_Delivery").Value) & "')"
   strReturn = objFunction.Execute(strStatement)

end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="ics_con_note.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->