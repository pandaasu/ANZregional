<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_typ.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : August 2005                                        //
'// Text    : This script implements the validation              //
'//           type configuration functionality                   //
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
   strTarget = "ics_val_typ.asp"
   strHeading = "Validation Type"
   strError = ""

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
   strReturn = GetSecurityCheck("VAL_TYP_CONFIG")
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
'// Retrieve group routine //
'////////////////////////////
sub RetrieveGroup()

   dim strQuery
   dim lngSize

   '//
   '// Retrieve the groups
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vag_group,"
   strQuery = strQuery & " t01.vag_description"
   strQuery = strQuery & " from sap_val_grp t01"
   strQuery = strQuery & " order by vag_description asc"
   strReturn = objSelection.Execute("GROUP", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'///////////////////////////
'// Retrieve rule routine //
'///////////////////////////
sub RetrieveRule(strGroup)

   dim strQuery
   dim lngSize

   '//
   '// Retrieve the rules
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.var_rule,"
   strQuery = strQuery & " t01.var_description,"
   strQuery = strQuery & " nvl(t02.rul_select,'0')"
   strQuery = strQuery & " from sap_val_rul t01,"
   strQuery = strQuery & " (select t01.vtr_rule, '1' as rul_select"
   strQuery = strQuery & " from sap_val_typ_rul t01"
   strQuery = strQuery & " where t01.vtr_type = '" & objForm.Fields("DTA_VatType").Value & "') t02"
   strQuery = strQuery & " where t01.var_rule = t02.vtr_rule(+)"
   if strGroup <> "" then
      strQuery = strQuery & " and t01.var_group = '" & strGroup & "'"
   end if
   strQuery = strQuery & " order by t01.var_rule asc"
   strReturn = objSelection.Execute("RULE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

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
   '// Retrieve the type list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vat_type,"
   strQuery = strQuery & " t01.vat_description,"
   strQuery = strQuery & " t01.vat_group"
   strQuery = strQuery & " from sap_val_typ t01"
   strQuery = strQuery & " order by t01.vat_group asc, t01.vat_type asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

   '//
   '// Retrieve the groups
   '//
   call RetrieveGroup
   if strMode = "FATAL" then
      exit sub
   end if

end sub

'/////////////////////////////////
'// Process insert load routine //
'/////////////////////////////////
sub ProcessInsertLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VatType", "")
   call objForm.AddField("DTA_VatDescription", "")

   '//
   '// Retrieve the rules
   '//
   call RetrieveRule(objForm.Fields("DTA_VatGroup").Value)
   if strMode = "FATAL" then
      exit sub
   end if

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
   dim lngCount

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

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
   call objProcedure.Execute("lics_form.set_value('VAT_TYPE','" & objSecurity.FixString(objForm.Fields("DTA_VatType").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAT_DESCRIPTION','" & objSecurity.FixString(objForm.Fields("DTA_VatDescription").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAT_GROUP','" & objSecurity.FixString(objForm.Fields("DTA_VatGroup").Value) & "')")

   '//
   '// Insert the type rules
   '//
   lngCount = clng(objForm.Fields("DET_RuleCount").Value)
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VTR_RULE','" & objSecurity.FixString(objForm.Fields("DET_Rule" & i).Value) & "')")
   next

   '//
   '// Insert the type
   '//
   strStatement = "lads_val_configuration.insert_type"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "INSERT"
      strError = FormatError(strReturn)
      call RetrieveRule(objForm.Fields("DTA_VatGroup").Value)
      if strMode = "FATAL" then
         exit sub
      end if
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

   dim strQuery
   dim lngSize
   dim strStatement
   dim lngIndex
   dim lngCount
   dim strBuffer

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

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
   call objProcedure.Execute("lics_form.set_value('VAT_TYPE','" & objSecurity.FixString(objForm.Fields("DTA_VatType").Value) & "')")

   '//
   '// Retrieve the type
   '//
   strStatement = "lads_val_configuration.retrieve_type"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VatDescription", objFunction.Execute("lics_form.get_array('VAT_DESCRIPTION',1)"))
   call objForm.UpdateField("DTA_VatGroup", objFunction.Execute("lics_form.get_array('VAT_GROUP',1)"))

   '//
   '// Retrieve the rules
   '//
   call RetrieveRule(objForm.Fields("DTA_VatGroup").Value)
   if strMode = "FATAL" then
      exit sub
   end if

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
   dim lngCount

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

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
   call objProcedure.Execute("lics_form.set_value('VAT_TYPE','" & objSecurity.FixString(objForm.Fields("DTA_VatType").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAT_DESCRIPTION','" & objSecurity.FixString(objForm.Fields("DTA_VatDescription").Value) & "')")

   '//
   '// Insert the type rules
   '//
   lngCount = clng(objForm.Fields("DET_RuleCount").Value)
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VTR_RULE','" & objSecurity.FixString(objForm.Fields("DET_Rule" & i).Value) & "')")
   next

   '//
   '// Update the type
   '//
   strStatement = "lads_val_configuration.update_type"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "UPDATE"
      strError = FormatError(strReturn)
      call RetrieveRule(objForm.Fields("DTA_VatGroup").Value)
      if strMode = "FATAL" then
         exit sub
      end if
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
   call objProcedure.Execute("lics_form.set_value('VAT_TYPE','" & objSecurity.FixString(objForm.Fields("DTA_VatType").Value) & "')")

   '//
   '// Retrieve the type
   '//
   strStatement = "lads_val_configuration.retrieve_type"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VatDescription", objFunction.Execute("lics_form.get_array('VAT_DESCRIPTION',1)"))
   call objForm.UpdateField("DTA_VatGroup", objFunction.Execute("lics_form.get_array('VAT_GROUP',1)"))

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
   call objProcedure.Execute("lics_form.set_value('VAT_TYPE','" & objSecurity.FixString(objForm.Fields("DTA_VatType").Value) & "')")

   '//
   '// Delete the type
   '//
   strStatement = "lads_val_configuration.delete_type"
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

   dim strQuery
   dim lngSize
   dim strStatement
   dim lngIndex
   dim lngCount
   dim strBuffer

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

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
   call objProcedure.Execute("lics_form.set_value('VAT_TYPE','" & objSecurity.FixString(objForm.Fields("DTA_VatType").Value) & "')")

   '//
   '// Retrieve the type
   '//
   strStatement = "lads_val_configuration.retrieve_type"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VatDescription", objFunction.Execute("lics_form.get_array('VAT_DESCRIPTION',1)"))
   call objForm.AddField("DTA_VatGroup", objFunction.Execute("lics_form.get_array('VAT_GROUP',1)"))

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
<!--#include file="ics_val_typ_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_val_typ_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_val_typ_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_val_typ_delete.inc"-->
<%end sub

'///////////////////////////
'// Paint enquiry routine //
'///////////////////////////
sub PaintEnquiry()%>
<!--#include file="ics_val_typ_enquiry.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->