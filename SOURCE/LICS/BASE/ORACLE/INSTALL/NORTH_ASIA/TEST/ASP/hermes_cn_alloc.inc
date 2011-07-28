<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_FilName.focus();<%if strError <> "" then%>
      alert('<%=strError%>');<%else%>return;<%end if%>
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
   function doAccept() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.main.INP_FilName.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Allocation file must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      
      //document.main.action = '<%=strBase%><%=strTarget%>';
      //document.main.Mode.value = 'LOAD';
      //document.main.submit();
      
      loadFile(document.main.INP_FilName.value);
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'ACCEPT';
      document.main.submit();
   }
   
   function doDownload() {
      var strURL = '<%=strBase%>hermes_cn_alloc_download.asp';
      strURL = strURL + '?DTA_TpaComCode=' + document.main.DTA_TpaComCode.value;
      strURL = strURL + '&DTA_TpaCurrPrd=' + document.main.DTA_TpaCurrPrd.value;
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
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_file.inc"-->
<!--#include file="ics_std_scrollable.inc"-->

<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('hermes_cn_alloc_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100%  cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Allocation File (Tab Delimited):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="file" name="INP_FilName" size="128" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
                  <%if objSelection.ListCount("LIST") > 0 then%>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDownload();">&nbsp;Download&nbsp;</a></nobr></td>
                  <%end if%>
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
                     <table class="clsTableHead" id="tabHead" align=left cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;TP Group&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Material&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Percentage&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Updated At&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cellpadding="0" cellspacing="1"><%if objSelection.ListCount("LIST") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=3 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=right colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                        </tr><%next%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr>
          <td id="hidLines" colspan=2 style="display:none"></td>
        </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_TpaComCode" value="<%=objForm.Fields("DTA_TpaComCode").Value%>">
   <input type="hidden" name="DTA_TpaCurrPrd" value="<%=objSelection.ListValue01("LIST",1)%>">
   <input type="hidden" name="LIN_Count" value="">
</form>
</body>
</html>