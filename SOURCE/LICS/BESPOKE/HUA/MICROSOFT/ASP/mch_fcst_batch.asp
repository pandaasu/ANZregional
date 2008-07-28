<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : mch_fcst_batch.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : February 2008                                      //
'// Text    : This script implements the China forecast          //
'//           batch functionality                                //
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

   '//
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "mch_fcst_batch.asp"
   strHeading = "China Forecast Batch Extract"
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
   strReturn = GetSecurityCheck("MCH_FCST_BATCH")
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
         case "EXECUTE"
            call ProcessExecute
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
   '// Retrieve the forecast batch list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.extract_format,"
   strQuery = strQuery & " max(t01.extract_procedure)"
   strQuery = strQuery & " from fcst_extract_type t01"
   strQuery = strQuery & " where t01.extract_format not in ('*FILE','*INTERFACE')"
   strQuery = strQuery & " group by t01.extract_format"
   strQuery = strQuery & " order by t01.extract_format asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

end sub

'/////////////////////////////
'// Process execute routine //
'/////////////////////////////
sub ProcessExecute()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Execute the forecast batch extract
   '//
   strStatement = objSecurity.FixString(objForm.Fields("DTA_ExtractProcedure").Value)
   strStatement = strStatement & ".export('" & objSecurity.FixString(objForm.Fields("DTA_ExtractFormat").Value) & "')"
   strReturn = objProcedure.Execute(strStatement)
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
<!--#include file="mch_fcst_batch.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->