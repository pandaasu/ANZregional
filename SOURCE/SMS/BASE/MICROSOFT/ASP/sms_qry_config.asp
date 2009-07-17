<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : SMS (SMS Reporting System)                         //
'// Script  : sms_qry_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : July 2009                                          //
'// Text    : This script implements the query configuration     //
'//           functionality                                      //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim strBase
   dim strTarget
   dim strStatus
   dim strCharset
   dim strReturn
   dim strHeading
   dim objSecurity

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "sms_qry_config.asp"
   strHeading = "Query Maintenance"

   '//
   '// Get the base string
   '//
   strBase = GetBase()

   '//
   '// Get the status
   '//
   strStatus = GetStatus()

   '//
   '// Get the character set
   '//
   strCharset = GetCharSet()

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurityCheck("SMS_QRY_CONFIG")
   if strReturn <> "*OK" then
      call PaintFatal
   else
      call PaintFunction
   end if

   '//
   '// Destroy references
   '//
   set objSecurity = nothing

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="ics_fatal.inc"-->
<%end sub

'////////////////////////////
'// Paint function routine //
'////////////////////////////
sub PaintFunction()%>
<html>
<script language="javascript">
<!--

   ///////////////////////
   // Generic Functions //
   ///////////////////////
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

   ////////////////////
   // Load Functions //
   ////////////////////
   function loadFunction() {
      cobjScreens[0] = new clsScreen('dspLoad','hedLoad');
      cobjScreens[1] = new clsScreen('dspSelect','hedSelect');
      cobjScreens[2] = new clsScreen('dspDefine','hedDefine');
      cobjScreens[0].hedtxt = '**LOADING**';
      cobjScreens[1].hedtxt = 'Query Selection';
      cobjScreens[2].hedtxt = 'Query Maintenance';
      displayScreen('dspLoad');
      doSelectRefresh();
   }

   ///////////////////////
   // Control Functions //
   ///////////////////////
   var cobjScreens = new Array();
   function clsScreen(strScrName,strHedName) {
      this.scrnam = strScrName;
      this.hednam = strHedName;
      this.hedtxt = '';
   }
   function displayScreen(strScreen) {
      var objScreen;
      var objHeading;
      for (var i=0;i<cobjScreens.length;i++) {
         objScreen = document.getElementById(cobjScreens[i].scrnam);
         objHeading = document.getElementById(cobjScreens[i].hednam);
         if (cobjScreens[i].scrnam == strScreen) {
            objScreen.style.display = 'block';
            objHeading.innerText = cobjScreens[i].hedtxt;
            objScreen.focus();
         } else {
            objScreen.style.display = 'none';
            objHeading.innerText = cobjScreens[i].hedtxt;
         }
      }
   }

   //////////////////////
   // Select Functions //
   //////////////////////
   var cstrSelectStrCode;
   var cstrSelectEndCode;
   function doSelectUpdate(strCode) {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+strCode+'\');',10);
   }
   function doSelectCopy(strCode) {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+strCode+'\');',10);
   }
   function doSelectCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
   }
   function doSelectRefresh() {
      if (!processForm()) {return;}
      cstrSelectStrCode = document.getElementById('SEL_SelCode').value.toUpperCase();
      doActivityStart(document.body);
      window.setTimeout('requestSelectList(\'*SELQRY\');',10);
   }
   function doSelectPrevious() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestSelectList(\'*PRVQRY\');',10);
   }
   function doSelectNext() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestSelectList(\'*NXTQRY\');',10);
   }
   function requestSelectList(strAction) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="'+strAction+'" STRCDE="'+cstrSelectStrCode+'" ENDCDE="'+cstrSelectEndCode+'"/>';
      doPostRequest('<%=strBase%>sms_qry_config_select.asp',function(strResponse) {checkSelectList(strResponse);},false,streamXML(strXML));
   }
   function checkSelectList(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var objDocument = loadXML(strResponse.substring(3,strResponse.length));
         if (objDocument == null) {return;}
         var strMessage = '';
         var objElements = objDocument.documentElement.childNodes;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'ERROR') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + objElements[i].getAttribute('ERRTXT');
            }
         }
         if (strMessage != '') {
            alert(strMessage);
            return;
         }
         displayScreen('dspSelect');
         var objSelCode = document.getElementById('SEL_SelCode');
         var objSelPrev = document.getElementById('SEL_SelPrev');
         var objSelNext = document.getElementById('SEL_SelNext');
         var objTabHead = document.getElementById('tabHeadList');
         var objTabBody = document.getElementById('tabBodyList');
         objTabHead.style.tableLayout = 'auto';
         objTabBody.style.tableLayout = 'auto';
         var objRow;
         var objCell;
         for (var i=objTabHead.rows.length-1;i>=0;i--) {
            objTabHead.deleteRow(i);
         }
         for (var i=objTabBody.rows.length-1;i>=0;i--) {
            objTabBody.deleteRow(i);
         }
         objRow = objTabHead.insertRow(-1);
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Action&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Query&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Name&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;Status&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(-1);
         objCell.colSpan = 1;
         objCell.align = 'center';
         objCell.innerHTML = '&nbsp;';
         objCell.className = 'clsLabelHB';
         objCell.style.whiteSpace = 'nowrap';
         cstrSelectStrCode = '';
         cstrSelectEndCode = '';
         var strStrList = '1';
         var strEndList = '1';
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'LSTCTL') {
               strStrList = objElements[i].getAttribute('STRLST');
               strEndList = objElements[i].getAttribute('ENDLST');
            } else if (objElements[i].nodeName == 'LSTROW') {
               if (cstrSelectStrCode == '') {
                  cstrSelectStrCode = objElements[i].getAttribute('QRYCDE');
               }
               cstrSelectEndCode = objElements[i].getAttribute('QRYCDE');
               objRow = objTabBody.insertRow(-1);
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'center';
               objCell.innerHTML = '<a class="clsSelect" onClick="doSelectUpdate(\''+objElements[i].getAttribute('QRYCDE')+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" onClick="doSelectCopy(\''+objElements[i].getAttribute('QRYCDE')+'\');">Copy</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('QRYCDE')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('QRYNAM')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(-1);
               objCell.colSpan = 1;
               objCell.align = 'left';
               objCell.innerHTML = '&nbsp;'+objElements[i].getAttribute('QRYSTS')+'&nbsp;';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         if (objTabBody.rows.length == 0) {
            objRow = objTabBody.insertRow(-1);
            objCell = objRow.insertCell(-1);
            objCell.colSpan = 4;
            objCell.innerHTML = '&nbsp;NO DATA FOUND&nbsp;';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
            setScrollable('HeadList','BodyList','horizontal');
            objTabHead.rows(0).cells[4].style.width = 16;
            objTabHead.style.tableLayout = 'auto';
            objTabBody.style.tableLayout = 'auto';
         } else {
            setScrollable('HeadList','BodyList','horizontal');
            objTabHead.rows(0).cells[4].style.width = 16;
            objTabHead.style.tableLayout = 'fixed';
            objTabBody.style.tableLayout = 'fixed';
         }
         objSelCode.value = cstrSelectStrCode;
         objSelPrev.className = 'clsButton';
         objSelPrev.onclick = function() {doSelectPrevious();};
         if (strStrList == '1') {
            objSelPrev.className = 'clsButtonD';
            objSelPrev.onclick = '';
         }
         objSelNext.className = 'clsButton';
         objSelNext.onclick = function() {doSelectNext();};
         if (strEndList == '1') {
            objSelNext.className = 'clsButtonD';
            objSelNext.onclick = '';
         }
         objSelCode.focus();
      }
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="*UPDQRY" QRYCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>sms_qry_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="*CRTQRY" QRYCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>sms_qry_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><SMS_REQUEST ACTION="*CPYQRY" QRYCDE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>sms_qry_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function checkDefineLoad(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var objDocument = loadXML(strResponse.substring(3,strResponse.length));
         if (objDocument == null) {return;}
         var strMessage = '';
         var objElements = objDocument.documentElement.childNodes;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'ERROR') {
               if (strMessage != '') {strMessage = strMessage + '\r\n';}
               strMessage = strMessage + objElements[i].getAttribute('ERRTXT');
            }
         }
         if (strMessage != '') {
            alert(strMessage);
            return;
         }
         if (cstrDefineMode == '*UPD') {
            cobjScreens[2].hedtxt = 'Update Query ('+cstrDefineCode+')';
            document.getElementById('addDefine').style.display = 'none';
         } else {
            cobjScreens[2].hedtxt = 'Create Query';
            document.getElementById('addDefine').style.display = 'block';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_QryCode').value = '';
         document.getElementById('DEF_QryName').value = '';
         document.getElementById('DEF_EmaStxt').value = '';
         document.getElementById('DEF_RcvDay1').checked = false;
         document.getElementById('DEF_RcvDay2').checked = false;
         document.getElementById('DEF_RcvDay3').checked = false;
         document.getElementById('DEF_RcvDay4').checked = false;
         document.getElementById('DEF_RcvDay5').checked = false;
         document.getElementById('DEF_RcvDay6').checked = false;
         document.getElementById('DEF_RcvDay7').checked = false;
         document.getElementById('DEF_DimDpth').value = '';
         document.getElementById('DEF_DimCod1').value = '';
         document.getElementById('DEF_DimCod2').value = '';
         document.getElementById('DEF_DimCod3').value = '';
         document.getElementById('DEF_DimCod4').value = '';
         document.getElementById('DEF_DimCod5').value = '';
         document.getElementById('DEF_DimCod6').value = '';
         document.getElementById('DEF_DimCod7').value = '';
         var strQryStat = '';
         var objQryStat = document.getElementById('DEF_QryStat');
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'QUERY') {
               document.getElementById('DEF_QryCode').value = objElements[i].getAttribute('QRYCDE');
               document.getElementById('DEF_QryName').value = objElements[i].getAttribute('QRYNAM');
               document.getElementById('DEF_EmaStxt').value = objElements[i].getAttribute('EMASUB');
               if (objElements[i].getAttribute('RCVD01') == '1') {
                  document.getElementById('DEF_RcvDay1').checked = true;
               } 
               if (objElements[i].getAttribute('RCVD02') == '1') {
                  document.getElementById('DEF_RcvDay2').checked = true;
               }
               if (objElements[i].getAttribute('RCVD03') == '1') {
                  document.getElementById('DEF_RcvDay3').checked = true;
               }
               if (objElements[i].getAttribute('RCVD04') == '1') {
                  document.getElementById('DEF_RcvDay4').checked = true;
               }
               if (objElements[i].getAttribute('RCVD05') == '1') {
                  document.getElementById('DEF_RcvDay5').checked = true;
               }
               if (objElements[i].getAttribute('RCVD06') == '1') {
                  document.getElementById('DEF_RcvDay6').checked = true;
               }
               if (objElements[i].getAttribute('RCVD07') == '1') {
                  document.getElementById('DEF_RcvDay7').checked = true;
               }
               document.getElementById('DEF_DimDpth').value = objElements[i].getAttribute('DIMDEP');
               document.getElementById('DEF_DimCod1').value = objElements[i].getAttribute('DIMC01');
               document.getElementById('DEF_DimCod2').value = objElements[i].getAttribute('DIMC02');
               document.getElementById('DEF_DimCod3').value = objElements[i].getAttribute('DIMC03');
               document.getElementById('DEF_DimCod4').value = objElements[i].getAttribute('DIMC04');
               document.getElementById('DEF_DimCod5').value = objElements[i].getAttribute('DIMC05');
               document.getElementById('DEF_DimCod6').value = objElements[i].getAttribute('DIMC06');
               document.getElementById('DEF_DimCod7').value = objElements[i].getAttribute('DIMC07');
               document.getElementById('DEF_DimCod8').value = objElements[i].getAttribute('DIMC08');
               document.getElementById('DEF_DimCod9').value = objElements[i].getAttribute('DIMC09');
               strQryStat = objElements[i].getAttribute('QRYSTS');
            }
         }
         objQryStat.selectedIndex = -1;
         for (var i=0;i<objQryStat.length;i++) {
            if (objQryStat.options[i].value == strQryStat) {
               objQryStat.options[i].selected = true;
               break;
            }
         }
         if (cstrDefineMode == '*UPD') {
            document.getElementById('DEF_QryName').focus();
         } else {
            document.getElementById('DEF_QryCode').focus();
         }
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objQryStat = document.getElementById('DEF_QryStat');
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      if (cstrDefineMode == '*UPD') {
         strXML = strXML+'<SMS_REQUEST ACTION="*UPDQRY"';
         strXML = strXML+' QRYCDE="'+fixXML(cstrDefineCode)+'"';
      } else {
         strXML = strXML+'<SMS_REQUEST ACTION="*CRTQRY"';
         strXML = strXML+' QRYCDE="'+fixXML(document.getElementById('DEF_QryCode').value.toUpperCase())+'"';
      }
      strXML = strXML+' QRYNAM="'+fixXML(document.getElementById('DEF_QryName').value)+'"';
      if (objQryStat.selectedIndex == -1) {
         strXML = strXML+' QRYSTS=""';
      } else {
         strXML = strXML+' QRYSTS="'+fixXML(objQryStat.options[objQryStat.selectedIndex].value)+'"';
      }
      strXML = strXML+' EMASUB="'+fixXML(document.getElementById('DEF_EmaStxt').value)+'"';
      if (document.getElementById('DEF_RcvDay1').checked) {
         strXML = strXML+' RCVD01="1"';
      } else {
         strXML = strXML+' RCVD01="0"';
      }
      if (document.getElementById('DEF_RcvDay2').checked) {
         strXML = strXML+' RCVD02="1"';
      } else {
         strXML = strXML+' RCVD02="0"';
      }
      if (document.getElementById('DEF_RcvDay3').checked) {
         strXML = strXML+' RCVD03="1"';
      } else {
         strXML = strXML+' RCVD03="0"';
      }
      if (document.getElementById('DEF_RcvDay4').checked) {
         strXML = strXML+' RCVD04="1"';
      } else {
         strXML = strXML+' RCVD04="0"';
      }
      if (document.getElementById('DEF_RcvDay5').checked) {
         strXML = strXML+' RCVD05="1"';
      } else {
         strXML = strXML+' RCVD05="0"';
      }
      if (document.getElementById('DEF_RcvDay6').checked) {
         strXML = strXML+' RCVD06="1"';
      } else {
         strXML = strXML+' RCVD06="0"';
      }
      if (document.getElementById('DEF_RcvDay7').checked) {
         strXML = strXML+' RCVD07="1"';
      } else {
         strXML = strXML+' RCVD07="0"';
      }
      strXML = strXML+' DIMDEP="'+fixXML(document.getElementById('DEF_DimDpth').value)+'"';
      strXML = strXML+' DIMC01="'+fixXML(document.getElementById('DEF_DimCod1').value)+'"';
      strXML = strXML+' DIMC02="'+fixXML(document.getElementById('DEF_DimCod2').value)+'"';
      strXML = strXML+' DIMC03="'+fixXML(document.getElementById('DEF_DimCod3').value)+'"';
      strXML = strXML+' DIMC04="'+fixXML(document.getElementById('DEF_DimCod4').value)+'"';
      strXML = strXML+' DIMC05="'+fixXML(document.getElementById('DEF_DimCod5').value)+'"';
      strXML = strXML+' DIMC06="'+fixXML(document.getElementById('DEF_DimCod6').value)+'"';
      strXML = strXML+' DIMC07="'+fixXML(document.getElementById('DEF_DimCod7').value)+'"';
      strXML = strXML+' DIMC08="'+fixXML(document.getElementById('DEF_DimCod8').value)+'"';
      strXML = strXML+' DIMC09="'+fixXML(document.getElementById('DEF_DimCod9').value)+'"';
      strXML = strXML+'/>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>sms_qry_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
   }
   function checkDefineAccept(strResponse) {
      doActivityStop();
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         if (strResponse.length > 3) {
            var objDocument = loadXML(strResponse.substring(3,strResponse.length));
            if (objDocument == null) {return;}
            var strMessage = '';
            var objElements = objDocument.documentElement.childNodes;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'ERROR') {
                  if (strMessage != '') {strMessage = strMessage + '\r\n';}
                  strMessage = strMessage + objElements[i].getAttribute('ERRTXT');
               }
            }
            if (strMessage != '') {
               alert(strMessage);
               return;
            }
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'CONFIRM') {
                  alert(objElements[i].getAttribute('CONTXT'));
               }
            }
         }
         doSelectRefresh();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspSelect');
      document.getElementById('SEL_SelCode').focus();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<!--#include file="ics_std_scrollable.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('sms_qry_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspSelect" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSelect" class="clsFunction" align=center colspan=2 nowrap><nobr>Query Selection</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=8 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectRefresh();">&nbsp;Refresh&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr><input class="clsInputNN" style="text-transform:uppercase;" type="text" name="SEL_SelCode" size="64" maxlength="64" value="" onFocus="setSelect(this);"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doSelectCreate();">&nbsp;Create&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" name="SEL_SelPrev" onClick="doSelectPrevious();"><&nbsp;Prev&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" name="SEL_SelNext" onClick="doSelectNext();">&nbsp;Next&nbsp;></a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHeadList">
                     <table class="clsTableHead" id="tabHeadList" align=left cols=1 cellpadding="0" cellspacing="1">
                     </table>
                     </div>
                  </nobr></td>
               </tr>
               <tr height=100%>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsScroll" id="conBodyList">
                     <table class="clsTableBody" id="tabBodyList" align=left cols=1 cellpadding="0" cellspacing="1"></table>
                     </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Query Define</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr id="addDefine" style="display:none;visibility:visible">
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_QryCode" size="64" maxlength="64" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_QryName" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_QryStat">
               <option value="0">Inactive
               <option value="1">Active
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query SMS Subject:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_EmaStxt" size="64" maxlength="64" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Query Received Days:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input type="checkbox" name="DEF_RcvDay2" value="1">Monday&nbsp;
            <input type="checkbox" name="DEF_RcvDay3" value="1">Tuesday&nbsp;
            <input type="checkbox" name="DEF_RcvDay4" value="1">Wednesday&nbsp;
            <input type="checkbox" name="DEF_RcvDay5" value="1">Thursday&nbsp;
            <input type="checkbox" name="DEF_RcvDay6" value="1">Friday&nbsp;
            <input type="checkbox" name="DEF_RcvDay7" value="1">Saturday&nbsp;
            <input type="checkbox" name="DEF_RcvDay1" value="1">Sunday&nbsp;
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension Levels (1 to 9):&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DimDpth" size="1" maxlength="1" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension Level 1 Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DimCod1" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension Level 2 Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DimCod2" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension Level 3 Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DimCod3" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension Level 4 Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DimCod4" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension Level 5 Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DimCod5" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension Level 6 Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DimCod6" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension Level 7 Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DimCod7" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension Level 8 Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DimCod8" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Dimension Level 9 Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_DimCod9" size="80" maxlength="256" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->