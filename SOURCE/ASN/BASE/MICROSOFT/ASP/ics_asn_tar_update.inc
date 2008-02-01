<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_TarText.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_TarText.value != document.main.DTA_TarText.value) {bolChange = true;}
      if (document.main.INP_TarWarnType.value != document.main.DTA_TarWarnType.value) {bolChange = true;}
      if (document.main.INP_TarWarnTime.value != document.main.DTA_TarWarnTime.value) {bolChange = true;}
      if (document.main.INP_TarWarnText.value != document.main.DTA_TarWarnText.value) {bolChange = true;}
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
      if (document.main.INP_TarText.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Target description must be entered';
      }
      if (document.main.INP_TarWarnType.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Target acknowledgement warning type must be entered';
      }
      if (document.main.INP_TarWarnType.value != '0') {
         if (document.main.INP_TarWarnTime.value == '0') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Target acknowledgement warning wait seconds must be entered';
         }
      }
      if (document.main.INP_TarWarnType.value == '0') {
         document.main.INP_TarWarnTime.value = '0';
         document.main.INP_TarWarnText.value == ''
      }
      if (document.main.INP_TarWarnType.value == '1') {
         if (document.main.INP_TarWarnText.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Target acknowledgement warning email group must be entered';
         }
      }
      if (document.main.INP_TarWarnType.value == '2') {
         if (document.main.INP_TarWarnText.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Target acknowledgement warning alert text must be entered';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_TarText.value = document.main.INP_TarText.value;
      document.main.DTA_TarWarnType.value = document.main.INP_TarWarnType.value;
      document.main.DTA_TarWarnTime.value = document.main.INP_TarWarnTime.value;
      document.main.DTA_TarWarnText.value = document.main.INP_TarWarnText.value;
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
      document.main.INP_TarWarnType.value = strValue;
      setWarnText();
   }
   function setWarnText() {
      if (document.main.INP_TarWarnType.value == '0') {
         document.getElementById('txtWarnText').innerHTML = '<nobr>&nbspAcknowledgement warning email group or alert message:&nbsp;</nobr>';
         document.getElementById('rowWarnTime').style.display = 'none';
         document.getElementById('rowWarnText').style.display = 'none';
      } else if (document.main.INP_TarWarnType.value == '1') {
         document.getElementById('txtWarnText').innerHTML = '<nobr>&nbspAcknowledgement warning email group:&nbsp;</nobr>';
         document.getElementById('rowWarnTime').style.display = 'block';
         document.getElementById('rowWarnText').style.display = 'block';
      } else if (document.main.INP_TarWarnType.value == '2') {
         document.getElementById('txtWarnText').innerHTML = '<nobr>&nbspAcknowledgement warning alert message:&nbsp;</nobr>';
         document.getElementById('rowWarnTime').style.display = 'block';
         document.getElementById('rowWarnText').style.display = 'block';
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_asn_tar_update_help.htm');parent.setHeading('<%=strHeading%> - Update Target');parent.showContent();setWarnText();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Target Code:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_TarCode").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Target Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_TarText" size="64" maxlength="128" value="<%=objForm.Fields("DTA_TarText").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Acknowledgement warning type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltWarnType"<%if objForm.Fields("DTA_TarWarnType").Value = "0" or objForm.Fields("DTA_TarWarnType").Value = "" then%> checked<%end if%> value="0" onClick="javascript:selectWarnType('0');">None&nbsp;
            <input type="radio" name="sltWarnType"<%if objForm.Fields("DTA_TarWarnType").Value = "1" then%> checked<%end if%> value="1" onClick="javascript:selectWarnType('1');">Email&nbsp;
            <input type="radio" name="sltWarnType"<%if objForm.Fields("DTA_TarWarnType").Value = "2" then%> checked<%end if%> value="2" onClick="javascript:selectWarnType('2');">Alert&nbsp;
         </nobr></td>
      </tr>
      <tr id="rowWarnTime">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Acknowledgement warning wait time (seconds):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_TarWarnTime" size="9" maxlength="9" value="<%=objForm.Fields("DTA_TarWarnTime").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr id="rowWarnText">
         <td class="clsLabelBB" id="txtWarnText" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Acknowledgement warning email group or alert message:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_TarWarnText" size="64" maxlength="256" value="<%=replace(objForm.Fields("DTA_TarWarnText").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
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
   <input type="hidden" name="DTA_TarCode" value="<%=objForm.Fields("DTA_TarCode").Value%>">
   <input type="hidden" name="DTA_TarText" value="<%=objForm.Fields("DTA_TarText").Value%>">
   <input type="hidden" name="DTA_TarWarnType" value="<%=objForm.Fields("DTA_TarWarnType").Value%>">
   <input type="hidden" name="DTA_TarWarnTime" value="<%=objForm.Fields("DTA_TarWarnTime").Value%>">
   <input type="hidden" name="DTA_TarWarnText" value="<%=replace(objForm.Fields("DTA_TarWarnText").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="INP_TarWarnType" value="<%=objForm.Fields("DTA_TarWarnType").Value%>">
</form>
</body>
</html>