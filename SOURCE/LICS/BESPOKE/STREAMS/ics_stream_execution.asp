<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_stream_execution.asp                           //
'// Author  : Steve Gregan                                       //
'// Date    : December 2008                                      //
'// Text    : This script implements the stream execution        //
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
   strTarget = "ics_stream_execution.asp"
   strHeading = "Stream Execution"
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
   strReturn = GetSecurityCheck("ICS_STR_EXECUTE")
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
         case "SUBMIT_LOAD"
            call ProcessSubmitLoad
         case "SUBMIT_ACCEPT"
            call ProcessSubmitAccept
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
      case "SUBMIT"
         call PaintSubmit
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
   '// Retrieve the stream
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sth_str_code,"
   strQuery = strQuery & " t01.sth_str_text"
   strQuery = strQuery & " from lics_str_header t01"
   strQuery = strQuery & " where t01.sth_str_status = '1'"
   strQuery = strQuery & " order by t01.sth_str_code asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process submit load routine //
'/////////////////////////////////
sub ProcessSubmitLoad()

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the stream header
   '//
   strQuery = "select t01.sth_str_code,"
   strQuery = strQuery & " t01.sth_str_text"
   strQuery = strQuery & " from lics_str_header t01"
   strQuery = strQuery & " where t01.sth_str_code = '" & objForm.Fields("DTA_StreamCode").Value & "'"
   strReturn = objSelection.Execute("STREAM", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_StreamText", objSelection.ListValue02("STREAM",objSelection.ListLower("LIST")))

   '//
   '// Retrieve the stream parameters
   '//
   strQuery = "select t01.stp_par_code,"
   strQuery = strQuery & " t01.stp_par_text,"
   strQuery = strQuery & " t01.stp_par_value"
   strQuery = strQuery & " from lics_str_param t01"
   strQuery = strQuery & " where t01.stp_str_code = '" & objForm.Fields("DTA_StreamCode").Value & "'"
   strReturn = objSelection.Execute("PARAMS", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SUBMIT"

end sub

'///////////////////////////////////
'// Process submit accept routine //
'///////////////////////////////////
sub ProcessSubmitAccept()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   lngCount = clng(objForm.Fields("StreamCount").Value)
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('TRANSACTION_STREAM','" & objSecurity.FixString(objForm.Fields("StreamPart" & i).Value) & "')")
   next

   '//
   '// Submit the stream
   '//
   strStatement = "lics_stream_execution.submit_stream"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if


   '//
   '// Set the mode
   '//
   strMode = "SUBMIT"
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
<!--#include file="ics_stream_execution_select.inc"-->
<%end sub

'//////////////////////////
'// Paint submit routine //
'//////////////////////////
sub PaintSubmit()%>
<!--#include file="ics_stream_execution_submit.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->