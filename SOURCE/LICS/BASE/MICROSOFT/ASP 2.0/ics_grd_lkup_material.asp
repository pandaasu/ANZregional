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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Execute the event list
   '//
   lngSize = 0
   if objForm.Fields().Item("Mode") = "" then
      call objForm.AddField("INP_CODE_TYPE", "1")
      call objForm.AddField("QRY_REG_CODE", "8")
   else
      call objForm.AddField("INP_CODE_TYPE", objForm.Fields().Item("INP_CODE_TYPE"))
   end if
   if objForm.Fields().Item("Mode") = "SEARCH" then
  
		strQuery = "select "
		strQuery = strQuery & " ltrim(a.sap_material_code,'0') as grd_code,"
		strQuery = strQuery & " ltrim(b.regional_code,'0') as legacy_code,"
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

		if objForm.Fields().Item("INP_CODE_TYPE") = "1" and objForm.Fields().Item("QRY_CODE") <> "" then 'GRD
		   strWhere = strWhere & " and upper(a.sap_material_code) like upper('%" & objForm.Fields().Item("QRY_CODE") & "%')"
		end if
		if objForm.Fields().Item("INP_CODE_TYPE") = "0" and objForm.Fields().Item("QRY_CODE") <> "" then
		   strWhere = strWhere & " and upper(ltrim(b.regional_code,'0')) = upper('" & objForm.Fields().Item("QRY_CODE") & "')"    
		end if
		
		if objForm.Fields().Item("QRY_REG_CODE") <> "" then 
		   strWhere = strWhere & " and b.regional_code_id = '" & objForm.Fields().Item("QRY_REG_CODE") & "'"
		end if		
		
		if objForm.Fields().Item("QRY_DESC") <> "" then
		   strWhere = strWhere & " and upper(a.bds_material_desc_en) like upper('%" & objForm.Fields().Item("QRY_DESC") & "%')"   
		end if
		if objForm.Fields().Item("QRY_CN_DESC") <> "" then
		   strWhere = strWhere & " and upper(a.bds_material_desc_zh) like upper('%" & objForm.Fields().Item("QRY_CN_DESC") & "%')"   
		end if
		
		if objForm.Fields().Item("QRY_MATL_TYPE") <> "" then 
		   strWhere = strWhere & " and a.material_type = upper('" & objForm.Fields().Item("QRY_MATL_TYPE") & "')"
		end if			
		
		if objForm.Fields().Item("QRY_MATL_STATUS") <> "" then 
		   strWhere = strWhere & " and a.xplant_status = upper('" & objForm.Fields().Item("QRY_MATL_STATUS") & "')"
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
<!--#include file="ics_grd_lkup_material.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->