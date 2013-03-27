<%if strReturn <> "*OK" then%>
<html>
<head>
   <meta http-equiv="content-type" content="text/html">
</head>
<body onLoad="parent.showError('<%=strReturn%>');">
</html><%else%>
<table border=1 cellpadding="0" cellspacing="0">
   <tr><%if clng(objQuery.MetaCount("DATA")) = 0 then%>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">View Data</td><%else%><%for i = clng(objQuery.MetaLower("DATA")) to clng(objQuery.MetaUpper("DATA"))%>
      <td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;"><%=objQuery.MetaName("DATA",i)%></td><%next%><%end if%>
   </tr><%if clng(objQuery.ListCount("DATA")) = 0 then%>
   <tr><td align=left>NO ROWS RETURNED</tr><%else%><%for i = clng(objQuery.ListLower("DATA")) to clng(objQuery.ListUpper("DATA"))%>
   <tr><%for j = clng(objQuery.MetaLower("DATA")) to clng(objQuery.MetaUpper("DATA"))%>
      <td align=left><%=objQuery.ListValue("DATA",i,j)%></td><%next%>
   </tr><%next%><%end if%>
</table><%end if%>