<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes                                             //
'// Script  : hermes_com_info.asp                                //
'// Author  : Plus Lee			                                 //
'// Date    : April 2006                                         //
'// Text    : This script closes the current period              //
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
   strTarget = "hermes_com_info.asp"
   strHeading = "Company Information"

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
         case "DISPLAY"
            call ProcessDisplay
         case "CLOSE"
			call ProcessClose
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
      case "DISPLAY"
         call PaintDisplay
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objFunction = nothing

'////////////////////////////
'// Process display routine //
'////////////////////////////
sub ProcessDisplay()

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
   strQuery = strQuery & " t01.tpc_com_code, "
	strQuery = strQuery & " t01.tpc_curr_prd, "
	strQuery = strQuery & " t01.tpc_accr_acct_code, "
	strQuery = strQuery & " t01.tpc_tax_code, "
	strQuery = strQuery & " t01.tpc_currency, "
	strQuery = strQuery & " t01.tpc_plant "
	strQuery = strQuery & " FROM tp_com t01 "
	strQuery = strQuery & " WHERE t01.tpc_com_code = '" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "' "
	
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   
   'strMode = "*TEST"
   
   if strReturn <> "*OK" then
      strMode = "FATAL"
      'strReturn = strQuery
   end if

end sub

'////////////////////////////
'// Process Close routine //
'////////////////////////////
sub ProcessClose()

   dim strStatement
   dim lngIndex
   dim lngCount
   
   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

	'// let's calculate the accrual value   
	call objProcedure.Execute("lics_form.clear_form")	'clear the lics_form to store error messages  
	
	strStatement = "hermes_com_info.close_curr_prd('" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "') "	
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
		strMode = "DISPLAY"
		call ProcessDisplay
	else 
		strMode = "FATAL"
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
sub PaintDisplay%>
<!--#include file="hermes_com_info.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->