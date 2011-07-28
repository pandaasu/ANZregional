<%if strReturn <> "*OK" then%>
<html>
<head>
   <meta http-equiv="content-type" content="text/html">
</head>
<body onLoad="parent.showError('<%=strReturn%>');">
</html><%else%>
<table border=1 cellpadding="0" cellspacing="0">
   <tr>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">TP BR Version</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Company Code</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">TP Type</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Customer Level</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Material Level</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Period</td>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">TP BR Value</td>  
   </tr><%if objSelection.ListCount("DATA") = 0 then%>
   <tr><td align=left>NO ROWS RETURNED</tr><%else%><%for i = objSelection.ListLower("DATA") to objSelection.ListUpper("DATA")%>
   <tr>
      <td align=center><%=objSelection.ListValue01("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue02("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue03("DATA",i)%></td>
      <td align=right><%=objSelection.ListValue04("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue05("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue06("DATA",i)%></td>
      <td align=center><%=objSelection.ListValue07("DATA",i)%></td>
   </tr><%next%><%end if%>
</table><%end if%>