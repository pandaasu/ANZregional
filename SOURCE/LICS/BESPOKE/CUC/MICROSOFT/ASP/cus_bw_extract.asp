<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : cus_bw_extract.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : February 2009                                      //
'// Text    : This script implements the Care BW extract         //
'//           execution functionality                            //
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
   dim intCount
   dim lngPeriod

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "cus_bw_extract.asp"
   strHeading = "Care BW Extract"
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
   strReturn = GetSecurityCheck("BW_EXTRACT_EXECUTE")
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

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the current period
   '//
   strQuery = "select to_char(t01.mars_period,'fm000000')"
   strQuery = strQuery & " from mars_date t01"
   strQuery = strQuery & " where trunc(t01.calendar_date) = trunc(sysdate)"
   strReturn = objSelection.Execute("PERIOD", strQuery, 0)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if
   lngPeriod = clng(objSelection.ListValue01("PERIOD",0))

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_Period", "*LAST")
   call objForm.AddField("DTA_Action", "*VALIDATE")

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
   '// Submit the BW extract
   '//
   strStatement = "lics_trigger_submitter.execute('CARE BW Extract','cr_app.care_bw_extract.execute("
   strStatement = strStatement & "''" & objSecurity.FixString(objForm.Fields("DTA_Period").Value) & "'',"
   strStatement = strStatement & "''" & objSecurity.FixString(objForm.Fields("DTA_Action").Value) & "'')',"
   strStatement = strStatement & "'CARE_SAPBW_EXTRACT')"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
   else
      strConfirm = "Care BW Extract - Period(" & objSecurity.FixString(objForm.Fields("DTA_Period").Value) & ") Action(" & objSecurity.FixString(objForm.Fields("DTA_Action").Value) & ") submitted"
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
<!--#include file="cus_bw_extract.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->