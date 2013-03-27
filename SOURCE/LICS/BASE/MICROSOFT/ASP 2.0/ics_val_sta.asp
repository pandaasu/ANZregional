<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_sta.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : July 2005                                          //
'// Text    : This script implements the statistics submit       //
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
   dim strError
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection
   dim objProcedure

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_val_sta.asp"
   strHeading = "Validation Statistics - Batch"

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
   strReturn = GetSecurityCheck("VAL_STATISTICS")
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
         case "SUBMIT"
            call ProcessSubmit
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
      end select

   end if

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
   set objSelection = nothing
   set objProcedure = nothing

'////////////////////////////
'// Process select routine //
'////////////////////////////
sub ProcessSelect()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the groups
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vag_group,"
   strQuery = strQuery & " t01.vag_description"
   strQuery = strQuery & " from sap_val_grp t01"
   strQuery = strQuery & " order by vag_description asc"
   strReturn = objSelection.Execute("GROUP", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'////////////////////////////
'// Process submit routine //
'////////////////////////////
sub ProcessSubmit()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Submit the validation execution
   '//
   strStatement = "lics_trigger_submitter.execute('LADS Statistics','lads_validation.statistics(''" & objSecurity.FixString(objForm.Fields().Item("DTA_GROUP")) & "'')','LADS_VALIDATION')"
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
<!--#include file="ics_val_sta.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->