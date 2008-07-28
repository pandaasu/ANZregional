<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_EdiSndtoCode.focus();<%if strReturn <> "*OK" then%>
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
      if (document.main.INP_EdiSndtoCode.value != document.main.DTA_EdiSndtoCode.value) {bolChange = true;}
      if (document.main.INP_EdiEffatMonth.value != document.main.DTA_EdiEffatMonth.value) {bolChange = true;}
      if (document.main.INP_EdiSndonDelay.value != document.main.DTA_EdiSndonDelay.value) {bolChange = true;}
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
      if (document.main.INP_EdiSndtoCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Send to code must be entered';
      }
      if (document.main.INP_EdiEffatMonth.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Effective at month must be entered';
      }
      if (document.main.INP_EdiSndonDelay.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Send on delay must be entered';
      }
      var strTest01 = '*';
      var strTest02 = '*';
      var strTest03 = '*';
      var strTest04 = '*';
      var strTest05 = '*';
      var intTest01 = -1;
      var intTest02 = -1;
      var intTest03 = -1;
      var intTest04 = -1;
      var intTest05 = -1;
      var strCycle01 = '*';
      var strCycle02 = '*';
      var strCycle03 = '*';
      var strCycle04 = '*';
      var strCycle05 = '*';
      for (var i=0;i<55;i++) {
         if (objCycles[i] == 'C01A') {
            if (strTest01 == '*') {
               strTest01 = 'A';
               strCycle01 = (i+1) + ':';
            } else if (strTest01 == 'A') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 01 already started';
            } else {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 01 already defined';
            }
         } else if (objCycles[i] == 'C02A') {
            if (strTest01 != 'B') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 02 - cycle 01 not defined or ended';
            }
            if (intTest01 != i-1) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 02 must start directly after cycle 01';
            }
            if (strTest02 == '*') {
               strTest02 = 'A';
               strCycle02 = (i+1) + ':';
            } else if (strTest02 == 'A') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 02 already started';
            } else {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 02 already defined';
            }
         } else if (objCycles[i] == 'C03A') {
            if (strTest02 != 'B') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 03 - cycle 02 not defined or ended';
            }
            if (intTest02 != i-1) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 03 must start directly after cycle 02';
            }
            if (strTest03 == '*') {
               strTest03 = 'A';
               strCycle03 = (i+1) + ':';
            } else if (strTest03 == 'A') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 03 already started';
            } else {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 03 already defined';
            }
         } else if (objCycles[i] == 'C04A') {
            if (strTest03 != 'B') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 04 - cycle 03 not defined or ended';
            }
            if (intTest03 != i-1) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 04 must start directly after cycle 03';
            }
            if (strTest04 == '*') {
               strTest04 = 'A';
               strCycle04 = (i+1) + ':';
            } else if (strTest04 == 'A') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 04 already started';
            } else {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 04 already defined';
            }
         } else if (objCycles[i] == 'C05A') {
            if (strTest04 != 'B') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 05 - cycle 04 not defined or ended';
            }
            if (intTest04 != i-1) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 05 must start directly after cycle 04';
            }
            if (strTest05 == '*') {
               strTest05 = 'A';
               strCycle05 = (i+1) + ':';
            } else if (strTest05 == 'A') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 05 already started';
            } else {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 05 already defined';
            }
         } else if (objCycles[i] == 'C01B') {
            if (strTest01 == '*') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 01 not started';
            } else if (strTest01 == 'A') {
               strTest01 = 'B';
               intTest01 = i;
               strCycle01 = strCycle01 + (i+1);
            } else {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 01 already defined';
            }
         } else if (objCycles[i] == 'C02B') {
            if (strTest02 == '*') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 02 not started';
            } else if (strTest02 == 'A') {
               strTest02 = 'B';
               intTest02 = i;
               strCycle02 = strCycle02 + (i+1);
            } else {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 02 already defined';
            }
         } else if (objCycles[i] == 'C03B') {
            if (strTest03 == '*') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 03 not started';
            } else if (strTest03 == 'A') {
               strTest03 = 'B';
               intTest03 = i;
               strCycle03 = strCycle03 + (i+1);
            } else {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 03 already defined';
            }
         } else if (objCycles[i] == 'C04B') {
            if (strTest04 == '*') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 04 not started';
            } else if (strTest04 == 'A') {
               strTest04 = 'B';
               intTest04 = i;
               strCycle04 = strCycle04 + (i+1);
            } else {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 04 already defined';
            }
         } else if (objCycles[i] == 'C05B') {
            if (strTest05 == '*') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 05 not started';
            } else if (strTest05 == 'A') {
               strTest05 = 'B';
               intTest05 = i;
               strCycle05 = strCycle05 + (i+1);
            } else {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Cycle 05 already defined';
            }
         }
      }
      if (strTest01 == 'A') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Cycle 01 not ended';
      }
      if (strTest02 == 'A') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Cycle 02 not ended';
      }
      if (strTest03 == 'A') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Cycle 03 not ended';
      }
      if (strTest04 == 'A') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Cycle 04 not ended';
      }
      if (strTest05 == 'A') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Cycle 05 not ended';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      document.main.DTA_EdiSndtoCode.value = document.main.INP_EdiSndtoCode.value;
      document.main.DTA_EdiEffatMonth.value = document.main.INP_EdiEffatMonth.value;
      document.main.DTA_EdiSndonDelay.value = document.main.INP_EdiSndonDelay.value;
      document.main.DTA_EdiCycle01.value = strCycle01;
      document.main.DTA_EdiCycle02.value = strCycle02;
      document.main.DTA_EdiCycle03.value = strCycle03;
      document.main.DTA_EdiCycle04.value = strCycle04;
      document.main.DTA_EdiCycle05.value = strCycle05;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'INSERT_ACCEPT';
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
   function selectSndtoCode(objSelect) {
      document.main.INP_EdiSndtoCode.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectEffatMonth(objSelect) {
      document.main.INP_EdiEffatMonth.value = objSelect.options[objSelect.selectedIndex].value;
   }
   var objCycles = new Array();
   for (var i=0;i<55;i++) {
      objCycles[i] = '****';
   }
   function selectCycle(objSelect,intDay) {
      objCycles[intDay] = objSelect.options[objSelect.selectedIndex].value;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('mjp_edi_whslr_cycle_insert_help.htm');parent.setHeading('<%=strHeading%> - Insert');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Send To Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltSndtoCode" onChange="selectSndtoCode(this);">
               <option value=""<%if objForm.Fields("DTA_EdiSndtoCode").Value = "" then%> selected<%end if%>>** select send to code **<%for i = 0 to objSelection.ListCount("WHSLR") - 1%>
               <option value="<%=objSelection.ListValue01("WHSLR",i)%>"<%if objForm.Fields("DTA_EdiSndtoCode").Value = objSelection.ListValue01("WHSLR",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("WHSLR",i)%>) <%=objSelection.ListValue02("WHSLR",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Effective Month:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltEffatMonth" onChange="selectEffatMonth(this);">
               <option value=""<%if objForm.Fields("DTA_EdiEffatMonth").Value = "" then%> selected<%end if%>>** select effective month **<%for i = 2008 to 2028%><%for j = 1 to 13%>
               <option value="<%=(i*100)+j%>"><%=mid((i*100)+j,1,4)&"/"&mid((i*100)+j,5,2)%><%next%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Send Delay Days:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EdiSndonDelay" size="1" maxlength="1" value="<%=objForm.Fields("DTA_EdiSndonDelay").Value%>" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <table class="clsTableHead" align=center cols=3 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Month&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Day&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Cycles&nbsp;</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelHB" align=center rowspan=27 colspan=1 nowrap><nobr>&nbsp;Previous&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;01&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP01" onChange="selectCycle(this,0);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;02&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP02" onChange="selectCycle(this,1);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;03&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP03" onChange="selectCycle(this,2);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;04&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP04" onChange="selectCycle(this,3);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;05&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP05" onChange="selectCycle(this,4);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;06&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP06" onChange="selectCycle(this,5);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;07&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP07" onChange="selectCycle(this,6);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;08&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP08" onChange="selectCycle(this,7);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;09&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP09" onChange="selectCycle(this,8);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;10&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP10" onChange="selectCycle(this,9);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;11&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP11" onChange="selectCycle(this,10);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;12&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP12" onChange="selectCycle(this,11);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;13&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP13" onChange="selectCycle(this,12);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;14&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP14" onChange="selectCycle(this,13);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;15&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP15" onChange="selectCycle(this,14);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;16&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP16" onChange="selectCycle(this,15;">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;17&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP17" onChange="selectCycle(this,16);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;18&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP18" onChange="selectCycle(this,17);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;19&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP19" onChange="selectCycle(this,18);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;20&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP20" onChange="selectCycle(this,19);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;21&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP21" onChange="selectCycle(this,20);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;22&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP22" onChange="selectCycle(this,21);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;23&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP23" onChange="selectCycle(this,22);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;24&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP24" onChange="selectCycle(this,23);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;25&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP25" onChange="selectCycle(this,24);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;26&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP26" onChange="selectCycle(this,25);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;27&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycP27" onChange="selectCycle(this,26);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelHB" align=center colspan=3 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelHB" align=center rowspan=28 colspan=1 nowrap><nobr>&nbsp;Current&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;01&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC01" onChange="selectCycle(this,27);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;02&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC02" onChange="selectCycle(this,28);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;03&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC03" onChange="selectCycle(this,29);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;04&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC04" onChange="selectCycle(this,30);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;05&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC05" onChange="selectCycle(this,31);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;06&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC06" onChange="selectCycle(this,32);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;07&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC07" onChange="selectCycle(this,33);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;08&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC08" onChange="selectCycle(this,34);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;09&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC09" onChange="selectCycle(this,35);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;10&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC10" onChange="selectCycle(this,36);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;11&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC11" onChange="selectCycle(this,37);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;12&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC12" onChange="selectCycle(this,38);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;13&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC13" onChange="selectCycle(this,39);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;14&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC14" onChange="selectCycle(this,40);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;15&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC15" onChange="selectCycle(this,41);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;16&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC16" onChange="selectCycle(this,42);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;17&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC17" onChange="selectCycle(this,43);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;18&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC18" onChange="selectCycle(this,44);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;19&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC19" onChange="selectCycle(this,45);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;20&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC20" onChange="selectCycle(this,46);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;21&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC21" onChange="selectCycle(this,47);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;22&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC22" onChange="selectCycle(this,48);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;23&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC23" onChange="selectCycle(this,49);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;24&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC24" onChange="selectCycle(this,50);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;25&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC25" onChange="selectCycle(this,51);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;26&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC26" onChange="selectCycle(this,52);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;27&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC27" onChange="selectCycle(this,53);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;*LAST&nbsp;</nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" name="sltCycC99" onChange="selectCycle(this,54);">
                                                                                          <option value="****">*
                                                                                          <option value="C01A">Cycle 01 - Start
                                                                                          <option value="C02A">Cycle 02 - Start
                                                                                          <option value="C03A">Cycle 03 - Start
                                                                                          <option value="C04A">Cycle 04 - Start
                                                                                          <option value="C05A">Cycle 05 - Start
                                                                                          <option value="C01B">Cycle 01 - End
                                                                                          <option value="C02B">Cycle 02 - End
                                                                                          <option value="C03B">Cycle 03 - End
                                                                                          <option value="C04B">Cycle 04 - End
                                                                                          <option value="C05B">Cycle 05 - End
                                                                                       </select></nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>

      </table></nobr></td></tr>
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
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_EdiSndtoCode" value="<%=objForm.Fields("DTA_EdiSndtoCode").Value%>">
   <input type="hidden" name="DTA_EdiEffatMonth" value="<%=objForm.Fields("DTA_EdiEffatMonth").Value%>">
   <input type="hidden" name="DTA_EdiSndonDelay" value="<%=objForm.Fields("DTA_EdiSndonDelay").Value%>">
   <input type="hidden" name="DTA_EdiCycle01" value="<%=objForm.Fields("DTA_EdiCycle01").Value%>">
   <input type="hidden" name="DTA_EdiCycle02" value="<%=objForm.Fields("DTA_EdiCycle02").Value%>">
   <input type="hidden" name="DTA_EdiCycle03" value="<%=objForm.Fields("DTA_EdiCycle03").Value%>">
   <input type="hidden" name="DTA_EdiCycle04" value="<%=objForm.Fields("DTA_EdiCycle04").Value%>">
   <input type="hidden" name="DTA_EdiCycle05" value="<%=objForm.Fields("DTA_EdiCycle05").Value%>">
   <input type="hidden" name="INP_EdiSndtoCode" value="<%=objForm.Fields("DTA_EdiSndtoCode").Value%>">
   <input type="hidden" name="INP_EdiEffatMonth" value="<%=objForm.Fields("DTA_EdiEffatMonth").Value%>">
</form>
</body>
</html>