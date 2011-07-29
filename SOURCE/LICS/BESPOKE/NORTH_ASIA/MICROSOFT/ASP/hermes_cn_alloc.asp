<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : Hermes                                             //
'// Script  : hermes_cn_alloc.asp                                //
'// Author  : ISI China                                          //
'// Date    : July 2007                                          //
'// Text    : This script implements the allocation upload       //
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
   strTarget = "hermes_cn_alloc.asp"
   strHeading = "TP Allocation Load"

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
         case "ACCEPT"
            call ProcessImportAccept
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
         call PaintAlloc
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
   lngSize = 0
   strQuery = "select"
   strQuery = strQuery & " t01.tp_grp, "
   strQuery = strQuery & " t01.tp_matl_level,"
   strQuery = strQuery & " to_char(t01.tp_pct,'fm999999990.00'), "
   strQuery = strQuery & " to_char(t01.tp_pct_lupdt,'YYYY.MM.DD') "
   strQuery = strQuery & " from tp_alloc t01, tp_com t02"
   strQuery = strQuery & " where t01.tp_com_code = t02.tpc_com_code"
   strQuery = strQuery & " and t01.tp_com_code = '" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "'"
   strQuery = strQuery & " and exists (select * "
   strQuery = strQuery & "               from tp_user_sec t04 "
   strQuery = strQuery & "              where t04.tp_com_code = t01.tp_com_code "    
   strQuery = strQuery & "                and t04.tp_user_func = 'ALLLOAD' "   
   strQuery = strQuery & "                and t04.tp_user = '" & strUser & "')"
   strQuery = strQuery & " order by t01.tp_grp, t01.tp_matl_level asc "
   strReturn = objSelection.Execute("LIST", strQuery, lngSize)

' for testing
'   strReturn = strQuery  
   
   if strReturn <> "*OK" then
      strMode = "FATAL"
   else
    strMode = "LOAD"
   end if
   
end sub

'///////////////////////////////////
'// Process import accept routine //
'///////////////////////////////////
sub ProcessImportAccept()

   dim strStatement
   dim lngIndex
   dim lngCount

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Load the form data
   '//
   call objProcedure.Execute("lics_form.clear_form")
   lngCount = clng(objForm.Fields("LIN_Count").Value)
   for i = 1 to lngCount
      call objProcedure.Execute("lics_form.set_value('INP_DATA','" & objSecurity.FixString(objForm.Fields("FileLine" & i).Value) & "')")
   next

   '//
   '// Load the allocation data
   '//
   on error resume next   'get rid of the 500 error
   strStatement = "hermes_load.load_alloc('" & objSecurity.FixString(objForm.Fields("DTA_TpaComCode").Value) & "','" & strUser & "')"
   strReturn = objFunction.Execute(strStatement)
   if strReturn <> "*OK" then
      strMode = "FATAL"
      exit sub
   end if

   '//
   '// Output any errors from the procedure
   '//
   strReturn = ""
   lngCount = clng(objFunction.Execute("lics_form.get_array_count('VAR_ERROR')"))
   for lngIndex = 1 to lngCount
      strReturn = strReturn & objFunction.Execute("lics_form.get_array('VAR_ERROR'," & lngIndex & ")")
      if lngIndex < lngCount then
         strReturn = strReturn & "<br>"
      end if
   next

   '//
   '// Set the mode
   '//
   if strReturn = "" then
    strMode = "LOAD"
    call ProcessImportLoad
  else 
    strMode = "FATAL"
  end if

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint allocation routine //
'//////////////////////////
sub PaintAlloc()%>
<!--#include file="hermes_cn_alloc.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->