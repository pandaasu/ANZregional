<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_int_configuration.asp                          //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the interface configuration //
'//           functionality                                      //
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
   dim aryIntStatus(2)
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
   strTarget = "ics_int_configuration.asp"
   strHeading = "Interface Configuration"
   aryIntStatus(0) = "Inactive"
   aryIntStatus(1) = "Active"

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
   strReturn = GetSecurityCheck("ICS_INT_CONFIG")
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
   '// Retrieve the interface list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.int_interface,"
   strQuery = strQuery & " t01.int_description,"
   strQuery = strQuery & " t01.int_type,"
   strQuery = strQuery & " t01.int_status"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " order by t01.int_interface asc"
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
   call objForm.AddField("DTA_IntInterface", "")
   call objForm.AddField("DTA_IntDescription", "")
   call objForm.AddField("DTA_IntType", "*INBOUND")
   call objForm.AddField("DTA_IntGroup", "")
   call objForm.AddField("DTA_IntPriority", "1")
   call objForm.AddField("DTA_IntHdrHistory", "1")
   call objForm.AddField("DTA_IntDtaHistory", "1")
   call objForm.AddField("DTA_IntFilPath", "ICS_INBOUND")
   call objForm.AddField("DTA_IntFilPrefix", "")
   call objForm.AddField("DTA_IntFilSequence", "0")
   call objForm.AddField("DTA_IntFileExtension", "")
   call objForm.AddField("DTA_IntOprAlert", "")
   call objForm.AddField("DTA_IntEmaGroup", "")
   call objForm.AddField("DTA_IntSearch", "")
   call objForm.AddField("DTA_IntProcedure", "")
   call objForm.AddField("DTA_IntStatus", "1")
   call objForm.AddField("DTA_IntUsrInvocation", "")
   call objForm.AddField("DTA_IntUsrValidation", "")
   call objForm.AddField("DTA_IntUsrMessage", "")
   call objForm.AddField("DTA_IntLodType", "*PUSH")
   call objForm.AddField("DTA_IntLodGroup", "*NONE")

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
   '// Insert the interface
   '//
   strStatement = "lics_interface_configuration.insert_interface("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntInterface").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntDescription").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntType").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntGroup").Value) & "',"
   strStatement = strStatement & objForm.Fields("DTA_IntPriority").Value & ","
   strStatement = strStatement & objForm.Fields("DTA_IntHdrHistory").Value & ","
   strStatement = strStatement & objForm.Fields("DTA_IntDtaHistory").Value & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntFilPath").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntFilPrefix").Value) & "',"
   strStatement = strStatement & objForm.Fields("DTA_IntFilSequence").Value & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntFilExtension").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntOprAlert").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntEmaGroup").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntSearch").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntProcedure").Value) & "',"
   strStatement = strStatement & "'" & objForm.Fields("DTA_IntStatus").Value & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntUsrInvocation").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntUsrValidation").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntUsrMessage").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntLodType").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntLodGroup").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "INSERT"
      strReturn = FormatError(strReturn)
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
   '// Retrieve the interface data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.int_interface,"
   strQuery = strQuery & " t01.int_description,"
   strQuery = strQuery & " t01.int_type,"
   strQuery = strQuery & " t01.int_group,"
   strQuery = strQuery & " t01.int_priority,"
   strQuery = strQuery & " t01.int_hdr_history,"
   strQuery = strQuery & " t01.int_dta_history,"
   strQuery = strQuery & " t01.int_fil_path,"
   strQuery = strQuery & " t01.int_fil_prefix,"
   strQuery = strQuery & " nvl(t01.int_fil_sequence,0),"
   strQuery = strQuery & " t01.int_fil_extension,"
   strQuery = strQuery & " t01.int_opr_alert,"
   strQuery = strQuery & " t01.int_ema_group,"
   strQuery = strQuery & " t01.int_search,"
   strQuery = strQuery & " t01.int_procedure,"
   strQuery = strQuery & " t01.int_status,"
   strQuery = strQuery & " t01.int_usr_invocation,"
   strQuery = strQuery & " t01.int_usr_validation,"
   strQuery = strQuery & " t01.int_usr_message,"
   strQuery = strQuery & " t01.int_lod_type,"
   strQuery = strQuery & " t01.int_lod_group"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " where t01.int_interface = '" & objForm.Fields("DTA_IntInterface").Value & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_IntInterface", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntType", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntGroup", objSelection.ListValue04("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntPriority", objSelection.ListValue05("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntHdrHistory", objSelection.ListValue06("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntDtaHistory", objSelection.ListValue07("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntFilPath", objSelection.ListValue08("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntFilPrefix", objSelection.ListValue09("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntFilSequence", objSelection.ListValue10("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntFilExtension", objSelection.ListValue11("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntOprAlert", objSelection.ListValue12("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntEmaGroup", objSelection.ListValue13("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntSearch", objSelection.ListValue14("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntProcedure", objSelection.ListValue15("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntStatus", objSelection.ListValue16("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntUsrInvocation", objSelection.ListValue17("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntUsrValidation", objSelection.ListValue18("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntUsrMessage", objSelection.ListValue19("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntLodType", objSelection.ListValue20("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntLodGroup", objSelection.ListValue21("LIST",objSelection.ListLower("LIST")))
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
   '// Update the interface
   '//
   strStatement = "lics_interface_configuration.update_interface("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntInterface").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntDescription").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntType").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntGroup").Value) & "',"
   strStatement = strStatement & objForm.Fields("DTA_IntPriority").Value & ","
   strStatement = strStatement & objForm.Fields("DTA_IntHdrHistory").Value & ","
   strStatement = strStatement & objForm.Fields("DTA_IntDtaHistory").Value & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntFilPath").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntFilPrefix").Value) & "',"
   strStatement = strStatement & objForm.Fields("DTA_IntFilSequence").Value & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntFilExtension").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntOprAlert").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntEmaGroup").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntSearch").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntProcedure").Value) & "',"
   strStatement = strStatement & "'" & objForm.Fields("DTA_IntStatus").Value & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntUsrInvocation").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntUsrValidation").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntUsrMessage").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntLodType").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntLodGroup").Value) & "'"
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
   '// Retrieve the interface data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.int_interface,"
   strQuery = strQuery & " t01.int_description,"
   strQuery = strQuery & " t01.int_type,"
   strQuery = strQuery & " t01.int_group,"
   strQuery = strQuery & " t01.int_priority,"
   strQuery = strQuery & " t01.int_hdr_history,"
   strQuery = strQuery & " t01.int_dta_history,"
   strQuery = strQuery & " t01.int_fil_path,"
   strQuery = strQuery & " t01.int_fil_prefix,"
   strQuery = strQuery & " nvl(t01.int_fil_sequence,0),"
   strQuery = strQuery & " t01.int_fil_extension,"
   strQuery = strQuery & " t01.int_opr_alert,"
   strQuery = strQuery & " t01.int_ema_group,"
   strQuery = strQuery & " t01.int_search,"
   strQuery = strQuery & " t01.int_procedure,"
   strQuery = strQuery & " t01.int_status,"
   strQuery = strQuery & " t01.int_usr_invocation,"
   strQuery = strQuery & " t01.int_usr_validation,"
   strQuery = strQuery & " t01.int_usr_message,"
   strQuery = strQuery & " t01.int_lod_type,"
   strQuery = strQuery & " t01.int_lod_group"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " where t01.int_interface = '" & objForm.Fields("DTA_IntInterface").Value & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_IntInterface", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntType", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntGroup", objSelection.ListValue04("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntPriority", objSelection.ListValue05("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntHdrHistory", objSelection.ListValue06("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntDtaHistory", objSelection.ListValue07("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntFilPath", objSelection.ListValue08("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntFilPrefix", objSelection.ListValue09("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntFilSequence", objSelection.ListValue10("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntFilExtension", objSelection.ListValue11("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntOprAlert", objSelection.ListValue12("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntEmaGroup", objSelection.ListValue13("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntSearch", objSelection.ListValue14("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntProcedure", objSelection.ListValue15("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntStatus", objSelection.ListValue16("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntUsrInvocation", objSelection.ListValue17("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntUsrValidation", objSelection.ListValue18("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntUsrMessage", objSelection.ListValue19("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntLodType", objSelection.ListValue20("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntLodGroup", objSelection.ListValue21("LIST",objSelection.ListLower("LIST")))

   '//
   '// Set the mode
   '//
   strMode = "DELETE"

end sub

'/////////////////////////////////
'// Process delete accept routine //
'/////////////////////////////////
sub ProcessDeleteAccept()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Delete the interface
   '//
   strStatement = "lics_interface_configuration.delete_interface("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_IntInterface").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "DELETE"
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
<!--#include file="ics_int_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_int_configuration_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_int_configuration_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_int_configuration_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->