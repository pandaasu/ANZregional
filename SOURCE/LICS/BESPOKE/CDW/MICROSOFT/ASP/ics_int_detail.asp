<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_int_detail.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the interface detail        //
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
   dim aryIntStatus(8)
   dim aryIntClass(8)
   dim lngCount
   dim strDataHead
   dim lngMaximum
   dim objForm
   dim objSecurity
   dim objSelection
   dim objFunction

   '//
   '// Set the server script timeout to (20 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "ics_int_detail.asp"
   strHeading = "Interface Detail"
   aryIntStatus(1) = "Load Working"
   aryIntStatus(2) = "Load Working (Errors)"
   aryIntStatus(3) = "Load Completed"
   aryIntStatus(4) = "Load Completed (Errors)"
   aryIntStatus(5) = "Process Working"
   aryIntStatus(6) = "Process Working (Errors)"
   aryIntStatus(7) = "Process Completed"
   aryIntStatus(8) = "Process Completed (Errors)"
   aryIntClass(1) = "clsWorking"
   aryIntClass(2) = "clsError"
   aryIntClass(3) = "clsNormal"
   aryIntClass(4) = "clsError"
   aryIntClass(5) = "clsWorking"
   aryIntClass(6) = "clsError"
   aryIntClass(7) = "clsNormal"
   aryIntClass(8) = "clsError"
   lngMaximum = 50001

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
   set objFunction = nothing

'//////////////////////////
'// Process form routine //
'//////////////////////////
sub ProcessForm()

   dim strQuery
   dim strStatement

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the interface header detail
   '//
   strQuery = "select"
   strQuery = strQuery & " case when t02.hea_fil_name = t02.hea_msg_name then to_char(t01.het_header,'FM999999999999990') || ' (' || t02.hea_fil_name || ')'"
   strQuery = strQuery & " else to_char(t01.het_header,'FM999999999999990') || ' (' || t02.hea_fil_name || ' : Message = ' || t02.hea_msg_name || ')' end,"
   strQuery = strQuery & " to_char(t01.het_hdr_trace,'FM99990'),"
   strQuery = strQuery & " t02.hea_interface || ' : ' || t03.int_description,"
   strQuery = strQuery & " t03.int_type,"
   strQuery = strQuery & " t03.int_group,"
   strQuery = strQuery & " to_char(t01.het_execution,'FM999999999999990'),"
   strQuery = strQuery & " t01.het_user,"
   strQuery = strQuery & " to_char(t01.het_str_time, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " to_char(t01.het_end_time, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " t01.het_status,"
   strQuery = strQuery & " t04.errind"
   strQuery = strQuery & " from lics_hdr_trace t01, lics_header t02, lics_interface t03,"
   strQuery = strQuery & " (select t05.hem_header, t05.hem_hdr_trace, 'x' as errind from lics_hdr_message t05"
   strQuery = strQuery & " where t05.hem_header = " & objForm.Fields("QRY_Header").Value
   strQuery = strQuery & " and t05.hem_hdr_trace = " & objForm.Fields("QRY_Trace").Value
   strQuery = strQuery & " group by t05.hem_header, t05.hem_hdr_trace) t04"
   strQuery = strQuery & " where t01.het_header = t02.hea_header(+)"
   strQuery = strQuery & " and t02.hea_interface = t03.int_interface(+)"
   strQuery = strQuery & " and t01.het_header = t04.hem_header(+)"
   strQuery = strQuery & " and t01.het_hdr_trace = t04.hem_hdr_trace(+)"
   strQuery = strQuery & " and t01.het_header = " & objForm.Fields("QRY_Header").Value
   strQuery = strQuery & " and t01.het_hdr_trace = " & objForm.Fields("QRY_Trace").Value
   strReturn = objSelection.Execute("DETAIL", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the interface view data when required
   '// **retrieves the data from the archive directory
   '//
   if objSelection.ListValue04("DETAIL",0) <> "*INBOUND" then

      '//
      '// Create the function object
      '//
      set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
      set objFunction.Security = objSecurity

      '//
      '// Retrieve the interface data
      '//
      strStatement = "lics_interface_view.retrieve(" & objForm.Fields("QRY_Header").Value & ")"
      strReturn = objFunction.Execute(strStatement)
      if strReturn <> "*OK" then
         strReturn = FormatError(strReturn)
         exit sub
      end if

   end if

   '//
   '// Retrieve the interface data as required
   '// **NOTE** processes maximum viewable rows
   '//
   if objSelection.ListValue04("DETAIL",0) = "*INBOUND" then
      if objForm.Fields("QRY_Error").Value <> "Y" then
         strQuery = "select * from"
         strQuery = strQuery & " (select t01.dat_record,"
         strQuery = strQuery & " to_char(t01.dat_dta_seq,'FM999999990'),"
         strQuery = strQuery & " t02.errind"
         strQuery = strQuery & " from lics_data t01,"
         strQuery = strQuery & " (select t03.dam_dta_seq, 'x' as errind from lics_dta_message t03"
         strQuery = strQuery & " where t03.dam_header = " & objForm.Fields("QRY_Header").Value
         strQuery = strQuery & " and t03.dam_hdr_trace = " & objForm.Fields("QRY_Trace").Value
         strQuery = strQuery & " group by t03.dam_dta_seq) t02"
         strQuery = strQuery & " where t01.dat_dta_seq = t02.dam_dta_seq(+)"
         strQuery = strQuery & " and t01.dat_header = " & objForm.Fields("QRY_Header").Value
         strQuery = strQuery & " and rownum <= " & lngMaximum
         strQuery = strQuery & " order by t01.dat_dta_seq asc)"
         strQuery = strQuery & " where rownum <= " & lngMaximum
         strReturn = objSelection.Execute("DATA", strQuery, 0)
         if strReturn <> "*OK" then
            exit sub
         end if
      else
         strQuery = "select * from"
         strQuery = strQuery & " (select t01.dat_record,"
         strQuery = strQuery & " to_char(t01.dat_dta_seq,'FM999999990'),"
         strQuery = strQuery & " t02.errind"
         strQuery = strQuery & " from lics_data t01,"
         strQuery = strQuery & " (select t03.dam_dta_seq, 'x' as errind from lics_dta_message t03"
         strQuery = strQuery & " where t03.dam_header = " & objForm.Fields("QRY_Header").Value
         strQuery = strQuery & " and t03.dam_hdr_trace = " & objForm.Fields("QRY_Trace").Value
         strQuery = strQuery & " group by t03.dam_dta_seq) t02"
         strQuery = strQuery & " where t01.dat_dta_seq = t02.dam_dta_seq"
         strQuery = strQuery & " and t01.dat_header = " & objForm.Fields("QRY_Header").Value
         strQuery = strQuery & " order by t01.dat_dta_seq asc)"
         strQuery = strQuery & " where rownum <= " & lngMaximum
         strReturn = objSelection.Execute("DATA", strQuery, 0)
         if strReturn <> "*OK" then
            exit sub
         end if
      end if
   else
      strQuery = "select * from"
      strQuery = strQuery & " (select t01.dat_record from lics_temp t01 order by t01.dat_dta_seq asc)"
      strQuery = strQuery & " where rownum <= " & lngMaximum
      strReturn = objSelection.Execute("DATA", strQuery, 0)
      if strReturn <> "*OK" then
         exit sub
      end if
   end if

   '//
   '// Retrieve the interface data length as required
   '//
   if objSelection.ListValue04("DETAIL",0) = "*INBOUND" then
      strQuery = "select"
      strQuery = strQuery & " nvl(max(length(t01.dat_record)),0)"
      strQuery = strQuery & " from lics_data t01"
      strQuery = strQuery & " where t01.dat_header = " & objForm.Fields("QRY_Header").Value
      strReturn = objSelection.Execute("COUNT", strQuery, 0)
      if strReturn <> "*OK" then
         exit sub
      end if
      strDataHead = ""
      lngCount = clng(objSelection.ListValue01("COUNT",0))
      for i = 1 to lngCount
         if i mod 10 = 0 then
            strDataHead = strDataHead & cstr(i / 10) & "0"
         else
            if len(strDataHead) < i then
               strDataHead = strDataHead & "."
            end if
         end if
      next
   else
      strQuery = "select"
      strQuery = strQuery & " nvl(max(length(t01.dat_record)),0)"
      strQuery = strQuery & " from lics_temp t01"
      strReturn = objSelection.Execute("COUNT", strQuery, 0)
      if strReturn <> "*OK" then
         exit sub
      end if
      strDataHead = ""
      lngCount = clng(objSelection.ListValue01("COUNT",0))
      for i = 1 to lngCount
         if i mod 10 = 0 then
            strDataHead = strDataHead & cstr(i / 10) & "0"
         else
            if len(strDataHead) < i then
               strDataHead = strDataHead & "."
            end if
         end if
      next
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
<!--#include file="ics_int_detail.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->