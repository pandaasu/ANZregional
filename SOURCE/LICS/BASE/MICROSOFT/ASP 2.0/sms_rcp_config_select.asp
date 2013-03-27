<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : SMS (SMS Reporting System)                         //
'// Script  : sms_rcp_config_select.asp                          //
'// Author  : Steve Gregan                                       //
'// Date    : July 2009                                          //
'// Text    : This script implements the recipient configuration //
'//           select functionality                               //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strReturn
   dim objForm
   dim objSecurity
   dim objProcedure
   dim objSelection

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 600

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurityCheck("SMS_RCP_CONFIG")
   if strReturn = "*OK" then
      GetForm()
      call ProcessRequest
   end if

   '//
   '// Return the error message
   '//
   if strReturn <> "*OK" then
      Response.Buffer = true
      Response.ContentType = "text/xml"
      Response.AddHeader "Cache-Control", "no-cache"
      Response.Write(strReturn)
   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objProcedure = nothing

'/////////////////////////////
'// Process request routine //
'/////////////////////////////
sub ProcessRequest()

   dim strStatement
   dim lngCount
   dim intIndex
   dim i

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   lngCount = clng(objForm.Fields().Item("StreamCount"))
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('SMS_STREAM','" & objSecurity.FixString(objForm.Fields().Item("StreamPart" & i)) & "')")
   next

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the recipient selection
   '//
   strStatement = "select xml_text from table(sms_app.sms_rcp_function.select_list)"
   strReturn = objSelection.Execute("RESPONSE", strStatement, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Retrieve any messages
   '//
   strStatement = "select xml_text from table(sms_app.sms_gen_function.get_mesg_data)"
   strReturn = objSelection.Execute("MESSAGE", strStatement, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Return the response string
   '//
   if strReturn = "*OK" then
      Response.Buffer = true
      Response.ContentType = "text/xml"
      Response.AddHeader "Cache-Control", "no-cache"
      Response.Write(strReturn)
      for intIndex = 0 to clng(objSelection.ListCount("MESSAGE")) - 1
         call Response.Write(objSelection.ListValue01("MESSAGE",intIndex))
      next
      if clng(objSelection.ListCount("MESSAGE")) = 0 then
         for intIndex = 0 to objSelection.ListCount("RESPONSE") - 1
            call Response.Write(objSelection.ListValue01("RESPONSE",intIndex))
         next
      end if
   end if

end sub%>
<!--#include file="ics_std_code.inc"-->