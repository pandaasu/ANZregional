<%@  language="VBScript" %>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_view_excel.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : May 2005                                           //
'// Text    : This script implements the view excel              //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim j
   dim strReturn
   dim objForm
   dim objSecurity
   dim objQuery

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurity()
   if strReturn = "*OK" then

      '//
      '// Get the form data
      '//
      GetForm()

      '//
      '// Process the request
      '//
      call ProcessRequest

   end if

   '//
   '// Paint response
   '//
   call PaintResponse
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objQuery = nothing

'/////////////////////////////
'// Process request routine //
'/////////////////////////////
sub ProcessRequest

   dim strQuery
   dim lngcount

   '//
   '// Create the query object
   '//
   set objQuery = Server.CreateObject("ics_query2.ICS_QUERY")
   objQuery.Security(objSecurity)

   '//
   '// Retrieve view data (first 100 rows)
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
   Response.Buffer = true
   Response.AddHeader "content-disposition", "attachment; filename=" & objForm.Fields().Item("SRC_Name") & ".xls"
   Response.ContentType = "application/vnd.ms-excel"

end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="ics_view_excel.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->
