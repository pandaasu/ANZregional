<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes                                             //
'// Script  : hermes_accrual.asp                                 //
'// Author  : Plus Lee			                                 //
'// Date    : April 2006                                         //
'// Text    : This script implements the accrual calculation     //
'//           and posting                                        //
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
   dim objProcedure
   

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "hermes_accrual.asp"
   strHeading = "Accrual Calculation and Posting"

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
      strMode = objForm.Fields().Item("Mode")

      '//
      '// Process the form data
      '//
      select case strMode
         case "SELECT"
            call ProcessSelect
         case "CREATE"
			call ProcessCreate
         case "SEND"
            call ProcessSend
         case else
			strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
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
  'strQuery = strQuery & " t01.tpr_com_code, "
	'strQuery = strQuery & " t01.tpr_tp_id, "
	'strQuery = strQuery & " t01.tpr_cust_level, "
	'strQuery = strQuery & " t01.tpr_matl_level, "
	'strQuery = strQuery & " t01.tpr_usg_code, "
	'strQuery = strQuery & " t01.tpr_tp_acct_code, "
	'strQuery = strQuery & " t01.tpr_accr_value, "
	'strQuery = strQuery & " t01.tpr_cost_center, "
	'strQuery = strQuery & " t01.tpr_tp_desc "
	'strQuery = strQuery & " FROM tp_accruals t01 "
	'strQuery = strQuery & " Order by tpr_tp_id asc "
	
	strQuery = strQuery & " 		t01.tph_period,	"
	strQuery = strQuery & " 		sum(t01.tph_curr_accr)	"
	strQuery = strQuery & " 	FROM tp_header t01, tp_com t02	"
	strQuery = strQuery & " 	WHERE T01.TPH_COM_CODE = t02.tpc_com_code	"
	strQuery = strQuery & " 		and T01.TPH_COM_CODE = '" & objSecurity.FixString(objForm.Fields().Item("DTA_TpaComCode")) & "' "
	strQuery = strQuery & " 	  and t01.tph_period = t02.tpc_curr_prd	"
	strQuery = strQuery & "			AND T01.TPH_CNCL_FLAG <> 'Y' "
	strQuery = strQuery & " 	GROUP BY t01.tph_period	"
	
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   'strReturn = strQuery
   'strMode = "*TEST"
   
   if strReturn <> "*OK" then
      strMode = "FATAL"
      'strReturn = strQuery
   end if

end sub

'////////////////////////////
'// Process Create routine //
'////////////////////////////
sub ProcessCreate()

   dim strStatement
   dim lngIndex
   dim lngCount
   
   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

	'// let's calculate the accrual value   
	call objProcedure.Execute("lics_form.clear_form")	'clear the lics_form to store error messages  
	
	strStatement = "hermes_tp_accrual.create_accr('" & objSecurity.FixString(objForm.Fields().Item("DTA_TpaComCode")) & "') "	
	on error resume next
	strReturn = objFunction.Execute(strStatement)
	'  strReturn = strStatement
    if strReturn <> "*OK" then
       strError = FormatError(strReturn)
	   strMode = "FATAL"
	   exit sub
    end if

	'//
	'// Output any errors from the procedure
	'//
	strReturn = ""
	lngCount = clng(objFunction.Execute("lics_form.get_array_count('VAR_ERROR')"))
	for lngIndex = 1 to lngCount
	   strReturn = strReturn & objFunction.Execute("lics_form.get_array('VAR_ERROR'," & lngIndex & ")")
	   if lngIndex < lngCount then
	      strReturn = strReturn & "<br>"
	   end if
	next

	'//
	'// Set the mode
	'//
	if strReturn = "" then
		strMode = "SELECT"
		call ProcessSelect
	else 
		strMode = "FATAL"
	end if
		
end sub

'////////////////////////////
'// Process Send routine //
'////////////////////////////
sub ProcessSend()

	dim strStatement

	set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
	objFunction.Security(objSecurity)

	'// let's calculate the accrual value   
	strMode = "SELECT"
	
    strStatement = "hermes_tp_accrual.send_accr('" & objSecurity.FixString(objForm.Fields().Item("DTA_TpaComCode")) & "') "
	  
	on error resume next
	strReturn = objFunction.Execute(strStatement)
'	  strReturn = strStatement
    if strReturn <> "*OK" then
       strError = FormatError(strReturn)
	   strMode = "FATAL"
    end if

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
<!--#include file="hermes_accrual.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->