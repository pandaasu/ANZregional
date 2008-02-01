<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_int_monitor.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the interface monitor       //
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
   dim strHeading
   dim bolStrList
   dim bolEndList
   dim aryIntStatus(8)
   dim aryIntClass(8)
   dim objForm
   dim objSecurity
   dim objSelection

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_int_monitor.asp"
   strHeading = "Interface Monitor"
   aryIntStatus(1) = "Load Working"
   aryIntStatus(2) = "Load Working (Errors)"
   aryIntStatus(3) = "Load Completed"
   aryIntStatus(4) = "Load Completed (Errors)"
   aryIntStatus(5) = "Process Working"
   aryIntStatus(6) = "Process Working (Errors)"
   aryIntStatus(7) = "Process Completed"
   aryIntStatus(8) = "Process Completed (Errors)"
   aryIntClass(1) = "clsLabelFG"
   aryIntClass(2) = "clsLabelFR"
   aryIntClass(3) = "clsLabelFN"
   aryIntClass(4) = "clsLabelFR"
   aryIntClass(5) = "clsLabelFG"
   aryIntClass(6) = "clsLabelFR"
   aryIntClass(7) = "clsLabelFN"
   aryIntClass(8) = "clsLabelFR"

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
   strReturn = GetSecurityCheck("ICS_INT_MONITOR")
   if strReturn = "*OK" then

      '//
      '// Get the form data
      '//
      GetForm()

      '//
      '// Process the form
      '//
      call ProcessForm

   end if

   '//
   '// Paint response
   '//
   if strReturn <> "*OK" then
      call PaintFatal
   else
      call PaintForm
   end if

   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing

'//////////////////////////
'// Process form routine //
'//////////////////////////
sub ProcessForm()

   dim strQuery
   dim strWhere
   dim strTest
   dim lngSize
   dim strOrder
   dim intIndex
   dim aryReference
   dim strReference
   dim strRefCode
   dim strRefValue
   dim intRefCount
   dim intTab

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Initialise the selection
   '//
   lngSize = 40
   if objForm.Fields("Mode").Value = "" then
      call objForm.AddField("Mode", "SEARCH")
   end if
   select case objForm.Fields("Mode").Value
      case "SEARCH"
         strWhere = ""
         strTest = " where "
         strOrder = "desc"
      case "PREVIOUS"
         strWhere = " where (t01.het_header > " & objForm.Fields("STR_Header").Value
         strWhere = strWhere & " or (t01.het_header = " & objForm.Fields("STR_Header").Value & " and t01.het_hdr_trace > " & objForm.Fields("STR_Trace").Value & "))"
         strTest = " and "
         strOrder = "asc"
      case "NEXT"
         strWhere = " where (t01.het_header < " & objForm.Fields("END_Header").Value
         strWhere = strWhere & " or (t01.het_header = " & objForm.Fields("END_Header").Value & " and t01.het_hdr_trace < " & objForm.Fields("END_Trace").Value & "))"
         strTest = " and "
         strOrder = "desc"
   end select

   '//
   '// Execute the selection - Advanced search off
   '//
   if objForm.Fields("QRY_Advanced").Value <> "1" then

      strQuery = "select"
      strQuery = strQuery & " to_char(t02.het_header,'FM999999999999990'),"
      strQuery = strQuery & " to_char(t02.het_hdr_trace,'FM99990'),"
      strQuery = strQuery & " to_char(t02.het_execution,'FM999999999999990'),"
      strQuery = strQuery & " t02.het_user,"
      strQuery = strQuery & " to_char(t02.het_str_time, 'YYYY/MM/DD HH24:MI:SS'),"
      strQuery = strQuery & " to_char(t02.het_end_time, 'YYYY/MM/DD HH24:MI:SS'),"
      strQuery = strQuery & " t02.het_status,"
      strQuery = strQuery & " t01.hea_interface,"
      strQuery = strQuery & " t01.int_type,"
      strQuery = strQuery & " t01.int_group"
      strQuery = strQuery & " from (select /*+ FIRST_ROWS */"
      strQuery = strQuery & " t01.hea_header,"
      strQuery = strQuery & " t01.hea_interface,"
      strQuery = strQuery & " t02.int_type,"
      strQuery = strQuery & " t02.int_group"
      strQuery = strQuery & " from lics_header t01, lics_interface t02"
      strQuery = strQuery & " where t01.hea_interface = t02.int_interface(+)"
      if objForm.Fields("QRY_Interface").Value <> "" then
         strQuery = strQuery & " and t01.hea_interface = '" & objForm.Fields("QRY_Interface").Value & "'"
      else
         if objForm.Fields("QRY_Grouping").Value <> "" then
            strQuery = strQuery & " and t01.hea_interface in (select gri_interface from lics_grp_interface where gri_group = '" & objForm.Fields("QRY_Grouping").Value & "')"
         end if
      end if
      strQuery = strQuery & " ) t01, (select t01.* from lics_hdr_trace t01"
      if strWhere <> "" then
         strQuery = strQuery & strWhere
      end if
      strQuery = strQuery & " ) t02"
      strQuery = strQuery & " where t01.hea_header = t02.het_header"
      strQuery = strQuery & " order by t02.het_header " & strOrder & ", t02.het_hdr_trace " & strOrder
      strReturn = objSelection.Execute("LIST", strQuery, lngSize)
      if strReturn <> "*OK" then
         exit sub
      end if

   '//
   '// Execute the selection - Advanced search applied
   '//
   else

      strQuery = "select"
      strQuery = strQuery & " to_char(t02.het_header,'FM999999999999990'),"
      strQuery = strQuery & " to_char(t02.het_hdr_trace,'FM99990'),"
      strQuery = strQuery & " to_char(t02.het_execution,'FM999999999999990'),"
      strQuery = strQuery & " t02.het_user,"
      strQuery = strQuery & " to_char(t02.het_str_time, 'YYYY/MM/DD HH24:MI:SS'),"
      strQuery = strQuery & " to_char(t02.het_end_time, 'YYYY/MM/DD HH24:MI:SS'),"
      strQuery = strQuery & " t02.het_status,"
      strQuery = strQuery & " t01.hea_interface,"
      strQuery = strQuery & " t01.int_type,"
      strQuery = strQuery & " t01.int_group"
      strQuery = strQuery & " from (select /*+ FIRST_ROWS */"
      strQuery = strQuery & " t01.hea_header,"
      strQuery = strQuery & " t01.hea_interface,"
      strQuery = strQuery & " t02.int_type,"
      strQuery = strQuery & " t02.int_group"
      strQuery = strQuery & " from lics_header t01, lics_interface t02"
      if objForm.Fields("QRY_Reference").Value <> "" then
         intRefCount = 0
         strReference = ""
         aryReference = split(objForm.Fields("QRY_Reference").Value , chr(10))
         for intIndex = 0 to ubound(aryReference)
            intTab = instr(aryReference(intIndex), chr(9))
            if intTab <> 0 then
               strRefCode = mid(aryReference(intIndex),1,intTab-1)
               strRefValue = mid(aryReference(intIndex),intTab+1,len(aryReference(intIndex))-(intTab+1))
               if strRefCode <> "" and strRefValue <> "" then
                  intRefCount = intRefCount + 1
                  if strReference = "" then
                     strReference = " where"
                  else
                     strReference = strReference & " or"
                  end if
                  strReference = strReference & " (t01.hes_sea_tag = '" & trim(strRefCode) & "'"
                  strReference = strReference & " and t01.hes_sea_value = '" & trim(strRefValue) & "')"
               end if
            end if
         next
         if strReference <> "" then
            strQuery = strQuery & ", (select t01.hes_header"
            strQuery = strQuery & " from lics_hdr_search t01" & strReference
            strQuery = strQuery & " group by t01.hes_header"
            if objForm.Fields("QRY_Condition").Value = "AND" then
               strQuery = strQuery & " having count(*) = " & intRefCount
            end if
            strQuery = strQuery & ") t03"
         end if
      end if
      strQuery = strQuery & " where t01.hea_interface = t02.int_interface(+)"
      if objForm.Fields("QRY_Reference").Value <> "" and strReference <> "" then
         strQuery = strQuery & " and t01.hea_header = t03.hes_header"
      end if
      if objForm.Fields("QRY_Header").Value <> "" then
         if objForm.Fields("QRY_Test").Value = "EQ" then
            strQuery = strQuery & " and t01.hea_header = " & objForm.Fields("QRY_Header").Value
         end if
         if objForm.Fields("QRY_Test").Value = "LE" then
            strQuery = strQuery & " and t01.hea_header <= " & objForm.Fields("QRY_Header").Value
         end if
         if objForm.Fields("QRY_Test").Value = "GE" then
            strQuery = strQuery & " and t01.hea_header >= " & objForm.Fields("QRY_Header").Value
         end if
      end if
      if objForm.Fields("QRY_Interface").Value <> "" then
         strQuery = strQuery & " and t01.hea_interface = '" & objForm.Fields("QRY_Interface").Value & "'"
      else
         if objForm.Fields("QRY_Grouping").Value <> "" then
            strQuery = strQuery & " and t01.hea_interface in (select gri_interface from lics_grp_interface where gri_group = '" & objForm.Fields("QRY_Grouping").Value & "')"
         end if
      end if
      if objForm.Fields("QRY_Type").Value <> "" then
         strQuery = strQuery & " and t02.int_type = '" & objForm.Fields("QRY_Type").Value & "'"
         strTest = " and "
      end if
      if objForm.Fields("QRY_Process").Value <> "" then
         strQuery = strQuery & " and t02.int_group = '" & objForm.Fields("QRY_Process").Value & "'"
         strTest = " and "
      end if
      strQuery = strQuery & " ) t01, (select t01.* from lics_hdr_trace t01"
      if strWhere <> "" then
         strQuery = strQuery & strWhere
      end if
      if objForm.Fields("QRY_Execution").Value <> "" then
         strQuery = strQuery & strTest & "t01.het_execution = " & objForm.Fields("QRY_Execution").Value
         strTest = " and "
      end if
      if objForm.Fields("QRY_StrTime").Value <> "" then
         strQuery = strQuery & strTest & "to_char(t01.het_str_time,'YYYYMMDDHH24MISS') >= '" & objForm.Fields("QRY_StrTime").Value & "'"
         strTest = " and "
      end if
      if objForm.Fields("QRY_EndTime").Value <> "" then
         strQuery = strQuery & strTest & "to_char(t01.het_end_time,'YYYYMMDDHH24MISS') <= '" & objForm.Fields("QRY_EndTime").Value & "'"
         strTest = " and "
      end if
      if objForm.Fields("QRY_Status").Value <> "" then
         strQuery = strQuery & strTest & "t01.het_status = '" & objForm.Fields("QRY_Status").Value & "'"
         strTest = " and "
      end if
      strQuery = strQuery & " ) t02"
      strQuery = strQuery & " where t01.hea_header = t02.het_header"
      strQuery = strQuery & " order by t02.het_header " & strOrder & ", t02.het_hdr_trace " & strOrder
      strReturn = objSelection.Execute("LIST", strQuery, lngSize)
      if strReturn <> "*OK" then
         exit sub
      end if

   end if

   '//
   '// Set the list start and end indicators
   '//
   bolStrList = true
   bolEndList = true
   if objSelection.ListCount("LIST") <> 0 then
      select case objForm.Fields("Mode").Value
         case "SEARCH"
            bolStrList = true
            if objSelection.ListMore("LIST") = true then
               bolEndList = false
            end if
         case "PREVIOUS"
            if objSelection.ListMore("LIST") = true then
               bolStrList = false
            end if
            bolEndList = false
         case "NEXT"
            bolStrList = false
            if objSelection.ListMore("LIST") = true then
               bolEndList = false
            end if
      end select
   end if

   '//
   '// Execute the grouping selection
   '//
   strQuery = "select t01.gro_group,"
   strQuery = strQuery & " t01.gro_description"
   strQuery = strQuery & " from lics_group t01"
   strQuery = strQuery & " order by t01.gro_description asc"
   strReturn = objSelection.Execute("GROUPING", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the interface selection
   '//
   strQuery = "select t01.int_interface,"
   strQuery = strQuery & " t01.int_description"
   strQuery = strQuery & " from lics_interface t01"
   if objForm.Fields("QRY_Grouping").Value <> "" then
      strQuery = strQuery & " where t01.int_interface in (select gri_interface from lics_grp_interface where gri_group = '" & objForm.Fields("QRY_Grouping").Value & "')"
   end if
   strQuery = strQuery & " order by t01.int_interface asc"
   strReturn = objSelection.Execute("INTERFACE", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the interface type selection
   '//
   strQuery = "select t01.int_type"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " group by t01.int_type"
   strQuery = strQuery & " order by t01.int_type asc"
   strReturn = objSelection.Execute("TYPE", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the interface process selection
   '//
   strQuery = "select t01.int_group"
   strQuery = strQuery & " from lics_interface t01"
   strQuery = strQuery & " group by t01.int_group"
   strQuery = strQuery & " order by t01.int_group asc"
   strReturn = objSelection.Execute("PROCESS", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the interface/stream/triggered backlog
   '//
   lngSize = 0
   strQuery = "select * from"
   strQuery = strQuery & " (select"
   strQuery = strQuery & " t01.hea_interface as backlog_code,"
   strQuery = strQuery & " max(t02.int_description) as backlog_desc,"
   strQuery = strQuery & " max(t02.int_type) as backlog_type,"
   strQuery = strQuery & " max(t02.int_group) as backlog_group,"
   strQuery = strQuery & " count(*) as backlog_count"
   strQuery = strQuery & " from lics_header t01, lics_interface t02"
   strQuery = strQuery & " where t01.hea_interface = t02.int_interface(+)"
   strQuery = strQuery & " and t01.hea_status = '3'"
   strQuery = strQuery & " group by t01.hea_interface"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select"
   strQuery = strQuery & " '*STREAM_'||t01.sta_job_group as backlog_code,"
   strQuery = strQuery & " t01.sta_job_group||' - Stream procedures' as backlog_desc,"
   strQuery = strQuery & " '*STREAMED' as backlog_type,"
   strQuery = strQuery & " t01.sta_job_group as backlog_group,"
   strQuery = strQuery & " count(*) as backlog_count"
   strQuery = strQuery & " from lics_str_action t01"
   strQuery = strQuery & " where t01.sta_status = '*CREATED'"
   strQuery = strQuery & " group by t01.sta_job_group"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select"
   strQuery = strQuery & " '*TRIGGER_'||t01.tri_group as backlog_code,"
   strQuery = strQuery & " t01.tri_group||' - Triggered procedures' as backlog_desc,"
   strQuery = strQuery & " '*TRIGGERED' as backlog_type,"
   strQuery = strQuery & " t01.tri_group as backlog_group,"
   strQuery = strQuery & " count(*) as backlog_count"
   strQuery = strQuery & " from lics_triggered t01"
   strQuery = strQuery & " group by t01.tri_group)"
   strQuery = strQuery & " order by backlog_count desc, backlog_code asc"
   strReturn = objSelection.Execute("BACKLOG", strQuery, lngSize)
   if strReturn <> "*OK" then
      exit sub
   end if

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint form routine //
'//////////////////////////
sub PaintForm()%>
<!--#include file="ics_int_monitor.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->