<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_view_documentation.asp                         //
'// Author  : Steve Gregan                                       //
'// Date    : May 2005                                           //
'// Text    : This script implements the view documentation      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim j
   dim strBase
   dim strTarget
   dim strStatus
   dim strCharset
   dim strReturn
   dim strMessage
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection
   dim objQuery
   dim objProcedure
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_view_documentation.asp"
   strHeading = "View Documentation"

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
   strReturn = GetSecurityCheck("LAD_VEW_ENQUIRY")
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else

      '//
      '// Get the form data
      '//
      GetForm()
      strMode = objForm.Fields().Item("Mode")

      '//
      '// Process the request
      '//
      call ProcessRequest

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
   set objQuery = nothing
   set objProcedure = nothing
   set objFunction = nothing

'/////////////////////////////
'// Process request routine //
'/////////////////////////////
sub ProcessRequest

   dim strQuery
   dim strStatement
   dim lngcount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Create the query object
   '//
   set objQuery = Server.CreateObject("ics_query2.ICS_QUERY")
   objQuery.Security(objSecurity)

   '//
   '// Retrieve view list
   '//
   strQuery = "select view_name from dba_views"
   strQuery = strQuery & " where owner = '" & objForm.Fields().Item("SRC_Owner") & "'"
   strQuery = strQuery & " order by view_name asc"
   strReturn = objSelection.Execute("LIST", strQuery, 0)
   if strReturn <> "*OK" then
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Retrieve the view source when required
   '//
   if objForm.Fields().Item("SRC_Name") <> "" then

      '//
      '// Retrieve the view source when required
      '//
      if objForm.Fields().Item("Mode") <> "DATA" then

         '//
         '// Retrieve the view source
         '//
         strStatement = "lics_documentation.retrieve_view_source("
         strStatement = strStatement & "'" & objForm.Fields().Item("SRC_Owner") & "',"
         strStatement = strStatement & "'" & objForm.Fields().Item("SRC_Name") & "')"
         strReturn = objProcedure.Execute(strStatement)
         if strReturn <> "*OK" then
            strReturn = FormatError(strReturn)
            response.write()
            response.end
            exit sub
         end if

         '//
         '// Retrieve source text
         '//
         strQuery = "select t01.dat_record from lics_temp t01 order by t01.dat_dta_seq asc"
         strReturn = objSelection.Execute("SOURCE", strQuery, 0)
         if strReturn <> "*OK" then
            strReturn = FormatError(strReturn)
            exit sub
         end if

      else

         '//
         '// Retrieve view data
         '//
         lngCount = 100
         if objForm.Fields().Item("SRC_Rows") = "A" then
            lngCount = 0
         end if
         strQuery = "select * from " & objForm.Fields().Item("SRC_Owner") & "." & objForm.Fields().Item("SRC_Name")
         if trim(objForm.Fields().Item("SRC_Where")) <> "" then
            strQuery = strQuery & " where " & objForm.Fields().Item("SRC_Where")
            if lngCount = 100 then
                strQuery = strQuery & " and ROWNUM <= " & lngCount & " ORDER BY ROWNUM ASC"
            end if
         else 
            if lngCount = 100 then
                strQuery = strQuery & " where ROWNUM <= " & lngCount & " ORDER BY ROWNUM ASC"
            end if
         end if
         strReturn = objQuery.Execute("DATA", strQuery, lngCount)
         if strReturn <> "*OK" then
            strReturn = FormatError(strReturn)
            exit sub
         end if

      end if

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
<!--#include file="ics_view_documentation.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->