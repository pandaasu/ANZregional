<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_report.asp                                     //
'// Author  : Steve Gregan                                       //
'// Date    : March 2008                                         //
'// Text    : This script implements the report facility         //
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
   strTarget = "ics_report.asp"

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
      strMode = objForm.Fields().Item("Mode")

      '//
      '// Process the form data
      '//
      select case strMode
         case "PROMPT"
            call ProcessReportPrompt
         case "*SPREADSHEET"
            call ProcessReportSpreadsheet
         case else
            strReturn = "*ERROR: Invalid processing mode " & objForm.Fields().Item("Mode") & " specified"
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
'// Process report prompt routine //
'///////////////////////////////////
sub ProcessReportPrompt()%>
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
   function doClose() {
      parent.doReportClose();
   }
   function doExecute() {
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = '<%=objForm.Fields().Item("DTA_Format")%>';
      document.main.submit();
   }
// -->
</script>
<html>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Report</title>
</head>
<body class="clsTable02" scroll="no" onLoad="parent.doReportShow();doExecute();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsPopup" align=center cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr><td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;Report Processing</nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr><%=objForm.Fields().Item("DTA_Name")%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doClose();">&nbsp;Close&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
    </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="DTA_Name" value="<%=objForm.Fields().Item("DTA_Name")%>">
   <input type="hidden" name="DTA_Format" value="<%=objForm.Fields().Item("DTA_Format")%>">
   <input type="hidden" name="DTA_Query" value="<%=objForm.Fields().Item("DTA_Query")%>">
</form>
</html>
<%end sub

'////////////////////////////////////////
'// Process report spreadsheet routine //
'////////////////////////////////////////
sub ProcessReportSpreadsheet()

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ics_selection2.ICS_Selection")
   objSelection.Security(objSecurity)

   '//
   '// Execute the report spreadsheet
   '//
   strReturn = objSelection.Execute("REPORT", objForm.Fields().Item("DTA_Query"), 0)
   if strReturn = "*OK" then
      Response.Buffer = true
      Response.ContentType = "application/vnd.ms-excel; charset=UTF-8"
      Response.AddHeader "content-disposition", "attachment; filename=" & objForm.Fields().Item("DTA_Name") & ".xls"
      Response.Write "<meta http-equiv='content-type' content='application/vnd.ms-excel; charset=UTF-8'>"
      for i = objSelection.ListLower("REPORT") to objSelection.ListUpper("REPORT")
         Response.Write objSelection.ListValue01("REPORT",i)
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
   function doClose() {
      parent.doReportClose();
   }
// -->
</script>
<html>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Report</title>
</head>
<body class="clsTable02" scroll="no">
   <table class="clsPopup" align=center cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr><td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Report Spreadsheet Creation Failed</nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr><%=objForm.Fields().Item("DTA_Name")%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doClose();">&nbsp;Close&nbsp;</a></nobr></td>
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

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub%>
<!--#include file="ics_std_code.inc"-->