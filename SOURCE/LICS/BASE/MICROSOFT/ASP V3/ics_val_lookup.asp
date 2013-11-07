<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_lookup.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : December 2006                                      //
'// Text    : This script implements the validation              //
'//           lookup functionality                               //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strReturn
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection

   '//
   '// Set the server script timeout to (5 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 300

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
      '// Process the form data
      '//
      strMode = objForm.Fields().Item("Mode")
      select case strMode
         case "GROUP"
            call ProcessGroup
         case else
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
      end select

   end if

   '//
   '// Return the error message
   '//
   if strReturn <> "*OK" then
      Response.Buffer = true
      Response.ContentType = "text/xml"
      Response.AddHeader "Cache-Control", "no-cache"
      Response.Write(strReturn)
   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing

'///////////////////////////
'// Process group routine //
'///////////////////////////
sub ProcessGroup()

   dim intIndex
   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Execute the group selection
   '//
   strQuery = "select level,"
   strQuery = strQuery & " grp_code,"
   strQuery = strQuery & " cla_code,"
   strQuery = strQuery & " typ_code,"
   strQuery = strQuery & " fil_code,"
   strQuery = strQuery & " rul_code,"
   strQuery = strQuery & " sea_flag,"
   strQuery = strQuery & " text"
   strQuery = strQuery & " from (select '*TOP' as par_typ,"
   strQuery = strQuery & " '*TOP' as par_id,"
   strQuery = strQuery & " '*GRP' as typ_id,"
   strQuery = strQuery & " '*ALL' as val_id,"
   strQuery = strQuery & " '*ALL' as grp_code,"
   strQuery = strQuery & " '*ALL' as cla_code,"
   strQuery = strQuery & " '*ALL' as typ_code,"
   strQuery = strQuery & " '*ALL' as fil_code,"
   strQuery = strQuery & " '*ALL' as rul_code,"
   strQuery = strQuery & " 'N' as sea_flag,"
   strQuery = strQuery & " 'Group=[*ALL] - Rules=[*ALL]' as text"
   strQuery = strQuery & " from dual"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select '*TOP' as par_typ,"
   strQuery = strQuery & " '*TOP' as par_id,"
   strQuery = strQuery & " '*GRPCLA' as typ_id,"
   strQuery = strQuery & " 'GRPCLA_'||vag_group as val_id,"
   strQuery = strQuery & " vag_group as grp_code,"
   strQuery = strQuery & " '*ALL' as cla_code,"
   strQuery = strQuery & " '*CLASS' as typ_code,"
   strQuery = strQuery & " '*CLASS' as fil_code,"
   strQuery = strQuery & " '*ALL' as rul_code,"
   strQuery = strQuery & " 'N' as sea_flag,"
   strQuery = strQuery & " 'Group=['||vag_description||'] - Classifications=[*ALL] - Rules=[*ALL]' as text"
   strQuery = strQuery & " from (select * from sap_val_grp order by vag_group asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select '*GRPCLA' as par_typ,"
   strQuery = strQuery & " 'GRPCLA_'||vag_group as par_id,"
   strQuery = strQuery & " '*CLA' as typ_id,"
   strQuery = strQuery & " 'CLA_'||vac_class as val_id,"
   strQuery = strQuery & " vag_group as grp_code,"
   strQuery = strQuery & " vac_class as cla_code,"
   strQuery = strQuery & " '*CLASS' as typ_code,"
   strQuery = strQuery & " '*CLASS' as fil_code,"
   strQuery = strQuery & " '*ALL' as rul_code,"
   strQuery = strQuery & " 'Y' as sea_flag,"
   strQuery = strQuery & " 'Group=['||vag_description||'] - Classification=['||vac_description||'] - Rules=[*ALL]' as text"
   strQuery = strQuery & " from (select * from sap_val_cla, sap_val_grp where vac_group = vag_group order by vac_class asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select '*CLA' as par_typ,"
   strQuery = strQuery & " 'CLA_'||vac_class as par_id,"
   strQuery = strQuery & " '*CLARUL' as typ_id,"
   strQuery = strQuery & " 'CLARUL'||var_rule as val_id,"
   strQuery = strQuery & " vag_group as grp_code,"
   strQuery = strQuery & " vac_class as cla_code,"
   strQuery = strQuery & " '*CLASS' as typ_code,"
   strQuery = strQuery & " '*CLASS' as fil_code,"
   strQuery = strQuery & " var_rule as rul_code,"
   strQuery = strQuery & " 'Y' as sea_flag,"
   strQuery = strQuery & " 'Group=['||vag_description||'] - Classification=['||vac_description||'] - Rule=['||var_description||']' as text"
   strQuery = strQuery & " from (select * from sap_val_cla_rul, sap_val_cla, sap_val_rul, sap_val_grp where vcr_class = vac_class and vcr_rule = var_rule and var_group = vag_group order by vac_class asc, var_rule asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select '*TOP' as par_typ,"
   strQuery = strQuery & " '*TOP' as par_id,"
   strQuery = strQuery & " '*GRPTYP' as typ_id,"
   strQuery = strQuery & " 'GRPTYP_'||vag_group as val_id,"
   strQuery = strQuery & " vag_group as grp_code,"
   strQuery = strQuery & " '*ALL' as cla_code,"
   strQuery = strQuery & " '*CODE' as typ_code,"
   strQuery = strQuery & " '*ALL' as fil_code,"
   strQuery = strQuery & " '*ALL' as rul_code,"
   strQuery = strQuery & " 'N' as sea_flag,"
   strQuery = strQuery & " 'Group=['||vag_description||'] - Types=[*ALL] - Rules=[*ALL]' as text"
   strQuery = strQuery & " from (select * from sap_val_grp order by vag_group asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select '*GRPTYP' as par_typ,"
   strQuery = strQuery & " 'GRPTYP_'||vag_group as par_id,"
   strQuery = strQuery & " '*TYP' as typ_id,"
   strQuery = strQuery & " 'TYP_'||vat_type as val_id,"
   strQuery = strQuery & " vag_group as grp_code,"
   strQuery = strQuery & " '*ALL' as cla_code,"
   strQuery = strQuery & " vat_type as typ_code,"
   strQuery = strQuery & " '*ALL' as fil_code,"
   strQuery = strQuery & " '*ALL' as rul_code,"
   strQuery = strQuery & " 'N' as sea_flag,"
   strQuery = strQuery & " 'Group=['||vag_description||'] - Type=['||vat_description||'] - Rules=[*ALL]' as text"
   strQuery = strQuery & " from (select * from sap_val_typ, sap_val_grp where vat_group = vag_group order by vat_type asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select '*TYP' as par_typ,"
   strQuery = strQuery & " 'TYP_'||vat_type as par_id,"
   strQuery = strQuery & " '*TYPRUL' as typ_id,"
   strQuery = strQuery & " 'TYPRUL_'||var_rule as val_id,"
   strQuery = strQuery & " var_group as grp_code,"
   strQuery = strQuery & " '*ALL' as cla_code,"
   strQuery = strQuery & " vat_type as typ_code,"
   strQuery = strQuery & " '*ALL' as fil_code,"
   strQuery = strQuery & " var_rule as rul_code,"
   strQuery = strQuery & " 'N' as sea_flag,"
   strQuery = strQuery & " 'Group=['||vag_description||'] - Type=['||vat_description||'] - Rule=['||var_description||']' as text"
   strQuery = strQuery & " from (select * from sap_val_typ_rul, sap_val_typ, sap_val_rul, sap_val_grp where vtr_type = vat_type and vtr_rule = var_rule and var_group = vag_group order by vat_type asc, var_rule asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select '*TOP' as par_typ,"
   strQuery = strQuery & " '*TOP' as par_id,"
   strQuery = strQuery & " '*GRPFIL' as typ_id,"
   strQuery = strQuery & " 'GRPFIL_'||vag_group as val_id,"
   strQuery = strQuery & " vag_group as grp_code,"
   strQuery = strQuery & " '*FILTER' as cla_code,"
   strQuery = strQuery & " '*FILTER' as typ_code,"
   strQuery = strQuery & " '*ALL' as fil_code,"
   strQuery = strQuery & " '*MISSING' as rul_code,"
   strQuery = strQuery & " 'N' as sea_flag,"
   strQuery = strQuery & " 'Group=['||vag_description||'] - Filters=[*ALL] - Rule=[*MISSING]' as text"
   strQuery = strQuery & " from (select * from sap_val_grp order by vag_group asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select '*GRPFIL' as par_typ,"
   strQuery = strQuery & " 'GRPFIL_'||vag_group as par_id,"
   strQuery = strQuery & " '*FIL' as typ_id,"
   strQuery = strQuery & " 'FIL_'||vaf_filter as val_id,"
   strQuery = strQuery & " vag_group as grp_code,"
   strQuery = strQuery & " '*FILTER' as cla_code,"
   strQuery = strQuery & " '*FILTER' as typ_code,"
   strQuery = strQuery & " vaf_filter as fil_code,"
   strQuery = strQuery & " '*MISSING' as rul_code,"
   strQuery = strQuery & " 'N' as sea_flag,"
   strQuery = strQuery & " 'Group=['||vag_description||'] - Filter=['||vaf_description||'] - Rule=[*MISSING]' as text"
   strQuery = strQuery & " from (select * from sap_val_fil, sap_val_grp where vaf_group = vag_group order by vaf_filter asc)"
   strQuery = strQuery & " ) start with par_typ = '*TOP'"
   strQuery = strQuery & " connect by prior typ_id = par_typ and prior val_id = par_id"
   strReturn = objSelection.Execute("GROUP", strQuery, 0)

   '//
   '// Return the response string
   '//
   if strReturn = "*OK" then
      Response.Buffer = true
      Response.ContentType = "text/xml"
      Response.AddHeader "Cache-Control", "no-cache"
      Response.Write(strReturn)
      for intIndex = 0 to clng(objSelection.ListCount("GROUP")) - 1
         call Response.Write(objSelection.ListValue01("GROUP",intIndex) & chr(9) & objSelection.ListValue08("GROUP",intIndex) & chr(10))
      next
   end if

end sub%>
<!--#include file="ics_std_code.inc"-->