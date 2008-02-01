<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_SrcCode.focus();<%if strReturn <> "*OK" then%>
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
   function checkChange() {
      var bolChange = false;
      var bolReturn;
      if (document.main.INP_SrcCode.value != document.main.DTA_SrcCode.value) {bolChange = true;}
      if (document.main.INP_TarCode.value != document.main.DTA_TarCode.value) {bolChange = true;}
      if (document.main.INP_RteProcedure.value != document.main.DTA_RteProcedure.value) {bolChange = true;}
      if (document.main.INP_RteWarnType.value != document.main.DTA_RteWarnType.value) {bolChange = true;}
      if (document.main.INP_RteWarnTime.value != document.main.DTA_RteWarnTime.value) {bolChange = true;}
      if (document.main.INP_RteWarnText.value != document.main.DTA_RteWarnText.value) {bolChange = true;}
      if (document.main.INP_RteAlrtType.value != document.main.DTA_RteAlrtType.value) {bolChange = true;}
      if (document.main.INP_RteAlrtTime.value != document.main.DTA_RteAlrtTime.value) {bolChange = true;}
      if (document.main.INP_RteAlrtText.value != document.main.DTA_RteAlrtText.value) {bolChange = true;}
      if (bolChange == true) {
         bolReturn = confirm('Changes have been made to this information\r\npress OK continue (changes will be lost)\r\npress Cancel to return to the function');
         return bolReturn;
      }
      return true;
   }
   function doCancel() {
      if (checkChange() == false) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SELECT';
      document.main.submit();
   }
   function doAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_SrcCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Source must be selected';
      }
      if (document.main.INP_TarCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Target must be selected';
      }
      if (document.main.INP_RteProcedure.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Route EDI procedure must be entered';
      }
      if (document.main.INP_RteWarnType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Route warning type must be entered';
      }
      if (document.main.INP_RteWarnType.value != '0') {
         if (document.main.INP_RteWarnTime.value == '0') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Route warning wait seconds must be entered';
         }
      }
      if (document.main.INP_RteWarnType.value == '0') {
         document.main.INP_RteWarnTime.value = '0';
         document.main.INP_RteWarnText.value == ''
      }
      if (document.main.INP_RteWarnType.value == '1') {
         if (document.main.INP_RteWarnText.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Route warning email group must be entered';
         }
      }
      if (document.main.INP_RteAlrtType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Route alert type must be entered';
      }
      if (document.main.INP_RteAlrtType.value != '0') {
         if (document.main.INP_RteAlrtTime.value == '0') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Route alert wait seconds must be entered';
         }
      }
      if (document.main.INP_RteAlrtType.value == '0') {
         document.main.INP_RteAlrtTime.value = '0';
         document.main.INP_RteAlrtText.value == ''
      }
      if (document.main.INP_RteAlrtType.value == '1') {
         if (document.main.INP_RteAlrtText.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Route alert email group must be entered';
         }
      }
      if (document.main.INP_RteAlrtType.value == '2') {
         if (document.main.INP_RteAlrtText.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Route alert text must be entered';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_SrcCode.value = document.main.INP_SrcCode.value;
      document.main.DTA_TarCode.value = document.main.INP_TarCode.value;
      document.main.DTA_RteProcedure.value = document.main.INP_RteProcedure.value;
      document.main.DTA_RteWarnType.value = document.main.INP_RteWarnType.value;
      document.main.DTA_RteWarnTime.value = document.main.INP_RteWarnTime.value;
      document.main.DTA_RteWarnText.value = document.main.INP_RteWarnText.value;
      document.main.DTA_RteAlrtType.value = document.main.INP_RteAlrtType.value;
      document.main.DTA_RteAlrtTime.value = document.main.INP_RteAlrtTime.value;
      document.main.DTA_RteAlrtText.value = document.main.INP_RteAlrtText.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'INSERT_ACCEPT';
      document.main.submit();
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectSource(objSelect) {
      document.main.INP_SrcCode.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectTarget(objSelect) {
      document.main.INP_TarCode.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectWarnType(strValue) {
      document.main.INP_RteWarnType.value = strValue;
      setWarnText();
   }
   function selectAlrtType(strValue) {
      document.main.INP_RteAlrtType.value = strValue;
      setAlrtText();
   }
   function setWarnText() {
      if (document.main.INP_RteWarnType.value == '0') {
         document.getElementById('txtWarnText').innerHTML = '<nobr>&nbspWarning email group:&nbsp;</nobr>';
         document.getElementById('rowWarnTime').style.display = 'none';
         document.getElementById('rowWarnText').style.display = 'none';
      } else if (document.main.INP_RteWarnType.value == '1') {
         document.getElementById('txtWarnText').innerHTML = '<nobr>&nbspWarning email group:&nbsp;</nobr>';
         document.getElementById('rowWarnTime').style.display = 'block';
         document.getElementById('rowWarnText').style.display = 'block';
      }
   }
   function setAlrtText() {
      if (document.main.INP_RteAlrtType.value == '0') {
         document.getElementById('txtAlrtText').innerHTML = '<nobr>&nbspAlert email group or message:&nbsp;</nobr>';
         document.getElementById('rowAlrtTime').style.display = 'none';
         document.getElementById('rowAlrtText').style.display = 'none';
      } else if (document.main.INP_RteAlrtType.value == '1') {
         document.getElementById('txtAlrtText').innerHTML = '<nobr>&nbspAlert email group:&nbsp;</nobr>';
         document.getElementById('rowAlrtTime').style.display = 'block';
         document.getElementById('rowAlrtText').style.display = 'block';
      } else if (document.main.INP_RteAlrtType.value == '2') {
         document.getElementById('txtAlrtText').innerHTML = '<nobr>&nbspAlert message:&nbsp;</nobr>';
         document.getElementById('rowAlrtTime').style.display = 'block';
         document.getElementById('rowAlrtText').style.display = 'block';
      }
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_asn_rte_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert Route');parent.showContent();setWarnText();setAlrtText();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Source:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltSource" onChange="selectSource(this);">
               <option value=""<%if objForm.Fields("DTA_SrcCode").Value = "" then%> selected<%end if%>>** select source **<%for i = 0 to objSelection.ListCount("SOURCE") - 1%>
               <option value="<%=objSelection.ListValue01("SOURCE",i)%>"<%if objForm.Fields("DTA_SrcCode").Value = objSelection.ListValue01("SOURCE",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("SOURCE",i)%>) <%=objSelection.ListValue02("SOURCE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Target:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltTarget" onChange="selectTarget(this);">
               <option value=""<%if objForm.Fields("DTA_TarCode").Value = "" then%> selected<%end if%>>** select receiver **<%for i = 0 to objSelection.ListCount("TARGET") - 1%>
               <option value="<%=objSelection.ListValue01("TARGET",i)%>"<%if objForm.Fields("DTA_TarCode").Value = objSelection.ListValue01("TARGET",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("TARGET",i)%>) <%=objSelection.ListValue02("TARGET",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;EDI message procedure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_RteProcedure" size="64" maxlength="128" value="<%=objForm.Fields("DTA_RteProcedure").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Warning type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltWarnType"<%if objForm.Fields("DTA_RteWarnType").Value = "0" or objForm.Fields("DTA_RteWarnType").Value = "" then%> checked<%end if%> value="0" onClick="javascript:selectWarnType('0');">None&nbsp;
            <input type="radio" name="sltWarnType"<%if objForm.Fields("DTA_RteWarnType").Value = "1" then%> checked<%end if%> value="1" onClick="javascript:selectWarnType('1');">Email&nbsp;
         </nobr></td>
      </tr>
      <tr id="rowWarnTime">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Warning wait time (seconds):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_RteWarnTime" size="9" maxlength="9" value="<%=objForm.Fields("DTA_RteWarnTime").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr id="rowWarnText">
         <td class="clsLabelBB" id="txtWarnText" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Warning email group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_RteWarnText" size="64" maxlength="256" value="<%=replace(objForm.Fields("DTA_RteWarnText").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Alert type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltAlrtType"<%if objForm.Fields("DTA_RteAlrtType").Value = "0" or objForm.Fields("DTA_RteAlrtType").Value = "" then%> checked<%end if%> value="0" onClick="javascript:selectAlrtType('0');">None&nbsp;
            <input type="radio" name="sltAlrtType"<%if objForm.Fields("DTA_RteAlrtType").Value = "1" then%> checked<%end if%> value="1" onClick="javascript:selectAlrtType('1');">Email&nbsp;
            <input type="radio" name="sltAlrtType"<%if objForm.Fields("DTA_RteAlrtType").Value = "2" then%> checked<%end if%> value="2" onClick="javascript:selectAlrtType('2');">Alert&nbsp;
         </nobr></td>
      </tr>
      <tr id="rowAlrtTime">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Alert wait time (seconds):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_RteAlrtTime" size="9" maxlength="9" value="<%=objForm.Fields("DTA_RteAlrtTime").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr id="rowAlrtText">
         <td class="clsLabelBB" id="txtAlrtText" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Alert email group or message:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_RteAlrtText" size="64" maxlength="256" value="<%=replace(objForm.Fields("DTA_RteAlrtText").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_SrcCode" value="<%=objForm.Fields("DTA_ScrCode").Value%>">
   <input type="hidden" name="DTA_TarCode" value="<%=objForm.Fields("DTA_TarCode").Value%>">
   <input type="hidden" name="DTA_RteProcedure" value="<%=objForm.Fields("DTA_RteProcedure").Value%>">
   <input type="hidden" name="DTA_RteWarnType" value="<%=objForm.Fields("DTA_RteWarnType").Value%>">
   <input type="hidden" name="DTA_RteWarnTime" value="<%=objForm.Fields("DTA_RteWarnTime").Value%>">
   <input type="hidden" name="DTA_RteWarnText" value="<%=replace(objForm.Fields("DTA_RteWarnText").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_RteAlrtType" value="<%=objForm.Fields("DTA_RteAlrtType").Value%>">
   <input type="hidden" name="DTA_RteAlrtTime" value="<%=objForm.Fields("DTA_RteAlrtTime").Value%>">
   <input type="hidden" name="DTA_RteAlrtText" value="<%=replace(objForm.Fields("DTA_RteAlrtText").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="INP_SrcCode" value="<%=objForm.Fields("DTA_ScrCode").Value%>">
   <input type="hidden" name="INP_TarCode" value="<%=objForm.Fields("DTA_TarCode").Value%>">
   <input type="hidden" name="INP_RteWarnType" value="<%=objForm.Fields("DTA_RteWarnType").Value%>">
   <input type="hidden" name="INP_RteAlrtType" value="<%=objForm.Fields("DTA_RteAlrtType").Value%>">
</form>
</body>
</html>