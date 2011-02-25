<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_fil_monitor.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : February 2011                                      //
'// Text    : This script implements the file monitor            //
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
   dim aryFilStatus(2)
   dim aryFilClass(2)
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
   strTarget = "ics_fil_monitor.asp"
   strHeading = "File Monitor"
   aryFilStatus(1) = "Available"
   aryFilStatus(2) = "Errors"
   aryFilClass(1) = "clsLabelFG"
   aryFilClass(2) = "clsLabelFR"

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
   strReturn = GetSecurityCheck("ICS_FIL_MONITOR")
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
         case "SEARCH"
            call ProcessSelect
         case "RETRY"
            call ProcessRetry
         case "DELETE"
            call ProcessDelete
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
      case "SEARCH"
         call PaintSelect
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the file list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.fil_file,'FM999999999999990'),"
   strQuery = strQuery & " t01.fil_path,"
   strQuery = strQuery & " t01.fil_name,"
   strQuery = strQuery & " t01.fil_status,"
   strQuery = strQuery & " t01.fil_crt_user,"
   strQuery = strQuery & " to_char(t01.fil_crt_time, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " t02.int_type,"
   strQuery = strQuery & " t02.int_lod_group,"
   strQuery = strQuery & " t01.fil_message"
   strQuery = strQuery & " from lics_file t01, lics_interface t02"
   strQuery = strQuery & " where t01.fil_path = t02.int_interface(+)"
   strQuery = strQuery & " order by t01.fil_file asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

end sub

'///////////////////////////
'// Process retry routine //
'///////////////////////////
sub ProcessRetry()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Retry the file
   '//
   strStatement = "lics_file_monitor.retry_file("
   strStatement = strStatement & objForm.Fields("DTA_FilFile").Value
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "SEARCH"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SEARCH"
   call ProcessSelect

end sub

'////////////////////////////
'// Process delete routine //
'////////////////////////////
sub ProcessDelete()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Delete the file
   '//
   strStatement = "lics_file_monitor.delete_file("
   strStatement = strStatement & objForm.Fields("DTA_FilFile").Value
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "SEARCH"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SEARCH"
   call ProcessSelect

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint select routine //
'//////////////////////////
sub PaintSelect()%>
<!--#include file="ics_fil_monitor_select.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->