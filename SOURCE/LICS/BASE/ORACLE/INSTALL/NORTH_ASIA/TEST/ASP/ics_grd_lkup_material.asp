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
   strTarget = "ics_grd_lkup_material.asp"
   strHeading = "GRD Material XREF Lookup"

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
   strReturn = GetSecurityCheck("ICS_GRD_LKUP_MATERIAL")
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the event list
   '//
   lngSize = 0
   if objForm.Fields("Mode").Value = "" then
      call objForm.AddField("INP_CODE_TYPE", "1")
   else
      call objForm.AddField("INP_CODE_TYPE", objForm.Fields("INP_CODE_TYPE").Value)
   end if
   if objForm.Fields("Mode").Value = "SEARCH" then
  
		strQuery = "select "
		strQuery = strQuery & " a.sap_material_code as grd_code,"
		strQuery = strQuery & " b.regional_code as legacy_code,"
		strQuery = strQuery & " b.regional_code_id as regional_code,"
		strQuery = strQuery & " max(a.bds_material_desc_en) as name_en,"
		strQuery = strQuery & " max(a.bds_material_desc_zh) as name_zh,"
		strQuery = strQuery & " max(a.material_type) as material_type,"
		strQuery = strQuery & " max(a.material_grp) as material_grp,"
		strQuery = strQuery & " decode(max(a.xplant_status), "
		strQuery = strQuery & "            '10','ACTIVE - 正在生产 可订/退货',"
		strQuery = strQuery & "            '40','DEVELOPMENT - 数据维护中',"
		strQuery = strQuery & "            '03','PLANNING - 主数据维护中',"
		strQuery = strQuery & "            '20','ACTIVE - 正在生产 可订/退货',"
		strQuery = strQuery & "            '50','CREATION - 数据创建中',"
		strQuery = strQuery & "            '30','BILL ADJ - 不再生产 只可退货',"
		strQuery = strQuery & "            '90','RETIRED - 不再生产 不可订货/退货',"
		strQuery = strQuery & "            '99','RETIRED - 不再生产 不可订货/退货',"
		strQuery = strQuery & "            max(a.xplant_status)) as material_status "
		strQuery = strQuery & " from bds_material_hdr a,"
		strQuery = strQuery & " bds_material_regional b"
		strQuery = strQuery & " where a.sap_material_code = b.sap_material_code"

		if objForm.Fields("INP_CODE_TYPE").Value = "1" and objForm.Fields("QRY_CODE").Value <> "" then 'GRD
		   strWhere = strWhere & " and ltrim(a.sap_material_code,'0') like '%" & objForm.Fields("QRY_CODE").Value & "%'"
		end if
		if objForm.Fields("INP_CODE_TYPE").Value = "0" and objForm.Fields("QRY_CODE").Value <> "" then
		   strWhere = strWhere & " and ltrim(b.regional_code,'0') like '%" & objForm.Fields("QRY_CODE").Value & "%'"    
		end if
		
		if objForm.Fields("QRY_REG_CODE").Value <> "" then 
		   strWhere = strWhere & " and b.regional_code_id = '" & objForm.Fields("QRY_REG_CODE").Value & "'"
		end if		
		
		if objForm.Fields("QRY_DESC").Value <> "" then
		   strWhere = strWhere & " and upper(a.bds_material_desc_en) like upper('%" & objForm.Fields("QRY_DESC").Value & "%')"   
		end if
		if objForm.Fields("QRY_CN_DESC").Value <> "" then
		   strWhere = strWhere & " and upper(a.bds_material_desc_zh) like upper('%" & objForm.Fields("QRY_CN_DESC").Value & "%')"   
		end if
		
		if objForm.Fields("QRY_MATL_TYPE").Value <> "" then 
		   strWhere = strWhere & " and a.material_type = upper('" & objForm.Fields("QRY_MATL_TYPE").Value & "')"
		end if			
		
		if objForm.Fields("QRY_MATL_STATUS").Value <> "" then 
		   strWhere = strWhere & " and a.xplant_status = upper('" & objForm.Fields("QRY_MATL_STATUS").Value & "')"
		end if	
				
		strGroup = " group by a.sap_material_code, b.regional_code, b.regional_code_id"

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
   if objSelection.ListCount("LIST") <> 0 then
      select case objForm.Fields("Mode").Value
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
<!--#include file="ics_grd_lkup_material.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->