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
   function doBack() {
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'SELECT';
      document.main.submit();
   }
   function doRefresh() {
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'REVIEW';
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
   var cobjStream = null;
   function loadStream() {
      var objData = new Array();<%for i = objSelection.ListLower("NODES") to objSelection.ListUpper("NODES")%>
      objData[<%=i%>] = new clsData('<%=objSelection.ListValue01("NODES",i)%>','<%=objSelection.ListValue02("NODES",i)%>','<%=replace(objSelection.ListValue03("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue04("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue05("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue06("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue07("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue08("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue09("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue10("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue11("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue12("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue13("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue14("NODES",i), "'", "\'", 1, -1, 1)%>','<%=replace(objSelection.ListValue15("NODES",i), "'", "\'", 1, -1, 1)%>');<%next%>
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
            cobjStream = new clsStream(objWork.strtyp,objWork.str001,objWork.str002,objWork.str003,objWork.str004,objWork.str005,objWork.str006,objWork.str007,objWork.str008,objWork.str009);
            intPidx = 0;
            intTidx = 0;
            objParent[intTidx] = cobjStream;
         } else if (objWork.strtyp == 'P') {
            objParam = new clsParam(objWork.str001,objWork.str002,objWork.str003);
            intPidx = objWork.strdep;
            objParent[intPidx].parary[objParent[intPidx].parary.length] = objParam;
         } else if (objWork.strtyp == 'T') {
            objTask = new clsTask(objWork.strtyp,objWork.str001,objWork.str002,objWork.str003,objWork.str004,objWork.str005);
            intPidx = objWork.strdep - 1;
            intTidx = objWork.strdep - 0;
            objParent[intPidx].tskary[objParent[intPidx].tskary.length] = objTask;
            objParent[intTidx] = objTask;
         } else if (objWork.strtyp == 'G') {
            objGate = new clsGate(objWork.strtyp,objWork.str001,objWork.str002,objWork.str003,objWork.str004,objWork.str005);
            intPidx = objWork.strdep - 1;
            intTidx = objWork.strdep - 0;
            objParent[intPidx].gteary[objParent[intPidx].gteary.length] = objGate;
            objParent[intTidx] = objGate;
         } else if (objWork.strtyp == 'D') {
            objDepend = new clsDepend(objWork.str002);
            intPidx = objWork.strdep;
            objParent[intPidx].depary[objParent[intPidx].depary.length] = objDepend;
         } else if (objWork.strtyp == 'E') {
            objEvent = new clsEvent(objWork.strtyp,objWork.str001,objWork.str002,objWork.str003,objWork.str004,objWork.str005,objWork.str006,objWork.str007,objWork.str008,objWork.str009,objWork.str010,objWork.str011,objWork.str012,objWork.str013);
            intPidx = objWork.strdep - 1;
            objParent[intPidx].evtary[objParent[intPidx].evtary.length] = objEvent;
         }
      }
      paintStream();
   }
   function clsData(strdep,strtyp,str001,str002,str003,str004,str005,str006,str007,str008,str009,str010,str011,str012,str013) {
      this.strdep = strdep;
      this.strtyp = strtyp;
      this.str001 = str001;
      this.str002 = str002;
      this.str003 = str003;
      this.str004 = str004;
      this.str005 = str005;
      this.str006 = str006;
      this.str007 = str007;
      this.str008 = str008;
      this.str009 = str009;
      this.str010 = str010;
      this.str011 = str011;
      this.str012 = str012;
      this.str013 = str013;
   }
   function clsStream(strtyp,str001,str002,str003,str004,str005,str006,str007,str008,str009) {
      this.strtyp = strtyp;
      this.strcod = str001;
      this.strtxt = str002;
      this.strsqn = str003;
      this.stretx = str004;
      this.strsts = str005;
      this.strrqs = str006;
      this.strlod = str007;
      this.strstr = str008;
      this.strend = str009;
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
   function clsTask(strtyp,str001,str002,str003,str004,str005) {
      this.strtyp = strtyp;
      this.strcod = str001;
      this.strtxt = str002;
      this.strsts = str003;
      this.strstr = str004;
      this.strend = str005;
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
   function clsGate(strtyp,str001,str002,str003,str004,str005) {
      this.strtyp = strtyp;
      this.strcod = str001;
      this.strtxt = str002;
      this.strsts = str003;
      this.strstr = str004;
      this.strend = str005;
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
   function clsEvent(strtyp,str001,str002,str003,str004,str005,str006,str007,str008,str009,str010,str011,str012,str013) {
      this.strtyp = strtyp;
      this.strcod = str001;
      this.strtxt = str002;
      this.strlck = str003;
      this.strprc = str004;
      this.strgrp = str005;
      this.stralt = str006;
      this.strema = str007;
      this.strsts = str008;
      this.strque = str009;
      this.stropn = str010;
      this.strstr = str011;
      this.strend = str012;
      this.strmsg = str013;
      this.strlef = 0;
      this.strrig = 0;
      this.strtop = 0;
      this.strbot = 0;
   }
   function clsParam(str001,str002,str003) {
      this.strcod = str001;
      this.strtxt = str002;
      this.strval = str003;
   }
   function clsDepend(str001) {
      this.strcod = str001;
   }
   function paintStream() {
      var objCanvas = document.getElementById('divStream');
      while(objCanvas.firstChild) {
         objCanvas.removeChild(objCanvas.firstChild);
      }
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
      objDiv.appendChild(document.createTextNode(cobjStream.strcod));
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
               objFont.appendChild(document.createTextNode('('+cobjStream.parary[i].strcod+') '+cobjStream.parary[i].strtxt+' (*NONE)'));
            }
            objDiv.appendChild(objFont);
         }
      }
      objDiv.appendChild(document.createElement('br'));
      objDiv.appendChild(document.createTextNode('('+cobjStream.strsqn + ') ' + cobjStream.stretx));
      objDiv.appendChild(document.createElement('br'));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'bold';
      objFont.appendChild(document.createTextNode('Status: '));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode(cobjStream.strsts));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'bold';
      objFont.appendChild(document.createTextNode(' Request: '));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode(cobjStream.strrqs));
      objDiv.appendChild(objFont);
      objDiv.appendChild(document.createElement('br'));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'bold';
      objFont.appendChild(document.createTextNode('Loaded: '));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode(cobjStream.strlod));
      objDiv.appendChild(objFont);
      if (cobjStream.strsts != '*PENDING') {
         objDiv.appendChild(document.createElement('br'));
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'bold';
         objFont.appendChild(document.createTextNode('Started: '));
         objDiv.appendChild(objFont);
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'normal';
         objFont.appendChild(document.createTextNode(cobjStream.strstr));
         objDiv.appendChild(objFont);
         if (cobjStream.strsts == '*COMPLETED' || cobjStream.strsts == '*CANCELLED') {
            objDiv.appendChild(document.createElement('br'));
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'bold';
            objFont.appendChild(document.createTextNode('Ended: '));
            objDiv.appendChild(objFont);
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'normal';
            objFont.appendChild(document.createTextNode(cobjStream.strend));
            objDiv.appendChild(objFont);
         }
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
      var objFont;
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
      if (objTask.strsts == '*OPENED') {
         objDiv.style.backgroundColor = '#c0ffc0';
      }
      if (objTask.strsts == '*COMPLETED') {
         objDiv.style.backgroundColor = '#f5f5f5';
      }
      if (objTask.strsts == '*CANCELLED') {
         objDiv.style.backgroundColor = '#ffc0ff';
      }
      if (objTask.strsts == '*FAILED') {
         objDiv.style.backgroundColor = '#ffc0c0';
      }
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
      objDiv.appendChild(document.createElement('br'));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'bold';
      objFont.appendChild(document.createTextNode('Status: '));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode(objTask.strsts));
      objDiv.appendChild(objFont);
      if (objTask.strsts != '*PENDING' && objTask.strsts != '*CANCELLED') {
         objDiv.appendChild(document.createElement('br'));
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'bold';
         objFont.appendChild(document.createTextNode('Started: '));
         objDiv.appendChild(objFont);
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'normal';
         objFont.appendChild(document.createTextNode(objTask.strstr));
         objDiv.appendChild(objFont);
         if (objTask.strsts == '*COMPLETED' || objTask.strsts == '*FAILED') {
            objDiv.appendChild(document.createElement('br'));
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'bold';
            objFont.appendChild(document.createTextNode('Ended: '));
            objDiv.appendChild(objFont);
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'normal';
            objFont.appendChild(document.createTextNode(objTask.strend));
            objDiv.appendChild(objFont);
         }
      }
      if (objTask.strsts == '*CANCELLED') {
         objDiv.appendChild(document.createElement('br'));
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'bold';
         objFont.appendChild(document.createTextNode('Cancelled: '));
         objDiv.appendChild(objFont);
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'normal';
         objFont.appendChild(document.createTextNode(objTask.strend));
         objDiv.appendChild(objFont);
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
      if (objGate.strsts == '*COMPLETED') {
         objDiv.style.backgroundColor = '#f5f5f5';
      }
      if (objGate.strsts == '*CANCELLED') {
         objDiv.style.backgroundColor = '#ffc0ff';
      }
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
      objFont.style.fontWeight = 'bold';
      objFont.appendChild(document.createTextNode('Status: '));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode(objGate.strsts));
      objDiv.appendChild(objFont);
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
      if (objGate.strsts == '*COMPLETED') {
         objDiv.appendChild(document.createElement('br'));
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'bold';
         objFont.appendChild(document.createTextNode('Opened: '));
         objDiv.appendChild(objFont);
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'normal';
         objFont.appendChild(document.createTextNode(objGate.strstr));
         objDiv.appendChild(objFont);
      }
      if (objGate.strsts == '*CANCELLED') {
         objDiv.appendChild(document.createElement('br'));
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'bold';
         objFont.appendChild(document.createTextNode('Cancelled: '));
         objDiv.appendChild(objFont);
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'normal';
         objFont.appendChild(document.createTextNode(objGate.strstr));
         objDiv.appendChild(objFont);
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
      if (objEvent.strsts == '*QUEUED') {
         objDiv.style.backgroundColor = '#d5d6f9';
      }
      if (objEvent.strsts == '*OPENED') {
         objDiv.style.backgroundColor = '#c0ffff';
      }
      if (objEvent.strsts == '*WORKING') {
         objDiv.style.backgroundColor = '#c0ffc0';
      }
      if (objEvent.strsts == '*COMPLETED') {
         objDiv.style.backgroundColor = '#f5f5f5';
      }
      if (objEvent.strsts == '*CANCELLED') {
         objDiv.style.backgroundColor = '#ffc0ff';
      }
      if (objEvent.strsts == '*FAILED') {
         objDiv.style.backgroundColor = '#ffc0c0';
      }
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
      objDiv.appendChild(document.createElement('br'));
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'bold';
      objFont.appendChild(document.createTextNode('Status: '));
      objDiv.appendChild(objFont);
      objFont = document.createElement('font');
      objFont.style.fontFamily = 'Verdana,sans-serif';
      objFont.style.fontSize = '8pt';
      objFont.style.fontWeight = 'normal';
      objFont.appendChild(document.createTextNode(objEvent.strsts));
      objDiv.appendChild(objFont);
      if (objEvent.strsts != '*PENDING' && objEvent.strsts != '*CANCELLED') {
         objDiv.appendChild(document.createElement('br'));
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'bold';
         objFont.appendChild(document.createTextNode('Queued: '));
         objDiv.appendChild(objFont);
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'normal';
         objFont.appendChild(document.createTextNode(objEvent.strque));
         objDiv.appendChild(objFont);
         if (objEvent.strsts != '*QUEUED') {
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'bold';
            objFont.appendChild(document.createTextNode(' Opened: '));
            objDiv.appendChild(objFont);
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'normal';
            objFont.appendChild(document.createTextNode(objEvent.stropn));
            objDiv.appendChild(objFont);
         }
         if (objEvent.strsts == '*WORKING' || objEvent.strsts == '*COMPLETED' || objEvent.strsts == '*FAILED') {
            objDiv.appendChild(document.createElement('br'));
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'bold';
            objFont.appendChild(document.createTextNode('Started: '));
            objDiv.appendChild(objFont);
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'normal';
            objFont.appendChild(document.createTextNode(objEvent.strstr));
            objDiv.appendChild(objFont);
         }
         if (objEvent.strsts == '*COMPLETED' || objEvent.strsts == '*FAILED') {
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'bold';
            objFont.appendChild(document.createTextNode(' Ended: '));
            objDiv.appendChild(objFont);
            objFont = document.createElement('font');
            objFont.style.fontFamily = 'Verdana,sans-serif';
            objFont.style.fontSize = '8pt';
            objFont.style.fontWeight = 'normal';
            objFont.appendChild(document.createTextNode(objEvent.strend));
            objDiv.appendChild(objFont);
         }
      }
      if (objEvent.strsts == '*CANCELLED') {
         objDiv.appendChild(document.createElement('br'));
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'bold';
         objFont.appendChild(document.createTextNode('Cancelled: '));
         objDiv.appendChild(objFont);
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'normal';
         objFont.appendChild(document.createTextNode(objEvent.strend));
         objDiv.appendChild(objFont);
      }
      if (objEvent.strmsg != '') {
         objDiv.appendChild(document.createElement('br'));
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'bold';
         objFont.appendChild(document.createTextNode('Error: '));
         objDiv.appendChild(objFont);
         objFont = document.createElement('font');
         objFont.style.fontFamily = 'Verdana,sans-serif';
         objFont.style.fontSize = '8pt';
         objFont.style.fontWeight = 'normal';
         objFont.appendChild(document.createTextNode(objEvent.strmsg));
         objDiv.appendChild(objFont);
      }
      objCanvas.appendChild(objDiv);
      objEvent.strrig = (objEvent.strlef-0) + objDiv.offsetWidth;
      objEvent.strbot = (objEvent.strtop-0) + objDiv.offsetHeight;
      objParent.strwrk = objEvent.strbot;
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="nonr" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_stream_monitor_review_help.htm');parent.setHeading('<%=strHeading%> - Stream Review');parent.showContent();loadStream();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table id="dspStream" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=2 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doBack();">&nbsp;Back&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100% >
         <td align=center colspan=2 nowrap><nobr>
            <div id="divStream" class="clsScroll01" style="background-color=#ffffff;"></div>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="DTA_StreamSeqn" value="<%=objForm.Fields("DTA_StreamSeqn").Value%>">
</form>
</body>
</html>