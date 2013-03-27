<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_stream_configuration.asp                       //
'// Author  : Steve Gregan                                       //
'// Date    : December 2008                                      //
'// Text    : This script implements the stream configuration    //
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
   strTarget = "ics_stream_configuration.asp"
   strHeading = "Stream Configuration"
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
   strReturn = GetSecurityCheck("ICS_STR_CONFIG")
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
         case "DEFINE_LOAD"
            call ProcessDefineLoad
         case "DEFINE_ACCEPT"
            call ProcessDefineAccept
         case "DELETE_LOAD"
            call ProcessDeleteLoad
         case "DELETE_ACCEPT"
            call ProcessDeleteAccept
         case "COPY_LOAD"
            call ProcessCopyLoad
         case "COPY_ACCEPT"
            call ProcessCopyAccept
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
      case "DEFINE"
         call PaintDefine
      case "DELETE"
         call PaintDelete
      case "COPY"
         call PaintCopy
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
   set objSelection = Server.CreateObject("ics_selection2.ICS_SELECTION")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the stream
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sth_str_code,"
   strQuery = strQuery & " t01.sth_str_text,"
   strQuery = strQuery & " decode(t01.sth_status,'1','Active','0','Inactive',t01.sth_status),"
   strQuery = strQuery & " t01.sth_upd_user,"
   strQuery = strQuery & " to_char(t01.sth_upd_time,'yyyy/mm/dd hh24:mi:ss')"
   strQuery = strQuery & " from lics_str_header t01"
   strQuery = strQuery & " order by t01.sth_str_code asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process define load routine //
'/////////////////////////////////
sub ProcessDefineLoad()

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_SELECTION")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the stream data
   '//
   if objForm.Fields().Item("DTA_StreamCode") <> "*NEW" then

      '//
      '// Retrieve the stream header
      '//
      strQuery = "select t01.sth_str_code,"
      strQuery = strQuery & " t01.sth_str_text,"
      strQuery = strQuery & " t01.sth_status"
      strQuery = strQuery & " from lics_str_header t01"
      strQuery = strQuery & " where t01.sth_str_code = '" & objForm.Fields().Item("DTA_StreamCode") & "'"
      strReturn = objSelection.Execute("STREAM", strQuery, 0)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Retrieve the stream nodes
      '//
      strQuery = "select "
      strQuery = strQuery & " to_char(t01.str_depth),"
      strQuery = strQuery & " t01.str_type,"
      strQuery = strQuery & " t01.str_parent,"
      strQuery = strQuery & " t01.str_code,"
      strQuery = strQuery & " t01.str_text,"
      strQuery = strQuery & " t01.str_lock,"
      strQuery = strQuery & " t01.str_proc,"
      strQuery = strQuery & " t01.str_job_group,"
      strQuery = strQuery & " t01.str_opr_alert,"
      strQuery = strQuery & " t01.str_ema_group"
      strQuery = strQuery & " from table(lics_app.lics_stream_configuration.get_nodes('" & objForm.Fields().Item("DTA_StreamCode") & "')) t01"
      strReturn = objSelection.Execute("NODES", strQuery, 0)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Initialise the data fields
      '//
      call objForm.AddField("DTA_StreamAction", "*UPDATE")
      call objForm.AddField("DTA_StreamText", objSelection.ListValue02("STREAM",objSelection.ListLower("STREAM")))
      call objForm.AddField("DTA_StreamStatus", objSelection.ListValue03("STREAM",objSelection.ListLower("STREAM")))

   else

      '//
      '// Initialise the data fields
      '//
      call objForm.AddField("DTA_StreamAction", "*CREATE")
      call objForm.UpdateField("DTA_StreamCode", "")
      call objForm.AddField("DTA_StreamText", "")
      call objForm.AddField("DTA_StreamStatus", "1")

   end if

   '//
   '// Set the mode
   '//
   strMode = "DEFINE"

end sub

'///////////////////////////////////
'// Process define accept routine //
'///////////////////////////////////
sub ProcessDefineAccept()

   dim strStatement
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   lngCount = clng(objForm.Fields().Item("StreamCount"))
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('TRANSACTION_STREAM','" & objSecurity.FixString(objForm.Fields().Item("StreamPart" & i)) & "')")
   next

   '//
   '// Define the stream
   '//
   strStatement = "lics_stream_configuration.define_stream('" & GetUser() & "')"
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
   strMode = "SELECT"
   call ProcessSelect

end sub


'/////////////////////////////////
'// Process delete load routine //
'/////////////////////////////////
sub ProcessDeleteLoad()

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_SELECTION")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the stream header
   '//
   strQuery = "select t01.sth_str_code,"
   strQuery = strQuery & " t01.sth_str_text,"
   strQuery = strQuery & " t01.sth_status"
   strQuery = strQuery & " from lics_str_header t01"
   strQuery = strQuery & " where t01.sth_str_code = '" & objForm.Fields().Item("DTA_StreamCode") & "'"
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
   '// Set the mode
   '//
   strMode = "DELETE"

end sub

'///////////////////////////////////
'// Process delete accept routine //
'///////////////////////////////////
sub ProcessDeleteAccept()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Delete the report
   '//
   strStatement = "lics_stream_configuration.delete_stream('" & objForm.Fields().Item("DTA_StreamCode") & "')"
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
   strMode = "SELECT"
   call ProcessSelect

end sub

'///////////////////////////////
'// Process copy load routine //
'///////////////////////////////
sub ProcessCopyLoad()

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_SELECTION")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the stream header
   '//
   strQuery = "select t01.sth_str_code,"
   strQuery = strQuery & " t01.sth_str_text,"
   strQuery = strQuery & " t01.sth_status"
   strQuery = strQuery & " from lics_str_header t01"
   strQuery = strQuery & " where t01.sth_str_code = '" & objForm.Fields().Item("DTA_StreamCode") & "'"
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
   call objForm.AddField("DTA_CopyCode", objForm.Fields().Item("DTA_StreamCode"))
   call objForm.UpdateField("DTA_StreamCode", "")
   call objForm.AddField("DTA_StreamText", objSelection.ListValue02("STREAM",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StreamStatus", objSelection.ListValue03("STREAM",objSelection.ListLower("STREAM")))

   '//
   '// Set the mode
   '//
   strMode = "COPY"

end sub

'/////////////////////////////////
'// Process copy accept routine //
'/////////////////////////////////
sub ProcessCopyAccept()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Copy the stream
   '//
   strStatement = "lics_stream_configuration.copy_stream("
   strStatement = strStatement & "'" & objForm.Fields().Item("DTA_CopyCode") & "',"
   strStatement = strStatement & "'" & objForm.Fields().Item("DTA_StreamCode") & "',"
   strStatement = strStatement & "'" & objForm.Fields().Item("DTA_StreamText") & "',"
   strStatement = strStatement & "'" & objForm.Fields().Item("DTA_StreamStatus") & "',"
   strStatement = strStatement & "'" & GetUser() & "'"
   strStatement = strStatement & ")"
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
<!--#include file="ics_stream_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint define routine //
'//////////////////////////
sub PaintDefine()%>
<!--#include file="ics_stream_configuration_define.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_stream_configuration_delete.inc"-->
<%end sub

'////////////////////////
'// Paint copy routine //
'////////////////////////
sub PaintCopy()%>
<!--#include file="ics_stream_configuration_copy.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->