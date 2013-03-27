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
      strMode = objForm.Fields().Item("Mode")

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

	strMode = "LOAD"
   
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