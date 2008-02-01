<%if strReturn <> "*OK" then%>
<html>
<head>
   <meta http-equiv="content-type" content="text/html">
</head>
<body onLoad="parent.showError('<%=strReturn%>');">
</html><%else%>
<table border=1 cellpadding="0" cellspacing="0">
   <tr>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">SAP Code</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Sequence</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Group</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Classification</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Type</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Filter</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Rule</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Message</td>
   </tr><%if objSelection.ListCount("DATA") = 0 then%>
   <tr><td align=left>NO ROWS RETURNED</tr><%else%><%for i = objSelection.ListLower("DATA") to objSelection.ListUpper("DATA")%>
   <tr>
      <td align=left><%=objSelection.ListValue01("DATA",i)%></td>
      <td align=left><%=objSelection.ListValue02("DATA",i)%></td>
      <td align=left><%=objSelection.ListValue03("DATA",i)%></td>
      <td align=left><%=objSelection.ListValue04("DATA",i)%></td>
      <td align=left><%=objSelection.ListValue05("DATA",i)%></td>
      <td align=left><%=objSelection.ListValue06("DATA",i)%></td>
      <td align=left><%=objSelection.ListValue07("DATA",i)%></td>
      <td align=left><%=objSelection.ListValue08("DATA",i)%></td>
   </tr><%next%><%end if%>
</table><%end if%>