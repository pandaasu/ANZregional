<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes                                             //
'// Script  : hermes_cn_budget_adm.asp                           //
'// Author  : ISI China                                          //
'// Date    : July 2007                                          //
'// Text    : This script implements the budget download         //
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
   dim objProcedure
   dim objFunction
   dim strUser

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "hermes_cn_budget_adm.asp"
   strHeading = "TP Budget Download"

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
   '// Get the logon ID
   '//
   strUser = GetUser()

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurity()
   if strReturn = "*OK" then

      '//
      '// Get the form data
      '//
      GetForm()
      strMode = objForm.Fields("Mode").Value

      '//
      '// Process the form data
      '//
      select case strMode
         case "LOAD"
            call ProcessImportLoad
         case else
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   select case strMode
      case "FATAL"
         call PaintFatal
      case "LOAD"
         call PaintBudget
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objProcedure = nothing
   set objFunction = nothing

'/////////////////////////////////
'// Process import load routine //
'/////////////////////////////////
sub ProcessImportLoad()


   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the routing list
   '//
   'lngSize = 0
   'strQuery = "select"
   'strQuery = strQuery & " t01.tp_period,"
   'strQuery = strQuery & " t01.tp_id,"
   'strQuery = strQuery & " t01.tp_desc, "
   'strQuery = strQuery & " t01.tp_grp, "
   'strQuery = strQuery & " t01.tp_cust_level,"
   'strQuery = strQuery & " t01.tp_matl_level,"
   'strQuery = strQuery & " t01.tp_type_code,"
   'strQuery = strQuery & " to_char(t01.tp_bgt,'fm999999990.00'), "
   'strQuery = strQuery & " to_char(t01.tp_rvsl,'fm999999990.00'), "
   'strQuery = strQuery & " to_char(t01.tp_bgt_lupdt,'YYYY.MM.DD'), "
   'strQuery = strQuery & " t01.tp_bgt_stat, "
   'strQuery = strQuery & " t01.tp_user_sec "   
   'strQuery = strQuery & " from tp_budget t01, tp_com t02, tp_type t03, tp_user_sec t04"
   'strQuery = strQuery & " where t01.tp_com_code = t02.tpc_com_code"
   'strQuery = strQuery & " and t01.tp_period = t02.tpc_curr_prd"
   'strQuery = strQuery & " and t01.tp_com_code = '" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "'"
   'strQuery = strQuery & " and t01.tp_com_code = t03.tp_com_code (+)"    
   'strQuery = strQuery & " and t01.tp_type_code = t03.tp_type_code (+)"
   'strQuery = strQuery & " and t01.tp_com_code = t04.tp_com_code"    
   'strQuery = strQuery & " and t04.tp_user_adm = 'Y'"
   'strQuery = strQuery & " and t04.tp_user_func = 'BGTLOAD'"   
   'strQuery = strQuery & " and '" & strUser & "' = t04.tp_user" 
   'strQuery = strQuery & " order by t01.tp_id asc "
   'strReturn = objSelection.Execute("LIST", strQuery, lngSize)

' for testing
'   strReturn = strQuery  
   
   strReturn = "*OK"
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else
      strMode = "LOAD"
   end if
   
end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint budget routine //
'//////////////////////////
sub PaintBudget()%>
<!--#include file="hermes_cn_budget_adm.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->