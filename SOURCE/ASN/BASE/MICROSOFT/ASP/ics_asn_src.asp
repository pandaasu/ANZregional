<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_asn_src.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : September 2006                                     //
'// Text    : This script implements the ASN source              //
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
   strTarget = "ics_asn_src.asp"
   strHeading = "ASN Source Configuration"
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
   strReturn = GetSecurityCheck("ASN_SRC_CONFIG")
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
   '// Retrieve the source list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.cfs_src_code,"
   strQuery = strQuery & " t01.cfs_src_text"
   strQuery = strQuery & " from asn_cfg_src t01"
   strQuery = strQuery & " order by t01.cfs_src_code asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process insert load routine //
'/////////////////////////////////
sub ProcessInsertLoad()

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SrcCode", "")
   call objForm.AddField("DTA_SrcText", "")
   call objForm.AddField("DTA_SrcIdentifier", "")
   call objForm.AddField("DTA_SrcProcedure", "")
   call objForm.AddField("DTA_SrcWarnType", "0")
   call objForm.AddField("DTA_SrcWarnTime", "")
   call objForm.AddField("DTA_SrcWarnText", "")
   call objForm.AddField("DTA_SrcAlrtType", "0")
   call objForm.AddField("DTA_SrcAlrtTime", "")
   call objForm.AddField("DTA_SrcAlrtText", "")

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
   '// Insert the source
   '//
   strStatement = "asn_configuration.insert_source("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcText").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcIdentifier").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcProcedure").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcWarnType").Value) & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_SrcWarnTime").Value) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcWarnText").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcAlrtType").Value) & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_SrcAlrtTime").Value) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcAlrtText").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "INSERT"
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
   '// Retrieve the source data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.cfs_src_text,"
   strQuery = strQuery & " t01.cfs_src_iden,"
   strQuery = strQuery & " t01.cfs_msg_proc,"
   strQuery = strQuery & " t01.cfs_wrn_type,"
   strQuery = strQuery & " t01.cfs_wrn_time,"
   strQuery = strQuery & " t01.cfs_wrn_text,"
   strQuery = strQuery & " t01.cfs_alt_type,"
   strQuery = strQuery & " t01.cfs_alt_time,"
   strQuery = strQuery & " t01.cfs_alt_text"
   strQuery = strQuery & " from asn_cfg_src t01"
   strQuery = strQuery & " where t01.cfs_src_code = '" & objForm.Fields("DTA_SrcCode").Value & "'"
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
   call objForm.AddField("DTA_SrcIdentifier", objSelection.ListValue02("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_SrcProcedure", objSelection.ListValue03("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_SrcWarnType", objSelection.ListValue04("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_SrcWarnTime", objSelection.ListValue05("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_SrcWarnText", objSelection.ListValue06("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_SrcAlrtType", objSelection.ListValue07("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_SrcAlrtTime", objSelection.ListValue08("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("DTA_SrcAlrtText", objSelection.ListValue09("DETAIL",objSelection.ListLower("DETAIL")))

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
   '// Update the source
   '//
   strStatement = "asn_configuration.update_source("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcText").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcIdentifier").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcProcedure").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcWarnType").Value) & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_SrcWarnTime").Value) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcWarnText").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcAlrtType").Value) & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_SrcAlrtTime").Value) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcAlrtText").Value) & "'"
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
   '// Retrieve the source data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.cfs_src_text"
   strQuery = strQuery & " from asn_cfg_src t01"
   strQuery = strQuery & " where t01.cfs_src_code = '" & objForm.Fields("DTA_SrcCode").Value & "'"
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
   '// Delete the source
   '//
   strStatement = "asn_configuration.delete_source("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SrcCode").Value) & "'"
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
<!--#include file="ics_asn_src_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_asn_src_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_asn_src_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_asn_src_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->