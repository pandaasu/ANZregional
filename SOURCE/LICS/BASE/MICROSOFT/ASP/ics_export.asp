<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_export.asp                                     //
'// Author  : Steve Gregan                                       //
'// Date    : March 2008                                         //
'// Text    : This script implements the export facility         //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim strBase
   dim strTarget
   dim strCharset
   dim strReturn
   dim strError
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection

   '//
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "ics_export.asp"

   '//
   '// Get the base string
   '//
   strBase = GetBase()

   '//
   '// Get the character set
   '//
   strCharset = GetCharSet()

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurity()
   if strReturn <> "*OK" then
      call PaintFatal
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
            call ProcessExportPrompt
         case "*FILE"
            call ProcessExportFile
         case "*INTERFACE"
            call ProcessExportInterface
         case else
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
            call PaintFatal
      end select

   end if
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing

'///////////////////////////////////
'// Process export prompt routine //
'///////////////////////////////////
sub ProcessExportPrompt()%>
<html>
<script language="javascript">
<!--
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
      if (objElement.className == 'clsSelect') {
         objElement.className = 'clsSelectX';
      }
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
      if (objElement.className == 'clsSelectX') {
         objElement.className = 'clsSelect';
      }
   }
   function doCancel() {
      parent.doExportClose(false);
   }
   function doExecute() {
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = '<%=objForm.Fields("DTA_Format").Value%>';
      document.main.submit();
   }
// -->
</script>
<html>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Export</title>
</head>
<body class="clsTable01" scroll="no" onLoad="parent.doExportShow();doExecute();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsSheet" align=center cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr><td class="clsLabelWB" align=center colspan=2 nowrap><nobr>&nbsp;Export Processing</nobr></td></tr>
      <tr>
         <td class="clsLabelWB" align=center colspan=2 nowrap><nobr><%=objForm.Fields("DTA_Name").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelWB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
    </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_Name" value="<%=objForm.Fields("DTA_Name").Value%>">
   <input type="hidden" name="DTA_Format" value="<%=objForm.Fields("DTA_Format").Value%>">
   <input type="hidden" name="DTA_Query" value="<%=objForm.Fields("DTA_Query").Value%>">
</form>
</html>
<%end sub

'/////////////////////////////////
'// Process export file routine //
'/////////////////////////////////
sub ProcessExportFile()

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Execute the export file
   '//
   strReturn = objSelection.Execute("EXPORT", objForm.Fields("DTA_Query").Value, 0)
   if strReturn = "*OK" then
      Response.Buffer = true
      Response.ContentType = "application/octet-stream"
      Response.AddHeader "content-disposition", "attachment; filename=" & objForm.Fields("DTA_Name").Value & ".TXT"
      for i = objSelection.ListLower("EXPORT") to objSelection.ListUpper("EXPORT")
         if i > objSelection.ListLower("EXPORT") then
            Response.Write vbNewLine
         end if
         Response.Write objSelection.ListValue01("EXPORT",i)
      next
   else%>
<script language="javascript">
<!--
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
      if (objElement.className == 'clsSelect') {
         objElement.className = 'clsSelectX';
      }
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
      if (objElement.className == 'clsSelectX') {
         objElement.className = 'clsSelect';
      }
   }
   function doCancel() {
      parent.doExportClose(false);
   }
// -->
</script>
<html>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Export</title>
</head>
<body class="clsTable01" scroll="no">
   <table class="clsSheet" align=center cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr><td class="clsLabelWB" align=center colspan=1 nowrap><nobr>&nbsp;Export File Creation Failed</nobr></td></tr>
      <tr>
         <td class="clsLabelWB" align=center colspan=2 nowrap><nobr><%=objForm.Fields("DTA_Name").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelWB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScrollFrame" id="conBody">
                     <table class="clsGrid01" id="tabBody" align=left cols=1 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsNormalFix" align=left colspan=1><pre><%=strReturn%></pre></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
    </table>
</body>
</html><%
   end if

end sub

'//////////////////////////////////////
'// Process export interface routine //
'//////////////////////////////////////
sub ProcessExportInterface()

   '//
   '// Create the procedure object
   '//
   set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
   set objProcedure.Security = objSecurity

   '//
   '// Execute the export interface
   '//
   strReturn = objFunction.Execute(objForm.Fields("DTA_Query").Value)%>
<html>
<script language="javascript">
<!--
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
      if (objElement.className == 'clsSelect') {
         objElement.className = 'clsSelectX';
      }
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
      if (objElement.className == 'clsSelectX') {
         objElement.className = 'clsSelect';
      }
   }
   function doCancel() {
      parent.doExportClose(false);
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Export</title>
</head>
<body class="clsTable01" scroll="no">
   <table class="clsSheet" align=center cols=2 height=100% width=100% cellpadding="1" cellspacing="0"><%if strReturn = "*OK" then%>
      <tr><td class="clsLabelWB" align=center colspan=2 nowrap><nobr>&nbsp;Export Interface Created Successfully</nobr></td></tr>
      <tr>
         <td class="clsLabelWB" align=center colspan=2 nowrap><nobr><%=objForm.Fields("DTA_Name").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelWB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr><%else%>
      <tr><td class="clsLabelWB" align=center colspan=1 nowrap><nobr>&nbsp;Export Interface Creation Failed</nobr></td></tr>
      <tr>
         <td class="clsLabelWB" align=center colspan=2 nowrap><nobr><%=objForm.Fields("DTA_Name").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelWB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScrollFrame" id="conBody">
                     <table class="clsGrid01" id="tabBody" align=left cols=1 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsNormalFix" align=left colspan=1><pre><%=strReturn%></pre></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr><%end if%>
    </table>
</body>
</html>
<%end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->