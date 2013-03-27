<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_sec_usr_configuration.asp                      //
'// Author  : Steve Gregan                                       //
'// Date    : June 2007                                          //
'// Text    : This script implements the security user           //
'//           configuration functionality				   //
'//  History  : Record the person who add/udpate the user and the time when //
'//		add/update the user. 	-- Derek, 21-May-21		   //
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
    dim strUserName 

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_sec_usr_configuration.asp"
   strHeading = "Security User Configuration"
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
   '// Retrieve the user list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.seu_user,"
   strQuery = strQuery & " t01.seu_description,"
   strQuery = strQuery & " decode(t01.seu_status,'1','Active','Inactive')"
   strQuery = strQuery & " from lics_sec_user t01"
   strQuery = strQuery & " order by t01.seu_user asc"
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
   '// Retrieve the menu data
   '//
   lngSize = 0
   strQuery = "select t01.sem_menu,"
   strQuery = strQuery & " t01.sem_description"
   strQuery = strQuery & " from lics_sec_menu t01"
   strQuery = strQuery & " order by t01.sem_menu asc"
   strReturn = objSelection.Execute("MENU", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SeuUser", "")
   call objForm.AddField("DTA_SeuDescription", "")
   call objForm.AddField("DTA_SeuMenu", "")
   call objForm.AddField("DTA_SeuStatus", "1")

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

   strUserName = GetUser()

   '//
   '// Create the function object
   '//
    set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Insert the user
   '//
   strStatement = "lics_security_configuration.insert_user("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeuUser")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeuDescription")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeuMenu")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeuStatus")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(strUserName) & "'"

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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the user data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.seu_user,"
   strQuery = strQuery & " t01.seu_description,"
   strQuery = strQuery & " t01.seu_menu,"
   strQuery = strQuery & " t01.seu_status"
   strQuery = strQuery & " from lics_sec_user t01"
   strQuery = strQuery & " where t01.seu_user = '" & objForm.Fields().Item("DTA_SeuUser") & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the menu data
   '//
   lngSize = 0
   strQuery = "select t01.sem_menu,"
   strQuery = strQuery & " t01.sem_description"
   strQuery = strQuery & " from lics_sec_menu t01"
   strQuery = strQuery & " order by t01.sem_menu asc"
   strReturn = objSelection.Execute("MENU", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SeuDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_SeuMenu", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_SeuStatus", objSelection.ListValue04("LIST",objSelection.ListLower("LIST")))

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
   dim lnglink

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)
   strUserName = GetUser()

   '//
   '// Update the user
   '//
   strStatement = "lics_security_configuration.update_user("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SeuUser").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SeuDescription").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SeuMenu").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SeuStatus").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(strUserName) & "'"

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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)


   '//
   '// Retrieve the user data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.seu_user,"
   strQuery = strQuery & " t01.seu_description"
   strQuery = strQuery & " from lics_sec_user t01"
   strQuery = strQuery & " where t01.seu_user = '" & objForm.Fields().Item("DTA_SeuUser") & "'"
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
   call objForm.AddField("DTA_SeuUser", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_SeuDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))

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
   '// Delete the user
   '//
   strStatement = "lics_security_configuration.delete_user("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SeuUser")) & "'"
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
<!--#include file="ics_sec_usr_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_sec_usr_configuration_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_sec_usr_configuration_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_sec_usr_configuration_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->