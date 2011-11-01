<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_alerting_configuration.asp                     //
'// Author  : Steve Gregan                                       //
'// Date    : October 2011                                       //
'// Text    : This script implements the setting configuration   //
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
   strTarget = "ics_alerting_configuration.asp"
   strHeading = "Alert Configuration"

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
   strReturn = GetSecurityCheck("ICS_ALE_CONFIG")
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
         case "INSERT_LOAD"
            call ProcessInsertLoad
         case "INSERT_ACCEPT"
            call ProcessInsertAccept
         case "UPDATE_LOAD"
            call ProcessUpdateLoad
         case "UPDATE_ACCEPT"
            call ProcessUpdateAccept
         case "DELETE_LOAD"
            call ProcessDeleteLoad
         case "DELETE_ACCEPT"
            call ProcessDeleteAccept
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
      case "INSERT"
         call PaintInsert
      case "UPDATE"
         call PaintUpdate
      case "DELETE"
         call PaintDelete
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
   '// Retrieve the routing list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.ale_srch_txt,"
   strQuery = strQuery & " t01.ale_msg_txt"
   strQuery = strQuery & " from lics_alert t01"
   strQuery = strQuery & " order by t01.ale_srch_txt asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process insert load routine //
'/////////////////////////////////
sub ProcessInsertLoad()

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SrchTxt", "")
   call objForm.AddField("DTA_MsgTxt", "")

   '//
   '// Set the mode
   '//
   strMode = "INSERT"

end sub

'///////////////////////////////////
'// Process insert accept routine //
'///////////////////////////////////
sub ProcessInsertAccept()

   dim strStatement
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Insert the setting
   '//
   strStatement = "lics_alerting_configuration.update_setting("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrchTxt").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_MsgTxt").Value) & "',"
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "INSERT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

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
   '// Retrieve the setting data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.ale_srch_txt,"
   strQuery = strQuery & " t01.ale_msg_txt"
   strQuery = strQuery & " from lics_alert t01"
   strQuery = strQuery & " where t01.ale_srch_txt = '" & objForm.Fields("DTA_SrchTxt").Value & "'"
   strQuery = strQuery & " and t01.ale_msg_txt = '" & objForm.Fields("DTA_MsgTxt").Value & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SrchTxt", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_MsgTxt", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))

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
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Update the setting
   '//
   strStatement = "lics_alerting_configuration.update_setting("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrchTxt").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_MsgTxt").Value) & "',"
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
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

'/////////////////////////////////
'// Process delete load routine //
'/////////////////////////////////
sub ProcessDeleteLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the setting data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.ale_srch_txt,"
   strQuery = strQuery & " t01.ale_msg_txt"
   strQuery = strQuery & " from lics_alert t01"
   strQuery = strQuery & " where t01.ale_srch_txt = '" & objForm.Fields("DTA_SrchTxt").Value & "'"
   strQuery = strQuery & " and t01.ale_msg_txt = '" & objForm.Fields("DTA_MsgTxt").Value & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SrchTxt", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_MsgTxt", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))

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
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Set the procedure string
   '//
   strStatement = "lics_alerting_configuration.delete_setting("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrchTxt").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_MsgTxt").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "DELETE"
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
<!--#include file="ics_alerting_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_alerting_configuration_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_alerting_configuration_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_alerting_configuration_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->