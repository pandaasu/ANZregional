<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_val_mes_download.asp                           //
'// Author  : Steve Gregan                                       //
'// Date    : August 2005                                        //
'// Text    : This script implements the validation message      //
'//           download facility                                  //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strBase
   dim strCharset
   dim objForm

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Get the base string
   '//
   strBase = GetBase()

   '//
   '// Get the character set
   '//
   strCharset = GetCharSet()

   '//
   '// Get the form data
   '//
   GetForm()

   '//
   '// Paint response
   '//
   call PaintResponse
 
   '//
   '// Destroy references
   '//
   set objForm = nothing

'////////////////////////////
'// Paint response routine //
'////////////////////////////
sub PaintResponse()%>
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
      window.close();
   }
   function showError(strError) {
      alert(strError);
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Validation Filter Message Excel Download</title>
</head>
<body class="clsTable01" scroll="no">
   <table class="clsTable01" align=left cols=1 height=100% cellpadding="0" cellspacing="0">
      <tr>
         <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doClose();">&nbsp;Close&nbsp;</a></nobr></td>
         <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Downloading Excel Data - <%=objForm.Fields("DTA_Data").Value%> - <%=objForm.Fields("DTA_Select").Value%>&nbsp;</nobr></td>
      </tr>
    </table>
   <iframe style="display:none;visibility:hidden" scrolling=no frameborder=no src="<%=strBase%>ics_val_mes_excel.asp?DTA_Data=<%=objForm.Fields("DTA_Data").Value%>&DTA_Group=<%=objForm.Fields("DTA_Group").Value%>&DTA_Select=<%=objForm.Fields("DTA_Select").Value%>"></iframe>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->