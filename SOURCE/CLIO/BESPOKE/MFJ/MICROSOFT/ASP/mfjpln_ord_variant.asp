<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Masterfoods Japan Planning Reporting               //
'// Script  : mfjpln_ord_variant.asp                             //
'// Author  : Softstep Pty Ltd                                   //
'// Date    : September 2003                                     //
'// Text    : This script paints the order variant report        //
'//           selection interface                                //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim j
   dim strBase
   dim strTarget
   dim strStatus
   dim strReturn
   dim strHeading
   dim strSaved
   dim bolSelect
   dim strXML
   dim objForm
   dim objSecurity
   dim objSelection
   dim objVariable
   dim objServer

   '//
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "mfjpln_ord_variant.asp"
   strHeading = "ORDER VARIANT REPORT"

   '//
   '// Get the base string
   '//
   strBase = GetBase()

   '//
   '// Get the status
   '//
   strStatus = GetStatus()

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
      select case objForm.Fields("Mode").Value
         case "PROMPT"
            call ProcessPrompt
         case "SELECT"
            call ProcessSelect
         case "REPORT"
            call ProcessReport
         case else
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   if strReturn <> "*OK" then
      call PaintFatal
   else
      select case objForm.Fields("Mode")
         case "PROMPT"
            call PaintPrompt
         case "SELECT"
            call PaintSelect
         case "REPORT"
            call PaintReport
      end select
   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objVariable = nothing
   set objServer = nothing

'////////////////////////////
'// Process prompt routine //
'////////////////////////////
sub ProcessPrompt()

   dim strQuery

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("XL_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the business segment text
   '//
   strQuery = "select t01.bus_sgmnt_desc"
   strQuery = strQuery & " from bus_sgmnt t01"
   strQuery = strQuery & " where t01.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   strReturn = objSelection.Execute("BUS_SGMNT", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the period/month range selections
   '//
   if objForm.Fields("ForType").Value = "PRD" then
      strQuery = "select to_char(min(t01.fcst_yyyypp),'FM000000'),"
      strQuery = strQuery & " to_char(max(t01.fcst_yyyypp),'FM000000')"
      strQuery = strQuery & " from pld_for_format0103 t01,"
      strQuery = strQuery & " material_dim t02"
      strQuery = strQuery & " where t01.material_code = t02.material_code"
      strQuery = strQuery & " and t01.asof_yyyypp < 210000"
      strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   else
      strQuery = "select to_char(min(t01.fcst_yyyymm),'FM000000'),"
      strQuery = strQuery & " to_char(max(t01.fcst_yyyymm),'FM000000')"
      strQuery = strQuery & " from pld_for_format0104 t01,"
      strQuery = strQuery & " material_dim t02"
      strQuery = strQuery & " where t01.material_code = t02.material_code"
      strQuery = strQuery & " and t01.asof_yyyyMM < 210000"
      strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   end if
   strReturn = objSelection.Execute("TERM", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the brand flag selection
   '//
   strQuery = "select t02.sap_brand_flag_code,"
   strQuery = strQuery & " max(t02.brand_flag_desc) as description"
   strQuery = strQuery & " from pld_for_format0101 t01,"
   strQuery = strQuery & " material_dim t02"
   strQuery = strQuery & " where t01.material_code = t02.material_code"
   strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   strQuery = strQuery & " and t02.sap_brand_flag_code is not null"
   strQuery = strQuery & " group by t02.sap_brand_flag_code"
   strQuery = strQuery & " order by description asc"
   strReturn = objSelection.Execute("BRAND_FLAG", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the brand sub flag selection
   '//
   strQuery = "select t02.sap_brand_sub_flag_code,"
   strQuery = strQuery & " max(t02.brand_sub_flag_desc) as description"
   strQuery = strQuery & " from pld_for_format0101 t01,"
   strQuery = strQuery & " material_dim t02"
   strQuery = strQuery & " where t01.material_code = t02.material_code"
   strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   strQuery = strQuery & " and t02.sap_brand_sub_flag_code is not null"
   strQuery = strQuery & " group by t02.sap_brand_sub_flag_code"
   strQuery = strQuery & " order by description asc"
   strReturn = objSelection.Execute("BRAND_SUB_FLAG", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the product pack size selection
   '//
   strQuery = "select t02.sap_prdct_pack_size_code,"
   strQuery = strQuery & " max(t02.prdct_pack_size_desc) as description"
   strQuery = strQuery & " from pld_for_format0101 t01,"
   strQuery = strQuery & " material_dim t02"
   strQuery = strQuery & " where t01.material_code = t02.material_code"
   strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   strQuery = strQuery & " and t02.sap_prdct_pack_size_code is not null"
   strQuery = strQuery & " group by t02.sap_prdct_pack_size_code"
   strQuery = strQuery & " order by description asc"
   strReturn = objSelection.Execute("PRDCT_PACK_SIZE", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the multi pack quantity selection
   '//
   strQuery = "select t02.sap_multi_pack_qty_code,"
   strQuery = strQuery & " max(t02.multi_pack_qty_desc) as description"
   strQuery = strQuery & " from pld_for_format0101 t01,"
   strQuery = strQuery & " material_dim t02"
   strQuery = strQuery & " where t01.material_code = t02.material_code"
   strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   strQuery = strQuery & " and t02.sap_multi_pack_qty_code is not null"
   strQuery = strQuery & " group by t02.sap_multi_pack_qty_code"
   strQuery = strQuery & " order by description asc"
   strReturn = objSelection.Execute("MULTI_PACK_QTY", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the consumer package format  selection
   '//
   strQuery = "select t02.sap_cnsmr_pack_frmt_code,"
   strQuery = strQuery & " max(t02.cnsmr_pack_frmt_desc) as description"
   strQuery = strQuery & " from pld_for_format0101 t01,"
   strQuery = strQuery & " material_dim t02"
   strQuery = strQuery & " where t01.material_code = t02.material_code"
   strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   strQuery = strQuery & " and t02.sap_cnsmr_pack_frmt_code is not null"
   strQuery = strQuery & " group by t02.sap_cnsmr_pack_frmt_code"
   strQuery = strQuery & " order by description asc"
   strReturn = objSelection.Execute("CNSMR_PACK_FRMT", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the planning type selection
   '//
   strQuery = "select t01.planning_type as description"
   strQuery = strQuery & " from pld_for_format0101 t01,"
   strQuery = strQuery & " material_dim t02"
   strQuery = strQuery & " where t01.material_code = t02.material_code"
   strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   strQuery = strQuery & " group by t01.planning_type"
   strQuery = strQuery & " order by description asc"
   strReturn = objSelection.Execute("PLANNING_TYPE", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the planning source unit selection
   '//
   strQuery = "select t01.planning_src_unit as description"
   strQuery = strQuery & " from pld_for_format0101 t01,"
   strQuery = strQuery & " material_dim t02"
   strQuery = strQuery & " where t01.material_code = t02.material_code"
   strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   strQuery = strQuery & " group by t01.planning_src_unit"
   strQuery = strQuery & " order by description asc"
   strReturn = objSelection.Execute("PLANNING_SRC_UNIT", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

end sub

'////////////////////////////
'// Process select routine //
'////////////////////////////
sub ProcessSelect()

   dim strQuery
   dim bolGroup

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("XL_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the material selection
   '//
   strQuery = "select t01.sap_material_code,"
   strQuery = strQuery & " t01.material_desc_en,"
   strQuery = strQuery & " t01.material_desc_en || t01.sap_material_code as description"
   strQuery = strQuery & " from material_dim t01,"
   strQuery = strQuery & " pld_for_format0101 t02"
   strQuery = strQuery & " where t01.material_code = t02.material_code"
   strQuery = strQuery & " and t01.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   if objForm.Fields("BrandFlagCount").Value <> "" then
      bolGroup = false
      for i = 1 to clng(objForm.Fields("BrandFlagCount").Value)
         if objForm.Fields("BrandFlagValue" & cstr(i)).Value <> "" then
            if bolGroup = false then
               bolGroup = true
               strQuery = strQuery & " and (t01.sap_brand_flag_code = '" & objForm.Fields("BrandFlagValue" & cstr(i)).Value & "'"
            else
               strQuery = strQuery & " or t01.sap_brand_flag_code = '" & objForm.Fields("BrandFlagValue" & cstr(i)).Value & "'"
            end if
         end if
      next
      if bolGroup = true then
         strQuery = strQuery & ")"
      end if
   end if
   if objForm.Fields("BrandSubFlagCount").Value <> "" then
      bolGroup = false
      for i = 1 to clng(objForm.Fields("BrandSubFlagCount").Value)
         if objForm.Fields("BrandSubFlagValue" & cstr(i)).Value <> "" then
            if bolGroup = false then
               bolGroup = true
               strQuery = strQuery & " and (t01.sap_brand_sub_flag_code = '" & objForm.Fields("BrandSubFlagValue" & cstr(i)).Value & "'"
            else
               strQuery = strQuery & " or t01.sap_brand_sub_flag_code = '" & objForm.Fields("BrandSubFlagValue" & cstr(i)).Value & "'"
            end if
         end if
      next
      if bolGroup = true then
         strQuery = strQuery & ")"
      end if
   end if
   if objForm.Fields("PrdctPackSizeCount").Value <> "" then
      bolGroup = false
      for i = 1 to clng(objForm.Fields("PrdctPackSizeCount").Value)
         if objForm.Fields("PrdctPackSizeValue" & cstr(i)).Value <> "" then
            if bolGroup = false then
               bolGroup = true
               strQuery = strQuery & " and (t01.sap_prdct_pack_size_code = '" & objForm.Fields("PrdctPackSizeValue" & cstr(i)).Value & "'"
            else
               strQuery = strQuery & " or t01.sap_prdct_pack_size_code = '" & objForm.Fields("PrdctPackSizeValue" & cstr(i)).Value & "'"
            end if
         end if
      next
      if bolGroup = true then
         strQuery = strQuery & ")"
      end if
   end if
   if objForm.Fields("MultiPackQtyCount").Value <> "" then
      bolGroup = false
      for i = 1 to clng(objForm.Fields("MultiPackQtyCount").Value)
         if objForm.Fields("MultiPackQtyValue" & cstr(i)).Value <> "" then
            if bolGroup = false then
               bolGroup = true
               strQuery = strQuery & " and (t01.sap_multi_pack_qty_code = '" & objForm.Fields("MultiPackQtyValue" & cstr(i)).Value & "'"
            else
               strQuery = strQuery & " or t01.sap_multi_pack_qty_code = '" & objForm.Fields("MultiPackQtyValue" & cstr(i)).Value & "'"
            end if
         end if
      next
      if bolGroup = true then
         strQuery = strQuery & ")"
      end if
   end if
   if objForm.Fields("CnsmrPackFrmtCount").Value <> "" then
      bolGroup = false
      for i = 1 to clng(objForm.Fields("CnsmrPackFrmtCount").Value)
         if objForm.Fields("CnsmrPackFrmtValue" & cstr(i)).Value <> "" then
            if bolGroup = false then
               bolGroup = true
               strQuery = strQuery & " and (t01.sap_cnsmr_pack_frmt_code = '" & objForm.Fields("CnsmrPackFrmtValue" & cstr(i)).Value & "'"
            else
               strQuery = strQuery & " or t01.sap_cnsmr_pack_frmt_code = '" & objForm.Fields("CnsmrPackFrmtValue" & cstr(i)).Value & "'"
            end if
         end if
      next
      if bolGroup = true then
         strQuery = strQuery & ")"
      end if
   end if
   if objForm.Fields("PlanningType").Value <> "" then
      strQuery = strQuery & " and t02.planning_type = '" & objForm.Fields("PlanningType").Value & "'"
   end if
   if objForm.Fields("PlanningSrcUnit").Value <> "" then
      strQuery = strQuery & " and t02.planning_src_unit = '" & objForm.Fields("PlanningSrcUnit").Value & "'"
   end if
   if objForm.Fields("PlanningStatus").Value <> "" then
      strQuery = strQuery & " and t02.planning_status = '" & objForm.Fields("PlanningStatus").Value & "'"
   end if
   strQuery = strQuery & " order by description asc"
   strReturn = objSelection.Execute("MATERIAL", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

end sub

'////////////////////////////
'// Process report routine //
'////////////////////////////
sub ProcessReport()

   dim strProcedure
   dim strParameters

   '//
   '// Load the variables
   '//
   set objVariable = Server.CreateObject("XL_VARIABLE.Object")
   set objVariable.Security = objSecurity

   '//
   '// Insert the variable data as required
   '//
   if objForm.Fields("MaterialCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("MaterialCount").Value)
         call objVariable.SetVariable("MATERIAL", objForm.Fields("MaterialValue" & cstr(i)).Value)
      next
   end if
   if objForm.Fields("ForType").Value <> "" then
      call objVariable.SetVariable("FOR_TYPE", objForm.Fields("ForType").Value)
   end if
   if objForm.Fields("RepSummary").Value <> "" then
      call objVariable.SetVariable("REP_SUMMARY", objForm.Fields("RepSummary").Value)
   end if
   if objForm.Fields("FcstStart").Value <> "" then
      call objVariable.SetVariable("FCST_STR", objForm.Fields("FcstStart").Value)
   end if
   if objForm.Fields("FcstEnd").Value <> "" then
      call objVariable.SetVariable("FCST_END", objForm.Fields("FcstEnd").Value)
   end if
   if objForm.Fields("BusSgmnt").Value <> "" then
      call objVariable.SetVariable("BUS_SGMNT", objForm.Fields("BusSgmnt").Value)
   end if
   if objForm.Fields("BrandFlagCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("BrandFlagCount").Value)
         if objForm.Fields("BrandFlagValue" & cstr(i)).Value <> "" then
            call objVariable.SetVariable("BRAND_FLAG", objForm.Fields("BrandFlagValue" & cstr(i)).Value)
         end if
      next
   end if
   if objForm.Fields("BrandSubFlagCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("BrandSubFlagCount").Value)
         if objForm.Fields("BrandSubFlagValue" & cstr(i)).Value <> "" then
            call objVariable.SetVariable("BRAND_SUB_FLAG", objForm.Fields("BrandSubFlagValue" & cstr(i)).Value)
         end if
      next
   end if
   if objForm.Fields("PrdctPackSizeCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("PrdctPackSizeCount").Value)
         if objForm.Fields("PrdctPackSizeValue" & cstr(i)).Value <> "" then
            call objVariable.SetVariable("PRDCT_PACK_SIZE", objForm.Fields("PrdctPackSizeValue" & cstr(i)).Value)
         end if
      next
   end if
   if objForm.Fields("MultiPackQtyCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("MultiPackQtyCount").Value)
         if objForm.Fields("MultiPackQtyValue" & cstr(i)).Value <> "" then
            call objVariable.SetVariable("MULTI_PACK_QTY", objForm.Fields("MultiPackQtyValue" & cstr(i)).Value)
         end if
      next
   end if
   if objForm.Fields("CnsmrPackFrmtCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("CnsmrPackFrmtCount").Value)
         if objForm.Fields("CnsmrPackFrmtValue" & cstr(i)).Value <> "" then
            call objVariable.SetVariable("CNSMR_PACK_FRMT", objForm.Fields("CnsmrPackFrmtValue" & cstr(i)).Value)
         end if
      next
   end if
   if objForm.Fields("PlanningType").Value <> "" then
      call objVariable.SetVariable("PLANNING_TYPE", objForm.Fields("PlanningType").Value)
   end if
   if objForm.Fields("PlanningSrcUnit").Value <> "" then
      call objVariable.SetVariable("PLANNING_SRC_UNIT", objForm.Fields("PlanningSrcUnit").Value)
   end if
   if objForm.Fields("PlanningStatus").Value <> "" then
      call objVariable.SetVariable("PLANNING_STATUS", objForm.Fields("PlanningStatus").Value)
   end if
   call objVariable.SetVariable("PRINT_XML", "SetPrintOverride Orientation='" & objForm.Fields("PrintOrientation").Value & "' FitWidthPages='" & objForm.Fields("PrintPagesWide").Value & "'")
   strReturn = objVariable.UpdateDatabase()
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Set the procedure string
   '//
   strProcedure = "mfjpln_for_format01_excel01.main"

   '//
   '// Create the report server object and process
   '//
   set objServer = Server.CreateObject("XL_SERVER.Object")
   set objServer.Security = objSecurity
   strReturn = objServer.Process(strProcedure)
   if strReturn = "*OK" then
      strXML = objServer.XMLString
   end if

   '//
   '// Set the saved data string
   '//
   strSaved = "<input type=""hidden"" name=""Mode"" value=""" & objForm.Fields("Mode").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""ForType"" value=""" & objForm.Fields("ForType").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""RepSummary"" value=""" & objForm.Fields("RepSummary").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""FcstStart"" value=""" & objForm.Fields("FcstStart").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""FcstEnd"" value=""" & objForm.Fields("FcstEnd").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PrintOrientation"" value=""" & objForm.Fields("PrintOrientation").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PrintPagesWide"" value=""" & objForm.Fields("PrintPagesWide").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""BusSgmnt"" value=""" & objForm.Fields("BusSgmnt").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PlanningType"" value=""" & objForm.Fields("PlanningType").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PlanningSrcUnit"" value=""" & objForm.Fields("PlanningSrcUnit").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PlanningStatus"" value=""" & objForm.Fields("PlanningStatus").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""BusSgmntText"" value=""" & objForm.Fields("BusSgmntText").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PlanningTypeText"" value=""" & objForm.Fields("PlanningTypeText").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PlanningSrcUnitText"" value=""" & objForm.Fields("PlanningSrcUnitText").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PlanningStatusText"" value=""" & objForm.Fields("PlanningStatusText").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""MaterialCount"" value=""" & objForm.Fields("MaterialCount").Value & """>"
   if objForm.Fields("MaterialCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("MaterialCount").Value)
         strSaved = strSaved & "<input type=""hidden"" name=""MaterialValue" & cstr(i) & """ value=""" & objForm.Fields("MaterialValue" & cstr(i)).Value & """>"
         strSaved = strSaved & "<input type=""hidden"" name=""MaterialText" & cstr(i) & """ value=""" & replace(objForm.Fields("MaterialText" & cstr(i)).Value, """", "&#34;", 1, -1, 1) & """>"
      next
   end if
   strSaved = strSaved & "<input type=""hidden"" name=""BrandFlagCount"" value=""" & objForm.Fields("BrandFlagCount").Value & """>"
   if objForm.Fields("BrandFlagCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("BrandFlagCount").Value)
         strSaved = strSaved & "<input type=""hidden"" name=""BrandFlagValue" & cstr(i) & """ value=""" & objForm.Fields("BrandFlagValue" & cstr(i)).Value & """>"
      next
   end if
   strSaved = strSaved & "<input type=""hidden"" name=""BrandSubFlagCount"" value=""" & objForm.Fields("BrandSubFlagCount").Value & """>"
   if objForm.Fields("BrandSubFlagCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("BrandSubFlagCount").Value)
         strSaved = strSaved & "<input type=""hidden"" name=""BrandSubFlagValue" & cstr(i) & """ value=""" & objForm.Fields("BrandSubFlagValue" & cstr(i)).Value & """>"
      next
   end if
   strSaved = strSaved & "<input type=""hidden"" name=""PrdctPackSizeCount"" value=""" & objForm.Fields("PrdctPackSizeCount").Value & """>"
   if objForm.Fields("PrdctPackSizeCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("PrdctPackSizeCount").Value)
         strSaved = strSaved & "<input type=""hidden"" name=""PrdctPackSizeValue" & cstr(i) & """ value=""" & objForm.Fields("PrdctPackSizeValue" & cstr(i)).Value & """>"
      next
   end if
   strSaved = strSaved & "<input type=""hidden"" name=""MultiPackQtyCount"" value=""" & objForm.Fields("MultiPackQtyCount").Value & """>"
   if objForm.Fields("MultiPackQtyCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("MultiPackQtyCount").Value)
         strSaved = strSaved & "<input type=""hidden"" name=""MultiPackQtyValue" & cstr(i) & """ value=""" & objForm.Fields("MultiPackQtyValue" & cstr(i)).Value & """>"
      next
   end if
   strSaved = strSaved & "<input type=""hidden"" name=""CnsmrPackFrmtCount"" value=""" & objForm.Fields("CnsmrPackFrmtCount").Value & """>"
   if objForm.Fields("CnsmrPackFrmtCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("CnsmrPackFrmtCount").Value)
         strSaved = strSaved & "<input type=""hidden"" name=""CnsmrPackFrmtValue" & cstr(i) & """ value=""" & objForm.Fields("CnsmrPackFrmtValue" & cstr(i)).Value & """>"
      next
   end if

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="mfjpln_fatal02.inc"-->
<%end sub

'//////////////////////////
'// Paint prompt routine //
'//////////////////////////
sub PaintPrompt()%>
<!--#include file="mfjpln_ord_variant_prompt.inc"-->
<%end sub

'//////////////////////////
'// Paint select routine //
'//////////////////////////
sub PaintSelect()%>
<!--#include file="mfjpln_ord_variant_select.inc"-->
<%end sub

'//////////////////////////
'// Paint report routine //
'//////////////////////////
sub PaintReport()%>
<!--#include file="mfjpln_report.inc"-->
<%end sub%>
<!--#include file="mfjpln_std_code.inc"-->