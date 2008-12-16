<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : prc_lst_configuration.asp                          //
'// Author  : Steve Gregan                                       //
'// Date    : December 2008                                      //
'// Text    : This script implements the price list generator    //
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
   dim strError
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection
   dim objFunction
   dim objProcedure

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "prc_lst_configuration.asp"
   strHeading = "Price List Configuration"
   strError = ""

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
   strReturn = GetSecurityCheck("PRC_LST_CONFIGURATION")
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else

      '//
      '// Get the form data
      '//
      GetForm()
      strMode = objForm.Fields("Mode").Value

      '//
      '// Process the form data
      '//
      select case strMode
         case "SELECT"
            call ProcessSelect
         case "DEFINE_LOAD"
            call ProcessDefineLoad
         case "DEFINE_ACCEPT"
            call ProcessDefineAccept
         case "RULE_LOAD"
            call ProcessRuleLoad
         case "RULE_ACCEPT"
            call ProcessRuleAccept
         case "MATERIAL_LOAD"
            call ProcessMaterialLoad
         case "MATERIAL_ACCEPT"
            call ProcessMaterialAccept
         case "FORMAT_LOAD"
            call ProcessFormatLoad
         case "FORMAT_ACCEPT"
            call ProcessFormatAccept
         case "DELETE_LOAD"
            call ProcessDeleteLoad
         case "DELETE_ACCEPT"
            call ProcessDeleteAccept
         case "COPY_LOAD"
            call ProcessCopyLoad
         case "COPY_ACCEPT"
            call ProcessCopyAccept
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   select case strMode
      case "FATAL"
         call PaintFatal
      case "SELECT"
         call PaintSelect
      case "DEFINE"
         call PaintDefine
      case "RULE"
         call PaintRule
      case "MATERIAL"
         call PaintMaterial
      case "FORMAT"
         call PaintFormat
      case "DELETE"
         call PaintDelete
      case "COPY"
         call PaintCopy
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objFunction = nothing
   set objProcedure = nothing

'////////////////////////////
'// Process select routine //
'////////////////////////////
sub ProcessSelect()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the report list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.report_id),"
   strQuery = strQuery & " t01.report_name,"
   strQuery = strQuery & " decode(t01.status,'V','Available','I','Inactive',t01.status)"
   strQuery = strQuery & " from report t01"
   strQuery = strQuery & " order by t01.report_name asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process define load routine //
'/////////////////////////////////
sub ProcessDefineLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the report group data
   '//
   lngSize = 0
   strQuery = "select to_char(t01.report_grp_id),"
   strQuery = strQuery & " t01.report_grp_name"
   strQuery = strQuery & " from report_grp t01"
   strQuery = strQuery & " order by t01.report_grp_name asc"
   strReturn = objSelection.Execute("REPORT_GRP", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the price model data
   '//
   lngSize = 0
   strQuery = "select to_char(t01.price_mdl_id,'fm0000000')||to_char(t02.price_sales_org_id,'fm0000000')||to_char(t02.price_distbn_chnl_id,'fm0000000'),"
   strQuery = strQuery & " t01.price_mdl_name||' : '||t03.price_sales_org_name||' and '||t04.price_distbn_chnl_name"
   strQuery = strQuery & " from price_mdl t01, price_mdl_by_sales_area t02, price_sales_org t03, price_distbn_chnl t04"
   strQuery = strQuery & " where t01.price_mdl_id = t02.price_mdl_id and t02.price_sales_org_id = t03.price_sales_org_id and t02.price_distbn_chnl_id = t04.price_distbn_chnl_id"
   strQuery = strQuery & " order by t01.price_mdl_name||' : '||t03.price_sales_org_name||' and '||t04.price_distbn_chnl_name asc"
   strReturn = objSelection.Execute("PRICE_MDL", strQuery, 0)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the report data
   '//
   if objForm.Fields("DTA_ReportId").Value <> "0" then

      '//
      '// Retrieve the report data
      '//
      lngSize = 0
      strQuery = "select"
      strQuery = strQuery & " to_char(t01.report_id),"
      strQuery = strQuery & " t01.report_name,"
      strQuery = strQuery & " to_char(t01.report_grp_id),"
      strQuery = strQuery & " to_char(t01.price_mdl_id,'fm0000000')||to_char(t01.price_sales_org_id,'fm0000000')||to_char(t01.price_distbn_chnl_id,'fm0000000'),"
      strQuery = strQuery & " nvl(t01.status,'I'),"
      strQuery = strQuery & " nvl(t01.matl_alrtng,'N'),"
      strQuery = strQuery & " nvl(t01.auto_matl_update,'N'),"
      strQuery = strQuery & " t01.email_address,"
      strQuery = strQuery & " t01.update_user,"
      strQuery = strQuery & " t01.price_mdl_id"
      strQuery = strQuery & " from report t01"
      strQuery = strQuery & " where t01.report_id = " & objForm.Fields("DTA_ReportId").Value
      strReturn = objSelection.Execute("REPORT", strQuery, lngSize)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Retrieve the price item data
      '//
      lngSize = 0
      strQuery = "select"
      strQuery = strQuery & " to_char(t01.price_item_id),"
      strQuery = strQuery & " t01.price_item_name,"
      strQuery = strQuery & " t01.price_item_desc"
      strQuery = strQuery & " from price_item t01"
      strQuery = strQuery & " where t01.price_mdl_id is null or t01.price_mdl_id = " & objSelection.ListValue10("REPORT",objSelection.ListLower("LIST"))
      strQuery = strQuery & " order by t01.price_item_name asc"
      strReturn = objSelection.Execute("PRICE_ITEM", strQuery, lngSize)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Retrieve the report data items
      '//
      lngSize = 0
      strQuery = "select"
      strQuery = strQuery & " to_char(t01.report_item_id),"
      strQuery = strQuery & " to_char(t01.price_item_id),"
      strQuery = strQuery & " t02.price_item_name"
      strQuery = strQuery & " from report_item t01, price_item t02"
      strQuery = strQuery & " where t01.price_item_id = t02.price_item_id and t01.report_id = " & objForm.Fields("DTA_ReportId").Value & " and t01.report_item_type = 'D'"
      strQuery = strQuery & " order by t01.sort_order asc"
      strReturn = objSelection.Execute("REPORT_DATA", strQuery, lngSize)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Retrieve the report break items
      '//
      lngSize = 0
      strQuery = "select"
      strQuery = strQuery & " to_char(t01.report_item_id),"
      strQuery = strQuery & " to_char(t01.price_item_id),"
      strQuery = strQuery & " t02.price_item_name"
      strQuery = strQuery & " from report_item t01, price_item t02"
      strQuery = strQuery & " where t01.price_item_id = t02.price_item_id and t01.report_id = " & objForm.Fields("DTA_ReportId").Value & " and t01.report_item_type = 'B'"
      strQuery = strQuery & " order by t01.sort_order asc"
      strReturn = objSelection.Execute("REPORT_BREAK", strQuery, lngSize)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Retrieve the report order items
      '//
      lngSize = 0
      strQuery = "select"
      strQuery = strQuery & " to_char(t01.report_item_id),"
      strQuery = strQuery & " to_char(t01.price_item_id),"
      strQuery = strQuery & " t02.price_item_name"
      strQuery = strQuery & " from report_item t01, price_item t02"
      strQuery = strQuery & " where t01.price_item_id = t02.price_item_id and t01.report_id = " & objForm.Fields("DTA_ReportId").Value & " and t01.report_item_type = 'O'"
      strQuery = strQuery & " order by t01.sort_order asc"
      strReturn = objSelection.Execute("REPORT_ORDER", strQuery, lngSize)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Retrieve the report terms
      '//
      lngSize = 0
      strQuery = "select"
      strQuery = strQuery & " t01.value"
      strQuery = strQuery & " from report_term t01"
      strQuery = strQuery & " where t01.report_id = " & objForm.Fields("DTA_ReportId").Value
      strQuery = strQuery & " order by t01.sort_order asc"
      strReturn = objSelection.Execute("REPORT_TERM", strQuery, lngSize)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if

      '//
      '// Initialise the data fields
      '//
      call objForm.AddField("DTA_ReportName", objSelection.ListValue02("REPORT",objSelection.ListLower("REPORT")))
      call objForm.AddField("DTA_ReportGrpId", objSelection.ListValue03("REPORT",objSelection.ListLower("REPORT")))
      call objForm.AddField("DTA_PriceMdlId", objSelection.ListValue04("REPORT",objSelection.ListLower("REPORT")))
      call objForm.AddField("DTA_Status", objSelection.ListValue05("REPORT",objSelection.ListLower("REPORT")))
      call objForm.AddField("DTA_MatlAlrtng", objSelection.ListValue06("REPORT",objSelection.ListLower("REPORT")))
      call objForm.AddField("DTA_AutoMatlUpdate", objSelection.ListValue07("REPORT",objSelection.ListLower("REPORT")))
      call objForm.AddField("DTA_EmailAddress", objSelection.ListValue08("REPORT",objSelection.ListLower("REPORT")))
      call objForm.AddField("DTA_UpdateUser", objSelection.ListValue09("REPORT",objSelection.ListLower("REPORT")))

   else

      '//
      '// Initialise the data fields
      '//
      call objForm.AddField("DTA_ReportName", "")
      call objForm.AddField("DTA_ReportGrpId", "")
      call objForm.AddField("DTA_PriceMdlId", "")
      call objForm.AddField("DTA_Status", "V")
      call objForm.AddField("DTA_MatlAlrtng", "N")
      call objForm.AddField("DTA_AutoMatlUpdate", "N")
      call objForm.AddField("DTA_EmailAddress", "")
      call objForm.AddField("DTA_UpdateUser", "New Report")

   end if

   '//
   '// Set the mode
   '//
   strMode = "DEFINE"

end sub

'///////////////////////////////////
'// Process define accept routine //
'///////////////////////////////////
sub ProcessDefineAccept()

   dim strStatement
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Define the report
   '//
   strStatement = "pricelist_configuration.define_report("
   strStatement = strStatement & objForm.Fields("DTA_ReportId").Value & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ReportName").Value) & "',"
   strStatement = strStatement & objForm.Fields("DTA_ReportGrpId").Value & ","
   strStatement = strStatement & mid(objForm.Fields("DTA_PriceMdlId").Value,1,7) & ","
   strStatement = strStatement & mid(objForm.Fields("DTA_PriceMdlId").Value,8,7) & ","
   strStatement = strStatement & mid(objForm.Fields("DTA_PriceMdlId").Value,15,7) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_Status").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_MatlAlrtng").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_AutoMatlUpdate").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_EmailAddress").Value) & "',"
   strStatement = strStatement & "'" & GetUser() & "'"
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Define the report item data
   '//
   lngCount = clng(objForm.Fields("DET_RepDatCount").Value)
   for i = 1 to lngCount
      strStatement = "pricelist_configuration.define_data("
      strStatement = strStatement & objForm.Fields("DET_RepDatId" & i).Value & ","
      strStatement = strStatement & objForm.Fields("DET_RepDatPrcId" & i).Value
      strStatement = strStatement & ")"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

   '//
   '// Define the report item break
   '//
   lngCount = clng(objForm.Fields("DET_RepBrkCount").Value)
   for i = 1 to lngCount
      strStatement = "pricelist_configuration.define_break("
      strStatement = strStatement & objForm.Fields("DET_RepBrkId" & i).Value & ","
      strStatement = strStatement & objForm.Fields("DET_RepBrkPrcId" & i).Value
      strStatement = strStatement & ")"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

   '//
   '// Define the report item order
   '//
   lngCount = clng(objForm.Fields("DET_RepOrdCount").Value)
   for i = 1 to lngCount
      strStatement = "pricelist_configuration.define_order("
      strStatement = strStatement & objForm.Fields("DET_RepOrdId" & i).Value & ","
      strStatement = strStatement & objForm.Fields("DET_RepOrdPrcId" & i).Value
      strStatement = strStatement & ")"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

   '//
   '// Define the report term
   '//
   lngCount = clng(objForm.Fields("DET_RepTerCount").Value)
   for i = 1 to lngCount
      strStatement = "pricelist_configuration.define_term("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepTerText" & i).Value) & "'"
      strStatement = strStatement & ")"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

   '//
   '// Commit the define
   '//
   strStatement = "pricelist_configuration.define_commit"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'///////////////////////////////
'// Process rule load routine //
'///////////////////////////////
sub ProcessRuleLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the report data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.report_id),"
   strQuery = strQuery & " t01.report_name"
   strQuery = strQuery & " from report t01"
   strQuery = strQuery & " where t01.report_id = " & objForm.Fields("DTA_ReportId").Value
   strReturn = objSelection.Execute("REPORT", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the price rule types
   '//
   lngSize = 0
   strQuery = "select t01.price_rule_type_id,"
   strQuery = strQuery & " t01.price_rule_type_name"
   strQuery = strQuery & " from price_rule_type t01"
   strQuery = strQuery & " order by t01.price_rule_type_name asc"
   strReturn = objSelection.Execute("RULE_TYPE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the report rules
   '//
   lngSize = 0
   strQuery = "select t01.report_rule_id,"
   strQuery = strQuery & " t01.report_rule_name,"
   strQuery = strQuery & " t02.price_rule_type_id,"
   strQuery = strQuery & " t03.price_rule_type_name,"
   strQuery = strQuery & " t02.rule_vlu,"
   strQuery = strQuery & " t02.rule_not"
   strQuery = strQuery & " from report_rule t01, report_rule_detl t02, price_rule_type t03"
   strQuery = strQuery & " where t01.report_rule_id = t02.report_rule_id(+)"
   strQuery = strQuery & " and t02.price_rule_type_id = t03.price_rule_type_id(+)"
   strQuery = strQuery & " and t01.report_id = " & objForm.Fields("DTA_ReportId").Value
   strQuery = strQuery & " order by t01.report_rule_id asc, t02.price_rule_type_id asc"
   strReturn = objSelection.Execute("RULE", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "RULE"

end sub

'/////////////////////////////////
'// Process rule accept routine //
'/////////////////////////////////
sub ProcessRuleAccept()

   dim strStatement
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Begin the rules
   '//
   strStatement = "pricelist_configuration.rule_begin("
   strStatement = strStatement & objForm.Fields("DTA_ReportId").Value
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Define the report rule data
   '//
   lngCount = clng(objForm.Fields("DET_RepRulCount").Value)
   for i = 1 to lngCount
      if objForm.Fields("DET_RepRulTyp" & i).Value = "RH" then
         strStatement = "pricelist_configuration.rule_header("
         strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepRulNam" & i).Value) & "'"
         strStatement = strStatement & ")"
         strReturn = objProcedure.Execute(strStatement)
         if strReturn <> "*OK" then
            strError = FormatError(strReturn)
            strMode = "SELECT"
            call ProcessSelect
            exit sub
         end if
      end if
      if objForm.Fields("DET_RepRulTyp" & i).Value = "RD" then
         strStatement = "pricelist_configuration.rule_detail("
         strStatement = strStatement & objForm.Fields("DET_RepTypId" & i).Value & ","
         strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepRulVal" & i).Value) & "',"
         strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepRulNot" & i).Value) & "'"
         strStatement = strStatement & ")"
         strReturn = objProcedure.Execute(strStatement)
         if strReturn <> "*OK" then
            strError = FormatError(strReturn)
            strMode = "SELECT"
            call ProcessSelect
            exit sub
         end if
      end if
   next

   '//
   '// Commit the rule data
   '//
   strStatement = "pricelist_configuration.rule_commit"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'///////////////////////////////////
'// Process material load routine //
'///////////////////////////////////
sub ProcessMaterialLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the report data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.report_id),"
   strQuery = strQuery & " t01.report_name"
   strQuery = strQuery & " from report t01"
   strQuery = strQuery & " where t01.report_id = " & objForm.Fields("DTA_ReportId").Value
   strReturn = objSelection.Execute("REPORT", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the report materials
   '//
   lngSize = 0
   strQuery = "select t01.value, t01.text from table(pr_app.pricelist_material.list(" & objForm.Fields("DTA_ReportId").Value & ")) t01"
   strReturn = objSelection.Execute("MATERIAL", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "MATERIAL"

end sub

'/////////////////////////////////////
'// Process material accept routine //
'/////////////////////////////////////
sub ProcessMaterialAccept()

   dim strStatement
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Begin the materials
   '//
   strStatement = "pricelist_configuration.material_begin("
   strStatement = strStatement & objForm.Fields("DTA_ReportId").Value
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Define the report material codes
   '//
   lngCount = clng(objForm.Fields("DET_RepMatCount").Value)
   for i = 1 to lngCount
      strStatement = "pricelist_configuration.material_detail("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepMatCod" & i).Value) & "'"
      strStatement = strStatement & ")"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

   '//
   '// Commit the material data
   '//
   strStatement = "pricelist_configuration.material_commit"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'/////////////////////////////////
'// Process format load routine //
'/////////////////////////////////
sub ProcessFormatLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the report data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.report_id),"
   strQuery = strQuery & " t01.report_name,"
   strQuery = strQuery & " t01.report_name_frmt"
   strQuery = strQuery & " from report t01"
   strQuery = strQuery & " where t01.report_id = " & objForm.Fields("DTA_ReportId").Value
   strReturn = objSelection.Execute("REPORT", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the report data items
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.report_item_id),"
   strQuery = strQuery & " t02.price_item_name,"
   strQuery = strQuery & " nvl(t01.name_ovrd,t02.price_item_name),"
   strQuery = strQuery & " t01.name_frmt,"
   strQuery = strQuery & " t01.data_frmt"
   strQuery = strQuery & " from report_item t01, price_item t02"
   strQuery = strQuery & " where t01.price_item_id = t02.price_item_id and t01.report_id = " & objForm.Fields("DTA_ReportId").Value & " and t01.report_item_type = 'D'"
   strQuery = strQuery & " order by t01.sort_order asc"
   strReturn = objSelection.Execute("REPORT_DATA", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the report break items
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.report_item_id),"
   strQuery = strQuery & " t02.price_item_name,"
   strQuery = strQuery & " t01.data_frmt"
   strQuery = strQuery & " from report_item t01, price_item t02"
   strQuery = strQuery & " where t01.price_item_id = t02.price_item_id and t01.report_id = " & objForm.Fields("DTA_ReportId").Value & " and t01.report_item_type = 'B'"
   strQuery = strQuery & " order by t01.sort_order asc"
   strReturn = objSelection.Execute("REPORT_BREAK", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Retrieve the report terms
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " nvl(t01.value,'*Blank Line*'),"
   strQuery = strQuery & " t01.data_frmt"
   strQuery = strQuery & " from report_term t01"
   strQuery = strQuery & " where t01.report_id = " & objForm.Fields("DTA_ReportId").Value
   strQuery = strQuery & " order by t01.sort_order asc"
   strReturn = objSelection.Execute("REPORT_TERM", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "FORMAT"

end sub

'///////////////////////////////////
'// Process format accept routine //
'///////////////////////////////////
sub ProcessFormatAccept()

   dim strStatement
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Format the report
   '//
   strStatement = "pricelist_configuration.format_report("
   strStatement = strStatement & objForm.Fields("DTA_ReportId").Value & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepHed").Value) & "',"
   strStatement = strStatement & "'" & GetUser() & "'"
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the report item data format
   '//
   lngCount = clng(objForm.Fields("DET_RepDatCount").Value)
   for i = 1 to lngCount
      strStatement = "pricelist_configuration.format_data("
      strStatement = strStatement & objForm.Fields("DET_RepDatId" & i).Value & ","
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepDatOvr" & i).Value) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepDatHed" & i).Value) & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepDatDat" & i).Value) & "'"
      strStatement = strStatement & ")"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

   '//
   '// Set the report item break format
   '//
   lngCount = clng(objForm.Fields("DET_RepBrkCount").Value)
   for i = 1 to lngCount
      strStatement = "pricelist_configuration.format_break("
      strStatement = strStatement & objForm.Fields("DET_RepBrkId" & i).Value & ","
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepBrkDat" & i).Value) & "'"
      strStatement = strStatement & ")"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

   '//
   '// Set the report term format
   '//
   lngCount = clng(objForm.Fields("DET_RepTerCount").Value)
   for i = 1 to lngCount
      strStatement = "pricelist_configuration.format_term("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DET_RepTerDat" & i).Value) & "'"
      strStatement = strStatement & ")"
      strReturn = objProcedure.Execute(strStatement)
      if strReturn <> "*OK" then
         strError = FormatError(strReturn)
         strMode = "SELECT"
         call ProcessSelect
         exit sub
      end if
   next

   '//
   '// Commit the report
   '//
   strStatement = "pricelist_configuration.format_commit"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'/////////////////////////////////
'// Process delete load routine //
'/////////////////////////////////
sub ProcessDeleteLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the report data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.report_id),"
   strQuery = strQuery & " t01.report_name"
   strQuery = strQuery & " from report t01"
   strQuery = strQuery & " where t01.report_id = " & objForm.Fields("DTA_ReportId").Value
   strReturn = objSelection.Execute("REPORT", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_ReportName", objSelection.ListValue02("REPORT",objSelection.ListLower("LIST")))

   '//
   '// Set the mode
   '//
   strMode = "DELETE"

end sub

'///////////////////////////////////
'// Process delete accept routine //
'///////////////////////////////////
sub ProcessDeleteAccept()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Delete the report
   '//
   strStatement = "pricelist_configuration.delete_report("
   strStatement = strStatement & objForm.Fields("DTA_ReportId").Value
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'///////////////////////////////
'// Process copy load routine //
'///////////////////////////////
sub ProcessCopyLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the report data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " to_char(t01.report_id),"
   strQuery = strQuery & " t01.report_name"
   strQuery = strQuery & " from report t01"
   strQuery = strQuery & " where t01.report_id = " & objForm.Fields("DTA_ReportId").Value
   strReturn = objSelection.Execute("REPORT", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_ReportName", objSelection.ListValue02("REPORT",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_CopyGrpId", "")
   call objForm.AddField("DTA_CopyName", "")

   '//
   '// Set the mode
   '//
   strMode = "COPY"

end sub

'/////////////////////////////////
'// Process copy accept routine //
'/////////////////////////////////
sub ProcessCopyAccept()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Copy the report
   '//
   strStatement = "pricelist_configuration.copy_report("
   strStatement = strStatement & objForm.Fields("DTA_ReportId").Value & ","
   strStatement = strStatement & objForm.Fields("DTA_CopyGrpId").Value & ","
   strStatement = strStatement & "'" & objForm.Fields("DTA_CopyName").Value & "'"
   strStatement = strStatement & ")"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint prompt routine //
'//////////////////////////
sub PaintSelect()%>
<!--#include file="prc_lst_configuration_select.inc"-->
<%end sub

'//////////////////////////
'// Paint define routine //
'//////////////////////////
sub PaintDefine()%>
<!--#include file="prc_lst_configuration_define.inc"-->
<%end sub

'////////////////////////
'// Paint rule routine //
'////////////////////////
sub PaintRule()%>
<!--#include file="prc_lst_configuration_rule.inc"-->
<%end sub

'////////////////////////////
'// Paint material routine //
'////////////////////////////
sub PaintMaterial()%>
<!--#include file="prc_lst_configuration_material.inc"-->
<%end sub

'//////////////////////////
'// Paint format routine //
'//////////////////////////
sub PaintFormat()%>
<!--#include file="prc_lst_configuration_format.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="prc_lst_configuration_delete.inc"-->
<%end sub

'////////////////////////
'// Paint copy routine //
'////////////////////////
sub PaintCopy()%>
<!--#include file="prc_lst_configuration_copy.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->