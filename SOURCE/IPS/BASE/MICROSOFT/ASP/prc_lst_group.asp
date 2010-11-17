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
   dim objProcedure

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
         case "FORMAT_LOAD"
            call ProcessFormatLoad
         case "FORMAT_ACCEPT"
            call ProcessFormatAccept
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
      case "FORMAT"
         call PaintFormat
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
   '// Retrieve the group list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.report_grp_id,"
   strQuery = strQuery & " t01.report_grp_name,"
   strQuery = strQuery & " decode(t01.status,'V','Available','I','Inactive',t01.status)"
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
   if objForm.Fields("DTA_ReportGrpId").Value <> "0" then

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
      '// Retrieve the report group terms
      '//
      lngSize = 0
      strQuery = "select"
      strQuery = strQuery & " t01.value"
      strQuery = strQuery & " from report_grp_term t01"
      strQuery = strQuery & " where t01.report_grp_id = " & objForm.Fields("DTA_ReportGrpId").Value
      strQuery = strQuery & " order by t01.sort_order asc"
      strReturn = objSelection.Execute("GROUP_TERM", strQuery, lngSize)
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
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Update the group
   '//
   strStatement = "pricelist_configuration.define_group("
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_ReportGrpId").Value) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ReportGrpName").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_Status").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Define the group term
   '//
   lngCount = clng(objForm.Fields("DET_RepTerCount").Value)
   for i = 1 to lngCount
      strStatement = "pricelist_configuration.define_group_term("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepTerText" & i).Value) & "'"
      strStatement = strStatement & ")"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

   '//
   '// Commit the group define
   '//
   strStatement = "pricelist_configuration.define_group_commit"
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
'// Process format load routine //
'/////////////////////////////////
sub ProcessFormatLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the report group terms
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " nvl(t01.value,'*Blank Line*'),"
   strQuery = strQuery & " replace(t01.data_frmt,'\','\\')"
   strQuery = strQuery & " from report_grp_term t01"
   strQuery = strQuery & " where t01.report_grp_id = " & objForm.Fields("DTA_ReportGrpId").Value
   strQuery = strQuery & " order by t01.sort_order asc"
   strReturn = objSelection.Execute("GROUP_TERM", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "FORMAT"

end sub

'///////////////////////////////////
'// Process format accept routine //
'///////////////////////////////////
sub ProcessFormatAccept()

   dim strStatement
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Format the report group
   '//
   strStatement = "pricelist_configuration.format_group("
   strStatement = strStatement & objForm.Fields("DTA_ReportGrpId").Value & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the report group term format
   '//
   lngCount = clng(objForm.Fields("DET_RepTerCount").Value)
   for i = 1 to lngCount
      strStatement = "pricelist_configuration.format_group_term("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepTerDat" & i).Value) & "'"
      strStatement = strStatement & ")"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

   '//
   '// Commit the report group format
   '//
   strStatement = "pricelist_configuration.format_group_commit"
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
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Set the procedure string
   '//
   strStatement = "pricelist_configuration.delete_group("
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_ReportGrpId").Value)
   strStatement = strStatement & ")"
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
<!--#include file="prc_lst_group_select.inc"-->
<%end sub

'//////////////////////////
'// Paint define routine //
'//////////////////////////
sub PaintDefine()%>
<!--#include file="prc_lst_group_define.inc"-->
<%end sub

'//////////////////////////
'// Paint format routine //
'//////////////////////////
sub PaintFormat()%>
<!--#include file="prc_lst_group_format.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="prc_lst_group_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->