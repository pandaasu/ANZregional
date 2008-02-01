<html>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
   <title>MFANZ - Interface Control System - Interface Header Messages</title>
</head>
<body class="clsBody02" scroll="no">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% width=100% cellpadding="0" cellspacing="0">
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=1 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("MESSAGE") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=8 nowrap><nobr>&nbsp;NO MESSAGES FOUND&nbsp</nobr></td></tr><%else%><%for i = objSelection.ListLower("MESSAGE") to objSelection.ListUpper("MESSAGE")%>
                        <tr>
                           <td class="clsNormalFix" align=left colspan=1><%=objSelection.ListValue01("MESSAGE",i)%></td>
                        </tr><%next%><%end if%>
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