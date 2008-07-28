<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_asn_dcs_monitor.asp                            //
'// Author  : Steve Gregan                                       //
'// Date    : November 2005                                      //
'// Text    : This script implements the ASN DCS monitor         //
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
   dim strMode
   dim bolStrList
   dim bolEndList
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
   strTarget = "ics_asn_dcs_monitor.asp"
   strHeading = "Advanced Shipping Notice - Distribution Centre - Monitor"

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
   strReturn = GetSecurityCheck("ASN_DCS_MONITOR")
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

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the execution list
   '//
   lngSize = 20
   if objForm.Fields("Mode").Value = "" then
      call objForm.AddField("Mode", "SEARCH")
   end if
   select case objForm.Fields("Mode").Value
      case "SEARCH"
         strWhere = ""
         strTest = " where "
         strOrder = "desc"
      case "PREVIOUS"
         strWhere = " where (t01.dch_mars_cde > '" & objForm.Fields("STR_MarsCode").Value & "'"
         strWhere = strWhere & " or (t01.dch_mars_cde = '" & objForm.Fields("STR_MarsCode").Value & "' and t01.dch_pick_nbr > '" & objForm.Fields("STR_PickNumber").Value & "'))"
         strTest = " and "
         strOrder = "asc"
      case "NEXT"
         strWhere = " where (t01.dch_mars_cde < '" & objForm.Fields("END_MarsCode").Value & "'"
         strWhere = strWhere & " or (t01.dch_mars_cde = '" & objForm.Fields("END_MarsCode").Value & "' and t01.dch_pick_nbr < '" & objForm.Fields("END_PickNumber").Value & "'))"
         strTest = " and "
         strOrder = "desc"
   end select
   strQuery = "select /*+ FIRST_ROWS */"
   strQuery = strQuery & " t01.dch_mars_cde,"
   strQuery = strQuery & " t01.dch_pick_nbr,"
   strQuery = strQuery & " t01.dch_pick_typ,"
   strQuery = strQuery & " to_char(t01.dch_crtn_tim, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " to_char(t01.dch_updt_tim, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " nvl(to_char(t01.dch_smsg_tim, 'YYYY/MM/DD HH24:MI:SS'),'NO'),"
   strQuery = strQuery & " nvl(to_char(t01.dch_smsg_ack, 'YYYY/MM/DD HH24:MI:SS'),'NO'),"
   strQuery = strQuery & " t01.dch_stat_cde,"
   strQuery = strQuery & " decode(t01.dch_delv_ind,'0','N','1','Y',t01.dch_delv_ind),"
   strQuery = strQuery & " decode(t01.dch_sord_ind,'0','N','1','Y',t01.dch_sord_ind),"
   strQuery = strQuery & " decode(t01.dch_ship_ind,'0','N','1','Y',t01.dch_ship_ind),"
   strQuery = strQuery & " decode(t01.dch_invc_ind,'0','N','1','Y',t01.dch_invc_ind),"
   strQuery = strQuery & " t01.dch_smsg_nbr,"
   strQuery = strQuery & " t01.dch_smsg_cnt,"
   strQuery = strQuery & " t01.dch_emsg_txt"
   strQuery = strQuery & " from asn_dcs_hdr t01"
   if strWhere <> "" then
      strQuery = strQuery & strWhere
   end if
   if objForm.Fields("QRY_MarsCode").Value <> "" then
      strQuery = strQuery & strTest & "t01.dch_mars_cde = '" & objForm.Fields("QRY_MarsCode").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_PickNumber").Value <> "" then
      strQuery = strQuery & strTest & "t01.dch_pick_nbr like '%" & objForm.Fields("QRY_PickNumber").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_Status").Value <> "" then
      strQuery = strQuery & strTest & "t01.dch_stat_cde = '" & objForm.Fields("QRY_Status").Value & "'"
      strTest = " and "
   end if
   strQuery = strQuery & " order by t01.dch_mars_cde " & strOrder & ", t01.dch_pick_nbr " & strOrder
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
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
<!--#include file="ics_asn_dcs_monitor.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->