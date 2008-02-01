<html>
<script language="javascript">
<!--
   var bolFormError = false;
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
      if (bolFormError == true) {
         alert('Input data errors exist');
         return false;
      }
      if (document.main.FcstStart.value > document.main.FcstEnd.value) {
         alert('Forecast range from value must not be greater than to value');
         return;
      }
      if (document.main.FcstAccuracyNumber.value == '0') {
         alert('Forecast accuracy number must not be 0');
         return;
      }
      var intYear;
      var intNumber;
      var intMaximum = <%if objForm.Fields("ForType").Value = "PRD" then%>13<%else%>12<%end if%>;
      var intCount = 0;
      intCount = 0;
      var strStart = document.main.FcstStart.value;
      var strEnd = document.main.FcstEnd.value;
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
      if (!selectBrandFlag(false)) {
         return;
      }
      if (!selectBrandSubFlag(false)) {
         return;
      }
      if (!selectPrdctPackSize(false)) {
         return;
      }
      if (!selectMultiPackQty(false)) {
         return;
      }
      if (!selectCnsmrPackFrmt(false)) {
         return;
      }
      parent.setActions('<nobr>&nbsp;<%=strHeading%> - Processing request - please wait&nbsp;</nobr>');
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'REPORT';
      document.main.submit();
   }
   function setValues() {<%if objForm.Fields("FcstAccuracyNumber").Value = "" then%>
      document.main.FcstAccuracyNumber.value = '3';<%end if%>
      document.main.BusSgmntText.value = '<%=objSelection.ListValue01("BUS_SGMNT",i)%>';<%if objForm.Fields("PrintOrientation").Value = "" then%>
      document.main.PrintOrientation.value = '2';<%end if%><%if objForm.Fields("PrintPagesWide").Value = "" then%>
      document.main.PrintPagesWide.value = '1';<%end if%><%if objForm.Fields("PlanningType").Value = "" then%>
      document.main.PlanningTypeText.value = 'ALL';<%end if%><%if objForm.Fields("PlanningSrcUnit").Value = "" then%>
      document.main.PlanningSrcUnitText.value = 'ALL';<%end if%><%if objForm.Fields("PlanningStatus").Value = "" then%>
      document.main.PlanningStatusText.value = 'ALL';<%end if%><%if objForm.Fields("PlanningCategory").Value = "" then%>
      document.main.PlanningCategoryText.value = 'ALL';<%end if%>
   }
   function setRanges() {
      var objOption;
      var intYear;
      var intNumber;
      var intMaximum = <%if objForm.Fields("ForType").Value = "PRD" then%>13<%else%>12<%end if%>;
      var strStart = '<%=objSelection.ListValue01("TERM",0)%>';
      var strEnd = '<%=objSelection.ListValue02("TERM",0)%>';<%if objForm.Fields("FcstStart").Value = "" then%>
      var strSelect01 = '<%=objSelection.ListValue01("TERM",0)%>';
      document.main.FcstStart.value = '<%=objSelection.ListValue01("TERM",0)%>';<%else%>
      strSelect01 = '<%=objForm.Fields("FcstStart").Value%>';<%end if%><%if objForm.Fields("FcstEnd").Value = "" then%>
      var strSelect02 = '<%=objSelection.ListValue01("TERM",0)%>';
      document.main.FcstEnd.value = '<%=objSelection.ListValue01("TERM",0)%>';<%else%>
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
   function selectBrandFlag(bolText) {
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
            if (bolText) {
               strText = strText + '<input type="hidden" name="BrandFlagText' + lngWorkCount + '" value="' + objSelect.options(i).text + '">';
            }
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
   function selectBrandSubFlag(bolText) {
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
            if (bolText) {
               strText = strText + '<input type="hidden" name="BrandSubFlagText' + lngWorkCount + '" value="' + objSelect.options(i).text + '">';
            }
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
   function selectPrdctPackSize(bolText) {
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
            if (bolText) {
               strText = strText + '<input type="hidden" name="PrdctPackSizeText' + lngWorkCount + '" value="' + objSelect.options(i).text + '">';
            }
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
   function selectMultiPackQty(bolText) {
      var bolAll = false;
      var strText = '';
      var lngWorkCount = 0;
      var objSelect = eval('document.all("sltMultiPackQty")');
      for (i=0;i<objSelect.options.length;i++) {
         if (objSelect.options(i).selected) {
            if (objSelect.options(i).value == '') {
               bolAll = true;
            }
            lngWorkCount = lngWorkCount + 1;
            strText = strText + '<input type="hidden" name="MultiPackQtyValue' + lngWorkCount + '" value="' + objSelect.options(i).value + '">';
            if (bolText) {
               strText = strText + '<input type="hidden" name="MultiPackQtyText' + lngWorkCount + '" value="' + objSelect.options(i).text + '">';
            }
         }
      }
      if (lngWorkCount == 0) {
         alert('At least one multi pack must be selected');
         document.main.sltMultiPackQty.focus();
         return false;
      }
      if (bolAll && lngWorkCount > 1) {
         alert('Multi pack ALL must be only selection when selected');
         document.main.sltMultiPackQty.focus();
         return false;
      }
      document.all.MultiPackQtyData.innerHTML = strText;
      document.all.MultiPackQtyCount.value = lngWorkCount;
      return true;
   }
   function selectCnsmrPackFrmt(bolText) {
      var bolAll = false;
      var strText = '';
      var lngWorkCount = 0;
      var objSelect = eval('document.all("sltCnsmrPackFrmt")');
      for (i=0;i<objSelect.options.length;i++) {
         if (objSelect.options(i).selected) {
            if (objSelect.options(i).value == '') {
               bolAll = true;
            }
            lngWorkCount = lngWorkCount + 1;
            strText = strText + '<input type="hidden" name="CnsmrPackFrmtValue' + lngWorkCount + '" value="' + objSelect.options(i).value + '">';
            if (bolText) {
               strText = strText + '<input type="hidden" name="CnsmrPackFrmtText' + lngWorkCount + '" value="' + objSelect.options(i).text + '">';
            }
         }
      }
      if (lngWorkCount == 0) {
         alert('At least one consumer package must be selected');
         document.main.sltCnsmrPackFrmt.focus();
         return false;
      }
      if (bolAll && lngWorkCount > 1) {
         alert('Consumer package ALL must be only selection when selected');
         document.main.sltCnsmrPackFrmt.focus();
         return false;
      }
      document.all.CnsmrPackFrmtData.innerHTML = strText;
      document.all.CnsmrPackFrmtCount.value = lngWorkCount;
      return true;
   }
   function selectPlanningType(objSelect) {
      document.main.PlanningType.value = objSelect.options[objSelect.selectedIndex].value;
      document.main.PlanningTypeText.value = objSelect.options[objSelect.selectedIndex].text;
   }
   function selectPlanningSrcUnit(objSelect) {
      document.main.PlanningSrcUnit.value = objSelect.options[objSelect.selectedIndex].value;
      document.main.PlanningSrcUnitText.value = objSelect.options[objSelect.selectedIndex].text;
   }
   function selectPlanningStatus(strValue,strText) {
      document.main.PlanningStatus.value = strValue;
      document.main.PlanningStatusText.value = strText;
   }
   function selectPlanningCategory(strValue,strText) {
      document.main.PlanningCategory.value = strValue;
      document.main.PlanningCategoryText.value = strText;
   }
   function clearMaterials() {
      var strText = '<table class="clsTable02" align=center cols=1 cellpadding="0" cellspacing="0">';
      strText = strText + '<tr><td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;MATERIALS&nbsp;-&nbsp;<a class="clsButton" href="javascript:selectMaterials();">Select</a>&nbsp;</nobr></td></tr>';
      strText = strText + '<tr><td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;ALL MATERIALS&nbsp;</nobr></td></tr>';
      strText = strText + '</table>';
      document.all.MaterialData.innerHTML = strText;
      document.all.MaterialCount.value = '';
   }
   function selectMaterials() {
      if (!selectBrandFlag(true)) {
         return;
      }
      if (!selectBrandSubFlag(true)) {
         return;
      }
      if (!selectPrdctPackSize(true)) {
         return;
      }
      if (!selectMultiPackQty(true)) {
         return;
      }
      if (!selectCnsmrPackFrmt(true)) {
         return;
      }
      parent.setActions('<nobr>&nbsp;<%=strHeading%> - Processing request - please wait&nbsp;</nobr>');
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SELECT';
      document.main.submit();
   }
   var strInputName = '*';
   function validateNumber(objInput,intDecimals,bolNegative) {
      var fltWork;
      var bolDecimal = false;
      if ((strInputName != '*') && (objInput.name != strInputName)) {return;}
      bolFormError = false;
      strInputName = '*';
      if (objInput.value == '') {objInput.value = '0';}
      for (i=0;i<objInput.value.length;i++) {
         if (objInput.value.substring(i,i+1) == '-') {
            if (i != 0) {bolFormError = true; break;}
         } else if (objInput.value.substring(i,i+1) == '.') {
            if (bolDecimal == true) {bolFormError = true; break;}
            bolDecimal = true;  
         } else if ((objInput.value.substring(i,i+1) < '0') || (objInput.value.substring(i,i+1) > '9')) {
            bolFormError = true; break;
         }
      }
      if (bolFormError == false) {
         fltWork = parseFloat(objInput.value);
         if (bolNegative == false && fltWork < 0) {fltWork = -fltWork;}
         objInput.style.background = '#ffffff';
         objInput.value = roundNumber(fltWork,intDecimals);
      } else {
         strInputName = objInput.name;
         objInput.style.background = '#ffb6c1';
         objInput.focus();
      }
      return;     
   }
   function roundNumber(fltNumber,intDecimals) {
      var strNumber;
      var intWork;
      var regTest = /\./;
      intDecimals = (!intDecimals?0:intDecimals);
      fltNumber = Math.round((fltNumber*Math.pow(10,intDecimals)))/Math.pow(10,intDecimals);
      strNumber = fltNumber.toString();
      if (intDecimals != 0) {
         intWork = strNumber.search(regTest);
         if (intWork == -1) {strNumber = strNumber + '.'; intWork = intDecimals;} else {intWork = intDecimals - ((strNumber.length - 1) - intWork);}
         for (d=1;d<=intWork;d++) {strNumber = strNumber + '0';}
      }
      return strNumber;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html;charset=Shift-JIS">
   <link rel="stylesheet" type="text/css" href="mfjpln_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');setActions();setValues();setRanges();">
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
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Forecast Range:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltFcstStart" onChange="selectFcstStart(this);"></select>
            <font class="clsLabelBB" valign=center>&nbsp;-&nbsp;</font>
            <select class="clsInputBN" name="sltFcstEnd" onChange="selectFcstEnd(this);"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Forecast Accuracy Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="FcstAccuracyNumber" size="3" maxlength="3" value="<%if objForm.Fields("FcstAccuracyNumber").Value = "" then%>0<%else%><%=objForm.Fields("FcstAccuracyNumber").Value%><%end if%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Multi Pack:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltMultiPackQty" multiple size=5>
               <option value=""<%if objForm.Fields("MultiPackQtyCount").Value = "" or objForm.Fields("MultiPackQtyCount").Value = "0" or objForm.Fields("MultiPackQtyValue1").Value = "" then%> selected<%end if%>>ALL<%for i = 0 to objSelection.ListCount("MULTI_PACK_QTY") - 1%>
               <option value="<%=objSelection.ListValue01("MULTI_PACK_QTY",i)%>"<%bolSelect = false%><%if objForm.Fields("MultiPackQtyCount").Value <> "" then%><%for j = 1 to clng(objForm.Fields("MultiPackQtyCount").Value)%><%if objForm.Fields("MultiPackQtyValue" & cstr(j)).Value = objSelection.ListValue01("MULTI_PACK_QTY",i) then%><%bolSelect = true%><%exit for%><%end if%><%next%><%end if%><%if bolSelect = true then%> selected<%end if%>><%=objSelection.ListValue02("MULTI_PACK_QTY",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Consumer Package:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltCnsmrPackFrmt" multiple size=5>
               <option value=""<%if objForm.Fields("CnsmrPackFrmtCount").Value = "" or objForm.Fields("CnsmrPackFrmtCount").Value = "0" or objForm.Fields("CnsmrPackFrmtValue1").Value = "" then%> selected<%end if%>>ALL<%for i = 0 to objSelection.ListCount("CNSMR_PACK_FRMT") - 1%>
               <option value="<%=objSelection.ListValue01("CNSMR_PACK_FRMT",i)%>"<%bolSelect = false%><%if objForm.Fields("CnsmrPackFrmtCount").Value <> "" then%><%for j = 1 to clng(objForm.Fields("CnsmrPackFrmtCount").Value)%><%if objForm.Fields("CnsmrPackFrmtValue" & cstr(j)).Value = objSelection.ListValue01("CNSMR_PACK_FRMT",i) then%><%bolSelect = true%><%exit for%><%end if%><%next%><%end if%><%if bolSelect = true then%> selected<%end if%>><%=objSelection.ListValue02("CNSMR_PACK_FRMT",i)%><%next%>
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
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Source Unit:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltPlanningSrcUnit" onChange="selectPlanningSrcUnit(this);">
               <option value=""<%if objForm.Fields("PlanningSrcUnit").Value = "" then%> selected<%end if%>>ALL<%for i = 0 to objSelection.ListCount("PLANNING_SRC_UNIT") - 1%>
               <option value="<%=replace(objSelection.ListValue01("PLANNING_SRC_UNIT",i), """", "&#34;", 1, -1, 1)%>"<%if objForm.Fields("PlanningSrcUnit").Value = objSelection.ListValue01("PLANNING_SRC_UNIT",i) then%> selected<%end if%>><%=objSelection.ListValue01("PLANNING_SRC_UNIT",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Product Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltStatus"<%if objForm.Fields("PlanningStatus").Value = "" then%> checked<%end if%> value="" onClick="javascript:selectPlanningStatus('','ALL');">&nbsp;ALL&nbsp;
            <input type="radio" name="sltStatus"<%if objForm.Fields("PlanningStatus").Value = "0" then%> checked<%end if%> value="0" onClick="javascript:selectPlanningStatus('0','Active');">&nbsp;Active&nbsp;
            <input type="radio" name="sltStatus"<%if objForm.Fields("PlanningStatus").Value = "1" then%> checked<%end if%> value="1" onClick="javascript:selectPlanningStatus('1','Inactive');">&nbsp;Inactive&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Product Category:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="radio" name="sltCategory"<%if objForm.Fields("PlanningCategory").Value = "" then%> checked<%end if%> value="" onClick="javascript:selectPlanningCategory('','ALL');">&nbsp;ALL&nbsp;
            <input type="radio" name="sltCategory"<%if objForm.Fields("PlanningCategory").Value = "A" then%> checked<%end if%> value="A" onClick="javascript:selectPlanningStatus('A','A');">&nbsp;A&nbsp;
            <input type="radio" name="sltCategory"<%if objForm.Fields("PlanningCategory").Value = "B" then%> checked<%end if%> value="B" onClick="javascript:selectPlanningCategory('B','B');">&nbsp;B&nbsp;
            <input type="radio" name="sltCategory"<%if objForm.Fields("PlanningCategory").Value = "C" then%> checked<%end if%> value="C" onClick="javascript:selectPlanningCategory('C','C');">&nbsp;C&nbsp;
            <input type="radio" name="sltCategory"<%if objForm.Fields("PlanningCategory").Value = "N" then%> checked<%end if%> value="N" onClick="javascript:selectPlanningCategory('N','N');">&nbsp;N&nbsp;
            <input type="radio" name="sltCategory"<%if objForm.Fields("PlanningCategory").Value = "X" then%> checked<%end if%> value="X" onClick="javascript:selectPlanningCategory('X','None');">&nbsp;None&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelUL" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center id="MaterialData" colspan=2 nowrap><nobr>
            <table class="clsTable02" align=center cols=1 cellpadding="0" cellspacing="0"><%if objForm.Fields("MaterialCount").Value = "" then%>
               <tr>
                  <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;MATERIALS&nbsp;-&nbsp;<a class="clsButton" href="javascript:selectMaterials();">Select</a>&nbsp;</nobr></td>
               </tr>
               <tr>
                  <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;ALL MATERIALS&nbsp</nobr></td>
               </tr><%else%>
               <tr>
                  <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;MATERIALS&nbsp;-&nbsp;<a class="clsButton" href="javascript:clearMaterials();">Clear</a>&nbsp;</nobr></td>
               </tr><%for i = 1 to clng(objForm.Fields("MaterialCount").Value)%>
               <tr>
                  <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("MaterialText" & cstr(i)).Value%></nobr>
                     <input type="hidden" name="MaterialValue<%=i%>" value="<%=objForm.Fields("MaterialValue" & cstr(i)).Value%>">
                     <input type="hidden" name="MaterialText<%=i%>" value="<%=replace(objForm.Fields("MaterialText" & cstr(i)).Value, """", "&#34;", 1, -1, 1)%>">
                  </td>
               </tr><%next%><%end if%>
            </table>
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
      <tr>
         <td id="MultiPackQtyData" colspan=2 style="display:none">&nbsp;<%if objForm.Fields("MultiPackQtyCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("MultiPackQtyCount").Value)%>
            <input type="hidden" name="MultiPackQtyValue<%=i%>" value="<%=objForm.Fields("MultiPackQtyValue" & cstr(i)).Value%>"><%next%><%end if%>
         </td>
      </tr>
      <tr>
         <td id="CnsmrPackFrmtData" colspan=2 style="display:none">&nbsp;<%if objForm.Fields("CnsmrPackFrmtCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("CnsmrPackFrmtCount").Value)%>
            <input type="hidden" name="CnsmrPackFrmtValue<%=i%>" value="<%=objForm.Fields("CnsmrPackFrmtValue" & cstr(i)).Value%>"><%next%><%end if%>
         </td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="ForType" value="<%=objForm.Fields("ForType").Value%>">
   <input type="hidden" name="FcstStart" value="<%=objForm.Fields("FcstStart").Value%>">
   <input type="hidden" name="FcstEnd" value="<%=objForm.Fields("FcstEnd").Value%>">
   <input type="hidden" name="PrintOrientation" value="<%=objForm.Fields("PrintOrientation").Value%>">
   <input type="hidden" name="PrintPagesWide" value="<%=objForm.Fields("PrintPagesWide").Value%>">
   <input type="hidden" name="BusSgmnt" value="<%=objForm.Fields("BusSgmnt").Value%>">
   <input type="hidden" name="PlanningType" value="<%=objForm.Fields("PlanningType").Value%>">
   <input type="hidden" name="PlanningSrcUnit" value="<%=objForm.Fields("PlanningSrcUnit").Value%>">
   <input type="hidden" name="PlanningStatus" value="<%=objForm.Fields("PlanningStatus").Value%>">
   <input type="hidden" name="PlanningCategory" value="<%=objForm.Fields("PlanningCategory").Value%>">
   <input type="hidden" name="BusSgmntText" value="<%=objForm.Fields("BusSgmntText").Value%>">
   <input type="hidden" name="PlanningTypeText" value="<%=objForm.Fields("PlanningTypeText").Value%>">
   <input type="hidden" name="PlanningSrcUnitText" value="<%=objForm.Fields("PlanningSrcUnitText").Value%>">
   <input type="hidden" name="PlanningStatusText" value="<%=objForm.Fields("PlanningStatusText").Value%>">
   <input type="hidden" name="PlanningCategoryText" value="<%=objForm.Fields("PlanningCategoryText").Value%>">
   <input type="hidden" name="MaterialCount" value="<%=objForm.Fields("MaterialCount").Value%>">
   <input type="hidden" name="BrandFlagCount" value="<%=objForm.Fields("BrandFlagCount").Value%>">
   <input type="hidden" name="BrandSubFlagCount" value="<%=objForm.Fields("BrandSubFlagCount").Value%>">
   <input type="hidden" name="PrdctPackSizeCount" value="<%=objForm.Fields("PrdctPackSizeCount").Value%>">
   <input type="hidden" name="MultiPackQtyCount" value="<%=objForm.Fields("MultiPackQtyCount").Value%>">
   <input type="hidden" name="CnsmrPackFrmtCount" value="<%=objForm.Fields("CnsmrPackFrmtCount").Value%>">
</form>
</body>
</html>