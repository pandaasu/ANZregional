<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_sec_int_configuration.asp                      //
'// Author  : Trevor Keon                                        //
'// Date    : July 2008                                          //
'// Text    : This script implements the interface security      //
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
   strTarget = "ics_sec_int_configuration.asp"
   strHeading = "Security Interface Configuration"
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
   strReturn = GetSecurityCheck("ICS_USR_CONFIG")
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
   '// Retrieve the interface list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sei_interface,"
   strQuery = strQuery & " t01.sei_user"
   strQuery = strQuery & " from lics_sec_interface t01"
   strQuery = strQuery & " order by t01.sei_interface"
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
   '// Load required data for the form
   '//
   call LoadRequiredData

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SeiInterface", "")
   call objForm.AddField("DTA_SeiUser", "")

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
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Insert the interface
   '//
   strStatement = "lics_security_configuration.insert_int_sec("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeiInterface")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeiUser")) & "'"
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
   '// Load required data for the form
   '//
   call LoadRequiredData   

   '//
   '// Retrieve the interface data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sei_interface,"
   strQuery = strQuery & " t01.sei_user"
   strQuery = strQuery & " from lics_sec_interface t01"
   strQuery = strQuery & " where t01.sei_interface = '" & objForm.Fields().Item("DTA_SeiInterface") & "'"
   strQuery = strQuery & " and t01.sei_user = '" & objForm.Fields().Item("DTA_SeiUser") & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SeiInterface", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_SeiUser", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   
   '//
   '// Initialise the hidden data fields
   '//
   call objForm.AddField("DTA_SeiInterfaceOld", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_SeiUserOld", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))   

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
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Update the interface
   '//
   strStatement = "lics_security_configuration.update_int_sec("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeiInterfaceOld")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeiUserOld")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeiInterface")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeiUser")) & "'"
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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the interface data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sei_interface,"
   strQuery = strQuery & " t01.sei_user"
   strQuery = strQuery & " from lics_sec_interface t01"
   strQuery = strQuery & " where t01.sei_interface = '" & objForm.Fields().Item("DTA_SeiInterface") & "'"
   strQuery = strQuery & " and t01.sei_user = '" & objForm.Fields().Item("DTA_SeiUser") & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SeiInterface", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_SeiUser", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))

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
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Delete the interface
   '//
   strStatement = "lics_security_configuration.delete_int_sec("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeiInterface")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeiUser")) & "'"
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

'///////////////////////////////////////////
'// Load required data for insert/updates //
'///////////////////////////////////////////
sub LoadRequiredData()

   dim strQuery
   
   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Execute the interface selection
   '//
   strQuery = "select t01.int_interface,"
   strQuery = strQuery & " t01.int_description"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " order by t01.int_interface asc"
   strReturn = objSelection.Execute("INTERFACE", strQuery, 0)
   if strReturn <> "*OK" then
      strReturn = FormatError(strReturn)
      exit sub
   end if
   
   '//
   '// Execute the user selection
   '//
   strQuery = "select t01.seu_user,"
   strQuery = strQuery & " t01.seu_description"
   strQuery = strQuery & " from lics_sec_user t01"
   strQuery = strQuery & " order by t01.seu_user asc"
   strReturn = objSelection.Execute("USER", strQuery, 0)
   if strReturn <> "*OK" then
      strReturn = FormatError(strReturn)
      exit sub
   end if   

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
<!--#include file="ics_sec_int_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_sec_int_configuration_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_sec_int_configuration_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_sec_int_configuration_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->