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
      if (changeItems() == true) {bolChange = true;}
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
      var strDetail = '';
      strDetail = checkItems();
      if (strDetail != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strDetail;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'FORMAT_ACCEPT';
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
   // Report formatting script //
   //////////////////////////////
   var cobjReport;
   var cobjReportData = new Array();
   var cobjReportBreak = new Array();
   var cobjReportTerm = new Array();
   function loadReportItems() {
      cobjReport = new clsReport('<%=replace(objSelection.ListValue02("REPORT",objSelection.ListLower("REPORT")), """", "&#34;", 1, -1, 1)%>','<%=objSelection.ListValue03("REPORT",objSelection.ListLower("REPORT"))%>');<%if objSelection.ListCount("REPORT_DATA") <> 0 then%><%for i = objSelection.ListLower("REPORT_DATA") to objSelection.ListUpper("REPORT_DATA")%>
      cobjReportData[<%=i%>] = new clsReportData('<%=objSelection.ListValue01("REPORT_DATA",i)%>','<%=replace(objSelection.ListValue02("REPORT_DATA",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue03("REPORT_DATA",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue04("REPORT_DATA",i)%>','<%=objSelection.ListValue05("REPORT_DATA",i)%>');<%next%><%end if%><%if objSelection.ListCount("REPORT_BREAK") <> 0 then%><%for i = objSelection.ListLower("REPORT_BREAK") to objSelection.ListUpper("REPORT_BREAK")%>
      cobjReportBreak[<%=i%>] = new clsReportBreak('<%=objSelection.ListValue01("REPORT_BREAK",i)%>','<%=replace(objSelection.ListValue02("REPORT_BREAK",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue03("REPORT_BREAK",i)%>');<%next%><%end if%><%if objSelection.ListCount("REPORT_TERM") <> 0 then%><%for i = objSelection.ListLower("REPORT_TERM") to objSelection.ListUpper("REPORT_TERM")%>
      cobjReportTerm[<%=i%>] = new clsReportTerm('<%=objSelection.ListValue01("REPORT_TERM",i)%>','<%=replace(objSelection.ListValue02("REPORT_TERM",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue03("REPORT_TERM",i)%>');<%next%><%end if%>
      var objFormatTable;
      var objRow;
      var objCell;
      var objInput;
      var intRowCount;
      var intCellCount;
      objFormatTable = document.getElementById('tabFormatLayout');
      intRowCount = 0;
      objRow = objFormatTable.insertRow(intRowCount);
      objCell = objRow.insertCell(0);
      objCell.colSpan = cobjReportData.length;
      objCell.innerText = 'Report Heading';
      objCell.className = 'clsLabelBB';
      objCell.style.backgroundColor = '#40414c';
      objCell.style.color = '#ffffff';
      objCell.style.textAlign = 'center';
      objCell.style.whiteSpace = 'nowrap';
      intRowCount++;
      objRow = objFormatTable.insertRow(intRowCount);
      objCell = objRow.insertCell(0);
      objCell.id = 'REPHED';
      objCell.colSpan = cobjReportData.length;
      objCell.innerText = cobjReport.name;
      objCell.onclick = function() {startFormatter('*REPHED',this);};
      setStyle(objCell,cobjReport.namefrmt);
      objCell.style.whiteSpace = 'nowrap';
      objCell.style.cursor = 'pointer';
      intRowCount++;
      objRow = objFormatTable.insertRow(intRowCount);
      objCell = objRow.insertCell(0);
      objCell.colSpan = cobjReportData.length;
      objCell.innerHTML = '<table class="clsTable01" align=center cols=3 cellpadding=0 cellspacing=0><tr><td class="clsLabelWB" align=center colspan=1 nowrap><nobr>Column Headings</nobr></td><td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:startFormatter(\'*COLHEDALL\',null);">&nbsp;Format All&nbsp;</a></nobr></td></tr></table>';
      objCell.className = 'clsLabelBB';
      objCell.style.backgroundColor = '#40414c';
      objCell.style.color = '#ffffff';
      objCell.style.textAlign = 'center';
      objCell.style.whiteSpace = 'nowrap';
      intRowCount++;
      objRow = objFormatTable.insertRow(intRowCount);
      intCellCount = 0;
      for (var i=0;i<cobjReportData.length;i++) {
         objCell = objRow.insertCell(intCellCount);
         objCell.innerText = cobjReportData[i].name;
         objCell.className = 'clsLabelBB';
         objCell.style.backgroundColor = '#40414c';
         objCell.style.color = '#ffffff';
         objCell.style.textAlign = 'center';
         objCell.style.whiteSpace = 'nowrap';
         intCellCount++;
      }
      intRowCount++;
      objRow = objFormatTable.insertRow(intRowCount);
      intCellCount = 0;
      for (var i=0;i<cobjReportData.length;i++) {
         objCell = objRow.insertCell(intCellCount);
         objCell.id = 'COLHED'+i;
         objCell.innerText = cobjReportData[i].ovrd;
         objCell.onclick = function() {startFormatter('*COLHED',this);};
         setStyle(objCell,cobjReportData[i].datafrmt);
         objCell.style.whiteSpace = 'nowrap';
         objCell.style.cursor = 'pointer';
         objCell.setAttribute('idx',i);
         intCellCount++;
      }
      intRowCount++;
      objRow = objFormatTable.insertRow(intRowCount);
      objCell = objRow.insertCell(0);
      objCell.colSpan = cobjReportData.length;
      objCell.innerHTML = '<table class="clsTable01" align=center cols=3 cellpadding=0 cellspacing=0><tr><td class="clsLabelWB" align=center colspan=1 nowrap><nobr>Report Breaks</nobr></td><td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:startFormatter(\'*REPBRKALL\',null);">&nbsp;Format All&nbsp;</a></nobr></td></tr></table>';
      objCell.className = 'clsLabelBB';
      objCell.style.backgroundColor = '#40414c';
      objCell.style.color = '#ffffff';
      objCell.style.textAlign = 'center';
      objCell.style.whiteSpace = 'nowrap';
      for (var i=0;i<cobjReportBreak.length;i++) {
         intRowCount++;
         objRow = objFormatTable.insertRow(intRowCount);
         objCell = objRow.insertCell(0);
         objCell.id = 'REPBRK'+i;
         objCell.colSpan = cobjReportData.length;
         objCell.innerText = cobjReportBreak[i].name;
         objCell.onclick = function() {startFormatter('*REPBRK',this);};
         setStyle(objCell,cobjReportBreak[i].datafrmt);
         objCell.style.whiteSpace = 'nowrap';
         objCell.style.cursor = 'pointer';
         objCell.setAttribute('idx',i);
      }
      intRowCount++;
      objRow = objFormatTable.insertRow(intRowCount);
      objCell = objRow.insertCell(0);
      objCell.colSpan = cobjReportData.length;
      objCell.innerHTML = '<table class="clsTable01" align=center cols=3 cellpadding=0 cellspacing=0><tr><td class="clsLabelWB" align=center colspan=1 nowrap><nobr>Column Data</nobr></td><td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:startFormatter(\'*COLDATALL\',null);">&nbsp;Format All&nbsp;</a></nobr></td></tr></table>';
      objCell.className = 'clsLabelBB';
      objCell.style.backgroundColor = '#40414c';
      objCell.style.color = '#ffffff';
      objCell.style.textAlign = 'center';
      objCell.style.whiteSpace = 'nowrap';
      intRowCount++;
      objRow = objFormatTable.insertRow(intRowCount);
      intCellCount = 0;
      for (var i=0;i<cobjReportData.length;i++) {
         objCell = objRow.insertCell(intCellCount);
         objCell.id = 'COLDAT'+i;
         objCell.innerText = '*Data*';
         objCell.onclick = function() {startFormatter('*COLDAT',this);};
         setStyle(objCell,cobjReportData[i].datafrmt);
         objCell.style.whiteSpace = 'nowrap';
         objCell.style.cursor = 'pointer';
         objCell.setAttribute('idx',i);
         intCellCount++;
      }
      intRowCount++;
      objRow = objFormatTable.insertRow(intRowCount);
      objCell = objRow.insertCell(0);
      objCell.colSpan = cobjReportData.length;
      objCell.innerHTML = '<table class="clsTable01" align=center cols=3 cellpadding=0 cellspacing=0><tr><td class="clsLabelWB" align=center colspan=1 nowrap><nobr>Terms and Conditions</nobr></td><td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td><td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:startFormatter(\'*REPTERALL\',null);">&nbsp;Format All&nbsp;</a></nobr></td></tr></table>';
      objCell.className = 'clsLabelBB';
      objCell.style.backgroundColor = '#40414c';
      objCell.style.color = '#ffffff';
      objCell.style.textAlign = 'center';
      objCell.style.whiteSpace = 'nowrap';
      for (var i=0;i<cobjReportTerm.length;i++) {
         intRowCount++;
         objRow = objFormatTable.insertRow(intRowCount);
         objCell = objRow.insertCell(0);
         objCell.id = 'REPTER'+i;
         objCell.colSpan = cobjReportData.length;
         objCell.innerText = cobjReportTerm[i].text;
         objCell.onclick = function() {startFormatter('*REPTER',this);};
         setStyle(objCell,cobjReportTerm[i].datafrmt);
         objCell.style.whiteSpace = 'nowrap';
         objCell.style.cursor = 'pointer';
         objCell.setAttribute('idx',i);
      }
   }
   function clsReport(strName,strNameFrmt) {
      this.name = strName;
      this.namefrmt = strNameFrmt;
      this.namesave = strNameFrmt;
   }
   function clsReportData(strId,strName,strOvrd,strNameFrmt,strDataFrmt) {
      this.id = strId;
      this.name = strName;
      this.ovrd = strOvrd;
      this.namefrmt = strNameFrmt;
      this.datafrmt = strDataFrmt;
      this.ovrdsave = strOvrd;
      this.namesave = strNameFrmt;
      this.datasave = strDataFrmt;
   }
   function clsReportBreak(strId,strName,strDataFrmt) {
      this.id = strId;
      this.name = strName;
      this.datafrmt = strDataFrmt;
      this.datasave = strDataFrmt;
   }
   function clsReportTerm(strId,strText,strDataFrmt) {
      this.id = strId;
      this.text = strText;
      this.datafrmt = strDataFrmt;
      this.datasave = strDataFrmt;
   }
   function setStyle(objObject,strStyle) {
      objObject.style.fontFamily = 'Arial,sans-serif';
      objObject.style.fontSize = '10pt';
      objObject.style.fontWeight = 'normal';
      objObject.style.fontStyle = 'normal';
      objObject.style.backgroundColor = '#ffffff';
      objObject.style.color = '#000000';
      objObject.style.borderColor = '#000000 #000000 #000000 #000000';
      objObject.style.borderStyle = 'solid solid solid solid';
      objObject.style.borderWidth = '.75pt .75pt .75pt .75pt';
      objObject.style.textAlign = 'left';
      if (strStyle != '') {
         var aryStyle = strStyle.split(';');
         var aryAttribute;
         for (var i=0;i<aryStyle.length;i++) {
            aryAttribute = aryStyle[i].split(':');
            if (aryAttribute[0] == 'font-family') {
               objObject.style.fontFamily = aryAttribute[1];
            } else if (aryAttribute[0] == 'font-size') {
               objObject.style.fontSize = aryAttribute[1];
            } else if (aryAttribute[0] == 'font-weight') {
               objObject.style.fontWeight = aryAttribute[1];
            } else if (aryAttribute[0] == 'font-style') {
               objObject.style.fontStyle = aryAttribute[1];
            } else if (aryAttribute[0] == 'background-color') {
               objObject.style.backgroundColor = aryAttribute[1];
            } else if (aryAttribute[0] == 'color') {
               objObject.style.color = aryAttribute[1];
            } else if (aryAttribute[0] == 'border-color') {
               objObject.style.borderColor = aryAttribute[1];
            } else if (aryAttribute[0] == 'border-style') {
               objObject.style.borderStyle = aryAttribute[1];
            } else if (aryAttribute[0] == 'border-width') {
               objObject.style.borderWidth = aryAttribute[1];
            } else if (aryAttribute[0] == 'text-align') {
               objObject.style.textAlign = aryAttribute[1];
            }
         }
      }
   }
   function getStyle(objObject) {
      return 'font-family:'+objObject.style.fontFamily+';'+
             'font-size:'+objObject.style.fontSize+';'+
             'font-weight:'+objObject.style.fontWeight+';'+
             'font-style:'+objObject.style.fontStyle+';'+
             'background-color:'+objObject.style.backgroundColor+';'+
             'color:'+objObject.style.color+';'+
             'border-color:'+objObject.style.borderColor+' '+objObject.style.borderColor+' '+objObject.style.borderColor+' '+objObject.style.borderColor+';'+
             'border-style:'+objObject.style.borderStyle+' '+objObject.style.borderStyle+' '+objObject.style.borderStyle+' '+objObject.style.borderStyle+';'+
             'border-width:'+objObject.style.borderWidth+' '+objObject.style.borderWidth+' '+objObject.style.borderWidth+' '+objObject.style.borderWidth+';'+
             'text-align:'+objObject.style.textAlign+';';
   }
   function checkItems() {
      var strReturn = '';
      var objHidden = null;
      objHidden = document.createElement('input');
      objHidden.setAttribute('type','hidden');
      objHidden.setAttribute('name','DET_RepHed');
      objHidden.setAttribute('value',cobjReport.namefrmt);
      document.forms['main'].appendChild(objHidden);
      for (var i=0;i<cobjReportData.length;i++) {
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_RepDatId'+(i+1));
         objHidden.setAttribute('value',cobjReportData[i].id);
         document.forms['main'].appendChild(objHidden);
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_RepDatOvr'+(i+1));
         objHidden.setAttribute('value',cobjReportData[i].ovrd);
         document.forms['main'].appendChild(objHidden);
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_RepDatHed'+(i+1));
         objHidden.setAttribute('value',cobjReportData[i].namefrmt);
         document.forms['main'].appendChild(objHidden);
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_RepDatDat'+(i+1));
         objHidden.setAttribute('value',cobjReportData[i].datafrmt);
         document.forms['main'].appendChild(objHidden);
      }
      document.getElementById('DET_RepDatCount').value = cobjReportData.length;
      for (var i=0;i<cobjReportBreak.length;i++) {
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_RepBrkId'+(i+1));
         objHidden.setAttribute('value',cobjReportBreak[i].id);
         document.forms['main'].appendChild(objHidden);
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_RepBrkDat'+(i+1));
         objHidden.setAttribute('value',cobjReportBreak[i].datafrmt);
         document.forms['main'].appendChild(objHidden);
      }
      document.getElementById('DET_RepBrkCount').value = cobjReportBreak.length;
      for (var i=0;i<cobjReportTerm.length;i++) {
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_RepTerId'+(i+1));
         objHidden.setAttribute('value',cobjReportTerm[i].id);
         document.forms['main'].appendChild(objHidden);
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_RepTerDat'+(i+1));
         objHidden.setAttribute('value',cobjReportTerm[i].datafrmt);
         document.forms['main'].appendChild(objHidden);
      }
      document.getElementById('DET_RepTerCount').value = cobjReportTerm.length;
      return strReturn;
   }
   function changeItems() {
      var bolReturn = false;
      if (cobjReport.namefrmt != cobjReport.namesave) {
         bolReturn = true;
      }
      for (var i=0;i<cobjReportData.length;i++) {
         if (cobjReportData[i].ovrd != cobjReportData[i].ovrdsave ||
             cobjReportData[i].namefrmt != cobjReportData[i].namesave ||
             cobjReportData[i].datafrmt != cobjReportData[i].datasave) {
            bolReturn = true;
            break;
         }
      }
      for (var i=0;i<cobjReportBreak.length;i++) {
         if (cobjReportBreak[i].datafrmt != cobjReportBreak[i].datasave) {
            bolReturn = true;
            break;
         }
      }
      for (var i=0;i<cobjReportTerm.length;i++) {
         if (cobjReportTerm[i].datafrmt != cobjReportTerm[i].datasave) {
            bolReturn = true;
            break;
         }
      }
      return bolReturn;
   }
// -->
</script>
<script language="javascript">
<!--
   //////////////////////////////
   // Report formatting script //
   //////////////////////////////
   var cobjFormatterSource;
   var cobjFormatterTarget;
   var cstrFormatterAction;
   var cobjFontFamilys = new Array();
   cobjFontFamilys[0] = new clsSelectList('Arial','Arial,sans-serif');
   cobjFontFamilys[1] = new clsSelectList('Tahoma','Tahoma,sans-serif');
   cobjFontFamilys[2] = new clsSelectList('Verdana','Verdana,sans-serif');
   var cobjFontWeights = new Array();
   cobjFontWeights[0] = new clsSelectList('Normal','normal');
   cobjFontWeights[1] = new clsSelectList('Bold','bold');
   var cobjFontStyles = new Array();
   cobjFontStyles[0] = new clsSelectList('Normal','normal');
   cobjFontStyles[1] = new clsSelectList('Italic','italic');
   var cobjFontSizes = new Array();
   cobjFontSizes[0] = new clsSelectList('8','8pt');
   cobjFontSizes[1] = new clsSelectList('9','9pt');
   cobjFontSizes[2] = new clsSelectList('10','10pt');
   cobjFontSizes[3] = new clsSelectList('11','11pt');
   cobjFontSizes[4] = new clsSelectList('12','12pt');
   cobjFontSizes[5] = new clsSelectList('14','14pt');
   cobjFontSizes[6] = new clsSelectList('16','16pt');
   cobjFontSizes[7] = new clsSelectList('18','18pt');
   cobjFontSizes[8] = new clsSelectList('20','20pt');
   cobjFontSizes[9] = new clsSelectList('22','22pt');
   cobjFontSizes[10] = new clsSelectList('24','24pt');
   cobjFontSizes[11] = new clsSelectList('26','26pt');
   cobjFontSizes[12] = new clsSelectList('28','28pt');
   cobjFontSizes[13] = new clsSelectList('36','36pt');
   cobjFontSizes[14] = new clsSelectList('48','48pt');
   cobjFontSizes[15] = new clsSelectList('72','72pt');
   var cobjTextAligns = new Array();
   cobjTextAligns[0] = new clsSelectList('Left','left');
   cobjTextAligns[1] = new clsSelectList('Right','right');
   cobjTextAligns[2] = new clsSelectList('Center','center');
   cobjTextAligns[3] = new clsSelectList('Justify','justify');
   var cobjColors = new Array('000000','000033','000066','000099','0000CC','0000FF',
                              '003300','003333','003366','003399','0033CC','0033FF',
                              '006600','006633','006666','006699','0066CC','0066FF',
                              '009900','009933','009966','009999','0099CC','0099FF',
                              '00CC00','00CC33','00CC66','00CC99','00CCCC','00CCFF',
                              '00FF00','00FF33','00FF66','00FF99','00FFCC','00FFFF',
                              '330000','330033','330066','330099','3300CC','3300FF',
                              '333300','333333','333366','333399','3333CC','3333FF',
                              '336600','336633','336666','336699','3366CC','3366FF',
                              '339900','339933','339966','339999','3399CC','3399FF',
                              '33CC00','33CC33','33CC66','33CC99','33CCCC','33CCFF',
                              '33FF00','33FF33','33FF66','33FF99','33FFCC','33FFFF',
                              '660000','660033','660066','660099','6600CC','6600FF',
                              '663300','663333','663366','663399','6633CC','6633FF',
                              '666600','666633','666666','666699','6666CC','6666FF',
                              '669900','669933','669966','669999','6699CC','6699FF',
                              '66CC00','66CC33','66CC66','66CC99','66CCCC','66CCFF',
                              '66FF00','66FF33','66FF66','66FF99','66FFCC','66FFFF',
                              '990000','990033','990066','990099','9900CC','9900FF',
                              '993300','993333','993366','993399','9933CC','9933FF',
                              '996600','996633','996666','996699','9966CC','9966FF',
                              '999900','999933','999966','999999','9999CC','9999FF',
                              '99CC00','99CC33','99CC66','99CC99','99CCCC','99CCFF',
                              '99FF00','99FF33','99FF66','99FF99','99FFCC','99FFFF',
                              'CC0000','CC0033','CC0066','CC0099','CC00CC','CC00FF',
                              'CC3300','CC3333','CC3366','CC3399','CC33CC','CC33FF',
                              'CC6600','CC6633','CC6666','CC6699','CC66CC','CC66FF',
                              'CC9900','CC9933','CC9966','CC9999','CC99CC','CC99FF',
                              'CCCC00','CCCC33','CCCC66','CCCC99','CCCCCC','CCCCFF',
                              'CCFF00','CCFF33','CCFF66','CCFF99','CCFFCC','CCFFFF',
                              'FF0000','FF0033','FF0066','FF0099','FF00CC','FF00FF',
                              'FF3300','FF3333','FF3366','FF3399','FF33CC','FF33FF',
                              'FF6600','FF6633','FF6666','FF6699','FF66CC','FF66FF',
                              'FF9900','FF9933','FF9966','FF9999','FF99CC','FF99FF',
                              'FFCC00','FFCC33','FFCC66','FFCC99','FFCCCC','FFCCFF',
                              'FFFF00','FFFF33','FFFF66','FFFF99','FFFFCC','FFFFFF');
   var cobjBorderStyles = new Array('none','solid','dashed','dotted','solid','double','solid','dashed','dotted');
   var cobjBorderWidths = new Array('1.0pt','1.0pt','1.0pt','1.0pt','1.5pt','2.0pt','2.0pt','2.0pt','2.0pt');
   var cobjBorderColors = new Array('#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000');
   function clsSelectList(strText,strValue) {
      this.text = strText;
      this.value = strValue;
   }
   function loadFormatting() {
      var objSelect;
      var objTable;
      var objRow;
      var objCell;
      var intRowCount = 0;
      var intCellCount = 0;
      objTable = document.getElementById('tabForegroundColor');
      for (var i=0;i<cobjColors.length;i++) {
         if (i%12 == 0) {
            objRow = objTable.insertRow(intRowCount);
            intRowCount++;
            intCellCount = 0;
         }
         objCell = objRow.insertCell(intCellCount);
         objCell.height = '12px';
         objCell.width = '12px';
         objCell.style.backgroundColor = '#'+cobjColors[i];
         objCell.style.cursor = 'pointer';
         objCell.onclick = function() {selectForegroundColor(this);};
         intCellCount++;
      }
      intRowCount = 0;
      intCellCount = 0;
      objTable = document.getElementById('tabBackgroundColor');
      for (var i=0;i<cobjColors.length;i++) {
         if (i%12 == 0) {
            objRow = objTable.insertRow(intRowCount);
            intRowCount++;
            intCellCount = 0;
         }
         objCell = objRow.insertCell(intCellCount);
         objCell.height = '12px';
         objCell.width = '12px';
         objCell.style.backgroundColor = '#'+cobjColors[i];
         objCell.style.cursor = 'pointer';
         objCell.onclick = function() {selectBackgroundColor(this);};
         intCellCount++;
      }
      intRowCount = 0;
      intCellCount = 0;
      objTable = document.getElementById('tabBorderColor');
      for (var i=0;i<cobjColors.length;i++) {
         if (i%12 == 0) {
            objRow = objTable.insertRow(intRowCount);
            intRowCount++;
            intCellCount = 0;
         }
         objCell = objRow.insertCell(intCellCount);
         objCell.height = '12px';
         objCell.width = '12px';
         objCell.style.backgroundColor = '#'+cobjColors[i];
         objCell.style.cursor = 'pointer';
         objCell.onclick = function() {selectBorderColor(this);};
         intCellCount++;
      }
      intRowCount = 0;
      intCellCount = 0;
      objTable = document.getElementById('tabBorderStyle');
      for (var i=0;i<cobjBorderStyles.length;i++) {
         objRow = objTable.insertRow(intRowCount);
         intRowCount++;
         intCellCount = 0;
         objCell = objRow.insertCell(intCellCount);
         objCell.height = '8px';
         objCell.width = '32px';
         objCell.style.color = '#000000';
         objCell.style.backgroundColor = 'transparent';
         objCell.style.borderStyle = cobjBorderStyles[i];
         objCell.style.borderWidth = cobjBorderWidths[i];
         objCell.style.borderColor = cobjBorderColors[i];
         objCell.style.cursor = 'pointer';
         objCell.onclick = function() {selectBorderStyle(this);};
         objCell.style.fontFamily = 'Arial,sans-serif';
         objCell.style.fontWeight = 'bold';
         objCell.style.fontStyle = 'normal';
         objCell.style.fontSize = '8pt';
         objCell.align = 'center';
         if (cobjBorderStyles[i] == 'none') {
            objCell.innerText = 'none';
         } else {
            objCell.innerText = ' ';
         }
      }
      objSelect = document.getElementById('sltFontFamily');
      for (var i=0;i<cobjFontFamilys.length;i++) {
         objSelect.options[objSelect.options.length] = new Option(cobjFontFamilys[i].text,cobjFontFamilys[i].value);
      }
      objSelect = document.getElementById('sltFontWeight');
      for (var i=0;i<cobjFontWeights.length;i++) {
         objSelect.options[objSelect.options.length] = new Option(cobjFontWeights[i].text,cobjFontWeights[i].value);
      }
      objSelect = document.getElementById('sltFontStyle');
      for (var i=0;i<cobjFontStyles.length;i++) {
         objSelect.options[objSelect.options.length] = new Option(cobjFontStyles[i].text,cobjFontStyles[i].value);
      }
      objSelect = document.getElementById('sltFontSize');
      for (var i=0;i<cobjFontSizes.length;i++) {
         objSelect.options[objSelect.options.length] = new Option(cobjFontSizes[i].text,cobjFontSizes[i].value);
      }
      objSelect = document.getElementById('sltTextAlign');
      for (var i=0;i<cobjTextAligns.length;i++) {
         objSelect.options[objSelect.options.length] = new Option(cobjTextAligns[i].text,cobjTextAligns[i].value);
      }
      cobjFormatterTarget = document.getElementById('fmtTarget');
   }
   function startFormatter(strAction,objObject) {
      cstrFormatterAction = strAction;
      if (cstrFormatterAction == '*COLHEDALL') {
         if (cobjReportData.length != 0) {
            cobjFormatterSource = document.getElementById('COLHED0');
         }
      } else if (cstrFormatterAction == '*COLDATALL') {
         if (cobjReportData.length != 0) {
            cobjFormatterSource = document.getElementById('COLDAT0');
         }
      } else if (cstrFormatterAction == '*REPBRKALL') {
         if (cobjReportBreak.length != 0) {
            cobjFormatterSource = document.getElementById('REPBRK0');
         }
      } else if (cstrFormatterAction == '*REPTERALL') {
         if (cobjReportTerm.length != 0) {
            cobjFormatterSource = document.getElementById('REPTER0');
         }
      } else {
         cobjFormatterSource = objObject;
      }
      if (cobjFormatterSource == null) {
         return;
      }
      cobjFormatterTarget.style.color = cobjFormatterSource.style.color;
      cobjFormatterTarget.style.backgroundColor = cobjFormatterSource.style.backgroundColor;
      cobjFormatterTarget.style.borderColor = cobjFormatterSource.style.borderColor + ' ' + cobjFormatterSource.style.borderColor + ' ' + cobjFormatterSource.style.borderColor + ' ' + cobjFormatterSource.style.borderColor;
      cobjFormatterTarget.style.borderStyle = cobjFormatterSource.style.borderStyle + ' ' + cobjFormatterSource.style.borderStyle + ' ' + cobjFormatterSource.style.borderStyle + ' ' + cobjFormatterSource.style.borderStyle;
      cobjFormatterTarget.style.borderWidth = cobjFormatterSource.style.borderWidth + ' ' + cobjFormatterSource.style.borderWidth + ' ' + cobjFormatterSource.style.borderWidth + ' ' + cobjFormatterSource.style.borderWidth;
      cobjFormatterTarget.style.fontFamily = cobjFormatterSource.style.fontFamily;
      cobjFormatterTarget.style.fontWeight = cobjFormatterSource.style.fontWeight;
      cobjFormatterTarget.style.fontStyle = cobjFormatterSource.style.fontStyle;
      cobjFormatterTarget.style.fontSize = cobjFormatterSource.style.fontSize;
      cobjFormatterTarget.style.textAlign = cobjFormatterSource.style.textAlign;
      if (cstrFormatterAction == '*COLHEDALL') {
         cobjFormatterTarget.innerText = 'All Column Headings';
      } else if (cstrFormatterAction == '*COLDATALL') {
         cobjFormatterTarget.innerText = 'All Column Data';
      } else if (cstrFormatterAction == '*REPBRKALL') {
         cobjFormatterTarget.innerText = 'All Report Breaks';
      } else if (cstrFormatterAction == '*REPTERALL') {
         cobjFormatterTarget.innerText = 'All Terms and Conditions';
      } else {
         cobjFormatterTarget.innerText = cobjFormatterSource.innerText;
      }
      var objSelect;
      objSelect = document.getElementById('sltFontFamily');
      objSelect.selectedIndex = 0;
      for (var i=0;i<objSelect.options.length;i++) {
         if (cobjFormatterSource.style.fontFamily == objSelect.options[i].value) {
            objSelect.options[i].selected = true;
            break;
         }
      }
      objSelect = document.getElementById('sltFontWeight');
      objSelect.selectedIndex = 0;
      for (var i=0;i<objSelect.options.length;i++) {
         if (cobjFormatterSource.style.fontWeight == objSelect.options[i].value) {
            objSelect.options[i].selected = true;
            break;
         }
      }
      objSelect = document.getElementById('sltFontStyle');
      objSelect.selectedIndex = 0;
      for (var i=0;i<objSelect.options.length;i++) {
         if (cobjFormatterSource.style.fontStyle == objSelect.options[i].value) {
            objSelect.options[i].selected = true;
            break;
         }
      }
      objSelect = document.getElementById('sltFontSize');
      objSelect.selectedIndex = 0;
      for (var i=0;i<objSelect.options.length;i++) {
         if (cobjFormatterSource.style.fontSize == objSelect.options[i].value) {
            objSelect.options[i].selected = true;
            break;
         }
      }
      objSelect = document.getElementById('sltTextAlign');
      objSelect.selectedIndex = 0;
      for (var i=0;i<objSelect.options.length;i++) {
         if (cobjFormatterSource.style.textAlign == objSelect.options[i].value) {
            objSelect.options[i].selected = true;
            break;
         }
      }
      var objTableLayout = document.getElementById('tabLayout');
      var objTableFormat = document.getElementById('tabFormat');
      var objRowFormat = document.getElementById('rowFormat');
      var objInputTarget = document.getElementById('inpTarget');
      objTableLayout.style.display = 'none';
      objTableLayout.style.visibility = 'hidden';
      objTableFormat.style.display = 'block';
      objTableFormat.style.visibility = 'visible';
      if (cstrFormatterAction == '*COLHED') {
         objRowFormat.style.display = 'block';
         objRowFormat.style.visibility = 'visible';
         objInputTarget.value = cobjFormatterTarget.innerText;
      } else {
         objRowFormat.style.display = 'none';
         objRowFormat.style.visibility = 'hidden';
      }
   }
   function ApplyFormatter() {
      if (cobjFormatterSource == null) {return;};
      if (cstrFormatterAction == '*COLHEDALL') {
         for (var i=0;i<cobjReportData.length;i++) {
            cobjFormatterSource = document.getElementById('COLHED'+i);
            cobjFormatterSource.style.color = cobjFormatterTarget.style.color;
            cobjFormatterSource.style.backgroundColor = cobjFormatterTarget.style.backgroundColor;
            cobjFormatterSource.style.borderColor = cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor;
            cobjFormatterSource.style.borderStyle = cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle;
            cobjFormatterSource.style.borderWidth = cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth;
            cobjFormatterSource.style.fontFamily = cobjFormatterTarget.style.fontFamily;
            cobjFormatterSource.style.fontWeight = cobjFormatterTarget.style.fontWeight;
            cobjFormatterSource.style.fontStyle = cobjFormatterTarget.style.fontStyle;
            cobjFormatterSource.style.fontSize = cobjFormatterTarget.style.fontSize;
            cobjFormatterSource.style.textAlign = cobjFormatterTarget.style.textAlign;
            cobjReportData[cobjFormatterSource.getAttribute('idx')].namefrmt = getStyle(cobjFormatterSource);
         }
      } else if (cstrFormatterAction == '*COLDATALL') {
         for (var i=0;i<cobjReportData.length;i++) {
            cobjFormatterSource = document.getElementById('COLDAT'+i);
            cobjFormatterSource.style.color = cobjFormatterTarget.style.color;
            cobjFormatterSource.style.backgroundColor = cobjFormatterTarget.style.backgroundColor;
            cobjFormatterSource.style.borderColor = cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor;
            cobjFormatterSource.style.borderStyle = cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle;
            cobjFormatterSource.style.borderWidth = cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth;
            cobjFormatterSource.style.fontFamily = cobjFormatterTarget.style.fontFamily;
            cobjFormatterSource.style.fontWeight = cobjFormatterTarget.style.fontWeight;
            cobjFormatterSource.style.fontStyle = cobjFormatterTarget.style.fontStyle;
            cobjFormatterSource.style.fontSize = cobjFormatterTarget.style.fontSize;
            cobjFormatterSource.style.textAlign = cobjFormatterTarget.style.textAlign;
            cobjReportData[cobjFormatterSource.getAttribute('idx')].datafrmt = getStyle(cobjFormatterSource);
         }
      } else if (cstrFormatterAction == '*REPBRKALL') {
         for (var i=0;i<cobjReportBreak.length;i++) {
            cobjFormatterSource = document.getElementById('REPBRK'+i);
            cobjFormatterSource.style.color = cobjFormatterTarget.style.color;
            cobjFormatterSource.style.backgroundColor = cobjFormatterTarget.style.backgroundColor;
            cobjFormatterSource.style.borderColor = cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor;
            cobjFormatterSource.style.borderStyle = cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle;
            cobjFormatterSource.style.borderWidth = cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth;
            cobjFormatterSource.style.fontFamily = cobjFormatterTarget.style.fontFamily;
            cobjFormatterSource.style.fontWeight = cobjFormatterTarget.style.fontWeight;
            cobjFormatterSource.style.fontStyle = cobjFormatterTarget.style.fontStyle;
            cobjFormatterSource.style.fontSize = cobjFormatterTarget.style.fontSize;
            cobjFormatterSource.style.textAlign = cobjFormatterTarget.style.textAlign;
            cobjReportBreak[cobjFormatterSource.getAttribute('idx')].datafrmt = getStyle(cobjFormatterSource);
         }
      } else if (cstrFormatterAction == '*REPTERALL') {
         for (var i=0;i<cobjReportTerm.length;i++) {
            cobjFormatterSource = document.getElementById('REPTER'+i);
            cobjFormatterSource.style.color = cobjFormatterTarget.style.color;
            cobjFormatterSource.style.backgroundColor = cobjFormatterTarget.style.backgroundColor;
            cobjFormatterSource.style.borderColor = cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor;
            cobjFormatterSource.style.borderStyle = cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle;
            cobjFormatterSource.style.borderWidth = cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth;
            cobjFormatterSource.style.fontFamily = cobjFormatterTarget.style.fontFamily;
            cobjFormatterSource.style.fontWeight = cobjFormatterTarget.style.fontWeight;
            cobjFormatterSource.style.fontStyle = cobjFormatterTarget.style.fontStyle;
            cobjFormatterSource.style.fontSize = cobjFormatterTarget.style.fontSize;
            cobjFormatterSource.style.textAlign = cobjFormatterTarget.style.textAlign;
            cobjReportTerm[cobjFormatterSource.getAttribute('idx')].datafrmt = getStyle(cobjFormatterSource);
         }
      } else {
         cobjFormatterSource.style.color = cobjFormatterTarget.style.color;
         cobjFormatterSource.style.backgroundColor = cobjFormatterTarget.style.backgroundColor;
         cobjFormatterSource.style.borderColor = cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor + ' ' + cobjFormatterTarget.style.borderColor;
         cobjFormatterSource.style.borderStyle = cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle + ' ' + cobjFormatterTarget.style.borderStyle;
         cobjFormatterSource.style.borderWidth = cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth + ' ' + cobjFormatterTarget.style.borderWidth;
         cobjFormatterSource.style.fontFamily = cobjFormatterTarget.style.fontFamily;
         cobjFormatterSource.style.fontWeight = cobjFormatterTarget.style.fontWeight;
         cobjFormatterSource.style.fontStyle = cobjFormatterTarget.style.fontStyle;
         cobjFormatterSource.style.fontSize = cobjFormatterTarget.style.fontSize;
         cobjFormatterSource.style.textAlign = cobjFormatterTarget.style.textAlign;
         if (cstrFormatterAction == '*REPHED') {
            cobjReport.namefrmt = getStyle(cobjFormatterSource);
         } else if (cstrFormatterAction == '*REPBRK') {
            cobjReportBreak[cobjFormatterSource.getAttribute('idx')].datafrmt = getStyle(cobjFormatterSource);
         } else if (cstrFormatterAction == '*COLHED') {
            cobjFormatterSource.innerText = cobjFormatterTarget.innerText;
            cobjReportData[cobjFormatterSource.getAttribute('idx')].ovrd = cobjFormatterSource.innerText;
            cobjReportData[cobjFormatterSource.getAttribute('idx')].namefrmt = getStyle(cobjFormatterSource);
         } else if (cstrFormatterAction == '*COLDAT') {
            cobjReportData[cobjFormatterSource.getAttribute('idx')].datafrmt = getStyle(cobjFormatterSource);
         } else if (cstrFormatterAction == '*REPTER') {
            cobjReportTerm[cobjFormatterSource.getAttribute('idx')].datafrmt = getStyle(cobjFormatterSource);
         }
      }
      cstrFormatterAction == '';
      cobjFormatterSource == null;
      var objTableLayout = document.getElementById('tabLayout');
      var objTableFormat = document.getElementById('tabFormat');
      var objRowFormat = document.getElementById('rowFormat');
      objTableFormat.style.display = 'none';
      objTableFormat.style.visibility = 'hidden';
      objTableLayout.style.display = 'block';
      objTableLayout.style.visibility = 'visible';
      objRowFormat.style.display = 'none';
      objRowFormat.style.visibility = 'hidden';
   }
   function CancelFormatter() {
      cstrFormatterAction == '';
      cobjFormatterSource == null;
      var objTableLayout = document.getElementById('tabLayout');
      var objTableFormat = document.getElementById('tabFormat');
      var objRowFormat = document.getElementById('rowFormat');
      objTableFormat.style.display = 'none';
      objTableFormat.style.visibility = 'hidden';
      objTableLayout.style.display = 'block';
      objTableLayout.style.visibility = 'visible';
      objRowFormat.style.display = 'none';
      objRowFormat.style.visibility = 'hidden';
   }
   function setTargetText(objObject) {
      cobjFormatterTarget.innerText = objObject.value;
   }
   function selectForegroundColor(objObject) {
      if (cobjFormatterTarget == null) {return;};
      cobjFormatterTarget.style.color = objObject.style.backgroundColor;
   }
   function selectBackgroundColor(objObject) {
      if (cobjFormatterTarget == null) {return;};
      cobjFormatterTarget.style.backgroundColor = objObject.style.backgroundColor;
   }
   function selectBorderColor(objObject) {
      if (cobjFormatterTarget == null) {return;};
      cobjFormatterTarget.style.borderColor = objObject.style.backgroundColor + ' ' + objObject.style.backgroundColor + ' ' + objObject.style.backgroundColor + ' ' + objObject.style.backgroundColor;
   }
   function selectBorderStyle(objObject) {
      if (cobjFormatterTarget == null) {return;};
      cobjFormatterTarget.style.borderStyle = objObject.style.borderStyle + ' ' + objObject.style.borderStyle + ' ' + objObject.style.borderStyle + ' ' + objObject.style.borderStyle;
      cobjFormatterTarget.style.borderWidth = objObject.style.borderWidth + ' ' + objObject.style.borderWidth + ' ' + objObject.style.borderWidth + ' ' + objObject.style.borderWidth;
   }
   function setFontFamily(objObject) {
      if (cobjFormatterTarget == null) {return;};
      cobjFormatterTarget.style.fontFamily = objObject.options[objObject.selectedIndex].value;
   }
   function setFontWeight(objObject) {
      if (cobjFormatterTarget == null) {return;};
      cobjFormatterTarget.style.fontWeight = objObject.options[objObject.selectedIndex].value;
   }
   function setFontStyle(objObject) {
      if (cobjFormatterTarget == null) {return;};
      cobjFormatterTarget.style.fontStyle = objObject.options[objObject.selectedIndex].value;
   }
   function setFontSize(objObject) {
      if (cobjFormatterTarget == null) {return;};
      cobjFormatterTarget.style.fontSize = objObject.options[objObject.selectedIndex].value;
   }
   function setTextAlign(objObject) {
      if (cobjFormatterTarget == null) {return;};
      cobjFormatterTarget.style.textAlign = objObject.options[objObject.selectedIndex].value;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('prc_lst_configuration_format_help.htm');parent.setHeading('<%=strHeading%> - Report Formatting');parent.showContent();loadReportItems();loadFormatting();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table id="tabLayout" class="clsGrid02" style="display:block;visibility:visible" align=center valign=top cols=1 cellpadding=1 cellspacing=0>
      <tr><td colspan=1><table id="tabFormatLayout" class="clsGrid02" align=center valign=top cellpadding=2 cellspacing=4></table></td></tr>
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
   <table id="tabFormat" class="clsGrid02" style="display:none;visibility:hidden" align=center valign=top cols=3 cellpadding=4 cellspacing=0>
      <tr><td id="fmtTarget" colspan=3 width=100%></td></tr>
      <tr id="rowFormat" style="display:none;visibility:hidden;"><td colspan=3 align=center width=100%><input class="clsInputNN" type="text" id="inpTarget" size="128" maxlength="200" value="" onFocus="setSelect(this);" onBlur="setTargetText(this);"></td></tr>
      <tr>
         <td colspan=1 valign=top>
            <table class="clsGrid02" align=center border=0 cellpadding=2 cellspacing=0 cols=2>
               <tr><td class="clsLabelBB" style="color:#ffffff;background-color:#708090;" align=center colspan=2 nowrap><nobr>&nbsp;Text Properties&nbsp;</nobr></td></tr>
               <tr>
                  <td class="clsLabelBN" align=center valign=top colspan=1 nowrap><nobr>
                     <table align=center border=0 cellpadding=2 cellspacing=0 cols=2>
                        <tr>
                           <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Font:&nbsp;</nobr></td>
                           <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><select class="clsInputBN" name="sltFontFamily" onChange="setFontFamily(this);"></select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Font Weight:&nbsp;</nobr></td>
                           <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><select class="clsInputBN" name="sltFontWeight" onChange="setFontWeight(this);"></select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Font Style:&nbsp;</nobr></td>
                           <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><select class="clsInputBN" name="sltFontStyle" onChange="setFontStyle(this);"></select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Font Size:&nbsp;</nobr></td>
                           <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><select class="clsInputBN" name="sltFontSize" onChange="setFontSize(this);"></select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Alignment:&nbsp;</nobr></td>
                           <td class="clsLabelBN" align=left colspan=1 nowrap><nobr><select class="clsInputBN" name="sltTextAlign" onChange="setTextAlign(this);"></select></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
                  <td class="clsLabelBN" align=center valign=top colspan=1 nowrap><nobr><table id="tabForegroundColor" align=center border=1 cellpadding=0 cellspacing=0 cols=12></table></nobr></td>
               </tr>
            </table>
         </td>
         <td colspan=1 valign=top>
            <table class="clsGrid02" align=center border=0 cellpadding=2 cellspacing=0 cols=1>
               <tr><td class="clsLabelBB" style="color:#ffffff;background-color:#708090;" align=center colspan=2 nowrap><nobr>&nbsp;Background Color&nbsp;</nobr></td></tr>
               <tr>
                  <td class="clsLabelBN" align=center valign=top colspan=1 nowrap><nobr><table id="tabBackgroundColor" align=center border=1 cellpadding=0 cellspacing=0 cols=12></table></nobr></td>
               </tr>
            </table>
         </td>
         <td colspan=1 valign=top>
            <table class="clsGrid02" align=center border=0 cellpadding=2 cellspacing=0 cols=2>
               <tr><td class="clsLabelBB" style="color:#ffffff;background-color:#708090;" align=center colspan=2 nowrap><nobr>&nbsp;Border Properties&nbsp;</nobr></td></tr>
               <tr>
                  <td class="clsLabelBN" align=center valign=top colspan=1 nowrap><nobr><table id="tabBorderStyle" align=center border=0 cellpadding=0 cellspacing=4 cols=1></table></nobr></td>
                  <td class="clsLabelBN" align=center valign=top colspan=1 nowrap><nobr><table id="tabBorderColor" align=center border=1 cellpadding=0 cellspacing=0 cols=12></table></nobr></td>
               </tr>
            </table>
         </td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=3 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=3 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:CancelFormatter();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:ApplyFormatter();">&nbsp;Apply&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_ReportId" value="<%=objForm.Fields("DTA_ReportId").Value%>">
   <input type="hidden" name="DET_RepDatCount" value="">
   <input type="hidden" name="DET_RepBrkCount" value="">
   <input type="hidden" name="DET_RepTerCount" value="">
</form>
</body>
</html>