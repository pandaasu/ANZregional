<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes TP system                                   //
'// Script  : hermes_cn_accrual_post_excel.asp                   //
'// Author  : ISI China                                          //
'// Date    : July 2007                                          //
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
   '// Retrieve accrual data
   '//
   '//strQuery = "select"
   '//strQuery = strQuery & " t01.tp_period,"
   '//strQuery = strQuery & " t01.tp_id,"
   '//strQuery = strQuery & " t01.tp_desc, "
   '//strQuery = strQuery & " t01.tp_grp, "
   '//strQuery = strQuery & " t01.tp_cust_level,"
   '//strQuery = strQuery & " t01.tp_matl_level,"
   '//strQuery = strQuery & " t01.tp_type_code,"
   '//strQuery = strQuery & " to_char(t01.tp_bgt,'fm999999990.00'), "
   '//strQuery = strQuery & " to_char(t01.tp_clm,'fm999999990.00'), "
   '//strQuery = strQuery & " to_char(t01.tp_curr_accr,'fm999999990.00'), "
   '//strQuery = strQuery & " to_char(t01.tp_rvsl,'fm999999990.00'), "
   '//strQuery = strQuery & " to_char(t01.tp_bgt_lupdt,'YYYY.MM.DD'), "
   '//strQuery = strQuery & " to_char(t01.tp_accr_lupdt,'YYYY.MM.DD'), "
   '//strQuery = strQuery & " t01.tp_bgt_stat, "
   '//strQuery = strQuery & " t01.tp_user_sec "
   '//strQuery = strQuery & " from tp_budget t01, tp_com t02, tp_type t03, tp_user_sec t04"
   '//strQuery = strQuery & " where t01.tp_com_code = t02.tpc_com_code"
   '//strQuery = strQuery & " and t01.tp_period = t02.tpc_curr_prd"
   '//strQuery = strQuery & " and t01.tp_com_code = '" & objSecurity.FixString(objForm.Fields().Item("DTA_TpaComCode")) & "'"
   '//strQuery = strQuery & " and t01.tp_com_code = t03.tp_com_code (+)"    
   '//strQuery = strQuery & " and t01.tp_type_code = t03.tp_type_code (+)"
   '//strQuery = strQuery & " and t01.tp_bgt_stat = 'X'"
   '//strQuery = strQuery & " and t01.tp_com_code = t04.tp_com_code"    
   '//strQuery = strQuery & " and t04.tp_user_func = 'ACCRPST'"   
   '//strQuery = strQuery & " and '" & strUser & "' = t04.tp_user" 
   '//strQuery = strQuery & " order by t01.tp_id asc "
   
    strQuery = strQuery & " select * "
	strQuery = strQuery & "   from (select rownum numofrow, t02.* "
	strQuery = strQuery & "           from (select t01.tp_period, "
	strQuery = strQuery & "                        t01.tp_id, "
	strQuery = strQuery & "                        t01.tp_desc, "
	strQuery = strQuery & "                        t01.tp_grp, "
	strQuery = strQuery & "                        t01.tp_cust_level, "
	strQuery = strQuery & "                        t01.tp_division, "
	strQuery = strQuery & "                        t01.tp_matl_level, "
	strQuery = strQuery & "                        t01.tp_type_code, "
	strQuery = strQuery & "                        to_char(t01.tp_bgt, 'fm999999990.00'), "
	strQuery = strQuery & "                        to_char(t01.tp_clm, 'fm999999990.00'), "
	strQuery = strQuery & "                        to_char(t01.tp_curr_accr, 'fm999999990.00'), "
	strQuery = strQuery & "                        to_char(t01.tp_rvsl, 'fm999999990.00'), "
	strQuery = strQuery & "                        to_char(t01.tp_bgt_lupdt, 'YYYY.MM.DD'), "
	strQuery = strQuery & "                        to_char(t01.tp_accr_lupdt, 'YYYY.MM.DD'), "
	strQuery = strQuery & "                        t01.tp_bgt_stat, "
	strQuery = strQuery & "                        t01.tp_user_sec "
	strQuery = strQuery & "                   from tp_budget t01, tp_com t02, tp_type t03, tp_user_sec t04 "
	strQuery = strQuery & "                  where t01.tp_com_code = t02.tpc_com_code "
	strQuery = strQuery & "                    and t01.tp_period = t02.tpc_curr_prd "
	strQuery = strQuery & "                    and t01.tp_com_code = '" & objSecurity.FixString(objForm.Fields().Item("DTA_TpaComCode")) & "'"
	strQuery = strQuery & "                    and t01.tp_com_code = t04.tp_com_code"    
	strQuery = strQuery & "                    and t04.tp_user_func = 'ACCRPST'"   
	strQuery = strQuery & "                    and '" & strUser & "' = t04.tp_user" 
	strQuery = strQuery & "                    and t01.tp_com_code = t03.tp_com_code(+) "
	strQuery = strQuery & "                    and t01.tp_type_code = t03.tp_type_code(+) "
	strQuery = strQuery & "                   and t01.tp_bgt_stat = 'X' "
	strQuery = strQuery & "                  order by t01.tp_id) t02) "
	strQuery = strQuery & "  where numofrow between (50000 * to_number('" & objSecurity.FixString(objForm.Fields().Item("DTA_FILENUM")) & "') + 1) and (50000 * (to_number('" & objSecurity.FixString(objForm.Fields().Item("DTA_FILENUM")) & "') + 1)) "

   
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
   Response.AddHeader "content-disposition", "attachment; filename=" & strUser & ".xls"

end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="hermes_cn_accrual_post_excel.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->