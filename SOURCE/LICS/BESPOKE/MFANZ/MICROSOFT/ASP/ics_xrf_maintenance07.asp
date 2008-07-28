<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_xrf_maintenance06.asp                          //
'// Author  : Linden Glen                                        //
'// Date    : February 2005                                      //
'// Text    : This script implements the cross reference         //
'//           maintenance functionality (LADS_DET_XREF)          //
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
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_xrf_maintenance06.asp"
   strHeading = "Cross Reference Maintenance"

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
   strReturn = GetSecurityCheck("XRF_NZ_CUSTOMER")
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
         case "PREVIOUS"
            call ProcessSelect
         case "NEXT"
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
      case "PREVIOUS"
         call PaintSelect
      case "NEXT"
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
   dim strWhere
   dim lngSize
   dim strOrder

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the cross reference header
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.xrf_code,"
   strQuery = strQuery & " t01.xrf_desc"
   strQuery = strQuery & " from lads_xrf_hdr t01"
   strQuery = strQuery & " where t01.xrf_code = 'NZ_VENDOR'"
   strReturn = objSelection.Execute("HEADER", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("XRF_Code", objSelection.ListValue01("HEADER",objSelection.ListLower("HEADER")))
   call objForm.AddField("XRF_Description", objSelection.ListValue02("HEADER",objSelection.ListLower("HEADER")))

   '//
   '// Retrieve the cross reference detail list
   '//
   lngSize = 30
   if objForm.Fields("Mode").Value = "" then
      call objForm.AddField("Mode", "SEARCH")
   end if
   if objForm.Fields("QRY_Test").Value = "" then
      call objForm.AddField("QRY_Test", "EQ")
   end if
   select case objForm.Fields("Mode").Value
      case "SEARCH"
         strWhere = ""
         strOrder = "asc"
      case "PREVIOUS"
         strWhere = " and t01.xrf_source < '" & objForm.Fields("STR_Source").Value & "'"
         strOrder = "desc"
      case "NEXT"
         strWhere = " and t01.xrf_source > '" & objForm.Fields("END_Source").Value & "'"
         strOrder = "asc"
   end select
   strQuery = "select /*+ FIRST_ROWS */"
   strQuery = strQuery & " t01.xrf_source,"
   strQuery = strQuery & " t01.xrf_target"
   strQuery = strQuery & " from lads_xrf_det t01"
   strQuery = strQuery & " where t01.xrf_code = '" & objForm.Fields("XRF_Code").Value & "'"
   if strWhere <> "" then
      strQuery = strQuery & strWhere
   end if
   if objForm.Fields("QRY_Source").Value <> "" then
      if objForm.Fields("QRY_Test").Value = "EQ" then
         strQuery = strQuery & " and t01.xrf_source = '" & objForm.Fields("QRY_Source").Value & "'"
      end if
      if objForm.Fields("QRY_Test").Value = "LE" then
         strQuery = strQuery & " and t01.xrf_source <= '" & objForm.Fields("QRY_Source").Value & "'"
      end if
      if objForm.Fields("QRY_Test").Value = "GE" then
         strQuery = strQuery & " and t01.xrf_source >= '" & objForm.Fields("QRY_Source").Value & "'"
      end if
   end if
   strQuery = strQuery & " order by xrf_source " & strOrder
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)
   if strReturn <> "*OK" then
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

'/////////////////////////////////
'// Process insert load routine //
'/////////////////////////////////
sub ProcessInsertLoad()

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("XRF_Source", "")
   call objForm.AddField("XRF_Target", "")

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
   '// Insert the cross reference detail
   '//
   strStatement = "lads_xrf_maintenance.insert_detail("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("XRF_Code").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("XRF_Source").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("XRF_Target").Value) & "')"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "INSERT"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SEARCH"
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
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Retrieve the cross reference detail
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.xrf_source,"
   strQuery = strQuery & " t01.xrf_target"
   strQuery = strQuery & " from lads_xrf_det t01"
   strQuery = strQuery & " where t01.xrf_code = '" & objForm.Fields("XRF_Code").Value & "'"
   strQuery = strQuery & " and t01.xrf_source = '" & objForm.Fields("XRF_Source").Value & "'"
   strReturn = objSelection.Execute("DETAIL", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SEARCH"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("XRF_Source", objSelection.ListValue01("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("XRF_Target", objSelection.ListValue02("DETAIL",objSelection.ListLower("DETAIL")))

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
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Update the cross reference detail
   '//
   strStatement = "lads_xrf_maintenance.update_detail("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("XRF_Code").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("XRF_Source").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("XRF_Target").Value) & "')"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "UPDATE"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SEARCH"
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
   '// Retrieve the cross reference detail
   '//
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.xrf_source,"
   strQuery = strQuery & " t01.xrf_target"
   strQuery = strQuery & " from lads_xrf_det t01"
   strQuery = strQuery & " where t01.xrf_code = '" & objForm.Fields("XRF_Code").Value & "'"
   strQuery = strQuery & " and t01.xrf_source = '" & objForm.Fields("XRF_Source").Value & "'"
   strReturn = objSelection.Execute("DETAIL", strQuery, lngSize)
   if strReturn <> "*OK" then
      strMode = "SEARCH"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("XRF_Source", objSelection.ListValue01("DETAIL",objSelection.ListLower("DETAIL")))
   call objForm.AddField("XRF_Target", objSelection.ListValue02("DETAIL",objSelection.ListLower("DETAIL")))

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
   '// Delete the cross reference detail
   '//
   strStatement = "lads_xrf_maintenance.delete_detail("
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("XRF_Code").Value) & "',"
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("XRF_Source").Value) & "')"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "DELETE"
      strReturn = FormatError(strReturn)
      exit sub
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
'// Paint prompt routine //
'//////////////////////////
sub PaintSelect()%>
<!--#include file="ics_xrf_maintenance07_select.inc"-->
<%end sub

'//////////////////////////
'// Paint insert routine //
'//////////////////////////
sub PaintInsert()%>
<!--#include file="ics_xrf_maintenance07_insert.inc"-->
<%end sub

'//////////////////////////
'// Paint update routine //
'//////////////////////////
sub PaintUpdate()%>
<!--#include file="ics_xrf_maintenance07_update.inc"-->
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
<!--#include file="ics_xrf_maintenance07_delete.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->