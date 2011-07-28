<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_eve_monitor.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the event monitor           //
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
   strTarget = "ics_eve_monitor.asp"
   strHeading = "Event Monitor"

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
   strReturn = GetSecurityCheck("ICS_EVE_MONITOR")
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
   '// Execute the event list
   '//
   lngSize = 20
   if objForm.Fields("Mode").Value = "" then
      call objForm.AddField("Mode", "SEARCH")
   end if
   select case objForm.Fields("Mode").Value
      case "SEARCH"
         strWhere = ""
         strTest = " where "
         strOrder = "desc"
      case "PREVIOUS"
         strWhere = " where t01.eve_sequence > " & objForm.Fields("STR_Sequence").Value
         strTest = " and "
         strOrder = "asc"
      case "NEXT"
         strWhere = " where t01.eve_sequence < " & objForm.Fields("END_Sequence").Value
         strTest = " and "
         strOrder = "desc"
   end select
   strQuery = "select /*+ FIRST_ROWS */"
   strQuery = strQuery & " to_char(t01.eve_time,'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " t01.eve_result,"
   strQuery = strQuery & " t01.eve_job,"
   strQuery = strQuery & " to_char(t01.eve_execution,'FM999999999999990'),"
   strQuery = strQuery & " t01.eve_type,"
   strQuery = strQuery & " t01.eve_group,"
   strQuery = strQuery & " t01.eve_procedure,"
   strQuery = strQuery & " t01.eve_interface,"
   strQuery = strQuery & " to_char(t01.eve_header,'FM999999999999990'),"
   strQuery = strQuery & " to_char(t01.eve_hdr_trace,'FM99990'),"
   strQuery = strQuery & " t01.eve_message,"
   strQuery = strQuery & " t01.eve_opr_alert,"
   strQuery = strQuery & " t01.eve_ema_group,"
   strQuery = strQuery & " to_char(t01.eve_sequence,'FM999999999999990')"
   strQuery = strQuery & " from lics_event t01"
   if strWhere <> "" then
      strQuery = strQuery & strWhere
   end if
   if objForm.Fields("QRY_Time").Value <> "" then
      strQuery = strQuery & strTest & "to_char(t01.eve_time,'YYYYMMDDHH24MISS') <= " & objForm.Fields("QRY_Time").Value
      strTest = " and "
   end if
   if objForm.Fields("QRY_Result").Value <> "" then
      strQuery = strQuery & strTest & "t01.eve_result = '" & objForm.Fields("QRY_Result").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_Job").Value <> "" then
      strQuery = strQuery & strTest & "t01.eve_job = '" & objForm.Fields("QRY_Job").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_Interface").Value <> "" then
      strQuery = strQuery & strTest & "t01.eve_interface = '" & objForm.Fields("QRY_Interface").Value & "'"
      strTest = " and "
   end if
   strQuery = strQuery & " order by eve_sequence " & strOrder
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      exit sub
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
   '// Execute the interface selection
   '//
   strQuery = "select t01.int_interface,"
   strQuery = strQuery & " t01.int_description"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " order by t01.int_interface asc"
   strReturn = objSelection.Execute("INTERFACE", strQuery, 0)
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
<!--#include file="ics_eve_monitor.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->