<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes TP system				                     //
'// Script  : hermes_budget_excel.as                             //
'// Author  : Steve Gregan, Plus lee                             //
'// Date    : April 2006                                         //
'// Text    : This script implements the TP Budget		         //
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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

    '//
    '// Retrieve budget data
    '//
	strQuery = "select"
	strQuery = strQuery & " t01.tph_com_code,"
	strQuery = strQuery & " t01.tph_period,"
	strQuery = strQuery & " t01.tph_tp_id,"
	strQuery = strQuery & " t01.tph_tp_desc,"
	strQuery = strQuery & " t01.tph_cust_level,"
	strQuery = strQuery & " t01.tph_matl_level,"
	strQuery = strQuery & " t01.tph_tp_type,"
	strQuery = strQuery & " to_char(t01.tph_bgt,'fm999999990.00'), "
	strQuery = strQuery & " to_char(t01.tph_act,'fm999999990.00'), "
	strQuery = strQuery & " to_char(t01.tph_rvsl,'fm999999990.00'), "
	strQuery = strQuery & " to_char(t01.tph_curr_accr,'fm999999990.00'), "
	strQuery = strQuery & " to_char(t01.tph_new_accr,'fm999999990.00'), "
	strQuery = strQuery & " to_char(t01.tph_bgt_lupdt,'YYYY.MM.DD'), "
	strQuery = strQuery & " to_char(t01.tph_act_lupdt,'YYYY.MM.DD'), "
	strQuery = strQuery & " to_char(t01.tph_accr_lupdt,'YYYY.MM.DD'), "
	strQuery = strQuery & " t01.tph_cncl_flag "
	strQuery = strQuery & " from tp_header t01"
	strQuery = strQuery & " where t01.tph_com_code = '" & objSecurity.FixString(objForm.Fields().Item("DTA_TpaComCode")) & "'"
	strQuery = strQuery & "		and t01.tph_period = '" & objSecurity.FixString(objForm.Fields().Item("DTA_TpaCurrPrd")) & "'"
	strQuery = strQuery & " order by t01.tph_tp_id asc "
	
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
   Response.AddHeader "content-disposition", "attachment; filename=" & objForm.Fields().Item("DTA_TpaComCode") & "-" & objForm.Fields().Item("DTA_TpaCurrPrd") & ".xls"

end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="hermes_budget_excel.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->