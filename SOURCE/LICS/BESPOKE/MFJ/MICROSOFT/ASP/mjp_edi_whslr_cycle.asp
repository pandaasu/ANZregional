<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : mjp_edi_whslr_cycle.asp                            //
'// Author  : Steve Gregan                                       //
'// Date    : February 2008                                      //
'// Text    : This script implements the EDI wholesaler          //
'//           cycle configuration functionality                  //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim j
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

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "mjp_edi_whslr_cycle.asp"
   strHeading = "EDI Wholesaler Cycle Configuration"
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
   strReturn = GetSecurityCheck("MJP_EDI_WHSLR_CYCLE_CONFIG")
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
         case "INSERT_LOAD"
            call ProcessInsertLoad
         case "INSERT_ACCEPT"
            call ProcessInsertAccept
         case "DELETE_LOAD"
            call ProcessDeleteLoad
         case "DELETE_ACCEPT"
            call ProcessDeleteAccept
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
      case "INSERT"
         call PaintInsert
      case "DELETE"
         call PaintDelete
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the wholesaler cycle list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.edi_sndto_code,"
   strQuery = strQuery & " t02.edi_whslr_name,"
   strQuery = strQuery & " t01.edi_effat_month,"
   strQuery = strQuery & " t01.edi_sndon_delay,"
   strQuery = strQuery & " t03.cycle_text"
   strQuery = strQuery & " from whslr_cycle_hdr t01, whslr t02, table(edi_billing.whslr_cycle) t03"
   strQuery = strQuery & " where t01.edi_sndto_code = t02.edi_sndto_code(+)"
   strQuery = strQuery & " and t01.edi_sndto_code = t03.sndto_code(+)"
   strQuery = strQuery & " and t01.edi_effat_month = t03.effat_month(+)"
   strQuery = strQuery & " order by t01.edi_sndto_code asc, t01.edi_effat_month asc"
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the wholesaler list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.edi_sndto_code,"
   strQuery = strQuery & " t01.edi_whslr_name"
   strQuery = strQuery & " from whslr t01"
   strQuery = strQuery & " order by t01.edi_sndto_code asc"
   strReturn = objSelection.Execute("WHSLR", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_EdiSndtoCode", "")
   call objForm.AddField("DTA_EdiEffatMonth", "")
   call objForm.AddField("DTA_EdiSndonDelay", "0")
   call objForm.AddField("DTA_EdiCycle01", "")
   call objForm.AddField("DTA_EdiCycle02", "")
   call objForm.AddField("DTA_EdiCycle03", "")
   call objForm.AddField("DTA_EdiCycle04", "")
   call objForm.AddField("DTA_EdiCycle05", "")

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

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Insert the wholesaler cycle data
   '//
   strStatement = "edi_configuration.insert_whslr_cycle("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_EdiSndtoCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_EdiEffatMonth").Value) & "',"
   strStatement = strStatement & objSecurity.FixString(objForm.Fields("DTA_EdiSndonDelay").Value) & ","
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_EdiCycle01").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_EdiCycle02").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_EdiCycle03").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_EdiCycle04").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_EdiCycle05").Value) & "'"
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
   '// Retrieve the wholesaler cycle header data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.edi_sndto_code,"
   strQuery = strQuery & " t01.edi_effat_month,"
   strQuery = strQuery & " t01.edi_sndon_delay,"
   strQuery = strQuery & " t02.edi_whslr_name,"
   strQuery = strQuery & " t03.cycle_text"
   strQuery = strQuery & " from whslr_cycle_hdr t01, whslr t02, table(edi_billing.whslr_cycle) t03"
   strQuery = strQuery & " where t01.edi_sndto_code = t02.edi_sndto_code(+)"
   strQuery = strQuery & " and t01.edi_sndto_code = t03.sndto_code(+)"
   strQuery = strQuery & " and t01.edi_effat_month = t03.effat_month(+)"
   strQuery = strQuery & " and t01.edi_sndto_code = '" & objForm.Fields("DTA_EdiSndtoCode").Value & "'"
   strQuery = strQuery & " and t01.edi_effat_month = '" & objForm.Fields("DTA_EdiEffatMonth").Value & "'"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      call ProcessSelect
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_EdiSndonDelay", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_EdiWhslrName", objSelection.ListValue04("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_EdiCycleText", objSelection.ListValue05("LIST",objSelection.ListLower("LIST")))

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
   '// Delete the wholesaler cycle data
   '//
   strStatement = "edi_configuration.delete_whslr_cycle("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_EdiSndtoCode").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_EdiEffatMonth").Value) & "'"
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
<!--#include file="mjp_edi_whslr_cycle_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="mjp_edi_whslr_cycle_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="mjp_edi_whslr_cycle_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->