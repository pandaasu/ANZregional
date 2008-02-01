<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_job_control.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the job control             //
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
   dim bolStrList
   dim bolEndList
   dim aryExeStatus(4)
   dim aryExeClass(4)
   dim objForm
   dim objSecurity
   dim objSelection
   dim objProcedure

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_job_control.asp"
   strHeading = "Job Control"
   aryExeStatus(1) = "Working"
   aryExeStatus(2) = "Idle"
   aryExeStatus(3) = "Suspended"
   aryExeStatus(4) = "Stopped"
   aryExeClass(1) = "clsLabelFG"
   aryExeClass(2) = "clsLabelFN"
   aryExeClass(3) = "clsLabelFN"
   aryExeClass(4) = "clsLabelFN"

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
   strReturn = GetSecurityCheck("ICS_JOB_CONTROL")
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
   set objProcedure = nothing

'//////////////////////////
'// Process form routine //
'//////////////////////////
sub ProcessForm()

   dim strStatement
   dim strQuery
   dim lngSize

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the job task when required
   '//
   if objForm.Fields("Mode").Value = "STOP" then
      strStatement = "lics_job_control.stop_jobs"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         exit sub
      end if
   end if
   if objForm.Fields("Mode").Value = "START" then
      strStatement = "lics_job_control.start_jobs"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         exit sub
      end if
   end if
   if objForm.Fields("Mode").Value = "SUSPEND" then
      strStatement = "lics_job_control.suspend_processes('')"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         exit sub
      end if
   end if
   if objForm.Fields("Mode").Value = "RELEASE" then
      strStatement = "lics_job_control.release_processes('')"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         exit sub
      end if
   end if

   '//
   '// Execute the job control list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.job_job,"
   strQuery = strQuery & " t01.job_description,"
   strQuery = strQuery & " t01.job_type,"
   strQuery = strQuery & " '('||t01.job_int_group||') - '||nvl(t01.job_procedure,t01.job_type),"
   strQuery = strQuery & " nvl(t02.jot_status,'4')"
   strQuery = strQuery & " from lics_job t01,"
   strQuery = strQuery & " (select jot_job, min(jot_status) as jot_status from lics_job_trace"
   strQuery = strQuery & " where jot_type <> '*PROCEDURE'"
   strQuery = strQuery & " and (jot_status = '1' or jot_status = '2' or jot_status = '3')"
   strQuery = strQuery & " group by jot_job) t02"
   strQuery = strQuery & " where t01.job_job = t02.jot_job(+)"
   strQuery = strQuery & " and t01.job_type <> '*PROCEDURE'"
   strQuery = strQuery & " and t01.job_status = '1'"
   strQuery = strQuery & " order by t01.job_job asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the interface/triggered backlog
   '//
   lngSize = 0
   strQuery = "select * from"
   strQuery = strQuery & " (select"
   strQuery = strQuery & " t01.hea_interface as backlog_code,"
   strQuery = strQuery & " max(t02.int_description) as backlog_desc,"
   strQuery = strQuery & " max(t02.int_type) as backlog_type,"
   strQuery = strQuery & " max(t02.int_group) as backlog_group,"
   strQuery = strQuery & " count(*) as backlog_count"
   strQuery = strQuery & " from lics_header t01, lics_interface t02"
   strQuery = strQuery & " where t01.hea_interface = t02.int_interface(+)"
   strQuery = strQuery & " and t01.hea_status = '3'"
   strQuery = strQuery & " group by t01.hea_interface"
   strQuery = strQuery & " select"
   strQuery = strQuery & " '*STREAM_'||t01.sta_job_group as backlog_code,"
   strQuery = strQuery & " t01.sta_job_group||' - Stream procedures' as backlog_desc,"
   strQuery = strQuery & " '*STREAMED' as backlog_type,"
   strQuery = strQuery & " t01.sta_job_group as backlog_group,"
   strQuery = strQuery & " count(*) as backlog_count"
   strQuery = strQuery & " from lics_str_action t01"
   strQuery = strQuery & " where t01.sta_status = '*CREATED'"
   strQuery = strQuery & " group by t01.sta_job_group
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select"
   strQuery = strQuery & " '*TRIGGER_'||t01.tri_group as backlog_code,"
   strQuery = strQuery & " t01.tri_group||' - Triggered procedures' as backlog_desc,"
   strQuery = strQuery & " '*TRIGGERED' as backlog_type,"
   strQuery = strQuery & " t01.tri_group as backlog_group,"
   strQuery = strQuery & " count(*) as backlog_count"
   strQuery = strQuery & " from lics_triggered t01"
   strQuery = strQuery & " group by t01.tri_group)"
   strQuery = strQuery & " order by backlog_count desc, backlog_code asc"
   strReturn = objSelection.Execute("BACKLOG", strQuery, lngSize)
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
<!--#include file="ics_job_control.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->