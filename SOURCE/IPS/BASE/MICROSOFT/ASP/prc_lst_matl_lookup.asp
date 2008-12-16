<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : prc_lst_matl_lookup.asp                            //
'// Author  : Steve Gregan                                       //
'// Date    : December 2008                                      //
'// Text    : This script implements the price list material     //
'//           lookup functionality                               //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strReturn
   dim objForm
   dim objSecurity
   dim objSelection

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 600

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurity()
   if strReturn = "*OK" then
      GetForm()
      call ProcessLookup
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

'////////////////////////////
'// Process lookup routine //
'////////////////////////////
sub ProcessLookup()

   dim intIndex
   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the price material lookup
   '//
   strQuery = "select t01.value, t01.text from table(pr_app.pricelist_material.list(" & objForm.Fields("QRY_ReportId").Value & ")) t01"
   strReturn = objSelection.Execute("LIST", strQuery, 0)

   '//
   '// Return the response string
   '//
   if strReturn = "*OK" then
      Response.Buffer = true
      Response.ContentType = "text/xml"
      Response.AddHeader "Cache-Control", "no-cache"
      Response.Write(strReturn)
      for intIndex = 0 to objSelection.ListCount("LIST") - 1
         if intIndex > 0 then
            call Response.Write(chr(10))
         end if
         call Response.Write(objSelection.ListValue01("LIST",intIndex) & chr(9) & objSelection.ListValue02("LIST",intIndex))
      next
   end if

end sub%>
<!--#include file="ics_std_code.inc"-->