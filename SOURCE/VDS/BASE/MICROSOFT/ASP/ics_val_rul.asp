<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_rul.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : August 2005                                        //
'// Text    : This script implements the validation              //
'//           rule configuration functionality                   //
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
   strTarget = "ics_val_rul.asp"
   strHeading = "Validation Rule"

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
   strReturn = GetSecurityCheck("VAL_RUL_CONFIG")
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else

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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the rule list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.var_rule,"
   strQuery = strQuery & " t01.var_description,"
   strQuery = strQuery & " t01.var_group"
   strQuery = strQuery & " from vds_val_rul t01"
   strQuery = strQuery & " order by t01.var_group asc, t01.var_rule asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

   '//
   '// Retrieve the groups
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vag_group,"
   strQuery = strQuery & " t01.vag_description"
   strQuery = strQuery & " from vds_val_grp t01"
   strQuery = strQuery & " order by vag_description asc"
   strReturn = objSelection.Execute("GROUP", strQuery, lngSize)
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
   call objForm.AddField("DTA_VarRule", "")
   call objForm.AddField("DTA_VarDescription", "")
   call objForm.AddField("DTA_VarQuery", "")
   call objForm.AddField("DTA_VarTest", "*ANY_ROWS")
   call objForm.AddField("DTA_VarMessage", "*NONE")

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
   call objProcedure.Execute("lics_form.set_value('VAR_RULE','" & objSecurity.FixString(objForm.Fields("DTA_VarRule").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAR_DESCRIPTION','" & objSecurity.FixString(objForm.Fields("DTA_VarDescription").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAR_GROUP','" & objSecurity.FixString(objForm.Fields("DTA_VarGroup").Value) & "')")
   lngIndex = 1
   do while lngIndex <= len(objForm.Fields("DTA_VarQuery").Value)
      call objProcedure.Execute("lics_form.set_value('VAR_QUERY','" & objSecurity.FixString(mid(objForm.Fields("DTA_VarQuery").Value,lngIndex,2000)) & "')")
      lngIndex = lngIndex + 2000
   loop
   call objProcedure.Execute("lics_form.set_value('VAR_TEST','" & objSecurity.FixString(objForm.Fields("DTA_VarTest").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAR_MESSAGE','" & objSecurity.FixString(objForm.Fields("DTA_VarMessage").Value) & "')")

   '//
   '// Insert the rule
   '//
   strStatement = "vds_val_configuration.insert_rule"
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
   call objProcedure.Execute("lics_form.set_value('VAR_RULE','" & objSecurity.FixString(objForm.Fields("DTA_VarRule").Value) & "')")

   '//
   '// Retrieve the rule
   '//
   strStatement = "vds_val_configuration.retrieve_rule"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VarDescription", objFunction.Execute("lics_form.get_array('VAR_DESCRIPTION',1)"))
   call objForm.UpdateField("DTA_VarGroup", objFunction.Execute("lics_form.get_array('VAR_GROUP',1)"))
   strBuffer = ""
   lngCount = clng(objFunction.Execute("lics_form.get_array_count('VAR_QUERY')"))
   for lngIndex = 1 to lngCount
      strBuffer = strBuffer & objFunction.Execute("lics_form.get_array('VAR_QUERY'," & lngIndex & ")")
   next
   call objForm.AddField("DTA_VarQuery", cstr(strBuffer))
   call objForm.AddField("DTA_VarTest", objFunction.Execute("lics_form.get_array('VAR_TEST',1)"))
   call objForm.AddField("DTA_VarMessage", objFunction.Execute("lics_form.get_array('VAR_MESSAGE',1)"))

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
   call objProcedure.Execute("lics_form.set_value('VAR_RULE','" & objSecurity.FixString(objForm.Fields("DTA_VarRule").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAR_DESCRIPTION','" & objSecurity.FixString(objForm.Fields("DTA_VarDescription").Value) & "')")
   lngIndex = 1
   do while lngIndex <= len(objForm.Fields("DTA_VarQuery").Value)
      call objProcedure.Execute("lics_form.set_value('VAR_QUERY','" & objSecurity.FixString(mid(objForm.Fields("DTA_VarQuery").Value,lngIndex,2000)) & "')")
      lngIndex = lngIndex + 2000
   loop
   call objProcedure.Execute("lics_form.set_value('VAR_TEST','" & objSecurity.FixString(objForm.Fields("DTA_VarTest").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAR_MESSAGE','" & objSecurity.FixString(objForm.Fields("DTA_VarMessage").Value) & "')")

   '//
   '// Update the rule
   '//
   strStatement = "vds_val_configuration.update_rule"
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
   call objProcedure.Execute("lics_form.set_value('VAR_RULE','" & objSecurity.FixString(objForm.Fields("DTA_VarRule").Value) & "')")

   '//
   '// Retrieve the rule
   '//
   strStatement = "vds_val_configuration.retrieve_rule"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VarDescription", objFunction.Execute("lics_form.get_array('VAR_DESCRIPTION',1)"))
   call objForm.UpdateField("DTA_VarGroup", objFunction.Execute("lics_form.get_array('VAR_GROUP',1)"))
   strBuffer = ""
   lngCount = clng(objFunction.Execute("lics_form.get_array_count('VAR_QUERY')"))
   for lngIndex = 1 to lngCount
      strBuffer = strBuffer & objFunction.Execute("lics_form.get_array('VAR_QUERY'," & lngIndex & ")")
   next
   call objForm.AddField("DTA_VarQuery", cstr(strBuffer))
   call objForm.AddField("DTA_VarTest", objFunction.Execute("lics_form.get_array('VAR_TEST',1)"))
   call objForm.AddField("DTA_VarMessage", objFunction.Execute("lics_form.get_array('VAR_MESSAGE',1)"))

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
   call objProcedure.Execute("lics_form.set_value('VAR_RULE','" & objSecurity.FixString(objForm.Fields("DTA_VarRule").Value) & "')")

   '//
   '// Update the rule
   '//
   strStatement = "vds_val_configuration.delete_rule"
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
   call objProcedure.Execute("lics_form.set_value('VAR_RULE','" & objSecurity.FixString(objForm.Fields("DTA_VarRule").Value) & "')")

   '//
   '// Retrieve the rule
   '//
   strStatement = "vds_val_configuration.retrieve_rule"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VarDescription", objFunction.Execute("lics_form.get_array('VAR_DESCRIPTION',1)"))
   call objForm.AddField("DTA_VarGroup", objFunction.Execute("lics_form.get_array('VAR_GROUP',1)"))
   strBuffer = ""
   lngCount = clng(objFunction.Execute("lics_form.get_array_count('VAR_QUERY')"))
   for lngIndex = 1 to lngCount
      strBuffer = strBuffer & objFunction.Execute("lics_form.get_array('VAR_QUERY'," & lngIndex & ")")
   next
   call objForm.AddField("DTA_VarQuery", cstr(strBuffer))
   call objForm.AddField("DTA_VarTest", objFunction.Execute("lics_form.get_array('VAR_TEST',1)"))
   call objForm.AddField("DTA_VarMessage", objFunction.Execute("lics_form.get_array('VAR_MESSAGE',1)"))

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
<!--#include file="ics_val_rul_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_val_rul_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_val_rul_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_val_rul_delete.inc"-->
<%end sub

'///////////////////////////
'// Paint enquiry routine //
'///////////////////////////
sub PaintEnquiry()%>
<!--#include file="ics_val_rul_enquiry.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->