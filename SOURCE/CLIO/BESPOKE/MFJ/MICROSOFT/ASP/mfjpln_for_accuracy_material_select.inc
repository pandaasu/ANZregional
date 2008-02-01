<html>
<script language="javascript">
<!--
   function setActions() {
      var strText = '<nobr>&nbsp;<%=strHeading%> - MATERIAL SELECTION -';
      strText = strText + '&nbsp;<a class="clsButton" href="javascript:doAction(\'Cancel\');">Cancel</a>&nbsp;';<%if objSelection.ListCount("MATERIAL") > 0 then%>
      strText = strText + '|&nbsp;<a class="clsButton" href="javascript:doAction(\'Select\');">Select</a>&nbsp;';<%end if%>
      strText = strText + '</nobr>';
      parent.setActions(strText);
   }
   function doAction(strAction) {
      if (strAction == 'Cancel') {
         cancelForm();
      }
      if (strAction == 'Select') {
         processForm();
      }
   }
   function cancelForm() {
      parent.setActions('<nobr>&nbsp;<%=strHeading%> - MATERIAL SELECTION - Processing request - please wait&nbsp;</nobr>');
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'PROMPT';
      document.main.submit();
   }
   function processForm() {
      var strText = '';
      var lngMaterialCount = 0;
      var objSelect = eval('document.all("MaterialList")');
      for (i=0;i<objSelect.options.length;i++) {
         if (objSelect.options(i).selected) {
            lngMaterialCount = lngMaterialCount + 1;
            strText = strText + '<input type="hidden" name="MaterialValue' + lngMaterialCount + '" value="' + objSelect.options(i).value + '">';
            strText = strText + '<input type="hidden" name="MaterialText' + lngMaterialCount + '" value="' + objSelect.options(i).text.replace(/"/g,'&#34;') + '">';
         }
      }
      if (lngMaterialCount == 0) {
         alert('At least one material must be selected');
         document.main.MaterialList.focus();
         return;
      }
      document.all.MaterialData.innerHTML = strText;
      document.all.MaterialCount.value = lngMaterialCount;
      parent.setActions('<nobr>&nbsp;<%=strHeading%> - MATERIAL SELECTION - Processing request - please wait&nbsp;</nobr>');
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'PROMPT';
      document.main.submit();
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html;charset=Shift-JIS">
   <link rel="stylesheet" type="text/css" href="mfjpln_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');setActions();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr><%if objSelection.ListCount("MATERIAL") > 0 then%>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <select class="clsInputBN" name="MaterialList" multiple size=20><%for i = 0 to objSelection.ListCount("MATERIAL") - 1%>
               <option value="<%=objSelection.ListValue01("MATERIAL",i)%>">(<%=objSelection.ListValue01("MATERIAL",i)%>)&nbsp;<%=objSelection.ListValue02("MATERIAL",i)%><%next%>
            </select>
         </nobr></td><%else%>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;NO MATERIALS MATCH THE SELECTION VALUES&nbsp;</nobr></td><%end if%>
      </tr>
      <tr>
         <td class="clsLabelUL" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Business Segment:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("BusSgmntText").Value%>&nbsp;</nobr></td>
      </tr><%if objForm.Fields("BrandFlagCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("BrandFlagCount").Value)%><%if i = 1 then%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Brand:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("BrandFlagText" & cstr(i)).Value%>&nbsp;</nobr></td>
      </tr><%else%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("BrandFlagText" & cstr(i)).Value%>&nbsp;</nobr></td>
      </tr><%end if%><%next%><%end if%><%if objForm.Fields("BrandSubFlagCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("BrandSubFlagCount").Value)%><%if i = 1 then%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Sub Brand:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("BrandSubFlagText" & cstr(i)).Value%>&nbsp;</nobr></td>
      </tr><%else%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("BrandSubFlagText" & cstr(i)).Value%>&nbsp;</nobr></td>
      </tr><%end if%><%next%><%end if%><%if objForm.Fields("PrdctPackSizeCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("PrdctPackSizeCount").Value)%><%if i = 1 then%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Packsize:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("PrdctPackSizeText" & cstr(i)).Value%>&nbsp;</nobr></td>
      </tr><%else%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("PrdctPackSizeText" & cstr(i)).Value%>&nbsp;</nobr></td>
      </tr><%end if%><%next%><%end if%><%if objForm.Fields("MultiPackQtyCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("MultiPackQtyCount").Value)%><%if i = 1 then%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Multi Pack:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("MultiPackQtyText" & cstr(i)).Value%>&nbsp;</nobr></td>
      </tr><%else%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("MultiPackQtyText" & cstr(i)).Value%>&nbsp;</nobr></td>
      </tr><%end if%><%next%><%end if%><%if objForm.Fields("CnsmrPackFrmtCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("CnsmrPackFrmtCount").Value)%><%if i = 1 then%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Consumer Package:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("CnsmrPackFrmtText" & cstr(i)).Value%>&nbsp;</nobr></td>
      </tr><%else%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("CnsmrPackFrmtText" & cstr(i)).Value%>&nbsp;</nobr></td>
      </tr><%end if%><%next%><%end if%>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Product Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("PlanningTypeText").Value%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Source Unit:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("PlanningSrcUnitText").Value%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Product Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("PlanningStatusText").Value%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Product Category:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><%=objForm.Fields("PlanningCategoryText").Value%>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td id="MaterialData" colspan=2 style="display:none"><%if objForm.Fields("MaterialCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("MaterialCount").Value)%>
            <input type="hidden" name="MaterialValue<%=i%>" value="<%=objForm.Fields("MaterialValue" & cstr(i)).Value%>">
            <input type="hidden" name="MaterialText<%=i%>" value="<%=replace(objForm.Fields("MaterialText" & cstr(i)).Value, """", "&#34;", 1, -1, 1)%>"><%next%><%end if%>
         </td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="ForType" value="<%=objForm.Fields("ForType").Value%>">
   <input type="hidden" name="FcstStart" value="<%=objForm.Fields("FcstStart").Value%>">
   <input type="hidden" name="FcstEnd" value="<%=objForm.Fields("FcstEnd").Value%>">
   <input type="hidden" name="FcstAccuracyNumber" value="<%=objForm.Fields("FcstAccuracyNumber").Value%>">
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
   <input type="hidden" name="CnsmrPackFrmtCount" value="<%=objForm.Fields("CnsmrPackFrmtCount").Value%>"><%if objForm.Fields("BrandFlagCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("BrandFlagCount").Value)%>
   <input type="hidden" name="BrandFlagValue<%=i%>" value="<%=objForm.Fields("BrandFlagValue" & cstr(i)).Value%>">
   <input type="hidden" name="BrandFlagText<%=i%>" value="<%=objForm.Fields("BrandFlagText" & cstr(i)).Value%>"><%next%><%end if%><%if objForm.Fields("BrandSubFlagCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("BrandSubFlagCount").Value)%>
   <input type="hidden" name="BrandSubFlagValue<%=i%>" value="<%=objForm.Fields("BrandSubFlagValue" & cstr(i)).Value%>">
   <input type="hidden" name="BrandSubFlagText<%=i%>" value="<%=objForm.Fields("BrandSubFlagText" & cstr(i)).Value%>"><%next%><%end if%><%if objForm.Fields("PrdctPackSizeCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("PrdctPackSizeCount").Value)%>
   <input type="hidden" name="PrdctPackSizeValue<%=i%>" value="<%=objForm.Fields("PrdctPackSizeValue" & cstr(i)).Value%>">
   <input type="hidden" name="PrdctPackSizeText<%=i%>" value="<%=objForm.Fields("PrdctPackSizeText" & cstr(i)).Value%>"><%next%><%end if%><%if objForm.Fields("MultiPackQtyCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("MultiPackQtyCount").Value)%>
   <input type="hidden" name="MultiPackQtyValue<%=i%>" value="<%=objForm.Fields("MultiPackQtyValue" & cstr(i)).Value%>">
   <input type="hidden" name="MultiPackQtyText<%=i%>" value="<%=objForm.Fields("MultiPackQtyText" & cstr(i)).Value%>"><%next%><%end if%><%if objForm.Fields("CnsmrPackFrmtCount").Value <> "" then%><%for i = 1 to clng(objForm.Fields("CnsmrPackFrmtCount").Value)%>
   <input type="hidden" name="CnsmrPackFrmtValue<%=i%>" value="<%=objForm.Fields("CnsmrPackFrmtValue" & cstr(i)).Value%>">
   <input type="hidden" name="CnsmrPackFrmtText<%=i%>" value="<%=objForm.Fields("CnsmrPackFrmtText" & cstr(i)).Value%>"><%next%><%end if%>
</form>
</body>
</html>