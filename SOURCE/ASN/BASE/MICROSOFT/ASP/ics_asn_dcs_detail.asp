<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_asn_dcs_detail.asp                             //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the ASN DCS detail          //
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
   strTarget = "ics_asn_dcs_detail.asp"
   strHeading = "Advanced Shipping Notice - Distribution Centre - Detail"

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
   '// Retrieve the ASN DCS header 01
   '//
   strQuery = "select"
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
   strQuery = strQuery & " t01.dch_splr_iid,"
   strQuery = strQuery & " t01.dch_splr_nam,"
   strQuery = strQuery & " t01.dch_smsg_nbr,"
   strQuery = strQuery & " t01.dch_smsg_cnt,"
   strQuery = strQuery & " t01.dch_emsg_txt,"
   strQuery = strQuery & " t01.dch_whs_file_ide,"
   strQuery = strQuery & " t01.dch_whs_pick_nbr,"
   strQuery = strQuery & " t01.dch_whs_ship_frm,"
   strQuery = strQuery & " t01.dch_whs_send_dte,"
   strQuery = strQuery & " t01.dch_whs_desp_dte,"
   strQuery = strQuery & " t01.dch_whs_palt_num,"
   strQuery = strQuery & " t01.dch_whs_palt_spc,"
   strQuery = strQuery & " t01.dch_whs_csgn_nbr,"
   strQuery = strQuery & " t01.dch_whs_ship_tar"
   strQuery = strQuery & " from asn_dcs_hdr t01"
   strQuery = strQuery & " where t01.dch_mars_cde = '" & objForm.Fields("QRY_MarsCode").Value & "'"
   strQuery = strQuery & " and t01.dch_pick_nbr = '" & objForm.Fields("QRY_PickNumber").Value & "'"
   strReturn = objSelection.Execute("HEADER01", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Retrieve the ASN DCS header
   '//
   strQuery = "select"
   strQuery = strQuery & " t01.dch_trn_pick_nbr,"
   strQuery = strQuery & " t01.dch_trn_sord_nbr,"
   strQuery = strQuery & " t01.dch_trn_ship_nbr,"
   strQuery = strQuery & " t01.dch_trn_invc_nbr,"
   strQuery = strQuery & " t01.dch_trn_mars_iid,"
   strQuery = strQuery & " t01.dch_trn_cust_iid,"
   strQuery = strQuery & " t01.dch_trn_cust_pon,"
   strQuery = strQuery & " t01.dch_trn_agrd_dte,"
   strQuery = strQuery & " t01.dch_trn_ordr_dte,"
   strQuery = strQuery & " t01.dch_trn_invc_dte,"
   strQuery = strQuery & " t01.dch_trn_splt_shp,"
   strQuery = strQuery & " t01.dch_trn_invc_val,"
   strQuery = strQuery & " t01.dch_trn_invc_gst,"
   strQuery = strQuery & " t01.dch_trn_crcy_cde,"
   strQuery = strQuery & " t01.dch_trn_ship_iid,"
   strQuery = strQuery & " t01.dch_trn_ship_nam,"
   strQuery = strQuery & " t01.dch_trn_dock_nbr,"
   strQuery = strQuery & " t01.dch_trn_byer_ide"
   strQuery = strQuery & " from asn_dcs_hdr t01"
   strQuery = strQuery & " where t01.dch_mars_cde = '" & objForm.Fields("QRY_MarsCode").Value & "'"
   strQuery = strQuery & " and t01.dch_pick_nbr = '" & objForm.Fields("QRY_PickNumber").Value & "'"
   strReturn = objSelection.Execute("HEADER02", strQuery, 0)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Retrieve the ASN DCS detail
   '//
   strQuery = "select"
   strQuery = strQuery & " t01.dcd_whs_sscc_nbr,"
   strQuery = strQuery & " t01.dcd_whs_iden_typ,"
   strQuery = strQuery & " t01.dcd_whs_pack_typ,"
   strQuery = strQuery & " t01.dcd_whs_eqpt_typ,"
   strQuery = strQuery & " t01.dcd_whs_gtin,"
   strQuery = strQuery & " t01.dcd_whs_btch,"
   strQuery = strQuery & " t01.dcd_whs_bbdt,"
   strQuery = strQuery & " t01.dcd_whs_palt_qty,"
   strQuery = strQuery & " t01.dcd_whs_palt_lay,"
   strQuery = strQuery & " t01.dcd_whs_layr_unt"
   strQuery = strQuery & " from asn_dcs_det t01"
   strQuery = strQuery & " where t01.dcd_mars_cde = '" & objForm.Fields("QRY_MarsCode").Value & "'"
   strQuery = strQuery & " and t01.dcd_pick_nbr = '" & objForm.Fields("QRY_PickNumber").Value & "'"
   strQuery = strQuery & " order by t01.dcd_seqn_nbr asc"
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
<!--#include file="ics_asn_dcs_detail.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->