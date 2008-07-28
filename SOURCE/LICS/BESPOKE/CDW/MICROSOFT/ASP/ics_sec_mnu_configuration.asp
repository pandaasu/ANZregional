<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_sec_mnu_configuration.asp                      //
'// Author  : Steve Gregan                                       //
'// Date    : June 2007                                          //
'// Text    : This script implements the security menu           //
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
   strTarget = "ics_sec_mnu_configuration.asp"
   strHeading = "Security Menu Configuration"
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
   strReturn = GetSecurityCheck("ICS_MNU_CONFIG")
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
   '// Retrieve the menu list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sem_menu,"
   strQuery = strQuery & " t01.sem_description"
   strQuery = strQuery & " from lics_sec_menu t01"
   strQuery = strQuery & " order by t01.sem_menu asc"
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
   '// Retrieve the link menu data
   '//
   lngSize = 0
   strQuery = "select t01.sem_menu,"
   strQuery = strQuery & " t01.sem_description"
   strQuery = strQuery & " from lics_sec_menu t01"
   strQuery = strQuery & " order by t01.sem_menu asc"
   strReturn = objSelection.Execute("MENULINK", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the link option data
   '//
   lngSize = 0
   strQuery = "select t01.seo_option,"
   strQuery = strQuery & " t01.seo_description"
   strQuery = strQuery & " from lics_sec_option t01"
   strQuery = strQuery & " order by t01.seo_option asc"
   strReturn = objSelection.Execute("OPTIONLINK", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SemMenu", "")
   call objForm.AddField("DTA_SemDescription", "")

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
   dim lnglink

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Insert the menu
   '//
   strStatement = "lics_security_configuration.insert_menu("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SemMenu").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SemDescription").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Insert the menu links
   '//
   lngLink = 0
   lngCount = clng(objForm.Fields("DET_LinkMenuCount").Value)
   for i = 1 to lngCount
      lngLink = lngLink + 1
      strStatement = "lics_security_configuration.insert_menu_link("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SemMenu").Value) & "',"
      strStatement = strStatement & cstr(lngLink) & ","
      strStatement = strStatement & "'*MNU',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_LinkMenu" & i).Value) & "'"
      strStatement = strStatement & ")"
      strReturn = objFunction.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next
   lngCount = clng(objForm.Fields("DET_LinkOptionCount").Value)
   for i = 1 to lngCount
      lngLink = lngLink + 1
      strStatement = "lics_security_configuration.insert_menu_link("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SemMenu").Value) & "',"
      strStatement = strStatement & cstr(lngLink) & ","
      strStatement = strStatement & "'*OPT',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_LinkOption" & i).Value) & "'"
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the menu data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sem_menu,"
   strQuery = strQuery & " t01.sem_description"
   strQuery = strQuery & " from lics_sec_menu t01"
   strQuery = strQuery & " where t01.sem_menu = '" & objForm.Fields("DTA_SemMenu").Value & "'"
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
   strQuery = strQuery & " where t01.sem_menu != '" & objForm.Fields("DTA_SemMenu").Value & "'"
   strQuery = strQuery & " and t01.sem_menu not in (select sel_link from lics_sec_link where sel_menu = '" & objForm.Fields("DTA_SemMenu").Value & "' and sel_type = '*MNU')"
   strQuery = strQuery & " order by t01.sem_menu asc"
   strReturn = objSelection.Execute("MENULINK", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the option data
   '//
   lngSize = 0
   strQuery = "select t01.seo_option,"
   strQuery = strQuery & " t01.seo_description"
   strQuery = strQuery & " from lics_sec_option t01"
   strQuery = strQuery & " where t01.seo_option not in (select sel_link from lics_sec_link where sel_menu = '" & objForm.Fields("DTA_SemMenu").Value & "' and sel_type = '*OPT')"
   strQuery = strQuery & " order by t01.seo_option asc"
   strReturn = objSelection.Execute("OPTIONLINK", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the link menu data
   '//
   lngSize = 0
   strQuery = "select t02.sem_menu,"
   strQuery = strQuery & " t02.sem_description"
   strQuery = strQuery & " from lics_sec_link t01, lics_sec_menu t02"
   strQuery = strQuery & " where t01.sel_link = t02.sem_menu"
   strQuery = strQuery & " and t01.sel_menu = '" & objForm.Fields("DTA_SemMenu").Value & "'"
   strQuery = strQuery & " and t01.sel_type = '*MNU'"
   strQuery = strQuery & " order by t01.sel_sequence asc"
   strReturn = objSelection.Execute("MENUDETAIL", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the link option data
   '//
   lngSize = 0
   strQuery = "select t02.seo_option,"
   strQuery = strQuery & " t02.seo_description"
   strQuery = strQuery & " from lics_sec_link t01, lics_sec_option t02"
   strQuery = strQuery & " where t01.sel_link = t02.seo_option"
   strQuery = strQuery & " and t01.sel_menu = '" & objForm.Fields("DTA_SemMenu").Value & "'"
   strQuery = strQuery & " and t01.sel_type = '*OPT'"
   strQuery = strQuery & " order by t01.sel_sequence asc"
   strReturn = objSelection.Execute("OPTIONDETAIL", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_SemDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))

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
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Update the menu
   '//
   strStatement = "lics_security_configuration.update_menu("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SemMenu").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SemDescription").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Clear the menu links
   '//
   strStatement = "lics_security_configuration.clear_menu_links("
   strStatement = strStatement & "'" & objForm.Fields("DTA_SemMenu").Value & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Insert the menu links
   '//
   lngLink = 0
   lngCount = clng(objForm.Fields("DET_LinkMenuCount").Value)
   for i = 1 to lngCount
      lngLink = lngLink + 1
      strStatement = "lics_security_configuration.insert_menu_link("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SemMenu").Value) & "',"
      strStatement = strStatement & cstr(lngLink) & ","
      strStatement = strStatement & "'*MNU',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_LinkMenu" & i).Value) & "'"
      strStatement = strStatement & ")"
      strReturn = objFunction.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next
   lngCount = clng(objForm.Fields("DET_LinkOptionCount").Value)
   for i = 1 to lngCount
      lngLink = lngLink + 1
      strStatement = "lics_security_configuration.insert_menu_link("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SemMenu").Value) & "',"
      strStatement = strStatement & cstr(lngLink) & ","
      strStatement = strStatement & "'*OPT',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_LinkOption" & i).Value) & "'"
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the menu data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.sem_menu,"
   strQuery = strQuery & " t01.sem_description"
   strQuery = strQuery & " from lics_sec_menu t01"
   strQuery = strQuery & " where t01.sem_menu = '" & objForm.Fields("DTA_SemMenu").Value & "'"
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
   call objForm.AddField("DTA_SemMenu", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_SemDescription", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))

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
   '// Delete the menu
   '//
   strStatement = "lics_security_configuration.delete_menu("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SemMenu").Value) & "'"
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
<!--#include file="ics_sec_mnu_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_sec_mnu_configuration_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_sec_mnu_configuration_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_sec_mnu_configuration_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->