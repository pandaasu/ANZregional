<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_asn_dts_msg_detail.asp                         //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the ASN DTS message         //
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
   strTarget = "ics_asn_dts_msg_detail.asp"
   strHeading = "Advanced Shipping Notice - Direct To Store - Message Detail"

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
   '// Retrieve the ASN DTS message header
   '//
   strQuery = "select"
   strQuery = strQuery & " t01.dmh_smsg_nbr,"
   strQuery = strQuery & " to_char(t01.dmh_crtn_tim,'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " to_char(t01.dmh_updt_tim,'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " nvl(to_char(t01.dmh_smsg_tim,'YYYY/MM/DD HH24:MI:SS'),'NO'),"
   strQuery = strQuery & " nvl(to_char(t01.dmh_smsg_ack,'YYYY/MM/DD HH24:MI:SS'),'NO'),"
   strQuery = strQuery & " t01.dmh_smsg_cnt,"
   strQuery = strQuery & " t01.dmh_mars_cde,"
   strQuery = strQuery & " t01.dmh_load_nbr,"
   strQuery = strQuery & " t01.dmh_sndr_iid,"
   strQuery = strQuery & " t01.dmh_rcvr_iid,"
   strQuery = strQuery & " t01.dmh_splr_cde,"
   strQuery = strQuery & " t01.dmh_invc_nbr,"
   strQuery = strQuery & " t01.dmh_ship_nbr,"
   strQuery = strQuery & " t01.dmh_ship_iid,"
   strQuery = strQuery & " t01.dmh_csgn_nbr,"
   strQuery = strQuery & " t01.dmh_cust_pon,"
   strQuery = strQuery & " t01.dmh_cust_dte,"
   strQuery = strQuery & " t01.dmh_reqd_dte,"
   strQuery = strQuery & " t01.dmh_desp_dte,"
   strQuery = strQuery & " t01.dmh_edel_dte"
   strQuery = strQuery & " from asn_dts_msg_hdr t01"
   strQuery = strQuery & " where t01.dmh_smsg_nbr = " & objForm.Fields("QRY_SendNumber").Value
   strReturn = objSelection.Execute("HEADER", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Retrieve the ASN DTS message detail
   '//
   strQuery = "select"
   strQuery = strQuery & " dmd_whse_cde,"
   strQuery = strQuery & " dmd_invc_nbr,"
   strQuery = strQuery & " dmd_invc_lin,"
   strQuery = strQuery & " dmd_sscc_nbr,"
   strQuery = strQuery & " dmd_gros_wgt,"
   strQuery = strQuery & " to_char(dmd_expy_dte,'YYYY/MM/DD'),"
   strQuery = strQuery & " dmd_dang_ind,"
   strQuery = strQuery & " dmd_iapn_cde,"
   strQuery = strQuery & " dmd_ship_qty,"
   strQuery = strQuery & " dmd_sord_qty,"
   strQuery = strQuery & " dmd_delv_loc"
   strQuery = strQuery & " from asn_dts_msg_det t01"
   strQuery = strQuery & " where t01.dmd_smsg_nbr = " & objForm.Fields("QRY_SendNumber").Value
   strQuery = strQuery & " order by t01.dmd_seqn_nbr asc"
   strReturn = objSelection.Execute("DETAIL", strQuery, 0)
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
<!--#include file="ics_asn_dts_msg_detail.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->