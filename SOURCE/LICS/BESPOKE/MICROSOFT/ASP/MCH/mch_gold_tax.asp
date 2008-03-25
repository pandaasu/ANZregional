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

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "mch_gold_tax.asp"
   strHeading = "Stock Transfer Gold Tax Report"
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
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing

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
<%end sub%>
<!--#include file="ics_std_code.inc"-->