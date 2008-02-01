<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_SrcText.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_SrcText.value != document.main.DTA_SrcText.value) {bolChange = true;}
      if (document.main.INP_SrcIdentifier.value != document.main.DTA_SrcIdentifier.value) {bolChange = true;}
      if (document.main.INP_SrcProcedure.value != document.main.DTA_SrcProcedure.value) {bolChange = true;}
      if (document.main.INP_SrcWarnType.value != document.main.DTA_SrcWarnType.value) {bolChange = true;}
      if (document.main.INP_SrcWarnTime.value != document.main.DTA_SrcWarnTime.value) {bolChange = true;}
      if (document.main.INP_SrcWarnText.value != document.main.DTA_SrcWarnText.value) {bolChange = true;}
      if (document.main.INP_SrcAlrtType.value != document.main.DTA_SrcAlrtType.value) {bolChange = true;}
      if (document.main.INP_SrcAlrtTime.value != document.main.DTA_SrcAlrtTime.value) {bolChange = true;}
      if (document.main.INP_SrcAlrtText.value != document.main.DTA_SrcAlrtText.value) {bolChange = true;}
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
      if (document.main.INP_SrcText.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Source description must be entered';
      }
      if (document.main.INP_SrcIdentifier.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Source interchange identifier must be entered';
      }
      if (document.main.INP_SrcProcedure.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Source default EDI procedure must be entered';
      }
      if (document.main.INP_SrcWarnType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Source default warning type must be entered';
      }
      if (document.main.INP_SrcWarnType.value != '0') {
         if (document.main.INP_SrcWarnTime.value == '0') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Source default warning wait seconds must be entered';
         }
      }
      if (document.main.INP_SrcWarnType.value == '0') {
         document.main.INP_SrcWarnTime.value = '0';
         document.main.INP_SrcWarnText.value == ''
      }
      if (document.main.INP_SrcWarnType.value == '1') {
         if (document.main.INP_SrcWarnText.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Source default warning email group must be entered';
         }
      }
      if (document.main.INP_SrcAlrtType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Source default alert type must be entered';
      }
      if (document.main.INP_SrcAlrtType.value != '0') {
         if (document.main.INP_SrcAlrtTime.value == '0') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Source default alert wait seconds must be entered';
         }
      }
      if (document.main.INP_SrcAlrtType.value == '0') {
         document.main.INP_SrcAlrtTime.value = '0';
         document.main.INP_SrcAlrtText.value == ''
      }
      if (document.main.INP_SrcAlrtType.value == '1') {
         if (document.main.INP_SrcAlrtText.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Source default alert email group must be entered';
         }
      }
      if (document.main.INP_SrcAlrtType.value == '2') {
         if (document.main.INP_SrcAlrtText.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Source default alert text must be entered';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_SrcText.value = document.main.INP_SrcText.value;
      document.main.DTA_SrcIdentifier.value = document.main.INP_SrcIdentifier.value;
      document.main.DTA_SrcProcedure.value = document.main.INP_SrcProcedure.value;
      document.main.DTA_SrcWarnType.value = document.main.INP_SrcWarnType.value;
      document.main.DTA_SrcWarnTime.value = document.main.INP_SrcWarnTime.value;
      document.main.DTA_SrcWarnText.value = document.main.INP_SrcWarnText.value;
      document.main.DTA_SrcAlrtType.value = document.main.INP_SrcAlrtType.value;
      document.main.DTA_SrcAlrtTime.value = document.main.INP_SrcAlrtTime.value;
      document.main.DTA_SrcAlrtText.value = document.main.INP_SrcAlrtText.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'UPDATE_ACCEPT';
      document.main.submit();
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectWarnType(strValue) {
      document.main.INP_SrcWarnType.value = strValue;
      setWarnText();
   }
   function selectAlrtType(strValue) {
      document.main.INP_SrcAlrtType.value = strValue;
      setAlrtText();
   }
   function setWarnText() {
      if (document.main.INP_SrcWarnType.value == '0') {
         document.getElementById('txtWarnText').innerHTML = '<nobr>&nbspDefault warning email group:&nbsp;</nobr>';
         document.getElementById('rowWarnTime').style.display = 'none';
         document.getElementById('rowWarnText').style.display = 'none';
      } else if (document.main.INP_SrcWarnType.value == '1') {
         document.getElementById('txtWarnText').innerHTML = '<nobr>&nbspDefault warning email group:&nbsp;</nobr>';
         document.getElementById('rowWarnTime').style.display = 'block';
         document.getElementById('rowWarnText').style.display = 'block';
      }
   }
   function setAlrtText() {
      if (document.main.INP_SrcAlrtType.value == '0') {
         document.getElementById('txtAlrtText').innerHTML = '<nobr>&nbspDefault alert email group or alert message:&nbsp;</nobr>';
         document.getElementById('rowAlrtTime').style.display = 'none';
         document.getElementById('rowAlrtText').style.display = 'none';
      } else if (document.main.INP_SrcAlrtType.value == '1') {
         document.getElementById('txtAlrtText').innerHTML = '<nobr>&nbspDefault alert email group:&nbsp;</nobr>';
         document.getElementById('rowAlrtTime').style.display = 'block';
         document.getElementById('rowAlrtText').style.display = 'block';
      } else if (document.main.INP_SrcAlrtType.value == '2') {
         document.getElementById('txtAlrtText').innerHTML = '<nobr>&nbspDefault alert message:&nbsp;</nobr>';
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_asn_src_update_help.htm');parent.setHeading('<%=strHeading%> - Update Source');parent.showContent();setWarnText();setAlrtText();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Source Code:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_SrcCode").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Source Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SrcText" size="64" maxlength="128" value="<%=objForm.Fields("DTA_SrcText").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Source EDI Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SrcIdentifier" size="15" maxlength="15" value="<%=objForm.Fields("DTA_SrcIdentifier").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Default EDI message procedure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SrcProcedure" size="64" maxlength="128" value="<%=objForm.Fields("DTA_SrcProcedure").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Default warning type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltWarnType"<%if objForm.Fields("DTA_SrcWarnType").Value = "0" or objForm.Fields("DTA_SrcWarnType").Value = "" then%> checked<%end if%> value="0" onClick="javascript:selectWarnType('0');">None&nbsp;
            <input type="radio" name="sltWarnType"<%if objForm.Fields("DTA_SrcWarnType").Value = "1" then%> checked<%end if%> value="1" onClick="javascript:selectWarnType('1');">Email&nbsp;
         </nobr></td>
      </tr>
      <tr id="rowWarnTime">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Default warning time (seconds):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SrcWarnTime" size="9" maxlength="9" value="<%=objForm.Fields("DTA_SrcWarnTime").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr id="rowWarnText">
         <td class="clsLabelBB" id="txtWarnText" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Default warning email group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SrcWarnText" size="64" maxlength="256" value="<%=replace(objForm.Fields("DTA_SrcWarnText").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Default alert type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltAlrtType"<%if objForm.Fields("DTA_SrcAlrtType").Value = "0" or objForm.Fields("DTA_SrcAlrtType").Value = "" then%> checked<%end if%> value="0" onClick="javascript:selectAlrtType('0');">None&nbsp;
            <input type="radio" name="sltAlrtType"<%if objForm.Fields("DTA_SrcAlrtType").Value = "1" then%> checked<%end if%> value="1" onClick="javascript:selectAlrtType('1');">Email&nbsp;
            <input type="radio" name="sltAlrtType"<%if objForm.Fields("DTA_SrcAlrtType").Value = "2" then%> checked<%end if%> value="2" onClick="javascript:selectAlrtType('2');">Alert&nbsp;
         </nobr></td>
      </tr>
      <tr id="rowAlrtTime">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Default alert time (seconds):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SrcAlrtTime" size="9" maxlength="9" value="<%=objForm.Fields("DTA_SrcAlrtTime").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr id="rowAlrtText">
         <td class="clsLabelBB" id="txtAlrtText" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Default alert email group or alert message:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SrcAlrtText" size="64" maxlength="256" value="<%=replace(objForm.Fields("DTA_SrcAlrtText").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
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
   <input type="hidden" name="DTA_SrcCode" value="<%=objForm.Fields("DTA_SrcCode").Value%>">
   <input type="hidden" name="DTA_SrcText" value="<%=objForm.Fields("DTA_SrcText").Value%>">
   <input type="hidden" name="DTA_SrcIdentifier" value="<%=objForm.Fields("DTA_SrcIdentifier").Value%>">
   <input type="hidden" name="DTA_SrcProcedure" value="<%=objForm.Fields("DTA_SrcProcedure").Value%>">
   <input type="hidden" name="DTA_SrcWarnType" value="<%=objForm.Fields("DTA_SrcWarnType").Value%>">
   <input type="hidden" name="DTA_SrcWarnTime" value="<%=objForm.Fields("DTA_SrcWarnTime").Value%>">
   <input type="hidden" name="DTA_SrcWarnText" value="<%=replace(objForm.Fields("DTA_SrcWarnText").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_SrcAlrtType" value="<%=objForm.Fields("DTA_SrcAlrtType").Value%>">
   <input type="hidden" name="DTA_SrcAlrtTime" value="<%=objForm.Fields("DTA_SrcAlrtTime").Value%>">
   <input type="hidden" name="DTA_SrcAlrtText" value="<%=replace(objForm.Fields("DTA_SrcAlrtText").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="INP_SrcWarnType" value="<%=objForm.Fields("DTA_SrcWarnType").Value%>">
   <input type="hidden" name="INP_SrcAlrtType" value="<%=objForm.Fields("DTA_SrcAlrtType").Value%>">
</form>
</body>
</html>