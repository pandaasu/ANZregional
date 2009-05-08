<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
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

   ////////////////////
   // Load Functions //
   ////////////////////
   function loadFunction() {
      cobjScreens[0] = new clsScreen('dspPrompt','hedPrompt');
      cobjScreens[1] = new clsScreen('dspDefine','hedDefine');
      cobjScreens[0].hedtxt ='Sample Prompt';
      cobjScreens[1].hedtxt ='Sample Maintenance';
      initSearch();
      displayScreen('dspPrompt');
      document.getElementById('PRO_SamCode').focus();
   }

   ///////////////////////
   // Control Functions //
   ///////////////////////
   var cobjScreens = new Array();
   function clsScreen(strScrName,strHedName) {
      this.scrnam = strScrName;
      this.hednam= strHedName;
      this.hedtxt= '';
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
         } else {
            objScreen.style.display = 'none';
            objHeading.innerText = cobjScreens[i].hedtxt;
         }
      }
   }

   //////////////////////
   // Prompt Functions //
   //////////////////////
   function doPromptEnter() {
      if (document.getElementById('PRO_SamCode').value == '') {
         doPromptCreate();
      } else {
         doPromptUpdate();
      }
   }
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
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+document.getElementById('PRO_SamCode').value+'\');',10);
   }
   function doPromptCreate() {
      if (!processForm()) {return;}
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\');',10);
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
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+document.getElementById('PRO_SamCode').value+'\');',10);
   }
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*SAMPLE','Sample','pts_sam_search.asp','0',function() {doPromptSamCancel();},function(strCode,strText) {doPromptSamSelect(strCode,strText);});
   }
   function doPromptSamCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_SamCode').focus();
   }
   function doPromptSamSelect(strCode,strText) {
      document.getElementById('PRO_SamCode').value = strCode;
      displayScreen('dspPrompt');
      document.getElementById('PRO_SamCode').focus();
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDSAM" SAMCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_sam_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode) {
      cstrDefineMode = '*CRT';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTSAM" SAMCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_sam_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYSAM" SAMCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_sam_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[1].hedtxt ='Update Sample';
         } else {
            cobjScreens[1].hedtxt ='Create Sample';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_SamCode').innerText = '';
         document.getElementById('DEF_SamText').value = '';
         document.getElementById('DEF_UomSize').value = '';
         document.getElementById('DEF_PreDate').value = '';
         document.getElementById('DEF_ExtRfnr').value = '';
         document.getElementById('DEF_PlopCde').value = '';
         var strSamStat;
         var strUomCode;
         var strPreLocn;
         var objSamStat = document.getElementById('DEF_SamStat');
         var objUomCode = document.getElementById('DEF_UomCode');
         var objPreLocn = document.getElementById('DEF_PreLocn');
         objSamStat.options.length = 0;
         objUomCode.options.length = 0;
         objPreLocn.options.length = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'STA_LIST') {
               objSamStat.options[objSamStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'UOM_LIST') {
               objUomCode.options[objUomCode.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'PRE_LIST') {
               objPreLocn.options[objPreLocn.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'SAMPLE') {
               document.getElementById('DEF_SamCode').innerText = objElements[i].getAttribute('SAMCODE');
               document.getElementById('DEF_SamText').value = objElements[i].getAttribute('SAMTEXT');
               document.getElementById('DEF_UomSize').value = objElements[i].getAttribute('UOMSIZE');
               document.getElementById('DEF_PreDate').value = objElements[i].getAttribute('PREDATE');
               document.getElementById('DEF_ExtRfnr').value = objElements[i].getAttribute('EXTRFNR');
               document.getElementById('DEF_PlopCde').value = objElements[i].getAttribute('PLOPCDE');
               strSamStat = objElements[i].getAttribute('SAMSTAT');
               strUomCode = objElements[i].getAttribute('UOMCODE');
               strPreLocn = objElements[i].getAttribute('PRELOCN');
            }
         }
         objSamStat.selectedIndex = -1;
         for (var i=0;i<objSamStat.length;i++) {
            if (objSamStat.options[i].value == strSamStat) {
               objSamStat.options[i].selected = true;
               break;
            }
         }
         objUomCode.selectedIndex = -1;
         for (var i=0;i<objUomCode.length;i++) {
            if (objUomCode.options[i].value == strUomCode) {
               objUomCode.options[i].selected = true;
               break;
            }
         }
         objPreLocn.selectedIndex = -1;
         for (var i=0;i<objPreLocn.length;i++) {
            if (objPreLocn.options[i].value == strPreLocn) {
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
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>pts_sam_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         }
         displayScreen('dspPrompt');
         document.getElementById('PRO_SamCode').value = '';
         document.getElementById('PRO_SamCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_SamCode').value = '';
      document.getElementById('PRO_SamCode').focus();
   }

   ///////////////////////////
   // Search Rule Functions //
   ///////////////////////////
   var cstrSearchEntity;
   var cstrSearchHeading;
   var cstrSearchScript;
   var cobjSearchData;
   var cstrSearchTest;
   var cstrSearchCancel;
   var cobjSearchAccept;
   var cstrSearchMode;
   var cstrSearchGrpCde;
   var cstrSearchTabCde;
   var cstrSearchFldCde;
   var cstrSearchFldTxt;
   var cstrSearchRulTyp;
   var cstrSearchRulCde;
   var cintSearchRow;
   var cobjSearchArray;
   var cintSearchInstance;
   function clsSchInstance() {
      this.entnam = '';
      this.hedtxt = '';
      this.srvnam = '';
      this.schdat = new Array();
   }
   function clsSchRule() {
      this.grpcde = '';
      this.tabcde = '';
      this.fldcde = '';
      this.fldtxt = '';
      this.rultyp = '';
      this.rulcde = '';
      this.valary = new Array();
   }
   function clsSchValue(strValCde,strValTxt) {
      this.valcde = strValCde;
      this.valtxt = strValTxt;
   }
   function initSearch() {
      cobjScreens[cobjScreens.length] = new clsScreen('dspSchRule','hedSchRule');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSchFeld','hedSchFeld');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSchList','hedSchList');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSchNumb','hedSchNumb');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSchText','hedSchText');
      cobjScreens[cobjScreens.length] = new clsScreen('dspSchSlct','hedSchSlct');
      cintSearchInstance = -1;
      cobjSearchArray = new Array();
   }
   function startSchInstance(strEntity,strHeading,strScript,strTest,strCancel,strAccept) {
      cstrSearchTest = strTest;
      cstrSearchCancel = strCancel;
      cstrSearchAccept = strAccept;
      var intSearchInstance = -1;
      for (var i=0;i<cobjSearchArray.length;i++) {
         if (cobjSearchArray[i].entnam == strEntity) {
            intSearchInstance = i;
         }
      }
      if (intSearchInstance == -1) {
         var objInstance = new clsSchInstance();
         objInstance.entnam = strEntity;
         objInstance.hedtxt = strHeading;
         objInstance.srvnam = strScript;
         cobjSearchArray[cobjSearchArray.length] = objInstance;
         intSearchInstance = cobjSearchArray.length-1;
      }
      if (cintSearchInstance != intSearchInstance) {
         cintSearchInstance = intSearchInstance;
         cstrSearchEntity = cobjSearchArray[cintSearchInstance].entnam;
         cstrSearchHeading = cobjSearchArray[cintSearchInstance].hedtxt;
         cstrSearchScript = cobjSearchArray[cintSearchInstance].srvnam;
         cobjSearchData = cobjSearchArray[cintSearchInstance].schdat;
         var objScreen;
         var objHeading;
         for (var i=0;i<cobjScreens.length;i++) {
            if (cobjScreens[i].scrnam == 'dspSchRule') {
              cobjScreens[i].hedtxt = cstrSearchHeading+' Search Rules';
            } else if (cobjScreens[i].scrnam == 'dspSchFeld') {
               cobjScreens[i].hedtxt = cstrSearchHeading+' Search Fields';
            } else if (cobjScreens[i].scrnam == 'dspSchList') {
               cobjScreens[i].hedtxt = cstrSearchHeading+' Search List Rule';
            } else if (cobjScreens[i].scrnam == 'dspSchNumb') {
               cobjScreens[i].hedtxt = cstrSearchHeading+' Search Number Rule';
            } else if (cobjScreens[i].scrnam == 'dspSchText') {
               cobjScreens[i].hedtxt = cstrSearchHeading+' Search Text Rule';
            } else if (cobjScreens[i].scrnam == 'dspSchSlct') {
               cobjScreens[i].hedtxt = cstrSearchHeading+' Selection';
            }
         }
         loadSchData();
      }
      displayScreen('dspSchRule');
   }
   function loadSchData() {
      var objTable = document.getElementById('tabSchRule');
      var objFont = document.getElementById('fntSchRule');
      var objRow;
      var objCell;
      var bolFound = false;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objTable.deleteRow(i);
      }
      for (var i=0;i<cobjSearchData.length;i++) {
         if (cobjSearchData[i].tabcde == '*GROUP') {
            objRow = objTable.insertRow(-1);
            objRow.setAttribute('grpcde',cobjSearchData[i].grpcde);
            objRow.setAttribute('tabcde',cobjSearchData[i].tabcde);
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            objCell.innerHTML = '<a class="clsSelect" href="javascript:doSchRuleAddRule(\''+objRow.rowIndex+'\');">Add Rule</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doSchRuleDelGroup(\''+objRow.rowIndex+'\');">Delete</a>';
            objCell.className = 'clsLabelFN';
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(1);
            objCell.colSpan = 1;
            objCell.innerText = '';
            if (!bolFound) {
               objCell.innerText = 'SELECTION GROUP - WHERE';
            } else {
               objCell.innerText = 'SELECTION GROUP - OR';
            }
            bolFound = true;
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
         } else {
            objRow = objTable.insertRow(-1);
            objRow.setAttribute('grpcde',cobjSearchData[i].grpcde);
            objRow.setAttribute('tabcde',cobjSearchData[i].tabcde);
            objRow.setAttribute('fldcde',cobjSearchData[i].fldcde);
            objRow.setAttribute('fldtxt',cobjSearchData[i].fldtxt);
            objRow.setAttribute('rultyp',cobjSearchData[i].rultyp);
            objRow.setAttribute('rulcde',cobjSearchData[i].rulcde);
            var strText = cobjSearchData[i].fldtxt+' - NO VALUES';
            if (cobjSearchData[i].rulcde != '') {
               strText = cobjSearchData[i].fldtxt+' - '+cobjSearchData[i].rulcde;
               var objValues = new Array();
               for (var j=0;j<cobjSearchData[i].valary.length;j++) {
                  objValues[j] = new clsSchValue(cobjSearchData[i].valary[j].valcde,cobjSearchData[i].valary[j].valtxt);
                  if (j == 0) {
                     if (cobjSearchData[i].rultyp == '*TEXT') {
                        strText = strText+' - "'+cobjSearchData[i].valary[j].valtxt+'"';
                     } else {
                        strText = strText+' - '+cobjSearchData[i].valary[j].valtxt;
                     }
                  } else {
                     if (cobjSearchData[i].rultyp == '*TEXT') {
                        strText = strText+', "'+cobjSearchData[i].valary[j].valtxt+'"';
                     } else {
                        strText = strText+', '+cobjSearchData[i].valary[j].valtxt;
                     }
                  }
               }
               objRow.setAttribute('valary',objValues);
            }
            objCell = objRow.insertCell(0);
            objCell.colSpan = 1;
            objCell.innerHTML = '<a class="clsSelect" href="javascript:doSchRuleUpdRule(\''+objRow.rowIndex+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doSchRuleDelRule(\''+objRow.rowIndex+'\');">Delete</a>';
            objCell.className = 'clsLabelFN';
            objCell.style.whiteSpace = 'nowrap';
            objCell = objRow.insertCell(1);
            objCell.colSpan = 1;
            objCell.innerText = strText;
            objCell.className = 'clsLabelFN';
            objCell.style.whiteSpace = 'nowrap';
         }
      }
      objTable.style.display = 'block';
      objFont.style.display = 'none';
      if (objTable.rows.length == 0) {
         objTable.style.display = 'none';
         objFont.style.display = 'block';
      }
   }
   function updateSchData() {
      var objTable = document.getElementById('tabSchRule');
      var objFont = document.getElementById('fntSchRule');
      var objValues;
      var bolFound = false;
      cobjSearchData.length = 0;
      for (var i=0;i<objTable.rows.length;i++) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('tabcde') == '*GROUP') {
            objRow.cells[0].innerHTML = '<a class="clsSelect" href="javascript:doSchRuleAddRule(\''+objRow.rowIndex+'\');">Add Rule</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doSchRuleDelGroup(\''+objRow.rowIndex+'\');">Delete</a>';
            if (!bolFound) {
               objRow.cells[1].innerText = 'SELECTION GROUP - WHERE';
            } else {
               objRow.cells[1].innerText = 'SELECTION GROUP - OR';
            }
            bolFound = true;
            cobjSearchData[i] = new clsSchRule();
            cobjSearchData[i].grpcde = objRow.getAttribute('grpcde');
            cobjSearchData[i].tabcde = objRow.getAttribute('tabcde');
         } else {
            objRow.cells[0].innerHTML = '<a class="clsSelect" href="javascript:doSchRuleUpdRule(\''+objRow.rowIndex+'\');">Update</a>&nbsp;/&nbsp;<a class="clsSelect" href="javascript:doSchRuleDelRule(\''+objRow.rowIndex+'\');">Delete</a>';
            cobjSearchData[i] = new clsSchRule();
            cobjSearchData[i].grpcde = objRow.getAttribute('grpcde');
            cobjSearchData[i].tabcde = objRow.getAttribute('tabcde');
            cobjSearchData[i].fldcde = objRow.getAttribute('fldcde');
            cobjSearchData[i].fldtxt = objRow.getAttribute('fldtxt');
            cobjSearchData[i].rultyp = objRow.getAttribute('rultyp');
            cobjSearchData[i].rulcde = objRow.getAttribute('rulcde');
            if (cobjSearchData[i].rulcde != '') {
               cobjSearchData[i].valary.length = 0;
               objValues = objRow.getAttribute('valary');
               for (var j=0;j<objValues.length;j++) {
                  cobjSearchData[i].valary[j] = new clsSchValue(objValues[j].valcde,objValues[j].valtxt);
               }
            }
         }
      }
      objTable.style.display = 'block';
      objFont.style.display = 'none';
      if (objTable.rows.length == 0) {
         objTable.style.display = 'none';
         objFont.style.display = 'block';
      }
   }
   function addSchData(objRule) {
      var objWork = new Array();
      var bolGroup = false;
      var bolInsert = false;
      var intIndex = 0
      for (var i=0;i<cobjSearchData.length;i++) {
         if (cobjSearchData[i].grpnam != cstrSearchGrpCde) {
            if (bolGroup && !bolInsert) {
               bolInsert = true;
               objWork[intIndex] = objRule;
               intIndex++;
            }
            objWork[intIndex] = cobjSearchData[i];
            intIndex++;
         } else {
            bolGroup = true;
            objWork[intIndex] = cobjSearchData[i];
            intIndex++;
         }
      }
      if (!bolInsert) {
         objWork[intIndex] = objRule;
      }
      cobjSearchData.length = 0;
      for (var i=0;i<objWork.length;i++) {
         cobjSearchData[i] = objWork[i];
      }
   }
   function doSchRuleAddGroup() {
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
      objCell.innerHTML = '';
      objCell.className = 'clsLabelFN';
      objCell.style.whiteSpace = 'nowrap';
      objCell = objRow.insertCell(1);
      objCell.colSpan = 1;
      objCell.innerText = '';
      objCell.className = 'clsLabelFB';
      objCell.style.whiteSpace = 'nowrap';
      updateSchData();
   }
   function doSchRuleAddRule(intRow) {
      var objTable = document.getElementById('tabSchRule');
      cstrSearchGrpCde = objTable.rows[intRow].getAttribute('grpcde');
      doActivityStart(document.body);
      window.setTimeout('requestSchFeldList();',10);
   }
   function doSchRuleDelGroup(intRow) {
      var objTable = document.getElementById('tabSchRule');
      var strGroup = objTable.rows[intRow].getAttribute('grpcde');
      var objRow;
      for (var i=objTable.rows.length-1;i>=0;i--) {
         objRow = objTable.rows[i];
         if (objRow.getAttribute('grpcde') == strGroup) {
            objTable.deleteRow(i);
         }
      }
      updateSchData();
   }
   function doSchRuleUpdRule(intRow) {
      var objTable = document.getElementById('tabSchRule');
      cintSearchRow = intRow;
      cstrSearchGrpCde = cobjSearchData[cintSearchRow].grpcde;
      cstrSearchTabCde = cobjSearchData[cintSearchRow].tabcde;
      cstrSearchFldCde = cobjSearchData[cintSearchRow].fldcde;
      cstrSearchRulTyp = cobjSearchData[cintSearchRow].rultyp;
      cstrSearchRulCde = cobjSearchData[cintSearchRow].rulcde;
      doActivityStart(document.body);
      window.setTimeout('requestSchFeldUpdate();',10);
   }
   function doSchRuleDelRule(intRow) {
      var objTable = document.getElementById('tabSchRule');
      objTable.deleteRow(intRow);
      updateSchData();
   }
   function doSchRuleSelect() {
      if (!processForm()) {return;}
      doSchSlctSelect();
   }
   function doSchRuleCancel() {
      cstrSearchCancel();
   }

   ////////////////////////////
   // Search Field Functions //
   ////////////////////////////
   function doSchFeldCancel() {
      displayScreen('dspSchRule');
   }
   function doSchFeldSelect(intRow) {
      var objTable = document.getElementById('tabSchFeld');
      objFieldRow = objTable.rows[intRow];
      var bolFound = false;
      for (var i=0;i<cobjSearchData.length;i++) {
         if (cobjSearchData[i].grpcde == cstrSearchGrpCde && 
             cobjSearchData[i].tabcde == objFieldRow.getAttribute('tabcde') && 
             cobjSearchData[i].fldcde == objFieldRow.getAttribute('fldcde')) {
            bolFound = true;
            break;
         }
      }
      if (bolFound) {
         alert('Field already selected in rule group');
         return;
      }
      cintSearchRow = -1;
      cstrSearchTabCde = objFieldRow.getAttribute('tabcde');
      cstrSearchFldCde = objFieldRow.getAttribute('fldcde');
      cstrSearchFldTxt = objFieldRow.getAttribute('fldtxt');
      cstrSearchRulTyp = objFieldRow.getAttribute('rultyp');
      cstrSearchRulCde = '';
      doActivityStart(document.body);
      window.setTimeout('requestSchFeldUpdate();',10);
   }
   function requestSchFeldList() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTFLD" ENTCDE="'+cstrSearchEntity+'" TESFLG="'+cstrSearchTest+'"/>';
      doPostRequest('<%=strBase%>pts_sys_fld_list.asp',function(strResponse) {checkSchFeldList(strResponse);},false,streamXML(strXML));
   }
   function checkSchFeldList(strResponse) {
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
         displayScreen('dspSchFeld');
         var objTable = document.getElementById('tabSchFeld');
         for (var i=objTable.rows.length-1;i>=0;i--) {
            objTable.deleteRow(i);
         }
         var objRow;
         var objCell;
         var strTabCode;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'TABLE') {
               objRow = objTable.insertRow(-1);
               objCell = objRow.insertCell(0);
               objCell.colSpan = 2;
               objCell.innerText = objElements[i].getAttribute('TABTXT');
               objCell.className = 'clsLabelFB';
               objCell.style.whiteSpace = 'nowrap';
               strTabCode = objElements[i].getAttribute('TABCDE');
            } else if (objElements[i].nodeName == 'FIELD') {
               objRow = objTable.insertRow(-1);
               objRow.setAttribute('tabcde',strTabCode);
               objRow.setAttribute('fldcde',objElements[i].getAttribute('FLDCDE'));
               objRow.setAttribute('fldtxt',objElements[i].getAttribute('FLDTXT'));
               objRow.setAttribute('rultyp',objElements[i].getAttribute('RULTYP'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '<a class="clsSelect" href="javascript:doSchFeldSelect(\''+objRow.rowIndex+'\');">Select</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('FLDTXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
      }
   }
   function requestSchFeldUpdate(strXML) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*LSTRUL" TABCDE="'+cstrSearchTabCde+'" FLDCDE="'+cstrSearchFldCde+'"/>';
      doPostRequest('<%=strBase%>pts_sys_rul_list.asp',function(strResponse) {checkSchFeldUpdate(strResponse);},false,streamXML(strXML));
   }
   function checkSchFeldUpdate(strResponse) {
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
         if (cstrSearchRulTyp == '*LIST') {
            var objSelRulCode = document.getElementById('SEL_RulCode');
            var objSelRulValue = document.getElementById('SEL_RulValue');
            var objSelSelValue = document.getElementById('SEL_SelValue');
            objSelRulCode.options.length = 0;
            objSelRulCode.selectedIndex = 1;
            objSelRulValue.options.length = 0;
            objSelRulValue.selectedIndex = -1;
            objSelSelValue.options.length = 0;
            objSelSelValue.selectedIndex = -1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSelRulCode.options[objSelRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSearchRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSelRulCode.options[objSelRulCode.options.length-1].selected = true;
                  }
               } else if (objElements[i].nodeName == 'VALUE') {
                  objSelRulValue.options[objSelRulValue.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
               }
            }
            if (cintSearchRow != -1) {
               var objValues = cobjSearchData[cintSearchRow].valary;
               for (var i=0;i<objValues.length;i++) {
                  objSelSelValue.options[i] = new Option(objValues[i].valtxt,objValues[i].valcde);
               }
            }
            displayScreen('dspSchList');
            objSelRulCode.focus();
         } else if (cstrSearchRulTyp == '*NUMBER') {
            var objSenRulCode = document.getElementById('SEN_RulCode');
            var objSenSelValue = document.getElementById('SEN_SelValue');
            objSenRulCode.options.length = 0;
            objSenRulCode.selectedIndex = 1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSenRulCode.options[objSenRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSearchRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSenRulCode.options[objSenRulCode.options.length-1].selected = true;
                  }
               }
            }
            objSenSelValue.value = '';
            if (cintSearchRow != -1) {
               var objValues = cobjSearchData[cintSearchRow].valary;
               if (objValues.length != 0) {
                  objSenSelValue.value = objValues[0].valtxt;
               }
            }
            displayScreen('dspSchNumb');
            objSenRulCode.focus();
         } else if (cstrSearchRulTyp == '*TEXT') {
            var objSetRulCode = document.getElementById('SET_RulCode');
            var objSetSelValue = document.getElementById('SET_SelValue');
            objSetRulCode.options.length = 0;
            objSetRulCode.selectedIndex = 1;
            for (var i=0;i<objElements.length;i++) {
               if (objElements[i].nodeName == 'RULE') {
                  objSetRulCode.options[objSetRulCode.options.length] = new Option(objElements[i].getAttribute('RULCDE'),objElements[i].getAttribute('RULCDE'));
                  if (cstrSearchRulCde == objElements[i].getAttribute('RULCDE')) {
                     objSetRulCode.options[objSetRulCode.options.length-1].selected = true;
                  }
               }
            }
            objSetSelValue.value = '';
            if (cintSearchRow != -1) {
               var objValues = cobjSearchData[cintSearchRow].valary;
               if (objValues.length != 0) {
                  objSetSelValue.value = objValues[0].valtxt;
               }
            }
            displayScreen('dspSchText');
            objSetRulCode.focus();
         } else {
            alert('Unknown Rule Type ('+cstrSearchRulCde+')');
         }
      }
   }

   ///////////////////////////
   // Search List Functions //
   ///////////////////////////
   function doSchListCancel() {
      displayScreen('dspSchRule');
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
      if (cintSearchRow != -1) {
         cobjSearchData[cintSearchRow].rulcde = objSelRulCode[objSelRulCode.selectedIndex].value;
         var objValues = cobjSearchData[cintSearchRow].valary;
         objValues.length = 0;
         for (var i=0;i<objSelSelValue.options.length;i++) {
            objValues[i] = new clsSchValue(objSelSelValue[i].value,objSelSelValue[i].text);
         }
      } else {
         var objRule = new clsSchRule();
         objRule.grpcde = cstrSearchGrpCde;
         objRule.tabcde = cstrSearchTabCde;
         objRule.fldcde = cstrSearchFldCde;
         objRule.fldtxt = cstrSearchFldTxt;
         objRule.rultyp = cstrSearchRulTyp;
         objRule.rulcde = objSelRulCode[objSelRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         for (var i=0;i<objSelSelValue.options.length;i++) {
            objValues[i] = new clsSchValue(objSelSelValue[i].value,objSelSelValue[i].text);
         }
         addSchData(objRule);
      }
      displayScreen('dspSchRule');
      loadSchData();
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
      if ((obj01.value-0) < (obj02.value-0)) {
         return -1;
      } else if ((obj01.value-0) > (obj02.value-0)) {
         return 1;
      }
      return 0;
   }

   /////////////////////////////
   // Search Number Functions //
   /////////////////////////////
   function doSchNumbCancel() {
      displayScreen('dspSchRule');
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
      if (cintSearchRow != -1) {
         cobjSearchData[cintSearchRow].rulcde = objSenRulCode[objSenRulCode.selectedIndex].value;
         var objValues = cobjSearchData[cintSearchRow].valary;
         objValues.length = 0;
         objValues[0] = new clsSchValue('1',objSenSelValue.value);
      } else {
         var objRule = new clsSchRule();
         objRule.grpcde = cstrSearchGrpCde;
         objRule.tabcde = cstrSearchTabCde;
         objRule.fldcde = cstrSearchFldCde;
         objRule.fldtxt = cstrSearchFldTxt;
         objRule.rultyp = cstrSearchRulTyp;
         objRule.rulcde = objSenRulCode[objSenRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         objValues[0] = new clsSchValue('1',objSenSelValue.value);
         addSchData(objRule);
      }
      displayScreen('dspSchRule');
      loadSchData();
   }

   ///////////////////////////
   // Search Text Functions //
   ///////////////////////////
   function doSchTextCancel() {
      displayScreen('dspSchRule');
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
      if (cintSearchRow != -1) {
         cobjSearchData[cintSearchRow].rulcde = objSetRulCode[objSetRulCode.selectedIndex].value;
         var objValues = cobjSearchData[cintSearchRow].valary;
         objValues.length = 0;
         objValues[0] = new clsSchValue('1',objSetSelValue.value);
      } else {
         var objRule = new clsSchRule();
         objRule.grpcde = cstrSearchGrpCde;
         objRule.tabcde = cstrSearchTabCde;
         objRule.fldcde = cstrSearchFldCde;
         objRule.fldtxt = cstrSearchFldTxt;
         objRule.rultyp = cstrSearchRulTyp;
         objRule.rulcde = objSetRulCode[objSetRulCode.selectedIndex].value;
         var objValues = objRule.valary;
         objValues.length = 0;
         objValues[0] = new clsSchValue('1',objSetSelValue.value);
         addSchData(objRule);
      }
      displayScreen('dspSchRule');
      loadSchData();
   }

   /////////////////////////////
   // Search Select Functions //
   /////////////////////////////
   function doSchSlctSelect() {
      cstrSearchMode = '*SLT';
      var strEndCode = '0';
      doActivityStart(document.body);
      window.setTimeout('requestSchSlct(\''+strEndCode+'\');',10);
   }
   function doSchSlctMore() {
      if (!processForm()) {return;}
      cstrSearchMode = '*MOR';
      var strEndCode = '0';
      var objList = document.getElementById('SEL_SelList');
      if (objList.rows.length != 0) {
         strEndCode = objList.rows[objList.rows.length-1].getAttribute('selcde');
      }
      doActivityStart(document.body);
      window.setTimeout('requestSchSlct(\''+strEndCode+'\');',10);
   }
   function requestSchSlct(strEndCode) {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*SELDTA" ENDCDE="'+strEndCode+'">';
      var intGroup = 0;
      var objValues;
      for (var i=0;i<cobjSearchData.length;i++) {
         if (cobjSearchData[i].tabcde == '*GROUP') {
            if (intGroup > 0) {
               strXML = strXML+'</GROUP>';
            }
            intGroup++;
            strXML = strXML+'<GROUP GRPCDE="*GROUP'+intGroup+'">';
         } else {
            if (cobjSearchData[i].rulcde != '' && cobjSearchData[i].valary.length != 0) {
               strXML = strXML+'<RULE TABCDE="'+cobjSearchData[i].tabcde+'" FLDCDE="'+cobjSearchData[i].fldcde+'" RULCDE="'+cobjSearchData[i].rulcde+'">';
               objValues = cobjSearchData[i].valary;
               for (var j=0;j<objValues.length;j++) {
                  strXML = strXML+'<VALUE VALCDE="'+objValues[j].valcde+'" VALTXT="'+objValues[j].valtxt+'"/>';
               }
               strXML = strXML+'</RULE>';
            }
         }
      }
      if (intGroup > 0) {
         strXML = strXML+'</GROUP>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doPostRequest('<%=strBase%>'+cstrSearchScript,function(strResponse) {checkSchSlct(strResponse);},false,streamXML(strXML));
   }
   function checkSchSlct(strResponse) {
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
         displayScreen('dspSchSlct');
         var objTable = document.getElementById('SEL_SelList');
         var objRow;
         var objCell;
         if (cstrSearchMode == '*SLT') {
            for (var i=objTable.rows.length-1;i>=0;i--) {
               objTable.deleteRow(i);
            }
         }
         var intColCount = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'LSTCTL') {
               intColCount = objElements[i].getAttribute('COLCNT');
            } else if (objElements[i].nodeName == 'LSTROW') {
               objRow = objTable.insertRow(-1);
               objRow.setAttribute('selcde',objElements[i].getAttribute('SELCDE'));
               objRow.setAttribute('seltxt',objElements[i].getAttribute('SELTXT'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '<a class="clsSelect" href="javascript:doSchSlctAccept(\''+objElements[i].getAttribute('SELCDE')+'\',\''+objElements[i].getAttribute('SELTXT')+'\');">Select</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               for (var j=1;j<=intColCount;j++) {
                  objCell = objRow.insertCell(j);
                  objCell.colSpan = 1;
                  objCell.innerText = objElements[i].getAttribute('COL'+j);
                  objCell.className = 'clsLabelFN';
                  objCell.style.whiteSpace = 'nowrap';
               }
            }
         }
         if (objTable.rows.length == 0) {
            objRow = objTable.insertRow(-1);
            objCell = objRow.insertCell(0);
            objCell.colSpan = intColCount+1;
            objCell.innerText = 'NO DATA FOUND';
            objCell.className = 'clsLabelFB';
            objCell.style.whiteSpace = 'nowrap';
         }
      }
   }
   function doSchSlctAccept(strCode,strText) {
      cstrSearchAccept(strCode,strText);
   }
   function doSchSlctCancel() {
      cstrSearchCancel();
   }

   ///////////////////////////
   // Search Save Functions //
   ///////////////////////////
   function getSchSaveData() {
      var strXML = '';
      var intGroup = 0;
      var objValues;
      for (var i=0;i<cobjSearchData.length;i++) {
         if (cobjSearchData[i].tabcde == '*GROUP') {
            if (intGroup > 0) {
               strXML = strXML+'</GROUP>';
            }
            intGroup++;
            strXML = strXML+'<GROUP GRPCDE="*GROUP'+intGroup+'">';
         } else {
            if (cobjSearchData[i].rulcde != '' && cobjSearchData[i].valary.length != 0) {
               strXML = strXML+'<RULE TABCDE="'+cobjSearchData[i].tabcde+'" FLDCDE="'+cobjSearchData[i].fldcde+'" RULCDE="'+cobjSearchData[i].rulcde+'">';
               objValues = cobjSearchData[i].valary;
               for (var j=0;j<objValues.length;j++) {
                  strXML = strXML+'<VALUE VALCDE="'+objValues[j].valcde+'" VALTXT="'+objValues[j].valtxt+'"/>';
               }
               strXML = strXML+'</RULE>';
            }
         }
      }
      if (intGroup > 0) {
         strXML = strXML+'</GROUP>';
      }
      return strXML;
   }

// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_sam_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspPrompt" class="clsGrid02" style="display:block;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPromptEnter();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Sample Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
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
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center colspan=2 nowrap><nobr>Sample Maintenance</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Sample Code:&nbsp;</nobr></td>
         <td id="DEF_SamCode" class="clsLabelBB" align=left valign=center colspan=1 nowrap></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Sample Description:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_SamText" size="120" maxlength="120" value="" onFocus="setSelect(this);">
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
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Unit Of Measure Size:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_UomSize" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Prepared Location:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_PreLocn"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Prepared Date:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_PreDate" size="10" maxlength="10" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;External Recipe Reference:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_ExtRfnr" size="32" maxlength="32" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;PLOP Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_PlopCde" size="32" maxlength="32" value="" onFocus="setSelect(this);">
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
   <table id="dspSchRule" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSchRuleSelect();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSchRule" class="clsFunction" align=center colspan=2 nowrap><nobr>Search Rules</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=5 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchRuleAddGroup();">&nbsp;Add Group&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchRuleCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchRuleSelect();">&nbsp;Select&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="tabSchRule" class="clsTableBody" style="display:block;visibility:visible" cols=2 align=left cellpadding="2" cellspacing="1"></table>
               <font id="fntSchRule" class="clsLabelWB" style="display:none;visibility:visible;font-size:12pt" align=center>Select All Data</font>
            </div>
         </nobr></td>
      </tr>
   </table>
   <table id="dspSchFeld" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSchFeld" class="clsFunction" align=center colspan=2 nowrap><nobr>Search Field</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="tabSchFeld" class="clsTableBody" cols=1 align=left cellpadding="2" cellspacing="1"></table>
            </div>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchFeldCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspSchList" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSchListAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSchList" class="clsFunction" align=center colspan=2 nowrap><nobr>Search List Rule</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center valign=center colspan=2 nowrap><nobr><select class="clsInputBN" id="SEL_RulCode"></select></nobr></td>
      </tr>
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
      </table></nobr></td></tr>
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
   <table id="dspSchNumb" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSchNumbAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSchNumb" class="clsFunction" align=center colspan=2 nowrap><nobr>Search Number Rule</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center valign=center colspan=2 nowrap><nobr><select class="clsInputBN" id="SEN_RulCode"></select></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
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
   <table id="dspSchText" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doSchTextAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSchText" class="clsFunction" align=center colspan=2 nowrap><nobr>Search Text Rule</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=center valign=center colspan=2 nowrap><nobr><select class="clsInputBN" id="SET_RulCode"></select></nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
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
   <table id="dspSchSlct" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedSchSlct" class="clsFunction" align=center colspan=2 nowrap><nobr>Selection</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      </table></nobr></td></tr>
      <tr height=100%>
         <td align=center colspan=2 nowrap><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible">
               <table id="SEL_SelList" class="clsTableBody" cols=1 align=left cellpadding="2" cellspacing="1"></table>
            </div>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchSlctCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSchSlctMore();">&nbsp;More&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->