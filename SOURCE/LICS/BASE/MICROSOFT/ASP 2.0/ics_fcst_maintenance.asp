<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_fcst_maintenance.asp                           //
'// Author  : Steve Gregan                                       //
'// Date    : July 2006                                          //
'// Text    : This script implements the forecast maintenance    //
'//           functionality                                      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim strBase
   dim strUser
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
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "ics_fcst_maintenance.asp"
   strHeading = "Forecast Maintenance"
   strError = ""

   '//
   '// Get the base/user string
   '//
   strBase = GetBase()
   strUser = GetUser()

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
   strReturn = GetSecurityCheck("CLIO_FCST_MAINTENANCE")
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
         case "CREATE"
            call ProcessCreate
         case "DELETE"
            call ProcessDelete
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   if strMode = "FATAL" then
      call PaintFatal
   else
      call PaintResponse
   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objProcedure = nothing
   set objFunction = nothing

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
   '// Retrieve the forecast split list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " rpad(t01.fcst_split_division,5,' ')||rpad(t01.fcst_split_brand,5,' ')||rpad(t01.fcst_split_sub_brand,5,' '),"
   strQuery = strQuery & " t01.fcst_split_text"
   strQuery = strQuery & " from fcst_split t01"
   strQuery = strQuery & " order by t01.fcst_split_text asc"
   strReturn = objSelection.Execute("SPLIT", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Retrieve the forecast load list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.load_identifier,"
   strQuery = strQuery & " t01.load_description,"
   strQuery = strQuery & " t01.load_status,"
   strQuery = strQuery & " t01.load_replace,"
   strQuery = strQuery & " nvl(t02.fcst_split_text,'*UNKNOWN'),"
   strQuery = strQuery & " t01.fcst_time,"
   strQuery = strQuery & " t01.fcst_type,"
   strQuery = strQuery & " t01.fcst_cast_yyyynn,"
   strQuery = strQuery & " decode(t01.fcst_source,'*PLN','*PLAN','*TEXT'),"
   strQuery = strQuery & " decode(t01.fcst_source,'*PLN',decode(t01.fcst_material_list,'*ALL','*ALL','*LIST'),'*FILE'),"
   strQuery = strQuery & " t01.upd_user||' - '||to_char(t01.upd_date,'YYYY/MM/DD HH24:MI:SS')"
   strQuery = strQuery & " from fcst_load_header t01, fcst_split t02"
   strQuery = strQuery & " where t01.fcst_split_division = t02.fcst_split_division(+)"
   strQuery = strQuery & " and t01.fcst_split_brand = t02.fcst_split_brand(+)"
   strQuery = strQuery & " and t01.fcst_split_sub_brand = t02.fcst_split_sub_brand(+)"
   strQuery = strQuery & " order by t01.load_identifier asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Initialise the fields
   '//
   if strMode = "SELECT" then
      call objForm.AddField("DTA_ForIdentifier", "")
      call objForm.AddField("DTA_ForDescription", "")
      call objForm.AddField("DTA_ForReplace", "*SPLIT")
      call objForm.AddField("DTA_ForType", "PRDBR")
      call objForm.AddField("DTA_ForSplit", "")
      call objForm.AddField("DTA_ForSource", "*TXQ")
      call objForm.AddField("DTA_ForFileTXQ", "")
      call objForm.AddField("DTA_ForFileTXV", "")
   end if

end sub

'////////////////////////////
'// Process create routine //
'////////////////////////////
sub ProcessCreate()

   dim strStatement
   dim lngIndex

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
   if objForm.Fields().Item("DTA_ForSource") = "*TXQ" or objForm.Fields().Item("DTA_ForSource") = "*TXV" then
      lngIndex = 1
      do while lngIndex <= len(objForm.Fields().Item("DTA_ForStream"))
         call objProcedure.Execute("lics_form.set_value('FOR_STREAM','" & objSecurity.FixString(mid(objForm.Fields().Item("DTA_ForStream"),lngIndex,2000)) & "')")
         lngIndex = lngIndex + 2000
      loop
   end if

   '//
   '// Execute the forecast load creation
   '//
   strStatement = "dw_forecast_loading."
   if objForm.Fields().Item("DTA_ForType") = "PRDBR" then
      strStatement = strStatement & "create_period_load("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForIdentifier"))  & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForDescription"))  & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForReplace"))  & "',"
      strStatement = strStatement & "'*BR',"
      strStatement = strStatement & "'" & trim(mid(objForm.Fields().Item("DTA_ForSplit"),1,5))  & "',"
      strStatement = strStatement & "'" & trim(mid(objForm.Fields().Item("DTA_ForSplit"),6,5))  & "',"
      strStatement = strStatement & "'" & trim(mid(objForm.Fields().Item("DTA_ForSplit"),11,5))  & "',"
      strStatement = strStatement & "'" & objForm.Fields().Item("DTA_ForSource")  & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForMaterial"))  & "',"
      strStatement = strStatement & "'" & strUser  & "')"
   end if
   if objForm.Fields().Item("DTA_ForType") = "PRDOP1" then
      strStatement = strStatement & "create_period_load("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForIdentifier"))  & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForDescription"))  & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForReplace"))  & "',"
      strStatement = strStatement & "'*OP1',"
      strStatement = strStatement & "'" & trim(mid(objForm.Fields().Item("DTA_ForSplit"),1,5))  & "',"
      strStatement = strStatement & "'" & trim(mid(objForm.Fields().Item("DTA_ForSplit"),6,5))  & "',"
      strStatement = strStatement & "'" & trim(mid(objForm.Fields().Item("DTA_ForSplit"),11,5))  & "',"
      strStatement = strStatement & "'" & objForm.Fields().Item("DTA_ForSource")  & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForMaterial"))  & "',"
      strStatement = strStatement & "'" & strUser  & "')"
   end if
   if objForm.Fields().Item("DTA_ForType") = "PRDOP2" then
      strStatement = strStatement & "create_period_load("
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForIdentifier"))  & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForDescription"))  & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForReplace"))  & "',"
      strStatement = strStatement & "'*OP2',"
      strStatement = strStatement & "'" & trim(mid(objForm.Fields().Item("DTA_ForSplit"),1,5))  & "',"
      strStatement = strStatement & "'" & trim(mid(objForm.Fields().Item("DTA_ForSplit"),6,5))  & "',"
      strStatement = strStatement & "'" & trim(mid(objForm.Fields().Item("DTA_ForSplit"),11,5))  & "',"
      strStatement = strStatement & "'" & objForm.Fields().Item("DTA_ForSource")  & "',"
      strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_ForMaterial"))  & "',"
      strStatement = strStatement & "'" & strUser  & "')"
   end if
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
   else
      strMode = "SELECT"
   end if

   '//
   '// Process the select
   '//
   call ProcessSelect

end sub

'////////////////////////////
'// Process delete routine //
'////////////////////////////
sub ProcessDelete()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ics_procedure2.ICS_PROCEDURE")
   objProcedure.Security(objSecurity)

   '//
   '// Execute the forecast load creation
   '//
   strStatement = "dw_forecast_loading.delete_load('" & objSecurity.FixString(objForm.Fields().Item("DTA_ForIdentifier"))  & "')"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
   end if

   '//
   '// Process the select
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

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
<!--#include file="ics_fcst_maintenance.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->