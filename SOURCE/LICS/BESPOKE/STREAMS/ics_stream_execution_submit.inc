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
   function doCancel() {
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SELECT';
      document.main.submit();
   }
   function doSubmit() {
      if (!processForm()) {return;}
      cstrMessage = '';
      checkSubmit();
      if (cstrMessage != '') {
         alert(cstrMessage);
         return;
      }
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SUBMIT_ACCEPT';
      document.main.submit();
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
<script language="javascript">
<!--
   //////////////////////////////
   // Submit definition script //
   //////////////////////////////
   var cstrMessage = null;
   var cobjParam = new Array();
   function clsParam(strCode,strText,strValue) {
      this.strcod = strCode;
      this.strtxt = strText;
      this.strval = strValue;
      this.strsav = strValue;
   }
   function loadScreen() {<%for i = objSelection.ListLower("PARAMS") to objSelection.ListUpper("PARAMS")%>
      cobjParam[<%=i%>] = new clsParam('<%=objSelection.ListValue01("PARAMS",i)%>','<%=objSelection.ListValue02("PARAMS",i)%>','<%=objSelection.ListValue03("PARAMS",i)%>');<%next%>
      var strText = '<table align=center border=0 cellpadding=0 cellspacing=2 cols=2>';
      strText = strText + '<tr>';
      strText = strText + '<td class="clsLabelBB" align=left colspan=1 nowrap><nobr>&nbsp;Text&nbsp;</nobr></td>';
      strText = strText + '<td class="clsLabelBB" align=left colspan=1 nowrap><nobr>&nbsp;Value&nbsp;</nobr></td>';
      strText = strText + '</tr>';
      for (var i=0;i<cobjParam.length;i++) {
         strText = strText + '<tr>';
         strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr>' + cobjParam[i].strtxt + '</nobr></td>';
         if (cobjParam[i].strsav == '*SUPPLIED') {
            strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="INP_ParValu' + i + '" size="64" maxlength="64" value="" onFocus="setSelect(this);"></nobr></td>';
         } else {
            strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr>' + cobjParam[i].strval + '</nobr></td>';
         }
         strText = strText + '</tr>';
      }
      strText = strText + '</table>';
      document.getElementById('tabParam').innerHTML = strText;
   }
   function checkSubmit() {
      var objHidden = null;
      var intPart = 0;
      var aryStream = null;
      var bolFound = false;
      var strXML = editSubmit();
      if (cstrMessage == '') {
         intPart = 0;
         aryStream = strXML.match(RegExp('.{1,2000}','g'));
         for (var i=0;i<aryStream.length;i++) {
            intPart++;
            objHidden = document.createElement('input');
            objHidden.type = 'hidden';
            objHidden.name = 'StreamPart'+intPart;
            objHidden.value = aryStream[i];
            document.forms['main'].appendChild(objHidden);
         }
         objHidden = document.createElement('input');
         objHidden.type = 'hidden';
         objHidden.name = 'StreamCount';
         objHidden.value = intPart;
         document.forms['main'].appendChild(objHidden);
      }
   }
   function editSubmit() {
      var strCode = document.getElementById('DTA_StreamCode').value;
      var strText = document.getElementById('INP_StrText').value;
      var strProcedure = document.getElementById('INP_StrProc').value;
      if (strText == '') {
         if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
         cstrMessage = cstrMessage + 'Stream execution text must be entered';
      }
      for (var i=0;i<cobjParam.length;i++) {
         if (cobjParam[i].strsav == '*SUPPLIED') {
            cobjParam[i].strval = document.getElementById('INP_ParValu' + i).value;
         }
         if (cobjParam[i].strval == '') {
            if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
            cstrMessage = cstrMessage + 'Parameter value must be entered';
         }
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<ICS_STREAM';
      strXML = strXML+' CODE="'+fixAttribute(strCode)+'"';
      strXML = strXML+' TEXT="'+fixAttribute(strText)+'"';
      strXML = strXML+' PROCEDURE="'+fixAttribute(strProc)+'"';
      strXML = strXML+'>';
      if (cobjParam.length > 0) {
         for (var i=0;i<cobjParam.length;i++) {
            strXML = strXML+'<PARAM';
            strXML = strXML+' CODE="'+fixAttribute(cobjParam[i].strcod)+'"';
            strXML = strXML+' VALUE="'+fixAttribute(cobjParam[i].strval)+'"';
            strXML = strXML+'/>'
        }
      }
      strXML = strXML+'</ICS_STREAM>';
      return strXML;
   }
   function fixAttribute(strText) {
      var strReturn = strText;
      strReturn = strReturn.replace(/</g,'&lt;');
      strReturn = strReturn.replace(/>/g,'&gt;');
      strReturn = strReturn.replace(/"/g,'&#34;');
      return strReturn;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_stream_execution_submit_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadScreen();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>(<%=objForm.Fields("DTA_StreamCode").Value%>) <%=objForm.Fields("DTA_StreamText").Value%></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Execution Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_StrText" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Execution (*SUPPLIED) procedure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_StrProc" size="64" maxlength="512" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Parameters&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" id="tabParam" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSubmit();">&nbsp;Submit&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_StreamCode" value="<%=objForm.Fields("DTA_StreamCode").Value%>">
</form>
</body>
</html>