<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_exe.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : May 2005                                           //
'// Text    : This script implements the validation execution    //
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
   dim objSelection
   dim objSecurity
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_val_exe.asp"
   strHeading = "Validation Execution"

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
   strReturn = GetSecurityCheck("VAL_SNG_EXECUTE")
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
      call ProcessRequest

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
   set objSelection = nothing
   set objSecurity = nothing
   set objFunction = nothing

'/////////////////////////////
'// Process request routine //
'/////////////////////////////
sub ProcessRequest

   dim strQuery
   dim lngSize
   dim strStatement

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Retrieve the classifications
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vac_class,"
   strQuery = strQuery & " '(' || t01.vac_group || ') ' || t01.vac_description"
   strQuery = strQuery & " from vds_val_cla t01"
   strQuery = strQuery & " order by t01.vac_group asc, t01.vac_description asc"
   strReturn = objSelection.Execute("CLASS", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

   '//
   '// Perform validation when required
   '//
   if strMode = "VALIDATE" then

      '//
      '// Execute the single validation
      '//
      strStatement = "vds_validation.execute_single("
      strStatement = strStatement & "'" & objForm.Fields("DTA_Class").Value & "',"
      strStatement = strStatement & "'" & objForm.Fields("DTA_Code").Value & "')"
      strReturn = objFunction.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         exit sub
      end if

      '//
      '// Retrieve the messages
      '//
      lngSize = 0
      strQuery = "select"
      strQuery = strQuery & " vam_rule,"
      strQuery = strQuery & " vam_text"
      strQuery = strQuery & " from vds_val_mes t01"
      strQuery = strQuery & " where t01.vam_execution = '*SINGLE'"
      strQuery = strQuery & " and t01.vam_code = '" & objForm.Fields("DTA_Code").Value & "'"
      strQuery = strQuery & " and t01.vam_class = '" & objForm.Fields("DTA_Class").Value & "'"
      strQuery = strQuery & " order by t01.vam_sequence asc"
      strReturn = objSelection.Execute("LIST", strQuery, lngSize)
      if strReturn <> "*OK" then
         strMode = "FATAL"
      end if

   end if

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
<!--#include file="ics_val_exe.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->