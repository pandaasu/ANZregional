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
   function checkAccept() {
      bolReturn = confirm('Please confirm the accept\r\npress OK continue (any changes will be applied)\r\npress Cancel to return to the function');
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
      if (checkAccept() == false) {return;}
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
      var objSltExclusion = document.getElementById('sltExclusion');
      objSltExclusion.options.length = 0;
      objSltExclusion.selectedIndex = -1;<%if objSelection.ListCount("EXCLUSION") <> 0 then%><%for i = objSelection.ListLower("EXCLUSION") to objSelection.ListUpper("EXCLUSION")%>
      objSltExclusion.options[<%=i%>] = new Option('<%=replace(objSelection.ListValue02("EXCLUSION",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue01("EXCLUSION",i)%>');<%next%><%end if%>
   }
   function excludeMaterials() {
      var objSltMaterial = document.getElementById('sltMaterial');
      var objSltExclusion = document.getElementById('sltExclusion');
      var objWorkM = new Array();
      var objWorkE = new Array();
      for (var i=0;i<objSltExclusion.options.length;i++) {
         objWorkE[i] = objSltExclusion[i];
      }
      for (var i=0;i<objSltMaterial.options.length;i++) {
         if (objSltMaterial.options[i].selected == true) {
            objWorkE[objWorkE.length] = objSltMaterial[i];
         } else {
            objWorkM[objWorkM.length] = objSltMaterial[i];
         }
      }
      objWorkM.sort(sortWorkList);
      objSltMaterial.options.length = 0;
      objSltMaterial.selectedIndex = -1;
      for (var i=0;i<objWorkM.length;i++) {
         objSltMaterial.options[i] = objWorkM[i];
      }
      objWorkE.sort(sortWorkList);
      objSltExclusion.options.length = 0;
      objSltExclusion.selectedIndex = -1;
      for (var i=0;i<objWorkE.length;i++) {
         objSltExclusion.options[i] = objWorkE[i];
      }
   }
   function includeMaterials() {
      var objSltMaterial = document.getElementById('sltMaterial');
      var objSltExclusion = document.getElementById('sltExclusion');
      var objWorkM = new Array();
      var objWorkE = new Array();
      for (var i=0;i<objSltMaterial.options.length;i++) {
         objWorkM[i] = objSltMaterial[i];
      }
      for (var i=0;i<objSltExclusion.options.length;i++) {
         if (objSltExclusion.options[i].selected == true) {
            objWorkM[objWorkM.length] = objSltExclusion[i];
         } else {
            objWorkE[objWorkE.length] = objSltExclusion[i];
         }
      }
      objWorkM.sort(sortWorkList);
      objSltMaterial.options.length = 0;
      objSltMaterial.selectedIndex = -1;
      for (var i=0;i<objWorkM.length;i++) {
         objSltMaterial.options[i] = objWorkM[i];
      }
      objWorkE.sort(sortWorkList);
      objSltExclusion.options.length = 0;
      objSltExclusion.selectedIndex = -1;
      for (var i=0;i<objWorkE.length;i++) {
         objSltExclusion.options[i] = objWorkE[i];
      }
   }
   function sortWorkList(obj01, obj02) {
      if (obj01.value < obj02.value) {
         return -1;
      } else if (obj01.value > obj02.value) {
         return 1;
      }
      return 0;
   }
   function checkMaterials() {
      var strReturn = '';
      var objHidden = null;
      var objSltMaterial = document.getElementById('sltMaterial');
      var objSltExclusion = document.getElementById('sltExclusion');
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
         for (var i=0;i<objSltExclusion.options.length;i++) {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_RepExlCod'+(i+1));
            objHidden.setAttribute('value',objSltExclusion.options[i].value);
            document.forms['main'].appendChild(objHidden);
         }
         document.getElementById('DET_RepExlCount').value = objSltExclusion.options.length;
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
         <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
            <table align=center border=0 cellpadding=0 cellspacing=2 cols=3>
               <tr>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Material Inclusions&nbsp;</nobr></td>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;Material Exclusions&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="sltMaterial" name="sltMaterial" style="width:400px" multiple size=25></select>
                  </nobr></td>
                  <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                     <table class="clsTable01" width=100% align=center cols=2 cellpadding="0" cellspacing="0">
                        <tr><td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_loff.gif" align=absmiddle onClick="includeMaterials();"></nobr></td>
                            <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_roff.gif" align=absmiddle onClick="excludeMaterials();"></nobr></td></tr>
                     </table>
                  </nobr></td>
                  <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                     <select class="clsInputBN" id="sltExclusion" name="sltExclusion" style="width:400px" multiple size=25></select>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
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
   <input type="hidden" name="DET_RepExlCount" value="">
</form>
</body>
</html>