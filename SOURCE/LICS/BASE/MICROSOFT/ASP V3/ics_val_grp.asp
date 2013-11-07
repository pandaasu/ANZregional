<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_grp.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : August 2005                                        //
'// Text    : This script implements the validation              //
'//           group configuration functionality                  //
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
   strTarget = "ics_val_grp.asp"
   strHeading = "Validation Group"

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
   strReturn = GetSecurityCheck("VAL_GRP_CONFIG")
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else

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
         case "INSERT_LOAD"
            call ProcessInsertLoad
         case "INSERT_ACCEPT"
            call ProcessInsertAccept
         case "UPDATE_LOAD"
            call ProcessUpdateLoad
         case "UPDATE_ACCEPT"
            call ProcessUpdateAccept
         case "DELETE_LOAD"
            call ProcessDeleteLoad
         case "DELETE_ACCEPT"
            call ProcessDeleteAccept
         case "ENQUIRY_LOAD"
            call ProcessEnquiryLoad
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
      case "INSERT"
         call PaintInsert
      case "UPDATE"
         call PaintUpdate
      case "DELETE"
         call PaintDelete
      case "ENQUIRY"
         call PaintEnquiry
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objProcedure = nothing
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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the group list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vag_group,"
   strQuery = strQuery & " t01.vag_description"
   strQuery = strQuery & " from sap_val_grp t01"
   strQuery = strQuery & " order by t01.vag_group asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process insert load routine //
'/////////////////////////////////
sub ProcessInsertLoad()

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VagGroup", "")
   call objForm.AddField("DTA_VagDescription", "")
   call objForm.AddField("DTA_VagCodLength", "0")
   call objForm.AddField("DTA_VagCodQuery", "")

   '//
   '// Set the mode
   '//
   strMode = "INSERT"

end sub

'///////////////////////////////////
'// Process insert accept routine //
'///////////////////////////////////
sub ProcessInsertAccept()

   dim strStatement
   dim lngIndex

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
   call objProcedure.Execute("lics_form.set_value('VAG_GROUP','" & objSecurity.FixString(objForm.Fields().Item("DTA_VagGroup")) & "')")
   call objProcedure.Execute("lics_form.set_value('VAG_DESCRIPTION','" & objSecurity.FixString(objForm.Fields().Item("DTA_VagDescription")) & "')")
   call objProcedure.Execute("lics_form.set_value('VAG_COD_LENGTH','" & objSecurity.FixString(objForm.Fields().Item("DTA_VagCodLength")) & "')")
   lngIndex = 1
   do while lngIndex <= len(objForm.Fields().Item("DTA_VagCodQuery"))
      call objProcedure.Execute("lics_form.set_value('VAG_COD_QUERY','" & objSecurity.FixString(mid(objForm.Fields().Item("DTA_VagCodQuery"),lngIndex,2000)) & "')")
      lngIndex = lngIndex + 2000
   loop

   '//
   '// Insert the group
   '//
   strStatement = "lads_val_configuration.insert_group"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "INSERT"
      strError = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'/////////////////////////////////
'// Process update load routine //
'/////////////////////////////////
sub ProcessUpdateLoad()

   dim strStatement
   dim lngIndex
   dim lngCount
   dim strBuffer

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
   call objProcedure.Execute("lics_form.set_value('VAG_GROUP','" & objSecurity.FixString(objForm.Fields().Item("DTA_VagGroup")) & "')")

   '//
   '// Retrieve the group
   '//
   strStatement = "lads_val_configuration.retrieve_group"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VagDescription", objFunction.Execute("lics_form.get_array('VAG_DESCRIPTION',1)"))
   call objForm.AddField("DTA_VagCodLength", objFunction.Execute("lics_form.get_array('VAG_COD_LENGTH',1)"))
   strBuffer = ""
   lngCount = clng(objFunction.Execute("lics_form.get_array_count('VAG_COD_QUERY')"))
   for lngIndex = 1 to lngCount
      strBuffer = strBuffer & objFunction.Execute("lics_form.get_array('VAG_COD_QUERY'," & lngIndex & ")")
   next
   call objForm.AddField("DTA_VagCodQuery", cstr(strBuffer))

   '//
   '// Set the mode
   '//
   strMode = "UPDATE"

end sub

'///////////////////////////////////
'// Process update accept routine //
'///////////////////////////////////
sub ProcessUpdateAccept()

   dim strStatement
   dim lngIndex

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
   call objProcedure.Execute("lics_form.set_value('VAG_GROUP','" & objSecurity.FixString(objForm.Fields().Item("DTA_VagGroup")) & "')")
   call objProcedure.Execute("lics_form.set_value('VAG_DESCRIPTION','" & objSecurity.FixString(objForm.Fields().Item("DTA_VagDescription")) & "')")
   call objProcedure.Execute("lics_form.set_value('VAG_COD_LENGTH','" & objSecurity.FixString(objForm.Fields().Item("DTA_VagCodLength")) & "')")
   lngIndex = 1
   do while lngIndex <= len(objForm.Fields().Item("DTA_VagCodQuery"))
      call objProcedure.Execute("lics_form.set_value('VAG_COD_QUERY','" & objSecurity.FixString(mid(objForm.Fields().Item("DTA_VagCodQuery"),lngIndex,2000)) & "')")
      lngIndex = lngIndex + 2000
   loop

   '//
   '// Update the group
   '//
   strStatement = "lads_val_configuration.update_group"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "UPDATE"
      strError = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'/////////////////////////////////
'// Process delete load routine //
'/////////////////////////////////
sub ProcessDeleteLoad()

   dim strStatement
   dim lngIndex
   dim lngCount
   dim strBuffer

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
   call objProcedure.Execute("lics_form.set_value('VAG_GROUP','" & objSecurity.FixString(objForm.Fields().Item("DTA_VagGroup")) & "')")

   '//
   '// Retrieve the group
   '//
   strStatement = "lads_val_configuration.retrieve_group"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VagDescription", objFunction.Execute("lics_form.get_array('VAG_DESCRIPTION',1)"))
   call objForm.AddField("DTA_VagCodLength", objFunction.Execute("lics_form.get_array('VAG_COD_LENGTH',1)"))
   strBuffer = ""
   lngCount = clng(objFunction.Execute("lics_form.get_array_count('VAG_COD_QUERY')"))
   for lngIndex = 1 to lngCount
      strBuffer = strBuffer & objFunction.Execute("lics_form.get_array('VAG_COD_QUERY'," & lngIndex & ")")
   next
   call objForm.AddField("DTA_VagCodQuery", cstr(strBuffer))

   '//
   '// Set the mode
   '//
   strMode = "DELETE"

end sub

'///////////////////////////////////
'// Process delete accept routine //
'///////////////////////////////////
sub ProcessDeleteAccept()

   dim strStatement

   '//
   '// Create the procedure on object
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
   call objProcedure.Execute("lics_form.set_value('VAG_GROUP','" & objSecurity.FixString(objForm.Fields().Item("DTA_VagGroup")) & "')")

   '//
   '// Delete the group
   '//
   strStatement = "lads_val_configuration.delete_group"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "DELETE"
      strError = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'//////////////////////////////////
'// Process enquiry load routine //
'//////////////////////////////////
sub ProcessEnquiryLoad()

   dim strStatement
   dim lngIndex
   dim lngCount
   dim strBuffer

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
   call objProcedure.Execute("lics_form.set_value('VAG_GROUP','" & objSecurity.FixString(objForm.Fields().Item("DTA_VagGroup")) & "')")

   '//
   '// Retrieve the group
   '//
   strStatement = "lads_val_configuration.retrieve_group"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VagDescription", objFunction.Execute("lics_form.get_array('VAG_DESCRIPTION',1)"))
   call objForm.AddField("DTA_VagCodLength", objFunction.Execute("lics_form.get_array('VAG_COD_LENGTH',1)"))
   strBuffer = ""
   lngCount = clng(objFunction.Execute("lics_form.get_array_count('VAG_COD_QUERY')"))
   for lngIndex = 1 to lngCount
      strBuffer = strBuffer & objFunction.Execute("lics_form.get_array('VAG_COD_QUERY'," & lngIndex & ")")
   next
   call objForm.AddField("DTA_VagCodQuery", cstr(strBuffer))

   '//
   '// Set the mode
   '//
   strMode = "ENQUIRY"

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
<!--#include file="ics_val_grp_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_val_grp_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_val_grp_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_val_grp_delete.inc"-->
<%end sub

'///////////////////////////
'// Paint enquiry routine //
'///////////////////////////
sub PaintEnquiry()%>
<!--#include file="ics_val_grp_enquiry.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->