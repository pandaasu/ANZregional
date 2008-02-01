<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_job_monitor.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the job monitor             //
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
   strTarget = "ics_job_monitor.asp"
   strHeading = "Job Monitor"
   aryJobStatus(1) = "Working"
   aryJobStatus(2) = "Idle"
   aryJobStatus(3) = "Suspended"
   aryJobStatus(4) = "Completed"
   aryJobStatus(5) = "Aborted"
   aryJobClass(1) = "clsLabelFG"
   aryJobClass(2) = "clsLabelFN"
   aryJobClass(3) = "clsLabelFN"
   aryJobClass(4) = "clsLabelFN"
   aryJobClass(5) = "clsLabelFR"

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
   strReturn = GetSecurityCheck("ICS_JOB_MONITOR")
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
   dim strWhere
   dim strTest
   dim lngSize
   dim strOrder

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the execution list
   '//
   lngSize = 20
   if objForm.Fields("Mode").Value = "" then
      call objForm.AddField("Mode", "SEARCH")
   end if
   if objForm.Fields("QRY_Test").Value = "" then
      call objForm.AddField("QRY_Test", "EQ")
   end if
   select case objForm.Fields("Mode").Value
      case "SEARCH"
         strWhere = ""
         strTest = " and "
         strOrder = "desc"
      case "PREVIOUS"
         strWhere = " and t01.jot_execution > " & objForm.Fields("STR_Execution").Value
         strTest = " and "
         strOrder = "asc"
      case "NEXT"
         strWhere = " and t01.jot_execution < " & objForm.Fields("END_Execution").Value
         strTest = " and "
         strOrder = "desc"
   end select
   strQuery = "select /*+ FIRST_ROWS */"
   strQuery = strQuery & " to_char(t01.jot_execution,'FM999999999999990'),"
   strQuery = strQuery & " t01.jot_job,"
   strQuery = strQuery & " t01.jot_type,"
   strQuery = strQuery & " decode(t01.jot_int_group,null,'*PROCEDURE',t01.jot_int_group),"
   strQuery = strQuery & " t01.jot_user,"
   strQuery = strQuery & " to_char(t01.jot_str_time, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " to_char(t01.jot_end_time, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " t01.jot_status"
   strQuery = strQuery & " from lics_job_trace t01, lics_job t02"
   strQuery = strQuery & " where t01.jot_job = t02.job_job(+)"
   if strWhere <> "" then
      strQuery = strQuery & strWhere
   end if
   if objForm.Fields("QRY_Execution").Value <> "" then
      if objForm.Fields("QRY_Test").Value = "EQ" then
         strQuery = strQuery & strTest & "t01.jot_execution = " & objForm.Fields("QRY_Execution").Value
         strTest = " and "
      end if
      if objForm.Fields("QRY_Test").Value = "LE" then
         strQuery = strQuery & strTest & "t01.jot_execution <= " & objForm.Fields("QRY_Execution").Value
         strTest = " and "
      end if
      if objForm.Fields("QRY_Test").Value = "GE" then
         strQuery = strQuery & strTest & "t01.jot_execution >= " & objForm.Fields("QRY_Execution").Value
         strTest = " and "
      end if
   end if
   if objForm.Fields("QRY_Job").Value <> "" then
      strQuery = strQuery & strTest & "t01.jot_job = '" & objForm.Fields("QRY_Job").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_Group").Value <> "" then
      strQuery = strQuery & strTest & "t01.jot_int_group = '" & objForm.Fields("QRY_Group").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_StrTime").Value <> "" then
      strQuery = strQuery & strTest & "to_char(t01.jot_str_time,'YYYYMMDDHH24MISS') <= '" & objForm.Fields("QRY_StrTime").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_EndTime").Value <> "" then
      strQuery = strQuery & strTest & "to_char(t01.jot_end_time,'YYYYMMDDHH24MISS') <= '" & objForm.Fields("QRY_EndTime").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_Status").Value <> "" then
      strQuery = strQuery & strTest & "t01.jot_status = '" & objForm.Fields("QRY_Status").Value & "'"
      strTest = " and "
   end if
   strQuery = strQuery & " order by jot_execution " & strOrder
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Set the list start and end indicators
   '//
   bolStrList = true
   bolEndList = true
   if objSelection.ListCount("LIST") <> 0 then
      select case objForm.Fields("Mode").Value
         case "SEARCH"
            bolStrList = true
            if objSelection.ListMore("LIST") = true then
               bolEndList = false
            end if
         case "PREVIOUS"
            if objSelection.ListMore("LIST") = true then
               bolStrList = false
            end if
            bolEndList = false
         case "NEXT"
            bolStrList = false
            if objSelection.ListMore("LIST") = true then
               bolEndList = false
            end if
      end select
   end if

   '//
   '// Execute the job selection
   '//
   strQuery = "select t01.job_job,"
   strQuery = strQuery & " t01.job_description"
   strQuery = strQuery & " from lics_job t01"
   strQuery = strQuery & " order by t01.job_job asc"
   strReturn = objSelection.Execute("JOB", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the interface group selection
   '//
   strQuery = "select t01.job_int_group"
   strQuery = strQuery & " from lics_job t01"
   strQuery = strQuery & " where not(t01.job_int_group is null)"
   strQuery = strQuery & " group by t01.job_int_group"
   strQuery = strQuery & " order by t01.job_int_group asc"
   strReturn = objSelection.Execute("GROUP", strQuery, 0)
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

'////////////////////////
'// Paint form routine //
'////////////////////////
sub PaintForm()%>
<!--#include file="ics_job_monitor.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->