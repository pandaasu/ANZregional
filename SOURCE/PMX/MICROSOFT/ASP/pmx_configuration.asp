<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PMX (PROMAX)                                       //
'// Script  : pmx_configuration.asp                              //
'// Author  : Rebekah Arnold                                     //
'// Date    : September 2005                                     //
'// Text    : This script implements the interface for job       //
'//           configuration and maintenance functionality        //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim strBase
   dim strTarget
   dim strStatus
   dim strReturn
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection
   dim objModify
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "pmx_configuration.asp"
   strHeading = "Job Configuration & Maintenance"

   '//
   '// Get the base string
   '//
   strBase = GetBase()

   '//
   '// Get the status
   '//
   strStatus = GetStatus()

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
         case ""
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
      case ""
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
   set objModify = nothing

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
   '// Retrieve the job list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.pmx_job_cnfgn_id,"
   strQuery = strQuery & " t01.pstbx_short_name,"
   strQuery = strQuery & " t01.pstbx_long_name,"
   strQuery = strQuery & " t01.pstbx_job,"
   strQuery = strQuery & " t01.job_type_code,"
   strQuery = strQuery & " t01.max_run_time,"
   strQuery = strQuery & " t01.email_group,"
   strQuery = strQuery & " t01.alert_group,"
   strQuery = strQuery & " t01.job_prty,"
   strQuery = strQuery & " t01.job_status,"
   strQuery = strQuery & " t01.pmx_job_cnfgn_lupdp,"
   strQuery = strQuery & " t01.pmx_job_cnfgn_lupdt"
   strQuery = strQuery & " from pds_pmx_job_cnfgn t01"
   strQuery = strQuery & " order by t01.pmx_job_cnfgn_id asc"
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
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("INP_IntJobID", "")
   call objForm.AddField("INP_StrShortName", "")
   call objForm.AddField("INP_StrLongName", "")
   call objForm.AddField("INP_StrPostboxJob", "")
   call objForm.AddField("INP_IntJobType", 68) ' default value
   call objForm.AddField("INP_IntMaxRunTime", "")
   call objForm.AddField("INP_StrEmail", "")
   call objForm.AddField("INP_StrAlertGroup", "")
   call objForm.AddField("INP_StrPriority", "")
   call objForm.AddField("INP_StrStatus", "")
   
   '// Populate the job type list
   ProcessJobTypes()
   
   '// Populate the email list
   ProcessEmailList(objForm.Fields("INP_IntJobType").Value)

   '// Populate the alert list
   ProcessAlertGroups()
   
   '//
   '// Set the mode
   '//
   strMode = "INSERT"

end sub

sub ProcessJobTypes()

   dim strQuery
   dim lngSize
 
   '//
   '// Retrieve Job Type Descriptions
   '//
   lngSize = 0
   strQuery = "select distinct"
   strQuery = strQuery & " t01.job_type_code,"
   strQuery = strQuery & " t01.job_type_desc"
   strQuery = strQuery & " from pds_job_type t01"
   strQuery = strQuery & " order by t01.job_type_desc asc"
   strReturn = objSelection.Execute("JOBTYPES", strQuery, lngSize)
   
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if
   
end sub

'///////////////////////////////////
'// Process retrieve email list   //
'///////////////////////////////////
sub ProcessEmailList(intJobTypeCode)

   dim strQuery
   dim lngSize

   '//
   '// Retrieve Email Groups
   '//
   lngSize = 0
   strQuery = "select distinct"
   strQuery = strQuery & " t01.email_address"
   strQuery = strQuery & " from pds_email_list t01"
   strQuery = strQuery & " where t01.job_type_code = " & intJobTypeCode
   strQuery = strQuery & " order by t01.email_address asc"
   strReturn = objSelection.Execute("EMAILS", strQuery, lngSize)

   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

sub ProcessAlertGroups()

   dim strQuery
   dim lngSize

   '//
   '// Retrieve Alert Groups
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.alert_group"
   strQuery = strQuery & " from pds_email_list t01"
   strQuery = strQuery & " order by t01.alert_group asc"
   'strReturn = objSelection.Execute("ALERTS", strQuery, lngSize)
   
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if
   
end sub

'///////////////////////////////////
'// Process insert accept routine //
'///////////////////////////////////
sub ProcessInsertAccept()

   dim strQuery

   '//
   '// Create the modify object
   '//
   Set objModify = Server.CreateObject("ICS_MODIFY.Object")
   Set objModify.Security = objSecurity

   '//
   '// Insert the job
   '//
   strQuery = "insert into pds_pmx_job_cnfgn "
   strQuery = strQuery & " VALUES("
   strQuery = strQuery & "0,"
   strQuery = strQuery & "'" & objSecurity.FixString(objForm.Fields("INP_StrShortName").Value) & "',"
   strQuery = strQuery & "'" & objSecurity.FixString(objForm.Fields("INP_StrLongName").Value) & "',"
   strQuery = strQuery & "'" & objSecurity.FixString(objForm.Fields("INP_StrPostboxJob").Value) & "',"
   strQuery = strQuery & objForm.Fields("INP_IntJobType").Value & ","
   strQuery = strQuery & objForm.Fields("INP_IntMaxRunTime").Value & ","
   strQuery = strQuery & "'" & objSecurity.FixString(objForm.Fields("INP_StrEmail").Value) & "',"
   strQuery = strQuery & "'" & objSecurity.FixString(objForm.Fields("INP_StrAlertGroup").Value) & "',"
   strQuery = strQuery & "'" & objSecurity.FixString(objForm.Fields("INP_StrPriority").Value) & "',"
   strQuery = strQuery & "'" & objSecurity.FixString(objForm.Fields("INP_StrStatus").Value) & "',"
   strQuery = strQuery & "'" & objSecurity.FixString(UCase(Trim(Request.ServerVariables("LOGON_USER")))) &  "', "
   strQuery = strQuery & " SYSDATE"
   strQuery = strQuery & ")"
   strReturn = objModify.Execute(strQuery)
         
   if strReturn <> "*OK" then
      strMode = ""
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = ""
   call ProcessSelect

end sub

'/////////////////////////////////
'// Process update load routine //
'/////////////////////////////////
sub ProcessUpdateLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the job data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.pmx_job_cnfgn_id,"
   strQuery = strQuery & " t01.pstbx_short_name,"
   strQuery = strQuery & " t01.pstbx_long_name,"
   strQuery = strQuery & " t01.pstbx_job,"
   strQuery = strQuery & " t01.job_type_code,"
   strQuery = strQuery & " t01.max_run_time,"
   strQuery = strQuery & " t01.email_group,"
   strQuery = strQuery & " t01.alert_group,"
   strQuery = strQuery & " t01.job_prty,"
   strQuery = strQuery & " t01.job_status"
   strQuery = strQuery & " from pds_pmx_job_cnfgn t01"
   strQuery = strQuery & " where t01.pmx_job_cnfgn_id = '" & objForm.Fields("DTA_IntJobID").Value & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)

   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_IntJobID", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrShortName", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrLongName", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrPostboxJob", objSelection.ListValue04("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntJobType", objSelection.ListValue05("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntMaxRunTime", objSelection.ListValue06("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrEmail", objSelection.ListValue07("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrAlertGroup", objSelection.ListValue08("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrPriority", objSelection.ListValue09("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrStatus", objSelection.ListValue10("LIST",objSelection.ListLower("LIST")))
   
   '// Populate the job type list
   ProcessJobTypes()
   
   '// Populate the email list
   ProcessEmailList(objForm.Fields("DTA_IntJobType").Value)
   
   '// Populate the alert list
   ProcessAlertGroups()
      
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

   '//
   '// Create the modify object
   '//
   Set objModify = Server.CreateObject("ICS_MODIFY.Object")
   Set objModify.Security = objSecurity

   '//
   '// Update the job
   '//
   strQuery = "UPDATE pds_pmx_job_cnfgn t01"
   strQuery = strQuery & " SET "
   strQuery = strQuery & " t01.pstbx_short_name='" & objSecurity.FixString(objForm.Fields("DTA_StrShortName").Value) & "', "
   strQuery = strQuery & " t01.pstbx_long_name='" & objSecurity.FixString(objForm.Fields("DTA_StrLongName").Value) & "', "
   strQuery = strQuery & " t01.pstbx_job='" & objSecurity.FixString(objForm.Fields("DTA_StrPostboxJob").Value) & "', "
   strQuery = strQuery & " t01.job_type_code=" & objForm.Fields("DTA_IntJobType").Value & ", "
   strQuery = strQuery & " t01.max_run_time=" & objForm.Fields("DTA_IntMaxRunTime").Value & ", "
   strQuery = strQuery & " t01.email_group='" & objSecurity.FixString(objForm.Fields("DTA_StrEmail").Value) & "', "
   strQuery = strQuery & " t01.alert_group='" & objSecurity.FixString(objForm.Fields("DTA_StrAlertGroup").Value) & "', "
   strQuery = strQuery & " t01.job_prty='" & objSecurity.FixString(objForm.Fields("DTA_StrPriority").Value) & "', "
   strQuery = strQuery & " t01.job_status='" & objSecurity.FixString(objForm.Fields("DTA_StrStatus").Value) & "', "
   strQuery = strQuery & " t01.pmx_job_cnfgn_lupdp='" & objSecurity.FixString(UCase(Trim(Request.ServerVariables("LOGON_USER")))) &  "', "
   strQuery = strQuery & " t01.pmx_job_cnfgn_lupdt=" & "SYSDATE"
   strQuery = strQuery & " where t01.pmx_job_cnfgn_id=" & objForm.Fields("DTA_IntJobID").Value
   strReturn = objModify.Execute(strQuery)

   if strReturn <> "*OK" then
      strMode = "UPDATE"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = ""
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
   '// Retrieve the job data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.pmx_job_cnfgn_id,"
   strQuery = strQuery & " t01.pstbx_short_name,"
   strQuery = strQuery & " t01.pstbx_long_name,"
   strQuery = strQuery & " t01.pstbx_job,"
   strQuery = strQuery & " t01.job_type_code,"
   strQuery = strQuery & " t01.max_run_time,"
   strQuery = strQuery & " t01.email_group,"
   strQuery = strQuery & " t01.alert_group,"
   strQuery = strQuery & " t01.job_prty,"
   strQuery = strQuery & " t01.job_status,"
   strQuery = strQuery & " t01.pmx_job_cnfgn_lupdp,"
   strQuery = strQuery & " t01.pmx_job_cnfgn_lupdt"
   strQuery = strQuery & " from pds_pmx_job_cnfgn t01"
   strQuery = strQuery & " where t01.pmx_job_cnfgn_id = '" & objForm.Fields("DTA_IntJobID").Value & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   
   if strReturn <> "*OK" then
      strMode = "SELECT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_IntJobID", objSelection.ListValue01("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrShortName", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrLongName", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrPostboxJob", objSelection.ListValue04("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntJobType", objSelection.ListValue05("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_IntMaxRunTime", objSelection.ListValue06("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrEmail", objSelection.ListValue07("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrAlertGroup", objSelection.ListValue08("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrPriority", objSelection.ListValue09("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrStatus", objSelection.ListValue10("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrUpdated", objSelection.ListValue11("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_StrDateTime", objSelection.ListValue12("LIST",objSelection.ListLower("LIST")))

   '//
   '// Set the mode
   '//
   strMode = "DELETE"

end sub

'/////////////////////////////////
'// Process delete accept routine //
'/////////////////////////////////
sub ProcessDeleteAccept()

   dim strQuery

   '//
   '// Create the modify object
   '//
   Set objModify = Server.CreateObject("ICS_MODIFY.Object")
   Set objModify.Security = objSecurity

   '//
   '// Delete the job
   '//
   strQuery = "delete"
   strQuery = strQuery & " from pds_pmx_job_cnfgn"
   strQuery = strQuery & " where pmx_job_cnfgn_id = '" & objForm.Fields("DTA_IntJobID").Value & "'"
   strReturn = objModify.Execute(strQuery)
      
   if strReturn <> "*OK" then
      strMode = "DELETE"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = ""
   call ProcessSelect

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="../ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint prompt routine //
'//////////////////////////
sub PaintSelect()%>
<!--#include file="pmx_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="pmx_configuration_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="pmx_configuration_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="pmx_configuration_delete.inc"-->
<%end sub%>
<!--#include file="../ics_std_code.inc"-->