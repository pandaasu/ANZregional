<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : mjp_edi_payer.asp                                  //
'// Author  : Steve Gregan                                       //
'// Date    : February 2008                                      //
'// Text    : This script implements the EDI Payer               //
'//           configuration functionality                        //
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
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "mjp_edi_payer.asp"
   strHeading = "EDI Payer Configuration"
   strError = ""

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
   strReturn = GetSecurityCheck("MJP_EDI_PAYER_CONFIG")
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
         case "INSERT_LOAD"
            call ProcessInsertLoad
         case "INSERT_ACCEPT"
            call ProcessInsertAccept
         case "UPDATE_LOAD"
            call ProcessUpdateLoad
         case "UPDATE_ACCEPT"
            call ProcessUpdateAccept
         case "DELETE_LOAD"
            call ProcessDeleteLoad
         case "DELETE_ACCEPT"
            call ProcessDeleteAccept
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   select case strMode
      case "FATAL"
         call PaintFatal
      case "SELECT"
         call PaintSelect
      case "INSERT"
         call PaintInsert
      case "UPDATE"
         call PaintUpdate
      case "DELETE"
         call PaintDelete
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the payer list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sap_payer_code,"
   strQuery = strQuery & " t01.edi_link_type||' - '||t01.edi_link_code"
   strQuery = strQuery & " from payer_link t01"
   strQuery = strQuery & " order by t01.sap_payer_code asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process insert load routine //
'/////////////////////////////////
sub ProcessInsertLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the link data
   '//
   lngSize = 0
   strQuery = "select * from ("
   strQuery = strQuery & "select rpad('*AGENCY',10,' ')||t01.edi_agency_code as code,"
   strQuery = strQuery & " 'Collection Agency: '||t01.edi_agency_name as name"
   strQuery = strQuery & " from agency t01"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select rpad('*WHSLR',10,' ')||t01.edi_sndto_code as code,"
   strQuery = strQuery & " 'Wholesaler: '||t01.edi_whslr_name as name"
   strQuery = strQuery & " from whslr t01"
   strQuery = strQuery & ") order by code asc"
   strReturn = objSelection.Execute("PAYERLINK", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SapPayerCode", "")
   call objForm.AddField("DTA_PayerLink", "")

   '//
   '// Set the mode
   '//
   strMode = "INSERT"

end sub

'///////////////////////////////////
'// Process insert accept routine //
'///////////////////////////////////
sub ProcessInsertAccept()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Insert the payer
   '//
   strStatement = "edi_configuration.insert_payer("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SapPayerCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(trim(mid(objForm.Fields("DTA_PayerLink").Value,1,10))) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(mid(objForm.Fields("DTA_PayerLink").Value,11)) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'/////////////////////////////////
'// Process update load routine //
'/////////////////////////////////
sub ProcessUpdateLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the payer data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sap_payer_code,"
   strQuery = strQuery & " rpad(t01.edi_link_type,10,' ')||t01.edi_link_code"
   strQuery = strQuery & " from payer_link t01"
   strQuery = strQuery & " where t01.sap_payer_code = '" & objForm.Fields("DTA_SapPayerCode").Value & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the link data
   '//
   lngSize = 0
   strQuery = "select * from ("
   strQuery = strQuery & "select rpad('*AGENCY',10,' ')||t01.edi_agency_code as code,"
   strQuery = strQuery & " 'Collection Agency: '||t01.edi_agency_name as name"
   strQuery = strQuery & " from agency t01"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select rpad('*WHSLR',10,' ')||t01.edi_sndto_code as code,"
   strQuery = strQuery & " 'Wholesaler: '||t01.edi_whslr_name as name"
   strQuery = strQuery & " from whslr t01"
   strQuery = strQuery & ") order by code asc"
   strReturn = objSelection.Execute("PAYERLINK", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_PayerLink", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))

   '//
   '// Set the mode
   '//
   strMode = "UPDATE"

end sub

'///////////////////////////////////
'// Process update accept routine //
'///////////////////////////////////
sub ProcessUpdateAccept()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Update the payer
   '//
   strStatement = "edi_configuration.update_payer("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SapPayerCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(trim(mid(objForm.Fields("DTA_PayerLink").Value,1,10))) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(mid(objForm.Fields("DTA_PayerLink").Value,11)) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'/////////////////////////////////
'// Process delete load routine //
'/////////////////////////////////
sub ProcessDeleteLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the payer data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sap_payer_code"
   strQuery = strQuery & " from payer_link t01"
   strQuery = strQuery & " where t01.sap_payer_code = '" & objForm.Fields("DTA_SapPayerCode").Value & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "DELETE"

end sub

'///////////////////////////////////
'// Process delete accept routine //
'///////////////////////////////////
sub ProcessDeleteAccept()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Delete the payer
   '//
   strStatement = "edi_configuration.delete_payer("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SapPayerCode").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint prompt routine //
'//////////////////////////
sub PaintSelect()%>
<!--#include file="mjp_edi_payer_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="mjp_edi_payer_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="mjp_edi_payer_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="mjp_edi_payer_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->