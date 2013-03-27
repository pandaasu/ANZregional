<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_grp_configuration.asp                          //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the group configuration     //
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
   strTarget = "ics_grp_configuration.asp"
   strHeading = "Group Configuration"
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
   strReturn = GetSecurityCheck("ICS_GRP_CONFIG")
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else

      '//
      '// Get the form data
      '//
      GetForm()
      strMode = objForm.Fields().Item("Mode")

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
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the group list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.gro_group,"
   strQuery = strQuery & " t01.gro_description"
   strQuery = strQuery & " from lics_group t01"
   strQuery = strQuery & " order by t01.gro_group asc"
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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the interface data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.int_interface,"
   strQuery = strQuery & " t01.int_description,"
   strQuery = strQuery & " '0'"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " order by t01.int_interface asc"
   strReturn = objSelection.Execute("INTERFACE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_GroGroup", "")
   call objForm.AddField("DTA_GroDescription", "")

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
   dim lngCount

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Insert the group
   '//
   strStatement = "lics_group_configuration.insert_group("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_GroGroup")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_GroDescription")) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Insert the group details
   '//
   lngCount = clng(objForm.Fields().Item("DET_Count"))
   for i = 1 to lngCount
      strStatement = "lics_group_configuration.insert_group_detail("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_GroGroup")) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DET_Interface" & i)) & "'"
      strStatement = strStatement & ")"
      strReturn = objFunction.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the group data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.gro_group,"
   strQuery = strQuery & " t01.gro_description"
   strQuery = strQuery & " from lics_group t01"
   strQuery = strQuery & " where t01.gro_group = '" & objForm.Fields().Item("DTA_GroGroup") & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the interface data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.int_interface,"
   strQuery = strQuery & " t01.int_description,"
   strQuery = strQuery & " nvl(t02.gri_select,'0')"
   strQuery = strQuery & " from lics_interface t01,"
   strQuery = strQuery & " (select t01.gri_interface, '1' as gri_select"
   strQuery = strQuery & " from lics_grp_interface t01"
   strQuery = strQuery & " where t01.gri_group = '" & objForm.Fields().Item("DTA_GroGroup") & "') t02"
   strQuery = strQuery & " where t01.int_interface = t02.gri_interface(+)"
   strQuery = strQuery & " order by t01.int_interface asc"
   strReturn = objSelection.Execute("INTERFACE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_GroDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))

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
   dim lngCount

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Update the group
   '//
   strStatement = "lics_group_configuration.update_group("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_GroGroup")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_GroDescription")) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Clear the group details
   '//
   strStatement = "lics_group_configuration.clear_group_details("
   strStatement = strStatement & "'" & objForm.Fields().Item("DTA_GroGroup") & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Insert the group details
   '//
   lngCount = clng(objForm.Fields().Item("DET_Count"))
   for i = 1 to lngCount
      strStatement = "lics_group_configuration.insert_group_detail("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_GroGroup")) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DET_Interface" & i)) & "'"
      strStatement = strStatement & ")"
      strReturn = objFunction.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the group data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.gro_group,"
   strQuery = strQuery & " t01.gro_description"
   strQuery = strQuery & " from lics_group t01"
   strQuery = strQuery & " where t01.gro_group = '" & objForm.Fields().Item("DTA_GroGroup") & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_GroGroup", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_GroDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))

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
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Set the procedure string
   '//
   strStatement = "lics_group_configuration.delete_group("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_GroGroup")) & "'"
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
<!--#include file="ics_grp_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_grp_configuration_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_grp_configuration_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_grp_configuration_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->