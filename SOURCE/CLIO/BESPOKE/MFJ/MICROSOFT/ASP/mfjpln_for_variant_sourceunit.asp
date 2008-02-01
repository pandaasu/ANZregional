<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Masterfoods Japan Planning Reporting               //
'// Script  : mfjpln_for_variant_sourceunit.asp                  //
'// Author  : Softstep Pty Ltd                                   //
'// Date    : September 2003                                     //
'// Text    : This script paints the forecast variant source     //
'//           unit report selection interface                    //
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
   strTarget = "mfjpln_for_variant_sourceunit.asp"
   strHeading = "FORECAST VARIANT SOURCE UNIT REPORT"

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
      strQuery = "select to_char(min(t01.casting_yyyypp),'FM000000'),"
      strQuery = strQuery & " to_char(max(t01.casting_yyyypp),'FM000000'),"
      strQuery = strQuery & " to_char(min(t01.fcst_yyyypp),'FM000000'),"
      strQuery = strQuery & " to_char(max(t01.fcst_yyyypp),'FM000000')"
      strQuery = strQuery & " from pld_for_format0203 t01,"
      strQuery = strQuery & " material_dim t02"
      strQuery = strQuery & " where t01.material_code = t02.material_code"
      strQuery = strQuery & " and t01.casting_yyyypp < 210000"
      strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   else
      strQuery = "select to_char(min(t01.casting_yyyymm),'FM000000'),"
      strQuery = strQuery & " to_char(max(t01.casting_yyyymm),'FM000000'),"
      strQuery = strQuery & " to_char(min(t01.fcst_yyyymm),'FM000000'),"
      strQuery = strQuery & " to_char(max(t01.fcst_yyyymm),'FM000000')"
      strQuery = strQuery & " from pld_for_format0204 t01,"
      strQuery = strQuery & " material_dim t02"
      strQuery = strQuery & " where t01.material_code = t02.material_code"
      strQuery = strQuery & " and t01.casting_yyyyMM < 210000"
      strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   end if
   strReturn = objSelection.Execute("TERM", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the planning source unit selection
   '//
   strQuery = "select t01.planning_src_unit as description"
   strQuery = strQuery & " from pld_for_format0201 t01,"
   strQuery = strQuery & " material_dim t02"
   strQuery = strQuery & " where t01.material_code = t02.material_code"
   strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   strQuery = strQuery & " group by t01.planning_src_unit"
   strQuery = strQuery & " order by description asc"
   strReturn = objSelection.Execute("PLANNING_SRC_UNIT", strQuery)
   if strReturn <> "*OK" then
      exit sub
   end if

   '//
   '// Execute the brand flag selection
   '//
   strQuery = "select t02.sap_brand_flag_code,"
   strQuery = strQuery & " max(t02.brand_flag_desc) as description"
   strQuery = strQuery & " from pld_for_format0201 t01,"
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
   strQuery = strQuery & " from pld_for_format0201 t01,"
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
   strQuery = strQuery & " from pld_for_format0201 t01,"
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
   '// Execute the planning type selection
   '//
   strQuery = "select t01.planning_type as description"
   strQuery = strQuery & " from pld_for_format0201 t01,"
   strQuery = strQuery & " material_dim t02"
   strQuery = strQuery & " where t01.material_code = t02.material_code"
   strQuery = strQuery & " and t02.sap_bus_sgmnt_code = '" & objForm.Fields("BusSgmnt").Value & "'"
   strQuery = strQuery & " group by t01.planning_type"
   strQuery = strQuery & " order by description asc"
   strReturn = objSelection.Execute("PLANNING_TYPE", strQuery)
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
   if objForm.Fields("ForType").Value <> "" then
      call objVariable.SetVariable("FOR_TYPE", objForm.Fields("ForType").Value)
   end if
   if objForm.Fields("AsofStart").Value <> "" then
      call objVariable.SetVariable("ASOF_STR", objForm.Fields("AsofStart").Value)
   end if
   if objForm.Fields("AsofEnd").Value <> "" then
      call objVariable.SetVariable("ASOF_END", objForm.Fields("AsofEnd").Value)
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
   if objForm.Fields("PlanningSrcUnitCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("PlanningSrcUnitCount").Value)
         if objForm.Fields("PlanningSrcUnitValue" & cstr(i)).Value <> "" then
            call objVariable.SetVariable("PLANNING_SRC_UNIT", objForm.Fields("PlanningSrcUnitValue" & cstr(i)).Value)
         end if
      next
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
   if objForm.Fields("PlanningType").Value <> "" then
      call objVariable.SetVariable("PLANNING_TYPE", objForm.Fields("PlanningType").Value)
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
   strProcedure = "mfjpln_for_format02_excel06.main"

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
   strSaved = strSaved & "<input type=""hidden"" name=""AsofStart"" value=""" & objForm.Fields("AsofStart").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""AsofEnd"" value=""" & objForm.Fields("AsofEnd").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""FcstStart"" value=""" & objForm.Fields("FcstStart").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""FcstEnd"" value=""" & objForm.Fields("FcstEnd").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PrintOrientation"" value=""" & objForm.Fields("PrintOrientation").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PrintPagesWide"" value=""" & objForm.Fields("PrintPagesWide").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""BusSgmnt"" value=""" & objForm.Fields("BusSgmnt").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PlanningType"" value=""" & objForm.Fields("PlanningType").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PlanningStatus"" value=""" & objForm.Fields("PlanningStatus").Value & """>"
   strSaved = strSaved & "<input type=""hidden"" name=""PlanningSrcUnitCount"" value=""" & objForm.Fields("PlanningSrcUnitCount").Value & """>"
   if objForm.Fields("PlanningSrcUnitCount").Value <> "" then
      for i = 1 to clng(objForm.Fields("PlanningSrcUnitCount").Value)
         strSaved = strSaved & "<input type=""hidden"" name=""PlanningSrcUnitValue" & cstr(i) & """ value=""" & replace(objForm.Fields("PlanningSrcUnitValue" & cstr(i)).Value, """", "&#34;", 1, -1, 1) & """>"
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
<!--#include file="mfjpln_for_variant_sourceunit_prompt.inc"-->
<%end sub

'//////////////////////////
'// Paint report routine //
'//////////////////////////
sub PaintReport()%>
<!--#include file="mfjpln_report.inc"-->
<%end sub%>
<!--#include file="mfjpln_std_code.inc"-->