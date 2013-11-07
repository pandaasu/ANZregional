<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_job_configuration.asp                          //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the job configuration       //
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
   dim aryJobStatus(2)
   dim objForm
   dim objSecurity
   dim objSelection
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_job_configuration.asp"
   strHeading = "Job Configuration"
   aryJobStatus(0) = "Inactive"
   aryJobStatus(1) = "Active"

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
   strReturn = GetSecurityCheck("ICS_JOB_CONFIG")
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
         case "INSERT_LOAD"
            call ProcessInsertLoad
         case "INSERT_ACCEPT"
            call ProcessInsertAccept
         case "UPDATE_LOAD"
            call ProcessUpdateLoad
         case "UPDATE_ACCEPT"
            call ProcessUpdateAccept
         case "DELETE_LOAD"
            call ProcessDeleteLoad
         case "DELETE_ACCEPT"
            call ProcessDeleteAccept
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   select case strMode
      case "FATAL"
         call PaintFatal
      case "SELECT"
         call PaintSelect
      case "INSERT"
         call PaintInsert
      case "UPDATE"
         call PaintUpdate
      case "DELETE"
         call PaintDelete
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objFunction = nothing

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
   '// Retrieve the job list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.job_job,"
   strQuery = strQuery & " t01.job_description,"
   strQuery = strQuery & " t01.job_type,"
   strQuery = strQuery & " nvl(t01.job_procedure,t01.job_type),"
   strQuery = strQuery & " t01.job_status"
   strQuery = strQuery & " from lics_job t01"
   strQuery = strQuery & " order by t01.job_job asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process insert load routine //
'/////////////////////////////////
sub ProcessInsertLoad()

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_JobJob", "")
   call objForm.AddField("DTA_JobDescription", "")
   call objForm.AddField("DTA_JobResGroup", "")
   call objForm.AddField("DTA_JobExeHistory", "0")
   call objForm.AddField("DTA_JobOprAlert", "")
   call objForm.AddField("DTA_JobEmaGroup", "")
   call objForm.AddField("DTA_JobType", "*PROCEDURE")
   call objForm.AddField("DTA_JobIntGroup", "")
   call objForm.AddField("DTA_JobProcedure", "")
   call objForm.AddField("DTA_JobNext", "sysdate")
   call objForm.AddField("DTA_JobInterval", "")
   call objForm.AddField("DTA_JobStatus", "1")

   '//
   '// Set the mode
   '//
   strMode = "INSERT"

end sub

'///////////////////////////////////
'// Process insert accept routine //
'///////////////////////////////////
sub ProcessInsertAccept()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Insert the job
   '//
   strStatement = "lics_job_configuration.insert_job("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobJob")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobDescription")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobResGroup")) & "',"
   strStatement = strStatement & objForm.Fields().Item("DTA_JobExeHistory") & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobOprAlert")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobEmaGroup")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobType")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobIntGroup")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobProcedure")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobNext")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobInterval")) & "',"
   strStatement = strStatement & "'" & objForm.Fields().Item("DTA_JobStatus") & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "INSERT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'/////////////////////////////////
'// Process update load routine //
'/////////////////////////////////
sub ProcessUpdateLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the job list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.job_job,"
   strQuery = strQuery & " t01.job_description,"
   strQuery = strQuery & " t01.job_res_group,"
   strQuery = strQuery & " t01.job_exe_history,"
   strQuery = strQuery & " t01.job_opr_alert,"
   strQuery = strQuery & " t01.job_ema_group,"
   strQuery = strQuery & " t01.job_type,"
   strQuery = strQuery & " t01.job_int_group,"
   strQuery = strQuery & " t01.job_procedure,"
   strQuery = strQuery & " t01.job_next,"
   strQuery = strQuery & " t01.job_interval,"
   strQuery = strQuery & " t01.job_status"
   strQuery = strQuery & " from lics_job t01"
   strQuery = strQuery & " where t01.job_job = '" & objForm.Fields().Item("DTA_JobJob") & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_JobJob", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobResGroup", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobExeHistory", objSelection.ListValue04("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobOprAlert", objSelection.ListValue05("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobEmaGroup", objSelection.ListValue06("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobType", objSelection.ListValue07("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobIntGroup", objSelection.ListValue08("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobProcedure", objSelection.ListValue09("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobNext", objSelection.ListValue10("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobInterval", objSelection.ListValue11("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobStatus", objSelection.ListValue12("LIST",objSelection.ListLower("LIST")))

   '//
   '// Set the mode
   '//
   strMode = "UPDATE"

end sub

'///////////////////////////////////
'// Process update accept routine //
'///////////////////////////////////
sub ProcessUpdateAccept()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Update the job
   '//
   strStatement = "lics_job_configuration.update_job("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobJob")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobDescription")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobResGroup")) & "',"
   strStatement = strStatement & objForm.Fields().Item("DTA_JobExeHistory") & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobOprAlert")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobEmaGroup")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobType")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobIntGroup")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobProcedure")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobNext")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobInterval")) & "',"
   strStatement = strStatement & "'" & objForm.Fields().Item("DTA_JobStatus") & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "UPDATE"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'/////////////////////////////////
'// Process delete load routine //
'/////////////////////////////////
sub ProcessDeleteLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the job list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.job_job,"
   strQuery = strQuery & " t01.job_description,"
   strQuery = strQuery & " t01.job_res_group,"
   strQuery = strQuery & " t01.job_exe_history,"
   strQuery = strQuery & " t01.job_opr_alert,"
   strQuery = strQuery & " t01.job_ema_group,"
   strQuery = strQuery & " t01.job_type,"
   strQuery = strQuery & " t01.job_int_group,"
   strQuery = strQuery & " t01.job_procedure,"
   strQuery = strQuery & " t01.job_next,"
   strQuery = strQuery & " t01.job_interval,"
   strQuery = strQuery & " t01.job_status"
   strQuery = strQuery & " from lics_job t01"
   strQuery = strQuery & " where t01.job_job = '" & objForm.Fields().Item("DTA_JobJob") & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_JobJob", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobResGroup", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobExeHistory", objSelection.ListValue04("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobOprAlert", objSelection.ListValue05("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobEmaGroup", objSelection.ListValue06("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobType", objSelection.ListValue07("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobIntGroup", objSelection.ListValue08("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobProcedure", objSelection.ListValue09("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobNext", objSelection.ListValue10("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobInterval", objSelection.ListValue11("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_JobStatus", objSelection.ListValue12("LIST",objSelection.ListLower("LIST")))

   '//
   '// Set the mode
   '//
   strMode = "DELETE"

end sub

'/////////////////////////////////
'// Process delete accept routine //
'/////////////////////////////////
sub ProcessDeleteAccept()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Delete the job
   '//
   strStatement = "lics_job_configuration.delete_job("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_JobJob")) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "DELETE"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint prompt routine //
'//////////////////////////
sub PaintSelect()%>
<!--#include file="ics_job_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_job_configuration_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_job_configuration_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_job_configuration_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->