<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes                                             //
'// Script  : hermes_cn_period_close.asp                         //
'// Author  : ISI China                                          //
'// Date    : July 2007                                          //
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
   dim strUser
  
   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "hermes_cn_period_close.asp"
   strHeading = "Period Close"

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
   '// Get the logon ID
   '//
   strUser = GetUser()

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
         case "CREATE"
            call ProcessCreate
         case "SEND"
            call ProcessSend
         case else
			      strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
      end select
   end if
dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity


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
	strQuery = strQuery & " WHERE t01.tpc_com_code = '135' "
	
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
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

'////////////////////////////
'// Process Create routine //
'////////////////////////////
sub ProcessCreate()

   dim strStatement
   dim lngIndex
   dim lngCount
   dim strUserSec
   
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
	
  strStatement = "hermes_post.create_reversal('" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "','" & strUser & "')"
	on error resume next
	strReturn = objFunction.Execute(strStatement)

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
		strReturn = "*OK"
	else 
		strMode = "FATAL"
	end if
		
end sub

'////////////////////////////
'// Process Send routine //
'////////////////////////////
sub ProcessSend()

	dim strStatement

	set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
	set objFunction.Security = objSecurity

	'// let's calculate the accrual value   
	strMode = "SELECT"
	
  strStatement = "hermes_post.send_reversal('" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "','" & strUser & "')"
	  
	on error resume next
	strReturn = objFunction.Execute(strStatement)
'	  strReturn = strStatement
  if strReturn <> "*OK" then
    strError = FormatError(strReturn)
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
sub PaintSelect()%>
<!--#include file="hermes_cn_period_close.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->
<%
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objFunction = nothing
%>