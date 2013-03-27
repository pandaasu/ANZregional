<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_job_detail.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the job detail              //
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
   dim aryJobStatus(5)
   dim aryJobClass(5)
   dim objForm
   dim objSecurity
   dim objSelection

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_job_detail.asp"
   strHeading = "Job Detail"
   aryJobStatus(1) = "Working"
   aryJobStatus(2) = "Idle"
   aryJobStatus(3) = "Suspended"
   aryJobStatus(4) = "Completed"
   aryJobStatus(5) = "Aborted"
   aryJobClass(1) = "clsWorking"
   aryJobClass(2) = "clsNormal"
   aryJobClass(3) = "clsNormal"
   aryJobClass(4) = "clsNormal"
   aryJobClass(5) = "clsError"

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

      '//
      '// Process the form
      '//
      call ProcessForm

   end if

   '//
   '// Paint response
   '//
   if strReturn <> "*OK" then
      call PaintFatal
   else
      call PaintForm
   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing

'//////////////////////////
'// Process form routine //
'//////////////////////////
sub ProcessForm()

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Execute the job execution detail
   '//
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.jot_execution,'FM999999999999990'),"
   strQuery = strQuery & " t01.jot_job || ' : ' || t02.job_description,"
   strQuery = strQuery & " t01.jot_type,"
   strQuery = strQuery & " decode(t01.jot_int_group,null,'Procedure : ' || t01.jot_procedure,'Interface Group : ' || t01.jot_int_group),"
   strQuery = strQuery & " t01.jot_user,"
   strQuery = strQuery & " to_char(t01.jot_str_time, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " to_char(t01.jot_end_time, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " t01.jot_status,"
   strQuery = strQuery & " t01.jot_message"
   strQuery = strQuery & " from lics_job_trace t01, lics_job t02"
   strQuery = strQuery & " where t01.jot_job = t02.job_job(+)"
   strQuery = strQuery & " and t01.jot_execution = " & objForm.Fields().Item("QRY_Execution")
   strReturn = objSelection.Execute("DETAIL", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint form routine //
'//////////////////////////
sub PaintForm()%>
<!--#include file="ics_job_detail.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->