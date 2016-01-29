<%@ language = VBScript  CODEPAGE="65001"%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_int_loader.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : November 2008                                      //
'// Text    : This script implements the interface loader        //
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
   dim strConfirm
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection
   dim objProcedure
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_int_loader.asp"
   strHeading = "Interface Loader"
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
   strReturn = GetSecurityCheck("ICS_INT_LOADER")
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
         case "SUBMIT"
            call ProcessSubmit
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the groups
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.int_interface,"
   strQuery = strQuery & " t01.int_description"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " where t01.int_usr_invocation = '1' and t01.int_status = '1'"
   strQuery = strQuery & " order by t01.int_interface asc"
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
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Load the form data
   '//
   '//call objProcedure.Execute("lics_form.clear_form")
   objProcedure.PutStatement("lics_form.clear_form")
   lngCount = clng(objForm.Fields().Item("StreamCount"))
   
   for i = 1 to lngCount	
      '//call objProcedure.Execute("lics_form.set_value('LOAD_STREAM','" & objSecurity.FixString(objForm.Fields().Item("StreamPart" & i)) & "')")      
      objProcedure.PutStatement("lics_form.set_value('LOAD_STREAM','" & objSecurity.FixString(objForm.Fields().Item("StreamPart" & i)) & "')")
   next 
      
   '//
   '// Execute the interface loader
   '//
   strStatement = "lics_interface_loader."
   strStatement = strStatement & "execute("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("SLT_Interface")) & "',"
   strStatement = strStatement & "'" & GetUser() & "')"
   '//strReturn = objFunction.Execute(strStatement)
   objProcedure.PutStatement(strStatement)
   objProcedure.PutStatement("lics_form.clear_form")
   strReturn = objProcedure.ExecuteProcedureBatchAndFunction()
   
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
   else
      strMode = "SELECT"
      strConfirm = "Interface " & objForm.Fields().Item("SLT_Interface") & " loaded"
   end if
   
   '//call objProcedure.Execute("lics_form.clear_form")
   set objProcedure = nothing

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
<!--#include file="ics_int_loader.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->