<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_stream_monitor.asp                             //
'// Author  : Steve Gregan                                       //
'// Date    : December 2012                                      //
'// Text    : This script implements the stream monitor          //
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
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_stream_monitor.asp"
   strHeading = "Stream Monitor"
   strError = ""

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
   strReturn = GetSecurityCheck("ICS_STR_MONITOR")
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
         case "REVIEW"
            call ProcessReview
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
      case "REVIEW"
         call PaintReview
   end select
 
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the stream instances
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.sth_exe_seqn),"
   strQuery = strQuery & " t01.sth_exe_text,"
   strQuery = strQuery & " t01.sth_exe_status,"
   strQuery = strQuery & " t01.sth_exe_request,"
   strQuery = strQuery & " to_char(t01.sth_exe_load,'yyyy/mm/dd hh24:mi:ss'),"
   strQuery = strQuery & " to_char(t01.sth_exe_start,'yyyy/mm/dd hh24:mi:ss'),"
   strQuery = strQuery & " to_char(t01.sth_exe_end,'yyyy/mm/dd hh24:mi:ss'),"
   strQuery = strQuery & " t01.sth_str_code,"
   strQuery = strQuery & " t01.sth_str_text"
   strQuery = strQuery & " from lics_str_exe_header t01"
   strQuery = strQuery & " order by t01.sth_exe_seqn desc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'////////////////////////////
'// Process review routine //
'////////////////////////////
sub ProcessReview()

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the stream instance nodes
   '//
   strQuery = "select "
   strQuery = strQuery & " to_char(t01.str_depth),"
   strQuery = strQuery & " t01.str_type,"
   strQuery = strQuery & " t01.str_dt001,"
   strQuery = strQuery & " t01.str_dt002,"
   strQuery = strQuery & " t01.str_dt003,"
   strQuery = strQuery & " t01.str_dt004,"
   strQuery = strQuery & " t01.str_dt005,"
   strQuery = strQuery & " t01.str_dt006,"
   strQuery = strQuery & " t01.str_dt007,"
   strQuery = strQuery & " t01.str_dt008,"
   strQuery = strQuery & " t01.str_dt009,"
   strQuery = strQuery & " t01.str_dt010,"
   strQuery = strQuery & " t01.str_dt011,"
   strQuery = strQuery & " t01.str_dt012,"
   strQuery = strQuery & " t01.str_dt013"
   strQuery = strQuery & " from table(lics_app.lics_stream_monitor.get_nodes(" & objForm.Fields("DTA_StreamSeqn").Value & ")) t01"
   strReturn = objSelection.Execute("NODES", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "REVIEW"

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
<!--#include file="ics_stream_monitor_select.inc"-->
<%end sub

'//////////////////////////
'// Paint review routine //
'//////////////////////////
sub PaintReview()%>
<!--#include file="ics_stream_monitor_review.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->