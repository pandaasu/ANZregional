<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes TP system				                     //
'// Script  : hermes_opbr_excel.as                             //
'// Author  : Steve Gregan, Plus lee                             //
'// Date    : April 2006                                         //
'// Text    : This script implements the TP opbr		         //
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
    '// Retrieve opbr data
    '//
	strQuery = "select"
	strQuery = strQuery & " t01.TPB_BR_VRSN,"
	strQuery = strQuery & " t01.TPB_COM_CODE,"
	strQuery = strQuery & " t01.TPB_TP_TYPE,"
	strQuery = strQuery & " t01.TPB_CUST_LEVEL,"
	strQuery = strQuery & " t01.TPB_MATL_LEVEL,"
	strQuery = strQuery & " t01.TPB_PERIOD,"
	strQuery = strQuery & " t01.TPB_BR_VALUE"
	strQuery = strQuery & " from TP_BR t01"
	strQuery = strQuery & " where t01.tpb_com_code = '" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "'"
       strQuery = strQuery & "   and t01.tpb_period >= substrb('" & objSecurity.FixString(objForm.Fields("DTA_TpaBRSdt").Value) & "',1,6)"
       strQuery = strQuery & "   and t01.tpb_period <= substrb('" & objSecurity.FixString(objForm.Fields("DTA_TpaBREnd").Value) & "',1,6)"
	strQuery = strQuery & " order by t01.tpb_br_vrsn asc "
	
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
<!--#include file="hermes_opbr_excel_BR.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->