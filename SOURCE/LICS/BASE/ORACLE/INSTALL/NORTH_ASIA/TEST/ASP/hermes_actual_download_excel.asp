<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes TP system				                     //
'// Script  : hermes_actual_download_excel.as                             //
'// Author  : Steve Gregan, Plus lee                             //
'// Date    : April 2006                                         //
'// Text    : This script implements the TP actual		         //
'//            excel		                                     //
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
   set objSelection = nothing

'/////////////////////////////
'// Process request routine //
'/////////////////////////////
sub ProcessRequest

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

    '//
    '// Retrieve actual data
    '//
	strQuery = "select"
	strQuery = strQuery & " t01.tpa_com_code,"
	strQuery = strQuery & " t01.tpa_period,"
	strQuery = strQuery & " t01.tpa_tp_id,"
	strQuery = strQuery & " t01.tpa_cust_code,"
	strQuery = strQuery & " t01.tpa_matl_code,"
	strQuery = strQuery & " to_char(t01.tpa_act,'fm999999990.00') "
	strQuery = strQuery & " from tp_actuals t01"
	strQuery = strQuery & " where t01.tpa_com_code = '" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "'"
	strQuery = strQuery & "		and t01.tpa_period = '" & objSecurity.FixString(objForm.Fields("DTA_TpaCurrPrd").Value) & "'"
	strQuery = strQuery & " order by t01.tpa_tp_id asc "
	
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
   Response.AddHeader "content-disposition", "attachment; filename=" & objForm.Fields("DTA_TpaComCode").Value & "-" & objForm.Fields("DTA_TpaCurrPrd").Value & ".xls"

end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="hermes_actual_download_excel.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->