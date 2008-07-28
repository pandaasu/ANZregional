<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_fcst_loading.asp                               //
'// Author  : Steve Gregan                                       //
'// Date    : July 2006                                          //
'// Text    : This script implements the forecast loading        //
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

   '//
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "ics_fcst_loading.asp"
   strHeading = "Forecast Loading"
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
   strReturn = GetSecurityCheck("CLIO_FCST_LOADING")
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
         case "LOAD"
            call ProcessLoad
         case else
            strMode = "FATAL"
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
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
   strQuery = strQuery & " where t01.load_status = '*VALID'"
   strQuery = strQuery & " and t01.fcst_split_division = t02.fcst_split_division(+)"
   strQuery = strQuery & " and t01.fcst_split_brand = t02.fcst_split_brand(+)"
   strQuery = strQuery & " and t01.fcst_split_sub_brand = t02.fcst_split_sub_brand(+)"
   strQuery = strQuery & " order by t01.load_identifier asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

end sub

'//////////////////////////
'// Process load routine //
'//////////////////////////
sub ProcessLoad()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Execute the forecast loading
   '//
   strStatement = "dw_forecast_loading.accept_period_load("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ForIdentifier").Value)  & "',"
   strStatement = strStatement & "'" & strUser  & "')"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
   end if

   '//
   '// Process the select
   '//
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
<!--#include file="ics_fcst_loading.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->