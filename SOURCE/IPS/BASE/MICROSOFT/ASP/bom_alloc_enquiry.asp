<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : bom_alloc_enquiry.asp                              //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the BOM allocation enquiry  //
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

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "bom_alloc_enquiry.asp"
   strHeading = "BOM Allocation Enquiry"
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
   strReturn = GetSecurityCheck("BOM_ALLOC_ENQUIRY")
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
         case "EXECUTE"
            call ProcessSelect
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

'////////////////////////////
'// Process select routine //
'////////////////////////////
sub ProcessSelect()

   dim strQuery
   dim strCompany
   dim strMaterial
   dim strDate
   dim strDetail

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the BOM allocation data when required
   '//
   if strMode = "EXECUTE" then
      strCompany = objForm.Fields("DTA_Company").Value
      strMaterial = objForm.Fields("DTA_Material").Value
      strDate = objForm.Fields("DTA_Date").Value
      strDetail = objForm.Fields("DTA_Detail").Value
      strQuery = "select"
      strQuery = strQuery & " alc_type,"
      strQuery = strQuery & " bom_plant,"
      strQuery = strQuery & " bom_matl_code,"
      strQuery = strQuery & " bom_altv,"
      strQuery = strQuery & " bom_qty,"
      strQuery = strQuery & " bom_uom,"
      strQuery = strQuery & " bom_matl_type,"
      strQuery = strQuery & " bom_trdd_unit,"
      strQuery = strQuery & " bom_base_uom,"
      strQuery = strQuery & " bom_net_wght,"
      strQuery = strQuery & " bom_gross_wght,"
      strQuery = strQuery & " cmpnt_matl_code,"
      strQuery = strQuery & " cmpnt_qty,"
      strQuery = strQuery & " cmpnt_uom,"
      strQuery = strQuery & " cmpnt_matl_type,"
      strQuery = strQuery & " cmpnt_base_uom,"
      strQuery = strQuery & " cmpnt_net_wght,"
      strQuery = strQuery & " cmpnt_gross_wght,"
      strQuery = strQuery & " proportion,"
      strQuery = strQuery & " bom_hierarchy_level,"
      strQuery = strQuery & " bom_hierarchy_root,"
      strQuery = strQuery & " bom_hierarchy_path"
      strQuery = strQuery & " from table(bp_app.bpip_bom.allocation('" & strCompany & "', '" & strMaterial & "', '" & strDate & "', '" & strDetail & "'))"
      strReturn = objSelection.Execute("REPORT", strQuery, 0)
      if strReturn <> "*OK" then
         strReturn = strReturn
         strMode = "FATAL"
         exit sub
      end if
   end if

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
<!--#include file="bom_alloc_enquiry.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->