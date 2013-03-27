<html>
<script language="javascript">
<!--
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
   var strSearchGrouping;
   var strSearchInterface;
   var strSearchCondition;
   var strSearchReference;
   var strSearchType;
   var strSearchProcess;
   var strSearchHeader;
   var strSearchTest;
   var strSearchStart;
   var strSearchEnd;
   var strSearchStatus;
   var strSearchExecution;
   var strSearchAdvanced;
   var strAdvancedGrouping;
   var strAdvancedCondition;
   var strAdvancedInterface;
   var strAdvancedType;
   var strAdvancedProcess;
   var strAdvancedHeader;
   var strAdvancedTest;
   var strAdvancedStart;
   var strAdvancedEnd;
   var strAdvancedStatus;
   var strAdvancedExecution;
   var objAdvancedReference = new Array();
   function clsAdvancedReference(strKey,strValue,intIndex) {
      this.key = strKey;
      this.value = strValue;
      this.index = intIndex;
   }
   function addAdvancedReference(strKey,strValue,intIndex) {
      objAdvancedReference[objAdvancedReference.length] = new clsAdvancedReference(strKey,strValue,intIndex);
   }
   function resetAdvancedReference() {
      for (var i=0;i<objAdvancedReference.length;i++) {
         objAdvancedReference[i].index = null;
      }
   }
   function setAdvancedReference(strData) {
      objAdvancedReference.length = 0;
      if (strData != null && strData != '') {
         var aryReturn = strData.split('\n');
         for (var i=0;i<aryReturn.length;i++) {
            var intIdx = aryReturn[i].indexOf('\t');
            if (intIdx != -1) {
               var strKey = aryReturn[i].substring(0,intIdx);
               var strValue = aryReturn[i].substring(intIdx+1,aryReturn[i].length);
               objAdvancedReference[i] = new clsAdvancedReference(strKey,strValue,null);
            }
         }
      }
   }
   function getAdvancedReference() {
      strReturn = '';
      for (var i=0;i<objAdvancedReference.length;i++) {
         if (objAdvancedReference[i].index != null) {
            objAdvancedReference[i].value = document.getElementById('REF_'+objAdvancedReference[i].index).value;
         }
         if (objAdvancedReference[i].value != '' && objAdvancedReference[i].value != null) {
            strReturn = strReturn + objAdvancedReference[i].key + '\t' + objAdvancedReference[i].value + '\n';
         }
      }
      return strReturn;
   }
   function getCurrentReference() {
      strReturn = '';
      for (var i=0;i<objAdvancedReference.length;i++) {
         if (objAdvancedReference[i].index != null) {
            if (objAdvancedReference[i].value != '' && objAdvancedReference[i].value != null) {
               strReturn = strReturn + objAdvancedReference[i].key + '\t' + objAdvancedReference[i].value + '\n';
            }
         }
      }
      return strReturn;
   }
   function removeCurrentReference() {
      for (var i=0;i<objAdvancedReference.length;i++) {
         if (objAdvancedReference[i].index != null) {
            document.getElementById('REF_'+objAdvancedReference[i].index).value = '';
         }
      }
   }
   function showPage() {
      strSearchGrouping = document.getElementById('QRY_Grouping').value;
      strSearchInterface = document.getElementById('QRY_Interface').value;
      strSearchCondition = document.getElementById('QRY_Condition').value;
      strSearchReference = document.getElementById('QRY_Reference').value;
      strSearchType = document.getElementById('QRY_Type').value;
      strSearchProcess = document.getElementById('QRY_Process').value;
      strSearchHeader = document.getElementById('QRY_Header').value;
      strSearchTest = document.getElementById('QRY_Test').value;
      strSearchStart = document.getElementById('QRY_StrTime').value;
      strSearchEnd = document.getElementById('QRY_EndTime').value;
      strSearchStatus = document.getElementById('QRY_Status').value;
      strSearchExecution = document.getElementById('QRY_Execution').value;
      strSearchAdvanced = document.getElementById('QRY_Advanced').value;
      strPage = document.getElementById('Page').value;
      if (strPage == 'P1') {
         showMonitor();
      } else if (strPage == 'P2') {
         showBacklog();
      } else {
         showMonitor();
      }
   }
   function showMonitor() {
      if (strSearchAdvanced == '1') {
         document.getElementById('butAdvanced').innerHTML = '<nobr><a class="clsButton" href="javascript:showAdvanced();">&nbsp;Advanced Filters (Applied)&nbsp;</a></nobr>';
      } else {
         document.getElementById('butAdvanced').innerHTML = '<nobr><a class="clsButton" href="javascript:showAdvanced();">&nbsp;Advanced Filters (Off)&nbsp;</a></nobr>';
      }
      var objMonitor = eval('document.all("tabMonitor")');
      var objAdvanced = eval('document.all("tabAdvanced")');
      var objBacklog = eval('document.all("tabBacklog")');
      objBacklog.style.display = 'none';
      objBacklog.style.visibility = 'hidden';
      objAdvanced.style.display = 'none';
      objAdvanced.style.visibility = 'hidden';
      objMonitor.style.display = 'block';
      objMonitor.style.visibility = 'visible';
   }
   function showAdvanced() {
      strAdvancedGrouping = getCookie('ics_search_grouping');
      strAdvancedInterface = getCookie('ics_search_interface');
      strAdvancedCondition = getCookie('ics_search_condition');
      setAdvancedReference(getCookie('ics_search_reference'));
      strAdvancedType = getCookie('ics_search_type');
      strAdvancedProcess = getCookie('ics_search_process');
      strAdvancedHeader = getCookie('ics_search_header');
      strAdvancedTest = getCookie('ics_search_test');
      if (strAdvancedTest == '') {
         strAdvancedTest = 'EQ';
      }
      strAdvancedStart = getCookie('ics_search_start');
      strAdvancedEnd = getCookie('ics_search_end');
      strAdvancedStatus = getCookie('ics_search_status');
      strAdvancedExecution = getCookie('ics_search_execution');
      document.getElementById('SLT_Header').value = strAdvancedHeader;
      document.getElementById('SLT_StrTime').value = strAdvancedStart;
      document.getElementById('SLT_EndTime').value = strAdvancedEnd;
      document.getElementById('SLT_Execution').value = strAdvancedExecution;
      var objGrouping = document.getElementById('sltAdvancedGrouping');
      for (var i=0;i<objGrouping.options.length;i++) {
         if (objGrouping.options[i].value == strAdvancedGrouping) {
            objGrouping.options[i].selected = true;
            break;
         }
      }
      retrieveAdvancedInterface();
      var objType = document.getElementById('sltAdvancedType');
      for (var i=0;i<objType.options.length;i++) {
         if (objType.options[i].value == strAdvancedType) {
            objType.options[i].selected = true;
            break;
         }
      }
      var objProcess = document.getElementById('sltAdvancedProcess');
      for (var i=0;i<objProcess.options.length;i++) {
         if (objProcess.options[i].value == strAdvancedProcess) {
            objProcess.options[i].selected = true;
            break;
         }
      }
      var objStatus = document.getElementById('sltAdvancedStatus');
      for (var i=0;i<objStatus.options.length;i++) {
         if (objStatus.options[i].value == strAdvancedStatus) {
            objStatus.options[i].selected = true;
            break;
         }
      }
      var objTest = document.getElementById('sltAdvancedTest');
      if (typeof objTest.length == 'number') {
         if (strAdvancedTest != '') {
            var intTestCount = objTest.length;
            for (var i=0;i<intTestCount;i++) {
               objTest[i].checked = false;
               if (objTest[i].value == strAdvancedTest) {
                  objTest[i].checked = true;
               }
            }
         } else {
            objTest[0].checked = true;
         }
      } else {
         objTest.checked = true;
      }
      var objMonitor = eval('document.all("tabMonitor")');
      var objAdvanced = eval('document.all("tabAdvanced")');
      var objBacklog = eval('document.all("tabBacklog")');
      var objReference = eval('document.all("rowReference")');
      objMonitor.style.display = 'none';
      objMonitor.style.visibility = 'hidden';
      objBacklog.style.display = 'none';
      objBacklog.style.visibility = 'hidden';
      objReference.style.display = 'none';
      objReference.style.visibility = 'hidden';
      objAdvanced.style.display = 'block';
      objAdvanced.style.visibility = 'visible';
   }
   function showBacklog() {
      var objMonitor = eval('document.all("tabMonitor")');
      var objAdvanced = eval('document.all("tabAdvanced")');
      var objBacklog = eval('document.all("tabBacklog")');
      objMonitor.style.display = 'none';
      objMonitor.style.visibility = 'hidden';
      objAdvanced.style.display = 'none';
      objAdvanced.style.visibility = 'hidden';
      objBacklog.style.display = 'block';
      objBacklog.style.visibility = 'visible';
   }
   function doMonitor() {
      if (!processForm()) {return;}
      document.main.QRY_Grouping.value = strSearchGrouping;
      document.main.QRY_Interface.value = strSearchInterface;
      document.main.QRY_Condition.value = strSearchCondition;
      document.main.QRY_Reference.value = strSearchReference;
      document.main.QRY_Type.value = strSearchType;
      document.main.QRY_Process.value = strSearchProcess;
      document.main.QRY_Header.value = strSearchHeader;
      document.main.QRY_Test.value = strSearchTest;
      document.main.QRY_StrTime.value = strSearchStart;
      document.main.QRY_EndTime.value = strSearchEnd;
      document.main.QRY_Status.value = strSearchStatus;
      document.main.QRY_Execution.value = strSearchExecution;
      document.main.QRY_Advanced.value = strSearchAdvanced;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SEARCH';
      document.main.Page.value = 'P1';
      document.main.submit();
   }
   function doPrevious() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'PREVIOUS';
      document.main.Page.value = 'P1';
      document.main.submit();
   }
   function doNext() {
      if (!processForm()) {return;}
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'NEXT';
      document.main.Page.value = 'P1';
      document.main.submit();
   }
   function doAdvanced() {
      if (!processForm()) {return;}
      strSearchAdvanced = '1';
      strAdvancedHeader = document.getElementById('SLT_Header').value;
      strAdvancedStart = document.getElementById('SLT_StrTime').value;
      strAdvancedEnd = document.getElementById('SLT_EndTime').value;
      strAdvancedExecution = document.getElementById('SLT_Execution').value;
      setCookie('ics_search_grouping',strAdvancedGrouping,365);
      setCookie('ics_search_interface',strAdvancedInterface,365);
      setCookie('ics_search_condition',strAdvancedCondition,365);
      setCookie('ics_search_reference',getAdvancedReference(),365);
      setCookie('ics_search_type',strAdvancedType,365);
      setCookie('ics_search_process',strAdvancedProcess,365);
      setCookie('ics_search_header',strAdvancedHeader,365);
      setCookie('ics_search_test',strAdvancedTest,365);
      setCookie('ics_search_start',strAdvancedStart,365);
      setCookie('ics_search_end',strAdvancedEnd,365);
      setCookie('ics_search_status',strAdvancedStatus,365);
      setCookie('ics_search_execution',strAdvancedExecution,365);
      strSearchGrouping = strAdvancedGrouping;
      strSearchInterface = strAdvancedInterface;
      strSearchCondition = strAdvancedCondition;
      strSearchReference = getCurrentReference();
      strSearchType = strAdvancedType;
      strSearchProcess = strAdvancedProcess;
      strSearchHeader = strAdvancedHeader;
      strSearchTest = strAdvancedTest;
      strSearchStart = strAdvancedStart;
      strSearchEnd = strAdvancedEnd;
      strSearchStatus = strAdvancedStatus;
      strSearchExecution = strAdvancedExecution;
      document.main.QRY_Grouping.value = strSearchGrouping;
      document.main.QRY_Interface.value = strSearchInterface;
      document.main.QRY_Condition.value = strSearchCondition;
      document.main.QRY_Reference.value = strSearchReference;
      document.main.QRY_Type.value = strSearchType;
      document.main.QRY_Process.value = strSearchProcess;
      document.main.QRY_Header.value = strSearchHeader;
      document.main.QRY_Test.value = strSearchTest;
      document.main.QRY_StrTime.value = strSearchStart;
      document.main.QRY_EndTime.value = strSearchEnd;
      document.main.QRY_Status.value = strSearchStatus;
      document.main.QRY_Execution.value = strSearchExecution;
      document.main.QRY_Advanced.value = strSearchAdvanced;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SEARCH';
      document.main.Page.value = 'P1';
      document.main.submit();
   }
   function removeAdvanced() {
      if (!processForm()) {return;}
      strSearchAdvanced = '0';
      strAdvancedGrouping = '';
      strAdvancedInterface = '';
      strAdvancedCondition = '';
      removeCurrentReference();
      strAdvancedType = '';
      strAdvancedProcess = '';
      strAdvancedHeader = '';
      strAdvancedTest = '';
      strAdvancedStart = '';
      strAdvancedEnd = '';
      strAdvancedStatus = '';
      strAdvancedExecution = '';
      setCookie('ics_search_grouping',strAdvancedGrouping,365);
      setCookie('ics_search_interface',strAdvancedInterface,365);
      setCookie('ics_search_condition',strAdvancedCondition,365);
      setCookie('ics_search_reference',getAdvancedReference(),365);
      setCookie('ics_search_type',strAdvancedType,365);
      setCookie('ics_search_process',strAdvancedProcess,365);
      setCookie('ics_search_header',strAdvancedHeader,365);
      setCookie('ics_search_test',strAdvancedTest,365);
      setCookie('ics_search_start',strAdvancedStart,365);
      setCookie('ics_search_end',strAdvancedEnd,365);
      setCookie('ics_search_status',strAdvancedStatus,365);
      setCookie('ics_search_execution',strAdvancedExecution,365);
      strSearchGrouping = strAdvancedGrouping;
      strSearchInterface = strAdvancedInterface;
      strSearchCondition = strAdvancedCondition;
      strSearchReference = getCurrentReference();
      strSearchType = strAdvancedType;
      strSearchProcess = strAdvancedProcess;
      strSearchHeader = strAdvancedHeader;
      strSearchTest = strAdvancedTest;
      strSearchStart = strAdvancedStart;
      strSearchEnd = strAdvancedEnd;
      strSearchStatus = strAdvancedStatus;
      strSearchExecution = strAdvancedExecution;
      document.main.QRY_Grouping.value = strSearchGrouping;
      document.main.QRY_Interface.value = strSearchInterface;
      document.main.QRY_Condition.value = strSearchCondition;
      document.main.QRY_Reference.value = strSearchReference;
      document.main.QRY_Type.value = strSearchType;
      document.main.QRY_Process.value = strSearchProcess;
      document.main.QRY_Header.value = strSearchHeader;
      document.main.QRY_Test.value = strSearchTest;
      document.main.QRY_StrTime.value = strSearchStart;
      document.main.QRY_EndTime.value = strSearchEnd;
      document.main.QRY_Status.value = strSearchStatus;
      document.main.QRY_Execution.value = strSearchExecution;
      document.main.QRY_Advanced.value = strSearchAdvanced;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SEARCH';
      document.main.Page.value = 'P1';
      document.main.submit();
   }
   function cancelAdvanced() {
      if (strSearchAdvanced == '1') {
         document.getElementById('butAdvanced').innerHTML = '<nobr><a class="clsButton" href="javascript:showAdvanced();">&nbsp;Advanced Filters (Applied)&nbsp;</a></nobr>';
      } else {
         document.getElementById('butAdvanced').innerHTML = '<nobr><a class="clsButton" href="javascript:showAdvanced();">&nbsp;Advanced Filters (Off)&nbsp;</a></nobr>';
      }
      var objMonitor = eval('document.all("tabMonitor")');
      var objAdvanced = eval('document.all("tabAdvanced")');
      var objBacklog = eval('document.all("tabBacklog")');
      objBacklog.style.display = 'none';
      objBacklog.style.visibility = 'hidden';
      objAdvanced.style.display = 'none';
      objAdvanced.style.visibility = 'hidden';
      objMonitor.style.display = 'block';
      objMonitor.style.visibility = 'visible';
   }
   function doBacklog() {
      if (!processForm()) {return;}
      document.main.QRY_Grouping.value = strSearchGrouping;
      document.main.QRY_Interface.value = strSearchInterface;
      document.main.QRY_Condition.value = strSearchCondition;
      document.main.QRY_Reference.value = strSearchReference;
      document.main.QRY_Type.value = strSearchType;
      document.main.QRY_Process.value = strSearchProcess;
      document.main.QRY_Header.value = strSearchHeader;
      document.main.QRY_Test.value = strSearchTest;
      document.main.QRY_StrTime.value = strSearchStart;
      document.main.QRY_EndTime.value = strSearchEnd;
      document.main.QRY_Status.value = strSearchStatus;
      document.main.QRY_Execution.value = strSearchExecution;
      document.main.QRY_Advanced.value = strSearchAdvanced;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SEARCH';
      document.main.Page.value = 'P2';
      document.main.submit();
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function processInterface(strHeader,strTrace) {
      var strParameters;
      strParameters = 'Child=ics_int_detail.asp';
      strParameters = strParameters + '&QRY_Header=' + strHeader;
      strParameters = strParameters + '&QRY_Trace=' + strTrace;
      openWindow(strParameters);
   }
   function retrieveBasicInterface() {
      doActivityStart(document.body);
      doGetRequest('<%=strBase%>ics_lookup.asp?Mode=GROUPING&QRY_Grouping='+strSearchGrouping,function(strResponse) {displayBasicInterface(strResponse);},true);
   }
   function displayBasicInterface(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         strSearchInterface = '';
         alert(strResponse);
      } else {
         var objInterface = document.getElementById('sltBasicInterface');
         if (objInterface) {
            objInterface.options.length = 0;
            objInterface.selectedIndex = -1;
            objInterface.options[0] = new Option('*ALL','');
            objInterface.selectedIndex = 0;
            var aryReturn = strResponse.substring(3,strResponse.length).split('\n');
            for (var i=0;i<aryReturn.length;i++) {
               var intIdx = aryReturn[i].indexOf('\t');
               if (intIdx != -1) {
                  var strValue = aryReturn[i].substring(0,intIdx);
                  var strText = aryReturn[i].substring(intIdx+1,aryReturn[i].length);
                  objInterface.options[i+1] = new Option(strText,strValue);
                  if (strValue == strSearchInterface) {
                     objInterface.options[i+1].selected = true;
                  }
               }
            }
            strSearchInterface = objInterface.options[objInterface.selectedIndex].value;
         } else {
            strSearchInterface = '';
         }
      }
      doActivityStop();
   }
   function updateBasicSearch() {
      var objBasicGrouping = document.getElementById('sltBasicGrouping');
      objBasicGrouping.selectedIndex = -1;
      for (var i=0;i<objBasicGrouping.options.length;i++) {
         if (objBasicGrouping.options[i].value == strSearchGrouping) {
            objBasicGrouping.options[i].selected = true;
         }
      }
      var objBasicInterface = document.getElementById('sltBasicInterface');
      var objAdvancedInterface = document.getElementById('sltAdvancedInterface');
      objBasicInterface.options.length = 0;
      objBasicInterface.selectedIndex = -1;
      for (var i=0;i<objAdvancedInterface.options.length;i++) {
         objBasicInterface.options[i] = new Option(objAdvancedInterface.options[i].text,objAdvancedInterface.options[i].value);
         if (objBasicInterface.options[i].value == strSearchInterface) {
            objBasicInterface.options[i].selected = true;
         }
      }
   }
   function retrieveAdvancedInterface() {
      doActivityStart(document.body);
      doGetRequest('<%=strBase%>ics_lookup.asp?Mode=GROUPING&QRY_Grouping='+strAdvancedGrouping,function(strResponse) {displayAdvancedInterface(strResponse);},true);
   }
   function displayAdvancedInterface(strResponse) {
      var strInterface = '';
      if (strResponse.substring(0,3) != '*OK') {
         strAdvancedInterface = '';
         alert(strResponse);
      } else {
         var objInterface = document.getElementById('sltAdvancedInterface');
         if (objInterface) {
            objInterface.options.length = 0;
            objInterface.selectedIndex = -1;
            objInterface.options[0] = new Option('*ALL','');
            objInterface.selectedIndex = 0;
            var aryReturn = strResponse.substring(3,strResponse.length).split('\n');
            for (var i=0;i<aryReturn.length;i++) {
               var intIdx = aryReturn[i].indexOf('\t');
               if (intIdx != -1) {
                  var strValue = aryReturn[i].substring(0,intIdx);
                  var strText = aryReturn[i].substring(intIdx+1,aryReturn[i].length);
                  objInterface.options[i+1] = new Option(strText,strValue);
                  if (strValue == strAdvancedInterface) {
                     objInterface.options[i+1].selected = true;
                     strInterface = strAdvancedInterface;
                  }
               }
            }
            strAdvancedInterface = objInterface.options[objInterface.selectedIndex].value;
         } else {
            strAdvancedInterface = '';
         }
      }
      retrieveAdvancedReference(strInterface);
   }
   function retrieveAdvancedReference(strInterface) {
      doActivityStart(document.body);
      doGetRequest('<%=strBase%>ics_lookup.asp?Mode=REFERENCE&QRY_Interface='+strInterface,function(strResponse) {displayAdvancedReference(strResponse);},true);
   }
   function displayAdvancedReference(strResponse) {
      resetAdvancedReference();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var objRowReference = document.getElementById('rowReference');
         var objTabReference = document.getElementById('tabReference');
         if (objRowReference) {
            var strText = '<table align=left border=0 cellpadding=0 cellspacing=2 cols=2>';
            if (strResponse.substring(3,strResponse.length).length == 0) {
               strText = strText + '<tr>';
               strText = strText + '<td class="clsLabelBB" align=left colspan=2 nowrap><nobr>&nbsp;</nobr></td>';
               strText = strText + '</tr>';
               objRowReference.style.display = 'none';
               objRowReference.style.visibility = 'hidden';
            } else {
               strText = strText + '<tr><td class="clsInner" align=left colspan=2 valign=center nowrap><nobr><font class="clsLabelWB">&nbsp;(AND) Interface Data Search - Inner Condition:&nbsp;';
               if (strAdvancedCondition == 'OR' || strAdvancedCondition == '' || strAdvancedCondition == null) {
                  strText = strText + '<input type="radio" name="sltAdvancedCondition" value="OR" checked onClick="javascript:selectAdvancedCondition(\'OR\');">OR&nbsp;';
                  strText = strText + '<input type="radio" name="sltAdvancedCondition" value="AND" onClick="javascript:selectAdvancedCondition(\'AND\');">AND&nbsp;';
               } else {
                  strText = strText + '<input type="radio" name="sltAdvancedCondition" value="OR" onClick="javascript:selectAdvancedCondition(\'OR\');">OR&nbsp;';
                  strText = strText + '<input type="radio" name="sltAdvancedCondition" value="AND" checked onClick="javascript:selectAdvancedCondition(\'AND\');">AND&nbsp;';
               }
               strText = strText + '</font></nobr></td></tr>';
               var aryReturn = strResponse.substring(3,strResponse.length).split('\n');
               for (var i=0;i<aryReturn.length;i++) {
                  if (aryReturn[i] != null && aryReturn[i] != '') {
                     var strValue = '';
                     var bolFound = false;
                     for (var j=0;j<objAdvancedReference.length;j++) {
                        if (aryReturn[i] == objAdvancedReference[j].key) {
                           bolFound = true;
                           objAdvancedReference[j].index = i;
                           strValue = objAdvancedReference[j].value;
                        }
                     }
                     if (bolFound == false) {
                        addAdvancedReference(aryReturn[i],'',i);
                     }
                     strText = strText + '<tr>';
                     strText = strText + '<td class="clsLabelBB" align=right colspan=1 valign=center nowrap><nobr>&nbsp;'+aryReturn[i]+':</nobr></td>';
                     strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="REF_'+i+'" size="64" maxlength="128" value="'+strValue+'" onFocus="setSelect(this);"></nobr></td>';
                     strText = strText + '</tr>';
                  }
               }
               objRowReference.style.display = 'block';
               objRowReference.style.visibility = 'visible';
            }
            strText = strText + '</table>';
            objTabReference.innerHTML = strText;
         }
      }
      doActivityStop();
   }
   function selectBasicGrouping(objSelect) {
      strSearchGrouping = objSelect.options[objSelect.selectedIndex].value;
      retrieveBasicInterface();
   }
   function selectBasicInterface(objSelect) {
      strSearchInterface = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectAdvancedGrouping(objSelect) {
      strAdvancedGrouping = objSelect.options[objSelect.selectedIndex].value;
      retrieveAdvancedInterface();
   }
   function selectAdvancedInterface(objSelect) {
      strAdvancedInterface = objSelect.options[objSelect.selectedIndex].value;
      retrieveAdvancedReference(strAdvancedInterface);
   }
   function selectAdvancedType(objSelect) {
      strAdvancedType = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectAdvancedProcess(objSelect) {
      strAdvancedProcess = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectAdvancedStatus(objSelect) {
      strAdvancedStatus = objSelect.options[objSelect.selectedIndex].value;
   }
   function selectAdvancedCondition(strValue) {
      strAdvancedCondition = strValue;
   }
   function selectAdvancedTest(strValue) {
      strAdvancedTest = strValue;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_child.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_timestamp.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<!--#include file="ics_std_cookie.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="no" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_int_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');setScrollable('HeadB','BodyB','horizontal');showPage();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table id="tabMonitor" style="display:block;visibility:hidden" class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0"><%if objForm.Fields().Item("QRY_Advanced") <> "1" then%>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Grouping:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltBasicGrouping" onChange="selectBasicGrouping(this);">
               <option value=""<%if objForm.Fields().Item("QRY_Grouping") = "" then%> selected<%end if%>>*ALL<%for i = 0 to clng(objSelection.ListCount("GROUPING")) - 1%>
               <option value="<%=objSelection.ListValue01("GROUPING",i)%>"<%if objForm.Fields().Item("QRY_Grouping") = objSelection.ListValue01("GROUPING",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("GROUPING",i)%>) <%=objSelection.ListValue02("GROUPING",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltBasicInterface" onChange="selectBasicInterface(this);">
               <option value=""<%if objForm.Fields().Item("QRY_Interface") = "" then%> selected<%end if%>>*ALL<%for i = 0 to clng(objSelection.ListCount("INTERFACE")) - 1%>
               <option value="<%=objSelection.ListValue01("INTERFACE",i)%>"<%if objForm.Fields().Item("QRY_Interface") = objSelection.ListValue01("INTERFACE",i) then%> selected<%end if%>>(<%=objSelection.ListValue01("INTERFACE",i)%>) <%=objSelection.ListValue02("INTERFACE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      </table></nobr></td></tr><%end if%>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=9 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doMonitor();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td><%if bolStrList = true then%>
                  <td align=center colspan=1 nowrap><nobr><font class="clsButtonD"><&nbsp;Prev&nbsp</font></nobr></td><%else%>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPrevious();"><&nbsp;Prev&nbsp</a></nobr></td><%end if%>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td><%if bolEndList = true then%>
                  <td align=center colspan=1 nowrap><nobr><font class="clsButtonD">&nbspNext&nbsp></font></nobr></td><%else%>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doNext();">&nbspNext&nbsp></a></nobr></td><%end if%>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td id="butAdvanced" align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:showAdvanced();">&nbsp;Advanced Filters (Off)&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:showBacklog();">&nbsp;Show Backlog&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=11 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Interface&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Trace&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Identifier&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Process&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Job&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;User&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Start Time&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;End Time&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Status&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align=left cols=10 cellpadding="0" cellspacing="1"><%if clng(objSelection.ListCount("LIST")) = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=8 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%><%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%for i = clng(objSelection.ListLower("LIST")) to clng(objSelection.ListUpper("LIST"))%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:processInterface('<%=objSelection.ListValue01("LIST",i)%>','<%=objSelection.ListValue02("LIST",i)%>');"><%=objSelection.ListValue01("LIST",i)%></a></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue08("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue09("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue10("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="<%=aryIntClass(objSelection.ListValue07("LIST",i))%>" align=left colspan=1 nowrap><nobr><%=aryIntStatus(objSelection.ListValue07("LIST",i))%></nobr></td>
                        </tr><%next%><%else%><%for i = clng(objSelection.ListUpper("LIST")) to clng(objSelection.ListLower("LIST")) step -1%>
                        <tr>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><a class="clsSelect" href="javascript:processInterface('<%=objSelection.ListValue01("LIST",i)%>','<%=objSelection.ListValue02("LIST",i)%>');"><%=objSelection.ListValue01("LIST",i)%></a></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue08("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue09("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue10("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("LIST",i)%></nobr></td>
                           <td class="<%=aryIntClass(objSelection.ListValue07("LIST",i))%>" align=left colspan=1 nowrap><nobr><%=aryIntStatus(objSelection.ListValue07("LIST",i))%></nobr></td>
                        </tr><%next%><%end if%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="tabAdvanced" style="display:block;visibility:hidden" class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>Advanced Search Filters</nobr></td>
      </tr>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Grouping:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltAdvancedGrouping" onChange="selectAdvancedGrouping(this);">
               <option value="">*ALL<%for i = 0 to clng(objSelection.ListCount("GROUPING")) - 1%>
               <option value="<%=objSelection.ListValue01("GROUPING",i)%>">(<%=objSelection.ListValue01("GROUPING",i)%>) <%=objSelection.ListValue02("GROUPING",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Identifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltAdvancedInterface" onChange="selectAdvancedInterface(this);">
               <option value="">*ALL<%for i = 0 to clng(objSelection.ListCount("INTERFACE")) - 1%>
               <option value="<%=objSelection.ListValue01("INTERFACE",i)%>">(<%=objSelection.ListValue01("INTERFACE",i)%>) <%=objSelection.ListValue02("INTERFACE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr id="rowReference" style="display:none;visibility:hidden">
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsLabelBB" id="tabReference" align=left colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltAdvancedType" onChange="selectAdvancedType(this);">
               <option value="">*ALL<%for i = 0 to clng(objSelection.ListCount("TYPE")) - 1%>
               <option value="<%=objSelection.ListValue01("TYPE",i)%>"><%=objSelection.ListValue01("TYPE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Process:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltAdvancedProcess" onChange="selectAdvancedProcess(this);">
               <option value="">*ALL<%for i = 0 to clng(objSelection.ListCount("PROCESS")) - 1%>
               <option value="<%=objSelection.ListValue01("PROCESS",i)%>"><%=objSelection.ListValue01("PROCESS",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_Header" size="15" maxlength="15" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
            <input type="radio" name="sltAdvancedTest" value="EQ" onClick="javascript:selectAdvancedTest('EQ');">EQ&nbsp;
            <input type="radio" name="sltAdvancedTest" value="LE" onClick="javascript:selectAdvancedTest('LE');">LE&nbsp;
            <input type="radio" name="sltAdvancedTest" value="GE" onClick="javascript:selectAdvancedTest('GE');">GE&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Start Time (YYYYMMDDHHMISS):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_StrTime" size="14" maxlength="14" value="" onFocus="setSelect(this);" onBlur="validateTimestamp(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface End Time (YYYYMMDDHHMISS):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_EndTime" size="14" maxlength="14" value="" onFocus="setSelect(this);" onBlur="validateTimestamp(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltAdvancedStatus" onChange="selectAdvancedStatus(this);">
               <option value="">*ALL
               <option value="1">Load working
               <option value="2">Load working (errors)
               <option value="3">Load completed
               <option value="4">Load completed (errors)
               <option value="5">Process working
               <option value="6">Process working (errors)
               <option value="7">Process completed
               <option value="8">Process completed (errors)
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SLT_Execution" size="15" maxlength="15" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=5 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:cancelAdvanced();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:removeAdvanced();">&nbsp;Remove&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doAdvanced();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="tabBacklog" style="display:block;visibility:hidden" class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doBacklog();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:showMonitor();">&nbsp;Show Monitor&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHeadB">
                     <table class="clsTableHead" id="tabHeadB" align=left cols=6 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Identifer&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Description&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Process&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Backlog&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
                        </tr>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBodyB">
                     <table class="clsTableBody" id="tabBodyB" align=left cols=5 cellpadding="0" cellspacing="1"><%if clng(objSelection.ListCount("BACKLOG")) = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=5 nowrap><nobr>&nbsp;NO BACKLOG FOUND&nbsp</nobr></td></tr><%else%><%for i = clng(objSelection.ListLower("BACKLOG")) to clng(objSelection.ListUpper("BACKLOG"))%>
                        <tr>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue01("BACKLOG",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue02("BACKLOG",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue03("BACKLOG",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue04("BACKLOG",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr><%=objSelection.ListValue05("BACKLOG",i)%></nobr></td>
                        </tr><%next%><%end if%>
                     </table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields().Item("Mode")%>">
   <input type="hidden" name="Page" value="<%=objForm.Fields().Item("Page")%>">
   <input type="hidden" name="STR_Header" value="<%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%=objSelection.ListValue01("LIST",objSelection.ListLower("LIST"))%><%else%><%=objSelection.ListValue01("LIST",objSelection.ListUpper("LIST"))%><%end if%>">
   <input type="hidden" name="END_Header" value="<%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%=objSelection.ListValue01("LIST",objSelection.ListUpper("LIST"))%><%else%><%=objSelection.ListValue01("LIST",objSelection.ListLower("LIST"))%><%end if%>">
   <input type="hidden" name="STR_Trace" value="<%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%=objSelection.ListValue02("LIST",objSelection.ListLower("LIST"))%><%else%><%=objSelection.ListValue02("LIST",objSelection.ListUpper("LIST"))%><%end if%>">
   <input type="hidden" name="END_Trace" value="<%if objForm.Fields().Item("Mode") <> "PREVIOUS" then%><%=objSelection.ListValue02("LIST",objSelection.ListUpper("LIST"))%><%else%><%=objSelection.ListValue02("LIST",objSelection.ListLower("LIST"))%><%end if%>">
   <input type="hidden" name="QRY_Grouping" value="<%=objForm.Fields().Item("QRY_Grouping")%>">
   <input type="hidden" name="QRY_Interface" value="<%=objForm.Fields().Item("QRY_Interface")%>">
   <input type="hidden" name="QRY_Condition" value="<%=objForm.Fields().Item("QRY_Condition")%>">
   <input type="hidden" name="QRY_Reference" value="<%=objForm.Fields().Item("QRY_Reference")%>">
   <input type="hidden" name="QRY_Type" value="<%=objForm.Fields().Item("QRY_Type")%>">
   <input type="hidden" name="QRY_Process" value="<%=objForm.Fields().Item("QRY_Process")%>">
   <input type="hidden" name="QRY_Header" value="<%=objForm.Fields().Item("QRY_Header")%>">
   <input type="hidden" name="QRY_Test" value="<%=objForm.Fields().Item("QRY_Test")%>">
   <input type="hidden" name="QRY_StrTime" value="<%=objForm.Fields().Item("QRY_StrTime")%>">
   <input type="hidden" name="QRY_EndTime" value="<%=objForm.Fields().Item("QRY_EndTime")%>">
   <input type="hidden" name="QRY_Status" value="<%=objForm.Fields().Item("QRY_Status")%>">
   <input type="hidden" name="QRY_Execution" value="<%=objForm.Fields().Item("QRY_Execution")%>">
   <input type="hidden" name="QRY_Advanced" value="<%=objForm.Fields().Item("QRY_Advanced")%>">
</form>
</body>
</html>