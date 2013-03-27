<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_job_configuration.asp                          //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the routing configuration   //
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
   strTarget = "ics_rou_configuration.asp"
   strHeading = "Routing Configuration"

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
   strReturn = GetSecurityCheck("ICS_ROU_CONFIG")
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
   '// Retrieve the routing list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.rou_source,"
   strQuery = strQuery & " t01.rou_description"
   strQuery = strQuery & " from lics_routing t01"
   strQuery = strQuery & " order by t01.rou_source asc"
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
   strQuery = strQuery & " t01.int_description"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " order by t01.int_interface asc"
   strReturn = objSelection.Execute("INTERFACE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_RouSource", "")
   call objForm.AddField("DTA_RouDescription", "")
   call objForm.AddField("DTA_RouPreLength", "1")

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
   '// Insert the routing
   '//
   strStatement = "lics_routing_configuration.insert_routing("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_RouSource")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_RouDescription")) & "',"
   strStatement = strStatement & objForm.Fields().Item("DTA_RouPreLength")
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "INSERT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Insert the routing details
   '//
   lngCount = clng(objForm.Fields().Item("DET_Count"))
   for i = 1 to lngCount
      strStatement = "lics_routing_configuration.insert_routing_detail("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_RouSource")) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DET_Prefix" & i)) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DET_Interface" & i)) & "'"
      strStatement = strStatement & ")"
      strReturn = objFunction.Execute(strStatement)
      if strReturn <> "*OK" then
         strMode = "INSERT"
         strReturn = FormatError(strReturn)
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
   '// Retrieve the routing data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.rou_source,"
   strQuery = strQuery & " t01.rou_description,"
   strQuery = strQuery & " t01.rou_pre_length"
   strQuery = strQuery & " from lics_routing t01"
   strQuery = strQuery & " where t01.rou_source = '" & objForm.Fields().Item("DTA_RouSource") & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Retrieve the routing detail data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.rde_prefix,"
   strQuery = strQuery & " t01.rde_interface"
   strQuery = strQuery & " from lics_rtg_detail t01"
   strQuery = strQuery & " where t01.rde_source = '" & objForm.Fields().Item("DTA_RouSource") & "'"
   strQuery = strQuery & " order by t01.rde_prefix asc"
   strReturn = objSelection.Execute("DETAIL", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Retrieve the interface data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.int_interface,"
   strQuery = strQuery & " t01.int_description"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " order by t01.int_interface asc"
   strReturn = objSelection.Execute("INTERFACE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_RouSource", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_RouDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_RouPreLength", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))

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
   '// Update the routing
   '//
   strStatement = "lics_routing_configuration.update_routing("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_RouSource")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_RouDescription")) & "',"
   strStatement = strStatement & objForm.Fields().Item("DTA_RouPreLength")
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "UPDATE"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Clear the routing details
   '//
   strStatement = "lics_routing_configuration.clear_routing_details("
   strStatement = strStatement & "'" & objForm.Fields().Item("DTA_RouSource") & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "UPDATE"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Insert the routing details
   '//
   lngCount = clng(objForm.Fields().Item("DET_Count"))
   for i = 1 to lngCount
      strStatement = "lics_routing_configuration.insert_routing_detail("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_RouSource")) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DET_Prefix" & i)) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DET_Interface" & i)) & "'"
      strStatement = strStatement & ")"
      strReturn = objFunction.Execute(strStatement)
      if strReturn <> "*OK" then
         strMode = "UPDATE"
         strReturn = FormatError(strReturn)
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
   '// Retrieve the routing data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.rou_source,"
   strQuery = strQuery & " t01.rou_description,"
   strQuery = strQuery & " t01.rou_pre_length"
   strQuery = strQuery & " from lics_routing t01"
   strQuery = strQuery & " where t01.rou_source = '" & objForm.Fields().Item("DTA_RouSource") & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_RouSource", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_RouDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_RouPreLength", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))

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
   '// Set the procedure string
   '//
   strStatement = "lics_routing_configuration.delete_routing("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_RouSource")) & "'"
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
<!--#include file="ics_rou_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_rou_configuration_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_rou_configuration_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_rou_configuration_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->