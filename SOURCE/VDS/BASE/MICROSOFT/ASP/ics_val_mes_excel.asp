<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_mes_excel.asp                              //
'// Author  : Steve Gregan                                       //
'// Date    : August 2005                                        //
'// Text    : This script implements the validation filter       //
'//           message excel                                      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim j
   dim strReturn
   dim objForm
   dim objSecurity
   dim objSelection

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

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
      '// Process the request
      '//
      call ProcessRequest

   end if

   '//
   '// Paint response
   '//
   call PaintResponse
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing

'/////////////////////////////
'// Process request routine //
'/////////////////////////////
sub ProcessRequest

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Classification
   '//
   if objForm.Fields("DTA_Data").Value = "*CLASS" then

      '//
      '// Retrieve classification messages
      '//
      strQuery = "select vam_code, vam_sequence, vam_group, vam_class, vam_type, vam_filter, vam_rule, vam_text"
      strQuery = strQuery & " from vds_val_mes"
      strQuery = strQuery & " where vam_class = '" & objForm.Fields("DTA_Select").Value & "'"
      strQuery = strQuery & " and vam_version = 0"
      strQuery = strQuery & " order by vam_code asc, vam_sequence asc"
      strReturn = objSelection.Execute("DATA", strQuery, 0)
      if strReturn <> "*OK" then
         strMode = "FATAL"
         exit sub
      end if

   end if

   '//
   '// Type
   '//
   if objForm.Fields("DTA_Data").Value = "*TYPE" then

      '//
      '// Retrieve type messages
      '//
      strQuery = "select vam_code, vam_sequence, vam_group, vam_class, vam_type, vam_filter, vam_rule, vam_text"
      strQuery = strQuery & " from vds_val_mes"
      strQuery = strQuery & " where vam_type = '" & objForm.Fields("DTA_Select").Value & "'"
      strQuery = strQuery & " and vam_version = 0"
      strQuery = strQuery & " order by vam_code asc, vam_sequence asc"
      strReturn = objSelection.Execute("DATA", strQuery, 0)
      if strReturn <> "*OK" then
         strMode = "FATAL"
         exit sub
      end if

   end if

   '//
   '// Filter
   '//
   if objForm.Fields("DTA_Data").Value = "*FILTER" then

      '//
      '// Retrieve filter messages
      '//
      strQuery = "select vam_code, vam_sequence, vam_group, vam_class, vam_type, vam_filter, vam_rule, vam_text"
      strQuery = strQuery & " from vds_val_mes"
      strQuery = strQuery & " where vam_filter = '" & objForm.Fields("DTA_Select").Value & "'"
      strQuery = strQuery & " and vam_version = 0"
      strQuery = strQuery & " order by vam_code asc, vam_sequence asc"
      strReturn = objSelection.Execute("DATA", strQuery, 0)
      if strReturn <> "*OK" then
         strMode = "FATAL"
         exit sub
      end if

   end if

   '//
   '// Rule
   '//
   if objForm.Fields("DTA_Data").Value = "*RULE" then

      '//
      '// Retrieve rule messages
      '//
      strQuery = "select vam_code, vam_sequence, vam_group, vam_class, vam_type, vam_filter, vam_rule, vam_text"
      strQuery = strQuery & " from vds_val_mes"
      strQuery = strQuery & " where vam_rule = '" & objForm.Fields("DTA_Select").Value & "'"
      strQuery = strQuery & " and vam_version = 0"
      strQuery = strQuery & " order by vam_code asc, vam_sequence asc"
      strReturn = objSelection.Execute("DATA", strQuery, 0)
      if strReturn <> "*OK" then
         strMode = "FATAL"
         exit sub
      end if

   end if

   '//
   '// Set the response
   '//
   Response.Buffer = true
   Response.ContentType = "application/vnd.ms-excel"
   Response.AddHeader "content-disposition", "attachment; filename=" & objForm.Fields("DTA_Select").Value & ".xls"

end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="ics_val_mes_excel.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->