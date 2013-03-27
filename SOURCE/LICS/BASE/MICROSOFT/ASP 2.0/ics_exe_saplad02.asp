<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_exe_prompt.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : February 2005                                      //
'// Text    : This script implements the execution prompt        //
'//           functionality                                      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim strBase
   dim strTarget
   dim strStatus
   dim strCharset
   dim strReturn
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objProcedure

   '//
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "ics_exe_saplad02.asp"
   strHeading = "Execution Prompt"

   '//
   '// Get the base string
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
      '// Get the form data
      '//
      GetForm()
      strMode = objForm.Fields().Item("Mode")

      '//
      '// Process the form data
      '//
      select case strMode
         case "PROMPT"
            call ProcessPrompt
         case "EXECUTE"
            call ProcessExecute
         case else
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
      end select

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
   set objProcedure = nothing

'////////////////////////////
'// Process prompt routine //
'////////////////////////////
sub ProcessPrompt()

   strMode = "PROMPT"

end sub

'/////////////////////////////
'// Process execute routine //
'/////////////////////////////
sub ProcessExecute()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Set the procedure string
   '//
   strStatement = "lics_script_execution.execute_inbound_sap("
   strStatement = strStatement & "'SAPLAD02',"
   strStatement = strStatement & "'SAPLAD02',"
   strStatement = strStatement & "'" & objForm.Fields().Item("DTA_User") & "',"
   strStatement = strStatement & "'" & objForm.Fields().Item("DTA_password") & "',"
   strStatement = strStatement & "'*NONE'"
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strReturn = FormatError(strReturn)
      strMode = "PROMPT"
   end if


end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="ics_exe_saplad02.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->