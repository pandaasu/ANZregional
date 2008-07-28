<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_lookup.asp                                     //
'// Author  : Steve Gregan                                       //
'// Date    : August 2006                                        //
'// Text    : This script implements the lookup functionality    //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strReturn
   dim strMode
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

      '//
      '// Get the form data
      '//
      GetForm()

      '//
      '// Process the form data
      '//
      strMode = objForm.Fields("Mode").Value
      select case strMode
         case "GROUPING"
            call ProcessGrouping
         case "REFERENCE"
            call ProcessReference
         case else
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
      end select

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

'//////////////////////////////
'// Process grouping routine //
'//////////////////////////////
sub ProcessGrouping()

   dim intIndex
   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the interface selection
   '//
   if objForm.Fields("QRY_Grouping").Value = "" then
      strQuery = "select t01.int_interface,"
      strQuery = strQuery & " t01.int_description"
      strQuery = strQuery & " from lics_interface t01"
      strQuery = strQuery & " order by t01.int_interface asc"
      strReturn = objSelection.Execute("INTERFACE", strQuery, 0)
   else
      strQuery = "select t02.int_interface,"
      strQuery = strQuery & " t02.int_description"
      strQuery = strQuery & " from lics_grp_interface t01, lics_interface t02"
      strQuery = strQuery & " where t01.gri_interface = t02.int_interface"
      strQuery = strQuery & " and t01.gri_group = '" & objForm.Fields("QRY_Grouping").Value & "'"
      strQuery = strQuery & " order by t02.int_interface asc"
      strReturn = objSelection.Execute("INTERFACE", strQuery, 0)
   end if

   '//
   '// Return the response string
   '//
   if strReturn = "*OK" then
      Response.Buffer = true
      Response.ContentType = "text/xml"
      Response.AddHeader "Cache-Control", "no-cache"
      Response.Write(strReturn)
      for intIndex = 0 to objSelection.ListCount("INTERFACE") - 1
         call Response.Write(objSelection.ListValue01("INTERFACE",intIndex) & chr(9) & "(" & objSelection.ListValue01("INTERFACE",intIndex) & ") " & objSelection.ListValue02("INTERFACE",intIndex) & chr(10))
      next
   end if

end sub

'///////////////////////////////
'// Process reference routine //
'///////////////////////////////
sub ProcessReference()

   dim intIndex
   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the reference selection
   '//
   strQuery = "select t01.inr_reference"
   strQuery = strQuery & " from lics_int_reference t01"
   strQuery = strQuery & " where t01.inr_interface = '" & objForm.Fields("QRY_Interface").Value & "'"
   strQuery = strQuery & " order by t01.inr_reference asc"
   strReturn = objSelection.Execute("REFERENCE", strQuery, 0)

   '//
   '// Return the response string
   '//
   if strReturn = "*OK" then
      Response.Buffer = true
      Response.ContentType = "text/xml"
      Response.AddHeader "Cache-Control", "no-cache"
      Response.Write(strReturn)
      for intIndex = 0 to objSelection.ListCount("REFERENCE") - 1
         call Response.Write(objSelection.ListValue01("REFERENCE",intIndex) & chr(10))
      next
   end if

end sub%>
<!--#include file="ics_std_code.inc"-->