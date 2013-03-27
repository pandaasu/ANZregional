<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes                                             //
'// Script  : hermes_cn_claim_adm.asp                            //
'// Author  : ISI China                                          //
'// Date    : July 2007                                          //
'// Text    : This script implements the claim download          //
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
   strTarget = "hermes_cn_claim_adm.asp"
   strHeading = "TP Claim Download"

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
      strMode = objForm.Fields().Item("Mode")

      '//
      '// Process the form data
      '//
      select case strMode
         case "LOAD"
            call ProcessImportLoad
         case else
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
      end select

   end if

   '//
   '// Paint response
   '//
   select case strMode
      case "FATAL"
         call PaintFatal
      case "LOAD"
         call PaintClaim
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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the routing list
   '//
   'lngSize = 0
   'strQuery = "select"
   'strQuery = strQuery & " t01.tp_period,"
   'strQuery = strQuery & " t01.tp_batch, "
   'strQuery = strQuery & " t01.tp_id,"
   'strQuery = strQuery & " t05.tp_desc, "
   'strQuery = strQuery & " t05.tp_grp, "
   'strQuery = strQuery & " t01.tp_vend, "
   'strQuery = strQuery & " t05.tp_cust_level,"
   'strQuery = strQuery & " t05.tp_matl_level,"
   'strQuery = strQuery & " t05.tp_type_code,"
   'strQuery = strQuery & " to_char(t01.tp_clm,'fm999999990.00'), "
   'strQuery = strQuery & " to_char(t01.tp_clm_lupdt,'YYYY.MM.DD'), "
   'strQuery = strQuery & " t01.tp_rmks, "   
   'strQuery = strQuery & " t01.tp_clm_stat, "   
   'strQuery = strQuery & " t01.tp_user_sec "   
   'strQuery = strQuery & " from tp_claim t01, tp_com t02, tp_type t03, tp_user_sec t04, tp_budget t05"
   'strQuery = strQuery & " where t01.tp_com_code = t02.tpc_com_code"
   'strQuery = strQuery & " and t01.tp_period = t02.tpc_curr_prd"
   'strQuery = strQuery & " and t01.tp_com_code = '" & objSecurity.FixString(objForm.Fields().Item("DTA_TpaComCode")) & "'"
   'strQuery = strQuery & " and t05.tp_com_code = t03.tp_com_code (+)"    
   'strQuery = strQuery & " and t05.tp_type_code = t03.tp_type_code (+)"
   'strQuery = strQuery & " and t01.tp_com_code = t04.tp_com_code"    
   'strQuery = strQuery & " and t04.tp_user_adm = 'Y'"
   'strQuery = strQuery & " and t04.tp_user_func = 'CLMLOAD'"   
   'strQuery = strQuery & " and '" & strUser & "' = t04.tp_user" 
   'strQuery = strQuery & " and t01.tp_com_code = t05.tp_com_code (+)"
   'strQuery = strQuery & " and t01.tp_period = t05.tp_period (+)"
   'strQuery = strQuery & " and t01.tp_id = t05.tp_id (+)"
   'strQuery = strQuery & " order by t01.tp_batch, t01.tp_id asc "
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
'// Paint claim routine //
'//////////////////////////
sub PaintClaim()%>
<!--#include file="hermes_cn_claim_adm.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->