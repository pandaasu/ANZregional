<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_tes_response_load.asp                          //
'// Author  : Peter Tylee                                        //
'// Date    : October 2011                                       //
'// Text    : This script implements the test response load      //
'//           functionality                                      //
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
   strReturn = GetSecurityCheck("PTS_VAL_RESPONSE")
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
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   lngCount = clng(objForm.Fields("StreamCount").Value)
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('PTS_STREAM','" & objSecurity.FixString(objForm.Fields("StreamPart" & i).Value) & "')")
   next

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Load the test response data
   '//
   strStatement = "select xml_text from table(pts_app.pts_val_function.response_load)"
   strReturn = objSelection.Execute("RESPONSE", strStatement, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Retrieve any messages
   '//
   strStatement = "select xml_text from table(pts_app.pts_gen_function.get_mesg_data)"
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
      for intIndex = 0 to objSelection.ListCount("MESSAGE") - 1
         call Response.Write(objSelection.ListValue01("MESSAGE",intIndex))
      next
      if objSelection.ListCount("MESSAGE") = 0 then
         for intIndex = 0 to objSelection.ListCount("RESPONSE") - 1
            call Response.Write(objSelection.ListValue01("RESPONSE",intIndex))
         next
      end if
   end if

end sub%>
<!--#include file="ics_std_code.inc"-->