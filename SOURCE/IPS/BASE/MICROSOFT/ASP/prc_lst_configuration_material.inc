<html>
<script language="javascript">
<!--
   function showError() {<%if strReturn <> "*OK" then%>
      alert('<%=strReturn%>');<%else%>
      return;<%end if%>
   }
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
      if (objElement.className == 'clsButtonN') {
         objElement.className = 'clsButtonNX';
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
      if (objElement.className == 'clsButtonNX') {
         objElement.className = 'clsButtonN';
      }
      if (objElement.className == 'clsSelectX') {
         objElement.className = 'clsSelect';
      }
   }
   function checkChange() {
      bolReturn = confirm('Please confirm the cancel\r\npress OK continue (any changes will be lost)\r\npress Cancel to return to the function');
      return bolReturn;
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
      var strDetail = '';
      strDetail = checkMaterials();
      if (strDetail != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strDetail;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'MATERIAL_ACCEPT';
      document.main.submit();
   }
   function doSelect(objSelected) {
      if (cobjSelected) {
         cobjSelected.className = 'clsList';
      }
      cobjSelected = objSelected;
      cobjSelected.className = 'clsListX';
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
   ////////////////////////////
   // Report material script //
   ////////////////////////////
   var cobjSelected = null;
   function loadMaterials() {
      var objSltMaterial = document.getElementById('sltMaterial');
      objSltMaterial.options.length = 0;
      objSltMaterial.selectedIndex = -1;<%if objSelection.ListCount("MATERIAL") <> 0 then%><%for i = objSelection.ListLower("MATERIAL") to objSelection.ListUpper("MATERIAL")%>
      objSltMaterial.options[<%=i%>] = new Option('<%=replace(objSelection.ListValue02("MATERIAL",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue01("MATERIAL",i)%>');<%next%><%end if%>
   }
   function refreshMaterials() {
      doActivityStart(document.body);
      window.setTimeout('refreshMaterialList(\'<%=objForm.Fields("DTA_ReportId").Value%>\');',10);
   }
   function refreshMaterialList(strReportId) {
      doGetRequest('<%=strBase%>prc_lst_matl_lookup.asp?QRY_ReportId='+strReportId,function(strResponse) {reloadMaterials(strResponse);},false);
   }
   function reloadMaterials() {
      doActivityStart(document.body);
      window.setTimeout('reloadMaterialList(\'<%=objForm.Fields("DTA_ReportId").Value%>\');',10);
   }
   function reloadMaterialList(strReportId) {
      doGetRequest('<%=strBase%>prc_lst_matl_reload.asp?QRY_ReportId='+strReportId,function(strResponse) {reloadMaterials(strResponse);},false);
   }
   function reloadMaterials(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var aryRows = strResponse.substring(3,strResponse.length).split('\n');
         var aryColumns;
         var objSltMaterial = document.getElementById('sltMaterial');
         objSltMaterial.options.length = 0;
         objSltMaterial.selectedIndex = -1;
         for (var i=0;i<aryRows.length;i++) {
            aryColumns = aryRows[i].split('\t');
            objSltMaterial.options[i] = new Option(aryColumns[1],aryColumns[0]);
         }
      }
      doActivityStop();
   }
   function deleteMaterials() {
      var objSltMaterial = document.getElementById('sltMaterial');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objSltMaterial.options.length;i++) {
         if (objSltMaterial.options[i].selected == false) {
            objWork[intIndex] = objSltMaterial[i];
            intIndex++;
         }
      }
      objSltMaterial.options.length = 0;
      objSltMaterial.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSltMaterial.options[i] = objWork[i];
      }
   }
   function addMaterials() {
      var objSltMaterial = document.getElementById('sltMaterial');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objSltMaterial.options.length;i++) {
         if (objSltMaterial.options[i].selected == false) {
            objWork[intIndex] = objSltMaterial[i];
            intIndex++;
         }
      }
      objSltMaterial.options.length = 0;
      objSltMaterial.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSltMaterial.options[i] = objWork[i];
      }
   }
   function checkMaterials() {
      var strReturn = '';
      var objHidden = null;
      var objSltMaterial = document.getElementById('sltMaterial');
      if (objSltMaterial.options.length == 0) {
         strReturn = 'The report must have at least one material';
      } else {
         for (var i=0;i<objSltMaterial.options.length;i++) {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepMatCod'+(i+1));
            objHidden.setAttribute('value',objSltMaterial.options[i].value);
            document.forms['main'].appendChild(objHidden);
         }
         document.getElementById('DET_RepMatCount').value = objSltMaterial.options.length;
      }
      return strReturn;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('prc_lst_configuration_material_help.htm');parent.setHeading('<%=strHeading%> - Report Materials - Manual Update');parent.showContent();loadMaterials();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Report Name:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=replace(objSelection.ListValue02("REPORT",objSelection.ListLower("REPORT")), """", "&#34;", 1, -1, 1)%></nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=4 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:reloadMaterials();">&nbsp;Reload (apply rules)&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:refreshMaterials();">&nbsp;Refresh (restart function)&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:deleteMaterials();">&nbsp;Delete&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addMaterials();">&nbsp;Add&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td align=center colspan=2 nowrap><nobr><select class="clsInputBN" id="sltMaterial" name="sltMaterial" style="width:500px" multiple size=20></select></nobr></td>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_ReportId" value="<%=objForm.Fields("DTA_ReportId").Value%>">
   <input type="hidden" name="DET_RepMatCount" value="">
</form>
</body>
</html>