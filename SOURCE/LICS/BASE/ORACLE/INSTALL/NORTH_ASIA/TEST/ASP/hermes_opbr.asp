<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes                                             //
'// Script  : hermes_opbr.asp                                    //
'// Author  : ISI China                                          //
'// Date    : March 2006                                         //
'// Text    : This script implements the opbr import             //
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
   strTarget = "hermes_opbr.asp"
   strHeading = "OP/BR Import"

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
         case "ACCEPTOP"
            call ProcessImportAccept("OP")
         case "ACCEPTBR"
            call ProcessImportAccept("BR")
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
         call PaintOPBR
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the routing list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.TPO_OP_VRSN,"
   strQuery = strQuery & " t01.TPO_COM_CODE,"
   strQuery = strQuery & " t01.TPO_TP_TYPE,"
   strQuery = strQuery & " t01.TPO_CUST_LEVEL,"
   strQuery = strQuery & " t01.TPO_MATL_LEVEL,"
   strQuery = strQuery & " t01.TPO_PERIOD,"
   strQuery = strQuery & " t01.TPO_OP_VALUE"
   strQuery = strQuery & " from TP_OP t01"
   strQuery = strQuery & " where t01.tpo_com_code = '" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "'"
   strQuery = strQuery & " order by t01.TPO_OP_VRSN asc "
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
sub ProcessImportAccept(ByVal planFmt)

   dim strStatement
   dim lngIndex
   dim lngCount

	'check parameter first
	if planFmt = "OP" then
		strStatement = "hermes_opbr.import_opbr('OP')"	
	elseif planFmt = "BR" then
		strStatement = "hermes_opbr.import_opbr('BR')"
	else
		strMode = "FATAL"
		exit sub
	end if

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
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   lngCount = clng(objForm.Fields("LIN_Count").Value)
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('INP_DATA','" & objSecurity.FixString(objForm.Fields("FileLine" & i).Value) & "')")
   next
   
   '//
   '// Load the opbr data
   '//
   on error resume next		'get rid of the 500 error
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
'// Paint opbr   routine //
'//////////////////////////
sub PaintOPBR()%>
<!--#include file="hermes_opbr.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->