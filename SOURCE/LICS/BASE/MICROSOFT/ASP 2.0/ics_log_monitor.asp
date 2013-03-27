<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_log_monitor.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the log monitor             //
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
   strTarget = "ics_log_monitor.asp"
   strHeading = "Log Monitor"

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
   strReturn = GetSecurityCheck("ICS_LOG_MONITOR")
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
   '// Execute the event list
   '//
   lngSize = 20
   if objForm.Fields().Item("Mode") = "" then
      call objForm.AddField("Mode", "SEARCH")
   end if
   select case objForm.Fields().Item("Mode")
      case "SEARCH"
         strWhere = " where t01.log_trace = 1"
         strTest = " and "
         strOrder = "desc"
      case "PREVIOUS"
         strWhere = " where (t01.log_sequence > " & objForm.Fields().Item("STR_Sequence") & " and t01.log_trace = 1)"
         strTest = " and "
         strOrder = "asc"
      case "NEXT"
         strWhere = " where (t01.log_sequence < " & objForm.Fields().Item("END_Sequence") & " and t01.log_trace = 1)"
         strTest = " and "
         strOrder = "desc"
   end select
   strQuery = "select /*+ FIRST_ROWS */"
   strQuery = strQuery & " to_char(t01.log_sequence,'FM999999999999990'),"
   strQuery = strQuery & " to_char(t01.log_time,'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " t01.log_text,"
   strQuery = strQuery & " t01.log_search"
   strQuery = strQuery & " from lics_log t01"
   if strWhere <> "" then
      strQuery = strQuery & strWhere
   end if
   if objForm.Fields().Item("QRY_Time") <> "" then
      strQuery = strQuery & strTest & "to_char(t01.log_time,'YYYYMMDDHH24MISS') <= " & objForm.Fields().Item("QRY_Time")
      strTest = " and "
   end if
   if objForm.Fields().Item("QRY_Search") <> "" then
      strQuery = strQuery & strTest & "t01.log_search like '%" & objForm.Fields().Item("QRY_Search") & "%'"
      strTest = " and "
   end if
   strQuery = strQuery & " order by log_sequence " & strOrder
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
<!--#include file="ics_log_monitor.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->