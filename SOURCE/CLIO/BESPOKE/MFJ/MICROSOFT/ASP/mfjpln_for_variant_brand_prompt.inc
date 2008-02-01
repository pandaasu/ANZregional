<html>
<script language="javascript">
<!--
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
   function setActions() {
      var strText = '<nobr>&nbsp;<%=strHeading%> -';
      strText = strText + '&nbsp;<a class="clsButton" href="javascript:doAction(\'Cancel\');">Cancel</a>&nbsp;';
      strText = strText + '|&nbsp;<a class="clsButton" href="javascript:doAction(\'Generate\');">Generate</a>&nbsp;</nobr>';
      parent.setActions(strText);
   }
   function doAction(strAction) {
      if (strAction == 'Cancel') {
         cancelForm();
      }
      if (strAction == 'Generate') {
         processForm();
      }
   }
   function cancelForm() {
      parent.setActions('<nobr>&nbsp;<%=strHeading%> - Processing request - please wait&nbsp;</nobr>');
      document.location.href = '<%=strBase%>mfjpln_home.htm';
   }
   function processForm() {
      if (document.main.AsofStart.value > document.main.AsofEnd.value) {
         alert('As of range from value must not be greater than to value');
         return;
      }
      if (document.main.FcstStart.value > document.main.FcstEnd.value) {
         alert('Forecast range from value must not be greater than to value');
         return;
      }
      var intYear;
      var intNumber;
      var intMaximum = <%if objForm.Fields("ForType").Value = "PRD" then%>13<%else%>12<%end if%>;
      var intCount = 0;
      var strStart = document.main.AsofStart.value;
      var strEnd = document.main.AsofEnd.value;
      while (strStart <= strEnd) {
         intCount++;
         intYear = strStart.substring(0,4);
         intNumber = strStart.substring(4,6);
         intNumber++;
         if (intNumber > intMaximum) {
            intYear++;
            intNumber = 1;
         }
         if (intNumber < 10) {
            strStart = intYear + '0' + intNumber;
         } else {
            strStart = intYear + intNumber;
         }
      }
      if (intCount > intMaximum) {
         alert('As of range must not exceed maximum - ' + intMaximum);
         return;
      }
      intCount = 0;
      strStart = document.main.FcstStart.value;
      strEnd = document.main.FcstEnd.value;
      while (strStart <= strEnd) {
         intCount++;
         intYear = strStart.substring(0,4);
         intNumber = strStart.substring(4,6);
         intNumber++;
         if (intNumber > intMaximum) {
            intYear++;
            intNumber = 1;
         }
         if (intNumber < 10) {
            strStart = intYear + '0' + intNumber;
         } else {
            strStart = intYear + intNumber;
         }
      }
      if (intCount > intMaximum) {
         alert('Forecast range must not exceed maximum - ' + intMaximum);
         return;
      }
      if (!selectBrandFlag()) {
         return;
      }
      if (!selectBrandSubFlag()) {
         return;
      }
      if (!selectPrdctPackSize()) {
         return;
      }
      parent.setActions('<nobr>&nbsp;<%=strHeading%> - Processing request - please wait&nbsp;</nobr>');
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'REPORT';
      document.main.submit();
   }
   function setValues() {<%if objForm.Fields("PrintOrientation").Value = "" then%>
      document.main.PrintOrientation.value = '2';<%end if%><%if objForm.Fields("PrintPagesWide").Value = "" then%>
      document.main.PrintPagesWide.value = '1';<%end if%>
      var objOption;
      var intYear;
      var intNumber;
      var intMaximum = <%if objForm.Fields("ForType").Value = "PRD" then%>13<%else%>12<%end if%>;
      var strStart = '<%=objSelection.ListValue01("TERM",0)%>';
      var strEnd = '<%=objSelection.ListValue02("TERM",0)%>';<%if objForm.Fields("AsofStart").Value = "" then%>
      var strSelect01 = '<%=objSelection.ListValue01("TERM",0)%>';
      document.main.AsofStart.value = '<%=objSelection.ListValue01("TERM",0)%>';<%else%>
      strSelect01 = '<%=objForm.Fields("AsofStart").Value%>';<%end if%><%if objForm.Fields("AsofEnd").Value = "" then%>
      var strSelect02 = '<%=objSelection.ListValue01("TERM",0)%>';
      document.main.AsofEnd.value = '<%=objSelection.ListValue01("TERM",0)%>';<%else%>
      strSelect02 = '<%=objForm.Fields("AsofEnd").Value%>';<%end if%>
      var objSelect01 = eval('document.all("sltAsofStart")');
      var objSelect02 = eval('document.all("sltAsofEnd")');
      while (strStart <= strEnd) {
         objOption = document.createElement("OPTION");
         objOption.value = strStart;
         objOption.text = strStart;
         if (strStart == strSelect01) {
            objOption.selected = true;
         }
         objSelect01.add(objOption);
         objOption = document.createElement("OPTION");
         objOption.value = strStart;
         objOption.text = strStart;
         if (strStart == strSelect02) {
            objOption.selected = true;
         }
         objSelect02.add(objOption);
         intYear = strStart.substring(0,4);
         intNumber = strStart.substring(4,6);
         intNumber++;
         if (intNumber > intMaximum) {
            intYear++;
            intNumber = 1;
         }
         if (intNumber < 10) {
            strStart = intYear + '0' + intNumber;
         } else {
            strStart = intYear + intNumber;
         }
      }
      strStart = '<%=objSelection.ListValue03("TERM",0)%>';
      strEnd = '<%=objSelection.ListValue04("TERM",0)%>';<%if objForm.Fields("FcstStart").Value = "" then%>
      strSelect01 = '<%=objSelection.ListValue03("TERM",0)%>';
      document.main.FcstStart.value = '<%=objSelection.ListValue03("TERM",0)%>';<%else%>
      strSelect01 = '<%=objForm.Fields("FcstStart").Value%>';<%end if%><%if objForm.Fields("FcstEnd").Value = "" then%>
      strSelect02 = '<%=objSelection.ListValue03("TERM",0)%>';
      document.main.FcstEnd.value = '<%=objSelection.ListValue03("TERM",0)%>';<%else%>
      strSelect02 = '<%=objForm.Fields("FcstEnd").Value%>';<%end if%>
      objSelect01 = eval('document.all("sltFcstStart")');
      objSelect02 = eval('document.all("sltFcstEnd")');
      while (strStart <= strEnd) {
         objOption = document.createElement("OPTION");
         objOption.value = strStart;
         objOption.text = strStart;
         if (strStart == strSelect01) {
            objOption.selected = true;
         }
         objSelect01.add(objOption);
         objOption = document.createElement("OPTION");
         objOption.value = strStart;
         objOption.text = strStart;
         if (strStart == strSelect02) {
            objOption.selected = true;
         }
         objSelect02.add(objOption);
         intYear = strStart.substring(0,4);
         intNumber = strStart.substring(4,6);
         intNumber++;
         if (intNumber > intMaximum) {
            intYear++;
            intNumber = 1;
         }
         if (intNumber < 10) {
            strStart = intYear + '0' + intNumber;
         } else {
            strStart = intYear + intNumber;
         }
      }
   }
   function selectAsofStart(objSelect) {
      document.main.AsofStart.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectAsofEnd(objSelect) {
      document.main.AsofEnd.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectFcstStart(objSelect) {
      document.main.FcstStart.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectFcstEnd(objSelect) {
      document.main.FcstEnd.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectPrintOrientation(strValue) {
      document.main.PrintOrientation.value = strValue;
   }
   function selectPrintPagesWide(objSelect) {
      document.main.PrintPagesWide.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectBrandFlag() {
      var bolAll = false;
      var strText = '';
      var lngWorkCount = 0;
      var objSelect = eval('document.all("sltBrandFlag")');
      for (i=0;i<objSelect.options.length;i++) {
         if (objSelect.options(i).selected) {
            if (objSelect.options(i).value == '') {
               bolAll = true;
            }
            lngWorkCount = lngWorkCount + 1;
            strText = strText + '<input type="hidden" name="BrandFlagValue' + lngWorkCount + '" value="' + objSelect.options(i).value + '">';
         }
      }
      if (lngWorkCount == 0) {
         alert('At least one brand must be selected');
         document.main.sltBrandFlag.focus();
         return false;
      }
      if (bolAll && lngWorkCount > 1) {
         alert('Brand ALL must be only selection when selected');
         document.main.sltBrandFlag.focus();
         return false;
      }
      document.all.BrandFlagData.innerHTML = strText;
      document.all.BrandFlagCount.value = lngWorkCount;
      return true;
   }
   function selectBrandSubFlag() {
      var bolAll = false;
      var strText = '';
      var lngWorkCount = 0;
      var objSelect = eval('document.all("sltBrandSubFlag")');
      for (i=0;i<objSelect.options.length;i++) {
         if (objSelect.options(i).selected) {
            if (objSelect.options(i).value == '') {
               bolAll = true;
            }
            lngWorkCount = lngWorkCount + 1;
            strText = strText + '<input type="hidden" name="BrandSubFlagValue' + lngWorkCount + '" value="' + objSelect.options(i).value + '">';
         }
      }
      if (lngWorkCount == 0) {
         alert('At least one sub brand must be selected');
         document.main.sltBrandSubFlag.focus();
         return false;
      }
      if (bolAll && lngWorkCount > 1) {
         alert('Sub brand ALL must be only selection when selected');
         document.main.sltBrandSubFlag.focus();
         return false;
      }
      document.all.BrandSubFlagData.innerHTML = strText;
      document.all.BrandSubFlagCount.value = lngWorkCount;
      return true;
   }
   function selectPrdctPackSize() {
      var bolAll = false;
      var strText = '';
      var lngWorkCount = 0;
      var objSelect = eval('document.all("sltPrdctPackSize")');
      for (i=0;i<objSelect.options.length;i++) {
         if (objSelect.options(i).selected) {
            if (objSelect.options(i).value == '') {
               bolAll = true;
            }
            lngWorkCount = lngWorkCount + 1;
            strText = strText + '<input type="hidden" name="PrdctPackSizeValue' + lngWorkCount + '" value="' + objSelect.options(i).value + '">';
         }
      }
      if (lngWorkCount == 0) {
         alert('At least one packsize must be selected');
         document.main.sltPrdctPackSize.focus();
         return false;
      }
      if (bolAll && lngWorkCount > 1) {
         alert('Packsize ALL must be only selection when selected');
         document.main.sltPrdctPackSize.focus();
         return false;
      }
      document.all.PrdctPackSizeData.innerHTML = strText;
      document.all.PrdctPackSizeCount.value = lngWorkCount;
      return true;
   }
   function selectPlanningType(objSelect) {
      document.main.PlanningType.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectPlanningStatus(strValue) {
      document.main.PlanningStatus.value = strValue;
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html;charset=Shift-JIS">
   <link rel="stylesheet" type="text/css" href="mfjpln_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');setActions();setValues();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Business Segment:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("BUS_SGMNT",i)%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Forecast:&nbsp;</nobr></td><%if objForm.Fields("ForType").Value = "PRD" then%>
         <td class="clsLabelBB" align=left colspan=1 nowrap><nobr>Period&nbsp;</nobr></td><%else%>
         <td class="clsLabelBB" align=left colspan=1 nowrap><nobr>Month&nbsp;</nobr></td><%end if%>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;As Of Range:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltAsofStart" onChange="selectAsofStart(this);"></select>
            <font class="clsLabelBB" valign=center>&nbsp;-&nbsp;</font>
            <select class="clsInputBN" name="sltAsofEnd" onChange="selectAsofEnd(this);"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Forecast Range:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltFcstStart" onChange="selectFcstStart(this);"></select>
            <font class="clsLabelBB" valign=center>&nbsp;-&nbsp;</font>
            <select class="clsInputBN" name="sltFcstEnd" onChange="selectFcstEnd(this);"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelUL" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Print (Page Orientation):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltPrintOrientation"<%if objForm.Fields("PrintOrientation").Value = "1" then%> checked<%end if%> value="1" onClick="javascript:selectPrintOrientation('1');">&nbsp;Portrait&nbsp;
            <input type="radio" name="sltPrintOrientation"<%if objForm.Fields("PrintOrientation").Value = "2" or objForm.Fields("PrintOrientation").Value = "" then%> checked<%end if%> value="2" onClick="javascript:selectPrintOrientation('2');">&nbsp;Landscape&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Print (Fit Pages Wide):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltPrintPagesWide" onChange="selectPrintPagesWide(this);">
               <option value="1"<%if objForm.Fields("PrintPagesWide").Value = "1" then%> selected<%end if%>>1
               <option value="2"<%if objForm.Fields("PrintPagesWide").Value = "2" then%> selected<%end if%>>2
               <option value="3"<%if objForm.Fields("PrintPagesWide").Value = "3" then%> selected<%end if%>>3
               <option value="4"<%if objForm.Fields("PrintPagesWide").Value = "4" then%> selected<%end if%>>4
               <option value="5"<%if objForm.Fields("PrintPagesWide").Value = "5" then%> selected<%end if%>>5
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelUL" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Brands:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltBrandFlag" multiple size=5>
               <option value=""<%if objForm.Fields("BrandFlagCount").Value = "" or objForm.Fields("BrandFlagCount").Value = "0" or objForm.Fields("BrandFlagValue1").Value = "" then%> selected<%end if%>>ALL<%for i = 0 to objSelection.ListCount("BRAND_FLAG") - 1%>
               <option value="<%=objSelection.ListValue01("BRAND_FLAG",i)%>"<%bolSelect = false%><%if objForm.Fields("BrandFlagCount").Value <> "" then%><%for j = 1 to clng(objForm.Fields("BrandFlagCount").Value)%><%if objForm.Fields("BrandFlagValue" & cstr(j)).Value = objSelection.ListValue01("BRAND_FLAG",i) then%><%bolSelect = true%><%exit for%><%end if%><%next%><%end if%><%if bolSelect = true then%> selected<%end if%>><%=objSelection.ListValue02("BRAND_FLAG",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Sub Brands:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltBrandSubFlag" multiple size=5>
               <option value=""<%if objForm.Fields("BrandSubFlagCount").Value = "" or objForm.Fields("BrandSubFlagCount").Value = "0" or objForm.Fields("BrandSubFlagValue1").Value = "" then%> selected<%end if%>>ALL<%for i = 0 to objSelection.ListCount("BRAND_SUB_FLAG") - 1%>
               <option value="<%=objSelection.ListValue01("BRAND_SUB_FLAG",i)%>"<%bolSelect = false%><%if objForm.Fields("BrandSubFlagCount").Value <> "" then%><%for j = 1 to clng(objForm.Fields("BrandSubFlagCount").Value)%><%if objForm.Fields("BrandSubFlagValue" & cstr(j)).Value = objSelection.ListValue01("BRAND_SUB_FLAG",i) then%><%bolSelect = true%><%exit for%><%end if%><%next%><%end if%><%if bolSelect = true then%> selected<%end if%>><%=objSelection.ListValue02("BRAND_SUB_FLAG",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Packsizes:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltPrdctPackSize" multiple size=5>
               <option value=""<%if objForm.Fields("PrdctPackSizeCount").Value = "" or objForm.Fields("PrdctPackSizeCount").Value = "0" or objForm.Fields("PrdctPackSizeValue1").Value = "" then%> selected<%end if%>>ALL<%for i = 0 to objSelection.ListCount("PRDCT_PACK_SIZE") - 1%>
               <option value="<%=objSelection.ListValue01("PRDCT_PACK_SIZE",i)%>"<%bolSelect = false%><%if objForm.Fields("PrdctPackSizeCount").Value <> "" then%><%for j = 1 to clng(objForm.Fields("PrdctPackSizeCount").Value)%><%if objForm.Fields("PrdctPackSizeValue" & cstr(j)).Value = objSelection.ListValue01("PRDCT_PACK_SIZE",i) then%><%bolSelect = true%><%exit for%><%end if%><%next%><%end if%><%if bolSelect = true then%> selected<%end if%>><%=objSelection.ListValue02("PRDCT_PACK_SIZE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Product Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltPlanningType" onChange="selectPlanningType(this);">
               <option value=""<%if objForm.Fields("PlanningType").Value = "" then%> selected<%end if%>>ALL<%for i = 0 to objSelection.ListCount("PLANNING_TYPE") - 1%>
               <option value="<%=objSelection.ListValue01("PLANNING_TYPE",i)%>"<%if objForm.Fields("PlanningType").Value = objSelection.ListValue01("PLANNING_TYPE",i) then%> selected<%end if%>><%=objSelection.ListValue01("PLANNING_TYPE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Product Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltStatus"<%if objForm.Fields("PlanningStatus").Value = "" then%> checked<%end if%> value="" onClick="javascript:selectPlanningStatus('');">&nbsp;ALL&nbsp;
            <input type="radio" name="sltStatus"<%if objForm.Fields("PlanningStatus").Value = "0" then%> checked<%end if%> value="0" onClick="javascript:selectPlanningStatus('0');">&nbsp;Active&nbsp;
            <input type="radio" name="sltStatus"<%if objForm.Fields("PlanningStatus").Value = "1" then%> checked<%end if%> value="1" onClick="javascript:selectPlanningStatus('1');">&nbsp;Inactive&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td id="BrandFlagData" colspan=2 style="display:none">&nbsp;<%if objForm.Fields("BrandFlagCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("BrandFlagCount").Value)%>
            <input type="hidden" name="BrandFlagValue<%=i%>" value="<%=objForm.Fields("BrandFlagValue" & cstr(i)).Value%>"><%next%><%end if%>
         </td>
      </tr>
      <tr>
         <td id="BrandSubFlagData" colspan=2 style="display:none">&nbsp;<%if objForm.Fields("BrandSubFlagCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("BrandSubFlagCount").Value)%>
            <input type="hidden" name="BrandSubFlagValue<%=i%>" value="<%=objForm.Fields("BrandSubFlagValue" & cstr(i)).Value%>"><%next%><%end if%>
         </td>
      </tr>
      <tr>
         <td id="PrdctPackSizeData" colspan=2 style="display:none">&nbsp;<%if objForm.Fields("PrdctPackSizeCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("PrdctPackSizeCount").Value)%>
            <input type="hidden" name="PrdctPackSizeValue<%=i%>" value="<%=objForm.Fields("PrdctPackSizeValue" & cstr(i)).Value%>"><%next%><%end if%>
         </td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="ForType" value="<%=objForm.Fields("ForType").Value%>">
   <input type="hidden" name="AsofStart" value="<%=objForm.Fields("AsofStart").Value%>">
   <input type="hidden" name="AsofEnd" value="<%=objForm.Fields("AsofEnd").Value%>">
   <input type="hidden" name="FcstStart" value="<%=objForm.Fields("FcstStart").Value%>">
   <input type="hidden" name="FcstEnd" value="<%=objForm.Fields("FcstEnd").Value%>">
   <input type="hidden" name="PrintOrientation" value="<%=objForm.Fields("PrintOrientation").Value%>">
   <input type="hidden" name="PrintPagesWide" value="<%=objForm.Fields("PrintPagesWide").Value%>">
   <input type="hidden" name="BusSgmnt" value="<%=objForm.Fields("BusSgmnt").Value%>">
   <input type="hidden" name="PlanningType" value="<%=objForm.Fields("PlanningType").Value%>">
   <input type="hidden" name="PlanningStatus" value="<%=objForm.Fields("PlanningStatus").Value%>">
   <input type="hidden" name="BrandFlagCount" value="<%=objForm.Fields("BrandFlagCount").Value%>">
   <input type="hidden" name="BrandSubFlagCount" value="<%=objForm.Fields("BrandSubFlagCount").Value%>">
   <input type="hidden" name="PrdctPackSizeCount" value="<%=objForm.Fields("PrdctPackSizeCount").Value%>">
</form>
</body>
</html>