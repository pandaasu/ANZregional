<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_vds_sbm.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : July 2005                                          //
'// Text    : This script implements the validation data store   //
'//           submit functionality                               //
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
   strTarget = "ics_vds_sbm.asp"
   strHeading = "Validation Data Store Interface Submit"
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
   strReturn = GetSecurity()
   if strReturn = "*OK" then

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
   '// Retrieve the groups
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vin_interface,"
   strQuery = strQuery & " t01.vin_description,"
   strQuery = strQuery & " t01.vin_logon01,"
   strQuery = strQuery & " t01.vin_logon02"
   strQuery = strQuery & " from vds_interface t01"
   strQuery = strQuery & " order by t01.vin_description asc"
   strReturn = objSelection.Execute("INTERFACE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'////////////////////////////
'// Process submit routine //
'////////////////////////////
sub ProcessSubmit()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Submit the validation execution
   '//
   strStatement = "lics_trigger_submitter.execute('Validation Data Store Interface'"
   strStatement = strStatement & ",'lics_sap_processor.execute_dual_inbound(''SAPVDS01'',''ics_inbound_vds.sh''"
   strStatement = strStatement & ",''" & objSecurity.FixString(objForm.Fields("SLT_Interface").Value) & "''"
   strStatement = strStatement & ",''" & objSecurity.FixString(objForm.Fields("SLT_User01").Value) & "''"
   strStatement = strStatement & ",''" & objSecurity.FixString(objForm.Fields("SLT_Password01").Value) & "''"
   strStatement = strStatement & ",''" & objSecurity.FixString(objForm.Fields("SLT_User02").Value) & "''"
   strStatement = strStatement & ",''" & objSecurity.FixString(objForm.Fields("SLT_Password02").Value) & "'')"
   strStatement = strStatement & "','LADS_VALIDATION')"
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
<!--#include file="ics_vds_sbm.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->