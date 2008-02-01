<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_vds_int.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : February 2007                                      //
'// Text    : This script implements the validation data store   //
'//           interface configuration functionality              //
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
   strTarget = "ics_vds_int.asp"
   strHeading = "Validation Data Store Interface"
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
      case "SELECT"
         call PaintSelect
      case "INSERT"
         call PaintInsert
      case "UPDATE"
         call PaintUpdate
      case "DELETE"
         call PaintDelete
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
   '// Retrieve the interface list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vin_interface,"
   strQuery = strQuery & " t01.vin_description,"
   strQuery = strQuery & " t01.vin_logon01,"
   strQuery = strQuery & " t01.vin_logon02"
   strQuery = strQuery & " from vds_interface t01"
   strQuery = strQuery & " order by t01.vin_interface asc"
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
   call objForm.AddField("DTA_VinInterface", "")
   call objForm.AddField("DTA_VinDescription", "")
   call objForm.AddField("DTA_VinLogon01", "1")
   call objForm.AddField("DTA_VinLogon02", "0")

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
   call objProcedure.Execute("lics_form.set_value('VIN_INTERFACE','" & objSecurity.FixString(objForm.Fields("DTA_VinInterface").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VIN_DESCRIPTION','" & objSecurity.FixString(objForm.Fields("DTA_VinDescription").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VIN_LOGON01','" & objSecurity.FixString(objForm.Fields("DTA_VinLogon01").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VIN_LOGON02','" & objSecurity.FixString(objForm.Fields("DTA_VinLogon02").Value) & "')")

   '//
   '// Insert the interface
   '//
   strStatement = "vds_configuration.insert_interface"
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
   call objProcedure.Execute("lics_form.set_value('VIN_INTERFACE','" & objSecurity.FixString(objForm.Fields("DTA_VinInterface").Value) & "')")

   '//
   '// Retrieve the interface
   '//
   strStatement = "vds_configuration.retrieve_interface"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VinDescription", objFunction.Execute("lics_form.get_array('VIN_DESCRIPTION',1)"))
   call objForm.AddField("DTA_VinLogon01", objFunction.Execute("lics_form.get_array('VIN_LOGON01',1)"))
   call objForm.AddField("DTA_VinLogon02", objFunction.Execute("lics_form.get_array('VIN_LOGON02',1)"))

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
   call objProcedure.Execute("lics_form.set_value('VIN_INTERFACE','" & objSecurity.FixString(objForm.Fields("DTA_VinInterface").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VIN_DESCRIPTION','" & objSecurity.FixString(objForm.Fields("DTA_VinDescription").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VIN_LOGON01','" & objSecurity.FixString(objForm.Fields("DTA_VinLogon01").Value) & "')")
   call objProcedure.Execute("lics_form.set_value('VIN_LOGON02','" & objSecurity.FixString(objForm.Fields("DTA_VinLogon02").Value) & "')")

   '//
   '// Update the interface
   '//
   strStatement = "vds_configuration.update_interface"
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
   call objProcedure.Execute("lics_form.set_value('VIN_INTERFACE','" & objSecurity.FixString(objForm.Fields("DTA_VinInterface").Value) & "')")

   '//
   '// Retrieve the interface
   '//
   strStatement = "vds_configuration.retrieve_interface"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VinDescription", objFunction.Execute("lics_form.get_array('VIN_DESCRIPTION',1)"))

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
   call objProcedure.Execute("lics_form.set_value('VIN_INTERFACE','" & objSecurity.FixString(objForm.Fields("DTA_VinInterface").Value) & "')")

   '//
   '// Delete the interface
   '//
   strStatement = "vds_configuration.delete_interface"
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
<!--#include file="ics_vds_int_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_vds_int_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_vds_int_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_vds_int_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->