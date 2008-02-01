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
   }
   function doSearch() {
      if (!processForm()) {return;}
      document.main.QRY_Source.value = document.main.SLT_Source.value;
      document.main.QRY_Test.value = document.main.SLT_Test.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SEARCH';
      document.main.submit();
   }
   function doPrevious() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'PREVIOUS';
      document.main.submit();
   }
   function doNext() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'NEXT';
      document.main.submit();
   }
   function doInsert() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'INSERT_LOAD';
      document.main.submit();
   }
   function doUpdate(strSource) {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'UPDATE_LOAD';
      document.main.XRF_Source.value = strSource;
      document.main.submit();
   }
   function doDelete(strSource) {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'DELETE_LOAD';
      document.main.XRF_Source.value = strSource;
      document.main.submit();
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectTest(strValue) {
      document.main.SLT_Test.value = strValue;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_xrf_maintenance02_select_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr><%=objForm.Fields("XRF_Description").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Cross Reference Source (Legacy):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_Source" size="20" maxlength="64" value="<%=objForm.Fields("QRY_Source").Value%>" onFocus="setSelect(this);">
            <input type="radio" name="sltTest"<%if objForm.Fields("QRY_Test").Value = "EQ" then%> checked<%end if%> value="EQ" onClick="javascript:selectTest('EQ');">EQ&nbsp;
            <input type="radio" name="sltTest"<%if objForm.Fields("QRY_Test").Value = "LE" then%> checked<%end if%> value="LE" onClick="javascript:selectTest('LE');">LE&nbsp;
            <input type="radio" name="sltTest"<%if objForm.Fields("QRY_Test").Value = "GE" then%> checked<%end if%> value="GE" onClick="javascript:selectTest('GE');">GE&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelUL" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSearch();">Search</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=5 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doInsert();">&nbsp;Insert&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td><%if bolStrList = true then%>
                  <td align=center colspan=1 nowrap><nobr><font class="clsButtonD"><&nbsp;Prev&nbsp</font></nobr></td><%else%>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPrevious();"><&nbsp;Prev&nbsp</a></nobr></td><%end if%>
                  <td align=center colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td><%if bolEndList = true then%>
                  <td align=center colspan=1 nowrap><nobr><font class="clsButtonD">&nbspNext&nbsp></font></nobr></td><%else%>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doNext();">&nbspNext&nbsp></a></nobr></td><%end if%>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=4 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Action&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Source (Legacy)&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Target (GRD)&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=3 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("LIST") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=3 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%if objForm.Fields("Mode").Value <> "PREVIOUS" then%><%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:doUpdate('<%=objSelection.ListValue01("LIST",i)%>','<%=objSelection.ListValue02("LIST",i)%>');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doDelete('<%=objSelection.ListValue01("LIST",i)%>','<%=objSelection.ListValue02("LIST",i)%>');">Delete</a></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                        </tr><%next%><%else%><%for i = objSelection.ListUpper("LIST") to objSelection.ListLower("LIST") step -1%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:doUpdate('<%=objSelection.ListValue01("LIST",i)%>','<%=objSelection.ListValue02("LIST",i)%>');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doDelete('<%=objSelection.ListValue01("LIST",i)%>','<%=objSelection.ListValue02("LIST",i)%>');">Delete</a></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                        </tr><%next%><%end if%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="STR_Source" value="<%if objForm.Fields("Mode").Value <> "PREVIOUS" then%><%=objSelection.ListValue01("LIST",objSelection.ListLower("LIST"))%><%else%><%=objSelection.ListValue01("LIST",objSelection.ListUpper("LIST"))%><%end if%>">
   <input type="hidden" name="END_Source" value="<%if objForm.Fields("Mode").Value <> "PREVIOUS" then%><%=objSelection.ListValue01("LIST",objSelection.ListUpper("LIST"))%><%else%><%=objSelection.ListValue01("LIST",objSelection.ListLower("LIST"))%><%end if%>">
   <input type="hidden" name="QRY_Source" value="<%=objForm.Fields("QRY_Source").Value%>">
   <input type="hidden" name="QRY_Test" value="<%=objForm.Fields("QRY_Test").Value%>">
   <input type="hidden" name="SLT_Test" value="<%=objForm.Fields("QRY_Test").Value%>">
   <input type="hidden" name="XRF_Code" value="<%=objForm.Fields("XRF_Code").Value%>">
   <input type="hidden" name="XRF_Description" value="<%=objForm.Fields("XRF_Description").Value%>">
   <input type="hidden" name="XRF_Source" value="">
</form>
</body>
</html>