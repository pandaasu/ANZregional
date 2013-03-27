<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes TP system                                   //
'// Script  : hermes_cn_alloc_excel.asp                          //
'// Author  : ISI China                                          //
'// Date    : July 2007                                          //
'// Text    : This script implements the TP Alloc                //
'//            excel                                             //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim j
   dim strReturn
   dim objForm
   dim objSecurity
   dim objSelection
   dim strUser

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurity()
   strUser = GetUser()
   
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
   set objSelection = nothing

'/////////////////////////////
'// Process request routine //
'/////////////////////////////
sub ProcessRequest

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve allocation data
   '//
   strQuery = "select"
   strQuery = strQuery & " t01.tp_grp, "
   strQuery = strQuery & " t01.tp_matl_level,"
   strQuery = strQuery & " to_char(t01.tp_pct,'fm999999990.00'), "
   strQuery = strQuery & " to_char(t01.tp_pct_lupdt,'YYYY.MM.DD') "
   strQuery = strQuery & " from tp_alloc t01, tp_com t02"
   strQuery = strQuery & " where t01.tp_com_code = t02.tpc_com_code"
   strQuery = strQuery & " and t01.tp_com_code = '" & objSecurity.FixString(objForm.Fields().Item("DTA_TpaComCode")) & "'"
   strQuery = strQuery & " and exists (select * "
   strQuery = strQuery & "               from tp_user_sec t04 "
   strQuery = strQuery & "              where t04.tp_com_code = t01.tp_com_code "    
   strQuery = strQuery & "                and t04.tp_user_func = 'ALLLOAD' "   
   strQuery = strQuery & "                and t04.tp_user = '" & strUser & "')"
   strQuery = strQuery & " order by t01.tp_grp, t01.tp_matl_level asc "
   
   strReturn = objSelection.Execute("DATA", strQuery, 0)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Set the response
   '//
   Response.Buffer = true
   Response.ContentType = "application/vnd.ms-excel"
   Response.AddHeader "content-disposition", "attachment; filename=tp_alloc.xls"

end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="hermes_cn_alloc_excel.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->