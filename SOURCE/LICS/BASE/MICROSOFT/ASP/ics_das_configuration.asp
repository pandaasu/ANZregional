<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_das_configuration.asp                          //
'// Author  : Steve Gregan                                       //
'// Date    : December 2008                                      //
'// Text    : This script implements the datastore configuration //
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

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_das_configuration.asp"
   strHeading = "Data Store Configuration"
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
   strReturn = GetSecurityCheck("ICS_DAS_CONFIG")
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
         case "DEFINE_LOAD"
            call ProcessDefineLoad
         case "DEFINE_ACCEPT"
            call ProcessDefineAccept
         case "DELETE_LOAD"
            call ProcessDeleteLoad
         case "DELETE_ACCEPT"
            call ProcessDeleteAccept
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
      case "DEFINE"
         call PaintDefine
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
   '// Retrieve the data stores
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.dss_system,"
   strQuery = strQuery & " t01.dss_description,"
   strQuery = strQuery & " t01.dss_upd_user,"
   strQuery = strQuery & " to_char(t01.dss_upd_date,'yyyy/mm/dd hh24:mi:ss')"
   strQuery = strQuery & " from lics_das_system t01"
   strQuery = strQuery & " order by t01.dss_system asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process define load routine //
'/////////////////////////////////
sub ProcessDefineLoad()

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the data store data
   '//
   if objForm.Fields("DTA_DasSystem").Value <> "*NEW" then

      '//
      '// Retrieve the data store
      '//
      strQuery = "select t01.dss_system,"
      strQuery = strQuery & " t01.dss_description,"
      strQuery = strQuery & " from lics_das_system t01"
      strQuery = strQuery & " where t01.dss_system = '" & objForm.Fields("DTA_DasSystem").Value & "'"
      strReturn = objSelection.Execute("STORE", strQuery, 0)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Retrieve the data store information
      '//
      strQuery = "select "
      strQuery = strQuery & " to_char(t01.str_depth),"
      strQuery = strQuery & " t01.str_node,"
      strQuery = strQuery & " t01.str_group,"
      strQuery = strQuery & " t01.str_code,"
      strQuery = strQuery & " t01.str_text,"
      strQuery = strQuery & " t01.str_value,"
      strQuery = strQuery & " t01.str_type,"
      strQuery = strQuery & " t01.str_data"
      strQuery = strQuery & " from table(lics_app.lics_datastore_configuration.get_nodes('" & objForm.Fields("DTA_DasSystem").Value & "')) t01"
      strReturn = objSelection.Execute("NODES", strQuery, 0)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Initialise the data fields
      '//
      call objForm.AddField("DTA_DasAction", "*UPDATE")
      call objForm.AddField("DTA_DasDescription", objSelection.ListValue02("STORE",objSelection.ListLower("STORE")))

   else

      '//
      '// Initialise the data fields
      '//
      call objForm.AddField("DTA_DasAction", "*CREATE")
      call objForm.UpdateField("DTA_DasSystem", "")
      call objForm.AddField("DTA_DasDescription", "")

   end if

   '//
   '// Set the mode
   '//
   strMode = "DEFINE"

end sub

'///////////////////////////////////
'// Process define accept routine //
'///////////////////////////////////
sub ProcessDefineAccept()

   dim strStatement
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   lngCount = clng(objForm.Fields("StreamCount").Value)
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('TRANSACTION_STREAM','" & objSecurity.FixString(objForm.Fields("StreamPart" & i).Value) & "')")
   next

   '//
   '// Define the data store
   '//
   strStatement = "lics_datastore_configuration.define_store('" & GetUser() & "')"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
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

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the data store
   '//
   strQuery = "select t01.dss_system,"
   strQuery = strQuery & " t01.dss_description,"
   strQuery = strQuery & " from lics_das_system t01"
   strQuery = strQuery & " where t01.dss_system = '" & objForm.Fields("DTA_DasSystem").Value & "'"
   strReturn = objSelection.Execute("STORE", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_DasDescription", objSelection.ListValue02("STORE",objSelection.ListLower("LIST")))

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
   '// Delete the report
   '//
   strStatement = "lics_datastore_configuration.delete_store('" & objForm.Fields("DTA_DasSystem").Value & "')"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
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
<!--#include file="ics_das_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint define routine //
'//////////////////////////
sub PaintDefine()%>
<!--#include file="ics_das_configuration_define.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_das_configuration_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->