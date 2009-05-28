<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : bpip_rad01_interface.asp                           //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the BPIP Radar forecast     //
'//           price interface functionality                      //
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
   dim strConfirm
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
   strTarget = "bpip_rad01_interface.asp"
   strHeading = "BPIP Radar Forecast Price Interface"
   strError = ""
   strConfirm = ""

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
   strReturn = GetSecurityCheck("BPIP_RAD01")
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
         case "SUBMIT"
            call ProcessSubmit
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
   '// Retrieve the plants
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.dsv_code||';'||trim(substr(t01.dsv_value,1,20)),"
   strQuery = strQuery & " trim(substr(t01.dsv_value,1,20)),"
   strQuery = strQuery & " substr(t01.dsv_value,21)"
   strQuery = strQuery & " from table(lics_datastore.retrieve_value('LADS','SAP_INTERFACE',null)) t01"
   strQuery = strQuery & " order by t01.dsv_code||';'||trim(substr(t01.dsv_value,1,20)) asc"
   strReturn = objSelection.Execute("PLANT", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'////////////////////////////
'// Process submit routine //
'////////////////////////////
sub ProcessSubmit()

   dim strStatement
   dim arySplit

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity


BUILD THE XML

   '//
   '// Submit the interface
   '//
   arySplit = split(objSecurity.FixString(objForm.Fields("SLT_Interface").Value), ";", -1, 1)
   strStatement = "lics_trigger_submitter.execute('SAP Table Interface'"
   strStatement = strStatement & ",'lics_sap_processor.execute_inbound(''" & arySplit(0) & "'',"
   strStatement = strStatement & "''" & arySplit(1) & "'',"
   strStatement = strStatement & "''" & objSecurity.FixString(objForm.Fields("SLT_User").Value) & "'',"
   strStatement = strStatement & "''" & objSecurity.FixString(objForm.Fields("SLT_password").Value) & "'',"
   strStatement = strStatement & "''*NONE'')"
   strStatement = strStatement & "','SAP_INTERFACE')"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
   else
      strConfirm = "Interface " & objForm.Fields("SLT_Interface").Value & " submitted"
   end if
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
<!--#include file="ics_sap_interface.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->