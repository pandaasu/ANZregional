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
      strDetail = checkStream();
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
   var cobjStream = null;
   var cobjSelect = null;
   var cstrSelectCode = null;
   var cstrSelectType = null;
   var cobjTarget = null;
   var cstrTargetCode = null;
   var cstrTargetType = null;
   var cintMode = null;

  // function loadStream() {<%if objSelection.ListCount("NODES") = 0 then%>
  //    cobjStream = new clsStream('0','S','*ROOT','*TOP','Stream Root','','','','','');<%else%><%for i = objSelection.ListLower("NODES") to objSelection.ListUpper("NODES")%>
  //    cobjStream[<%=i%>] = new clsStream('<%=objSelection.ListValue01("NODES",i)%>','<%=objSelection.ListValue02("NODES",i)%>','<%=objSelection.ListValue03("NODES",i)%>','<%=objSelection.ListValue04("NODES",i)%>','<%=replace(objSelection.ListValue05("NODES",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue06("NODES",i)%>','<%=replace(objSelection.ListValue07("NODES",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue08("NODES",i)%>','<%=replace(objSelection.ListValue09("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue10("NODES",i), "'", "\'", 1, -1, 1)%>');<%next%><%end if%>
  //    paintStream();
  // }
   function loadStream() {
      var objData = new Array();
      objData[0] = new clsData('0','S','*ROOT','*TOP','Stream Root','','','','','');
      objData[1] = new clsData('1','T','*TOP','T1','Task T1','','','','','');
      objData[2] = new clsData('2','E','T1','T1E1','Event T1E1','','','','','');
      objData[3] = new clsData('2','E','T1','T1E2','Event T1E2','','','','','');
      objData[4] = new clsData('2','T','T1','T2','Task T2','','','','','');
      objData[5] = new clsData('3','E','T2','T2E1','Event T2E1','','','','','');
      objData[6] = new clsData('2','T','T1','T3','Task T3','','','','','');
      objData[7] = new clsData('3','E','T3','T3E1','Event T3E1','','','','','');
      objData[8] = new clsData('1','T','*TOP','T4','Task T4','','','','','');
      objData[9] = new clsData('2','E','T4','T4E1','Event T4E1','','','','','');
      objData[10] = new clsData('2','E','T4','T4E2','Event T4E2','','','','','');
      objData[11] = new clsData('1','G','*TOP','G1','Gate G1','','','','','');
      objData[12] = new clsData('2','T','G1','T5','Task T5','','','','','');
      objData[13] = new clsData('3','E','T5','T5E1','Event T5E1','','','','','');
      objData[14] = new clsData('3','E','T5','T5E2','Event T5E2','','','','','');
      objData[15] = new clsData('2','T','G1','T6','Task T6','','','','','');
      objData[16] = new clsData('3','E','T6','T6E1','Event T6E1','','','','','');
      objData[17] = new clsData('3','E','T6','T6E2','Event T6E2','','','','','');
      objData[18] = new clsData('3','T','T6','T7','Task T7','','','','','');
      objData[19] = new clsData('4','E','T7','T7E1','Event T7E1','','','','','');
      objData[20] = new clsData('3','T','T6','T8','Task T8','','','','','');
      objData[21] = new clsData('4','E','T8','T8E1','Event T8E1','','','','','');
      objData[22] = new clsData('1','G','*TOP','G2','Gate G2','','','','','');
      objData[23] = new clsData('2','T','G2','T9','Task T9','','','','','');
      objData[24] = new clsData('3','E','T9','T9E1','Event T9E1','','','','','');
      objData[25] = new clsData('3','E','T9','T9E2','Event T9E2','','','','','');
      var intPidx = 0;
      var intTidx = 0;
      var objParent = new Array();
      var objWork = null;
      var objTask = null;
      var objGate = null;
      var objEvent = null;
      for (var i=0;i<objData.length;i++) {
         objWork = objData[i];
         if (objWork.strtyp == 'S') {
            intPidx = 0;
            intTidx = 0;
            cobjStream = new clsStream(objWork.strdep,objWork.strtyp,objWork.strpar,objWork.strcod,objWork.strtxt);
            objParent[intTidx] = cobjStream;
         } else if (objWork.strtyp == 'T') {
            intPidx = objWork.strdep - 1;
            intTidx = objWork.strdep - 0;
            objTask = new clsTask(objWork.strdep,objWork.strtyp,objWork.strpar,objWork.strcod,objWork.strtxt);
            objParent[intPidx].tskary[objParent[intPidx].tskary.length] = objTask;
            objParent[intTidx] = objTask;
         } else if (objWork.strtyp == 'G') {
            intPidx = objWork.strdep - 1;
            intTidx = objWork.strdep - 0;
            objGate = new clsGate(objWork.strdep,objWork.strtyp,objWork.strpar,objWork.strcod,objWork.strtxt);
            objParent[intPidx].gteary[objParent[intPidx].gteary.length] = objGate;
            objParent[intTidx] = objGate;
         } else if (objWork.strtyp == 'E') {
            objEvent = new clsEvent(objWork.strdep,objWork.strtyp,objWork.strpar,objWork.strcod,objWork.strtxt,objWork.strlck,objWork.strprc,objWork.strgrp,objWork.stralt,objWork.strema);
            intPidx = objWork.strdep - 1;
            objParent[intPidx].evtary[objParent[intPidx].evtary.length] = objEvent;
         }
      }
      paintStream();
   }
   function clsData(strDepth,strType,strParent,strCode,strText,strLock,strProc,strGroup,strAlert,strEmail) {
      this.strdep = strDepth;
      this.strtyp = strType;
      this.strpar = strParent;
      this.strcod = strCode;
      this.strtxt = strText;
      this.strlck = strLock;
      this.strprc = strProc;
      this.strgrp = strGroup;
      this.stralt = strAlert;
      this.strema = strEmail;
   }
   function clsStream(strDepth,strType,strParent,strCode,strText) {
      this.strdep = '0';
      this.strtyp = 'S';
      this.strpar = '*ROOT';
      this.strcod = '*TOP';
      this.strtxt = strText;
      this.strlef = 0;
      this.strrig = 0;
      this.strtop = 0;
      this.strbot = 0;
      this.strwrk = 0;
      this.strlil = 0;
      this.strlit = 0;
      this.strlib = 0;
      this.tskary = new Array();
      this.gteary = new Array();
   }
   function clsTask(strDepth,strType,strParent,strCode,strText) {
      this.strdep = strDepth;
      this.strtyp = strType;
      this.strpar = strParent;
      this.strcod = strCode;
      this.strtxt = strText;
      this.strlef = 0;
      this.strrig = 0;
      this.strtop = 0;
      this.strbot = 0;
      this.strwrk = 0;
      this.strlil = 0;
      this.strlit = 0;
      this.strlib = 0;
      this.tskary = new Array();
      this.evtary = new Array();
   }
   function clsGate(strDepth,strType,strParent,strCode,strText) {
      this.strdep = strDepth;
      this.strtyp = strType;
      this.strpar = strParent;
      this.strcod = strCode;
      this.strtxt = strText;
      this.strlef = 0;
      this.strrig = 0;
      this.strtop = 0;
      this.strbot = 0;
      this.strwrk = 0;
      this.strlil = 0;
      this.strlit = 0;
      this.strlib = 0;
      this.tskary = new Array();
      this.depary = new Array();
   }
   function clsEvent(strDepth,strType,strParent,strCode,strText,strLock,strProc,strGroup,strAlert,strEmail) {
      this.strdep = strDepth;
      this.strtyp = strType;
      this.strpar = strParent;
      this.strcod = strCode;
      this.strtxt = strText;
      this.strlck = strLock;
      this.strprc = strProc;
      this.strgrp = strGroup;
      this.stralt = strAlert;
      this.strema = strEmail;
      this.strlef = 0;
      this.strrig = 0;
      this.strtop = 0;
      this.strbot = 0;
   }
   function paintStream() {

      var objCanvas = document.getElementById('divStream');
      while(objCanvas.firstChild) {
         objCanvas.removeChild(objCanvas.firstChild);
      }
      cobjSelect = null;
      cobjTarget = null;

      var objDiv;
      cobjStream.strlef = 4;
      cobjStream.strrig = 4;
      cobjStream.strtop = 4;
      cobjStream.strbot = 4;
      cobjStream.strwrk = 4;
      cobjStream.strlil = 0;
      cobjStream.strlit = 0;
      cobjStream.strlib = 0;

      objDiv = document.createElement('div');
      objDiv.align = 'center';
      objDiv.vAlign = 'top';
      objDiv.style.position = 'absolute';
      objDiv.style.fontFamily = 'Verdana,sans-serif';
      objDiv.style.fontSize = '8pt';
      objDiv.style.fontWeight = 'bold';
      objDiv.style.whiteSpace = 'normal';
      objDiv.style.backgroundColor = '#ccffff';
      objDiv.style.color = '#000000';
      objDiv.style.border = '#888888 1px solid';
      objDiv.style.padding = '3px';
      objDiv.style.top = cobjStream.strtop + 'px';
      objDiv.style.left = cobjStream.strlef + 'px';
      objDiv.style.height = 'auto';
      objDiv.style.width = 'auto';
      objDiv.style.overflow = 'hidden';
      objDiv.style.cursor = 'pointer';
      objDiv.setAttribute('parref',null);
      objDiv.setAttribute('objref',cobjStream);
      objDiv.setAttribute('bakcol','#ccffff');
      objDiv.onclick = function() {setSelected(this);};
      objDiv.appendChild(document.createTextNode(cobjStream.strtxt));
      if (cstrSelectCode == cobjStream.strcod) {
         setSelected(objDiv);
      }
      if (cstrTargetCode == cobjStream.strcod) {
         setTarget(objDiv);
      }
      objCanvas.appendChild(objDiv);

      cobjStream.strrig = (cobjStream.strlef-0) + objDiv.offsetWidth;
      cobjStream.strbot = (cobjStream.strtop-0) + objDiv.offsetHeight;

      if (cobjStream.tskary.length != 0 || cobjStream.gteary.length != 0) {
         cobjStream.strlil = (cobjStream.strlef-0) + objDiv.offsetWidth;
         cobjStream.strlit = (cobjStream.strtop-0) + 8;
         cobjStream.strlib = (cobjStream.strtop-0) + 8;
         objDiv = document.createElement('div');
         objDiv.style.position = 'absolute';
         objDiv.style.backgroundColor = '#888888';
         objDiv.style.border = 'none';
         objDiv.style.padding = '0px';
         objDiv.style.top = cobjStream.strlit + 'px';
         objDiv.style.left = cobjStream.strlil + 'px';
         objDiv.style.height = '1px';
         objDiv.style.width = '8px';
         objDiv.style.overflow = 'hidden';
         objCanvas.appendChild(objDiv);
         cobjStream.strlil = (cobjStream.strlil-0) + 8;
      }

      for (var i=0;i<cobjStream.tskary.length;i++) {
         paintTask(objCanvas,cobjStream,cobjStream.tskary[i]);
      }
      for (var i=0;i<cobjStream.gteary.length;i++) {
         paintGate(objCanvas,cobjStream,cobjStream.gteary[i]);
      }

   }
   function paintTask(objCanvas,objParent,objTask) {
      var objDiv;
      objTask.strlef = (objParent.strlil-0) + 8;
      objTask.strrig = (objParent.strlil-0) + 8;
      objTask.strtop = objParent.strwrk;
      objTask.strbot = objParent.strwrk;
      objTask.strwrk = objParent.strwrk;
      objTask.strlil = 0;
      objTask.strlit = 0;
      objTask.strlib = 0;

      if (objParent.strwrk > objParent.strtop) {
         objTask.strtop = (objParent.strwrk-0) + 8;
         objTask.strbot = (objParent.strwrk-0) + 8;
         objTask.strwrk = (objParent.strwrk-0) + 8;
         objParent.strlib = (objParent.strwrk-0) + 16;
         objDiv = document.createElement('div');
         objDiv.style.position = 'absolute';
         objDiv.style.backgroundColor = '#888888';
         objDiv.style.border = 'none';
         objDiv.style.padding = '0px';
         objDiv.style.top = (objParent.strlit-0) + 'px';
         objDiv.style.left = (objParent.strlil-0) + 'px';
         objDiv.style.height = (objParent.strlib - objParent.strlit) + 'px';
         objDiv.style.width = '1px';
         objDiv.style.overflow = 'hidden';
         objCanvas.appendChild(objDiv);
         objParent.strlit = objParent.strlib;
      }

      objDiv = document.createElement('div');
      objDiv.style.position = 'absolute';
      objDiv.style.backgroundColor = '#888888';
      objDiv.style.border = 'none';
      objDiv.style.padding = '0px';
      objDiv.style.top = (objParent.strlit-0) + 'px';
      objDiv.style.left = (objParent.strlil-0) + 'px';
      objDiv.style.height = '1px';
      objDiv.style.width = '8px';
      objDiv.style.overflow = 'hidden';
      objCanvas.appendChild(objDiv);

      objDiv = document.createElement('div');
      objDiv.align = 'center';
      objDiv.vAlign = 'top';
      objDiv.style.position = 'absolute';
      objDiv.style.fontFamily = 'Verdana,sans-serif';
      objDiv.style.fontSize = '8pt';
      objDiv.style.fontWeight = 'bold';
      objDiv.style.whiteSpace = 'normal';
      objDiv.style.backgroundColor = '#e6e6fa';
      objDiv.style.color = '#000000';
      objDiv.style.border = '#888888 1px solid';
      objDiv.style.padding = '3px';
      objDiv.style.top = (objTask.strtop-0) + 'px';
      objDiv.style.left = (objTask.strlef-0) + 'px';
      objDiv.style.height = 'auto';
      objDiv.style.width = 'auto';
      objDiv.style.overflow = 'hidden';
      objDiv.style.cursor = 'pointer';
      objDiv.setAttribute('parref',objParent);
      objDiv.setAttribute('objref',objTask);
      objDiv.setAttribute('bakcol','#e6e6fa');
      objDiv.onclick = function() {setSelected(this);};
      objDiv.appendChild(document.createTextNode(objTask.strtxt));
      if (cstrSelectCode == objTask.strcod) {
         setSelected(objDiv);
      }
      if (cstrTargetCode == objTask.strcod) {
         setTarget(objDiv);
      }
      objCanvas.appendChild(objDiv);

      objTask.strrig = (objTask.strlef-0) + objDiv.offsetWidth;
      objTask.strbot = (objTask.strtop-0) + objDiv.offsetHeight;

      if (objTask.evtary.length != 0 || objTask.tskary.length != 0) {
         objTask.strlil = (objTask.strlef-0) + objDiv.offsetWidth;
         objTask.strlit = (objTask.strtop-0) + 8;
         objTask.strlib = (objTask.strtop-0) + 8;
         objDiv = document.createElement('div');
         objDiv.style.position = 'absolute';
         objDiv.style.backgroundColor = '#888888';
         objDiv.style.border = 'none';
         objDiv.style.padding = '0px';
         objDiv.style.top = objTask.strlit + 'px';
         objDiv.style.left = objTask.strlil + 'px';
         objDiv.style.height = '1px';
         objDiv.style.width = '8px';
         objDiv.style.overflow = 'hidden';
         objCanvas.appendChild(objDiv);
         objTask.strlil = (objTask.strlil-0) + 8;
      }

      for (var i=0;i<objTask.evtary.length;i++) {
         paintEvent(objCanvas,objTask,objTask.evtary[i]);
      }
      for (var i=0;i<objTask.tskary.length;i++) {
         paintTask(objCanvas,objTask,objTask.tskary[i]);
      }
      if (objTask.strbot > objTask.strwrk) {
         objParent.strwrk = objTask.strbot;
      } else {
         objParent.strwrk = objTask.strwrk;
      }
   }
   function paintGate(objCanvas,objParent,objGate) {
      var objDiv;
      objGate.strlef = (objParent.strlil-0) + 8;
      objGate.strrig = (objParent.strlil-0) + 8;
      objGate.strtop = objParent.strwrk;
      objGate.strbot = objParent.strwrk;
      objGate.strwrk = objParent.strwrk;
      objGate.strlil = 0;
      objGate.strlit = 0;
      objGate.strlib = 0;

      if (objParent.strwrk > objParent.strtop) {
         objGate.strtop = (objParent.strwrk-0) + 8;
         objGate.strbot = (objParent.strwrk-0) + 8;
         objGate.strwrk = (objParent.strwrk-0) + 8;
         objParent.strlib = (objParent.strwrk-0) + 16;
         objDiv = document.createElement('div');
         objDiv.style.position = 'absolute';
         objDiv.style.backgroundColor = '#888888';
         objDiv.style.border = 'none';
         objDiv.style.padding = '0px';
         objDiv.style.top = (objParent.strlit-0) + 'px';
         objDiv.style.left = (objParent.strlil-0) + 'px';
         objDiv.style.height = (objParent.strlib - objParent.strlit) + 'px';
         objDiv.style.width = '1px';
         objDiv.style.overflow = 'hidden';
         objCanvas.appendChild(objDiv);
         objParent.strlit = objParent.strlib;
      }

      objDiv = document.createElement('div');
      objDiv.style.position = 'absolute';
      objDiv.style.backgroundColor = '#888888';
      objDiv.style.border = 'none';
      objDiv.style.padding = '0px';
      objDiv.style.top = (objParent.strlit-0) + 'px';
      objDiv.style.left = (objParent.strlil-0) + 'px';
      objDiv.style.height = '1px';
      objDiv.style.width = '8px';
      objDiv.style.overflow = 'hidden';
      objCanvas.appendChild(objDiv);

      objDiv = document.createElement('div');
      objDiv.align = 'center';
      objDiv.vAlign = 'top';
      objDiv.style.position = 'absolute';
      objDiv.style.fontFamily = 'Verdana,sans-serif';
      objDiv.style.fontSize = '8pt';
      objDiv.style.fontWeight = 'bold';
      objDiv.style.whiteSpace = 'normal';
      objDiv.style.backgroundColor = '#f0fff0';
      objDiv.style.color = '#000000';
      objDiv.style.border = '#888888 1px solid';
      objDiv.style.padding = '3px';
      objDiv.style.top = (objGate.strtop-0) + 'px';
      objDiv.style.left = (objGate.strlef-0) + 'px';
      objDiv.style.height = 'auto';
      objDiv.style.width = 'auto';
      objDiv.style.overflow = 'hidden';
      objDiv.style.cursor = 'pointer';
      objDiv.setAttribute('parref',objParent);
      objDiv.setAttribute('objref',objGate);
      objDiv.setAttribute('bakcol','#f0fff0');
      objDiv.onclick = function() {setSelected(this);};
      objDiv.appendChild(document.createTextNode(objGate.strtxt));
      objDiv.appendChild(document.createElement('br'));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode('Dependencies: T2, T4'));
      objDiv.appendChild(objFont);

      objDiv.appendChild(document.createElement('br'));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode('Dependencies: T2, T4'));
      objDiv.appendChild(objFont);

      objDiv.appendChild(document.createElement('br'));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode('Dependencies: T2, T4'));
      objDiv.appendChild(objFont);

      objDiv.appendChild(document.createElement('br'));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode('Dependencies: T2, T4'));
      objDiv.appendChild(objFont);

      if (cstrSelectCode == objGate.strcod) {
         setSelected(objDiv);
      }
      if (cstrTargetCode == objGate.strcod) {
         setTarget(objDiv);
      }
      objCanvas.appendChild(objDiv);

      objGate.strrig = (objGate.strlef-0) + objDiv.offsetWidth;
      objGate.strbot = (objGate.strtop-0) + objDiv.offsetHeight;

      if (objGate.tskary.length != 0) {
         objGate.strlil = (objGate.strlef-0) + objDiv.offsetWidth;
         objGate.strlit = (objGate.strtop-0) + 8;
         objGate.strlib = (objGate.strtop-0) + 8;
         objDiv = document.createElement('div');
         objDiv.style.position = 'absolute';
         objDiv.style.backgroundColor = '#888888';
         objDiv.style.border = 'none';
         objDiv.style.padding = '0px';
         objDiv.style.top = objGate.strlit + 'px';
         objDiv.style.left = objGate.strlil + 'px';
         objDiv.style.height = '1px';
         objDiv.style.width = '8px';
         objDiv.style.overflow = 'hidden';
         objCanvas.appendChild(objDiv);
         objGate.strlil = (objGate.strlil-0) + 8;
      }

      for (var i=0;i<objGate.tskary.length;i++) {
         paintTask(objCanvas,objGate,objGate.tskary[i]);
      }
      if (objGate.strbot > objGate.strwrk) {
         objParent.strwrk = objGate.strbot;
      } else {
         objParent.strwrk = objGate.strwrk;
      }

   }
   function paintEvent(objCanvas,objParent,objEvent) {
      var objDiv;
      objEvent.strlef = (objParent.strlil-0) + 8;
      objEvent.strrig = (objParent.strlil-0) + 8;
      objEvent.strtop = objParent.strwrk;
      objEvent.strbot = objParent.strwrk;

      if (objParent.strwrk > objParent.strtop) {
         objEvent.strtop = (objParent.strwrk-0) + 8;
         objEvent.strbot = (objParent.strwrk-0) + 8;
         objParent.strlib = (objParent.strwrk-0) + 16;
         objDiv = document.createElement('div');
         objDiv.style.position = 'absolute';
         objDiv.style.backgroundColor = '#888888';
         objDiv.style.border = 'none';
         objDiv.style.padding = '0px';
         objDiv.style.top = (objParent.strlit-0) + 'px';
         objDiv.style.left = (objParent.strlil-0) + 'px';
         objDiv.style.height = (objParent.strlib - objParent.strlit) + 'px';
         objDiv.style.width = '1px';
         objDiv.style.overflow = 'hidden';
         objCanvas.appendChild(objDiv);
         objParent.strlit = objParent.strlib;
      }

      objDiv = document.createElement('div');
      objDiv.style.position = 'absolute';
      objDiv.style.backgroundColor = '#888888';
      objDiv.style.border = 'none';
      objDiv.style.padding = '0px';
      objDiv.style.top = (objParent.strlit-0) + 'px';
      objDiv.style.left = (objParent.strlil-0) + 'px';
      objDiv.style.height = '1px';
      objDiv.style.width = '8px';
      objDiv.style.overflow = 'hidden';
      objCanvas.appendChild(objDiv);

      objDiv = document.createElement('div');
      objDiv.align = 'center';
      objDiv.vAlign = 'top';
      objDiv.style.position = 'absolute';
      objDiv.style.fontFamily = 'Verdana,sans-serif';
      objDiv.style.fontSize = '8pt';
      objDiv.style.fontWeight = 'bold';
      objDiv.style.whiteSpace = 'normal';
      objDiv.style.backgroundColor = '#fffacd';
      objDiv.style.color = '#000000';
      objDiv.style.border = '#888888 1px solid';
      objDiv.style.padding = '3px';
      objDiv.style.top = (objEvent.strtop-0) + 'px';
      objDiv.style.left = (objEvent.strlef-0) + 'px';
      objDiv.style.height = 'auto';
      objDiv.style.width = 'auto';
      objDiv.style.overflow = 'hidden';
      objDiv.style.cursor = 'pointer';
      objDiv.setAttribute('parref',objParent);
      objDiv.setAttribute('objref',objEvent);
      objDiv.setAttribute('bakcol','#fffacd');
      objDiv.onclick = function() {setSelected(this);};
      objDiv.appendChild(document.createTextNode(objEvent.strtxt));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode(' Procedure: '+objEvent.strprc + ' Lock: '+objEvent.strlck + ' Job Group: '+objEvent.strgrp));
      objDiv.appendChild(objFont);
      if (cstrSelectCode == objEvent.strcod) {
         setSelected(objDiv);
      }
      objCanvas.appendChild(objDiv);

      objEvent.strrig = (objEvent.strlef-0) + objDiv.offsetWidth;
      objEvent.strbot = (objEvent.strtop-0) + objDiv.offsetHeight;
      objParent.strwrk = objEvent.strbot;

   }
   function setSelected(objSelect) {
      if (cobjTarget == objSelect) {
         cobjTarget = null;
         cstrTargetType = null;
         cstrTargetCode = null;
      }
      if (cobjSelect != null) {
         cobjSelect.style.backgroundColor = cobjSelect.getAttribute('bakcol');
      }
      cobjSelect = objSelect;
      cobjSelect.style.backgroundColor = '#ffff80';
      var objObject = cobjSelect.getAttribute('objref');
      cstrSelectType = objObject.strtyp;
      cstrSelectCode = objObject.strcod;
   }
   function setTarget() {
      if (cobjSelect == null) {
         alert('No selection');
         return;
      }
      if (cstrSelectType == 'E') {
         alert('Move target cannot be an event');
         return;
      }
      if (cobjTarget != null) {
         cobjTarget.style.backgroundColor = cobjTarget.getAttribute('bakcol');
      }
      cobjTarget = cobjSelect;
      cobjTarget.style.backgroundColor = '#80ff80';
      var objObject = cobjTarget.getAttribute('objref');
      cstrTargetType = objObject.strtyp;
      cstrTargetCode = objObject.strcod;
      cobjSelect = null;
      cstrSelectType = null;
      cstrSelectCode = null;
   }
   function clearTarget() {
      if (cobjTarget != null) {
         cobjTarget.style.backgroundColor = cobjTarget.getAttribute('bakcol');
      }
      cobjTarget = null;
      cstrTargetType = null;
      cstrTargetCode = null;
   }
   function findCode(objParent,strCode) {
      var bolFound = false;
      if (objParent.strcod.toUpperCase() == strCode) {
         bolFound = true;
         return;
      }
      if (objParent.strtyp == 'S' || objParent.strtyp == 'T' || objParent.strtyp == 'G') {
         for (var i=0;i<objParent.tskary.length;i++) {
            if (objParent.tskary[i].strcod.toUpperCase() == strCode) {
               bolFound = true;
               break;
            }
         }
      }
      if (!bolFound && objParent.strtyp == 'S') {
         for (var i=0;i<objParent.gteary.length;i++) {
            if (objParent.gteary[i].strcod.toUpperCase() == strCode) {
               bolFound = true;
               break;
            }
         }
      }
      if (!bolFound && objParent.strtyp == 'T') {
         for (var i=0;i<objParent.evtary.length;i++) {
            if (objParent.evtary[i].strcod.toUpperCase() == strCode) {
               bolFound = true;
               break;
            }
         }
      }
      if (!bolFound) {
         if (objParent.strtyp == 'S' || objParent.strtyp == 'T' || objParent.strtyp == 'G') {
            for (var i=0;i<objParent.tskary.length;i++) {
               bolFound = findCode(objParent.tskary[i],strCode);
               if (bolFound) {
                  break;
               }
            }
         }
         if (!bolFound && objParent.strtyp == 'S') {
            for (var i=0;i<objParent.gteary.length;i++) {
               bolFound = findCode(objParent.gteary[i],strCode);
               if (bolFound) {
                  break;
               }
            }
         }
      }
      return bolFound;
   }
   function upStream() {
      if (cobjSelect == null) {
         alert('No selection');
         return;
      }
      if (cobjTarget != null) {
         alert('Move target set - sequence minus not allowed');
         return;
      }
      var objParent = cobjSelect.getAttribute('parref');
      var objObject = cobjSelect.getAttribute('objref');
      var objWork = null;
      if (objObject.strtyp == 'S') {
         alert('Stream cannot be resequenced');
         return;
      } else if (objObject.strtyp == 'T') {
         objWork = objParent.tskary;
      } else if (objObject.strtyp == 'G') {
         objWork = objParent.gteary;
      } else if (objObject.strtyp == 'E') {
         objWork = objParent.evtary;
      }
      var intIndx = 0;
      for (var i=0;i<objWork.length;i++) {
         if (objWork[i].strcod == objObject.strcod) {
            intIndx = i;
            break;
         }
      }
      if (intIndx == 0) {
         alert('Selection already at top of parent hierarchy');
         return;
      }
      var objYarra = new Array();
      for (var i=0;i<objWork.length;i++) {
         objYarra[i] = objWork[i];
      }
      objYarra[intIndx-1] = objWork[intIndx];
      objYarra[intIndx] = objWork[intIndx-1];
      objWork.length = 0;
      for (i=0;i<objYarra.length;i++) {
         objWork[i] = objYarra[i];
      }
      paintStream();
   }
   function downStream() {
      if (cobjSelect == null) {
         alert('No selection');
         return;
      }
      if (cobjTarget != null) {
         alert('Move target set - sequence plus not allowed');
         return;
      }
      var objParent = cobjSelect.getAttribute('parref');
      var objObject = cobjSelect.getAttribute('objref');
      var objWork = null;
      if (objObject.strtyp == 'S') {
         alert('Stream cannot be resequenced');
         return;
      } else if (objObject.strtyp == 'T') {
         objWork = objParent.tskary;
      } else if (objObject.strtyp == 'G') {
         objWork = objParent.gteary;
      } else if (objObject.strtyp == 'E') {
         objWork = objParent.evtary;
      }
      var intIndx = 0;
      for (var i=0;i<objWork.length;i++) {
         if (objWork[i].strcod == objObject.strcod) {
            intIndx = i;
            break;
         }
      }
      if (intIndx == objWork.length-1) {
         alert('Selection already at bottom of parent hierarchy');
         return;
      }
      var objYarra = new Array();
      for (var i=0;i<objWork.length;i++) {
         objYarra[i] = objWork[i];
      }
      objYarra[intIndx+1] = objWork[intIndx];
      objYarra[intIndx] = objWork[intIndx+1];
      objWork.length = 0;
      for (i=0;i<objYarra.length;i++) {
         objWork[i] = objYarra[i];
      }
      paintStream();
   }
   function moveStream() {
      if (cobjSelect == null) {
         alert('No selection');
         return;
      }
      if (cobjTarget == null) {
         alert('No Target');
         return;
      }
      var objSelectParent = cobjSelect.getAttribute('parref');
      var objSelectObject = cobjSelect.getAttribute('objref');
      var objTargetObject = cobjTarget.getAttribute('objref');
      if (objSelectParent.strcod == objTargetObject.strcod) {
         alert('Selection already child of target');
         return;
      }
      var objWork = null;
      if (objSelectObject.strtyp == 'S') {
         alert('Stream cannot be moved');
         return;
      } else if (objSelectObject.strtyp == 'T') {
         objWork = objSelectParent.tskary;
      } else if (objSelectObject.strtyp == 'G') {
         objWork = objSelectParent.gteary;
      } else if (objSelectObject.strtyp == 'E') {
         objWork = objSelectParent.evtary;
      }
      var intIndx = 0;
      for (var i=0;i<objWork.length;i++) {
         if (objWork[i].strcod == objSelectObject.strcod) {
            intIndx = i;
            break;
         }
      }
      objWork.splice(intIndx,1);
      if (objSelectObject.strtyp == 'T') {
         objWork = objTargetObject.tskary;
      } else if (objSelectObject.strtyp == 'G') {
         objWork = objTargetObject.gteary;
      } else if (objSelectObject.strtyp == 'E') {
         objWork = objTargetObject.evtary;
      }
      objWork[objWork.length] = objSelectObject;
      cobjTarget.style.backgroundColor = cobjTarget.getAttribute('bakcol');
      cstrTargetType = null;
      cstrTargetCode = null;
      paintStream();
   }
   function addTask() {
      if (cobjSelect == null) {
         alert('No selection');
         return;
      }
      if (cobjTarget != null) {
         alert('Move target set - add task not allowed');
         return;
      }
      var objSelectObject = cobjSelect.getAttribute('objref');
      if (objSelectObject.strtyp == 'E') {
         alert('Task can only be added to the stream root, task or gate');
         return;
      }
      cintMode = 'A';
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'none';
      objDspStream.style.visibility = 'hidden';
      objDspTask.style.display = 'block';
      objDspTask.style.visibility = 'visible';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      document.getElementById('hedTask').innerText = 'Create Task';
      document.getElementById('INP_TskCode').value = '';
      document.getElementById('INP_TskText').value = '';
      document.getElementById('INP_TskCode').focus();
   }
   function cancelTask() {
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
   }
   function acceptTask() {
      if (!processForm()) {return;}
      var objSelectObject = cobjSelect.getAttribute('objref');
      var strTskCode;
      var strTskText;
      var strMessage = '';
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
      if (cintMode == 'A') {
         if (findCode(cobjStream,strTskCode)) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Task code already exists in the stream';
         }
      } else {
         if (objSelectObject.strcod.toUpperCase() != strTskCode) {
            if (findCode(cobjStream,strTskCode)) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Task code already exists in the stream';
            }
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintMode == 'A') {
         objSelectObject.tskary[objSelectObject.tskary.length] = new clsTask('0','T',objSelectObject.strcod,strTskCode,strTskText);
      } else {
         objSelectObject.strcod = strTskCode;
         objSelectObject.strtxt = strTskText;
         cstrSelectCode = strTskCode;
      }
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      paintStream();
   }
   function addGate() {
      if (cobjSelect == null) {
         alert('No selection');
         return;
      }
      if (cobjTarget != null) {
         alert('Move target set - add gate not allowed');
         return;
      }
      var objSelectObject = cobjSelect.getAttribute('objref');
      if (objSelectObject.strtyp != 'S') {
         alert('Gate can only be added to the stream root');
         return;
      }
      cintMode = 'A';
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'none';
      objDspStream.style.visibility = 'hidden';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'block';
      objDspGate.style.visibility = 'visible';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      document.getElementById('hedGate').innerText = 'Create Gate';
      document.getElementById('INP_GteCode').value = '';
      document.getElementById('INP_GteText').value = '';
      document.getElementById('INP_GteCode').focus();
   }
   function cancelGate() {
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
   }
   function acceptGate() {
      if (!processForm()) {return;}
      var objSelectObject = cobjSelect.getAttribute('objref');
      var strGteCode;
      var strGteText;
      var strMessage = '';
      strGteCode = document.getElementById('INP_GteCode').value.toUpperCase();
      strGteText = document.getElementById('INP_GteText').value;
      if (strGteCode == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Gate code must be entered';
      }
      if (strGteText == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Gate text must be entered';
      }
      if (cintMode == 'A') {
         if (findCode(cobjStream,strGteCode)) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Gate code already exists in the stream';
         }
      } else {
         if (objSelectObject.strcod.toUpperCase() != strGteCode) {
            if (findCode(cobjStream,strGteCode)) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Gate code already exists in the stream';
            }
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintMode == 'A') {
         objSelectObject.gteary[objSelectObject.gteary.length] = new clsGate('0','G',objSelectObject.strcod,strGteCode,strGteText);
      } else {
         objSelectObject.strcod = strGteCode;
         objSelectObject.strtxt = strGteText;
         cstrSelectCode = strGteCode;
      }
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      paintStream();
   }
   function addEvent() {
      if (cobjSelect == null) {
         alert('No selection');
         return;
      }
      if (cobjTarget != null) {
         alert('Move target set - add Event not allowed');
         return;
      }
      var objSelectObject = cobjSelect.getAttribute('objref');
      if (objSelectObject.strtyp != 'T') {
         alert('Event can only be added to a task');
         return;
      }
      cintMode = 'A';
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'none';
      objDspStream.style.visibility = 'hidden';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'block';
      objDspEvent.style.visibility = 'visible';
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
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
   }
   function acceptEvent() {
      if (!processForm()) {return;}
      var objSelectObject = cobjSelect.getAttribute('objref');
      var strEvtCode;
      var strEvtText;
      var strEvtLock;
      var strEvtProc;
      var strJobGroup;
      var strOprAlert;
      var strEmaGroup;
      var strMessage = '';
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
      if (strOprAlert == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Operator alert must be entered';
      }
      if (strEmaGroup == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Email group must be entered';
      }
      if (cintMode == 'A') {
         if (findCode(cobjStream,strEvtCode)) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Event code already exists in the stream';
         }
      } else {
         if (objSelectObject.strcod.toUpperCase() != strEvtCode) {
            if (findCode(cobjStream,strEvtCode)) {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + 'Event code already exists in the stream';
            }
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintMode == 'A') {
         objSelectObject.evtary[objSelectObject.tskary.length] = new clsEvent('0','E',objSelectObject.strcod,strEvtCode,strEvtText,strEvtLock,strEvtProc,strJobGroup,strOprAlert,strEmaGroup);
      } else {
         objSelectObject.strcod = strEvtCode;
         objSelectObject.strtxt = strEvtText;
         objSelectObject.strlck = strEvtLock;
         objSelectObject.strprc = strEvtProc;
         objSelectObject.strgrp = strJobGroup;
         objSelectObject.stralt = strOprAlert;
         objSelectObject.strema = strEmaGroup;
         cstrSelectCode = strEvtCode;
      }
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      paintStream();
   }
   function updateStream() {
      if (cobjSelect == null) {
         alert('No selection');
         return;
      }
      if (cobjTarget != null) {
         alert('Move target set - update not allowed');
         return;
      }
      cintMode = 'U';
      var objDspStream = document.getElementById('dspStream');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      var objSelectObject = cobjSelect.getAttribute('objref');
      if (objSelectObject.strtyp == 'S') {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspTask.style.display = 'none';
         objDspTask.style.visibility = 'hidden';
         objDspGate.style.display = 'none';
         objDspGate.style.visibility = 'hidden';
         objDspEvent.style.display = 'none';
         objDspEvent.style.visibility = 'hidden';
         document.getElementById('hedStream').innerText = 'Update Stream';
         document.getElementById('INP_StrCode').value = objSelectObject.strcod;
         document.getElementById('INP_StrText').value = objSelectObject.strtxt;
         document.getElementById('INP_StrText').focus();
      } else if (objSelectObject.strtyp == 'T') {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspTask.style.display = 'block';
         objDspTask.style.visibility = 'visible';
         objDspGate.style.display = 'none';
         objDspGate.style.visibility = 'hidden';
         objDspEvent.style.display = 'none';
         objDspEvent.style.visibility = 'hidden';
         document.getElementById('hedTask').innerText = 'Update Task';
         document.getElementById('INP_TskCode').value = objSelectObject.strcod;
         document.getElementById('INP_TskText').value = objSelectObject.strtxt;
         document.getElementById('INP_TskText').focus();
      } else if (objSelectObject.strtyp == 'G') {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspTask.style.display = 'none';
         objDspTask.style.visibility = 'hidden';
         objDspGate.style.display = 'block';
         objDspGate.style.visibility = 'visible';
         objDspEvent.style.display = 'none';
         objDspEvent.style.visibility = 'hidden';
         document.getElementById('hedGate').innerText = 'Update Gate';
         document.getElementById('INP_GteCode').value = objSelectObject.strcod;
         document.getElementById('INP_GteText').value = objSelectObject.strtxt;
         document.getElementById('INP_GteText').focus();
      } else if (objSelectObject.strtyp == 'E') {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspTask.style.display = 'none';
         objDspTask.style.visibility = 'hidden';
         objDspGate.style.display = 'none';
         objDspGate.style.visibility = 'hidden';
         objDspEvent.style.display = 'block';
         objDspEvent.style.visibility = 'visible';
         document.getElementById('hedEvent').innerText = 'Update Event';
         document.getElementById('INP_EvtCode').value = objSelectObject.strcod;
         document.getElementById('INP_EvtText').value = objSelectObject.strtxt;
         document.getElementById('INP_EvtLock').value = objSelectObject.strlck;
         document.getElementById('INP_EvtProc').value = objSelectObject.strprc;
         document.getElementById('INP_JobGroup').value = objSelectObject.strgrp;
         document.getElementById('INP_OprAlert').value = objSelectObject.stralt;
         document.getElementById('INP_EmaGroup').value = objSelectObject.strema;
         document.getElementById('INP_EvtText').focus();
      }
   }
   function deleteStream() {
      if (cobjSelect == null) {
         alert('No selection');
         return;
      }
      if (cobjTarget != null) {
         alert('Move target set - delete not allowed');
         return;
      }
      var objSelectParent = cobjSelect.getAttribute('parref');
      var objSelectObject = cobjSelect.getAttribute('objref');
      var objWork = null;
      if (objSelectObject.strtyp == 'S') {
         alert('Stream cannot be deleted');
         return;
      } else if (objSelectObject.strtyp == 'T') {
         objWork = objSelectParent.tskary;
      } else if (objSelectObject.strtyp == 'G') {
         objWork = objSelectParent.gteary;
      } else if (objSelectObject.strtyp == 'E') {
         objWork = objSelectParent.evtary;
      }
      var intIndx = 0;
      for (var i=0;i<objWork.length;i++) {
         if (objWork[i].strcod == objSelectObject.strcod) {
            intIndx = i;
            break;
         }
      }
      objWork.splice(intIndx,1);
      cstrSelectType = null;
      cstrSelectCode = null;
      paintStream();
   }
   function editStream(strXML) {
      if (cobjStream.strcod == '') {
         bolFound = true;
         strReturn = 'Stream code must be entered';
      }
      if (cobjStream.strtxt == '') {
         bolFound = true;
         strReturn = 'Stream text must be entered';
      }
      if (cobjStream.tskary.length == 0) {
         bolFound = true;
         strReturn = 'At least one task must be created for the stream';
         break;
      }

      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<ICS_STREAM';<%if objForm.Fields("DTA_StreamAction").Value = "*CREATE" then%>
      strXML = strXML+' CODE="'+fixAttribute(document.main.INP_StreamCode.value)+'"';<%else%>
      strXML = strXML+' CODE="'+fixAttribute(document.main.DTA_StreamCode.value)+'"';<%end if%>
      strXML = strXML+' TEXT="'+fixAttribute(document.main.INP_StreamText.value)+'"';
      strXML = strXML+' STATUS="'+fixAttribute(document.main.INP_StreamStatus.value)+'"';
      strXML = strXML+'>';
      strXML = strXML+'<NODES>';
      for (var i=0;i<cobjStream.tskary.length;i++) {
         strXML = strXML + editTask(cobjStream.tskary[i]);
      }
      for (var i=0;i<cobjStream.gteary.length;i++) {
         strXML = strXML + editGate(cobjStream.gteary[i]);
      }
      strXML = strXML+'</NODES>';
      strXML = strXML+'</ICS_STREAM>';
      return strXML;
   }
   editTask(objTask) {
      if (objTask.evtary.length == 0) {
         bolFound = true;
         strReturn = 'At least one event must be created for each task';
         break;
      }
      var strXML = '<NODE';
      strXML = strXML+' TYPE="'+objTask[i].strtyp+'"';
      strXML = strXML+' CODE="'+fixAttribute(objTask[i].strcod)+'"';
      strXML = strXML+' PARENT="'+fixAttribute(objTask[i].strpar)+'"';
      strXML = strXML+' TEXT="'+fixAttribute(objTask[i].strtxt)+'"';
      strXML = strXML+'/>';
      for (var i=0;i<objTask.evtary.length;i++) {
         strXML = strXML + editEvent(objTask.evtary[i]);
      }
      for (var i=0;i<objTask.tskary.length;i++) {
         strXML = strXML + editTask(objTask.tskary[i]);
      }
      return strXML;
   }
   editGate(objGate) {
      if (objGate.tskary.length == 0) {
         bolFound = true;
         strReturn = 'At least one task must be created for each gate';
         break;
      }
      var strXML = '<NODE';
      strXML = strXML+' TYPE="'+objGate[i].strtyp+'"';
      strXML = strXML+' CODE="'+fixAttribute(objGate[i].strcod)+'"';
      strXML = strXML+' PARENT="'+fixAttribute(objGate[i].strpar)+'"';
      strXML = strXML+' TEXT="'+fixAttribute(objGate[i].strtxt)+'"';
      strXML = strXML+'/>';
      for (var i=0;i<objGate.tskary.length;i++) {
         strXML = strXML + editTask(objGate.tskary[i]);
      }
      return strXML;
   }
   editEvent(objEvent) {
      var strXML = '<NODE';
      strXML = strXML+' TYPE="'+objEvent[i].strtyp+'"';
      strXML = strXML+' CODE="'+fixAttribute(objEvent[i].strcod)+'"';
      strXML = strXML+' PARENT="'+fixAttribute(objEvent[i].strpar)+'"';
      strXML = strXML+' TEXT="'+fixAttribute(objEvent[i].strtxt)+'"';
      strXML = strXML+' LOCK="'+fixAttribute(objEvent[i].strlck)+'"';
      strXML = strXML+' PROC="'+fixAttribute(objEvent[i].strprc)+'"';
      strXML = strXML+' GROUP="'+fixAttribute(objEvent[i].strgrp)+'"';
      strXML = strXML+' ALERT="'+fixAttribute(objEvent[i].stralt)+'"';
      strXML = strXML+' EMAIL="'+fixAttribute(objEvent[i].strema)+'"';
      strXML = strXML+'/>';
      return strXML;
   }
   function checkStream() {
      var strReturn = '';
      var objHidden = null;
      var intPart = 0;
      var aryStream = null;
      var bolFound = false;
      var strXML = editStream(cobjStream);
      if (strReturn == '') {
         editStream(cobjStream,strXML);

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
<body class="clsBody02" scroll="nonr" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_stream_configuration_define_help.htm');parent.setHeading('<%=strHeading%> - Stream Definition');parent.showContent();loadStream();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table id="dspStream" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr><%if objForm.Fields("DTA_StreamAction").Value = "*CREATE" then%>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_StreamCode" size="32" maxlength="32" value="<%=objForm.Fields("DTA_StreamCode").Value%>" onFocus="setSelect(this);">
         </nobr></td><%else%>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Code:&nbsp;</nobr></td>
         <td class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr><%=objForm.Fields("DTA_StreamCode").Value%></nobr></td><%end if%>
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
            <table class="clsTable01" align=center cols=10 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addTask();">&nbsp;Add Task&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addGate();">&nbsp;Add Gate&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:addEvent();">&nbsp;Add Event&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:updateStream();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:deleteStream();">&nbsp;Delete&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:upStream();">&nbsp;Seqn(-)&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:downStream();">&nbsp;Seqn(+)&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:setTarget();">&nbsp;Set Target&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:clearTarget();">&nbsp;Clear Target&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:moveStream();">&nbsp;Move&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=98% >
         <td align=center colspan=2 nowrap><nobr>
            <div id="divStream" class="clsScroll01" style="background-color=#ffffff;"></div>
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
   <table id="dspGate" class="clsGrid02" style="display:none;visibility:hidden" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedGate" class="clsFunction" align=center colspan=2 nowrap><nobr>Gate Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Gate Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_GteCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Gate Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_GteText" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:cancelGate();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:acceptGate();">&nbsp;Accept&nbsp;</a></nobr></td>
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
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsWorking" align=left valign=center colspan=1 nowrap><nobr>&nbsp;(*NONE or Lock with optional substitution values &ltPARAMETER&gt)&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Event Procedure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EvtProc" size="64" maxlength="512" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsWorking" align=left valign=center colspan=1 nowrap><nobr>&nbsp;(*SUPPLIED or Procedure with optional substitution values &ltPARAMETER&gt)&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Job Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_JobGroup" size="10" maxlength="10" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsWorking" align=left valign=center colspan=1 nowrap><nobr>&nbsp;(Job group with optional substitution values &ltPARAMETER&gt)&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Operator Alert:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_OprAlert" size="64" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsWorking" align=left valign=center colspan=1 nowrap><nobr>&nbsp;(*NONE or Operator alert)&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Email Group:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_EmaGroup" size="64" maxlength="64" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
         <td class="clsWorking" align=left valign=center colspan=1 nowrap><nobr>&nbsp;(*NONE or Email group)&nbsp;</nobr></td>
      </tr>
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
</form>
</body>
</html>