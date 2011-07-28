<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS - Interface Control System                     //
'// Script  : ics_val_enq.asp                                    //
'// Author  : Steve Gregan                                       //
'// Date    : August 2005                                        //
'// Text    : This script executes the validation enquiry        //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strBase
   dim strStatus
   dim strCharset
   dim strHeading
   dim strReturn
   dim objSecurity

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strHeading = "Validation Enquiry"

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
   strReturn = GetSecurityCheck("GRD_VAL_ENQUIRY")
   if strReturn <> "*OK" then
      call PaintFatal
   else
      call PaintResponse
   end if

   '//
   '// Destroy references
   '//
   set objSecurity = nothing

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
<html>
<script language="javascript">
<!--
   function setEnquiry(strValue) {
      fraEnquiry.document.location.href = strValue;
   }
   function showSelect() {
      var objStart = eval('document.all("fntStart")');
      var objEnquiry = eval('document.all("fraEnquiry")');
      var objSelect = eval('document.all("fraSelect")');
      objStart.style.display = 'none';
      objStart.style.visibility = 'hidden';
      objEnquiry.style.display = 'none';
      objEnquiry.style.visibility = 'hidden';
      objSelect.style.display = 'block';
      objSelect.style.visibility = 'visible';
   }
   function showEnquiry() {
      var objStart = eval('document.all("fntStart")');
      var objEnquiry = eval('document.all("fraEnquiry")');
      var objSelect = eval('document.all("fraSelect")');
      objStart.style.display = 'none';
      objStart.style.visibility = 'hidden';
      objSelect.style.display = 'none';
      objSelect.style.visibility = 'hidden';
      objEnquiry.style.display = 'block';
      objEnquiry.style.visibility = 'visible';
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="no" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_val_enq_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showSelect();">
   <table class="clsGrid02" align=center valign=top cols=1 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:showSelect();">&nbsp;Select&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:showEnquiry();">&nbsp;Enquiry&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td colspan=1 width=100% height=100%>
            <table class="clsSite" cols=1 width="100%" height="100%" cellspacing="0">
               <tr><td nowrap colspan=1 height=100% width=100% class="clsInner" align=center valign=center>
                  <font class="clsTitle" id="fntStart" style="display:block;visibility:visible;">** LOADING **</font>
                  <iframe id="fraSelect" style="display:none;visibility:hidden" scrolling=no frameborder=no bgcolor=#dedfe2 width=100% height=100% src="ics_val_enq_select.asp"></iframe>
                  <iframe id="fraEnquiry" style="display:none;visibility:hidden" scrolling=no frameborder=no bgcolor=#dedfe2 width=100% height=100% src="ics_val_enq_content.htm"></iframe>
               </td></tr>
            </table>
         </td>
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->