<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_asn_dts_message.asp                            //
'// Author  : Steve Gregan                                       //
'// Date    : November 2005                                      //
'// Text    : This script implements the ASN DTS monitor         //
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

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** allow for network performance issues **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_asn_dts_message.asp"
   strHeading = "Advanced Shipping Notice - Direct To Store - Message Monitor"

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
   strReturn = GetSecurity()
   if strReturn = "*OK" then

      '//
      '// Get the form data
      '//
      GetForm()

      '//
      '// Process the form
      '//
      call ProcessForm

   end if

   '//
   '// Paint response
   '//
   if strReturn <> "*OK" then
      call PaintFatal
   else
      call PaintForm
   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing

'//////////////////////////
'// Process form routine //
'//////////////////////////
sub ProcessForm()

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
         strTest = " where "
         strOrder = "desc"
      case "PREVIOUS"
         strWhere = " where t01.dmh_smsg_nbr > '" & objForm.Fields("STR_SendNumber").Value & "'"
         strTest = " and "
         strOrder = "asc"
      case "NEXT"
         strWhere = " where t01.dmh_smsg_nbr < '" & objForm.Fields("END_SendNumber").Value & "'"
         strTest = " and "
         strOrder = "desc"
   end select
   strQuery = "select /*+ FIRST_ROWS */"
   strQuery = strQuery & " t01.dmh_smsg_nbr,"
   strQuery = strQuery & " to_char(t01.dmh_crtn_tim, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " to_char(t01.dmh_updt_tim, 'YYYY/MM/DD HH24:MI:SS'),"
   strQuery = strQuery & " nvl(to_char(t01.dmh_smsg_tim, 'YYYY/MM/DD HH24:MI:SS'),'NO'),"
   strQuery = strQuery & " nvl(to_char(t01.dmh_smsg_ack, 'YYYY/MM/DD HH24:MI:SS'),'NO'),"
   strQuery = strQuery & " t01.dmh_smsg_cnt,"
   strQuery = strQuery & " t01.dmh_mars_cde,"
   strQuery = strQuery & " t01.dmh_load_nbr"
   strQuery = strQuery & " from asn_dts_msg_hdr t01"
   if strWhere <> "" then
      strQuery = strQuery & strWhere
   end if
   if objForm.Fields("QRY_MarsCode").Value <> "" then
      strQuery = strQuery & strTest & "t01.dmh_mars_cde = '" & objForm.Fields("QRY_MarsCode").Value & "'"
      strTest = " and "
   end if
   if objForm.Fields("QRY_LoadNumber").Value <> "" then
      strQuery = strQuery & strTest & "t01.dmh_load_nbr like '%" & objForm.Fields("QRY_LoadNumber").Value & "'"
      strTest = " and "
   end if
   strQuery = strQuery & " order by t01.dmh_smsg_nbr " & strOrder
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

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint form routine //
'//////////////////////////
sub PaintForm()%>
<!--#include file="ics_asn_dts_message.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->