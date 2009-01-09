<html>
<script language="javascript">
<!--
   function showError() {<%if objForm.Fields("DTA_StreamAction").Value = "*CREATE" then%>
      document.main.INP_StreamCode.focus();<%else%>
      document.main.INP_StreamText.focus();<%end if%><%if strReturn <> "*OK" then%>
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
      var strDetail = '';<%if objForm.Fields("DTA_StreamAction").Value = "*CREATE" then%>
      if (document.main.INP_StreamCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Stream code must be entered';
      }<%end if%>
      if (document.main.INP_StreamText.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Stream text must be entered';
      }
      if (document.main.INP_StreamStatus.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Stream status must be selected';
      }
      strDetail = checkTasks();
      if (strDetail != '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + strDetail;
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }<%if objForm.Fields("DTA_StreamAction").Value = "*CREATE" then%>
      document.main.DTA_StreamCode.value = document.main.INP_StreamCode.value;<%end if%>
      document.main.DTA_StreamText.value = document.main.INP_StreamText.value;
      document.main.DTA_StreamStatus.value = document.main.INP_StreamStatus.value;
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
   function selectStatus(objSelect) {
      document.main.INP_StreamStatus.value = objSelect.options[objSelect.selectedIndex].value;
   }
// -->
</script>
<script language="javascript">
<!--
   //////////////////////////////
   // Stream definition script //
   //////////////////////////////
   var cobjStream = new Array();
   var cobjImage = new Array();
   var cobjSelected = null;
   var cintSelectS = 0;
   var cintSelectE = 0;
   var cintSelectW = -1;
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
   function loadStream() {
      cobjStream[0] = new clsStream('0','S','*ROOT','*TOP','Stream Root','','','','','');
      cobjStream[1] = new clsStream('1','T','*TOP','T1','Task 1','','','','','');
      cobjStream[2] = new clsStream('2','E','T1','E1','Event 1','','','','','');
      cobjStream[3] = new clsStream('2','E','T1','E2','Event 2','','','','','');
      cobjStream[4] = new clsStream('2','E','T1','E3','Event 3','','','','','');
      cobjStream[5] = new clsStream('2','E','T1','E4','Event 4','','','','','');
      cobjStream[6] = new clsStream('2','T','T1','T2','Task 2','','','','','');
      cobjStream[7] = new clsStream('3','E','T2','E5','Event 5','','','','','');
      cobjStream[8] = new clsStream('3','E','T2','E6','Event 6','','','','','');
      cobjStream[9] = new clsStream('2','T','T1','T3','Task 3','','','','','');
      cobjStream[10] = new clsStream('3','E','T3','E7','Event 7','','','','','');
      cobjStream[11] = new clsStream('3','E','T3','E8','Event 8','','','','','');
      cobjStream[12] = new clsStream('3','T','T3','T4','Task 4','','','','','');
      cobjStream[13] = new clsStream('4','E','T4','E9','Event 9','','','','','');
      cobjStream[14] = new clsStream('4','E','T4','E10','Event 10','','','','','');
      cobjStream[15] = new clsStream('1','T','*TOP','T5','Task 5','','','','','');
      cobjStream[16] = new clsStream('2','E','T5','E11','Event 11','','','','','');
      cobjStream[17] = new clsStream('2','E','T5','E12','Event 12','','','','','');
      cobjStream[18] = new clsStream('2','T','T5','T6','Task 6','','','','','');
      cobjStream[19] = new clsStream('3','E','T6','E13','Event 13','','','','','');
      cobjStream[20] = new clsStream('3','T','T6','T7','Task 7','','','','','');
      cobjStream[21] = new clsStream('4','E','T7','E14','Event 14','','','','','');
      paintStream();
   }
   function clsStream(strDepth,strType,strParent,strCode,strText,strLock,strProc,strGroup,strAlert,strEmail) {
      this.strdep = strDepth;
      this.strtyp = strType;
      this.strpar = strParent;
      this.strcod = strCode;
      this.strtxt = strText;
      this.strlvl = '';
      this.strlck = strLock;
      this.strprc = strProc;
      this.strgrp = strGroup;
      this.stralt = strAlert;
      this.strema = strEmail;
   }
   function paintStream() {
     var objDepth = new Array();
      for (var i=cobjStream.length-1;i>=0;i--) {
         for (var j=objDepth.length;j<=(cobjStream[i].strdep-0);j++) {
            objDepth[j] = '0';
         }
         for (var j=(cobjStream[i].strdep-0)+1;j<objDepth.length;j++) {
            objDepth[j] = '0';
         }
         cobjStream[i].strlvl = '';
         for (var j=1;j<(cobjStream[i].strdep-0);j++) {
            if (objDepth[j] == '1') {
               cobjStream[i].strlvl = cobjStream[i].strlvl + '3';
            } else {
               cobjStream[i].strlvl = cobjStream[i].strlvl + 'B';
            }
         }
         if (cobjStream[i].strdep != '0') {
            if (objDepth[(cobjStream[i].strdep-0)] == '1') {
               cobjStream[i].strlvl = cobjStream[i].strlvl + '2';
            } else {
               cobjStream[i].strlvl = cobjStream[i].strlvl + '1';
            }
         }
         cobjStream[i].strlvl = cobjStream[i].strlvl + cobjStream[i].strtyp;
         objDepth[(cobjStream[i].strdep-0)] = '1';
      }
      var objTable = document.getElementById('tabStream');
      var objRow = null;
      var objCell = null;
      var objImage = null;
      var objSelect = null;
      var objTarget = null;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      for (var i=0;i<cobjStream.length;i++) {
         objRow = objTable.insertRow(i);
         objRow.height = '19';
         objCell = objRow.insertCell(0);
         objCell.colSpan = 1;
         objCell.style.whiteSpace = 'nowrap';
         if (cobjStream[i].strtyp == 'S') {
            objCell.className = 'clsLabelBB';
         } else if (cobjStream[i].strtyp == 'T') {
            objCell.onclick = function() {selectStream(this);};
            objCell.className = 'clsTreeBB';
         } else if (cobjStream[i].strtyp == 'E') {
            objCell.onclick = function() {selectStream(this);};
            objCell.className = 'clsTreeBN';
         }
         objCell.align = 'left';
         if (cintSelectW == i) {
            objSelect = objCell;
         }
         for (var j=0;j<cobjStream[i].strlvl.length;j++) {
            if (cobjStream[i].strlvl.substring(j,j+1) == 'S') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[4].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objImage.onclick = function() {moveStream(this,event);};
               objCell.appendChild(objImage);
               objImage = document.createElement('img');
               objImage.src = cobjImage[7].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objImage.onclick = function() {targetStream(this,event);};
               if (cintTargetW == i) {
                  objTarget = objImage;
               }
               objCell.appendChild(objImage);
            } else if (cobjStream[i].strlvl.substring(j,j+1) == 'T') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[5].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objImage.onclick = function() {moveStream(this,event);};
               objCell.appendChild(objImage);
               objImage = document.createElement('img');
               objImage.src = cobjImage[7].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objImage.onclick = function() {targetStream(this,event);};
               if (cintTargetW == i) {
                  objTarget = objImage;
               }
               objCell.appendChild(objImage);
            } else if (cobjStream[i].strlvl.substring(j,j+1) == 'E') {
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
               objImage.onclick = function() {targetStream(this,event);};
               if (cintTargetW == i) {
                  objTarget = objImage;
               }
               objCell.appendChild(objImage);
            } else if (cobjStream[i].strlvl.substring(j,j+1) == 'B') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[0].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
            } else if (cobjStream[i].strlvl.substring(j,j+1) == '1') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[1].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
            } else if (cobjStream[i].strlvl.substring(j,j+1) == '2') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[2].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
            } else if (cobjStream[i].strlvl.substring(j,j+1) == '3') {
               objImage = document.createElement('img');
               objImage.src = cobjImage[3].src;
               objImage.align = 'absmiddle';
               objImage.border = '0';
               objImage.height = '19';
               objImage.width = '18';
               objCell.appendChild(objImage);
            }
         }
         if (cobjStream[i].strtyp == 'S') {
            objCell.appendChild(document.createTextNode(' '+cobjStream[i].strtxt));
         } else if (cobjStream[i].strtyp == 'T') {
            objCell.appendChild(document.createTextNode(' ('+cobjStream[i].strcod+') '+cobjStream[i].strtxt));
         } else if (cobjStream[i].strtyp == 'E') {
            objCell.appendChild(document.createTextNode(' ('+cobjStream[i].strcod+') '+cobjStream[i].strtxt+' - Lock('+cobjStream[i].strlck+') Group('+cobjStream[i].strgrp+') Procedure('+cobjStream[i].strprc+')'));
         }
      }
      cobjSelected = null;
      cintSelectS = 0;
      cintSelectE = 0;
      cintSelectW = -1;
      cobjTarget = null;
      cintTargetS = 0;
      cintTargetE = 0;
      cintTargetW = -1;
      if (objSelect != null) {
         selectStream(objSelect);
      }
      if (objTarget != null) {
         targetStream(objTarget,null);
      }
   }
   function selectStream(objSelected) {
      var intWorkS = objSelected.parentNode.rowIndex;
      var intWorkE = intWorkS;
      for (var i=intWorkS+1;i<cobjStream.length;i++) {
         if ((cobjStream[i].strdep-0) <= (cobjStream[intWorkS].strdep-0)) {
            break;
         }
         intWorkE = i;
      }
      var objTable = document.getElementById('tabStream');
      if (cobjSelected) {
         for (var i=cintSelectS;i<=cintSelectE;i++) {
            if (objTable.rows[i].cells[0].className == 'clsTreeBBX' || objTable.rows[i].cells[0].className == 'clsTreeBBG') {
               objTable.rows[i].cells[0].className = 'clsTreeBB';
            } else {
               objTable.rows[i].cells[0].className = 'clsTreeBN';
            }
         }
      }
      cobjSelected = objSelected;
      if (cobjSelected.className == 'clsTreeBB') {
         cobjSelected.className = 'clsTreeBBX';
      } else {
         cobjSelected.className = 'clsTreeBNX';
      }
      cintSelectS = intWorkS;
      cintSelectE = intWorkE;
      cintSelectW = intWorkS;
      for (var i=cintSelectS+1;i<=cintSelectE;i++) {
         if (objTable.rows[i].cells[0].className == 'clsTreeBB') {
            objTable.rows[i].cells[0].className = 'clsTreeBBG';
         } else {
            objTable.rows[i].cells[0].className = 'clsTreeBNG';
         }
      }
   }
   function targetStream(objTarget,objEvent) {
      if (objEvent != null) {
         objEvent.cancelBubble = true;
      }
      var intWorkS = objTarget.parentNode.parentNode.rowIndex;
      var intWorkE = intWorkS;
      for (var i=intWorkS+1;i<cobjStream.length;i++) {
         if (cobjStream[i].strpar != cobjStream[intWorkS].strcod || cobjStream[i].strtyp != 'E') {
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
   function updateStream() {
      if (cobjTarget == null) {
         alert('Target must be selected');
         return;
      }
      if (cobjStream[cintTargetS].strtyp == 'S') {
         alert('Target must be task or event for update');
         return;
      }
      cintMode = 'U';
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objInpTask = document.getElementById('inpTask');
      var objEnqTask = document.getElementById('enqTask');
      var objDspEvent = document.getElementById('dspEvent');
      var objInpEvent = document.getElementById('inpEvent');
      var objEnqEvent = document.getElementById('enqEvent');
      if (cobjStream[cintTargetS].strtyp == 'T') {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspTask.style.display = 'block';
         objDspTask.style.visibility = 'visible';
         objInpTask.style.display = 'block';
         objInpTask.style.visibility = 'visible';
         objEnqTask.style.display = 'none';
         objEnqTask.style.visibility = 'hidden';
         objDspEvent.style.display = 'none';
         objDspEvent.style.visibility = 'hidden';
         objInpEvent.style.display = 'none';
         objInpEvent.style.visibility = 'hidden';
         objEnqEvent.style.display = 'none';
         objEnqEvent.style.visibility = 'hidden';
         document.getElementById('hedTask').innerText = 'Update Task';
         document.getElementById('INP_TskCode').value = cobjStream[cintTargetS].strcod;
         document.getElementById('INP_TskText').value = cobjStream[cintTargetS].strtxt;
         document.getElementById('INP_TskCode').focus();
      } else {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspTask.style.display = 'none';
         objDspTask.style.visibility = 'hidden';
         objInpTask.style.display = 'none';
         objInpTask.style.visibility = 'hidden';
         objEnqTask.style.display = 'none';
         objEnqTask.style.visibility = 'hidden';
         objDspEvent.style.display = 'block';
         objDspEvent.style.visibility = 'visible';
         objInpEvent.style.display = 'block';
         objInpEvent.style.visibility = 'visible';
         objEnqEvent.style.display = 'none';
         objEnqEvent.style.visibility = 'hidden';
         document.getElementById('hedEvent').innerText = 'Update Event';
         document.getElementById('INP_EvtCode').value = cobjStream[cintTargetS].strcod;
         document.getElementById('INP_EvtText').value = cobjStream[cintTargetS].strtxt;
         document.getElementById('INP_EvtLock').value = cobjStream[cintTargetS].strlck;
         document.getElementById('INP_EvtProc').value = cobjStream[cintTargetS].strprc;
         document.getElementById('INP_JobGroup').value = cobjStream[cintTargetS].strgrp;
         document.getElementById('INP_OprAlert').value = cobjStream[cintTargetS].stralt;
         document.getElementById('INP_EmaGroup').value = cobjStream[cintTargetS].strema;
         document.getElementById('INP_EvtCode').focus();
      }
   }
   function deleteStream() {
      if (cobjTarget == null) {
         alert('Target must be selected');
         return;
      }
      if (cobjStream[cintTargetS].strtyp == 'S') {
         alert('Target must be task or event for delete');
         return;
      }
      cintMode = 'D';
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objInpTask = document.getElementById('inpTask');
      var objEnqTask = document.getElementById('enqTask');
      var objDspEvent = document.getElementById('dspEvent');
      var objInpEvent = document.getElementById('inpEvent');
      var objEnqEvent = document.getElementById('enqEvent');
      if (cobjStream[cintTargetS].strtyp == 'T') {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspTask.style.display = 'block';
         objDspTask.style.visibility = 'visible';
         objInpTask.style.display = 'none';
         objInpTask.style.visibility = 'hidden';
         objEnqTask.style.display = 'block';
         objEnqTask.style.visibility = 'visible';
         objDspEvent.style.display = 'none';
         objDspEvent.style.visibility = 'hidden';
         objInpEvent.style.display = 'none';
         objInpEvent.style.visibility = 'hidden';
         objEnqEvent.style.display = 'none';
         objEnqEvent.style.visibility = 'hidden';
         document.getElementById('hedTask').innerText = 'Delete Task';
         document.getElementById('ENQ_TskCode').innerText = ' '+cobjStream[cintTargetS].strcod;
         document.getElementById('ENQ_TskText').innerText = ' '+cobjStream[cintTargetS].strtxt;
      } else {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspTask.style.display = 'none';
         objDspTask.style.visibility = 'hidden';
         objInpTask.style.display = 'none';
         objInpTask.style.visibility = 'hidden';
         objEnqTask.style.display = 'none';
         objEnqTask.style.visibility = 'hidden';
         objDspEvent.style.display = 'block';
         objDspEvent.style.visibility = 'visible';
         objInpEvent.style.display = 'none';
         objInpEvent.style.visibility = 'hidden';
         objEnqEvent.style.display = 'block';
         objEnqEvent.style.visibility = 'visible';
         document.getElementById('hedEvent').innerText = 'Delete Event';
         document.getElementById('ENQ_EvtCode').innerText = ' '+cobjStream[cintTargetS].strcod;
         document.getElementById('ENQ_EvtText').innerText = ' '+cobjStream[cintTargetS].strtxt;
         document.getElementById('ENQ_EvtLock').innerText = ' '+cobjStream[cintTargetS].strlck;
         document.getElementById('ENQ_EvtProc').innerText = ' '+cobjStream[cintTargetS].strprc;
         document.getElementById('ENQ_JobGroup').innerText = ' '+cobjStream[cintTargetS].strgrp;
         document.getElementById('ENQ_OprAlert').innerText = ' '+cobjStream[cintTargetS].stralt;
         document.getElementById('ENQ_EmaGroup').innerText = ' '+cobjStream[cintTargetS].strema;
      }
   }
   function addTask() {
      if (cobjTarget == null) {
         alert('Target must be selected');
         return;
      }
      if (cobjStream[cintTargetS].strtyp == 'E') {
         alert('Target must be stream or task for a new task');
         return;
      }
      cintMode = 'A';
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objInpTask = document.getElementById('inpTask');
      var objEnqTask = document.getElementById('enqTask');
      var objDspEvent = document.getElementById('dspEvent');
      var objInpEvent = document.getElementById('inpEvent');
      var objEnqEvent = document.getElementById('enqEvent');
      objDspStream.style.display = 'none';
      objDspStream.style.visibility = 'hidden';
      objDspTask.style.display = 'block';
      objDspTask.style.visibility = 'visible';
      objInpTask.style.display = 'block';
      objInpTask.style.visibility = 'visible';
      objEnqTask.style.display = 'none';
      objEnqTask.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      objInpEvent.style.display = 'none';
      objInpEvent.style.visibility = 'hidden';
      objEnqEvent.style.display = 'none';
      objEnqEvent.style.visibility = 'hidden';
      document.getElementById('hedTask').innerText = 'Create Task';
      document.getElementById('INP_TskCode').value = '';
      document.getElementById('INP_TskText').value = '';
      document.getElementById('INP_TskCode').focus();
   }
   function cancelTask() {
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objInpTask = document.getElementById('inpTask');
      var objEnqTask = document.getElementById('enqTask');
      var objDspEvent = document.getElementById('dspEvent');
      var objInpEvent = document.getElementById('inpEvent');
      var objEnqEvent = document.getElementById('enqEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objInpTask.style.display = 'none';
      objInpTask.style.visibility = 'hidden';
      objEnqTask.style.display = 'none';
      objEnqTask.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      objInpEvent.style.display = 'none';
      objInpEvent.style.visibility = 'hidden';
      objEnqEvent.style.display = 'none';
      objEnqEvent.style.visibility = 'hidden';
   }
   function acceptTask(strCode,strText) {
      if (!processForm()) {return;}
      var strTskCode;
      var strTskText;
      var bolFound = false;
      var strMessage = '';
      if (cintMode == 'A' || cintMode == 'U') {
         strTskCode = document.getElementById('INP_TskCode').value.toUpperCase();
         strTskText = document.getElementById('INP_TskText').value;
         if (strTskCode == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Task code must be entered';
         }
         if (strTskText == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Task text must be entered';
         }
         bolFound = false;
         for (var i=0;i<cobjStream.length;i++) {
            if ((cintMode == 'A' || (cintMode == 'U' && i != cintTargetS)) &&
                cobjStream[i].strtyp == 'T' &&
                cobjStream[i].strcod.toUpperCase() == strTskCode) {
               bolFound = true;
               break;
            }
         }
         if (bolFound == true) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Task code already exists in the stream';
         }
         if (strMessage != '') {
            alert(strMessage);
            return;
         }
      }
      var objYarra = new Array();
      if (cintMode == 'A') {
         var j = 0;
         for (var i=0;i<=cintTargetE;i++) {
            objYarra[j] = cobjStream[i];
            j++;
         }
         cintSelectW = j;
         objYarra[j] = new clsStream((cobjStream[cintTargetS].strdep-0) + 1,'T',cobjStream[cintTargetS].strcod,strTskCode,strTskText,'','','','','');
         j++;
         for (var i=cintTargetE+1;i<cobjStream.length;i++) {
            objYarra[j] = cobjStream[i];
            j++;
         }
         cobjStream.length = 0;
         for (i=0;i<objYarra.length;i++) {
            cobjStream[i] = objYarra[i];
         }
      } else if (cintMode == 'U') {
         cobjStream[cintTargetS].strcod = strTskCode;
         cobjStream[cintTargetS].strtxt = strTskText;
      } else if (cintMode == 'D') {
         var intWorkS = cintTargetS;
         var intWorkE = intWorkS;
         for (var i=intWorkS+1;i<cobjStream.length;i++) {
            if ((cobjStream[i].strdep-0) <= (cobjStream[intWorkS].strdep-0)) {
               break;
            }
            intWorkE = i;
         }
         var objYarra = new Array();
         var j = 0;
         for (var i=0;i<cobjStream.length;i++) {
            if (i < intWorkS || i > intWorkE) {
               objYarra[j] = cobjStream[i];
               j++;
            }
         }
         cobjStream.length = 0;
         for (i=0;i<objYarra.length;i++) {
            cobjStream[i] = objYarra[i];
         }
         cintTargetW = -1;
         if (cobjSelected != null) {
            if (cintSelectS >= intWorkS && cintSelectS <= intWorkE) {
               cintSelectW = -1;
            }
         }
      }
      paintStream();
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objInpTask = document.getElementById('inpTask');
      var objEnqTask = document.getElementById('enqTask');
      var objDspEvent = document.getElementById('dspEvent');
      var objInpEvent = document.getElementById('inpEvent');
      var objEnqEvent = document.getElementById('enqEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objInpTask.style.display = 'none';
      objInpTask.style.visibility = 'hidden';
      objEnqTask.style.display = 'none';
      objEnqTask.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      objInpEvent.style.display = 'none';
      objInpEvent.style.visibility = 'hidden';
      objEnqEvent.style.display = 'none';
      objEnqEvent.style.visibility = 'hidden';
   }
   function addEvent() {
      if (cobjTarget == null) {
         alert('Target must be selected');
         return;
      }
      if (cobjStream[cintTargetS].strtyp == 'S' ||
          cobjStream[cintTargetS].strtyp == 'E') {
         alert('Target must be task for a new event');
         return;
      }
      cintMode = 'A';
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objInpTask = document.getElementById('inpTask');
      var objEnqTask = document.getElementById('enqTask');
      var objDspEvent = document.getElementById('dspEvent');
      var objInpEvent = document.getElementById('inpEvent');
      var objEnqEvent = document.getElementById('enqEvent');
      objDspStream.style.display = 'none';
      objDspStream.style.visibility = 'hidden';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objInpTask.style.display = 'none';
      objInpTask.style.visibility = 'hidden';
      objEnqTask.style.display = 'none';
      objEnqTask.style.visibility = 'hidden';
      objDspEvent.style.display = 'block';
      objDspEvent.style.visibility = 'visible';
      objInpEvent.style.display = 'block';
      objInpEvent.style.visibility = 'visible';
      objEnqEvent.style.display = 'none';
      objEnqEvent.style.visibility = 'hidden';
      document.getElementById('hedEvent').innerText = 'Create Event';
      document.getElementById('INP_EvtCode').value = '';
      document.getElementById('INP_EvtText').value = '';
      document.getElementById('INP_EvtLock').value = '';
      document.getElementById('INP_EvtProc').value = '';
      document.getElementById('INP_JobGroup').value = '';
      document.getElementById('INP_OprAlert').value = '';
      document.getElementById('INP_EmaGroup').value = '';
      document.getElementById('INP_EvtCode').focus();
   }
   function cancelEvent() {
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objInpTask = document.getElementById('inpTask');
      var objEnqTask = document.getElementById('enqTask');
      var objDspEvent = document.getElementById('dspEvent');
      var objInpEvent = document.getElementById('inpEvent');
      var objEnqEvent = document.getElementById('enqEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objInpTask.style.display = 'none';
      objInpTask.style.visibility = 'hidden';
      objEnqTask.style.display = 'none';
      objEnqTask.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      objInpEvent.style.display = 'none';
      objInpEvent.style.visibility = 'hidden';
      objEnqEvent.style.display = 'none';
      objEnqEvent.style.visibility = 'hidden';
   }
   function acceptEvent() {
      if (!processForm()) {return;}
      var strEvtCode;
      var strEvtText;
      var strEvtLock;
      var strEvtProc;
      var strJobGroup;
      var strOprAlert;
      var strEmaGroup;
      var bolFound = false;
      var strMessage = '';
      if (cintMode == 'A' || cintMode == 'U') {
         strEvtCode = document.getElementById('INP_EvtCode').value.toUpperCase();
         strEvtText = document.getElementById('INP_EvtText').value;
         strEvtLock = document.getElementById('INP_EvtLock').value.toUpperCase();
         strEvtProc = document.getElementById('INP_EvtProc').value;
         strJobGroup = document.getElementById('INP_JobGroup').value.toUpperCase();
         strOprAlert = document.getElementById('INP_OprAlert').value;
         strEmaGroup = document.getElementById('INP_EmaGroup').value;
         if (strEvtCode == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Event code must be entered';
         }
         if (strEvtText == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Event text must be entered';
         }
         if (strEvtLock == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Event lock must be entered';
         }
         if (strEvtProc == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Event procedure must be entered';
         }
         if (strJobGroup == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Job group must be entered';
         }
         bolFound = false;
         for (var i=0;i<cobjStream.length;i++) {
            if ((cintMode == 'A' || (cintMode == 'U' && i != cintTargetS)) &&
                cobjStream[i].strpar.toUpperCase() == cobjStream[cintTargetS].strcod.toUpperCase() &&
                cobjStream[i].strtyp == 'E' &&
                cobjStream[i].strcod.toUpperCase() == strEvtCode) {
               bolFound = true;
               break;
            }
         }
         if (bolFound == true) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Event code already exists in the task';
         }
         if (strMessage != '') {
            alert(strMessage);
            return;
         }
      }
      var objYarra = new Array();
      if (cintMode == 'A') {
         var j = 0;
         for (var i=0;i<=cintTargetE;i++) {
            objYarra[j] = cobjStream[i];
            j++;
         }
         cintSelectW = j;
         objYarra[j] = new clsStream((cobjStream[cintTargetS].strdep-0) + 1,'E',cobjStream[cintTargetS].strcod,strEvtCode,strEvtText,strEvtLock,strEvtProc,strJobGroup,strOprAlert,strEmaGroup);
         j++;
         for (var i=cintTargetE+1;i<cobjStream.length;i++) {
            objYarra[j] = cobjStream[i];
            j++;
         }
         cobjStream.length = 0;
         for (i=0;i<objYarra.length;i++) {
            cobjStream[i] = objYarra[i];
         }
      } else if (cintMode == 'U') {
         cobjStream[cintTargetS].strcod = strEvtCode;
         cobjStream[cintTargetS].strtxt = strEvtText;
         cobjStream[cintTargetS].strlck = strEvtLock;
         cobjStream[cintTargetS].strprc = strEvtProc;
         cobjStream[cintTargetS].strgrp = strJobGroup;
         cobjStream[cintTargetS].stralt = strOprAlert;
         cobjStream[cintTargetS].strema = strEmaGroup;
      } else if (cintMode == 'D') {
         var intWorkS = cintTargetS;
         var intWorkE = intWorkS;
         for (var i=intWorkS+1;i<cobjStream.length;i++) {
            if ((cobjStream[i].strdep-0) <= (cobjStream[intWorkS].strdep-0)) {
               break;
            }
            intWorkE = i;
         }
         var objYarra = new Array();
         var j = 0;
         for (var i=0;i<cobjStream.length;i++) {
            if (i < intWorkS || i > intWorkE) {
               objYarra[j] = cobjStream[i];
               j++;
            }
         }
         cobjStream.length = 0;
         for (i=0;i<objYarra.length;i++) {
            cobjStream[i] = objYarra[i];
         }
         cintTargetW = -1;
         if (cobjSelected != null) {
            if (cintSelectS >= intWorkS && cintSelectS <= intWorkE) {
               cintSelectW = -1;
            }
         }
      }
      paintStream();
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objInpTask = document.getElementById('inpTask');
      var objEnqTask = document.getElementById('enqTask');
      var objDspEvent = document.getElementById('dspEvent');
      var objInpEvent = document.getElementById('inpEvent');
      var objEnqEvent = document.getElementById('enqEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objInpTask.style.display = 'none';
      objInpTask.style.visibility = 'hidden';
      objEnqTask.style.display = 'none';
      objEnqTask.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      objInpEvent.style.display = 'none';
      objInpEvent.style.visibility = 'hidden';
      objEnqEvent.style.display = 'none';
      objEnqEvent.style.visibility = 'hidden';
   }
   function moveStream(objTarget,objEvent) {
      objEvent.cancelBubble = true;
      if (cobjSelected == null) {
         alert('Task or event must be selected');
         return;
      }
      var intIndexS = objTarget.parentNode.parentNode.rowIndex;
      var intIndexE = intIndexS;
      if (cobjStream[intIndexS].strcod.toUpperCase() == cobjStream[cintSelectS].strpar.toUpperCase()) {
         alert('Target is current selection parent');
         return;
      }
      if (intIndexS >= cintSelectS && intIndexS <= cintSelectE) {
         alert('Target is within current selection');
         return;
      }
      var bolFound = false;
      for (var i=intIndexS+1;i<cobjStream.length;i++) {
         if (cobjStream[i].strpar.toUpperCase() != cobjStream[intIndexS].strcod.toUpperCase() || cobjStream[i].strtyp != 'E') {
            break;
         }
         intIndexE = i;
         if (cobjStream[cintSelectS].strtyp == 'E' &&
             cobjStream[i].strcod.toUpperCase() == cobjStream[cintSelectS].strcod.toUpperCase()) {
            bolFound = true;
            break;
         }
      }
      if (bolFound == true) {
         alert('Event code already exists in the target task');
         return;
      }
      cobjStream[cintSelectS].strpar = cobjStream[intIndexS].strcod;
      var intAdjust = (cobjStream[intIndexS].strdep-0) - (cobjStream[cintSelectS].strdep-0) + 1;
      for (var i=cintSelectS;i<=cintSelectE;i++) {
         cobjStream[i].strdep = (cobjStream[i].strdep-0)+intAdjust;
      }
      var objYarra = new Array();
      var j = 0;
      if (cintSelectS < intIndexS) {
         for (var i=0;i<cintSelectS;i++) {
            if (i == cintTargetS) {
               cintTargetW = j;
            }
            objYarra[j] = cobjStream[i];
            j++;
         }
         for (var i=cintSelectE+1;i<intIndexS;i++) {
            if (i == cintTargetS) {
               cintTargetW = j;
            }
            objYarra[j] = cobjStream[i];
            j++;
         }
         for (var i=intIndexS;i<=intIndexE;i++) {
            if (i == cintTargetS) {
               cintTargetW = j;
            }
            objYarra[j] = cobjStream[i];
            j++;
         }
         for (var i=cintSelectS;i<=cintSelectE;i++) {
            if (i == cintSelectS) {
               cintSelectW = j;
            }
            if (i == cintTargetS) {
               cintTargetW = j;
            }
            objYarra[j] = cobjStream[i];
            j++;
         }
         for (var i=intIndexE+1;i<cobjStream.length;i++) {
            if (i == cintTargetS) {
               cintTargetW = j;
            }
            objYarra[j] = cobjStream[i];
            j++;
         }
      } else {
         for (var i=0;i<=intIndexE;i++) {
            if (i == cintTargetS) {
               cintTargetW = j;
            }
            objYarra[j] = cobjStream[i];
            j++;
         }
         for (var i=cintSelectS;i<=cintSelectE;i++) {
            if (i == cintSelectS) {
               cintSelectW = j;
            }
            if (i == cintTargetS) {
               cintTargetW = j;
            }
            objYarra[j] = cobjStream[i];
            j++;
         }
         for (var i=intIndexE+1;i<cintSelectS;i++) {
            if (i == cintTargetS) {
               cintTargetW = j;
            }
            objYarra[j] = cobjStream[i];
            j++;
         }
         for (var i=cintSelectE+1;i<cobjStream.length;i++) {
            if (i == cintTargetS) {
               cintTargetW = j;
            }
            objYarra[j] = cobjStream[i];
            j++;
         }
      }
      cobjStream.length = 0;
      for (i=0;i<objYarra.length;i++) {
         cobjStream[i] = objYarra[i];
      }
      paintStream();
   }
   function upStream() {
      if (cobjSelected == null) {
         alert('Task or event must be selected');
         return;
      }
      var intIndexS = 0;
      var intIndexE = 0;
      for (var i=0;i<cintSelectS;i++) {
         if (cobjStream[i].strpar == cobjStream[cintSelectS].strpar &&
             cobjStream[i].strdep == cobjStream[cintSelectS].strdep &&
             cobjStream[i].strtyp == cobjStream[cintSelectS].strtyp) {
            intIndexS = i;
         } else if (cobjStream[i].strdep < cobjStream[cintSelectS].strdep) {
            intIndexS = 0;
         }
      }
      if (intIndexS == 0) {
         alert('Selection already at top of parent hierarchy');
         return;
      }
      intIndexE = intIndexS;
      for (var i=intIndexS+1;i<cobjStream.length;i++) {
         if ((cobjStream[i].strdep-0) <= (cobjStream[intIndexS].strdep-0)) {
            break;
         }
         intIndexE = i;
      }
      var objYarra = new Array();
      var j = 0;
      for (var i=0;i<intIndexS;i++) {
         if (i == cintTargetS) {
            cintTargetW = j;
         }
         objYarra[j] = cobjStream[i];
         j++;
      }
      for (var i=cintSelectS;i<=cintSelectE;i++) {
         if (i == cintSelectS) {
            cintSelectW = j;
         }
         if (i == cintTargetS) {
            cintTargetW = j;
         }
         objYarra[j] = cobjStream[i];
         j++;
      }
      for (var i=intIndexS;i<=intIndexE;i++) {
         if (i == cintTargetS) {
            cintTargetW = j;
         }
         objYarra[j] = cobjStream[i];
         j++;
      }
      for (var i=cintSelectE+1;i<cobjStream.length;i++) {
         if (i == cintTargetS) {
            cintTargetW = j;
         }
         objYarra[j] = cobjStream[i];
         j++;
      }
      cobjStream.length = 0;
      for (i=0;i<objYarra.length;i++) {
         cobjStream[i] = objYarra[i];
      }
      paintStream();
   }
   function downStream() {
      if (cobjSelected == null) {
         alert('Task or event must be selected');
         return;
      }
      var intIndexS = 0;
      var intIndexE = 0;
      for (var i=cobjStream.length-1;i>cintSelectE;i--) {
         if (cobjStream[i].strpar == cobjStream[cintSelectS].strpar &&
             cobjStream[i].strdep == cobjStream[cintSelectS].strdep &&
             cobjStream[i].strtyp == cobjStream[cintSelectS].strtyp) {
            intIndexS = i;
         } else if (cobjStream[i].strdep < cobjStream[cintSelectS].strdep) {
            intIndexS = 0;
         }
      }
      if (intIndexS == 0) {
         alert('Selection already at bottom of parent hierarchy');
         return;
      }
      intIndexE = intIndexS;
      for (var i=intIndexS+1;i<cobjStream.length;i++) {
         if ((cobjStream[i].strdep-0) <= (cobjStream[intIndexS].strdep-0)) {
            break;
         }
         intIndexE = i;
      }
      var objYarra = new Array();
      var j = 0;
      for (var i=0;i<cintSelectS;i++) {
         if (i == cintTargetS) {
            cintTargetW = j;
         }
         objYarra[j] = cobjStream[i];
         j++;
      }
      for (var i=intIndexS;i<=intIndexE;i++) {
         if (i == cintTargetS) {
            cintTargetW = j;
         }
         objYarra[j] = cobjStream[i];
         j++;
      }
      for (var i=cintSelectS;i<=cintSelectE;i++) {
         if (i == cintSelectS) {
            cintSelectW = j;
         }
         if (i == cintTargetS) {
            cintTargetW = j;
         }
         objYarra[j] = cobjStream[i];
         j++;
      }
      for (var i=intIndexE+1;i<cobjStream.length;i++) {
         if (i == cintTargetS) {
            cintTargetW = j;
         }
         objYarra[j] = cobjStream[i];
         j++;
      }
      cobjStream.length = 0;
      for (i=0;i<objYarra.length;i++) {
         cobjStream[i] = objYarra[i];
      }
      paintStream();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_stream_configuration_define_help.htm');parent.setHeading('<%=strHeading%> - Stream Definition');parent.showContent();loadStream();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table id="dspStream" class="clsGrid02" style="display:block;visibility:visible" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_StreamCode" size="32" maxlength="32" value="<%=objForm.Fields("DTA_StreamCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_StreamText" size="64" maxlength="128" value="<%=replace(objForm.Fields("DTA_StreamText").Value, """", "&#34;", 1, -1, 1)%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltJStreamStatus" onChange="selectStatus(this);">
               <option value="0"<%if objForm.Fields("DTA_StreamStatus").Value = "0" or objForm.Fields("DTA_StreamStatus").Value = "" then%> selected<%end if%>>Inactive
               <option value="1"<%if objForm.Fields("DTA_StreamStatus").Value = "1" then%> selected<%end if%>>Active
            </select>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addTask();">&nbsp;Add Task&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addEvent();">&nbsp;Add Event&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:updateStream();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:deleteStream();">&nbsp;Delete&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:upStream();">&nbsp;Up&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:downStream();">&nbsp;Down&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td align=center colspan=2 nowrap><nobr>
            <table id="tabStream" class="clsGrid02" cols=1 align=center cellpadding="0" cellspacing="0"></table>
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
   <table id="dspTask" class="clsGrid02" style="display:none;visibility:hidden" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedTask" class="clsFunction" align=center colspan=2 nowrap><nobr>Task Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="inpTask" style="display:none;visibility:hidden"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Task Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_TskCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Task Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_TskText" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr id="enqTask" style="display:none;visibility:hidden"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Task Code:&nbsp;</nobr></td>
         <td id="ENQ_TskCode" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Task Text:&nbsp;</nobr></td>
         <td id="ENQ_TskText" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:cancelTask();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:acceptTask();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspEvent" class="clsGrid02" style="display:none;visibility:hidden" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedEvent" class="clsFunction" align=center colspan=2 nowrap><nobr>Event Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="inpEvent" style="display:none;visibility:hidden"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_EvtCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EvtText" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Lock:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_EvtLock" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Procedure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EvtProc" size="64" maxlength="512" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_JobGroup" size="10" maxlength="10" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Operator Alert:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_OprAlert" size="64" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EmaGroup" size="64" maxlength="64" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr id="enqEvent" style="display:none;visibility:hidden"><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Code:&nbsp;</nobr></td>
         <td id="ENQ_EvtCode" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Text:&nbsp;</nobr></td>
         <td id="ENQ_EvtText" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Lock:&nbsp;</nobr></td>
         <td id="ENQ_EvtLock" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Procedure:&nbsp;</nobr></td>
         <td id="ENQ_EvtProc" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Group:&nbsp;</nobr></td>
         <td id="ENQ_JobGroup" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Operator Alert:&nbsp;</nobr></td>
         <td id="ENQ_OprAlert" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Email Group:&nbsp;</nobr></td>
         <td id="ENQ_EmaGroup" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:cancelEvent();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:acceptEvent();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_StreamCode" value="<%=objForm.Fields("DTA_StreamCode").Value%>">
   <input type="hidden" name="DTA_StreamText" value="<%=replace(objForm.Fields("DTA_StreamText").Value, """", "&#34;", 1, -1, 1)%>">
   <input type="hidden" name="DTA_StreamStatus" value="<%=objForm.Fields("DTA_StreamStatus").Value%>">
   <input type="hidden" name="INP_StreamStatus" value="<%=objForm.Fields("DTA_StreamStatus").Value%>">
   <input type="hidden" name="DET_StreamCount" value="">
</form>
</body>
</html>