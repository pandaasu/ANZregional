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
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
   }
   function doSearch() {
      if (!processForm()) {return;}
      var strMessage = '';
      var reInterface = /\s|\'|\"/;
      var reSearch = /\'|\"/;
      if (document.main.INP_Interface.value == '' && document.main.INP_FileName.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Either interface must be selected or file name must be entered';
      }
      if (document.main.INP_Interface.value != '' && document.main.INP_FileName.value != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Only interface or file name can be entered';
      }
      if (document.main.INP_FileName.value != '') {
         if (document.main.INP_FileName.value.search(reInterface) != -1) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'File name must not contain blanks and/or single or double quotes';
         }
      }
      if (document.main.INP_SearchString.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Search string must be entered';
      }
      if (document.main.INP_SearchString.value != '') {
         if (document.main.INP_SearchString.value.search(reSearch) != -1) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Search string must not contain single or double quotes';
         }
      }
      if (document.main.INP_SearchStrTime.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Search time range start must be specified';
      }
      if (document.main.INP_SearchEndTime.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Search time range end must be specified';
      }
      if (document.main.INP_SearchStrTime.value != '' && document.main.INP_SearchEndTime.value != '') {
         if (document.main.INP_SearchStrTime.value >= document.main.INP_SearchEndTime.value) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Search time range start must be less than end';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_Interface.value = document.main.INP_Interface.value;
      document.main.DTA_FileName.value = document.main.INP_FileName.value;
      document.main.DTA_SearchString.value = document.main.INP_SearchString.value;
      document.main.DTA_SearchStrTime.value = document.main.INP_SearchStrTime.value;
      document.main.DTA_SearchEndTime.value = document.main.INP_SearchEndTime.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SEARCH';
      document.main.submit();
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectInterface(objSelect) {
      document.main.INP_Interface.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_timestamp.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_fil_search_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltInterface" onChange="selectInterface(this);">
               <option value=""<%if objForm.Fields("DTA_Interface").Value = "" then%> selected<%end if%>>** select interface **<%for i = 0 to objSelection.ListCount("INTERFACE") - 1%>
               <option value="<%=objSelection.ListValue01("INTERFACE",i)%>"<%if objForm.Fields("DTA_Interface").Value = objSelection.ListValue01("INTERFACE",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("INTERFACE",i)%>) - <%=objSelection.ListValue02("INTERFACE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=right colspan=1 nowrap><nobr>&nbsp</nobr></td>
         <td class="clsLabelBB" align=left colspan=1 nowrap><nobr>&nbsp;OR&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;File Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_FileName" size="64" maxlength="64" value="<%=objForm.Fields("DTA_FileName").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center colspan=2>
            <p>The search will be performed on interface data files with a matching file name. The file name can be specified in one of two ways:</p>
            <p>1. Select an interface from the Interface selection and the system will created a file name wildcard using the interface identifier. For example, selecting interface
               (ATLLAD01) - Atlas to LADS - Control Recipes will create the file name wildcard ATLLAD01* and result in all interface data files starting with ATLLAD01 being searched
               for the following search string</p>
            <p>2. Enter a required file name wildcard. For example, entering the file name wildcard FILDTA* will result in all interface data files starting with FILDTA being searched
               for the following search string</p>
            <p>Notes</p>
            <p>1. Not all interface data file names start with the interface identifier. The majority of *INBOUND interfaces </p>
         </td>
      </tr>
      <tr>
         <td class="clsLabelUL" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Search String:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SearchString" size="64" maxlength="128" value="<%=objForm.Fields("DTA_SearchString").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Search Time Range:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_SearchStrTime" size="12" maxlength="12" value="<%=objForm.Fields("DTA_SearchStrTime").Value%>" onFocus="setSelect(this);" onBlur="validateTimestamp(this);">
            &nbsp;to&nbsp;
            <input class="clsInputNN" type="text" name="INP_SearchEndTime" size="12" maxlength="12" value="<%=objForm.Fields("DTA_SearchEndTime").Value%>" onFocus="setSelect(this);" onBlur="validateTimestamp(this);">
            &nbsp;(YYYYMMDDHHMI)
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSearch();">&nbsp;Search&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr><%if strMessage <> "" then%>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=left colspan=2 nowrap><nobr><pre><%=strMessage%></pre></td>
      </tr><%end if%>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_Interface" value="<%=objForm.Fields("DTA_Interface").Value%>">
   <input type="hidden" name="DTA_FileName" value="<%=objForm.Fields("DTA_FileName").Value%>">
   <input type="hidden" name="DTA_SearchString" value="<%=objForm.Fields("DTA_SearchString").Value%>">
   <input type="hidden" name="DTA_SearchStrTime" value="<%=objForm.Fields("DTA_SearchStrTime").Value%>">
   <input type="hidden" name="DTA_SearchEndTime" value="<%=objForm.Fields("DTA_SearchEndTime").Value%>">
   <input type="hidden" name="INP_Interface" value="<%=objForm.Fields("DTA_Interface").Value%>">
</form>
</body>
</html>