<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : prc_lst_item_lookup.asp                            //
'// Author  : Steve Gregan                                       //
'// Date    : December 2008                                      //
'// Text    : This script implements the price list item lookup  //
'//           functionality                                      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strReturn
   dim objForm
   dim objSecurity
   dim objSelection

   '//
   '// Set the server script timeout to (5 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 300

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
   '// Execute the price item lookup
   '//
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.price_item_id),"
   strQuery = strQuery & " t01.price_item_name,"
   strQuery = strQuery & " t01.price_item_desc"
   strQuery = strQuery & " from price_item t01"
   strQuery = strQuery & " where t01.price_mdl_id is null or t01.price_mdl_id = " & objForm.Fields("QRY_PriceMdlId").Value
   strQuery = strQuery & " order by t01.price_item_name asc"
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
         call Response.Write(objSelection.ListValue01("LIST",intIndex) & chr(9) & objSelection.ListValue02("LIST",intIndex) & chr(9) & objSelection.ListValue03("LIST",intIndex) & chr(10))
      next
   end if

end sub%>
<!--#include file="ics_std_code.inc"-->