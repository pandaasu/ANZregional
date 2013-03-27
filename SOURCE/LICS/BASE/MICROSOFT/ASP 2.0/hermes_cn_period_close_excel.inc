<%if strReturn <> "*OK" then%>
<html>
<head>
   <meta http-equiv="content-type" content="text/html">
</head>
<body onLoad="parent.showError('<%=strReturn%>');">
</html><%else%>
<table border=1 cellpadding="0" cellspacing="0">
   <tr>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Period</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">TP ID</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Description</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Group</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Customer</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Material</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">TP Type</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Reversal</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Budget Date</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Status</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">User</td>
   </tr><%if clng(objSelection.ListCount("DATA")) = 0 then%>
   <tr><td align=left>NO ROWS RETURNED</tr><%else%><%for i = clng(objSelection.ListLower("DATA")) to clng(objSelection.ListUpper("DATA"))%>
   <tr>
      <td align=center><%=objSelection.ListValue01("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue02("DATA",i)%></td>
      <td align=left><%=objSelection.ListValue03("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue04("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue05("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue06("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue07("DATA",i)%></td>
      <td align=right><%=objSelection.ListValue08("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue09("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue10("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue11("DATA",i)%></td>
   </tr><%next%><%end if%>
</table><%end if%>