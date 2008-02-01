<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_asn_rte.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : September 2006                                     //
'// Text    : This script implements the ASN route               //
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
   strTarget = "ics_asn_rte.asp"
   strHeading = "ASN Route Configuration"
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
   strReturn = GetSecurityCheck("ASN_RTE_CONFIG")
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
   '// Retrieve the route list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.cfr_src_code,"
   strQuery = strQuery & " t01.cfr_tar_code,"
   strQuery = strQuery & " t02.cfs_src_text,"
   strQuery = strQuery & " t03.cft_tar_text"
   strQuery = strQuery & " from asn_cfg_rte t01, asn_cfg_src t02, asn_cfg_tar t03"
   strQuery = strQuery & " where t01.cfr_src_code = t02.cfs_src_code(+) and t01.cfr_tar_code = t03.cft_tar_code(+)"
   strQuery = strQuery & " order by t01.cfr_src_code asc, t01.cfr_tar_code asc"
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
   '// Retrieve the source data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.cfs_src_code,"
   strQuery = strQuery & " t01.cfs_src_text"
   strQuery = strQuery & " from asn_cfg_src t01"
   strQuery = strQuery & " order by t01.cfs_src_code asc"
   strReturn = objSelection.Execute("SOURCE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the target data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.cft_tar_code,"
   strQuery = strQuery & " t01.cft_tar_text"
   strQuery = strQuery & " from asn_cfg_tar t01"
   strQuery = strQuery & " order by t01.cft_tar_code asc"
   strReturn = objSelection.Execute("TARGET", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SrcCode", "")
   call objForm.AddField("DTA_TarCode", "")
   call objForm.AddField("DTA_RteProcedure", "")
   call objForm.AddField("DTA_RteWarnType", "0")
   call objForm.AddField("DTA_RteWarnTime", "")
   call objForm.AddField("DTA_RteWarnText", "")
   call objForm.AddField("DTA_RteAlrtType", "0")
   call objForm.AddField("DTA_RteAlrtTime", "")
   call objForm.AddField("DTA_RteAlrtText", "")

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
   '// Insert the route
   '//
   strStatement = "asn_configuration.insert_route("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_TarCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_RteProcedure").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_RteWarnType").Value) & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_RteWarnTime").Value) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_RteWarnText").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_RteAlrtType").Value) & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_RteAlrtTime").Value) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_RteAlrtText").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "INSERT"
      call ProcessInsertLoad
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
   '// Retrieve the route data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.cfr_msg_proc,"
   strQuery = strQuery & " t01.cfr_wrn_type,"
   strQuery = strQuery & " t01.cfr_wrn_time,"
   strQuery = strQuery & " t01.cfr_wrn_text,"
   strQuery = strQuery & " t01.cfr_alt_type,"
   strQuery = strQuery & " t01.cfr_alt_time,"
   strQuery = strQuery & " t01.cfr_alt_text,"
   strQuery = strQuery & " t02.cfs_src_text,"
   strQuery = strQuery & " t03.cft_tar_text"
   strQuery = strQuery & " from asn_cfg_rte t01, asn_cfg_src t02, asn_cfg_tar t03"
   strQuery = strQuery & " where t01.cfr_src_code = t02.cfs_src_code(+) and t01.cfr_tar_code = t03.cft_tar_code(+)"
   strQuery = strQuery & " and t01.cfr_src_code = '" & objForm.Fields("DTA_SrcCode").Value & "'"
   strQuery = strQuery & " and t01.cfr_tar_code = '" & objForm.Fields("DTA_TarCode").Value & "'"
   strReturn = objSelection.Execute("DETAIL", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_RteProcedure", objSelection.ListValue01("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_RteWarnType", objSelection.ListValue02("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_RteWarnTime", objSelection.ListValue03("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_RteWarnText", objSelection.ListValue04("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_RteAlrtType", objSelection.ListValue05("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_RteAlrtTime", objSelection.ListValue06("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_RteAlrtText", objSelection.ListValue07("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_SrcText", objSelection.ListValue08("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_TarText", objSelection.ListValue09("DETAIL",objSelection.ListLower("DETAIL")))

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
   '// Update the route
   '//
   strStatement = "asn_configuration.update_route("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_TarCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_RteProcedure").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_RteWarnType").Value) & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_RteWarnTime").Value) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_RteWarnText").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_RteAlrtType").Value) & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_RteAlrtTime").Value) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_RteAlrtText").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "UPDATE"
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
   '// Retrieve the route data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t02.cfs_src_text,"
   strQuery = strQuery & " t03.cft_tar_text"
   strQuery = strQuery & " from asn_cfg_rte t01, asn_cfg_src t02, asn_cfg_tar t03"
   strQuery = strQuery & " where t01.cfr_src_code = t02.cfs_src_code(+) and t01.cfr_tar_code = t03.cft_tar_code(+)"
   strQuery = strQuery & " and t01.cfr_src_code = '" & objForm.Fields("DTA_SrcCode").Value & "'"
   strQuery = strQuery & " and t01.cfr_tar_code = '" & objForm.Fields("DTA_TarCode").Value & "'"
   strReturn = objSelection.Execute("DETAIL", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SrcText", objSelection.ListValue01("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_TarText", objSelection.ListValue02("DETAIL",objSelection.ListLower("DETAIL")))

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
   '// Delete the target
   '//
   strStatement = "asn_configuration.delete_route("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_TarCode").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "DELETE"
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
<!--#include file="ics_asn_rte_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_asn_rte_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_asn_rte_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_asn_rte_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->