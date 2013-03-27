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
      document.main.QRY_Header.value = document.main.SLT_Header.value;
      document.main.QRY_Test.value = document.main.SLT_Test.value;
      document.main.QRY_Type.value = document.main.SLT_Type.value;
      document.main.QRY_Group.value = document.main.SLT_Group.value;
      document.main.QRY_Interface.value = document.main.SLT_Interface.value;
      document.main.QRY_Execution.value = document.main.SLT_Execution.value;
      document.main.QRY_StrTime.value = document.main.SLT_StrTime.value;
      document.main.QRY_EndTime.value = document.main.SLT_EndTime.value;
      document.main.QRY_Status.value = document.main.SLT_Status.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SELECT';
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
   function doUpdate(strHeader) {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'UPDATE_LOAD';
      document.main.DTA_HeaHeader.value = strHeader;
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
   function selectInterface(objSelect) {
      document.main.SLT_Interface.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectType(objSelect) {
      document.main.SLT_Type.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectGroup(objSelect) {
      document.main.SLT_Group.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectStatus(objSelect) {
      document.main.SLT_Status.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_child.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_timestamp.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_int_process_select_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltInterface" onChange="selectInterface(this);">
               <option value=""<%if objForm.Fields().Item("QRY_Interface") = "" then%> selected<%end if%>>All<%for i = 0 to clng(objSelection.ListCount("INTERFACE")) - 1%>
               <option value="<%=objSelection.ListValue01("INTERFACE",i)%>"<%if objForm.Fields().Item("QRY_Interface") = objSelection.ListValue01("INTERFACE",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("INTERFACE",i)%>) <%=objSelection.ListValue02("INTERFACE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltType" onChange="selectType(this);">
               <option value=""<%if objForm.Fields().Item("QRY_Type") = "" then%> selected<%end if%>>All<%for i = 0 to clng(objSelection.ListCount("TYPE")) - 1%>
               <option value="<%=objSelection.ListValue01("TYPE",i)%>"<%if objForm.Fields().Item("QRY_Type") = objSelection.ListValue01("TYPE",i) then%> selected<%end if%>><%=objSelection.ListValue01("TYPE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltGroup" onChange="selectGroup(this);">
               <option value=""<%if objForm.Fields().Item("QRY_Group") = "" then%> selected<%end if%>>All<%for i = 0 to clng(objSelection.ListCount("GROUP")) - 1%>
               <option value="<%=objSelection.ListValue01("GROUP",i)%>"<%if objForm.Fields().Item("QRY_Group") = objSelection.ListValue01("GROUP",i) then%> selected<%end if%>><%=objSelection.ListValue01("GROUP",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_Header" size="15" maxlength="15" value="<%=objForm.Fields().Item("QRY_Header")%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
            <input type="radio" name="sltTest"<%if objForm.Fields().Item("QRY_Test") = "EQ" then%> checked<%end if%> value="EQ" onClick="javascript:selectTest('EQ');">EQ&nbsp;
            <input type="radio" name="sltTest"<%if objForm.Fields().Item("QRY_Test") = "LE" then%> checked<%end if%> value="LE" onClick="javascript:selectTest('LE');">LE&nbsp;
            <input type="radio" name="sltTest"<%if objForm.Fields().Item("QRY_Test") = "GE" then%> checked<%end if%> value="GE" onClick="javascript:selectTest('GE');">GE&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Start Time (YYYYMMDDHHMISS):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_StrTime" size="14" maxlength="14" value="<%=objForm.Fields().Item("QRY_StrTime")%>" onFocus="setSelect(this);" onBlur="validateTimestamp(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface End Time (YYYYMMDDHHMISS):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_EndTime" size="14" maxlength="14" value="<%=objForm.Fields().Item("QRY_EndTime")%>" onFocus="setSelect(this);" onBlur="validateTimestamp(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltStatus" onChange="selectStatus(this);">
               <option value=""<%if objForm.Fields().Item("QRY_Status") = "" then%> selected<%end if%>>All
               <option value="7"<%if objForm.Fields().Item("QRY_Status") = "7" then%> selected<%end if%>>Process completed
               <option value="8"<%if objForm.Fields().Item("QRY_Status") = "8" then%> selected<%end if%>>Process completed (errors)
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_Execution" size="15" maxlength="15" value="<%=objForm.Fields().Item("QRY_Execution")%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr><%if bolStrList = true then%>
                  <td align=left colspan=1 nowrap><nobr><font class="clsButtonD"><&nbsp;Prev&nbsp</font></nobr></td><%else%>
                  <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPrevious();"><&nbsp;Prev&nbsp</a></nobr></td><%end if%>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td><%if bolEndList = true then%>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbspNext&nbsp></font></nobr></td><%else%>
                  <td align=right colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doNext();">&nbspNext&nbsp></a></nobr></td><%end if%>
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
                     <table class="clsTableHead" id="tabHead" align=left cols=11 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Interface&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Trace&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Identifier&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Group&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Job&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;User&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Start Time&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;End Time&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Status&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=10 cellpadding="0" cellspacing="1"><%if clng(objSelection.ListCount("LIST")) = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=8 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%for i = clng(objSelection.ListLower("LIST")) to clng(objSelection.ListUpper("LIST"))%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:doUpdate('<%=objSelection.ListValue01("LIST",i)%>');"><%=objSelection.ListValue01("LIST",i)%></a></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue08("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue09("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue10("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="<%=aryIntClass(objSelection.ListValue07("LIST",i))%>" align=left colspan=1 nowrap><nobr><%=aryIntStatus(objSelection.ListValue07("LIST",i))%></nobr></td>
                        </tr><%next%><%else%><%for i = clng(objSelection.ListUpper("LIST")) to clng(objSelection.ListLower("LIST")) step -1%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:doUpdate('<%=objSelection.ListValue01("LIST",i)%>');"><%=objSelection.ListValue01("LIST",i)%></a></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue08("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue09("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue10("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="<%=aryIntClass(objSelection.ListValue07("LIST",i))%>" align=left colspan=1 nowrap><nobr><%=aryIntStatus(objSelection.ListValue07("LIST",i))%></nobr></td>
                        </tr><%next%><%end if%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="STR_Header" value="<%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%=objSelection.ListValue01("LIST",objSelection.ListLower("LIST"))%><%else%><%=objSelection.ListValue01("LIST",objSelection.ListUpper("LIST"))%><%end if%>">
   <input type="hidden" name="END_Header" value="<%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%=objSelection.ListValue01("LIST",objSelection.ListUpper("LIST"))%><%else%><%=objSelection.ListValue01("LIST",objSelection.ListLower("LIST"))%><%end if%>">
   <input type="hidden" name="STR_Trace" value="<%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%=objSelection.ListValue02("LIST",objSelection.ListLower("LIST"))%><%else%><%=objSelection.ListValue02("LIST",objSelection.ListUpper("LIST"))%><%end if%>">
   <input type="hidden" name="END_Trace" value="<%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%=objSelection.ListValue02("LIST",objSelection.ListUpper("LIST"))%><%else%><%=objSelection.ListValue02("LIST",objSelection.ListLower("LIST"))%><%end if%>">
   <input type="hidden" name="QRY_Header" value="<%=objForm.Fields().Item("QRY_Header")%>">
   <input type="hidden" name="QRY_Test" value="<%=objForm.Fields().Item("QRY_Test")%>">
   <input type="hidden" name="QRY_Interface" value="<%=objForm.Fields().Item("QRY_Interface")%>">
   <input type="hidden" name="QRY_Type" value="<%=objForm.Fields().Item("QRY_Type")%>">
   <input type="hidden" name="QRY_Group" value="<%=objForm.Fields().Item("QRY_Group")%>">
   <input type="hidden" name="QRY_StrTime" value="<%=objForm.Fields().Item("QRY_StrTime")%>">
   <input type="hidden" name="QRY_EndTime" value="<%=objForm.Fields().Item("QRY_EndTime")%>">
   <input type="hidden" name="QRY_Status" value="<%=objForm.Fields().Item("QRY_Status")%>">
   <input type="hidden" name="QRY_Execution" value="<%=objForm.Fields().Item("QRY_Execution")%>">
   <input type="hidden" name="SLT_Interface" value="<%=objForm.Fields().Item("QRY_Interface")%>">
   <input type="hidden" name="SLT_Type" value="<%=objForm.Fields().Item("QRY_Type")%>">
   <input type="hidden" name="SLT_Group" value="<%=objForm.Fields().Item("QRY_Group")%>">
   <input type="hidden" name="SLT_Test" value="<%=objForm.Fields().Item("QRY_Test")%>">
   <input type="hidden" name="SLT_Status" value="<%=objForm.Fields().Item("QRY_Status")%>">
   <input type="hidden" name="DTA_HeaHeader" value="">
</form>
</body>
</html>