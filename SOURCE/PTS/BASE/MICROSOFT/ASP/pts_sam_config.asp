<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product System)                               //
'// Script  : pts_sam_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the sample configuration    //
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
   strTarget = "pts_sam_config.asp"
   strHeading = "Sample Maintenance"

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
   strReturn = GetSecurityCheck("PTS_SAM_CONFIG")
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

   ///////////////////////
   // Control Functions //
   ///////////////////////
   function displayPrompt() {
      var objDspPrompt = document.getElementById('dspPrompt');
      var objDspDefine = document.getElementById('dspDefine');
      var objDspSchRule = document.getElementById('dspSchRule');
      var objDspSchList = document.getElementById('dspSchList');
      var objDspSchNumb = document.getElementById('dspSchNumb');
      var objDspSchText = document.getElementById('dspSchText');
      var objDspSchSlct = document.getElementById('dspSchSlct');
      objDspPrompt.style.display = 'block';
      objDspPrompt.style.visibility = 'visible';
      objDspDefine.style.display = 'none';
      objDspDefine.style.visibility = 'hidden';
      objDspSchRule.style.display = 'none';
      objDspSchRule.style.visibility = 'hidden';
      objDspSchList.style.display = 'none';
      objDspSchList.style.visibility = 'hidden';
      objDspSchNumb.style.display = 'none';
      objDspSchNumb.style.visibility = 'hidden';
      objDspSchText.style.display = 'none';
      objDspSchText.style.visibility = 'hidden';
      objDspSchSlct.style.display = 'none';
      objDspSchSlct.style.visibility = 'hidden';
   }
   function displayDefine() {
      var objDspPrompt = document.getElementById('dspPrompt');
      var objDspDefine = document.getElementById('dspDefine');
      var objDspSchRule = document.getElementById('dspSchRule');
      var objDspSchList = document.getElementById('dspSchList');
      var objDspSchNumb = document.getElementById('dspSchNumb');
      var objDspSchText = document.getElementById('dspSchText');
      var objDspSchSlct = document.getElementById('dspSchSlct');
      objDspPrompt.style.display = 'none';
      objDspPrompt.style.visibility = 'hidden';
      objDspDefine.style.display = 'block';
      objDspDefine.style.visibility = 'visible';
      objDspSchRule.style.display = 'none';
      objDspSchRule.style.visibility = 'hidden';
      objDspSchList.style.display = 'none';
      objDspSchList.style.visibility = 'hidden';
      objDspSchNumb.style.display = 'none';
      objDspSchNumb.style.visibility = 'hidden';
      objDspSchText.style.display = 'none';
      objDspSchText.style.visibility = 'hidden';
      objDspSchSlct.style.display = 'none';
      objDspSchSlct.style.visibility = 'hidden';
   }
   function displaySchRule() {
      var objDspPrompt = document.getElementById('dspPrompt');
      var objDspDefine = document.getElementById('dspDefine');
      var objDspSchRule = document.getElementById('dspSchRule');
      var objDspSchList = document.getElementById('dspSchList');
      var objDspSchNumb = document.getElementById('dspSchNumb');
      var objDspSchText = document.getElementById('dspSchText');
      var objDspSchSlct = document.getElementById('dspSchSlct');
      objDspPrompt.style.display = 'none';
      objDspPrompt.style.visibility = 'hidden';
      objDspDefine.style.display = 'none';
      objDspDefine.style.visibility = 'hidden';
      objDspSchRule.style.display = 'block';
      objDspSchRule.style.visibility = 'visible';
      objDspSchList.style.display = 'none';
      objDspSchList.style.visibility = 'hidden';
      objDspSchNumb.style.display = 'none';
      objDspSchNumb.style.visibility = 'hidden';
      objDspSchText.style.display = 'none';
      objDspSchText.style.visibility = 'hidden';
      objDspSchSlct.style.display = 'none';
      objDspSchSlct.style.visibility = 'hidden';
   }
   function displaySchList() {
      var objDspPrompt = document.getElementById('dspPrompt');
      var objDspDefine = document.getElementById('dspDefine');
      var objDspSchRule = document.getElementById('dspSchRule');
      var objDspSchList = document.getElementById('dspSchList');
      var objDspSchNumb = document.getElementById('dspSchNumb');
      var objDspSchText = document.getElementById('dspSchText');
      var objDspSchSlct = document.getElementById('dspSchSlct');
      objDspPrompt.style.display = 'none';
      objDspPrompt.style.visibility = 'hidden';
      objDspDefine.style.display = 'none';
      objDspDefine.style.visibility = 'hidden';
      objDspSchRule.style.display = 'none';
      objDspSchRule.style.visibility = 'hidden';
      objDspSchList.style.display = 'block';
      objDspSchList.style.visibility = 'visible';
      objDspSchNumb.style.display = 'none';
      objDspSchNumb.style.visibility = 'hidden';
      objDspSchText.style.display = 'none';
      objDspSchText.style.visibility = 'hidden';
      objDspSchSlct.style.display = 'none';
      objDspSchSlct.style.visibility = 'hidden';
   }
   function displaySchNumb() {
      var objDspPrompt = document.getElementById('dspPrompt');
      var objDspDefine = document.getElementById('dspDefine');
      var objDspSchRule = document.getElementById('dspSchRule');
      var objDspSchList = document.getElementById('dspSchList');
      var objDspSchNumb = document.getElementById('dspSchNumb');
      var objDspSchText = document.getElementById('dspSchText');
      var objDspSchSlct = document.getElementById('dspSchSlct');
      objDspPrompt.style.display = 'none';
      objDspPrompt.style.visibility = 'hidden';
      objDspDefine.style.display = 'none';
      objDspDefine.style.visibility = 'hidden';
      objDspSchRule.style.display = 'none';
      objDspSchRule.style.visibility = 'hidden';
      objDspSchList.style.display = 'none';
      objDspSchList.style.visibility = 'hidden';
      objDspSchNumb.style.display = 'block';
      objDspSchNumb.style.visibility = 'visible';
      objDspSchText.style.display = 'none';
      objDspSchText.style.visibility = 'hidden';
      objDspSchSlct.style.display = 'none';
      objDspSchSlct.style.visibility = 'hidden';
   }
   function displaySchText() {
      var objDspPrompt = document.getElementById('dspPrompt');
      var objDspDefine = document.getElementById('dspDefine');
      var objDspSchRule = document.getElementById('dspSchRule');
      var objDspSchList = document.getElementById('dspSchList');
      var objDspSchNumb = document.getElementById('dspSchNumb');
      var objDspSchText = document.getElementById('dspSchText');
      var objDspSchSlct = document.getElementById('dspSchSlct');
      objDspPrompt.style.display = 'none';
      objDspPrompt.style.visibility = 'hidden';
      objDspDefine.style.display = 'none';
      objDspDefine.style.visibility = 'hidden';
      objDspSchRule.style.display = 'none';
      objDspSchRule.style.visibility = 'hidden';
      objDspSchList.style.display = 'none';
      objDspSchList.style.visibility = 'hidden';
      objDspSchNumb.style.display = 'none';
      objDspSchNumb.style.visibility = 'hidden';
      objDspSchText.style.display = 'block';
      objDspSchText.style.visibility = 'visible';
      objDspSchSlct.style.display = 'none';
      objDspSchSlct.style.visibility = 'hidden';
   }
   function displaySchSlct() {
      var objDspPrompt = document.getElementById('dspPrompt');
      var objDspDefine = document.getElementById('dspDefine');
      var objDspSchRule = document.getElementById('dspSchRule');
      var objDspSchList = document.getElementById('dspSchList');
      var objDspSchNumb = document.getElementById('dspSchNumb');
      var objDspSchText = document.getElementById('dspSchText');
      var objDspSchSlct = document.getElementById('dspSchSlct');
      objDspPrompt.style.display = 'none';
      objDspPrompt.style.visibility = 'hidden';
      objDspDefine.style.display = 'none';
      objDspDefine.style.visibility = 'hidden';
      objDspSchRule.style.display = 'none';
      objDspSchRule.style.visibility = 'hidden';
      objDspSchList.style.display = 'none';
      objDspSchList.style.visibility = 'hidden';
      objDspSchNumb.style.display = 'none';
      objDspSchNumb.style.visibility = 'hidden';
      objDspSchText.style.display = 'none';
      objDspSchText.style.visibility = 'hidden';
      objDspSchSlct.style.display = 'block';
      objDspSchSlct.style.visibility = 'visible';
   }

   //////////////////////
   // Prompt Functions //
   //////////////////////
   function doPromptUpdate() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_SamCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Sample code must be entered for update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      requestDefineUpdate(document.getElementById('PRO_SamCode').value);
   }
   function doPromptCreate() {
      if (!processForm()) {return;}
      requestDefineCreate('*NEW');
   }
   function doPromptCopy() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_SamCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Sample code must be entered for copy';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      requestDefineCopy(document.getElementById('PRO_SamCode').value);
   }
   function doPromptSearch() {
      displaySchRule();
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDSAM" SAMCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_sam_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTSAM" SAMCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_sam_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYSAM" SAMCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_sam_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function checkDefineLoad(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var objDocument = loadXML(strResponse);
         if (varDocument == null) {return;}
         displayDefine();
         if (cstrDefineMode == '*UPD') {
            document.getElementById('hedDefine').innerText = 'Update Sample';
         } else {
            document.getElementById('hedDefine').innerText = 'Create Sample';
         }
         document.getElementById('DEF_SamCode').innerText = '';
         document.getElementById('DEF_SamText').value = '';
         document.getElementById('DEF_UomSize').value = '';
         document.getElementById('DEF_PreDate').value = '';
         document.getElementById('DEF_ExtRfnr').value = '';
         document.getElementById('DEF_PlopCde').value = '';
         var objSamStat = document.getElementById('DEF_SamStat');
         var objUomCode = document.getElementById('DEF_UomCode');
         var objPreLocn = document.getElementById('DEF_PreLocn');
         objSamStat.options.length = 0;
         objUomCode.options.length = 0;
         objPreLocn.options.length = 0;
         var objElements = objDocument.documentElement.childNodes;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'STA_LIST') {
               objSamStat.options[i] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'UOM_LIST') {
               objUomCode.options[i] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'PRE_LIST') {
               objPreLocn.options[i] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'SAMPLE') {
               document.getElementById('DEF_SamCode').innerText = objElements[i].getAttribute('SAMCODE');
               document.getElementById('DEF_SamText').value = objElements[i].getAttribute('SAMTEXT');
               document.getElementById('DEF_UomSize').value = objElements[i].getAttribute('UOMSIZE');
               document.getElementById('DEF_PreDate').value = objElements[i].getAttribute('PREDATE');
               document.getElementById('DEF_ExtRfnr').value = objElements[i].getAttribute('EXTRFNR');
               document.getElementById('DEF_PlopCde').value = objElements[i].getAttribute('PLOPCDE');
            }
         }
         objSamStat.selectedIndex = -1;
         for (var i=0;i<objSamStat.length;i++) {
            if (objSamStat.options[i].value == objElements[i].getAttribute('SAMSTAT')) {
               objSamStat.options[i].selected = true;
               break;
            }
         }
         objUomCode.selectedIndex = -1;
         for (var i=0;i<objUomCode.length;i++) {
            if (objUomCode.options[i].value == objElements[i].getAttribute('UOMCODE')) {
               objUomCode.options[i].selected = true;
               break;
            }
         }
         objPreLocn.selectedIndex = -1;
         for (var i=0;i<objPreLocn.length;i++) {
            if (objPreLocn.options[i].value == objElements[i].getAttribute('PRELOCN')) {
               objPreLocn.options[i].selected = true;
               break;
            }
         }
         document.getElementById('DEF_SamText').focus();
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objSamStat = document.getElementById('DEF_SamStat');
      var objUomCode = document.getElementById('DEF_UomCode');
      var objPreLocn = document.getElementById('DEF_PreLocn');
      var strMessage = '';
      if (document.getElementById('DEF_SamText').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Sample description must be entered';
      }
      if (objSamStat.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Sample status must be selected';
      }
      if (objUomCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Sample unit of measure must be selected';
      }
      if (objPreLocn.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Sample prepared location must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*DEFSAM"';
      strXML = strXML+' SAMCODE="'+fixXML(document.getElementById('DEF_SamCode').innerText)+'"';
      strXML = strXML+' SAMTEXT="'+fixXML(document.getElementById('DEF_SamText').value)+'"';
      strXML = strXML+' SAMSTAT="'+fixXML(objSamStat.options[objSamStat.selectedIndex].value)+'"';
      strXML = strXML+' UOMCODE="'+fixXML(objUomCode.options[objUomCode.selectedIndex].value)+'"';
      strXML = strXML+' UOMSIZE="'+fixXML(document.getElementById('DEF_UomSize').value)+'"';
      strXML = strXML+' PRELOCN="'+fixXML(objPreLocn.options[objPreLocn.selectedIndex].value)+'"';
      strXML = strXML+' PREDATE="'+fixXML(document.getElementById('DEF_PreDate').value)+'"';
      strXML = strXML+' EXTRFNR="'+fixXML(document.getElementById('DEF_ExtRfnr').value)+'"';
      strXML = strXML+' PLOPCDE="'+fixXML(document.getElementById('DEF_PlopCde').value)+'"';
      strXML = strXML+'/>';
      doPostRequest('<%=strBase%>pts_sam_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
   }
   function checkDefineAccept(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         displayPrompt();
         document.getElementById('PRO_SamCode').value = '';
         document.getElementById('PRO_SamCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayPrompt();
      document.getElementById('PRO_SamCode').value = '';
      document.getElementById('PRO_SamCode').focus();
   }

   ///////////////////////////
   // Search Rule Functions //
   ///////////////////////////
   var cstrSearchMode;
   var cobjSearchRow;
   function clsSchValue(strValCde,strValTxt) {
      this.valcde = strValCde;
      this.valtxt = strValTxt;
   }
   function doSearchAddGroup() {
      if (!processForm()) {return;}
      strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTFLD" ENTCDE="*SAMPLE" TESFLG="0"/>';
      doPostRequest('<%=strBase%>pts_sys_field_list.asp',function(strResponse) {checkSearchAddGroup(strResponse);},false,streamXML(strXML));
   }
   function checkSearchAddGroup(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var objDocument = loadXML(strResponse);
         if (varDocument == null) {return;}
         var objTable = document.getElementById('tabSchRule');
         var objRow;
         var objCell;
         var strGroup;
         objRow = objTable.insertRow(-1);
         strGroup = '*GROUP'+objRow.rowIndex;
         objRow.setAttribute('grpcde',strGroup);
         objRow.setAttribute('tabcde','*GROUP');
         objCell = objRow.insertCell(0);
         objCell.colSpan = 1;
         objCell.innerHtml = '<nobr><a class="clsSelect" href="javascript:doSearchClearGroup(\''+objRow.rowIndex+'\');">Clear</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doSearchDeleteGroup(\''+objRow.rowIndex+'\');">Delete</a></nobr>';
         objCell.style.whiteSpace = 'nowrap';
         objCell = objRow.insertCell(1);
         objCell.colSpan = 1;
         objCell.innerText = '';
         objCell.className = 'clsLabelFB';
         objCell.style.whiteSpace = 'nowrap';
         var objElements = objDocument.documentElement.childNodes;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'FIELD') {
               objRow = objTable.insertRow(-1);
               objRow.setAttribute('grpcde',strGroup);
               objRow.setAttribute('tabcde',objElements[i].getAttribute('TABCDE'));
               objRow.setAttribute('fldcde',objElements[i].getAttribute('FLDCDE'));
               objRow.setAttribute('fldtxt',objElements[i].getAttribute('FLDTXT'));
               objRow.setAttribute('rultyp',objElements[i].getAttribute('RULTYP'));
               objRow.setAttribute('rulcde','');
               objRow.setAttribute('rulcnd','');
               objRow.setAttribute('valary',new Array());
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHtml = '<nobr><a class="clsSelect" href="javascript:doSearchClearRule(\''+objRow.rowIndex+'\');">Clear</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doSearchUpdateRule(\''+objRow.rowIndex+'\');">Update</a></nobr>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('FLDTXT')+' - *ALL';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         var bolFound = false;
         for (var i=0;i<objTable.rows.length;i++) {
            objRow = objTable.rows[i];
            if (objRow.getAttribute('tabcde') == '*GROUP') {
               if (!bolFound) {
                  objRow.cells[1].innerText = 'SELECTION GROUP - WHERE';
               } else {
                  objRow.cells[1].innerText = 'SELECTION GROUP - OR';
               }
               bolFound = true;
            }
         }
      }
   }
   function doSearchClearGroup(intRow) {
      var objTable = document.getElementById('tabSchRule');
      var objRow;
      strGroup = objTable.rows[intRow].getAttribute('grpcde');
      for (var i=0;i<objTable.rows.length;i++) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('grpcde') == strGroup && objRow.getAttribute('tabcde') != '*GROUP') {
            objRow.setAttribute('rulcde','');
            objRow.setAttribute('rulcnd','');
            objRow.getAttribute('valary').length = 0;
            objRow.cells[1].innerText = objRow.getAttribute('fldtxt')+' - *ALL';
         }
      }
   }
   function doSearchDeleteGroup(intRow) {
      var objTable = document.getElementById('tabSchRule');
      var objRow;
      strGroup = objTable.rows[intRow].getAttribute('grpcde');
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('grpcde') == strGroup) {
            objTable.deleteRow(i);
         }
      }
      var bolFound = false;
      for (var i=0;i<objTable.rows.length;i++) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('tabcde') == '*GROUP') {
            if (!bolFound) {
               objRow.cells[1].innerText = 'SELECTION GROUP - WHERE';
            } else {
               objRow.cells[1].innerText = 'SELECTION GROUP - OR';
            }
            bolFound = true;
         }
      }
   }
   function doSearchClearRule(intRow) {
      var objTable = document.getElementById('tabRule');
      var objRow = objTable.rows[intRow];
      objRow.setAttribute('rulcde','');
      objRow.setAttribute('rulcnd','');
      objRow.getAttribute('valary').length = 0;
      objRow.cells[1].innerText = objRow.getAttribute('fldtxt')+' - *ALL';
   }
   function doSearchUpdateRule(intRow) {
      var objTable = document.getElementById('tabSchRule');
      cobjSearchRow = objTable.rows[intRow];
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTRUL" TABCDE="'+cobjSearchRow.getAttribute('tabcde')+'" FLDCDE="'+cobjSearchRow.getAttribute('fldcde')+'"/>';
      doPostRequest('<%=strBase%>pts_sys_rule_list.asp',function(strResponse) {checkSearchUpdateRule(strResponse);},false,streamXML(strXML));
   }
   function checkSearchUpdateRule(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var objDocument = loadXML(strResponse);
         if (varDocument == null) {return;}
         if (cobjSearchRow.getAttribute('rultyp') == '*LIST') {
            var objSelRulCode = document.getElementById('SEL_RulCode');
            var objSelRulValue = document.getElementById('SEL_RulValue');
            var objSelSelValue = document.getElementById('SEL_SelValue');
            objSelRulCode.options.length = 0;
            objSelRulCode.selectedIndex = 1;
            objSelRulValue.options.length = 0;
            objSelRulValue.selectedIndex = -1;
            objSelSelValue.options.length = 0;
            objSelSelValue.selectedIndex = -1;
            var objElements = objDocument.documentElement.childNodes;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSelRulCode.options[i] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE')+':'+objElements[i].getAttribute('RULCND'));
                  if (cobjSearchRow.getAttribute('rulcde') == objElements[i].getAttribute('RULCDE')) {
                     objSelRulCode.options[i].selected = true;
                  }
               } else if (objElements[i].nodeName == 'VALUE') {
                  objSelRulValue.options[i] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
               }
            }
            var objValues = cobjSearchRow.getAttribute('valary');
            for (var i=0;i<objValues.length;i++) {
               objSelSelValue.options[i] = new Option(objValues[i].valtxt,objValues[i].valcde);
            }
            displaySchList();
            objSelRulCode.focus();
         } else if (cobjSearchRow.getAttribute('rultyp') == '*NUMBER') {
            var objSenRulCode = document.getElementById('SEN_RulCode');
            var objSenSelValue = document.getElementById('SEN_SelValue');
            objSenRulCode.options.length = 0;
            objSenRulCode.selectedIndex = 1;
            var objElements = objDocument.documentElement.childNodes;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSenRulCode.options[i] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE')+':'+objElements[i].getAttribute('RULCND'));
                  if (cobjSearchRow.getAttribute('rulcde') == objElements[i].getAttribute('RULCDE')) {
                     objSenRulCode.options[i].selected = true;
                  }
               }
            }
            objSenSelValue.value = '';
            var objValues = cobjSearchRow.getAttribute('valary');
            if (objValues.length != 0) {
               objSenSelValue.value = objValues[0].valtxt;
            }
            displayRuleNumb();
            objSenRulCode.focus();
         } else if (cobjSearchRow.getAttribute('rultyp') == '*TEXT') {
            var objSetRulCode = document.getElementById('SET_RulCode');
            var objSetSelValue = document.getElementById('SET_SelValue');
            objSetRulCode.options.length = 0;
            objSetRulCode.selectedIndex = 1;
            var objElements = objDocument.documentElement.childNodes;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSetRulCode.options[i] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE')+':'+objElements[i].getAttribute('RULCND'));
                  if (cobjSearchRow.getAttribute('rulcde') == objElements[i].getAttribute('RULCDE')) {
                     objSetRulCode.options[i].selected = true;
                  }
               }
            }
            objSetSelValue.value = '';
            var objValues = cobjSearchRow.getAttribute('valary');
            if (objValues.length != 0) {
               objSetSelValue.value = objValues[0].valtxt;
            }
            displayRuleText();
            objSetRulCode.focus();
         } else {
            alert('Unknown Rule Type ('+cobjSearchRow.getAttribute('rultyp')+')');
         }
      }
   }
   function doSchRuleSelect() {
      if (!processForm()) {return;}
      requestSearchSelect();
   }
   function doSchRuleCancel() {
      displayPrompt();
      document.getElementById('PRO_SamCode').focus();
   }

   ///////////////////////////
   // Search List Functions //
   ///////////////////////////
   function doSchListCancel() {
      displaySchRule();
   }
   function doSchListAccept() {
      if (!processForm()) {return;}
      var objSelRulCode = document.getElementById('SEL_RulCode');
      var objSelSelValue = document.getElementById('SEL_SelValue');
      var strMessage = '';
      if (objSelRulCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection rule must be selected';
      }
      if (objSelSelValue.options.length == 0) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'At least one rule value must be selected';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var aryRulData = objSelRulValue[objSelRulCode.selectedIndex].value.split(':');
      cobjSearchRow.setAttribute('rulcde',aryRulData[0]);
      cobjSearchRow.setAttribute('rulcnd',aryRulData[1]);
      var strText = cobjSearchRow.getAttribute('fldtxt')+' '+aryRulData[0];
      var objValues = cobjSearchRow.getAttribute('valary');
      objValues.length = 0;
      for (var i=0;i<objSelSelValue.options.length;i++) {
         if (objSelSelValue.options[i].selected == true) {
            objValues[i] = new clsSchValue(objSelSelValue[i].value,objSelSelValue[i].text);
            if (i == 0) {
               strText = strText+' '+objSelSelValue[i].text;
            } else {
               strText = strText+' '+aryRulData[1]+' '+objSelSelValue[i].text;
            }
         }
      }
      cobjSearchRow.cells[1].innerText = strText;
      displaySchList();
      objSelRulCode.focus();
   }
   function selectSchListValues() {
      var objSelRulValue = document.getElementById('SEL_RulValue');
      var objSelSelValue = document.getElementById('SEL_SelValue');
      var bolFound;
      for (var i=0;i<objSelRulValue.options.length;i++) {
         if (objSelRulValue.options[i].selected == true) {
            bolFound = false;
            for (var j=0;i<objSelSelValue.options.length;i++) {
               if (objSelRulValue[i].value == objSelSelValue[i].value) {
                  bolFound = true;
                  break;
               }
            }
            if (!bolFound) {
               objSelSelValue.options[objSelSelValue.options.length] = new Option(objSelRulValue[i].text,objSelRulValue[i].value);
            }
         }
      }
      var objWork = new Array();
      var intIndex = 0
      for (var i=0;i<objSelSelValue.options.length;i++) {
         objWork[intIndex] = objSelSelValue[i];
         intIndex++;
      }
      objWork.sort(sortSchListValues);
      objSelSelValue.options.length = 0;
      objSelSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSelSelValue.options[i] = objWork[i];
      }
   }
   function removeSchListValues() {
      var objSelSelValue = document.getElementById('SEL_SelValue');
      var objWork = new Array();
      var intIndex = 0;
      for (var i=0;i<objSelSelValue.options.length;i++) {
         if (objSelSelValue.options[i].selected == false) {
            objWork[intIndex] = objSelSelValue[i];
            intIndex++;
         }
      }
      objSelSelValue.options.length = 0;
      objSelSelValue.selectedIndex = -1;
      for (var i=0;i<objWork.length;i++) {
         objSelSelValue.options[i] = objWork[i];
      }
   }
   function sortSchListValues(obj01, obj02) {
      if (obj01.value < obj02.value) {
         return -1;
      } else if (obj01.value > obj02.value) {
         return 1;
      }
      return 0;
   }

   /////////////////////////////
   // Search Number Functions //
   /////////////////////////////
   function doSchNumbCancel() {
      displaySchRule();
   }
   function doSchNumbAccept() {
      if (!processForm()) {return;}
      var objSenRulCode = document.getElementById('SEN_RulCode');
      var objSenSelValue = document.getElementById('SEN_SelValue');
      var strMessage = '';
      if (objSenRulCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection rule must be selected';
      }
      if (objSenSelValue.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection value must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var aryRulData = objSenRulValue[objSenRulCode.selectedIndex].value.split(':');
      cobjSearchRow.setAttribute('rulcde',aryRulData[0]);
      cobjSearchRow.setAttribute('rulcnd',aryRulData[1]);
      var objValues = cobjSearchRow.getAttribute('valary');
      objValues.length = 0;
      objValues[0] = new clsSchValue('1',objSenSelValue.value);
      cobjSearchRow.cells[1].innerText = cobjSearchRow.getAttribute('fldtxt')+' '+aryRulData[0]+' '+objSenSelValue.value;
      displaySchList();
      objSelRulCode.focus();
   }

   ///////////////////////////
   // Search Text Functions //
   ///////////////////////////
   function doSchTextCancel() {
      displaySchRule();
   }
   function doSchTextAccept() {
      if (!processForm()) {return;}
      var objSetRulCode = document.getElementById('SET_RulCode');
      var objSetSelValue = document.getElementById('SET_SelValue');
      var strMessage = '';
      if (objSetRulCode.selectedIndex == -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection rule must be selected';
      }
      if (objSetSelValue.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Selection value must be entered';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var aryRulData = objSetRulValue[objSetRulCode.selectedIndex].value.split(':');
      cobjSearchRow.setAttribute('rulcde',aryRulData[0]);
      cobjSearchRow.setAttribute('rulcnd',aryRulData[1]);
      var objValues = cobjSearchRow.getAttribute('valary');
      objValues.length = 0;
      objValues[0] = new clsSchValue('1',objSetSelValue.value);
      cobjSearchRow.cells[1].innerText = cobjSearchRow.getAttribute('fldtxt')+' '+aryRulData[0]+' '+objSetSelValue.value;
      displaySchList();
      objSelRulCode.focus();
   }

   /////////////////////////////
   // Search Select Functions //
   /////////////////////////////
   function requestSearchSelect() {
      cstrSearchMode = '*SLT';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*SELDTA" ENDCDE="0">';
      var objTable = document.getElementById('tabSchRule');
      var objRow;
      var objValues;
      var intGroup;
      if (objTable.rows.length != 0) {
         strXML = strXML+'<GROUPS>';
         for (var i=0;i<objTable.rows.length;i++) {
            var objRow = objTable.rows[i];
            if (objRow.getAttribute('tabcde') == '*GROUP') {
               if (intGroup > 0) {
                  strXML = strXML+'</GROUP>';
               }
               intGroup++;
               strXML = strXML+'<GROUP GRPCDE="*GROUP'+intGroup+'">';
            } else {
               if (objRow.getAttribute('rulcde') != '' && objRow.getAttribute('valary').length != 0) {
                  strXML = strXML+'<RULE TABCDE="'+objRow.getAttribute('tabcde')+'" FLDCDE="'+objRow.getAttribute('fldcde')+'" RULCDE="'+objRow.getAttribute('rulcde')+'"><VALUES>';
                  var objValues = objRow.getAttribute('valary');
                  for (var j=0;j<objValues.length;j++) {
                     strXML = strXML+'<VALUE VALCDE="'+objValues[j].valcde+'" VALTXT="'+objValues[j].valtxt+'"/>';
                  }
                  strXML = strXML+'</VALUES></RULE>';
               }
            }
         }
         strXML = strXML+'</GROUPS>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doPostRequest('<%=strBase%>pts_sam_search.asp',function(strResponse) {checkSearchResponse(strResponse);},false,streamXML(strXML));
   }
   function doSchSlctMore() {
      if (!processForm()) {return;}
      cstrSearchMode = '*MOR';
      var strEndCode = '0';
      var objList = document.getElementById('SES_SelList');
      if (objList.rows.length != 0) {
         strEndCode = objList.rows[objList.rows.length-1].getAttribute('selcde');
      }
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*SELDTA" ENDCDE="'+strEndCode+'">';
      var objTable = document.getElementById('tabSchRule');
      var objRow;
      var objValues;
      var intGroup;
      if (objTable.rows.length != 0) {
         strXML = strXML+'<GROUPS>';
         for (var i=0;i<objTable.rows.length;i++) {
            var objRow = objTable.rows[i];
            if (objRow.getAttribute('tabcde') == '*GROUP') {
               if (intGroup > 0) {
                  strXML = strXML+'</GROUP>';
               }
               intGroup++;
               strXML = strXML+'<GROUP GRPCDE="*GROUP'+intGroup+'">';
            } else {
               if (objRow.getAttribute('rulcde') != '' && objRow.getAttribute('valary').length != 0) {
                  strXML = strXML+'<RULE TABCDE="'+objRow.getAttribute('tabcde')+'" FLDCDE="'+objRow.getAttribute('fldcde')+'" RULCDE="'+objRow.getAttribute('rulcde')+'"><VALUES>';
                  var objValues = objRow.getAttribute('valary');
                  for (var j=0;j<objValues.length;j++) {
                     strXML = strXML+'<VALUE VALCDE="'+objValues[j].valcde+'" VALTXT="'+objValues[j].valtxt+'"/>';
                  }
                  strXML = strXML+'</VALUES></RULE>';
               }
            }
         }
         strXML = strXML+'</GROUPS>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doPostRequest('<%=strBase%>pts_sam_search.asp',function(strResponse) {checkSearchResponse(strResponse);},false,streamXML(strXML));
   }
   function checkSearchResponse(strResponse) {
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var objDocument = loadXML(strResponse);
         if (varDocument == null) {return;}
         var objTable = document.getElementById('SES_SelList');
         var objRow;
         var objCell;
         if (cstrSearchMode == '*SLT') {
            for (var i=objTable.rows.length-1;i>=0;i--) {
               objTable.deleteRow(i);
            }
         }
         var objElements = objDocument.documentElement.childNodes;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'SAMPLE') {
               objRow = objTable.insertRow(-1);
               objRow.setAttribute('selcde',objElements[i].getAttribute('SAMCODE'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerText = '<nobr><a class="clsSelect" href="javascript:doSchSlctAccept(\''+objElements[i].getAttribute('SAMCODE')+'\');">Select</a></nobr>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('SAMTEXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(2);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('SAMSTAT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         if (objTable.rows.length == 0) {
            objRow = objTable.insertRow(-1);
            objCell = objRow.insertCell(0);
            objCell.colSpan = 3;
            objCell.innerText = 'NO DATA FOUND';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
         }
         displaySchSlct();
      }
   }
   function doSchSlctAccept(strCode) {
      document.getElementById('PRO_SamCode').value = strCode;
      displayPrompt();
      document.getElementById('PRO_SamCode').focus();
   }
   function doSchSlctCancel() {
      displaySchRule();
   }

// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_xml.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_sam_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Sample Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Sample Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_SamCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=7 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPromptCreate();">&nbsp;Create&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPromptUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPromptCopy();">&nbsp;Copy&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPromptSearch();">&nbsp;Search&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspDefine" class="clsGrid02" style="display:block;visibility:hidden" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedDefine" class="clsFunction" align=center colspan=2 nowrap><nobr>Sample Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Sample Code:&nbsp;</nobr></td>
         <td id="DEF_SamCode" class="clsLabelBB" align=left valign=center colspan=1 nowrap><nobr></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Sample Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_SamText" size="64" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Sample Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_SamStat"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Unit Of Measure:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_UomCode"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Prepared Location:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_PreLocn"></select>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDefineCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDefineAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspSchRule" class="clsGrid02" style="display:block;visibility:hidden" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedSchRule" class="clsFunction" align=center colspan=2 nowrap><nobr>Sample Search Rules</nobr></td>
      </tr>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchRuleAddGroup();">&nbsp;Add Group&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="tabSchRule" class="clsTableBody" cols=2 align=left cellpadding="2" cellspacing="1"></table>
            </div>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchRuleCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchRuleSelect();">&nbsp;Select&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspSchList" class="clsGrid02" style="display:block;visibility:hidden" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedSchList" class="clsFunction" align=center colspan=2 nowrap><nobr>Sample Search List Rule</nobr></td>
      </tr>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBN" align=left valign=center colspan=2 nowrap><nobr><select class="clsInputBN" id="SEL_RulCode"></select></nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsGrid02" align=center valign=top cols=2 width=100% cellpadding=0 cellspacing=0>
               <tr>
                  <td class="clsLabelBN" align=center colspan=2 nowrap><nobr>
                     <table align=center border=0 cellpadding=0 cellspacing=2 cols=3>
                        <tr>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Available Values&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Selected Values&nbsp;</nobr></td>
                        </tr>
                        <tr>
                           <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                              <select class="clsInputBN" id="SEL_RulValue" name="SEL_RulValue" style="width:300px" multiple size=20></select>
                           </nobr></td>
                           <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>
                              <table class="clsTable01" width=100% align=center cols=2 cellpadding="0" cellspacing="0">
                                 <tr>
                                    <td align=right colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_loff.gif" align=absmiddle onClick="removeSchListValues();"></nobr></td>
                                    <td align=left colspan=1 nowrap><nobr><img class="clsImagePush" src="nav_roff.gif" align=absmiddle onClick="selectSchListValues();"></nobr></td>
                                 </tr>
                              </table>
                           </nobr></td>
                           <td class="clsLabelBN" align=center colspan=1 nowrap><nobr>
                              <select class="clsInputBN" id="SEL_SelValue" name="SEL_SelValue" style="width:300px" multiple size=20></select>
                           </nobr></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchListCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchListAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspSchNumb" class="clsGrid02" style="display:block;visibility:hidden" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedSchNumb" class="clsFunction" align=center colspan=2 nowrap><nobr>Sample Search Number Rule</nobr></td>
      </tr>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBN" align=left valign=center colspan=2 nowrap><nobr><select class="clsInputBN" id="SEN_RulCode"></select></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Selection Value:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SEN_SelValue" size="15" maxlength="15" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchNumbCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchNumbAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspSchText" class="clsGrid02" style="display:block;visibility:hidden" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedSchText" class="clsFunction" align=center colspan=2 nowrap><nobr>Sample Search Text Rule</nobr></td>
      </tr>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBN" align=left valign=center colspan=2 nowrap><nobr><select class="clsInputBN" id="SET_RulCode"></select></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Selection Value:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="SET_SelValue" size="64" maxlength="256" value="" onFocus="setSelect(this);">
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchTextCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchTextAccept();">&nbsp;Accept&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspSchSlct" class="clsGrid02" style="display:block;visibility:hidden" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
         <td id="hedSchSlct" class="clsFunction" align=center colspan=2 nowrap><nobr>Sample Selection</nobr></td>
      </tr>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchSlctMore();">&nbsp;More&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="SEL_SelList" class="clsTableBody" cols=2 align=left cellpadding="2" cellspacing="1"></table>
            </div>
         </nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchSlctCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->