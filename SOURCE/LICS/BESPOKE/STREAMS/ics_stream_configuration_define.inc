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
      cstrMessage = '';
      checkStream();
      if (cstrMessage != '') {
         alert(cstrMessage);
         return;
      }
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
   // Stream definition script //
   //////////////////////////////
   var cstrMessage = null;
   var cobjStream = null;
   var cobjSelect = null;
   var cstrSelectCode = null;
   var cstrSelectType = null;
   var cobjTarget = null;
   var cstrTargetCode = null;
   var cstrTargetType = null;
   var cintMode = null;
   var cobjGate = null;
   function loadStream() {<%if objForm.Fields("DTA_StreamAction").Value = "*CREATE" then%>
      cobjStream = new clsStream('S','','*TOP','','1');
      addHeader();<%else%>
      var objData = new Array();<%for i = objSelection.ListLower("NODES") to objSelection.ListUpper("NODES")%>
      objData[<%=i%>] = new clsData('<%=objSelection.ListValue01("NODES",i)%>','<%=objSelection.ListValue02("NODES",i)%>','<%=objSelection.ListValue03("NODES",i)%>','<%=objSelection.ListValue04("NODES",i)%>','<%=replace(objSelection.ListValue05("NODES",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue06("NODES",i)%>','<%=replace(objSelection.ListValue07("NODES",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue08("NODES",i)%>','<%=replace(objSelection.ListValue09("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue10("NODES",i), "'", "\'", 1, -1, 1)%>');<%next%>
      var intPidx = 0;
      var intTidx = 0;
      var objParent = new Array();
      var objWork = null;
      var objParam = null;
      var objTask = null;
      var objGate = null;
      var objDepend = null;
      var objEvent = null;
      for (var i=0;i<objData.length;i++) {
         objWork = objData[i];
         if (objWork.strtyp == 'S') {
            cobjStream = new clsStream(objWork.strtyp,objWork.strpar,objWork.strcod,objWork.strtxt,objWork.strlck);
            intPidx = 0;
            intTidx = 0;
            objParent[intTidx] = cobjStream;
         } else if (objWork.strtyp == 'P') {
            objParam = new clsParam(objWork.strcod,objWork.strtxt,objWork.strlck);
            intPidx = objWork.strdep;
            objParent[intPidx].parary[objParent[intPidx].parary.length] = objParam;
         } else if (objWork.strtyp == 'T') {
            objTask = new clsTask(objWork.strtyp,objWork.strpar,objWork.strcod,objWork.strtxt);
            intPidx = objWork.strdep - 1;
            intTidx = objWork.strdep - 0;
            objParent[intPidx].tskary[objParent[intPidx].tskary.length] = objTask;
            objParent[intTidx] = objTask;
         } else if (objWork.strtyp == 'G') {
            objGate = new clsGate(objWork.strtyp,objWork.strpar,objWork.strcod,objWork.strtxt);
            intPidx = objWork.strdep - 1;
            intTidx = objWork.strdep - 0;
            objParent[intPidx].gteary[objParent[intPidx].gteary.length] = objGate;
            objParent[intTidx] = objGate;
         } else if (objWork.strtyp == 'D') {
            objDepend = new clsDepend(objWork.strcod);
            intPidx = objWork.strdep;
            objParent[intPidx].depary[objParent[intPidx].depary.length] = objDepend;
         } else if (objWork.strtyp == 'E') {
            objEvent = new clsEvent(objWork.strtyp,objWork.strpar,objWork.strcod,objWork.strtxt,objWork.strlck,objWork.strprc,objWork.strgrp,objWork.stralt,objWork.strema);
            intPidx = objWork.strdep - 1;
            objParent[intPidx].evtary[objParent[intPidx].evtary.length] = objEvent;
         }
      }
      paintStream();<%end if%>
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
   function clsStream(strType,strParent,strCode,strText,strStat) {
      this.strtyp = 'S';
      this.strpar = strParent;
      this.strcod = strCode;
      this.strtxt = strText;
      this.strsts = strStat;
      this.strlef = 0;
      this.strrig = 0;
      this.strtop = 0;
      this.strbot = 0;
      this.strwrk = 0;
      this.strlil = 0;
      this.strlit = 0;
      this.strlib = 0;
      this.parary = new Array();
      this.tskary = new Array();
      this.gteary = new Array();
   }
   function clsTask(strType,strParent,strCode,strText) {
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
   function clsGate(strType,strParent,strCode,strText) {
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
   function clsEvent(strType,strParent,strCode,strText,strLock,strProc,strGroup,strAlert,strEmail) {
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
   function clsParam(strCode,strText,strValue) {
      this.strcod = strCode;
      this.strtxt = strText;
      this.strval = strValue;
   }
   function clsDepend(strCode) {
      this.strcod = strCode;
      this.strgat = null;
   }
   function paintStream() {
      var objCanvas = document.getElementById('divStream');
      while(objCanvas.firstChild) {
         objCanvas.removeChild(objCanvas.firstChild);
      }
      cobjSelect = null;
      cobjTarget = null;
      cobjGate = null;
      var objDiv;
      var objFont;
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
      objDiv.appendChild(document.createTextNode(cobjStream.strpar));
      objDiv.appendChild(document.createElement('br'));
      objDiv.appendChild(document.createTextNode(cobjStream.strtxt));
      if (cobjStream.parary.length > 0) {
         objDiv.appendChild(document.createElement('br'));
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'normal';
         objFont.appendChild(document.createTextNode('Parameters'));
         objDiv.appendChild(objFont);
         for (var i=0;i<cobjStream.parary.length;i++) {
            objDiv.appendChild(document.createElement('br'));
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'normal';
            if (cobjStream.parary[i].strval != '') {
               objFont.appendChild(document.createTextNode('('+cobjStream.parary[i].strcod+') '+cobjStream.parary[i].strtxt+' ('+cobjStream.parary[i].strval+')'));
            } else {
               objFont.appendChild(document.createTextNode('('+cobjStream.parary[i].strcod+') '+cobjStream.parary[i].strtxt+' (*SUPPLIED)'));
            }
            objDiv.appendChild(objFont);
         }
      }
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
      objDiv.appendChild(document.createTextNode(objTask.strcod));
      objDiv.appendChild(document.createElement('br'));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'bold';
      objFont.appendChild(document.createTextNode(objTask.strtxt));
      objDiv.appendChild(objFont);
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
      var objFont;
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
      objFont.appendChild(document.createTextNode('Dependencies'));
      objDiv.appendChild(objFont);
      for (var i=0;i<objGate.depary.length;i++) {
         objDiv.appendChild(document.createElement('br'));
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'normal';
         objFont.appendChild(document.createTextNode(objGate.depary[i].strcod));
         objDiv.appendChild(objFont);
      }
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
      var objFont;
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
      objDiv.appendChild(document.createElement('br'));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'bold';
      objFont.appendChild(document.createTextNode('Procedure: '));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode(objEvent.strprc));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'bold';
      objFont.appendChild(document.createTextNode(' Lock: '));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode(objEvent.strlck));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'bold';
      objFont.appendChild(document.createTextNode(' Job Group: '));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode(objEvent.strgrp));
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
      for (var i=0;i<objYarra.length;i++) {
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
      for (var i=0;i<objYarra.length;i++) {
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
      if (objSelectObject.strtyp == 'S') {
         alert('Stream cannot be moved');
         return;
      }
      if (objSelectObject.strtyp == 'G') {
         alert('Gate cannot be moved');
         return;
      }
      if (objSelectObject.strtyp == 'E' && objTargetObject.strtyp != 'T') {
         alert('Event can only be moved to another task');
         return;
      }
      var objWork = null;
      if (objSelectObject.strtyp == 'T') {
         objWork = objSelectParent.tskary;
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
      objSelectObject.strpar = objTargetObject.strcod;
      cobjTarget.style.backgroundColor = cobjTarget.getAttribute('bakcol');
      cstrTargetType = null;
      cstrTargetCode = null;
      paintStream();
   }
   function addHeader() {
      cintMode = 'A';
      var objDspStream = document.getElementById('dspStream');
      var objDspHeader = document.getElementById('dspHeader');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'none';
      objDspStream.style.visibility = 'hidden';
      objDspHeader.style.display = 'block';
      objDspHeader.style.visibility = 'visible';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
      document.getElementById('hedHeader').innerText = 'Create Stream';
      document.getElementById('INP_StrCode').value = '';
      document.getElementById('INP_StrCode').disabled = false;
      document.getElementById('INP_StrText').value = '';
      document.getElementById('INP_StrCode').focus();
      var objWork = document.getElementById('INP_StrStat')
      for (var i=0;i<objWork.options.length;i++) {
         if (objWork.options[i].value == '1') {
            objWork.options[i].selected = true;
            break;
         }
      }
      paintParam();
   }
   function cancelHeader() {
      if (cintMode == 'A') {
         doCancel();
         return;
      }
      var objDspStream = document.getElementById('dspStream');
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
   }
   function acceptHeader() {
      if (!processForm()) {return;}
      var objSelectObject;
      var strStrCode;
      var strStrText;
      var strStrStat;
      var strMessage = '';
      strStrCode = document.getElementById('INP_StrCode').value.toUpperCase();
      strStrText = document.getElementById('INP_StrText').value;
      strStrStat = document.getElementById('INP_StrStat').options[document.getElementById('INP_StrStat').selectedIndex].value;
      if (strStrCode == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Stream code must be entered';
      }
      if (strStrText == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Stream text must be entered';
      }
      for (var i=0;i<cobjStream.parary.length;i++) {
         cobjStream.parary[i].strcod = document.getElementById('INP_ParCode' + i).value.toUpperCase();
         cobjStream.parary[i].strtxt = document.getElementById('INP_ParText' + i).value;
         cobjStream.parary[i].strval = document.getElementById('INP_ParValu' + i).value;
         if (cobjStream.parary[i].strcod == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Parameter code must be entered';
         }
         if (cobjStream.parary[i].strtxt == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Parameter text must be entered';
         }
         if (cobjStream.parary[i].strval == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Parameter value must be entered';
         }
         var bolFound = false;
         for (var j=0;j<cobjStream.parary.length;j++) {
            if (i != j && cobjStream.parary[i].strcod == cobjStream.parary[j].strcod) {
               bolFound = true;
               break;
            }
         }
         if (bolFound == true) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Parameter code (' + cobjStream.parary[i].strcod + ') already exists';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintMode == 'A') {
         objSelectObject = cobjStream;
      } else {
         objSelectObject = cobjSelect.getAttribute('objref');
      }
      objSelectObject.strpar = strStrCode;
      objSelectObject.strtxt = strStrText;
      objSelectObject.strsts = strStrStat;
      cstrSelectCode = strStrCode;
      var objDspStream = document.getElementById('dspStream');
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
      objDspTask.style.display = 'none';
      objDspTask.style.visibility = 'hidden';
      objDspGate.style.display = 'none';
      objDspGate.style.visibility = 'hidden';
      objDspEvent.style.display = 'none';
      objDspEvent.style.visibility = 'hidden';
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
      var objDspHeader = document.getElementById('dspHeader');
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'none';
      objDspStream.style.visibility = 'hidden';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
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
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
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
         objSelectObject.tskary[objSelectObject.tskary.length] = new clsTask('T',objSelectObject.strcod,strTskCode,strTskText);
      } else {
         objSelectObject.strcod = strTskCode;
         objSelectObject.strtxt = strTskText;
         cstrSelectCode = strTskCode;
      }
      var objDspStream = document.getElementById('dspStream');
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
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
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'none';
      objDspStream.style.visibility = 'hidden';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
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
      cobjGate = new clsGate('G','','','');
      paintDepend();
   }
   function cancelGate() {
      var objDspStream = document.getElementById('dspStream');
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
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
      for (var i=0;i<cobjGate.depary.length;i++) {
         cobjGate.depary[i].strcod = document.getElementById('INP_DepCode' + i).value.toUpperCase();
         if (cobjGate.depary[i].strcod == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Task code must be entered';
         }
         var bolFound = false;
         for (var j=0;j<cobjGate.depary.length;j++) {
            if (i != j && cobjGate.depary[i].strcod == cobjGate.depary[j].strcod) {
               bolFound = true;
               break;
            }
         }
         if (bolFound == true) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Task code (' + cobjGate.depary[i].strcod + ') already selected';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (cintMode == 'A') {
         cobjGate.strpar = objSelectObject.strcod;
         cobjGate.strcod = strGteCode;
         cobjGate.strtxt = strGteText;
         objSelectObject.gteary[objSelectObject.gteary.length] = cobjGate;
      } else {
         objSelectObject.strcod = strGteCode;
         objSelectObject.strtxt = strGteText;
         objSelectObject.depary.length = cobjGate.depary.length;
         for (var i=0;i<cobjGate.depary.length;i++) {
            objSelectObject.depary[i] = cobjGate.depary[i];
         }
         cstrSelectCode = strGteCode;
      }
      var objDspStream = document.getElementById('dspStream');
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
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
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'none';
      objDspStream.style.visibility = 'hidden';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
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
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
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
         objSelectObject.evtary[objSelectObject.evtary.length] = new clsEvent('E',objSelectObject.strcod,strEvtCode,strEvtText,strEvtLock,strEvtProc,strJobGroup,strOprAlert,strEmaGroup);
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
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      objDspStream.style.display = 'block';
      objDspStream.style.visibility = 'visible';
      objDspHeader.style.display = 'none';
      objDspHeader.style.visibility = 'hidden';
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
      var objDspHeader = document.getElementById('dspHeader')
      var objDspTask = document.getElementById('dspTask');
      var objDspGate = document.getElementById('dspGate');
      var objDspEvent = document.getElementById('dspEvent');
      var objSelectObject = cobjSelect.getAttribute('objref');
      if (objSelectObject.strtyp == 'S') {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspHeader.style.display = 'block';
         objDspHeader.style.visibility = 'visible';
         objDspTask.style.display = 'none';
         objDspTask.style.visibility = 'hidden';
         objDspGate.style.display = 'none';
         objDspGate.style.visibility = 'hidden';
         objDspEvent.style.display = 'none';
         objDspEvent.style.visibility = 'hidden';
         document.getElementById('hedHeader').innerText = 'Update Stream';
         document.getElementById('INP_StrCode').value = objSelectObject.strpar;
         document.getElementById('INP_StrCode').disabled = true;
         document.getElementById('INP_StrText').value = objSelectObject.strtxt;
         document.getElementById('INP_StrText').focus();
         var objWork = document.getElementById('INP_StrStat')
         for (var i=0;i<objWork.options.length;i++) {
            if (objWork.options[i].value == cobjStream.strsts) {
               objWork.options[i].selected = true;
               break;
            }
         }
         paintParam();
      } else if (objSelectObject.strtyp == 'T') {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspHeader.style.display = 'none';
         objDspHeader.style.visibility = 'hidden';
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
         objDspHeader.style.display = 'none';
         objDspHeader.style.visibility = 'hidden';
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
         cobjGate = objSelectObject;
         paintDepend();
      } else if (objSelectObject.strtyp == 'E') {
         objDspStream.style.display = 'none';
         objDspStream.style.visibility = 'hidden';
         objDspHeader.style.display = 'none';
         objDspHeader.style.visibility = 'hidden';
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
   function addParam() {
      for (var i=0;i<cobjStream.parary.length;i++) {
         cobjStream.parary[i].strcod = document.getElementById('INP_ParCode' + i).value.toUpperCase();
         cobjStream.parary[i].strtxt = document.getElementById('INP_ParText' + i).value;
         cobjStream.parary[i].strval = document.getElementById('INP_ParValu' + i).value;
      }
      cobjStream.parary[cobjStream.parary.length] = new clsParam('','','');
      paintParam();
   }
   function deleteParam(lngIndex) {
      for (var i=0;i<cobjStream.parary.length;i++) {
         cobjStream.parary[i].strcod = document.getElementById('INP_ParCode' + i).value.toUpperCase();
         cobjStream.parary[i].strtxt = document.getElementById('INP_ParText' + i).value;
         cobjStream.parary[i].strval = document.getElementById('INP_ParValu' + i).value;
      }
      var objYarra = new Array();
      var j = 0;
      for (var i=0;i<cobjStream.parary.length;i++) {
         if (i != lngIndex) {
            objYarra[j] = cobjStream.parary[i];
            j++;
         }
      }
      cobjStream.parary.length = cobjStream.parary.length - 1;
      for (var i=0;i<objYarra.length;i++) {
         cobjStream.parary[i] = objYarra[i];
      }
      paintParam();
   }
   function paintParam() {
      var strText = '<table align=center border=0 cellpadding=0 cellspacing=2 cols=4>';
      strText = strText + '<tr>';
      strText = strText + '<td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<a class="clsSelect" href="javascript:addParam();">Add</a>&nbsp;</nobr></td>';
      strText = strText + '<td class="clsLabelBB" align=left colspan=1 nowrap><nobr>&nbsp;Code&nbsp;</nobr></td>';
      strText = strText + '<td class="clsLabelBB" align=left colspan=1 nowrap><nobr>&nbsp;Text&nbsp;</nobr></td>';
      strText = strText + '<td class="clsLabelBB" align=left colspan=1 nowrap><nobr>&nbsp;Value&nbsp;(Fixed Value or *SUPPLIED)</nobr></td>';
      strText = strText + '</tr>';
      for (var i=0;i<cobjStream.parary.length;i++) {
         strText = strText + '<tr>';
         strText = strText + '<td class="clsLabelBB" align=left colspan=1 valign=center nowrap><nobr>&nbsp;<a class="clsSelect" href="javascript:deleteParam(' + i + ');">Delete&nbsp;</a></nobr></td>';
         strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_ParCode' + i + '" size="32" maxlength="32" value="' + cobjStream.parary[i].strcod + '" onFocus="setSelect(this);"></nobr></td>';
         strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="INP_ParText' + i + '" size="64" maxlength="128" value="' + cobjStream.parary[i].strtxt + '" onFocus="setSelect(this);"></nobr></td>';
         strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" type="text" name="INP_ParValu' + i + '" size="64" maxlength="64" value="' + cobjStream.parary[i].strval + '" onFocus="setSelect(this);"></nobr></td>';
         strText = strText + '</tr>';
      }
      strText = strText + '</table>';
      document.getElementById('tabParam').innerHTML = strText;
   }
   function addDepend() {
      for (var i=0;i<cobjGate.depary.length;i++) {
         cobjGate.depary[i].strcod = document.getElementById('INP_DepCode' + i).value.toUpperCase();
      }
      cobjGate.depary[cobjGate.depary.length] = new clsDepend('');
      paintDepend();
   }
   function deleteDepend(lngIndex) {
      for (var i=0;i<cobjGate.depary.length;i++) {
         cobjGate.depary[i].strcod = document.getElementById('INP_DepCode' + i).value.toUpperCase();
      }
      var objYarra = new Array();
      var j = 0;
      for (var i=0;i<cobjGate.depary.length;i++) {
         if (i != lngIndex) {
            objYarra[j] = cobjGate.depary[i];
            j++;
         }
      }
      cobjGate.depary.length = cobjGate.depary.length - 1;
      for (var i=0;i<objYarra.length;i++) {
         cobjGate.depary[i] = objYarra[i];
      }
      paintDepend();
   }
   function paintDepend() {
      var strText = '<table align=center border=0 cellpadding=0 cellspacing=2 cols=2>';
      strText = strText + '<tr>';
      strText = strText + '<td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<a class="clsSelect" href="javascript:addDepend();">Add</a>&nbsp;</nobr></td>';
      strText = strText + '<td class="clsLabelBB" align=left colspan=1 nowrap><nobr>&nbsp;Task&nbsp;</nobr></td>';
      strText = strText + '</tr>';
      for (var i=0;i<cobjGate.depary.length;i++) {
         strText = strText + '<tr>';
         strText = strText + '<td class="clsLabelBB" align=left colspan=1 valign=center nowrap><nobr>&nbsp;<a class="clsSelect" href="javascript:deleteDepend(' + i + ');">Delete&nbsp;</a></nobr></td>';
         strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_DepCode' + i + '" size="32" maxlength="32" value="' + cobjGate.depary[i].strcod + '" onFocus="setSelect(this);"></nobr></td>';
         strText = strText + '</tr>';
      }
      strText = strText + '</table>';
      document.getElementById('tabDepend').innerHTML = strText;
   }
   function editStream() {
      if (cobjStream.strpar == '') {
         if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
         cstrMessage = cstrMessage + 'Stream code must be entered';
      }
      if (cobjStream.strtxt == '') {
         if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
         cstrMessage = cstrMessage + 'Stream text must be entered';
      }
      if (cobjStream.tskary.length == 0) {
         if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
         cstrMessage = cstrMessage + 'Stream must have at least one task';
      }
      var bolFound = false;
      for (var i=0;i<cobjStream.gteary.length;i++) {
         for (var j=0;j<cobjStream.gteary[i].depary.length;j++) {
            cobjStream.gteary[i].depary[j].strgat = null;
            bolFound = editDepend(cobjStream,cobjStream.gteary[i].depary[j].strcod);
            if (bolFound == false) {
               for (var k=0;k<cobjStream.gteary.length;k++) {
                  bolFound = editDepend(cobjStream.gteary[k],cobjStream.gteary[i].depary[j].strcod);
                  if (bolFound == true) {
                     cobjStream.gteary[i].depary[j].strgat = cobjStream.gteary[k].strcod;
                     break;
                  }
               }
            }
            if (bolFound == false) {
               if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
               cstrMessage = cstrMessage + 'Gate ('+cobjStream.gteary[i].strtxt+') dependency ('+cobjStream.gteary[i].depary[j].strcod+') does not exist';
            }
         }
      }
      for (var i=0;i<cobjStream.gteary.length;i++) {
         for (var j=0;j<cobjStream.gteary[i].depary.length;j++) {
            if (cobjStream.gteary[i].depary[j].strgat != null) {
               if (cobjStream.gteary[i].depary[j].strgat == cobjStream.gteary[i].strcod) {
                  if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
                  cstrMessage = cstrMessage + 'Gate ('+cobjStream.gteary[i].strtxt+') cannot be both dependent on and the parent of task ('+cobjStream.gteary[i].depary[j].strcod+')';
               } else {
                  bolFound = false;
                  for (var k=0;k<cobjStream.gteary.length;k++) {
                     if (cobjStream.gteary[k].strcod == cobjStream.gteary[i].depary[j].strgat) {
                        for (var l=0;l<cobjStream.gteary[k].depary.length;l++) {
                           if (cobjStream.gteary[k].depary[l].strgat == cobjStream.gteary[i].strcod) {
                              if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
                              cstrMessage = cstrMessage + 'Gate ('+cobjStream.gteary[i].strtxt+') has cross dependency with gate ('+cobjStream.gteary[k].strtxt+') task ('+cobjStream.gteary[k].depary[l].strcod+')';
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<ICS_STREAM';
      strXML = strXML+' CODE="'+fixAttribute(cobjStream.strpar)+'"';
      strXML = strXML+' TEXT="'+fixAttribute(cobjStream.strtxt)+'"';
      strXML = strXML+' STATUS="'+fixAttribute(cobjStream.strsts)+'"';
      strXML = strXML+'>';
      if (cobjStream.parary.length > 0) {
         for (var i=0;i<cobjStream.parary.length;i++) {
            strXML = strXML+'<NODE TYPE="P"';
            strXML = strXML+' CODE="'+fixAttribute(cobjStream.parary[i].strcod)+'"';
            strXML = strXML+' TEXT="'+fixAttribute(cobjStream.parary[i].strtxt)+'"';
            strXML = strXML+' VALUE="'+fixAttribute(cobjStream.parary[i].strval)+'"';
            strXML = strXML+'/>'
        }
      }
      for (var i=0;i<cobjStream.tskary.length;i++) {
         strXML = strXML + editTask(cobjStream.tskary[i],(i+1));
      }
      for (var i=0;i<cobjStream.gteary.length;i++) {
         strXML = strXML + editGate(cobjStream.gteary[i],(i+1));
      }
      strXML = strXML+'</ICS_STREAM>';
      return strXML;
   }
   function editTask(objTask,intSeqn) {
      if (objTask.evtary.length == 0) {
         if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
         cstrMessage = cstrMessage + 'At least one event must be created for task('+objTask.strtxt+')';
      }
      var strXML = '<NODE';
      strXML = strXML+' TYPE="'+objTask.strtyp+'"';
      strXML = strXML+' CODE="'+fixAttribute(objTask.strcod)+'"';
      strXML = strXML+' PARENT="'+fixAttribute(objTask.strpar)+'"';
      strXML = strXML+' TEXT="'+fixAttribute(objTask.strtxt)+'"';
      strXML = strXML+' SEQN="'+intSeqn+'"';
      strXML = strXML+'/>';
      for (var i=0;i<objTask.evtary.length;i++) {
         strXML = strXML + editEvent(objTask.evtary[i],(i+1));
      }
      for (var i=0;i<objTask.tskary.length;i++) {
         strXML = strXML + editTask(objTask.tskary[i],(i+1));
      }
      return strXML;
   }
   function editGate(objGate,intSeqn) {
      if (objGate.tskary.length == 0) {
         if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
         cstrMessage = cstrMessage + 'At least one task must be created for gate ('+objGate.strtxt+')';
      }
      if (objGate.depary.length == 0) {
         if (cstrMessage != '') {cstrMessage = cstrMessage + '\r\n';}
         cstrMessage = cstrMessage + 'At least dependancy task must be specified for gate ('+objGate.strtxt+')';
      }
      for (var i=0;i<objGate.depary.length;i++) {
      }
      var strXML = '<NODE';
      strXML = strXML+' TYPE="'+objGate.strtyp+'"';
      strXML = strXML+' CODE="'+fixAttribute(objGate.strcod)+'"';
      strXML = strXML+' PARENT="'+fixAttribute(objGate.strpar)+'"';
      strXML = strXML+' TEXT="'+fixAttribute(objGate.strtxt)+'"';
      strXML = strXML+' SEQN="'+intSeqn+'"';
      strXML = strXML+'/>';
      for (var i=0;i<objGate.depary.length;i++) {
         strXML = strXML+'<NODE';
         strXML = strXML+' TYPE="D"';
         strXML = strXML+' CODE="'+fixAttribute(objGate.depary[i].strcod)+'"';
         strXML = strXML+' PARENT="'+fixAttribute(objGate.strcod)+'"';
         strXML = strXML+'/>'
      }
      for (var i=0;i<objGate.tskary.length;i++) {
         strXML = strXML + editTask(objGate.tskary[i],(i+1));
      }
      return strXML;
   }
   function editEvent(objEvent,intSeqn) {
      var strXML = '<NODE';
      strXML = strXML+' TYPE="'+objEvent.strtyp+'"';
      strXML = strXML+' CODE="'+fixAttribute(objEvent.strcod)+'"';
      strXML = strXML+' PARENT="'+fixAttribute(objEvent.strpar)+'"';
      strXML = strXML+' TEXT="'+fixAttribute(objEvent.strtxt)+'"';
      strXML = strXML+' LOCK="'+fixAttribute(objEvent.strlck)+'"';
      strXML = strXML+' PROC="'+fixAttribute(objEvent.strprc)+'"';
      strXML = strXML+' GROUP="'+fixAttribute(objEvent.strgrp)+'"';
      strXML = strXML+' ALERT="'+fixAttribute(objEvent.stralt)+'"';
      strXML = strXML+' EMAIL="'+fixAttribute(objEvent.strema)+'"';
      strXML = strXML+' SEQN="'+intSeqn+'"';
      strXML = strXML+'/>';
      return strXML;
   }
   function editDepend(objParent,strCode) {
      var bolFound = false;
      for (var i=0;i<objParent.tskary.length;i++) {
         if (objParent.tskary[i].strcod == strCode) {
            bolFound = true;
            break;
         }
      }
      if (!bolFound) {
         for (var i=0;i<objParent.tskary.length;i++) {
            bolFound = editDepend(objParent.tskary[i],strCode);
            if (bolFound) {
               break;
            }
         }
      }
      return bolFound;
   }
   function checkStream() {
      var objHidden = null;
      var intPart = 0;
      var aryStream = null;
      var bolFound = false;
      var strXML = editStream();
      if (cstrMessage == '') {
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
   <table id="dspHeader" class="clsGrid02" style="display:none;visibility:hidden" align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedHeader" class="clsFunction" align=center colspan=2 nowrap><nobr>Stream Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="INP_StrCode" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Text:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_StrText" size="64" maxlength="128" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Stream Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="INP_StrStat">
               <option value="0">Inactive
               <option value="1">Active
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Parameters&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" id="tabParam" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:cancelHeader();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:acceptHeader();">&nbsp;Accept&nbsp;</a></nobr></td>
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
         <td class="clsLabelHB" align=center colspan=2 nowrap><nobr>&nbsp;Dependencies&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" id="tabDepend" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
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
</form>
</body>
</html>