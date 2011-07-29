<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes                                             //
'// Script  : hermes_actual_load.asp                                  //
'// Author  : ISI China                                          //
'// Date    : March 2006                                         //
'// Text    : This script implements the actual import           //
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
   dim objStream

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "hermes_actual_load.asp"
   strHeading = "Actual Import"

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
         case "LOAD"
            call ProcessImportLoad
         case "ACCEPT"
            call ProcessImportAccept
         case else
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   select case strMode
      case "FATAL"
         call PaintFatal
      case "LOAD"
         call Paintactual
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objProcedure = nothing
   set objFunction = nothing
   set objStream = nothing

'/////////////////////////////////
'// Process import load routine //
'/////////////////////////////////
sub ProcessImportLoad()


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
   strQuery = strQuery & " t01.tpa_com_code,"
   strQuery = strQuery & " t01.tpa_period,"
   strQuery = strQuery & " t01.tpa_tp_id,"
   strQuery = strQuery & " t01.tpa_cust_code,"
   strQuery = strQuery & " t01.tpa_matl_code,"
   strQuery = strQuery & " to_char(t01.tpa_act,'fm999999990.00') "
   strQuery = strQuery & " from tp_actuals t01, tp_com t02"
   strQuery = strQuery & " where t01.tpa_com_code = t02.tpc_com_code"
   strQuery = strQuery & " and t01.tpa_period = t02.tpc_curr_prd"
   strQuery = strQuery & " and t01.tpa_com_code = '" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "'"
   strQuery = strQuery & " order by t01.tpa_tp_id asc "
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
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Build the stream
   '//
   set objStream = Server.CreateObject("ICS_STREAM.Object")
   lngCount = clng(Request.Form("StreamCount"))
   objStream.ClearStream
   for i = 1 to lngCount
      objStream.AddToStream(Request.Form("StreamPart" & i))
   next

   '//
   '// Load the form data from the stream
   '//
   call objProcedure.Execute("lics_form.clear_form")
   objStream.OpenStream
   do while objStream.EndOfStream = false
      call objProcedure.Execute("lics_form.set_value('INP_DATA','" & objSecurity.FixString(objStream.ReadLine) & "')")
   loop

   '//
   '// Load the actual data
   '//
   on error resume next		'get rid of the 500 error
   strStatement = "hermes_actual.load_actual"
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
'// Paint actual routine //
'//////////////////////////
sub Paintactual()%>
<!--#include file="hermes_actual_load.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->