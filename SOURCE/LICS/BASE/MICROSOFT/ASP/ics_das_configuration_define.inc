<html>
<script language="javascript">
<!--
   function showError() {<%if objForm.Fields("DTA_DasAction").Value = "*CREATE" then%>
      document.main.INP_DasSystem.focus();<%else%>
      document.main.INP_DasDescription.focus();<%end if%><%if strReturn <> "*OK" then%>
      alert('<%=strReturn%>');<%else%>return;<%end if%>
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
      var strDetail = '';<%if objForm.Fields("DTA_DasAction").Value = "*CREATE" then%>
      if (document.main.INP_DasSystem.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Data store code must be entered';
      }<%end if%>
      if (document.main.INP_DasDescription.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Data store description must be entered';
      }
      strDetail = checkStore();
      if (strDetail != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strDetail;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }<%if objForm.Fields("DTA_DasAction").Value = "*CREATE" then%>
      document.main.DTA_DasSystem.value = document.main.INP_DasSystem.value;<%end if%>
      document.main.DTA_DasDescription.value = document.main.INP_DasDescription.value;
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'DEFINE_ACCEPT';
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
   // Store definition script //
   //////////////////////////////
   var cobjStore = new Array();
   var cobjImage = new Array();
   var cobjTarget = null;
   var cintTargetS = 0;
   var cintTargetE = 0;
   var cintTargetW = -1;
   var cintMode = null;
   cobjImage[0] = new Image();
   cobjImage[1] = new Image();
   cobjImage[2] = new Image();
   cobjImage[3] = new Image();
   cobjImage[4] = new Image();
   cobjImage[5] = new Image();
   cobjImage[6] = new Image();
   cobjImage[7] = new Image();
   cobjImage[8] = new Image();
   cobjImage[0].src = 'tree_nbsp.gif';
   cobjImage[1].src = 'tree_01.gif';
   cobjImage[2].src = 'tree_02.gif';
   cobjImage[3].src = 'tree_03.gif';
   cobjImage[4].src = 'tree_str.gif';
   cobjImage[5].src = 'tree_tsk.gif';
   cobjImage[6].src = 'tree_evt.gif';
   cobjImage[7].src = 'tree_boks.gif';
   cobjImage[8].src = 'tree_boko.gif';
   function loadStore() {<%if objSelection.ListCount("NODES") = 0 then%>
      cobjStore[0] = new clsStore('0','S','','','Data Store Root','','','');<%else%><%for i = objSelection.ListLower("NODES") to objSelection.ListUpper("NODES")%>
      cobjStore[<%=i%>] = new clsStore('<%=objSelection.ListValue01("NODES",i)%>','<%=objSelection.ListValue02("NODES",i)%>','<%=objSelection.ListValue03("NODES",i)%>','<%=objSelection.ListValue04("NODES",i)%>','<%=replace(objSelection.ListValue05("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue05("NODES",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue07("NODES",i)%>','<%=objSelection.ListValue08("NODES",i)%>');<%next%><%end if%>
      paintStore();
   }
   function clsStore(strDepth,strNode,strGroup,strCode,strText,strValue,strType,strData) {
      this.strdep = strDepth;
      this.strnod = strNode;
      this.strgrp = strGroup;
      this.strcod = strCode;
      this.strtxt = strText;
      this.strval = strValue;
      this.strvat = strType;
      this.strvad = strData;
      this.strlvl = '';
   }
   function paintStore() {
     var objDepth = new Array();
      for (var i=cobjStore.length-1;i>=0;i--) {
         for (var j=objDepth.length;j<=(cobjStore[i].strdep-0);j++) {
            objDepth[j] = '0';
         }
         for (var j=(cobjStore[i].strdep-0)+1;j<objDepth.length;j++) {
            objDepth[j] = '0';
         }
         cobjStore[i].strlvl = '';
         for (var j=1;j<(cobjStore[i].strdep-0);j++) {
            if (objDepth[j] == '1') {
               cobjStore[i].strlvl = cobjStore[i].strlvl + '3';
            } else {
               cobjStore[i].strlvl = cobjStore[i].strlvl + 'B';
            }
         }
         if (cobjStore[i].strdep != '0') {
            if (objDepth[(cobjStore[i].strdep-0)] == '1') {
               cobjStore[i].strlvl = cobjStore[i].strlvl + '2';
            } else {
               cobjStore[i].strlvl = cobjStore[i].strlvl + '1';
            }
         }
         cobjStore[i].strlvl = cobjStore[i].strlvl + cobjStore[i].strnod;
         objDepth[(cobjStore[i].strdep-0)] = '1';
      }
      var objTable = document.getElementById('tabStore');
      var objRow = null;
      var objCell = null;
      var objImage = null;
      var objTarget = null;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      for (var i=0;i<cobjStore.length;i++) {
         objRow = objTable.insertRow(i);
         objRow.height = '19';
         objCell = objRow.insertCell(0);
         objCell.colSpan = 1;
         objCell.style.whiteSpace = 'nowrap';
         if (cobjStore[i].strnod == 'S') {
            objCell.className = 'clsLabelBB';
         } else if (cobjStore[i].strnod == 'G') {
            objCell.className = 'clsTreeBB';
         } else if (cobjStore[i].strnod == 'C') {
            objCell.className = 'clsTreeBN';
         } else if (cobjStore[i].strnod == 'V') {
            objCell.className = 'clsTreeBN';
         }
         objCell.align = 'left';
         for (var j=0;j<cobjStore[i].strlvl.length;j++) {
            if (cobjStore[i].strlvl.substring(j,j+1) == 'S') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[4].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
               objImage = document.createElement('img');
               objImage.src = cobjImage[7].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objImage.onclick = function() {targetStore(this,event);};
               if (cintTargetW == i) {
                  objTarget = objImage;
               }
               objCell.appendChild(objImage);
            } else if (cobjStore[i].strlvl.substring(j,j+1) == 'G') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[5].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
               objImage = document.createElement('img');
               objImage.src = cobjImage[7].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objImage.onclick = function() {targetStore(this,event);};
               if (cintTargetW == i) {
                  objTarget = objImage;
               }
               objCell.appendChild(objImage);
            } else if (cobjStore[i].strlvl.substring(j,j+1) == 'C') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[6].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
               objImage = document.createElement('img');
               objImage.src = cobjImage[7].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objImage.onclick = function() {targetStore(this,event);};
               if (cintTargetW == i) {
                  objTarget = objImage;
               }
               objCell.appendChild(objImage);
            } else if (cobjStore[i].strlvl.substring(j,j+1) == 'V') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[7].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objImage.onclick = function() {targetStore(this,event);};
               if (cintTargetW == i) {
                  objTarget = objImage;
               }
               objCell.appendChild(objImage);
            } else if (cobjStore[i].strlvl.substring(j,j+1) == 'B') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[0].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
            } else if (cobjStore[i].strlvl.substring(j,j+1) == '1') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[1].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
            } else if (cobjStore[i].strlvl.substring(j,j+1) == '2') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[2].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
            } else if (cobjStore[i].strlvl.substring(j,j+1) == '3') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[3].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
            }
         }
         if (cobjStore[i].strnod == 'S') {
            objCell.appendChild(document.createTextNode(' '+cobjStore[i].strtxt));
         } else if (cobjStore[i].strnod == 'G') {
            objCell.appendChild(document.createTextNode(' ('+cobjStore[i].strcod+') '+cobjStore[i].strtxt));
         } else if (cobjStore[i].strnod == 'C') {
            objCell.appendChild(document.createTextNode(' ('+cobjStore[i].strcod+') '+cobjStore[i].strtxt+' - Type('+cobjStream[i].strvat+') Data('+cobjStream[i].strvad+')'));
         } else if (cobjStore[i].strnod == 'V') {
            objCell.appendChild(document.createTextNode(' '+cobjStore[i].strval));
         }
      }
      cobjTarget = null;
      cintTargetS = 0;
      cintTargetE = 0;
      cintTargetW = -1;
      if (objTarget != null) {
         targetStore(objTarget,null);
      }
   }
   function targetStore(objTarget,objEvent) {
      if (objEvent != null) {
         objEvent.cancelBubble = true;
      }
      var intWorkS = objTarget.parentNode.parentNode.rowIndex;
      var intWorkE = intWorkS;
      for (var i=intWorkS+1;i<cobjStore.length;i++) {
         if (cobjStore[i].strpar != cobjStore[intWorkS].strcod || cobjStore[i].strnod != 'E') {
            break;
         }
         intWorkE = i;
      }
      if (cobjTarget) {
         cobjTarget.src = cobjImage[7].src;
      }
      cobjTarget = objTarget;
      cobjTarget.src = cobjImage[8].src;
      cintTargetS = intWorkS;
      cintTargetE = intWorkE;
      cintTargetW = intWorkS;
   }
   function cancelStore() {
      var objDspStore = document.getElementById('dspStore');
      var objDspGroup = document.getElementById('dspGroup');
      var objInpGroup = document.getElementById('inpGroup');
      var objEnqGroup = document.getElementById('enqGroup');
      var objDspCode = document.getElementById('dspCode');
      var objInpCode = document.getElementById('inpCode');
      var objEnqCode = document.getElementById('enqCode');
      var objDspValue = document.getElementById('dspValue');
      var objInpValue = document.getElementById('inpValue');
      var objEnqValue = document.getElementById('enqValue');
      objDspStore.style.display = 'block';
      objDspStore.style.visibility = 'visible';
      objDspGroup.style.display = 'none';
      objDspGroup.style.visibility = 'hidden';
      objInpGroup.style.display = 'none';
      objInpGroup.style.visibility = 'hidden';
      objEnqGroup.style.display = 'none';
      objEnqGroup.style.visibility = 'hidden';
      objDspCode.style.display = 'none';
      objDspCode.style.visibility = 'hidden';
      objInpCode.style.display = 'none';
      objInpCode.style.visibility = 'hidden';
      objEnqCode.style.display = 'none';
      objEnqCode.style.visibility = 'hidden';
      objDspValue.style.display = 'none';
      objDspValue.style.visibility = 'hidden';
      objInpValue.style.display = 'none';
      objInpValue.style.visibility = 'hidden';
      objEnqValue.style.display = 'none';
      objEnqValue.style.visibility = 'hidden';
   }
   function updateStore() {
      if (cobjTarget == null) {
         alert('Target must be selected');
         return;
      }
      if (cobjStore[cintTargetS].strnod == 'S') {
         alert('Target must be group, code or value for update');
         return;
      }
      cintMode = 'U';
      var objDspStore = document.getElementById('dspStore');
      var objDspGroup = document.getElementById('dspGroup');
      var objInpGroup = document.getElementById('inpGroup');
      var objEnqGroup = document.getElementById('enqGroup');
      var objDspCode = document.getElementById('dspCode');
      var objInpCode = document.getElementById('inpCode');
      var objEnqCode = document.getElementById('enqCode');
      var objDspValue = document.getElementById('dspValue');
      var objInpValue = document.getElementById('inpValue');
      var objEnqValue = document.getElementById('enqValue');
      if (cobjStore[cintTargetS].strnod == 'G') {
         objDspStore.style.display = 'none';
         objDspStore.style.visibility = 'hidden';
         objDspGroup.style.display = 'block';
         objDspGroup.style.visibility = 'visible';
         objInpGroup.style.display = 'block';
         objInpGroup.style.visibility = 'visible';
         objEnqGroup.style.display = 'none';
         objEnqGroup.style.visibility = 'hidden';
         objDspCode.style.display = 'none';
         objDspCode.style.visibility = 'hidden';
         objInpCode.style.display = 'none';
         objInpCode.style.visibility = 'hidden';
         objEnqCode.style.display = 'none';
         objEnqCode.style.visibility = 'hidden';
         objDspValue.style.display = 'none';
         objDspValue.style.visibility = 'hidden';
         objInpValue.style.display = 'none';
         objInpValue.style.visibility = 'hidden';
         objEnqValue.style.display = 'none';
         objEnqValue.style.visibility = 'hidden';
         document.getElementById('hedGroup').innerText = 'Update Group';
         document.getElementById('INP_GrpCode').value = cobjStore[cintTargetS].strcod;
         document.getElementById('INP_GrpText').value = cobjStore[cintTargetS].strtxt;
         document.getElementById('INP_GrpText').focus();
      } else if (cobjStore[cintTargetS].strnod == 'C') {
         objDspStore.style.display = 'none';
         objDspStore.style.visibility = 'hidden';
         objDspGroup.style.display = 'none';
         objDspGroup.style.visibility = 'hidden';
         objInpGroup.style.display = 'none';
         objInpGroup.style.visibility = 'hidden';
         objEnqGroup.style.display = 'none';
         objEnqGroup.style.visibility = 'hidden';
         objDspCode.style.display = 'block';
         objDspCode.style.visibility = 'visible';
         objInpCode.style.display = 'block';
         objInpCode.style.visibility = 'visible';
         objEnqCode.style.display = 'none';
         objEnqCode.style.visibility = 'hidden';
         objDspValue.style.display = 'none';
         objDspValue.style.visibility = 'hidden';
         objInpValue.style.display = 'none';
         objInpValue.style.visibility = 'hidden';
         objEnqValue.style.display = 'none';
         objEnqValue.style.visibility = 'hidden';
         document.getElementById('hedCode').innerText = 'Update Code';
         document.getElementById('INP_CdeCode').value = cobjStore[cintTargetS].strcod;
         document.getElementById('INP_CdeText').value = cobjStore[cintTargetS].strtxt;
         document.getElementById('INP_CdeVat').selectedIndex = -1;
         document.getElementById('INP_CdeVad').selectedIndex = -1;
         var objObject = document.getElementById('INP_CdeVat');
         for (var i=0;i<objObject.length;i++) {
            if (objObject.options[i].value == cobjStore[cintTargetS].strvat) {
               objObject.selectedIndex = i;
               break;
            }
         }
         objObject = document.getElementById('INP_CdeVad');
         for (var i=0;i<objObject.length;i++) {
            if (objObject.options[i].value == cobjStore[cintTargetS].strvad) {
               objObject.selectedIndex = i;
               break;
            }
         }
         document.getElementById('INP_CdeText').focus();
      } else {
         objDspStore.style.display = 'none';
         objDspStore.style.visibility = 'hidden';
         objDspGroup.style.display = 'none';
         objDspGroup.style.visibility = 'hidden';
         objInpGroup.style.display = 'none';
         objInpGroup.style.visibility = 'hidden';
         objEnqGroup.style.display = 'none';
         objEnqGroup.style.visibility = 'hidden';
         objDspCode.style.display = 'none';
         objDspCode.style.visibility = 'hidden';
         objInpCode.style.display = 'none';
         objInpCode.style.visibility = 'hidden';
         objEnqCode.style.display = 'none';
         objEnqCode.style.visibility = 'hidden';
         objDspValue.style.display = 'block';
         objDspValue.style.visibility = 'visible';
         objInpValue.style.display = 'block';
         objInpValue.style.visibility = 'visible';
         objEnqValue.style.display = 'none';
         objEnqValue.style.visibility = 'hidden';
         document.getElementById('hedValue').innerText = 'Update Value';
         document.getElementById('INP_CdeValue').value = cobjStore[cintTargetS].strval;
         document.getElementById('INP_CdeValue').focus();
      }
   }
   function deleteStore() {
      if (cobjTarget == null) {
         alert('Target must be selected');
         return;
      }
      if (cobjStore[cintTargetS].strnod == 'S') {
         alert('Target must be group, code or value for delete');
         return;
      }
      cintMode = 'D';
      var objDspStore = document.getElementById('dspStore');
      var objDspGroup = document.getElementById('dspGroup');
      var objInpGroup = document.getElementById('inpGroup');
      var objEnqGroup = document.getElementById('enqGroup');
      var objDspCode = document.getElementById('dspCode');
      var objInpCode = document.getElementById('inpCode');
      var objEnqCode = document.getElementById('enqCode');
      var objDspValue = document.getElementById('dspValue');
      var objInpValue = document.getElementById('inpValue');
      var objEnqValue = document.getElementById('enqValue');
      if (cobjStore[cintTargetS].strnod == 'G') {
         objDspStore.style.display = 'none';
         objDspStore.style.visibility = 'hidden';
         objDspGroup.style.display = 'block';
         objDspGroup.style.visibility = 'visible';
         objInpGroup.style.display = 'none';
         objInpGroup.style.visibility = 'hidden';
         objEnqGroup.style.display = 'block';
         objEnqGroup.style.visibility = 'visible';
         objDspCode.style.display = 'none';
         objDspCode.style.visibility = 'hidden';
         objInpCode.style.display = 'none';
         objInpCode.style.visibility = 'hidden';
         objEnqCode.style.display = 'none';
         objEnqCode.style.visibility = 'hidden';
         objDspValue.style.display = 'none';
         objDspValue.style.visibility = 'hidden';
         objInpValue.style.display = 'none';
         objInpValue.style.visibility = 'hidden';
         objEnqValue.style.display = 'none';
         objEnqValue.style.visibility = 'hidden';
         document.getElementById('hedGroup').innerText = 'Delete Group';
         document.getElementById('ENQ_GrpCode').innerText = ' '+cobjStore[cintTargetS].strcod;
         document.getElementById('ENQ_GrpText').innerText = ' '+cobjStore[cintTargetS].strtxt;
      } else if (cobjStore[cintTargetS].strnod == 'C') {
         objDspStore.style.display = 'none';
         objDspStore.style.visibility = 'hidden';
         objDspGroup.style.display = 'none';
         objDspGroup.style.visibility = 'hidden';
         objInpGroup.style.display = 'none';
         objInpGroup.style.visibility = 'hidden';
         objEnqGroup.style.display = 'none';
         objEnqGroup.style.visibility = 'hidden';
         objDspCode.style.display = 'block';
         objDspCode.style.visibility = 'visible';
         objInpCode.style.display = 'none';
         objInpCode.style.visibility = 'hidden';
         objEnqCode.style.display = 'block';
         objEnqCode.style.visibility = 'visible';
         objDspValue.style.display = 'none';
         objDspValue.style.visibility = 'hidden';
         objInpValue.style.display = 'none';
         objInpValue.style.visibility = 'hidden';
         objEnqValue.style.display = 'none';
         objEnqValue.style.visibility = 'hidden';
         document.getElementById('hedCode').innerText = 'Delete Code';
         document.getElementById('ENQ_CdeCode').value = cobjStore[cintTargetS].strcod;
         document.getElementById('ENQ_CdeText').value = cobjStore[cintTargetS].strtxt;
         document.getElementById('ENQ_CdeValType').value = cobjStore[cintTargetS].strvat;
         document.getElementById('ENQ_CdeValData').value = cobjStore[cintTargetS].strvad;
      } else {
         objDspStore.style.display = 'none';
         objDspStore.style.visibility = 'hidden';
         objDspGroup.style.display = 'none';
         objDspGroup.style.visibility = 'hidden';
         objInpGroup.style.display = 'none';
         objInpGroup.style.visibility = 'hidden';
         objEnqGroup.style.display = 'none';
         objEnqGroup.style.visibility = 'hidden';
         objDspCode.style.display = 'none';
         objDspCode.style.visibility = 'hidden';
         objInpCode.style.display = 'none';
         objInpCode.style.visibility = 'hidden';
         objEnqCode.style.display = 'none';
         objEnqCode.style.visibility = 'hidden';
         objDspValue.style.display = 'block';
         objDspValue.style.visibility = 'visible';
         objInpValue.style.display = 'none';
         objInpValue.style.visibility = 'hidden';
         objEnqValue.style.display = 'block';
         objEnqValue.style.visibility = 'visible';
         document.getElementById('hedValue').innerText = 'Delete Value';
         document.getElementById('ENQ_CdeValue').innerText = ' '+cobjStore[cintTargetS].strval;
      }
   }
   function addGroup() {
      if (cobjTarget == null) {
         alert('Target must be selected');
         return;
      }
      if (cobjStore[cintTargetS].strnod != 'S') {
         alert('Target must be store for a new group');
         return;
      }
      cintMode = 'A';
      var objDspStore = document.getElementById('dspStore');
      var objDspGroup = document.getElementById('dspGroup');
      var objInpGroup = document.getElementById('inpGroup');
      var objEnqGroup = document.getElementById('enqGroup');
      var objDspCode = document.getElementById('dspCode');
      var objInpCode = document.getElementById('inpCode');
      var objEnqCode = document.getElementById('enqCode');
      var objDspValue = document.getElementById('dspValue');
      var objInpValue = document.getElementById('inpValue');
      var objEnqValue = document.getElementById('enqValue');
      objDspStore.style.display = 'none';
      objDspStore.style.visibility = 'hidden';
      objDspGroup.style.display = 'block';
      objDspGroup.style.visibility = 'visible';
      objInpGroup.style.display = 'block';
      objInpGroup.style.visibility = 'visible';
      objEnqGroup.style.display = 'none';
      objEnqGroup.style.visibility = 'hidden';
      objDspCode.style.display = 'none';
      objDspCode.style.visibility = 'hidden';
      objInpCode.style.display = 'none';
      objInpCode.style.visibility = 'hidden';
      objEnqCode.style.display = 'none';
      objEnqCode.style.visibility = 'hidden';
      objDspValue.style.display = 'none';
      objDspValue.style.visibility = 'hidden';
      objInpValue.style.display = 'none';
      objInpValue.style.visibility = 'hidden';
      objEnqValue.style.display = 'none';
      objEnqValue.style.visibility = 'hidden';
      document.getElementById('hedGroup').innerText = 'Create Group';
      document.getElementById('INP_GrpCode').value = '';
      document.getElementById('INP_GrpText').value = '';
      document.getElementById('INP_GrpCode').focus();
   }
   function acceptGroup() {
      if (!processForm()) {return;}
      var strGrpCode;
      var strGrpText;
      var bolFound = false;
      var strMessage = '';
      if (cintMode == 'A' || cintMode == 'U') {
         strGrpCode = document.getElementById('INP_GrpCode').value.toUpperCase();
         strGrpText = document.getElementById('INP_GrpText').value;
         if (strGrpCode == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Data store group must be entered';
         }
         if (strGrpText == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Group description must be entered';
         }
         bolFound = false;
         for (var i=0;i<cobjStore.length;i++) {
            if ((cintMode == 'A' || (cintMode == 'U' && i != cintTargetS)) &&
                cobjStore[i].strnod == 'G' &&
                cobjStore[i].strcod.toUpperCase() == strGrpCode) {
               bolFound = true;
               break;
            }
         }
         if (bolFound == true) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Data store group already exists in the data store';
         }
         if (strMessage != '') {
            alert(strMessage);
            return;
         }
      }
      var objYarra = new Array();
      if (cintMode == 'A') {
         var intInsert = 1;
         for (var i=0;i<cobjStore.length;i++) {
            if (cobjStore[i].strnod == 'G' &&
                cobjStore[i].strgrp > strGrpCode) {
               intInsert = i;
               break;
            }
         }
         var j = 0;
         for (var i=0;i<intInsert;i++) {
            objYarra[j] = cobjStore[i];
            j++;
         }
         objYarra[j] = new clsStore('1','G','*ROOT',strGrpCode,'',strGrpText,'','','');
         j++;
         for (var i=intInsert;i<cobjStore.length;i++) {
            objYarra[j] = cobjStore[i];
            j++;
         }
         cobjStore.length = 0;
         for (i=0;i<objYarra.length;i++) {
            cobjStore[i] = objYarra[i];
         }
      } else if (cintMode == 'U') {
////sorting
         for (var i=0;i<cobjStore.length;i++) {
            if (cobjStore[i].strgrp.toUpperCase() == cobjStore[cintTargetS].strgrp.toUpperCase()) {
               cobjStore[i].strgrp = strGrpCode;
            }
         }
         cobjStore[cintTargetS].strgrp = strGrpCode;
         cobjStore[cintTargetS].strtxt = strGrpText;
      } else if (cintMode == 'D') {
         var strGroup = cobjStore[cintTargetS].strgrp.toUpperCase();
         var objYarra = new Array();
         var j = 0;
         for (var i=0;i<cobjStore.length;i++) {
            if (cobjStore[i].strgrp.toUpperCase() != strGroup) {
               objYarra[j] = cobjStore[i];
               j++;
            }
         }
         cobjStore.length = 0;
         for (i=0;i<objYarra.length;i++) {
            cobjStore[i] = objYarra[i];
         }
         cintTargetW = -1;
      }
      paintStore();
      var objDspStore = document.getElementById('dspStore');
      var objDspGroup = document.getElementById('dspGroup');
      var objInpGroup = document.getElementById('inpGroup');
      var objEnqGroup = document.getElementById('enqGroup');
      var objDspCode = document.getElementById('dspCode');
      var objInpCode = document.getElementById('inpCode');
      var objEnqCode = document.getElementById('enqCode');
      var objDspValue = document.getElementById('dspValue');
      var objInpValue = document.getElementById('inpValue');
      var objEnqValue = document.getElementById('enqValue');
      objDspStore.style.display = 'block';
      objDspStore.style.visibility = 'visible';
      objDspGroup.style.display = 'none';
      objDspGroup.style.visibility = 'hidden';
      objInpGroup.style.display = 'none';
      objInpGroup.style.visibility = 'hidden';
      objEnqGroup.style.display = 'none';
      objEnqGroup.style.visibility = 'hidden';
      objDspCode.style.display = 'none';
      objDspCode.style.visibility = 'hidden';
      objInpCode.style.display = 'none';
      objInpCode.style.visibility = 'hidden';
      objEnqCode.style.display = 'none';
      objEnqCode.style.visibility = 'hidden';
      objDspValue.style.display = 'none';
      objDspValue.style.visibility = 'hidden';
      objInpValue.style.display = 'none';
      objInpValue.style.visibility = 'hidden';
      objEnqValue.style.display = 'none';
      objEnqValue.style.visibility = 'hidden';
   }
   function addCode() {
      if (cobjTarget == null) {
         alert('Target must be selected');
         return;
      }
      if (cobjStore[cintTargetS].strnod != 'G') {
         alert('Target must be group for a new code');
         return;
      }
      cintMode = 'A';
      var objDspStore = document.getElementById('dspStore');
      var objDspGroup = document.getElementById('dspGroup');
      var objInpGroup = document.getElementById('inpGroup');
      var objEnqGroup = document.getElementById('enqGroup');
      var objDspCode = document.getElementById('dspCode');
      var objInpCode = document.getElementById('inpCode');
      var objEnqCode = document.getElementById('enqCode');
      var objDspValue = document.getElementById('dspValue');
      var objInpValue = document.getElementById('inpValue');
      var objEnqValue = document.getElementById('enqValue');
      objDspStore.style.display = 'none';
      objDspStore.style.visibility = 'hidden';
      objDspGroup.style.display = 'none';
      objDspGroup.style.visibility = 'hidden';
      objInpGroup.style.display = 'none';
      objInpGroup.style.visibility = 'hidden';
      objEnqGroup.style.display = 'none';
      objEnqGroup.style.visibility = 'hidden';
      objDspCode.style.display = 'block';
      objDspCode.style.visibility = 'visible';
      objInpCode.style.display = 'block';
      objInpCode.style.visibility = 'visible';
      objEnqCode.style.display = 'none';
      objEnqCode.style.visibility = 'hidden';
      objDspValue.style.display = 'none';
      objDspValue.style.visibility = 'hidden';
      objInpValue.style.display = 'none';
      objInpValue.style.visibility = 'hidden';
      objEnqValue.style.display = 'none';
      objEnqValue.style.visibility = 'hidden';
      document.getElementById('hedCode').innerText = 'Create Code';
      document.getElementById('INP_CdeCode').value = '';
      document.getElementById('INP_CdeText').value = '';
      document.getElementById('INP_CdeVat').selectedIndex = 0;
      document.getElementById('INP_CdeVad').selectedIndex = 0;
      document.getElementById('INP_CdeCode').focus();
   }
   function acceptCode() {
      if (!processForm()) {return;}
      var strCdeCode;
      var strCdeText;
      var strCdeVat;
      var strCdeVad;
      var objObject;
      var bolFound = false;
      var intCount = 0;
      var strMessage = '';
      if (cintMode == 'A' || cintMode == 'U') {
         strCdeCode = document.getElementById('INP_CdeCode').value.toUpperCase();
         strCdeText = document.getElementById('INP_CdeText').value;
         objObject = document.getElementById('INP_CdeVat');
         for (var i=0;i<objObject.length;i++) {
            if (objObject.options[i].selected == true) {
               strCdeVat = objObject.options[i].value.toUpperCase();
            }
         }
         objObject = document.getElementById('INP_CdeVad');
         for (var i=0;i<objObject.length;i++) {
            if (objObject.options[i].selected == true) {
               strCdeVad = objObject.options[i].value.toUpperCase();
            }
         }
         if (strCdeCode == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Data store code must be entered';
         }
         if (strCdeText == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Code description must be entered';
         }
         if (strCdeVat == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Code value type must be entered';
         }
         if (strCdeVad == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Code value data must be entered';
         }
         bolFound = false;
         for (var i=0;i<cobjStore.length;i++) {
            if (cintMode == 'A' &&
                cobjStore[i].strnod == 'C' &&
                cobjStore[i].strgrp.toUpperCase() == cobjStore[cintTargetS].strgrp.toUpperCase() &&
                cobjStore[i].strcod.toUpperCase() == strCdeCode) {
               bolFound = true;
               break;
            }
            if (cintMode == 'U' &&
                i != cintTargetS &&
                cobjStore[i].strnod == 'C' &&
                cobjStore[i].strgrp.toUpperCase() == cobjStore[cintTargetS].strgrp.toUpperCase() &&
                cobjStore[i].strcod.toUpperCase() == strCdeCode) {
               bolFound = true;
               break;
            }
         }
         if (bolFound == true) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Data store code already exists in the group';
         }
         if (cintMode == 'U' && strCdeVat == '*SINGLE') {
            intCount = 0;
            for (var i=0;i<cobjStore.length;i++) {
               if (cobjStore[i].strnod == 'V' &&
                   cobjStore[i].strgrp.toUpperCase() == cobjStore[cintTargetS].strgrp.toUpperCase() &&
                   cobjStore[i].strcod.toUpperCase() == cobjStore[cintTargetS].strcod.toUpperCase()) {
                  intCount++;
                  break;
               }
            }
            if (intCount > 1) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Data store code type *SINGLE has more than one value';
            }
         }
         if (strMessage != '') {
            alert(strMessage);
            return;
         }
      }
      var objYarra = new Array();
      if (cintMode == 'A') {
         var intInsert = cintTargetS+1;
         for (var i=cintTargetS;i<cobjStore.length;i++) {
            if (cobjStore[i].strnod == 'C' &&
                cobjStore[i].strgrp.toUpperCase() == cobjStore[cintTargetS].strgrp.toUpperCase() &&
                cobjStore[i].strcod.toUpperCase() > strCdeCode) {
               intInsert = i;
               break;
            }
         }
         var j = 0;
         for (var i=0;i<intInsert;i++) {
            objYarra[j] = cobjStore[i];
            j++;
         }
         objYarra[j] = new clsStore(2,'C','*ROOT',cobjStore[cintTargetS].strgrp,strCdeCode,strCdeText,'',strCdeVat,strCdeVad);
         j++;
         for (var i=intInsert;i<cobjStore.length;i++) {
            objYarra[j] = cobjStore[i];
            j++;
         }
         cobjStore.length = 0;
         for (i=0;i<objYarra.length;i++) {
            cobjStore[i] = objYarra[i];
         }
      } else if (cintMode == 'U') {
////sorting
         for (var i=0;i<cobjStore.length;i++) {
            if (cobjStore[i].strgrp.toUpperCase() == cobjStore[cintTargetS].strgrp.toUpperCase() &&
                cobjStore[i].strcod.toUpperCase() == cobjStore[cintTargetS].strcod.toUpperCase()) {
               cobjStore[i].strcod = strCdeCode;
            }
         }
         cobjStore[cintTargetS].strcod = strCdeCode;
         cobjStore[cintTargetS].strtxt = strCdeText;
         cobjStore[cintTargetS].strvat = strCdeVat;
         cobjStore[cintTargetS].strvad = strCdeVad;
      } else if (cintMode == 'D') {
         var strGroup = cobjStore[cintTargetS].strgrp.toUpperCase();
         var strCode = cobjStore[cintTargetS].strcod.toUpperCase();
         var objYarra = new Array();
         var j = 0;
         for (var i=0;i<cobjStore.length;i++) {
            if (cobjStore[i].strgrp.toUpperCase() != strGroup &&
                cobjStore[i].strcod.toUpperCase() != strCode) {
               objYarra[j] = cobjStore[i];
               j++;
            }
         }
         cobjStore.length = 0;
         for (i=0;i<objYarra.length;i++) {
            cobjStore[i] = objYarra[i];
         }
         cintTargetW = -1;
      }
      paintStore();
      var objDspStore = document.getElementById('dspStore');
      var objDspGroup = document.getElementById('dspGroup');
      var objInpGroup = document.getElementById('inpGroup');
      var objEnqGroup = document.getElementById('enqGroup');
      var objDspCode = document.getElementById('dspCode');
      var objInpCode = document.getElementById('inpCode');
      var objEnqCode = document.getElementById('enqCode');
      var objDspValue = document.getElementById('dspValue');
      var objInpValue = document.getElementById('inpValue');
      var objEnqValue = document.getElementById('enqValue');
      objDspStore.style.display = 'block';
      objDspStore.style.visibility = 'visible';
      objDspGroup.style.display = 'none';
      objDspGroup.style.visibility = 'hidden';
      objInpGroup.style.display = 'none';
      objInpGroup.style.visibility = 'hidden';
      objEnqGroup.style.display = 'none';
      objEnqGroup.style.visibility = 'hidden';
      objDspCode.style.display = 'none';
      objDspCode.style.visibility = 'hidden';
      objInpCode.style.display = 'none';
      objInpCode.style.visibility = 'hidden';
      objEnqCode.style.display = 'none';
      objEnqCode.style.visibility = 'hidden';
      objDspValue.style.display = 'none';
      objDspValue.style.visibility = 'hidden';
      objInpValue.style.display = 'none';
      objInpValue.style.visibility = 'hidden';
      objEnqValue.style.display = 'none';
      objEnqValue.style.visibility = 'hidden';
   }
   function addValue() {
      if (cobjTarget == null) {
         alert('Target must be selected');
         return;
      }
      if (cobjStore[cintTargetS].strnod != 'C') {
         alert('Target must be code for a new value');
         return;
      }
      if (cobjStore[cintTargetS].strVat == '*SINGLE') {
         var intCount = 0;
         for (var i=0;i<cobjStore.length;i++) {
            if (cobjStore[i].strnod == 'V' &&
                cobjStore[i].strgrp.toUpperCase() == cobjStore[cintTargetS].strgrp.toUpperCase() &&
                cobjStore[i].strcod.toUpperCase() == cobjStore[cintTargetS].strcod.toUpperCase()) {
               intCount++;
               break;
            }
         }
         if (intCount > 1) {
            alert('Target data store code type *SINGLE can only have one value');
            return;
         }
      }
      cintMode = 'A';
      var objDspStore = document.getElementById('dspStore');
      var objDspGroup = document.getElementById('dspGroup');
      var objInpGroup = document.getElementById('inpGroup');
      var objEnqGroup = document.getElementById('enqGroup');
      var objDspCode = document.getElementById('dspCode');
      var objInpCode = document.getElementById('inpCode');
      var objEnqCode = document.getElementById('enqCode');
      var objDspValue = document.getElementById('dspValue');
      var objInpValue = document.getElementById('inpValue');
      var objEnqValue = document.getElementById('enqValue');
      objDspStore.style.display = 'none';
      objDspStore.style.visibility = 'hidden';
      objDspGroup.style.display = 'none';
      objDspGroup.style.visibility = 'hidden';
      objInpGroup.style.display = 'none';
      objInpGroup.style.visibility = 'hidden';
      objEnqGroup.style.display = 'none';
      objEnqGroup.style.visibility = 'hidden';
      objDspCode.style.display = 'none';
      objDspCode.style.visibility = 'hidden';
      objInpCode.style.display = 'none';
      objInpCode.style.visibility = 'hidden';
      objEnqCode.style.display = 'none';
      objEnqCode.style.visibility = 'hidden';
      objDspValue.style.display = 'block';
      objDspValue.style.visibility = 'visible';
      objInpValue.style.display = 'block';
      objInpValue.style.visibility = 'visible';
      objEnqValue.style.display = 'none';
      objEnqValue.style.visibility = 'hidden';
      document.getElementById('hedValue').innerText = 'Create Value';
      document.getElementById('INP_CdeValue').value = '';
      document.getElementById('INP_CdeValue').focus();
   }
   function acceptValue() {
      if (!processForm()) {return;}
      var strCdeValue;
      var bolFound = false;
      var strMessage = '';
      if (cintMode == 'A' || cintMode == 'U') {
         strCdeValue = document.getElementById('INP_CdeValue').value;
         if (strCdeValue == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Code value must be entered';
         }
         bolFound = false;
         for (var i=0;i<cobjStore.length;i++) {
            if (cintMode == 'A' &&
                cobjStore[i].strnod == 'V' &&
                cobjStore[i].strgrp.toUpperCase() == cobjStore[cintTargetS].strgrp.toUpperCase() &&
                cobjStore[i].strcod.toUpperCase() == cobjStore[cintTargetS].strcod.toUpperCase() &&
                cobjStore[i].strval == strCdeValue) {
               bolFound = true;
               break;
            }
            if (cintMode == 'U' &&
                i != cintTargetS &&
                cobjStore[i].strnod == 'V' &&
                cobjStore[i].strgrp.toUpperCase() == cobjStore[cintTargetS].strgrp.toUpperCase() &&
                cobjStore[i].strcod.toUpperCase() == cobjStore[cintTargetS].strcod.toUpperCase() &&
                cobjStore[i].strcod.toUpperCase() == strCdeValue) {
               bolFound = true;
               break;
            }
         }
         if (bolFound == true) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Data store value already exists in the code';
         }
         if (strMessage != '') {
            alert(strMessage);
            return;
         }
      }
      var objYarra = new Array();
      if (cintMode == 'A') {
         var intInsert = cintTargetS+1;
         for (var i=cintTargetS;i<cobjStore.length;i++) {
            if (cobjStore[i].strnod == 'V' &&
                cobjStore[i].strgrp.toUpperCase() == cobjStore[cintTargetS].strgrp.toUpperCase() &&
                cobjStore[i].strcod.toUpperCase() == cobjStore[cintTargetS].strcod.toUpperCase() &&
                cobjStore[i].strval > strCdeValue) {
               intInsert = i;
               break;
            }
         }
         var j = 0;
         for (var i=0;i<intInsert;i++) {
            objYarra[j] = cobjStore[i];
            j++;
         }
         objYarra[j] = new clsStore(3,'V','*ROOT',cobjStore[cintTargetS].strgrp,cobjStore[cintTargetS].strcod,'',strCdeValue,'','');
         j++;
         for (var i=intInsert;i<cobjStore.length;i++) {
            objYarra[j] = cobjStore[i];
            j++;
         }
         cobjStore.length = 0;
         for (i=0;i<objYarra.length;i++) {
            cobjStore[i] = objYarra[i];
         }
      } else if (cintMode == 'U') {
///sorting
         cobjStore[cintTargetS].strval = strCdeValue;
      } else if (cintMode == 'D') {
         var strGroup = cobjStore[cintTargetS].strgrp.toUpperCase();
         var strCode = cobjStore[cintTargetS].strcod.toUpperCase();
         var objYarra = new Array();
         var j = 0;
         for (var i=0;i<cobjStore.length;i++) {
            if (cobjStore[i].strgrp.toUpperCase() != strGroup &&
                cobjStore[i].strcod.toUpperCase() != strCode ||
                cobjStore[i].strval.toUpperCase() != strCode) {
               objYarra[j] = cobjStore[i];
               j++;
            }
         }
         cobjStore.length = 0;
         for (i=0;i<objYarra.length;i++) {
            cobjStore[i] = objYarra[i];
         }
         cintTargetW = -1;
      }
      paintStore();
      var objDspStore = document.getElementById('dspStore');
      var objDspGroup = document.getElementById('dspGroup');
      var objInpGroup = document.getElementById('inpGroup');
      var objEnqGroup = document.getElementById('enqGroup');
      var objDspCode = document.getElementById('dspCode');
      var objInpCode = document.getElementById('inpCode');
      var objEnqCode = document.getElementById('enqCode');
      var objDspValue = document.getElementById('dspValue');
      var objInpValue = document.getElementById('inpValue');
      var objEnqValue = document.getElementById('enqValue');
      objDspStore.style.display = 'block';
      objDspStore.style.visibility = 'visible';
      objDspGroup.style.display = 'none';
      objDspGroup.style.visibility = 'hidden';
      objInpGroup.style.display = 'none';
      objInpGroup.style.visibility = 'hidden';
      objEnqGroup.style.display = 'none';
      objEnqGroup.style.visibility = 'hidden';
      objDspCode.style.display = 'none';
      objDspCode.style.visibility = 'hidden';
      objInpCode.style.display = 'none';
      objInpCode.style.visibility = 'hidden';
      objEnqCode.style.display = 'none';
      objEnqCode.style.visibility = 'hidden';
      objDspValue.style.display = 'none';
      objDspValue.style.visibility = 'hidden';
      objInpValue.style.display = 'none';
      objInpValue.style.visibility = 'hidden';
      objEnqValue.style.display = 'none';
      objEnqValue.style.visibility = 'hidden';
   }
   function checkStore() {
      var strReturn = '';
      var strXML = null;
      var objHidden = null;
      var intPart = 0;
      var aryStream = null;
      var bolCode = false;
      var bolValue = false;
      if (cobjStore.length <= 1) {
         strReturn = 'At least one group must be created';
      } else {
         for (var i=1;i<cobjStore.length;i++) {
            if (cobjStore[i].strnod == 'G') {
               bolCode = false;
               for (var j=i;j<cobjStore.length;j++) {
                  if (cobjStore[j].strnod == 'C' && cobjStore[j].strgrp == cobjStore[i].strgrp) {
                     bolCode = true;
                     bolValue = false;
                     for (var k=j;k<cobjStore.length;k++) {
                        if (cobjStore[k].strnod == 'V' && cobjStore[k].strgrp == cobjStore[j].strgrp && cobjStore[k].strcod == cobjStore[j].strcod) {
                           bolValue = true;
                           break;
                        }
                     }
                     if (bolValue == false) {
                        strReturn = 'At least one value must be created for each code';
                        break;
                     }
                  }
               }
               if (bolCode == false) {
                  strReturn = 'At least one code must be created for each group';
                  break;
               }
            }
         }
      }
      if (strReturn == '') {
         strXML = '<?xml version="1.0" encoding="UTF-8"?>';
         strXML = strXML+'<ICS_STORE';<%if objForm.Fields("DTA_DasAction").Value = "*CREATE" then%>
         strXML = strXML+' CODE="'+fixAttribute(document.main.INP_DasSystem.value)+'"';<%else%>
         strXML = strXML+' CODE="'+fixAttribute(document.main.DTA_DasSystem.value)+'"';<%end if%>
         strXML = strXML+' TEXT="'+fixAttribute(document.main.INP_DasDescription.value)+'"';
         strXML = strXML+'>';
         strXML = strXML+'<NODES>';
         for (var i=1;i<cobjStore.length;i++) {
            if (cobjStore[i].strnod == 'G') {
               strXML = strXML+'<NODE';
               strXML = strXML+' NODE="'+cobjStore[i].strnod+'"';
               strXML = strXML+' GROUP="'+fixAttribute(cobjStore[i].strgrp)+'"';
               strXML = strXML+' TEXT="'+fixAttribute(cobjStore[i].strtxt)+'"';
               strXML = strXML+'/>';
            } else if (cobjStore[i].strnod == 'C') {
               strXML = strXML+'<NODE';
               strXML = strXML+' NODE="'+cobjStore[i].strnod+'"';
               strXML = strXML+' GROUP="'+fixAttribute(cobjStore[i].strgrp)+'"';
               strXML = strXML+' CODE="'+fixAttribute(cobjStore[i].strcod)+'"';
               strXML = strXML+' TEXT="'+fixAttribute(cobjStore[i].strtxt)+'"';
               strXML = strXML+' TYPE="'+fixAttribute(cobjStore[i].strvat)+'"';
               strXML = strXML+' DATA="'+fixAttribute(cobjStore[i].strvad)+'"';
               strXML = strXML+'/>';
            } else {
               strXML = strXML+'<NODE';
               strXML = strXML+' NODE="'+cobjStore[i].strnod+'"';
               strXML = strXML+' GROUP="'+fixAttribute(cobjStore[i].strgrp)+'"';
               strXML = strXML+' CODE="'+fixAttribute(cobjStore[i].strcod)+'"';
               strXML = strXML+' VALUE="'+fixAttribute(cobjStore[i].strval)+'"';
               strXML = strXML+'/>';
            }
         }
         strXML = strXML+'</NODES>';
         strXML = strXML+'</ICS_STORE>';
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
      return strReturn;
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
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_das_configuration_define_help.htm');parent.setHeading('<%=strHeading%> - Data Store Definition');parent.showContent();loadStore();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table id="dspStore" class="clsGrid02" style="display:block;visibility:visible" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr><%if objForm.Fields("DTA_DasAction").Value = "*CREATE" then%>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Data Store:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_DasSystem" size="32" maxlength="32" value="<%=objForm.Fields("DTA_DasSystem").Value%>" onFocus="setSelect(this);">
         </nobr></td><%else%>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Data Store:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_DasSystem").Value%></nobr></td><%end if%>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Data Store Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_DasDescription" size="64" maxlength="128" value="<%=replace(objForm.Fields("DTA_DasDescription").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=6 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addGroup();">&nbsp;Add Group&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addCode();">&nbsp;Add Code&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addValue();">&nbsp;Add Value&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:updateStore();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:deleteStore();">&nbsp;Delete&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td align=center colspan=2 nowrap><nobr>
            <table id="tabStore" class="clsGrid02" cols=1 align=center cellpadding="0" cellspacing="0"></table>
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
   <table id="dspGroup" class="clsGrid02" style="display:none;visibility:hidden" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedGroup" class="clsFunction" align=center colspan=2 nowrap><nobr>Group Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="inpGroup" style="display:none;visibility:hidden"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Data Store Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_GrpCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Group Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_GrpText" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr id="enqGroup" style="display:none;visibility:hidden"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Data Store Group:&nbsp;</nobr></td>
         <td id="ENQ_GrpCode" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Group Description:&nbsp;</nobr></td>
         <td id="ENQ_GrpText" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:cancelStore();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:acceptGroup();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspCode" class="clsGrid02" style="display:none;visibility:hidden" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedCode" class="clsFunction" align=center colspan=2 nowrap><nobr>Code Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="inpCode" style="display:none;visibility:hidden"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Data Store Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_CdeCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Code Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_CdeText" size="64" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Code Value Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="INP_CdeVat">
               <option value="*SINGLE">*SINGLE
               <option value="*LIST">*LIST
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Code Value Data:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="INP_CdeVad">
               <option value="*UPPER">*UPPER
               <option value="*MIXED">*MIXED
               <option value="*NUMBER">*NUMBER
               <option value="*DATE">*DATE
            </select>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr id="enqCode" style="display:none;visibility:hidden"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Data Store Code:&nbsp;</nobr></td>
         <td id="ENQ_CdeCode" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Code Description:&nbsp;</nobr></td>
         <td id="ENQ_CdeText" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Code Value Type:&nbsp;</nobr></td>
         <td id="ENQ_CdeValType" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Code Value Data:&nbsp;</nobr></td>
         <td id="ENQ_CdeValData" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:cancelStore();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:acceptCode();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspValue" class="clsGrid02" style="display:none;visibility:hidden" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedValue" class="clsFunction" align=center colspan=2 nowrap><nobr>Value Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="inpValue" style="display:none;visibility:hidden"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Code Value:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_CdeValue" size="64" maxlength="2000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr id="enqValue" style="display:none;visibility:hidden"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Code Value:&nbsp;</nobr></td>
         <td id="ENQ_CdeValue" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:cancelStore();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:acceptValue();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_DasSystem" value="<%=objForm.Fields("DTA_DasSystem").Value%>">
   <input type="hidden" name="DTA_DasDescription" value="<%=replace(objForm.Fields("DTA_DasDescription").Value, """", "&#34;", 1, -1, 1)%>">
</form>
</body>
</html>