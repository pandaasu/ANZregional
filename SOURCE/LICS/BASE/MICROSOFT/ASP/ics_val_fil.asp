<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_rul.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : August 2005                                        //
'// Text    : This script implements the validation              //
'//           fileter configuration functionality                //
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
   strTarget = "ics_val_fil.asp"
   strHeading = "Validation Filter"

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
   strReturn = GetSecurityCheck("VAL_FIL_CONFIG")
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
         case "DETAIL_LOAD"
            call ProcessDetailLoad
         case "DETAIL_ACCEPT"
            call ProcessDetailAccept
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
      case "DETAIL"
         call PaintDetail
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

'///////////////////////////
'// Retrieve type routine //
'///////////////////////////
sub RetrieveType(strGroup)

   dim strQuery
   dim lngSize

   '//
   '// Retrieve the rules
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vat_type,"
   strQuery = strQuery & " t01.vat_description"
   strQuery = strQuery & " from sap_val_typ t01"
   if strGroup <> "" then
      strQuery = strQuery & " where t01.vat_group = '" & strGroup & "'"
   end if
   strQuery = strQuery & " order by t01.vat_description asc"
   strReturn = objSelection.Execute("TYPE", strQuery, lngSize)
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
   '// Retrieve the filter list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vaf_filter,"
   strQuery = strQuery & " t01.vaf_description,"
   strQuery = strQuery & " t01.vaf_group"
   strQuery = strQuery & " from sap_val_fil t01"
   strQuery = strQuery & " order by t01.vaf_group asc, t01.vaf_filter asc"
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
   strQuery = strQuery & " from sap_val_grp t01"
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
   call objForm.AddField("DTA_VafFilter", "")
   call objForm.AddField("DTA_VafDescription", "")
   call objForm.AddField("DTA_VafType", "")

   '//
   '// Retrieve the types
   '//
   call RetrieveType(objForm.Fields("DTA_VafGroup").Value)
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

   dim strQuery
   dim lngSize
   dim strStatement
   dim lngIndex

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
   call objProcedure.Execute("lics_form.set_value('VAF_FILTER','" & objSecurity.FixString(objForm.Fields("DTA_VafFilter").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAF_DESCRIPTION','" & objSecurity.FixString(objForm.Fields("DTA_VafDescription").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAF_GROUP','" & objSecurity.FixString(objForm.Fields("DTA_VafGroup").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAF_TYPE','" & objSecurity.FixString(objForm.Fields("DTA_VafType").Value) & "')")

   '//
   '// Insert the filter
   '//
   strStatement = "lads_val_configuration.insert_filter"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "INSERT"
      strError = FormatError(strReturn)
      call RetrieveType(objForm.Fields("DTA_VafGroup").Value)
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
   call objProcedure.Execute("lics_form.set_value('VAF_FILTER','" & objSecurity.FixString(objForm.Fields("DTA_VafFilter").Value) & "')")

   '//
   '// Retrieve the filter
   '//
   strStatement = "lads_val_configuration.retrieve_filter"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VafDescription", objFunction.Execute("lics_form.get_array('VAF_DESCRIPTION',1)"))
   call objForm.UpdateField("DTA_VafGroup", objFunction.Execute("lics_form.get_array('VAF_GROUP',1)"))
   call objForm.AddField("DTA_VafType", objFunction.Execute("lics_form.get_array('VAF_TYPE',1)"))

   '//
   '// Retrieve the types
   '//
   call RetrieveType(objForm.Fields("DTA_VafGroup").Value)
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

   dim strQuery
   dim lngSize
   dim strStatement
   dim lngIndex

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
   call objProcedure.Execute("lics_form.set_value('VAF_FILTER','" & objSecurity.FixString(objForm.Fields("DTA_VafFilter").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAF_DESCRIPTION','" & objSecurity.FixString(objForm.Fields("DTA_VafDescription").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VAF_TYPE','" & objSecurity.FixString(objForm.Fields("DTA_VafType").Value) & "')")

   '//
   '// Update the filter
   '//
   strStatement = "lads_val_configuration.update_filter"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "UPDATE"
      strError = FormatError(strReturn)
      call RetrieveType(objForm.Fields("DTA_VafGroup").Value)
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
   call objProcedure.Execute("lics_form.set_value('VAF_FILTER','" & objSecurity.FixString(objForm.Fields("DTA_VafFilter").Value) & "')")

   '//
   '// Retrieve the filter
   '//
   strStatement = "lads_val_configuration.retrieve_filter"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VafDescription", objFunction.Execute("lics_form.get_array('VAF_DESCRIPTION',1)"))
   call objForm.UpdateField("DTA_VafGroup", objFunction.Execute("lics_form.get_array('VAF_GROUP',1)"))
   call objForm.UpdateField("DTA_VafType", objFunction.Execute("lics_form.get_array('VAF_TYPE',1)"))

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
   call objProcedure.Execute("lics_form.set_value('VAF_FILTER','" & objSecurity.FixString(objForm.Fields("DTA_VafFilter").Value) & "')")

   '//
   '// Update the filter
   '//
   strStatement = "lads_val_configuration.delete_filter"
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

'/////////////////////////////////
'// Process detail load routine //
'/////////////////////////////////
sub ProcessDetailLoad()

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
   call objProcedure.Execute("lics_form.set_value('VAF_FILTER','" & objSecurity.FixString(objForm.Fields("DTA_VafFilter").Value) & "')")

   '//
   '// Retrieve the filter
   '//
   strStatement = "lads_val_configuration.retrieve_filter"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VafDescription", objFunction.Execute("lics_form.get_array('VAF_DESCRIPTION',1)"))
   call objForm.UpdateField("DTA_VafGroup", objFunction.Execute("lics_form.get_array('VAF_GROUP',1)"))

   '//
   '// Set the mode
   '//
   strMode = "DETAIL"

end sub

'///////////////////////////////////
'// Process detail accept routine //
'///////////////////////////////////
sub ProcessDetailAccept()

   dim strStatement
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
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   call objProcedure.Execute("lics_form.set_value('VAF_FILTER','" & objSecurity.FixString(objForm.Fields("DTA_VafFilter").Value) & "')")

   '//
   '// Insert the filter details
   '//
   lngCount = clng(objForm.Fields("LIN_Count").Value)
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VFD_CODE','" & objSecurity.FixString(objForm.Fields("FileLine" & i).Value) & "')")
   next

   '//
   '// Update the filter
   '//
   strStatement = "lads_val_configuration.load_filter"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "DETAIL"
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
   call objProcedure.Execute("lics_form.set_value('VAF_FILTER','" & objSecurity.FixString(objForm.Fields("DTA_VafFilter").Value) & "')")

   '//
   '// Retrieve the filter
   '//
   strStatement = "lads_val_configuration.retrieve_filter"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VafDescription", objFunction.Execute("lics_form.get_array('VAF_DESCRIPTION',1)"))
   call objForm.AddField("DTA_VafGroup", objFunction.Execute("lics_form.get_array('VAF_GROUP',1)"))
   call objForm.AddField("DTA_VafType", objFunction.Execute("lics_form.get_array('VAF_TYPE',1)"))

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
<!--#include file="ics_val_fil_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_val_fil_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_val_fil_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_val_fil_delete.inc"-->
<%end sub

'//////////////////////////
'// Paint detail routine //
'//////////////////////////
sub PaintDetail()%>
<!--#include file="ics_val_fil_detail.inc"-->
<%end sub

'///////////////////////////
'// Paint enquiry routine //
'///////////////////////////
sub PaintEnquiry()%>
<!--#include file="ics_val_fil_enquiry.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->