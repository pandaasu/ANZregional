<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_asn_dcs_cancel.asp                             //
'// Author  : Steve Gregan                                       //
'// Date    : December 2005                                      //
'// Text    : This script implements the ASN DCS cancel          //
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
   dim strHeading
   dim strMode
   dim bolStrList
   dim bolEndList
   dim objForm
   dim objSecurity
   dim objSelection
   dim objProcedure

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_asn_dcs_cancel.asp"
   strHeading = "Advanced Shipping Notice - Distribution Centre - Cancel"

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
   strReturn = GetSecurityCheck("ASN_DCS_CANCEL")
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
         case "SEARCH"
            call ProcessSelect
         case "NEXT"
            call ProcessSelect
         case "PREVIOUS"
            call ProcessSelect
         case "UPDATE"
            call ProcessUpdate
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
      case "SEARCH"
         call PaintSelect
      case "NEXT"
         call PaintSelect
      case "PREVIOUS"
         call PaintSelect
   end select
 
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
   dim strWhere
   dim strTest
   dim lngSize
   dim strOrder

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the execution list
   '//
   lngSize = 20
   if objForm.Fields("Mode").Value = "" then
      call objForm.AddField("Mode", "SEARCH")
   end if
   select case objForm.Fields("Mode").Value
      case "SEARCH"
         strWhere = ""
         strTest = " and "
         strOrder = "desc"
      case "PREVIOUS"
         strWhere = " where (t01.dch_mars_cde > '" & objForm.Fields("STR_MarsCode").Value & "'"
         strWhere = strWhere & " or (t01.dch_mars_cde = '" & objForm.Fields("STR_MarsCode").Value & "' and t01.dch_pick_nbr > '" & objForm.Fields("STR_PickNumber").Value & "'))"
         strTest = " and "
         strOrder = "asc"
      case "NEXT"
         strWhere = " where (t01.dch_mars_cde < '" & objForm.Fields("STR_MarsCode").Value & "'"
         strWhere = strWhere & " or (t01.dch_mars_cde = '" & objForm.Fields("STR_MarsCode").Value & "' and t01.dch_pick_nbr < '" & objForm.Fields("STR_PickNumber").Value & "'))"
         strTest = " and "
         strOrder = "desc"
   end select
   strQuery = "select /*+ FIRST_ROWS */"
   strQuery = strQuery & " t01.dch_mars_cde,"
   strQuery = strQuery & " t01.dch_pick_nbr,"
   strQuery = strQuery & " t01.dch_pick_typ,"
   strQuery = strQuery & " to_char(t01.dch_crtn_tim, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " to_char(t01.dch_updt_tim, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " t01.dch_stat_cde,"
   strQuery = strQuery & " t01.dch_emsg_txt"
   strQuery = strQuery & " from asn_dcs_hdr t01"
   strQuery = strQuery & " where t01.dch_stat_cde != '*COMPLETE' and t01.dch_stat_cde != '*CANCELLED'"
   if strWhere <> "" then
      strQuery = strQuery & strWhere
   end if
   if objForm.Fields("QRY_MarsCode").Value <> "" then
      strQuery = strQuery & strTest & "t01.dch_mars_cde = '" & objForm.Fields("QRY_MarsCode").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_PickNumber").Value <> "" then
      strQuery = strQuery & strTest & "t01.dch_pick_nbr like '%" & objForm.Fields("QRY_PickNumber").Value & "'"
      strTest = " and "
   end if
   strQuery = strQuery & " order by t01.dch_mars_cde " & strOrder & ", t01.dch_pick_nbr " & strOrder
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Set the list start and end indicators
   '//
   bolStrList = true
   bolEndList = true
   if objSelection.ListCount("LIST") <> 0 then
      select case objForm.Fields("Mode").Value
         case "SEARCH"
            bolStrList = true
            if objSelection.ListMore("LIST") = true then
               bolEndList = false
            end if
         case "PREVIOUS"
            if objSelection.ListMore("LIST") = true then
               bolStrList = false
            end if
            bolEndList = false
         case "NEXT"
            bolStrList = false
            if objSelection.ListMore("LIST") = true then
               bolEndList = false
            end if
      end select
   end if

end sub

'////////////////////////////
'// Process update routine //
'////////////////////////////
sub ProcessUpdate()

   dim strStatement

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Update the interface
   '//
   strStatement = "asn_dcs_processor.cancel("
   strStatement = strStatement & "'" & objForm.Fields("DTA_MarsCode").Value & "',"
   strStatement = strStatement & "'" & objForm.Fields("DTA_PickNumber").Value & "'"
   strStatement = strStatement & ")"
   strReturn = objProcedure.Execute(strStatement)
   if strReturn <> "*OK" then
      strReturn = FormatError(strReturn)
   end if

   '//
   '// Set the mode
   '//
   strMode = "SEARCH"
   call ProcessSelect

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
<!--#include file="ics_asn_dcs_cancel.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->