<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : mch_fcst_extract.asp                               //
'// Author  : Steve Gregan                                       //
'// Date    : February 2008                                      //
'// Text    : This script implements the China forecast          //
'//           extract functionality                              //
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
   dim objFunction

   '//
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "mch_fcst_extract.asp"
   strHeading = "China Forecast Extract Maintenance"
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
   strReturn = GetSecurityCheck("MCH_FCST_EXTRACT")
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
   '// Retrieve the forecast extract type list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.extract_type,"
   strQuery = strQuery & " t01.extract_type_description"
   strQuery = strQuery & " from fcst_extract_type t01"
   strQuery = strQuery & " order by t01.extract_type asc"
   strReturn = objSelection.Execute("EXTRACT", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Retrieve the forecast extract type load list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.extract_type,"
   strQuery = strQuery & " t01.load_type"
   strQuery = strQuery & " from fcst_extract_type_load t01"
   strQuery = strQuery & " order by t01.extract_type asc, t01.load_type asc"
   strReturn = objSelection.Execute("EXTRACT_LOAD", strQuery, lngSize)
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
   strQuery = strQuery & " t01.load_type,"
   strQuery = strQuery & " to_char(t01.load_data_version)"
   strQuery = strQuery & " from fcst_load_header t01"
   strQuery = strQuery & " order by t01.load_identifier asc"
   strReturn = objSelection.Execute("LOAD", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Retrieve the forecast extract list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.extract_identifier,"
   strQuery = strQuery & " t01.extract_description,"
   strQuery = strQuery & " t01.extract_type,"
   strQuery = strQuery & " to_char(t01.extract_version),"
   strQuery = strQuery & " t01.crt_user||' - '||to_char(t01.crt_date,'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " t02.extract_format,"
   strQuery = strQuery & " t02.extract_procedure"
   strQuery = strQuery & " from fcst_extract_header t01, fcst_extract_type t02"
   strQuery = strQuery & " where t01.extract_type = t02.extract_type(+)"
   strQuery = strQuery & " order by t01.extract_identifier asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the fields
   '//
   if strMode = "SELECT" then
      call objForm.AddField("DTA_ExtractType", "")
      call objForm.AddField("DTA_ExtractIdentifier", "")
      call objForm.AddField("DTA_ExtractDescription", "")
      call objForm.AddField("DTA_ExtractVersion", "")
   end if

end sub

'////////////////////////////
'// Process create routine //
'////////////////////////////
sub ProcessCreate()

   dim strStatement
   dim lngCount
   dim strLoadIdentifier

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Retrieve the extract links
   '//
   strLoadIdentifier = ""
   lngCount = clng(objForm.Fields("DET_ExtractLinkCount").Value)
   for i = 1 to lngCount
      if strLoadIdentifier <> "" then
         strLoadIdentifier = strLoadIdentifier & ","
      end if
      strLoadIdentifier = strLoadIdentifier & objSecurity.FixString(objForm.Fields("DET_ExtractLink" & i).Value)
   next

   '//
   '// Execute the forecast extract creation
   '//
   strStatement = "dw_fcst_maintenance."
   strStatement = strStatement & "create_extract("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ExtractType").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ExtractIdentifier").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ExtractDescription").Value) & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_ExtractVersion").Value)  & ","
   strStatement = strStatement & "'" & strLoadIdentifier & "',"
   strStatement = strStatement & "'" & strUser & "')"
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
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Execute the forecast extract deletion
   '//
   strStatement = "dw_fcst_maintenance.delete_extract('" & objSecurity.FixString(objForm.Fields("DTA_ExtractIdentifier").Value) & "')"
   strReturn = objFunction.Execute(strStatement)
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
<!--#include file="mch_fcst_extract.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->