<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : mch_tax_customer.asp                               //
'// Author  : Steve Gregan                                       //
'// Date    : February 2008                                      //
'// Text    : This script implements the China tax customer      //
'//           configuration functionality                        //
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

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "mch_tax_customer.asp"
   strHeading = "Tax Customer Configuration"
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
   strReturn = GetSecurityCheck("MCH_TAX_CUST_CONFIG")
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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the tax customer list
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.cust_code,"
   strQuery = strQuery & " t01.cust_name"
   strQuery = strQuery & " from china_tax_customer t01"
   strQuery = strQuery & " order by t01.cust_code asc"
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

end sub

'/////////////////////////////////
'// Process insert load routine //
'/////////////////////////////////
sub ProcessInsertLoad()

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_CustCode", "")
   call objForm.AddField("DTA_CustName", "")
   call objForm.AddField("DTA_CustAddr", "")
   call objForm.AddField("DTA_CustBank", "")
   call objForm.AddField("DTA_TaxCode", "")

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
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Insert the tax customer data
   '//
   strStatement = "dw_tax_configuration.insert_tax_customer("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_CustCode")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_CustName")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_CustAddr")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_CustBank")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_TaxCode")) & "'"
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
'// Process update load routine //
'/////////////////////////////////
sub ProcessUpdateLoad()

   dim strQuery
   dim lngSize

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the tax customer data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.cust_code,"
   strQuery = strQuery & " t01.cust_name,"
   strQuery = strQuery & " t01.cust_addr,"
   strQuery = strQuery & " t01.cust_bank,"
   strQuery = strQuery & " t01.tax_code"
   strQuery = strQuery & " from china_tax_customer t01"
   strQuery = strQuery & " where t01.cust_code = '" & objForm.Fields().Item("DTA_CustCode") & "'"
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
   call objForm.AddField("DTA_CustName", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_CustAddr", objSelection.ListValue03("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_CustBank", objSelection.ListValue04("LIST",objSelection.ListLower("LIST")))
   call objForm.AddField("DTA_TaxCode", objSelection.ListValue05("LIST",objSelection.ListLower("LIST")))

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

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Update the tax customer data
   '//
   strStatement = "dw_tax_configuration.update_tax_customer("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_CustCode")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_CustName")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_CustAddr")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_CustBank")) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_TaxCode")) & "'"
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
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Retrieve the tax customer data
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.cust_code,"
   strQuery = strQuery & " t01.cust_name"
   strQuery = strQuery & " from china_tax_customer t01"
   strQuery = strQuery & " where t01.cust_code = '" & objForm.Fields().Item("DTA_CustCode") & "'"
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
   call objForm.AddField("DTA_CustName", objSelection.ListValue02("LIST",objSelection.ListLower("LIST")))

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
   set objFunction = Server.CreateObject("ics_function2.ICS_FUNCTION")
   objFunction.Security(objSecurity)

   '//
   '// Delete the tax customer data
   '//
   strStatement = "dw_tax_configuration.delete_tax_customer("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields().Item("DTA_CustCode")) & "'"
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
<!--#include file="mch_tax_customer_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="mch_tax_customer_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="mch_tax_customer_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="mch_tax_customer_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->