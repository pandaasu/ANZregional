<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : prc_lst_group.asp                                  //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the price list generator    //
'//           group functionality                                //
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
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "prc_lst_group.asp"
   strHeading = "Price List Group Configuration"
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
   strReturn = GetSecurityCheck("PRC_LST_GROUP")
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
   '// Retrieve the group list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.report_grp_id,"
   strQuery = strQuery & " t01.report_grp_name,"
   strQuery = strQuery & " t01.status"
   strQuery = strQuery & " from report_grp t01"
   strQuery = strQuery & " order by t01.report_grp_name asc"
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
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the report group data
   '//
   if objForm.Fields("DTA_ReportGrpId").Value <> "" then

      '//
      '// Retrieve the report group data
      '//
      lngSize = 0
      strQuery = "select"
      strQuery = strQuery & " to_char(t01.report_grp_id),"
      strQuery = strQuery & " t01.report_grp_name,"
      strQuery = strQuery & " t01.status"
      strQuery = strQuery & " from report_grp t01"
      strQuery = strQuery & " where t01.report_grp_id = '" & objForm.Fields("DTA_ReportGrpId").Value & "'"
      strReturn = objSelection.Execute("GROUP", strQuery, lngSize)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Initialise the data fields
      '//
      call objForm.AddField("DTA_ReportGrpName", objSelection.ListValue02("GROUP",objSelection.ListLower("GROUP")))
      call objForm.AddField("DTA_Status", objSelection.ListValue03("GROUP",objSelection.ListLower("GROUP")))

   else

      '//
      '// Initialise the data fields
      '//
      call objForm.AddField("DTA_ReportGrpName", "")
      call objForm.AddField("DTA_Status", "I")

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
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Update the group
   '//
   strStatement = "pricelist_configuration.define_group("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ReportGrpId").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ReportGrpName").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_Status").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
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
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the group data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.report_grp_id),"
   strQuery = strQuery & " t01.report_grp_name,"
   strQuery = strQuery & " t01.status"
   strQuery = strQuery & " from report_grp t01"
   strQuery = strQuery & " where t01.report_grp_id = '" & objForm.Fields("DTA_ReportGrpId").Value & "'"
   strReturn = objSelection.Execute("GROUP", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_ReportGrpName", objSelection.ListValue02("GROUP",objSelection.ListLower("GROUP")))
   call objForm.AddField("DTA_Status", objSelection.ListValue03("GROUP",objSelection.ListLower("GROUP")))

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
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Set the procedure string
   '//
   strStatement = "pricelist_configuration.delete_group("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ReportGrpId").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
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
<!--#include file="prc_lst_group_select.inc"-->
<%end sub

'//////////////////////////
'// Paint define routine //
'//////////////////////////
sub PaintDefine()%>
<!--#include file="prc_lst_group_define.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="prc_lst_group_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->