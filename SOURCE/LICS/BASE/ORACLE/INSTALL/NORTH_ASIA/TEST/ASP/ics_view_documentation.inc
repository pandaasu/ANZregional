<html>
<script language="javascript">
<!--
   function showError() {<%if strReturn <> "*OK" then%>
      alert('<%=strReturn%>');<%else%>return;<%end if%>
   }
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
   }<%if objForm.Fields("RUL_Diagram").Value <> "" then%>
   function doBack() {
      document.location.href = '<%=strBase%><%=objForm.Fields("RUL_Diagram").Value%>';
   }<%end if%>
   function doSource() {
      if (!processForm()) {return;}
      if (document.main.SRC_Name.value == '') {
         alert("View must be selected to show source");
         return;
      }
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'VIEW';
      document.main.submit();
   }
   function doData() {
      if (!processForm()) {return;}
      if (document.main.SRC_Name.value == '') {
         alert("View must be selected to show data");
         return;
      }
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'DATA';
      document.main.submit();
   }
   function doExcel() {
      if (!processForm()) {return;}
      if (document.main.SRC_Name.value == '') {
         alert("View must be selected to show Excel");
         return;
      }
      var strURL = '<%=strBase%>ics_view_download.asp';
      strURL = strURL + '?SRC_Owner=' + document.main.SRC_Owner.value;
      strURL = strURL + '&SRC_Name=' + document.main.SRC_Name.value;
      strURL = strURL + '&SRC_Rows=' + document.main.SRC_Rows.value;
      strURL = strURL + '&SRC_Where=' + document.main.SRC_Where.value;
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=no,status=no,titlebar=no,scrollbars=no';
      strFeatures = strFeatures + ',width=800';
      strFeatures = strFeatures + ',height=15';
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,"_blank",'"' + strFeatures + '"');
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectView(objSelect) {
      document.main.SRC_Name.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectRows(objSelect) {
      document.main.SRC_Rows.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="no" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_view_documentation_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();<%if objForm.Fields("Mode").Value = "DATA" then%>setScrollable('Head','Body','horizontal');<%end if%>showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=<%if objForm.Fields("RUL_Diagram").Value <> "" then%>5<%else%>4<%end if%> cellpadding="0" cellspacing="0">
               <tr><%if objForm.Fields("RUL_Diagram").Value <> "" then%>
                  <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doBack();">&nbsp;Back&nbsp;</a></nobr></td><%end if%>
                  <td align=left colspan=1 nowrap><nobr>
                     <select class="clsInputBN" name="sltView" onChange="selectView(this);">
                        <option value=""<%if objForm.Fields("SRC_Name").Value = "" then%> selected<%end if%>>** select a view **<%for i = 0 to objSelection.ListCount("LIST") - 1%>
                        <option value="<%=objSelection.ListValue01("LIST",i)%>"<%if objForm.Fields("SRC_Name").Value = objSelection.ListValue01("LIST",i) then%> selected<%end if%>><%=objSelection.ListValue01("LIST",i)%><%next%>
                     </select></nobr></td>
                  <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSource();">&nbsp;Show Source&nbsp;</a></nobr></td>
                  <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doData();">&nbsp;Show Data&nbsp;</a></nobr></td>
                  <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doExcel();">&nbsp;Show Excel&nbsp;</a></nobr></td>
               </tr>
               <tr><td align=left colspan=5 nowrap><nobr>
                  <table class="clsTable01" align=left cols=2 cellpadding="0" cellspacing="0">
                     <tr>
                        <td align=left colspan=1 nowrap><nobr>
                           <select class="clsInputBN" name="sltRows" onChange="selectRows(this);">
                              <option value="S"<%if objForm.Fields("SRC_Rows").Value = "" or objForm.Fields("SRC_Rows").Value = "S" then%> selected<%end if%>>Sample (first 100 rows)
                              <option value="A"<%if objForm.Fields("SRC_Rows").Value = "A" then%> selected<%end if%>>All rows
                           </select>
                        </nobr></td>
                        <td align=left colspan=1 width=100% nowrap><nobr>
                           <textarea class="clsInputNN" type="text" name="SRC_Where" rows=2 cols=100 style="width: 100%" onFocus="setSelect(this);"><%=replace(objForm.Fields("SRC_Where").Value, """", "&#34;", 1, -1, 1)%></textArea>
                        </nobr></td>
                     </tr>
                  </table>
               </nobr></td></tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr><%if objForm.Fields("Mode").Value = "VIEW" then%>
            <div class="clsScrollFrame">
            <table class="clsTableBody" align=left cols=1 cellpadding="0" cellspacing="0">
               <tr><td class="clsLabelFN" colspan=1><pre><%if objSelection.ListCount("SOURCE") = 0 then%>
&nbsp;<%else%><%for i = objSelection.ListLower("SOURCE") to objSelection.ListUpper("SOURCE")%>
<%=objSelection.ListValue01("SOURCE",i)%><%next%><%end if%>
               </pre></td></tr>
            </table>
            </div><%else%>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" cols=<%if objQuery.MetaCount("DATA") = 0 then%>2<%else%><%=objQuery.MetaCount("DATA") + 1%><%end if%> align=left cellpadding="0" cellspacing="1">
                        <tr><%if objQuery.MetaCount("DATA") = 0 then%>
                           <td class="clsLabelHB" align=left nowrap>&nbsp;View Data&nbsp;</td><%else%><%for i = objQuery.MetaLower("DATA") to objQuery.MetaUpper("DATA")%>
                           <td class="clsLabelHB" align=left nowrap>&nbsp;<%=objQuery.MetaName("DATA",i)%>&nbsp;</td><%next%><%end if%>
                           <td class="clsLabelHB" align=center nowrap><nobr>&nbsp;</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" cols=<%if objQuery.MetaCount("DATA") = 0 then%>1<%else%><%=objQuery.MetaCount("DATA")%><%end if%> align=left cellpadding="0" cellspacing="1"><%if objQuery.ListCount("DATA") = 0 then%>
                        <tr><td class="clsLabelFB" align=left nowrap>&nbsp;NO ROWS RETURNED&nbsp;</tr><%else%><%for i = objQuery.ListLower("DATA") to objQuery.ListUpper("DATA")%>
                        <tr><%for j = objQuery.MetaLower("DATA") to objQuery.MetaUpper("DATA")%><%if objQuery.ListValue("DATA",i,j) = "" then%>
                           <td class="clsLabelFN" align=left nowrap>&nbsp;</td><%else%>
                           <td class="clsLabelFN" align=left nowrap><%=objQuery.ListValue("DATA",i,j)%></td><%end if%><%next%>
                        </tr><%next%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table><%end if%>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="RUL_Diagram" value="<%=objForm.Fields("RUL_Diagram").Value%>">
   <input type="hidden" name="SRC_Owner" value="<%=objForm.Fields("SRC_Owner").Value%>">
   <input type="hidden" name="SRC_Name" value="<%=objForm.Fields("SRC_Name").Value%>">
   <input type="hidden" name="SRC_Rows" value="<%=objForm.Fields("SRC_Rows").Value%>">
</form>
</body>
</html>