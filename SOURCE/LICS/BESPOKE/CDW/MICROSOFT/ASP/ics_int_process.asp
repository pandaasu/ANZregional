<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_int_process.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the interface process       //
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
   dim bolStrList
   dim bolEndList
   dim aryIntStatus(8)
   dim aryIntClass(8)
   dim objForm
   dim objSecurity
   dim objSelection
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_int_process.asp"
   strHeading = "Interface Process"
   aryIntStatus(1) = "Load Working"
   aryIntStatus(2) = "Load Working (Errors)"
   aryIntStatus(3) = "Load Completed"
   aryIntStatus(4) = "Load Completed (Errors)"
   aryIntStatus(5) = "Process Working"
   aryIntStatus(6) = "Process Working (Errors)"
   aryIntStatus(7) = "Process Completed"
   aryIntStatus(8) = "Process Completed (Errors)"
   aryIntClass(1) = "clsLabelFG"
   aryIntClass(2) = "clsLabelFR"
   aryIntClass(3) = "clsLabelFN"
   aryIntClass(4) = "clsLabelFR"
   aryIntClass(5) = "clsLabelFG"
   aryIntClass(6) = "clsLabelFR"
   aryIntClass(7) = "clsLabelFN"
   aryIntClass(8) = "clsLabelFR"

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
   strReturn = GetSecurityCheck("ICS_INT_PROCESS")
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else

      '//
      '// Get the form data
      '//
      GetForm()
      strMode = objForm.Fields("Mode").Value

      '//
      '// Process the form data
      '//
      select case strMode
         case "SELECT"
            call ProcessSelect
         case "NEXT"
            call ProcessSelect
         case "PREVIOUS"
            call ProcessSelect
         case "UPDATE_LOAD"
            call ProcessUpdateLoad
         case "UPDATE_ACCEPT"
            call ProcessUpdateAccept
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
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
      case "NEXT"
         call PaintSelect
      case "PREVIOUS"
         call PaintSelect
      case "UPDATE"
         call PaintUpdate
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
   if objForm.Fields("QRY_Test").Value = "" then
      call objForm.AddField("QRY_Test", "EQ")
   end if
   select case strMode
      case "SELECT"
         strWhere = ""
         strTest = " and "
         strOrder = "desc"
      case "PREVIOUS"
         strWhere = " and (t01.het_header > " & objForm.Fields("STR_Header").Value
         strWhere = strWhere & " or (t01.het_header = " & objForm.Fields("STR_Header").Value & " and t01.het_hdr_trace > " & objForm.Fields("STR_Trace").Value & "))"
         strTest = " and "
         strOrder = "asc"
      case "NEXT"
         strWhere = " and (t01.het_header < " & objForm.Fields("END_Header").Value
         strWhere = strWhere & " or (t01.het_header = " & objForm.Fields("END_Header").Value & " and t01.het_hdr_trace < " & objForm.Fields("END_Trace").Value & "))"
         strTest = " and "
         strOrder = "desc"
   end select
   strQuery = "select /*+ FIRST_ROWS */"
   strQuery = strQuery & " to_char(t01.het_header,'FM999999999999990'),"
   strQuery = strQuery & " to_char(t01.het_hdr_trace,'FM99990'),"
   strQuery = strQuery & " to_char(t01.het_execution,'FM999999999999990'),"
   strQuery = strQuery & " t01.het_user,"
   strQuery = strQuery & " to_char(t01.het_str_time, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " to_char(t01.het_end_time, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " t01.het_status,"
   strQuery = strQuery & " t02.hea_interface,"
   strQuery = strQuery & " t03.int_type,"
   strQuery = strQuery & " t03.int_group"
   strQuery = strQuery & " from lics_hdr_trace t01, lics_header t02, lics_interface t03"
   strQuery = strQuery & " where t01.het_header = t02.hea_header(+)"
   strQuery = strQuery & " and t02.hea_interface = t03.int_interface(+)"
   strQuery = strQuery & " and (t01.het_status = '7' or t01.het_status = '8')"
   if strWhere <> "" then
      strQuery = strQuery & strWhere
   end if
   if objForm.Fields("QRY_Header").Value <> "" then
      if objForm.Fields("QRY_Test").Value = "EQ" then
         strQuery = strQuery & strTest & "t01.het_header = " & objForm.Fields("QRY_Header").Value
         strTest = " and "
      end if
      if objForm.Fields("QRY_Test").Value = "LE" then
         strQuery = strQuery & strTest & "t01.het_header <= " & objForm.Fields("QRY_Header").Value
         strTest = " and "
      end if
      if objForm.Fields("QRY_Test").Value = "GE" then
         strQuery = strQuery & strTest & "t01.het_header >= " & objForm.Fields("QRY_Header").Value
         strTest = " and "
      end if
   end if
   if objForm.Fields("QRY_Execution").Value <> "" then
      strQuery = strQuery & strTest & "t01.het_execution = " & objForm.Fields("QRY_Execution").Value
      strTest = " and "
   end if
   if objForm.Fields("QRY_StrTime").Value <> "" then
      strQuery = strQuery & strTest & "to_char(t01.het_str_time,'YYYYMMDDHH24MISS') >= '" & objForm.Fields("QRY_StrTime").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_EndTime").Value <> "" then
      strQuery = strQuery & strTest & "to_char(t01.het_end_time,'YYYYMMDDHH24MISS') <= '" & objForm.Fields("QRY_EndTime").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_Status").Value <> "" then
      strQuery = strQuery & strTest & "t01.het_status = '" & objForm.Fields("QRY_Status").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_interface").Value <> "" then
      strQuery = strQuery & strTest & "t02.hea_interface = '" & objForm.Fields("QRY_Interface").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_Type").Value <> "" then
      strQuery = strQuery & strTest & "t03.int_type = '" & objForm.Fields("QRY_Type").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_Group").Value <> "" then
      strQuery = strQuery & strTest & "t03.int_group = '" & objForm.Fields("QRY_Group").Value & "'"
      strTest = " and "
   end if
   strQuery = strQuery & " order by t01.het_header " & strOrder & ", t01.het_hdr_trace " & strOrder
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Set the list start and end indicators
   '//
   bolStrList = true
   bolEndList = true
   if objSelection.ListCount("LIST") <> 0 then
      select case strMode
         case "SELECT"
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
   '// Execute the interface selection
   '//
   strQuery = "select t01.int_interface,"
   strQuery = strQuery & " t01.int_description"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " order by t01.int_interface asc"
   strReturn = objSelection.Execute("INTERFACE", strQuery, 0)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Execute the interface type selection
   '//
   strQuery = "select t01.int_type"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " group by t01.int_type"
   strQuery = strQuery & " order by t01.int_type asc"
   strReturn = objSelection.Execute("TYPE", strQuery, 0)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Execute the interface group selection
   '//
   strQuery = "select t01.int_group"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " group by t01.int_group"
   strQuery = strQuery & " order by t01.int_group asc"
   strReturn = objSelection.Execute("GROUP", strQuery, 0)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the interface data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.hea_header,'FM999999999999990'),"
   strQuery = strQuery & " t02.int_interface,"
   strQuery = strQuery & " t02.int_description,"
   strQuery = strQuery & " t02.int_type,"
   strQuery = strQuery & " t02.int_group"
   strQuery = strQuery & " from lics_header t01, lics_interface t02"
   strQuery = strQuery & " where t01.hea_interface = t02.int_interface(+)"
   strQuery = strQuery & " and t01.hea_header = " & objForm.Fields("DTA_HeaHeader").Value
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_HeaHeader", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntInterface", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntDescription", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntType", objSelection.ListValue04("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntGroup", objSelection.ListValue05("LIST",objSelection.ListLower("LIST")))

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
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Update the interface
   '//
   strStatement = "lics_interface_process.update_status("
   strStatement = strStatement & "'" & objForm.Fields("DTA_HeaHeader").Value & "'"
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
<!--#include file="ics_int_process_select.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_int_process_update.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->