<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : mch_fcst_maintenance.asp                           //
'// Author  : Steve Gregan                                       //
'// Date    : February 2008                                      //
'// Text    : This script implements the China forecast          //
'//           maintenance functionality                          //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim strBase
   dim strUser
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
   dim objFunction

   '//
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "mch_fcst_maintenance.asp"
   strHeading = "China Forecast Maintenance"
   strError = ""

   '//
   '// Get the base/user string
   '//
   strBase = GetBase()
   strUser = GetUser()

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
   strReturn = GetSecurityCheck("MCH_FCST_MAINTENANCE")
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
         case "CREATE"
            call ProcessCreate
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
   if strMode = "FATAL" then
      call PaintFatal
   else
      call PaintResponse
   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objProcedure = nothing
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
   '// Retrieve the forecast split list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.load_type,"
   strQuery = strQuery & " t01.load_type_description"
   strQuery = strQuery & " from fcst_load_type t01"
   strQuery = strQuery & " order by t01.load_type asc"
   strReturn = objSelection.Execute("LOAD", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Retrieve the forecast load list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.load_identifier,"
   strQuery = strQuery & " t01.load_description,"
   strQuery = strQuery & " t01.load_status,"
   strQuery = strQuery & " t01.load_type,"
   strQuery = strQuery & " t01.load_data_type,"
   strQuery = strQuery & " to_char(t01.load_data_version),"
   strQuery = strQuery & " t01.upd_user||' - '||to_char(t01.upd_date,'YYYY/MM/DD HH24:MI:SS')"
   strQuery = strQuery & " from fcst_load_header t01"
   strQuery = strQuery & " order by t01.load_identifier asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the fields
   '//
   if strMode = "SELECT" then
      call objForm.AddField("DTA_LoadType", "*BR_AFFILIATE")
      call objForm.AddField("DTA_LoadIdentifier", "")
      call objForm.AddField("DTA_LoadDescription", "")
      call objForm.AddField("DTA_LoadDataType", "*QTY_GSV")
      call objForm.AddField("DTA_LoadDataVersion", "")
      call objForm.AddField("DTA_LoadDataRange", "13")
      call objForm.AddField("DTA_LoadDataFile", "")
   end if

end sub

'////////////////////////////
'// Process create routine //
'////////////////////////////
sub ProcessCreate()

   dim strStatement
   dim lngIndex

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   lngIndex = 1
   do while lngIndex <= len(objForm.Fields("DTA_LoadStream").Value)
      call objProcedure.Execute("lics_form.set_value('LOAD_STREAM','" & objSecurity.FixString(mid(objForm.Fields("DTA_LoadStream").Value,lngIndex,2000)) & "')")
      lngIndex = lngIndex + 2000
   loop

   '//
   '// Execute the forecast load creation
   '//
   strStatement = "dw_forecast_loading."
   strStatement = strStatement & "create_stream_load("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_LoadType").Value)  & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_LoadIdentifier").Value)  & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_LoadDescription").Value)  & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_LoadDataType").Value)  & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_LoadDataVersion").Value)  & ","
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_LoadDataRange").Value)  & ","
   strStatement = strStatement & "'" & strUser  & "')"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
   else
      strMode = "SELECT"
   end if

   '//
   '// Process the select
   '//
   call ProcessSelect

end sub

'////////////////////////////
'// Process delete routine //
'////////////////////////////
sub ProcessDelete()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Execute the forecast load creation
   '//
   strStatement = "dw_forecast_loading.delete_load('" & objSecurity.FixString(objForm.Fields("DTA_LoadIdentifier").Value)  & "')"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
   end if

   '//
   '// Process the select
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

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="mch_fcst_maintenance.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->