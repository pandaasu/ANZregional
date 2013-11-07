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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Execute the execution list
   '//
   lngSize = 20
   if objForm.Fields().Item("Mode") = "" then
      call objForm.AddField("Mode", "SEARCH")
   end if
   if objForm.Fields().Item("QRY_Test")= "" then
      call objForm.AddField("QRY_Test", "EQ")
   end if
   select case objForm.Fields().Item("Mode")
      case "SEARCH"
         strWhere = ""
         strTest = " and "
         strOrder = "desc"
      case "PREVIOUS"
         strWhere = " and t01.jot_execution > " & objForm.Fields().Item("STR_Execution")
         strTest = " and "
         strOrder = "asc"
      case "NEXT"
         strWhere = " and t01.jot_execution < " & objForm.Fields().Item("END_Execution")
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
   if objForm.Fields().Item("QRY_Execution") <> "" then
      if objForm.Fields().Item("QRY_Test") = "EQ" then
         strQuery = strQuery & strTest & "t01.jot_execution = " & objForm.Fields().Item("QRY_Execution")
         strTest = " and "
      end if
      if objForm.Fields().Item("QRY_Test") = "LE" then
         strQuery = strQuery & strTest & "t01.jot_execution <= " & objForm.Fields().Item("QRY_Execution")
         strTest = " and "
      end if
      if objForm.Fields().Item("QRY_Test") = "GE" then
         strQuery = strQuery & strTest & "t01.jot_execution >= " & objForm.Fields().Item("QRY_Execution")
         strTest = " and "
      end if
   end if
   if objForm.Fields().Item("QRY_Job") <> "" then
      strQuery = strQuery & strTest & "t01.jot_job = '" & objForm.Fields().Item("QRY_Job") & "'"
      strTest = " and "
   end if
   if objForm.Fields().Item("QRY_Group") <> "" then
      strQuery = strQuery & strTest & "t01.jot_int_group = '" & objForm.Fields().Item("QRY_Group") & "'"
      strTest = " and "
   end if
   if objForm.Fields().Item("QRY_StrTime") <> "" then
      strQuery = strQuery & strTest & "to_char(t01.jot_str_time,'YYYYMMDDHH24MISS') <= '" & objForm.Fields().Item("QRY_StrTime") & "'"
      strTest = " and "
   end if
   if objForm.Fields().Item("QRY_EndTime") <> "" then
      strQuery = strQuery & strTest & "to_char(t01.jot_end_time,'YYYYMMDDHH24MISS') <= '" & objForm.Fields().Item("QRY_EndTime") & "'"
      strTest = " and "
   end if
   if objForm.Fields().Item("QRY_Status") <> "" then
      strQuery = strQuery & strTest & "t01.jot_status = '" & objForm.Fields().Item("QRY_Status") & "'"
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
   if clng(objSelection.ListCount("LIST")) <> 0 then
      select case objForm.Fields().Item("Mode")
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