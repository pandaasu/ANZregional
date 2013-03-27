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
      strMode = objForm.Fields().Item("Mode")

      '//
      '// Process the form data
      '//
      select case strMode
         case "SEARCH"
            call ProcessSearch
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
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
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Perform the search when required
   '//
   strMessage = ""
   if objForm.Fields().Item("DTA_Interface") <> "" or objForm.Fields().Item("DTA_FileName") <> "" then

      '//
      '// Create the function object
      '//
      set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
      objFunction.Security(objSecurity)

      '//
      '// Submit the file search
      '//
      if objForm.Fields().Item("DTA_Interface") <> "" then
         strFileName = objSecurity.FixString(objForm.Fields().Item("DTA_Interface"))
      else
         strFileName = objSecurity.FixString(objForm.Fields().Item("DTA_FileName"))
      end if
      strStatement = "lics_file_search.execute('" & strFileName & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SearchString")) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SearchStrTime")) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_SearchEndTime")) & "')"
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