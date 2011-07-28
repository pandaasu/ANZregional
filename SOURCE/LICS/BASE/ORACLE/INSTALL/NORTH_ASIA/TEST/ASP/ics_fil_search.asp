<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_fil_search.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : July 2005                                          //
'// Text    : This script implements the file search             //
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
   dim strMessage
   dim objForm
   dim objSecurity
   dim objSelection
   dim objFunction

   '//
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "ics_fil_search.asp"
   strHeading = "File Search"

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
   strReturn = GetSecurityCheck("ICS_FIL_SEARCH")
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
         case "SEARCH"
            call ProcessSearch
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   if strMode = "FATAL" then
      call PaintFatal
   else
      call PaintResponse
   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objFunction = nothing

'////////////////////////////
'// Process search routine //
'////////////////////////////
sub ProcessSearch()

   dim strQuery
   dim strStatement
   dim strFileName

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the interface selection
   '//
   strQuery = "select t01.int_interface,"
   strQuery = strQuery & " t01.int_description"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " order by t01.int_interface asc"
   strReturn = objSelection.Execute("INTERFACE", strQuery, 0)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Perform the search when required
   '//
   strMessage = ""
   if objForm.Fields("DTA_Interface").Value <> "" or objForm.Fields("DTA_FileName").Value <> "" then

      '//
      '// Create the function object
      '//
      set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
      set objFunction.Security = objSecurity

      '//
      '// Submit the file search
      '//
      if objForm.Fields("DTA_Interface").Value <> "" then
         strFileName = objSecurity.FixString(objForm.Fields("DTA_Interface").Value)
      else
         strFileName = objSecurity.FixString(objForm.Fields("DTA_FileName").Value)
      end if
      strStatement = "lics_file_search.execute('" & strFileName & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SearchString").Value) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SearchStrTime").Value) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SearchEndTime").Value) & "')"
      strMessage = objFunction.Execute(strStatement)

   end if

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="ics_fil_search.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->