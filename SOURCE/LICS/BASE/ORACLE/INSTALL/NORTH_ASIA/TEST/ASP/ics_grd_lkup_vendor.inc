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
   function doSearch() {
      if (!processForm()) {return;}
      document.main.QRY_CODE.value = document.main.SLT_CODE.value;
      document.main.QRY_DESC.value = document.main.SLT_DESC.value;
      document.main.QRY_ZH_DESC.value = document.main.SLT_ZH_DESC.value;
      document.main.QRY_ACC_GRP.value = document.main.SLT_ACC_GRP.value;
      document.main.INP_CODE_TYPE.value = document.main.INP_CODE_TYPE.value;
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
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function processLog(strSequence) {
      var strParameters;
      strParameters = 'Child=ics_log_detail.asp';
      strParameters = strParameters + '&QRY_Sequence=' + strSequence;
      openWindow(strParameters);
   }
   function setSelect(objInput) {
      objInput.select();
   }
   function selectStatus(strValue) {
      document.main.INP_CODE_TYPE.value = strValue;
   }
// -->
</script>
<!--#include file="ics_std_child.inc"-->
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_timestamp.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_log_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;供应商编码（包含） Vendor Code (contains):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_CODE" size="64" maxlength="14" value="<%=objForm.Fields("QRY_CODE").Value%>" onFocus="setSelect(this);"">
            <input type="radio" name="SLT_CODE_TYPE"<%if objForm.Fields("INP_CODE_TYPE").Value = "1" then%> checked<%end if%> value="1" onClick="javascript:selectStatus('1');">GRD&nbsp;
            <input type="radio" name="SLT_CODE_TYPE"<%if objForm.Fields("INP_CODE_TYPE").Value = "0" then%> checked<%end if%> value="0" onClick="javascript:selectStatus('0');">Legacy MFG号&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;英文名称（包含） Description EN (contains):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_DESC" size="64" maxlength="256" value="<%=objForm.Fields("QRY_DESC").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;中文名称（包含） Description ZH (contains):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_ZH_DESC" size="64" maxlength="256" value="<%=objForm.Fields("QRY_ZH_DESC").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;账户组 Account Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_ACC_GRP" size="64" maxlength="256" value="<%=objForm.Fields("QRY_ACC_GRP").Value%>" onFocus="setSelect(this);">
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
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=4 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;GRD Code GRD号&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Legacy Code MFG 号&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Vendor Name ZH 供应商名（中）&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Street ZH 地址&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Vendor Name EN 供应商名（英）&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=left colspan=1 nowrap><nobr>&nbsp;Account Group Code 账户组&nbsp;</nobr></td>
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
                        <tr><td class="clsLabelFB" align=center colspan=13 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%if objForm.Fields("Mode").Value <> "PREVIOUS" then%><%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
                        <tr>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
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
   <input type="hidden" name="QRY_CODE" value="<%=objForm.Fields("QRY_CODE").Value%>">
   <input type="hidden" name="QRY_DESC" value="<%=objForm.Fields("QRY_DESC").Value%>">
   <input type="hidden" name="QRY_ZH_DESC" value="<%=objForm.Fields("QRY_ZH_DESC").Value%>">
   <input type="hidden" name="QRY_ACC_GRP" value="<%=objForm.Fields("QRY_ACC_GRP").Value%>">
   <input type="hidden" name="INP_CODE_TYPE" value="<%=objForm.Fields("INP_CODE_TYPE").Value%>">
</form>
</body>
</html>