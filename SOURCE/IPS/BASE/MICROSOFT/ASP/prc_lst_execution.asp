<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : prc_lst_execution.asp                              //
'// Author  : Steve Gregan                                       //
'// Date    : December 2008                                      //
'// Text    : This script implements the price list execution    //
'//           functionality                                      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim strBase
   dim strUser
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
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "prc_lst_execution.asp"
   strHeading = "Price List Execution"
   strError = ""

   '//
   '// Get the base/user string
   '//
   strBase = GetBase()
   strUser = GetUser()

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
   strReturn = GetSecurityCheck("PRC_LST_EXECUTION")
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
   '// Retrieve the sysdate date
   '//
   lngSize = 0
   strQuery = "select to_char(sysdate,'yyyymmdd') from dual"
   strReturn = objSelection.Execute("DATE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Retrieve the load type list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.report_id) as report_id,"
   strQuery = strQuery & " t01.report_name"
   strQuery = strQuery & " from report t01"
   strQuery = strQuery & " where t01.status = 'V'"
   strQuery = strQuery & " order by t01.report_name asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
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
<!--#include file="prc_lst_execution.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->