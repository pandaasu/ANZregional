<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes                                             //
'// Script  : hermes_actual_upload.asp                           //
'// Author  : ISI China                                          //
'// Date    : May 2006	                                         //
'// Text    : This script implements the Cash discount upload    //
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
   dim strError
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection
   dim objProcedure
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "hermes_actual_upload.asp"
   strHeading = "Cash Discount Upload"

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
         case "LOAD"
            call ProcessImportLoad
         case "ACCEPT"
            call ProcessImportAccept
         case else
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   select case strMode
      case "FATAL"
         call PaintFatal
      case "LOAD"
         call PaintActual
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objProcedure = nothing
   set objFunction = nothing

'/////////////////////////////////
'// Process import load routine //
'/////////////////////////////////
sub ProcessImportLoad()


   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the routing list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.tpca_com_code,"
   strQuery = strQuery & " t01.tpca_period,"
   strQuery = strQuery & " t01.tpca_cust_code,"
   strQuery = strQuery & " t01.tpca_matl_code,"
   strQuery = strQuery & " t01.tpca_tp_type,"
   strQuery = strQuery & " to_char(t01.tpca_act,'fm999999990.00'), "
   strQuery = strQuery & " to_char(t01.tpca_act_lupdt,'YYYY.MM.DD') "
   strQuery = strQuery & " from tp_cash t01, tp_com t02"
   strQuery = strQuery & " where t01.tpca_com_code = t02.tpc_com_code"
   strQuery = strQuery & " and t01.tpca_period = t02.tpc_curr_prd"
   strQuery = strQuery & " and t01.tpca_com_code = '" & objSecurity.FixString(objForm.Fields().Item("DTA_TpaComCode")) & "'"
   
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)

'	for testing
'   strReturn = strQuery  
   
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else
	  strMode = "LOAD"
   end if
   
end sub

'///////////////////////////////////
'// Process import accept routine //
'///////////////////////////////////
sub ProcessImportAccept()

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

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   lngCount = clng(objForm.Fields().Item("LIN_Count"))
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('INP_DATA','" & objSecurity.FixString(objForm.Fields().Item("FileLine" & i)) & "')")
   next

   '//
   '// Load the actual data
   '//
   on error resume next		'get rid of the 500 error
   strStatement = "hermes_act_maintenance.import_actual"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
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
		strMode = "LOAD"
		call ProcessImportLoad
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
'// Paint cash   routine //
'//////////////////////////
sub PaintActual()%>
<!--#include file="hermes_actual_upload.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->