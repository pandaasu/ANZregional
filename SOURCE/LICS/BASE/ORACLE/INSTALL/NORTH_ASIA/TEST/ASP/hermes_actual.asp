<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes                                             //
'// Script  : hermes_actual.asp                                  //
'// Author  : Plus Lee			                                 //
'// Date    : March 2006                                         //
'// Text    : This script implements the actuals maintenance     //
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
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "hermes_actual.asp"
   strHeading = "Actuals Maintenance"

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
   strReturn = GetSecurity()
   if strReturn = "*OK" then

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
         case "UPDATE"
            call ProcessUpdate
         case else
			strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   select case strMode
      case "FATAL"
         call PaintFatal
      case "SELECT"
         call PaintSelect
   end select
 
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
   '// Retrieve the routing list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.tpa_sap_doc_type,"
   strQuery = strQuery & " t01.tpa_sap_doc_no,"
   strQuery = strQuery & " t01.tpa_sap_doc_ln,"
   strQuery = strQuery & " t01.tpa_period,"
   strQuery = strQuery & " t01.tpa_cust_code,"
   strQuery = strQuery & " t01.tpa_matl_code,"
   strQuery = strQuery & " t01.tpa_tp_id,"
   strQuery = strQuery & " to_char(t01.tpa_act,'fm999999990.00')"
   strQuery = strQuery & " from tp_actuals t01, tp_com t02"
   strQuery = strQuery & " where t01.tpa_com_code = t02.tpc_com_code"
   strQuery = strQuery & " and t01.tpa_period = t02.tpc_curr_prd"
   strQuery = strQuery & " and t01.tpa_com_code = '" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "'"
   strQuery = strQuery & " and (t01.tpa_sap_doc_type = 'ZCRF' or t01.tpa_sap_doc_type = 'ZDRF') "	'ZCRF/ZDRF is for on-invoice credit memo
   strQuery = strQuery & " and not exists (SELECT tph_tp_id FROM tp_header t03"
   strQuery = strQuery & "									WHERE t03.tph_com_code = t01.tpa_com_code "
   strQuery = strQuery & "										and t03.tph_period = t01.tpa_period "
   strQuery = strQuery & "										and t03.tph_cncl_flag <> 'Y' "   
   strQuery = strQuery & "										and t03.tph_cust_level = t01.tpa_cust_code "
   strQuery = strQuery & "										and t03.tph_matl_level = t01.tpa_matl_code "
   strQuery = strQuery & "										and t03.tph_tp_id = t01.tpa_tp_id) "
   strQuery = strQuery & " order by t01.tpa_sap_doc_type asc, t01.tpa_sap_doc_no asc, t01.tpa_sap_doc_ln asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   
   'strMode = "*TEST"
   
   if strReturn <> "*OK" then
      strMode = "FATAL"
      'strReturn = strQuery
   end if

end sub

'////////////////////////////
'// Process update routine //
'////////////////////////////
sub ProcessUpdate()

   dim strStatement
   dim lngCount


   '//
   '// Create the selection object
   '//
   'set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   'set objSelection.Security = objSecurity

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

'for testing
'strMode = "FATAL"
'strReturn = "Update Error!"
'exit sub


   '//
   '// Update the actuals
   '//
   strMode = "SELECT"
   
   lngCount = clng(objForm.Fields("DET_Count").Value)
   for i = 0 to lngCount - 1
      strStatement = "hermes_act_maintenance.update_actual("
'	  strStatement = strStatement & "hehe"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_TpaSapDocType" & i).Value) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_TpaSapDocNo" & i).Value) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_TpaSapDocLn" & i).Value) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_TpaTpId" & i).Value) & "'"
      strStatement = strStatement & ")"
	  
	  on error resume next
	  strReturn = objFunction.Execute(strStatement)
'	  strReturn = strStatement
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
		 strMode = "FATAL"
         exit for
      end if
   next

   '//
   '// Set the mode
   '//
	if strMode = "SELECT" then
		call ProcessSelect
	end if
		
end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint prompt routine //
'//////////////////////////
sub PaintSelect()%>
<!--#include file="hermes_actual.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->