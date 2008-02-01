<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_lads_deletion.asp                              //
'// Author  : Steve Gregan                                       //
'// Date    : August 2006                                        //
'// Text    : This script implements the LADS deletion           //
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
   dim strConfirm
   dim strFinal
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objFunction

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "ics_lads_deletion.asp"
   strHeading = "LADS Transaction Deletion"
   strError = ""
   strConfirm = ""
   strFinal = ""

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
   strReturn = GetSecurityCheck("LAD_DELETION")
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
         case "PROMPT"
            call ProcessPrompt
         case "CONFIRM"
            call ProcessConfirm
         case "DELETE"
            call ProcessDelete
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
   set objFunction = nothing

'////////////////////////////
'// Process prompt routine //
'////////////////////////////
sub ProcessPrompt()

   '//
   '// Initialise the fields
   '//
   call objForm.AddField("DTA_Transaction", "*ORD")
   call objForm.AddField("DTA_Identifier", "")

end sub

'/////////////////////////////
'// Process confirm routine //
'/////////////////////////////
sub ProcessConfirm()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Process based on the transaction type
   '//
   if objForm.Fields("DTA_Transaction").Value = "*ORD" then
      strStatement = "lads_atllad13_deletion.execute('*CON',"
   end if
   if objForm.Fields("DTA_Transaction").Value = "*DLV" then
      strStatement = "lads_atllad16_deletion.execute('*CON',"
   end if
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_Identifier").Value) & "')"
   strReturn = objFunction.Execute(strStatement)
   if mid(strReturn,1,3) <> "*OK" then
      strMode = "ERROR"
      strError = FormatError(strReturn)
   else
      strMode = "CONFIRM"
      strConfirm = FormatError(mid(strReturn,4,len(strReturn)-3))
   end if

end sub

'////////////////////////////
'// Process delete routine //
'////////////////////////////
sub ProcessDelete()

   dim strStatement

   '//
   '// Create the function object
   '//
   set objFunction = Server.CreateObject("ICS_FUNCTION.Object")
   set objFunction.Security = objSecurity

   '//
   '// Process based on the transaction type
   '//
   if objForm.Fields("DTA_Transaction").Value = "*ORD" then
      strStatement = "lads_atllad13_deletion.execute('*DEL',"
   end if
   if objForm.Fields("DTA_Transaction").Value = "*DLV" then
      strStatement = "lads_atllad16_deletion.execute('*DEL',"
   end if
   strStatement = strStatement & "'" & objSecurity.FixString(objForm.Fields("DTA_Identifier").Value) & "')"
   strReturn = objFunction.Execute(strStatement)
   if mid(strReturn,1,3) <> "*OK" then
      strMode = "ERROR"
      strError = FormatError(strReturn)
   else
      strMode = "FINAL"
      strFinal = FormatError(mid(strReturn,4,len(strReturn)-3))
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
<!--#include file="ics_lads_deletion.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->