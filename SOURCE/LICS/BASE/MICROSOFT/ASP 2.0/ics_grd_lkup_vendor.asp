<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_log_monitor.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : February 2004                                      //
'// Text    : This script implements the log monitor             //
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
   strTarget = "ics_grd_lkup_vendor.asp"
   strHeading = "GRD Vendor XREF Lookup"

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
   strReturn = GetSecurityCheck("ICS_GRD_LKUP_VENDOR")
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
   dim strGroup
   dim lngSize
   dim strOrder

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Execute the event list
   '//
   lngSize = 0
   if objForm.Fields().Item("Mode") = "" then
      call objForm.AddField("INP_CODE_TYPE", "1")
   else
      call objForm.AddField("INP_CODE_TYPE", objForm.Fields().Item("INP_CODE_TYPE"))
   end if
   if objForm.Fields().Item("Mode") = "SEARCH" then
  
		strQuery = "select "
		strQuery = strQuery & " a.xrf_target as grd_code,"
		strQuery = strQuery & " a.xrf_source as legacy_code,"
		strQuery = strQuery & " max(b.vendor_name_01) as name_en,"
		strQuery = strQuery & " max(c.name) as name_zh,"
		strQuery = strQuery & " max(c.street) as street_zh,"
		strQuery = strQuery & " max(b.account_group_code) as acc_grp_code"
		strQuery = strQuery & " from lads_xrf_det a,"
		strQuery = strQuery & "      bds_vend_header b,"
		strQuery = strQuery & "      bds_addr_vendor c"
		strQuery = strQuery & " where ltrim(a.xrf_target,'0') = ltrim(b.vendor_code(+),'0')"
		strQuery = strQuery & " and b.vendor_code = c.vendor_code(+)"
		strQuery = strQuery & " and a.xrf_code = 'MCH_VEND'"
		strQuery = strQuery & " and c.address_version(+) = 'I'"
		
		if objForm.Fields().Item("INP_CODE_TYPE") = "1" and objForm.Fields().Item("QRY_CODE") <> "" then 'GRD
		   strWhere = strWhere & " and ltrim(a.xrf_target,'0') like '%" & objForm.Fields().Item("QRY_CODE") & "%'"
		end if
		if objForm.Fields().Item("INP_CODE_TYPE") = "0" and objForm.Fields().Item("QRY_CODE") <> "" then
		   strWhere = strWhere & " and ltrim(a.xrf_source,'0') like '%" & objForm.Fields().Item("QRY_CODE") & "%'"    
		end if
		
		if objForm.Fields().Item("QRY_DESC") <> "" then
		   strWhere = strWhere & " and upper(b.vendor_name_01) like upper('%" & objForm.Fields().Item("QRY_DESC") & "%')"   
		end if
		if objForm.Fields().Item("QRY_ZH_DESC") <> "" then
		   strWhere = strWhere & " and upper(c.name) like upper('%" & objForm.Fields().Item("QRY_ZH_DESC") & "%')"   
		end if
		if objForm.Fields().Item("QRY_ACC_GRP") <> "" then
		   strWhere = strWhere & " and b.account_group_code = '" & objForm.Fields().Item("QRY_ACC_GRP") & "'"   
		end if
		strGroup = " group by a.xrf_target, a.xrf_source "

		strQuery = strQuery & strWhere & strGroup
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
   if clng(objSelection.ListCount("LIST")) <> 0 then
      select case objForm.Fields().Item("Mode")
         case "SEARCH"
            bolStrList = true
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
<!--#include file="ics_grd_lkup_vendor.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->