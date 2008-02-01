<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_asn_parameter.asp                              //
'// Author  : Steve Gregan                                       //
'// Date    : November 2005                                      //
'// Text    : This script implements the ASN parameter           //
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
   strTarget = "ics_asn_parameter.asp"
   strHeading = "ASN Parameter Configuration"

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
   strReturn = GetSecurityCheck("ASN_PAR_CONFIG")
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
         case "UPDATE_LOAD"
            call ProcessUpdateLoad
         case "UPDATE_ACCEPT"
            call ProcessUpdateAccept
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
      case "UPDATE"
         call PaintUpdate
   end select
 
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the parameter group list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.apg_group,"
   strQuery = strQuery & " t01.apg_desc,"
   strQuery = strQuery & " t02.apc_code,"
   strQuery = strQuery & " t03.apv_value,"
   strQuery = strQuery & " decode(t03.apv_updt_tim,null,'Not defined',to_char(t03.apv_updt_tim,'yyyy/mm/dd hh24:mi:ss'))"
   strQuery = strQuery & " from asn_par_grp t01, asn_par_cde t02, asn_par_val t03"
   strQuery = strQuery & " where t01.apg_group = t02.apc_group"
   strQuery = strQuery & " and t02.apc_group = t03.apv_group(+)"
   strQuery = strQuery & " and t02.apc_code = t03.apv_code(+)"
   strQuery = strQuery & " order by t01.apg_group asc, t02.apc_code"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

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
   '// Retrieve the parameter group codes and values
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.apg_group,"
   strQuery = strQuery & " t02.apc_code,"
   strQuery = strQuery & " t03.apv_value,"
   strQuery = strQuery & " t01.apg_desc,"
   strQuery = strQuery & " t02.apc_type,"
   strQuery = strQuery & " decode(t03.apv_updt_tim,null,'Not defined',to_char(t03.apv_updt_tim,'yyyy/mm/dd hh24:mi:ss'))"
   strQuery = strQuery & " from asn_par_grp t01, asn_par_cde t02, asn_par_val t03"
   strQuery = strQuery & " where t01.apg_group = t02.apc_group(+)"
   strQuery = strQuery & " and t02.apc_group = t03.apv_group(+)"
   strQuery = strQuery & " and t02.apc_code = t03.apv_code(+)"
   strQuery = strQuery & " and t01.apg_group = '" & objForm.Fields("DTA_ParGroup").Value & "'"
   strQuery = strQuery & " and t02.apc_code = '" & objForm.Fields("DTA_ParCode").Value & "'"
   strReturn = objSelection.Execute("CODE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_ParGroup", objSelection.ListValue01("CODE",objSelection.ListLower("CODE")))
   call objForm.AddField("DTA_ParCode", objSelection.ListValue02("CODE",objSelection.ListLower("CODE")))
   call objForm.AddField("DTA_ParValue", objSelection.ListValue03("CODE",objSelection.ListLower("CODE")))
   call objForm.AddField("DTA_ParDesc", objSelection.ListValue04("CODE",objSelection.ListLower("CODE")))
   call objForm.AddField("DTA_ParType", objSelection.ListValue05("CODE",objSelection.ListLower("CODE")))
   call objForm.AddField("DTA_ParUpdate", objSelection.ListValue06("CODE",objSelection.ListLower("CODE")))

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
   '// Update the setting
   '//
   strStatement = "asn_parameter.update_value("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ParGroup").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ParCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ParValue").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "UPDATE"
      strReturn = FormatError(strReturn)
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
<!--#include file="ics_asn_parameter_select.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_asn_parameter_update.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->