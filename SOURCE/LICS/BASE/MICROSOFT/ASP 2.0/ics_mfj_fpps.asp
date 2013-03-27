<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_mfj_fpps.asp                                   //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the MFJ FPPS Sales Extract  //
'//           interface selection functionality                  //
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
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_mfj_fpps.asp"
   strHeading = "MFJ FPPS Sales Extract Interface"

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
   strReturn = GetSecurityCheck("CLIO_FPPS_EXTRACT")
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else

      '//
      '// Get the form data
      '//
      GetForm()
      strMode = objForm.Fields().Item("Mode")

      '//
      '// Process the form data
      '//
      select case strMode
         case "SELECT"
            call ProcessSelect
         case "UPDATE"
            call ProcessUpdate
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   '//
   '// Paint response
   '//
   if strMode = "FATAL" then
      call PaintFatal
   else
      call PaintResponse
   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objProcedure = nothing

'////////////////////////////
'// Process select routine //
'////////////////////////////
sub ProcessSelect()

   '//
   '// Clear the period
   '//
   exit sub

end sub

'////////////////////////////
'// Process update routine //
'////////////////////////////
sub ProcessUpdate()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Submit the MFJ FPPS Sales Extract interface
   '//
   strStatement = "lics_trigger_submitter.execute('MFJ FPPS Sales Extract Interface','dw_app.fpps_extract.run_sales_extract("
   strStatement = strStatement & "''" & objSecurity.FixString(objForm.Fields().Item("SLT_Period")) & "'')','FPPS_EXTRACT')"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strReturn = FormatError(strReturn)
      exit sub
   end if
   strMode = "CONFIRM"

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="ics_mfj_fpps.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->