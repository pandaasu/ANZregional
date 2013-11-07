<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_ema.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : August 2005                                        //
'// Text    : This script implements the validation              //
'//           email configuration functionality                  //
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
   dim objProcedure
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_val_ema.asp"
   strHeading = "Validation Email"
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
   strReturn = GetSecurityCheck("VAL_EMA_CONFIG")
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else

      '//
      '// Get the form data
      '//
      GetForm()
      strMode = objForm.Fields().Item("Mode")

      '//
      '// Process the form data
      '//
      select case strMode
         case "SELECT"
            call ProcessSelect
         case "INSERT_LOAD"
            call ProcessInsertLoad
         case "INSERT_ACCEPT"
            call ProcessInsertAccept
         case "UPDATE_LOAD"
            call ProcessUpdateLoad
         case "UPDATE_ACCEPT"
            call ProcessUpdateAccept
         case "DELETE_LOAD"
            call ProcessDeleteLoad
         case "DELETE_ACCEPT"
            call ProcessDeleteAccept
         case "ENQUIRY_LOAD"
            call ProcessEnquiryLoad
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
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
      case "INSERT"
         call PaintInsert
      case "UPDATE"
         call PaintUpdate
      case "DELETE"
         call PaintDelete
      case "ENQUIRY"
         call PaintEnquiry
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objProcedure = nothing
   set objFunction = nothing

'/////////////////////////////
'// Retrieve detail routine //
'/////////////////////////////
sub RetrieveDetail()

   dim strQuery
   dim lngSize

   '//
   '// Retrieve the details
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " rpad(nvl(t01.grp_code,' '),30,' ')||rpad(nvl(t01.cla_code,' '),30,' ')||rpad(nvl(t01.typ_code,' '),30,' ')||rpad(nvl(t01.fil_code,' '),30,' ')||rpad(nvl(t01.rul_code,' '),30,' ') as key_data,"
   strQuery = strQuery & " t01.text,"
   strQuery = strQuery & " nvl(t02.det_select,'0'),"
   strQuery = strQuery & " t01.sea_flag,"
   strQuery = strQuery & " nvl(t02.ved_search01,''),"
   strQuery = strQuery & " nvl(t02.ved_search02,''),"
   strQuery = strQuery & " nvl(t02.ved_search03,''),"
   strQuery = strQuery & " nvl(t02.ved_search04,''),"
   strQuery = strQuery & " nvl(t02.ved_search05,''),"
   strQuery = strQuery & " nvl(t02.ved_search06,''),"
   strQuery = strQuery & " nvl(t02.ved_search07,''),"
   strQuery = strQuery & " nvl(t02.ved_search08,''),"
   strQuery = strQuery & " nvl(t02.ved_search09,'')"
   strQuery = strQuery & " from (select level,"
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
   strQuery = strQuery & " '0' as sea_flag,"
   strQuery = strQuery & " 'Group=(*ALL)  Rules=(*ALL)' as text"
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
   strQuery = strQuery & " '0' as sea_flag,"
   strQuery = strQuery & " 'Group=('||vag_group||')  Classifications=(*ALL)  Rules=(*ALL)' as text"
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
   strQuery = strQuery & " '1' as sea_flag,"
   strQuery = strQuery & " 'Group=('||vag_group||')  Classification=('||vac_class||')  Rules=(*ALL)' as text"
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
   strQuery = strQuery & " '1' as sea_flag,"
   strQuery = strQuery & " 'Group=('||vag_group||')  Classification=('||vac_class||')  Rule=('||var_rule||' - '||var_description||')' as text"
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
   strQuery = strQuery & " '0' as sea_flag,"
   strQuery = strQuery & " 'Group=('||vag_group||')  Types=(*ALL)  Rules=(*ALL)' as text"
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
   strQuery = strQuery & " '0' as sea_flag,"
   strQuery = strQuery & " 'Group=('||vag_group||')  Type=('||vat_type||')  Rules=(*ALL)' as text"
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
   strQuery = strQuery & " '0' as sea_flag,"
   strQuery = strQuery & " 'Group=('||vag_group||')  Type=('||vat_type||')  Rule=('||var_rule||' - '||var_description||')' as text"
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
   strQuery = strQuery & " '0' as sea_flag,"
   strQuery = strQuery & " 'Group=('||vag_group||')  Filters=(*ALL)  Rule=(*MISSING)' as text"
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
   strQuery = strQuery & " '0' as sea_flag,"
   strQuery = strQuery & " 'Group=('||vag_group||')  Filter=('||vaf_filter||')  Rule=(*MISSING)' as text"
   strQuery = strQuery & " from (select * from sap_val_fil, sap_val_grp where vaf_group = vag_group order by vaf_filter asc)"
   strQuery = strQuery & " ) start with par_typ = '*TOP'"
   strQuery = strQuery & " connect by prior typ_id = par_typ and prior val_id = par_id) t01,"
   strQuery = strQuery & " (select t01.ved_group, t01.ved_class, t01.ved_type, t01.ved_filter, t01.ved_rule, t01.ved_search01, t01.ved_search02, t01.ved_search03, t01.ved_search04, t01.ved_search05, t01.ved_search06, t01.ved_search07, t01.ved_search08, t01.ved_search09, '1' as det_select"
   strQuery = strQuery & " from sap_val_ema_det t01"
   strQuery = strQuery & " where t01.ved_email = '" & objForm.Fields().Item("DTA_VaeEmail") & "') t02"
   strQuery = strQuery & " where t01.grp_code = t02.ved_group(+)"
   strQuery = strQuery & " and t01.cla_code = t02.ved_class(+)"
   strQuery = strQuery & " and t01.typ_code = t02.ved_type(+)"
   strQuery = strQuery & " and t01.fil_code = t02.ved_filter(+)"
   strQuery = strQuery & " and t01.rul_code = t02.ved_rule(+)"
   strQuery = strQuery & " order by key_data asc"
   strReturn = objSelection.Execute("DETAIL", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'////////////////////////////
'// Process select routine //
'////////////////////////////
sub ProcessSelect()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the classification list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.vae_email,"
   strQuery = strQuery & " t01.vae_description,"
   strQuery = strQuery & " t01.vae_address,"
   strQuery = strQuery & " t01.vae_status"
   strQuery = strQuery & " from sap_val_ema t01"
   strQuery = strQuery & " order by t01.vae_email asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process insert load routine //
'/////////////////////////////////
sub ProcessInsertLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VaeEmail", "")
   call objForm.AddField("DTA_VaeDescription", "")
   call objForm.AddField("DTA_VaeAddress", "")
   call objForm.AddField("DTA_VaeStatus", "1")

   '//
   '// Retrieve the details
   '//
   call RetrieveDetail
   if strMode = "FATAL" then
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "INSERT"

end sub

'///////////////////////////////////
'// Process insert accept routine //
'///////////////////////////////////
sub ProcessInsertAccept()

   dim strStatement
   dim lngCount

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   call objProcedure.Execute("lics_form.set_value('VAE_EMAIL','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeEmail")) & "')")
   call objProcedure.Execute("lics_form.set_value('VAE_DESCRIPTION','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeDescription")) & "')")
   call objProcedure.Execute("lics_form.set_value('VAE_ADDRESS','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeAddress")) & "')")
   call objProcedure.Execute("lics_form.set_value('VAE_STATUS','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeStatus")) & "')")

   '//
   '// Insert the email detail data
   '//
   lngCount = clng(objForm.Fields().Item("DET_DetailCount"))
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_GROUP','" & objSecurity.FixString(trim(mid(objForm.Fields().Item("DET_Key" & i),1,30))) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_CLASS','" & objSecurity.FixString(trim(mid(objForm.Fields().Item("DET_Key" & i),31,30))) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_TYPE','" & objSecurity.FixString(trim(mid(objForm.Fields().Item("DET_Key" & i),61,30))) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_FILTER','" & objSecurity.FixString(trim(mid(objForm.Fields().Item("DET_Key" & i),91,30))) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_RULE','" & objSecurity.FixString(trim(mid(objForm.Fields().Item("DET_Key" & i),121,30))) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH01','" & objSecurity.FixString(objForm.Fields().Item("DET_Search01_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH02','" & objSecurity.FixString(objForm.Fields().Item("DET_Search02_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH03','" & objSecurity.FixString(objForm.Fields().Item("DET_Search03_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH04','" & objSecurity.FixString(objForm.Fields().Item("DET_Search04_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH05','" & objSecurity.FixString(objForm.Fields().Item("DET_Search05_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH06','" & objSecurity.FixString(objForm.Fields().Item("DET_Search06_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH07','" & objSecurity.FixString(objForm.Fields().Item("DET_Search07_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH08','" & objSecurity.FixString(objForm.Fields().Item("DET_Search08_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH09','" & objSecurity.FixString(objForm.Fields().Item("DET_Search09_" & i)) & "')")
   next

   '//
   '// Insert the email
   '//
   strStatement = "lads_val_configuration.insert_email"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "INSERT"
      strError = FormatError(strReturn)
      call RetrieveDetail
      if strMode = "FATAL" then
         exit sub
      end if
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'/////////////////////////////////
'// Process update load routine //
'/////////////////////////////////
sub ProcessUpdateLoad()

   dim strStatement

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   call objProcedure.Execute("lics_form.set_value('VAE_EMAIL','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeEmail")) & "')")

   '//
   '// Retrieve the email
   '//
   strStatement = "lads_val_configuration.retrieve_email"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VaeDescription", objFunction.Execute("lics_form.get_array('VAE_DESCRIPTION',1)"))
   call objForm.AddField("DTA_VaeAddress", objFunction.Execute("lics_form.get_array('VAE_ADDRESS',1)"))
   call objForm.AddField("DTA_VaeStatus", objFunction.Execute("lics_form.get_array('VAE_STATUS',1)"))

   '//
   '// Retrieve the details
   '//
   call RetrieveDetail
   if strMode = "FATAL" then
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "UPDATE"

end sub

'///////////////////////////////////
'// Process update accept routine //
'///////////////////////////////////
sub ProcessUpdateAccept()

   dim strStatement
   dim lngCount

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   call objProcedure.Execute("lics_form.set_value('VAE_EMAIL','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeEmail")) & "')")
   call objProcedure.Execute("lics_form.set_value('VAE_DESCRIPTION','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeDescription")) & "')")
   call objProcedure.Execute("lics_form.set_value('VAE_ADDRESS','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeAddress")) & "')")
   call objProcedure.Execute("lics_form.set_value('VAE_STATUS','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeStatus")) & "')")

   '//
   '// Insert the email detail data
   '//
   lngCount = clng(objForm.Fields().Item("DET_DetailCount"))
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_GROUP','" & objSecurity.FixString(trim(mid(objForm.Fields().Item("DET_Key" & i),1,30))) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_CLASS','" & objSecurity.FixString(trim(mid(objForm.Fields().Item("DET_Key" & i),31,30))) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_TYPE','" & objSecurity.FixString(trim(mid(objForm.Fields().Item("DET_Key" & i),61,30))) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_FILTER','" & objSecurity.FixString(trim(mid(objForm.Fields().Item("DET_Key" & i),91,30))) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_RULE','" & objSecurity.FixString(trim(mid(objForm.Fields().Item("DET_Key" & i),121,30))) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH01','" & objSecurity.FixString(objForm.Fields().Item("DET_Search01_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH02','" & objSecurity.FixString(objForm.Fields().Item("DET_Search02_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH03','" & objSecurity.FixString(objForm.Fields().Item("DET_Search03_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH04','" & objSecurity.FixString(objForm.Fields().Item("DET_Search04_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH05','" & objSecurity.FixString(objForm.Fields().Item("DET_Search05_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH06','" & objSecurity.FixString(objForm.Fields().Item("DET_Search06_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH07','" & objSecurity.FixString(objForm.Fields().Item("DET_Search07_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH08','" & objSecurity.FixString(objForm.Fields().Item("DET_Search08_" & i)) & "')")
   next
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('VED_SEARCH09','" & objSecurity.FixString(objForm.Fields().Item("DET_Search09_" & i)) & "')")
   next

   '//
   '// Update the email
   '//
   strStatement = "lads_val_configuration.update_email"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "UPDATE"
      strError = FormatError(strReturn)
      call RetrieveDetail
      if strMode = "FATAL" then
         exit sub
      end if
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

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   call objProcedure.Execute("lics_form.set_value('VAE_EMAIL','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeEmail")) & "')")

   '//
   '// Retrieve the email
   '//
   strStatement = "lads_val_configuration.retrieve_email"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VaeDescription", objFunction.Execute("lics_form.get_array('VAE_DESCRIPTION',1)"))
   call objForm.AddField("DTA_VaeAddress", objFunction.Execute("lics_form.get_array('VAE_ADDRESS',1)"))
   call objForm.AddField("DTA_VaeStatus", objFunction.Execute("lics_form.get_array('VAE_STATUS',1)"))

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
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   call objProcedure.Execute("lics_form.set_value('VAE_EMAIL','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeEmail")) & "')")

   '//
   '// Delete the email
   '//
   strStatement = "lads_val_configuration.delete_email"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "DELETE"
      strError = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SELECT"
   call ProcessSelect

end sub

'//////////////////////////////////
'// Process enquiry load routine //
'//////////////////////////////////
sub ProcessEnquiryLoad()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   call objProcedure.Execute("lics_form.set_value('VAE_EMAIL','" & objSecurity.FixString(objForm.Fields().Item("DTA_VaeEmail")) & "')")

   '//
   '// Retrieve the email
   '//
   strStatement = "lads_val_configuration.retrieve_email"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_VaeDescription", objFunction.Execute("lics_form.get_array('VAE_DESCRIPTION',1)"))
   call objForm.AddField("DTA_VaeAddress", objFunction.Execute("lics_form.get_array('VAE_ADDRESS',1)"))
   call objForm.AddField("DTA_VaeStatus", objFunction.Execute("lics_form.get_array('VAE_STATUS',1)"))

   '//
   '// Set the mode
   '//
   strMode = "ENQUIRY"

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
<!--#include file="ics_val_ema_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_val_ema_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_val_ema_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_val_ema_delete.inc"-->
<%end sub

'///////////////////////////
'// Paint enquiry routine //
'///////////////////////////
sub PaintEnquiry()%>
<!--#include file="ics_val_ema_enquiry.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->