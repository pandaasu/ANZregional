<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : mch_gold_tax.asp                                   //
'// Author  : Steve Gregan                                       //
'// Date    : January 2008                                       //
'// Text    : This script implements the China gold tax          //
'//           enquiry functionality                              //
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
   dim objProcedure

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "mch_gold_tax.asp"
   strHeading = "Gold Tax Enquiry"
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
   strReturn = GetSecurityCheck("MCH_GOLD_TAX")
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
         case "ACCEPT"
            call ProcessAccept
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
      case "ACCEPT"
         call PaintAccept
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objProcedure = nothing

'////////////////////////////
'// Process select routine //
'////////////////////////////
sub ProcessSelect()

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_TaxClass01", "")
   call objForm.AddField("DTA_TaxClass01", "")
   call objForm.AddField("DTA_SupplyPlant", "")
   call objForm.AddField("DTA_SupplyLocation", "")
   call objForm.AddField("DTA_ReceivingPlant", "")
   call objForm.AddField("DTA_GIDate01", "")
   call objForm.AddField("DTA_GIDate02", "")

end sub

'////////////////////////////
'// Process accept routine //
'////////////////////////////
sub ProcessAccept()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Retrieve the gold tax data
   '//
   strStatement = "dw_tax_reporting.gold_tax_file("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_TaxClass01").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_TaxClass01").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SupplyPlant").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_SupplyLocation").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_ReceivingPlant").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_GIDate01").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_GIDate02").Value) & "'"
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strError = FormatError(strReturn)
      strMode = "SELECT"
      exit sub
   end if

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint select routine //
'//////////////////////////
sub PaintSelect()%>
<!--#include file="mch_gold_tax_select.inc"-->
<%end sub

'//////////////////////////
'// Paint accept routine //
'//////////////////////////
sub PaintAccept()%>
<!--#include file="mch_gold_tax_display.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->