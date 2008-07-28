<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_spreadsheet.asp                                //
'// Author  : Steve Gregan                                       //
'// Date    : June 2006                                          //
'// Text    : This script implements the spreadsheet facility    //
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
   dim strXML
   dim objForm
   dim objSecurity
   dim objServer

   '//
   '// Set the server script timeout to (20 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 1200

   '//
   '// Initialise the script
   '//
   strTarget = "ics_spreadsheet.asp"

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
         case "GET"
            call ProcessGet
         case "SET"
            call ProcessSet
         case "READ"
            call ProcessRead
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
      case "GET"
         call PaintGet
      case "SET"
         call PaintSet
      case "READ"
         call PaintRead
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objServer = nothing

'/////////////////////////
'// Process get routine //
'/////////////////////////
sub ProcessGet()

   '//
   '// Create the spreadsheet server object and process
   '//
   set objServer = Server.CreateObject("ICS_XLSERVER.Object")
   set objServer.Security = objSecurity
   strReturn = objServer.GetSpreadsheetV1(objForm.Fields("DTA_Procedure").Value)
   if strReturn = "*OK" then
      strXML = objServer.XMLString
   end if

end sub

'/////////////////////////
'// Process set routine //
'/////////////////////////
sub ProcessSet()

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("DTA_Stream", "")

end sub

'//////////////////////////
'// Process read routine //
'//////////////////////////
sub ProcessRead()

   dim lngCount
   dim strStream

   '//
   '// Build the stream
   '//
   strStream = ""
   lngCount = clng(objForm.Fields("DTA_Count").Value)
   for i = 1 to lngCount
      strStream = strStream & objForm.Fields("StreamPart" & i).Value
   next

   '//
   '// Create the spreadsheet server object and process
   '//
   set objServer = Server.CreateObject("ICS_XLSERVER.Object")
   set objServer.Security = objSecurity
   objServer.XMLString = strStream
   strReturn = objServer.SetSpreadsheet(objForm.Fields("DTA_Procedure").Value)

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'/////////////////////////////////////
'// Paint write spreadsheet routine //
'/////////////////////////////////////
sub PaintGet()%>
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
      parent.doSpreadsheetClose(false);
   }
   function doSave() {
      var objClient;
      var strReturn;
      objClient = new ActiveXObject('ICS_XLCLIENT.Object');
      objClient.XMLString = '<%=replace(strXML, "'", "\'", 1, -1, 1)%>';
      strReturn = objClient.SetXMLStream('<%=objForm.Fields("DTA_Name").Value%>');
      objClient = null;
      if (strReturn == '*OK') {
         doCancel();
      } else {
         alert(strReturn);
      }
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Spreadsheet Download</title>
</head>
<body class="clsTable01" scroll="no" onLoad="parent.doSpreadsheetShow();">
   <table class="clsSheet" align=center cols=2 height=100% width=100% cellpadding="1" cellspacing="0"><%if strReturn = "*OK" then%>
      <tr><td class="clsLabelWB" align=center colspan=2 nowrap><nobr>&nbsp;Spreadsheet Downloaded Successfully</nobr></td></tr>
      <tr>
         <td class="clsLabelWB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSave();">&nbsp;Save&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr><%else%>
      <tr><td class="clsLabelWB" align=center colspan=1 nowrap><nobr>&nbsp;Spreadsheet Download Failed</nobr></td></tr>
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

'///////////////////////////////////
'// Paint set spreadsheet routine //
'///////////////////////////////////
sub PaintSet()%>
<html>
<script language="javascript">
<!--
   function doUpload() {
      var objClient;
      var strReturn;
      var strStream;
      var strText;
      var intCount;
      var intIndex;
      var strValues = new Array();
      objClient = new ActiveXObject('ICS_XLCLIENT.Object');
      strReturn = objClient.GetXMLStream('<%=objForm.Fields("DTA_File").Value%>');
      strStream = objClient.XMLString;
      objClient = null;
      if (strReturn == '*OK') {
         intCount = 0;
         intIndex = 0;
         strText = '';
         while (intIndex < strStream.length) {
            intCount = intCount + 1;
            strText = strText + '<input type="hidden" name="StreamPart' + intCount + '">';
            strValues[intCount] = strStream.substring(intIndex,intIndex+4000);
            intIndex = intIndex + 4000;
         }
         document.all.hidStream.innerHTML = strText;
         document.all.DTA_Count.value = intCount;
         for (i=1;i<strValues.length;i++) {
            document.getElementById('StreamPart'+i).value = strValues[i];
         }
         document.main.action = '<%=strBase%><%=strTarget%>';
         document.main.Mode.value = 'READ';
         document.main.submit();
      } else {
         alert(strReturn);
         parent.doSpreadsheetClose(false);
      }
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Spreadsheet Upload</title>
</head>
<body scroll="no" onLoad="doUpload();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table><tr><td id="hidStream" style="display:none"></td></tr></table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_Procedure" value="<%=objForm.Fields("DTA_Procedure").Value%>">
   <input type="hidden" name="DTA_Count" value="">
</form>
</body>
</html>
<%end sub

'////////////////////////////////////
'// Paint read spreadsheet routine //
'////////////////////////////////////
sub PaintRead()%>
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
      parent.doSpreadsheetClose(false);
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <meta http-equiv="expires" content="0">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>Spreadsheet Upload</title>
</head>
<body class="clsTable01" scroll="no" <%if strReturn = "*OK" then%>onLoad="parent.doSpreadsheetClose(true);"<%else%>onLoad="parent.doSpreadsheetShow();"<%end if%>>
   <table class="clsSheet" align=center cols=1 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr><td class="clsLabelWB" align=center colspan=1 nowrap><nobr>&nbsp;Spreadsheet Upload Failed</nobr></td></tr>
      <tr>
         <td class="clsLabelWB" align=center colspan=1 nowrap><nobr>
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
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->