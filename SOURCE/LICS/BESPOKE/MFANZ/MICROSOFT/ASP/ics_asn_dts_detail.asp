<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_asn_dts_detail.asp                             //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the ASN DTS detail          //
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
   strTarget = "ics_asn_dts_detail.asp"
   strHeading = "Advanced Shipping Notice - Direct To Store - Detail"

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
   '// Retrieve the ASN DTS header
   '//
   strQuery = "select"
   strQuery = strQuery & " t01.dth_mars_cde,"
   strQuery = strQuery & " t01.dth_load_nbr,"
   strQuery = strQuery & " to_char(t01.dth_crtn_tim, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " to_char(t01.dth_updt_tim, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " t01.dth_stat_cde,"
   strQuery = strQuery & " t01.dth_delv_cnt,"
   strQuery = strQuery & " t01.dth_ship_cnt,"
   strQuery = strQuery & " t01.dth_pick_cnt,"
   strQuery = strQuery & " t01.dth_sord_cnt,"
   strQuery = strQuery & " t01.dth_invc_cnt,"
   strQuery = strQuery & " t01.dth_sndr_iid,"
   strQuery = strQuery & " t01.dth_sndr_nam,"
   strQuery = strQuery & " t01.dth_emsg_txt"
   strQuery = strQuery & " from asn_dts_hdr t01"
   strQuery = strQuery & " where t01.dth_mars_cde = '" & objForm.Fields("QRY_MarsCode").Value & "'"
   strQuery = strQuery & " and t01.dth_load_nbr = '" & objForm.Fields("QRY_LoadNumber").Value & "'"
   strReturn = objSelection.Execute("HEADER", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Retrieve the ASN DTS detail
   '//
   strQuery = "select"
   strQuery = strQuery & " dtd_whs_whse_cde,"
   strQuery = strQuery & " dtd_whs_csgn_nbr,"
   strQuery = strQuery & " dtd_whs_delv_nbr,"
   strQuery = strQuery & " dtd_whs_delv_lin,"
   strQuery = strQuery & " dtd_whs_matl_cde,"
   strQuery = strQuery & " dtd_whs_ship_uom,"
   strQuery = strQuery & " dtd_whs_ship_qty,"
   strQuery = strQuery & " dtd_whs_invt_sts,"
   strQuery = strQuery & " dtd_whs_sscc_nbr,"
   strQuery = strQuery & " dtd_whs_sscc_lbl,"
   strQuery = strQuery & " dtd_whs_load_nbr"
   strQuery = strQuery & " from asn_dts_det t01"
   strQuery = strQuery & " where t01.dtd_mars_cde = '" & objForm.Fields("QRY_MarsCode").Value & "'"
   strQuery = strQuery & " and t01.dtd_load_nbr = '" & objForm.Fields("QRY_LoadNumber").Value & "'"
   strQuery = strQuery & " order by t01.dtd_seqn_nbr asc"
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
<!--#include file="ics_asn_dts_detail.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->