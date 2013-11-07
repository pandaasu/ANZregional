<script language="javascript">
<!--
   /////////////////////////
   // Email detail script //
   /////////////////////////
   var objEmailDetails = new Array();<%for i = clng(objSelection.ListLower("DETAIL")) to clng(objSelection.ListUpper("DETAIL"))%>
   objEmailDetails[<%=i%>] = new clsEmailDetail('<%=objSelection.ListValue01("DETAIL",i)%>','<%=replace(objSelection.ListValue02("DETAIL",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue03("DETAIL",i)%>','<%=objSelection.ListValue04("DETAIL",i)%>','<%=objSelection.ListValue05("DETAIL",i)%>','<%=objSelection.ListValue06("DETAIL",i)%>','<%=objSelection.ListValue07("DETAIL",i)%>','<%=objSelection.ListValue08("DETAIL",i)%>','<%=objSelection.ListValue09("DETAIL",i)%>','<%=objSelection.ListValue10("DETAIL",i)%>','<%=objSelection.ListValue11("DETAIL",i)%>','<%=objSelection.ListValue12("DETAIL",i)%>','<%=objSelection.ListValue13("DETAIL",i)%>');<%next%>
   function clsEmailDetail(strKey,strDescription,strSelected,strSearchable,strSearch01,strSearch02,strSearch03,strSearch04,strSearch05,strSearch06,strSearch07,strSearch08,strSearch09) {
      this.key = strKey;
      this.description = strDescription;
      this.searchable = strSearchable;
      this.oldSearch01 = strSearch01;
      this.oldSearch02 = strSearch02;
      this.oldSearch03 = strSearch03;
      this.oldSearch04 = strSearch04;
      this.oldSearch05 = strSearch05;
      this.oldSearch06 = strSearch06;
      this.oldSearch07 = strSearch07;
      this.oldSearch08 = strSearch08;
      this.oldSearch09 = strSearch09;
      this.newSearch01 = strSearch01;
      this.newSearch02 = strSearch02;
      this.newSearch03 = strSearch03;
      this.newSearch04 = strSearch04;
      this.newSearch05 = strSearch05;
      this.newSearch06 = strSearch06;
      this.newSearch07 = strSearch07;
      this.newSearch08 = strSearch08;
      this.newSearch09 = strSearch09;
      this.oldSelected = strSelected;
      this.newSelected = strSelected;
   }
   function selectEmailDetails() {
      var objSltEmailDetail = document.getElementById('sltEmailDetail');
      for (var i=0;i<objSltEmailDetail.options.length;i++) {
         if (objSltEmailDetail.options[i].selected == true) {
            for (var j=0;j<objEmailDetails.length;j++) {
               if (objEmailDetails[j].key == objSltEmailDetail.options[i].value) {
                  objEmailDetails[j].newSelected = '1';
                  break;
               }
            }
         }
      }
      paintEmailDetails();
   }
   function removeEmailDetail(lngIndex) {
      if (lngIndex >= 0 && lngIndex < objEmailDetails.length) {
         objEmailDetails[lngIndex].newSelected = '0';
      }
      paintEmailDetails();
   }
   function checkEmailDetails() {
      var strReturn = '';
      return strReturn;
   }
   function changeEmailDetails() {
      var bolReturn = false;
      for (var i=0;i<objEmailDetails.length;i++) {
         if ((objEmailDetails[i].oldSelected != objEmailDetails[i].newSelected) ||
             (objEmailDetails[i].oldSearch01 != objEmailDetails[i].newSearch01) ||
             (objEmailDetails[i].oldSearch02 != objEmailDetails[i].newSearch02) ||
             (objEmailDetails[i].oldSearch03 != objEmailDetails[i].newSearch03) ||
             (objEmailDetails[i].oldSearch04 != objEmailDetails[i].newSearch04) ||
             (objEmailDetails[i].oldSearch05 != objEmailDetails[i].newSearch05) ||
             (objEmailDetails[i].oldSearch06 != objEmailDetails[i].newSearch06) ||
             (objEmailDetails[i].oldSearch07 != objEmailDetails[i].newSearch07) ||
             (objEmailDetails[i].oldSearch08 != objEmailDetails[i].newSearch08) ||
             (objEmailDetails[i].oldSearch09 != objEmailDetails[i].newSearch09)) {
            bolReturn = true;
            break;
         }
      }
      return bolReturn;
   }
   function selectEmailSearch(objInput,lngIndex,intNumber) {
      if (intNumber == 1) {
         objEmailDetails[lngIndex].newSearch01 = objInput.value;
      } else if (intNumber == 2) {
         objEmailDetails[lngIndex].newSearch02 = objInput.value;
      } else if (intNumber == 3) {
         objEmailDetails[lngIndex].newSearch03 = objInput.value;
      } else if (intNumber == 4) {
         objEmailDetails[lngIndex].newSearch04 = objInput.value;
      } else if (intNumber == 5) {
         objEmailDetails[lngIndex].newSearch05 = objInput.value;
      } else if (intNumber == 6) {
         objEmailDetails[lngIndex].newSearch06 = objInput.value;
      } else if (intNumber == 7) {
         objEmailDetails[lngIndex].newSearch07 = objInput.value;
      } else if (intNumber == 8) {
         objEmailDetails[lngIndex].newSearch08 = objInput.value;
      } else if (intNumber == 9) {
         objEmailDetails[lngIndex].newSearch09 = objInput.value;
      }
   }
   function paintEmailDetails() {
      var objSltEmailDetail = document.getElementById('sltEmailDetail');
      objSltEmailDetail.options.length = 0;
      objSltEmailDetail.selectedIndex = -1;
      for (var i=0;i<objEmailDetails.length;i++) {
         if (objEmailDetails[i].newSelected == '0') {
            objSltEmailDetail.options[objSltEmailDetail.options.length] = new Option(objEmailDetails[i].description,objEmailDetails[i].key);
         }
      }
      var intSelectedCount = 0;
      var strText = '<table align=center border=0 cellpadding=0 cellspacing=2 cols=10>';
      strText = strText + '<tr>';
      strText = strText + '<td class="clsInner" align=center colspan=10 nowrap><nobr><font class="clsLabelWB">&nbsp;Selected Messages - Search Criteria 01/09&nbsp;</font></nobr></td>';
      strText = strText + '</tr>';
      for (var i=0;i<objEmailDetails.length;i++) {
         if (objEmailDetails[i].newSelected == '1') {
            intSelectedCount++;
            strText = strText + '<tr>';
            strText = strText + '<td class="clsLabelBB" align=left colspan=1 valign=center nowrap><nobr>&nbsp;<a class="clsSelect" href="javascript:removeEmailDetail(' + i + ');">Remove&nbsp;</a></nobr></td>';
            strText = strText + '<td class="clsLabelBN" align=left colspan=9 valign=center nowrap><nobr>&nbsp;' + objEmailDetails[i].description + '&nbsp;</nobr><input type="hidden" name="DET_Key' + intSelectedCount + '" value="' + objEmailDetails[i].key + '"></td>';
            strText = strText + '</tr>';
            strText = strText + '<tr>';
            if (objEmailDetails[i].searchable == '1') {
               strText = strText + '<td class="clsLabelBB" align=left colspan=1 valign=center nowrap><nobr>&nbsp;</nobr></td>';
               strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="DET_Search01_' + intSelectedCount + '" size="10" maxlength="256" value="' + objEmailDetails[i].newSearch01 + '" onFocus="setSelect(this);" onBlur="selectEmailSearch(this,' + i + ',1);"></nobr></td>';
               strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="DET_Search02_' + intSelectedCount + '" size="10" maxlength="256" value="' + objEmailDetails[i].newSearch02 + '" onFocus="setSelect(this);" onBlur="selectEmailSearch(this,' + i + ',2);"></nobr></td>';
               strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="DET_Search03_' + intSelectedCount + '" size="10" maxlength="256" value="' + objEmailDetails[i].newSearch03 + '" onFocus="setSelect(this);" onBlur="selectEmailSearch(this,' + i + ',3);"></nobr></td>';
               strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="DET_Search04_' + intSelectedCount + '" size="10" maxlength="256" value="' + objEmailDetails[i].newSearch04 + '" onFocus="setSelect(this);" onBlur="selectEmailSearch(this,' + i + ',4);"></nobr></td>';
               strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="DET_Search05_' + intSelectedCount + '" size="10" maxlength="256" value="' + objEmailDetails[i].newSearch05 + '" onFocus="setSelect(this);" onBlur="selectEmailSearch(this,' + i + ',5);"></nobr></td>';
               strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="DET_Search06_' + intSelectedCount + '" size="10" maxlength="256" value="' + objEmailDetails[i].newSearch06 + '" onFocus="setSelect(this);" onBlur="selectEmailSearch(this,' + i + ',6);"></nobr></td>';
               strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="DET_Search07_' + intSelectedCount + '" size="10" maxlength="256" value="' + objEmailDetails[i].newSearch07 + '" onFocus="setSelect(this);" onBlur="selectEmailSearch(this,' + i + ',7);"></nobr></td>';
               strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="DET_Search08_' + intSelectedCount + '" size="10" maxlength="256" value="' + objEmailDetails[i].newSearch08 + '" onFocus="setSelect(this);" onBlur="selectEmailSearch(this,' + i + ',8);"></nobr></td>';
               strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="DET_Search09_' + intSelectedCount + '" size="10" maxlength="256" value="' + objEmailDetails[i].newSearch09 + '" onFocus="setSelect(this);" onBlur="selectEmailSearch(this,' + i + ',9);"></nobr></td>';
            }
            strText = strText + '</tr>';
         }
      }
      strText = strText + '</table>';
      document.all.tabEmailDetail.innerHTML = strText;
      document.all.DET_DetailCount.value = intSelectedCount;
   }
// -->
</script>