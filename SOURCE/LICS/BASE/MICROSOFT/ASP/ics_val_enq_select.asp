<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_enq_select.asp                             //
'// Author  : Steve Gregan                                       //
'// Date    : August 2005                                        //
'// Text    : This script implements the validation enquiry      //
'//           selection functionality                            //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim j
   dim strBase
   dim strTarget
   dim strStatus
   dim strCharset
   dim strReturn
   dim strError
   dim strHeading
   dim strMode
   dim objSecurity
   dim objSelection

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

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
      call ProcessRequest
   end if

   '//
   '// Paint response
   '//
   if strReturn <> "*OK" then
      call PaintFatal
   else
      call PaintResponse
   end if
 
   '//
   '// Destroy references
   '//
   set objSecurity = nothing
   set objSelection = nothing

'/////////////////////////////
'// Process request routine //
'/////////////////////////////
sub ProcessRequest()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the validation selection tree
   '//
   lngSize = 0
   strQuery = "select level, val_desc, val_script from ("
   strQuery = strQuery & " select 'MNUGRP' as typ_id, '*TOP' as par_typ, '*TOP' as par_id, 'MNUGRP' as val_id, 'GROUPS' as val_desc, '*NONE' as val_script from dual"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select 'GRP' as typ_id, 'MNUGRP' as par_typ, 'MNUGRP' as par_id, vag_group as val_id, '('||vag_group||') '||vag_description as val_desc, 'ics_val_grp.asp?Mode=ENQUIRY_LOAD&DTA_VagGroup='||vag_group as val_script from (select * from sap_val_grp order by vag_group asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select 'GRPRUL' as typ_id, 'GRP' as par_typ, vag_group as par_id, 'RUL_'||vag_group as val_id, 'RULES' as val_desc, '*NONE' as val_script from (select * from sap_val_grp order by vag_group asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select 'RUL' as typ_id, 'GRPRUL' as par_typ, 'RUL_'||var_group as par_id, var_rule as val_id, '('||var_rule||') '||var_description as val_desc, 'ics_val_rul.asp?Mode=ENQUIRY_LOAD&DTA_VarRule='||var_rule as val_script from (select * from sap_val_rul order by var_group asc, var_rule asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select 'GRPCLA' as typ_id, 'GRP' as par_typ, vag_group as par_id, 'CLA_'||vag_group as val_id, 'CLASSIFICATIONS' as val_desc, '*NONE' as val_script from (select * from sap_val_grp order by vag_group asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select 'CLA' as typ_id, 'GRPCLA' as par_typ, 'CLA_'||vac_group as par_id, vac_class as val_id, '('||vac_class||') '||vac_description as val_desc, 'ics_val_cla.asp?Mode=ENQUIRY_LOAD&DTA_VacClass='||vac_class as val_script from (select * from sap_val_cla order by vac_group asc, vac_class asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select 'GRPTYP' as typ_id, 'GRP' as par_typ, vag_group as par_id, 'TYP_'||vag_group as val_id, 'TYPES' as val_desc, '*NONE' as val_script from (select * from sap_val_grp order by vag_group asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select 'TYP' as typ_id, 'GRPTYP' as par_typ, 'TYP_'||vat_group as par_id, vat_type as val_id, '('||vat_type||') '||vat_description as val_desc, 'ics_val_typ.asp?Mode=ENQUIRY_LOAD&DTA_VatType='||vat_type as val_script from (select * from sap_val_typ order by vat_group asc, vat_type asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select 'GRPFIL' as typ_id, 'GRP' as par_typ, vag_group as par_id, 'FIL_'||vag_group as val_id, 'FILTERS' as val_desc, '*NONE' as val_script from (select * from sap_val_grp order by vag_group asc)"
   strQuery = strQuery & " union all"
   strQuery = strQuery & " select 'FIL' as typ_id, 'GRPFIL' as par_typ, 'FIL_'||vaf_group as par_id, vaf_filter as val_id, '('||vaf_filter||') '||vaf_description as val_desc, 'ics_val_fil.asp?Mode=ENQUIRY_LOAD&DTA_VafFilter='||vaf_filter as val_script from (select * from sap_val_fil order by vaf_group asc, vaf_filter asc)"
   strQuery = strQuery & " ) start with par_typ = '*TOP'"
   strQuery = strQuery & " connect by prior typ_id = par_typ and prior val_id = par_id"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<html>
<script language="javascript">
<!--
   function selectNode(strScript) {
      parent.setEnquiry('<%=strBase%>' + strScript);
      return;
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody01" scroll="auto"><%if objSelection.ListCount("LIST") <> 0 then%>
   <table class="clsGrid01" align=left valign=top cellpadding=0 cellspacing=0 cols=1>
      <%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
         <tr"><td class="clsLabelBN" align=left nowrap><nobr><%for j = 1 to cint(objSelection.ListValue01("LIST",i)) - 1%>
            <IMG src="tree_nbsp.gif" align=absmiddle><%next%>
            <font <%if objSelection.ListValue03("LIST",i) = "*NONE" then%>class="clsLabelBB"<%else%>class="clsSelectLNB"<%end if%> align=left valign=center <%if objSelection.ListValue03("LIST",i) <> "*NONE" then%>onClick="selectNode('<%=objSelection.ListValue03("LIST",i)%>');"<%end if%>><%=objSelection.ListValue02("LIST",i)%></font>
         </nobr></td></tr>
      <%next%>
   </table><%else%>
   <table class="clsGrid01" align=center valign=center height="100%" cellpadding=0 cellspacing=0 cols=1>
      <tr><td class="clsLabelBB" align=center nowrap><nobr>VALIDATION NOT DEFINED</nobr></td></tr>
   </table><%end if%>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->