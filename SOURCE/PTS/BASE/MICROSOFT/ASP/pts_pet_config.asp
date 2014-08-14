<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PTS (Product Testing System)                       //
'// Script  : pts_pet_config.asp                                 //
'// Author  : Steve Gregan                                       //
'// Date    : May 2009                                           //
'// Text    : This script implements the pet configuration       //
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
   dim strCode

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "pts_pet_config.asp"
   strHeading = "Pet Maintenance"

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
   '// Get the code from the querystring
   '//
   strCode = Request.QueryString("code")

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurityCheck("PTS_PET_CONFIG")
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
   document.onmouseover = function(evt) {
      var evt = evt || window.event;
      var objElement = evt.target || evt.srcElement;
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
   document.onmouseout = function(evt) {
      var evt = evt || window.event;
      var objElement = evt.target || evt.srcElement;
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
   function getQueryVariable(variable) {
        var query = window.location.search.substring(1);
        var vars = query.split("&");
        for (var i = 0; i < vars.length; i++) {
            var pair = vars[i].split("=");
            if (pair[0] == variable) {
                return unescape(pair[1]);
            }
        }
        return null;
    }
    function makeLink(text,code,page) {
        return "<a href='javascript:parent.setContent(\"\\" + page + "?code=" + code + "\");' onclick='parent.setContent(\"\\" + page + "?code=" + code + "\");return false;'>" + text + "</a>";
    }
    
   ////////////////////
   // Load Functions //
   ////////////////////
   function loadFunction() {
      cobjScreens[0] = new clsScreen('dspLoad','hedLoad');
      cobjScreens[1] = new clsScreen('dspPrompt','hedPrompt');
      cobjScreens[2] = new clsScreen('dspDefine','hedDefine');
      cobjScreens[0].hedtxt = '**LOADING**';
      cobjScreens[1].hedtxt = 'Pet Prompt';
      cobjScreens[2].hedtxt = 'Pet Maintenance';
      initSearch();
      initClass('Pet',function() {doDefineClaCancel();},function(intRowIndex,objValues) {doDefineClaAccept(intRowIndex,objValues);});
      displayScreen('dspLoad');
      requestPromptLoad();
      
      <%if strCode <> "" then%>
         document.getElementById('PRO_PetCode').value = "<%=strCode%>";
         doPromptUpdate();
      <%end if%>
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
   // Prompt Functions //
   //////////////////////
   function requestPromptLoad() {
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*PMTPET"/>';
      doPostRequest('<%=strBase%>pts_pet_config_prompt.asp',function(strResponse) {checkPromptLoad(strResponse);},false,streamXML(strXML));
   }
   function checkPromptLoad(strResponse) {
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
         displayScreen('dspPrompt');
         document.getElementById('PRO_PetCode').focus();
         document.getElementById('PRO_PetCode').value = '';
         var strPetType;
         var objPetType = document.getElementById('PRO_PetType');
         objPetType.selectedIndex = -1;
         objPetType.options.length = 0;
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'PET_TYPE') {
               objPetType.options[objPetType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            }
         }
      }
   }
   function doPromptEnter() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_PetCode').value == '') {
         if (document.getElementById('PRO_PetType').selectedIndex == -1 || document.getElementById('PRO_PetType').selectedIndex == 0) {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Pet type must be selected for create';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (document.getElementById('PRO_PetCode').value == '') {
         doPromptCreate();
      } else {
         doPromptUpdate();
      }
   }
   function doPromptUpdate() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_PetCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Pet code must be entered for update';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineUpdate(\''+document.getElementById('PRO_PetCode').value+'\');',10);
   }
   function doPromptCreate() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_PetType').selectedIndex == -1 || document.getElementById('PRO_PetType').selectedIndex == 0) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Pet type must be selected for create';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      var objPetType = document.getElementById('PRO_PetType');
      doActivityStart(document.body);
      window.setTimeout('requestDefineCreate(\'*NEW\',\''+objPetType.options[objPetType.selectedIndex].value+'\');',10);
   }
   function doPromptCopy() {
      if (!processForm()) {return;}
      var strMessage = '';
      if (document.getElementById('PRO_PetCode').value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Pet code must be entered for copy';
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      doActivityStart(document.body);
      window.setTimeout('requestDefineCopy(\''+document.getElementById('PRO_PetCode').value+'\');',10);
   }
   function doPromptSearch() {
      if (!processForm()) {return;}
      startSchInstance('*PET','Pet','pts_pet_search.asp',function() {doPromptPetCancel();},function(strCode,strText) {doPromptPetSelect(strCode,strText);});
   }
   function doPromptPetCancel() {
      displayScreen('dspPrompt');
      document.getElementById('PRO_PetCode').focus();
   }
   function doPromptPetSelect(strCode,strText) {
      document.getElementById('PRO_PetCode').value = strCode;
      displayScreen('dspPrompt');
      document.getElementById('PRO_PetCode').focus();
   }

   //////////////////////
   // Define Functions //
   //////////////////////
   var cstrDefineMode;
   var cstrDefineCode;
   var cstrHouCode;
   function requestDefineUpdate(strCode) {
      cstrDefineMode = '*UPD';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDPET" PETCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_pet_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCreate(strCode,strType) {
      cstrDefineMode = '*CRT';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CRTPET" PETCODE="'+fixXML(strCode)+'" PETTYPE="'+fixXML(strType)+'"/>';
      doPostRequest('<%=strBase%>pts_pet_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
   }
   function requestDefineCopy(strCode) {
      cstrDefineMode = '*CPY';
      cstrDefineCode = strCode;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*CPYPET" PETCODE="'+fixXML(strCode)+'"/>';
      doPostRequest('<%=strBase%>pts_pet_config_retrieve.asp',function(strResponse) {checkDefineLoad(strResponse);},false,streamXML(strXML));
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
            cobjScreens[2].hedtxt = 'Update Pet ('+cstrDefineCode+')';
         } else {
            cobjScreens[2].hedtxt = 'Create Pet (*NEW)';
         }
         displayScreen('dspDefine');
         document.getElementById('DEF_PetCode').value = '';
         document.getElementById('DEF_PetType').value = '';
         document.getElementById('DEF_CrtDate').innerHTML = '';
         document.getElementById('DEF_PetName').value = '';
         document.getElementById('DEF_HouCode').value = '';
         document.getElementById('DEF_HouText').innerHTML = '';
         document.getElementById('DEF_BthYear').value = '';
         document.getElementById('DEF_FedCmnt').value = '';
         document.getElementById('DEF_HthCmnt').value = '';
         document.getElementById('DEF_TypText').innerHTML = '';
         var strPetStat;
         var strDelNote;
         var objPetStat = document.getElementById('DEF_PetStat');
         var objDelNote = document.getElementById('DEF_DelNote');
         var objValStat = document.getElementById('DEF_ValStat');
         objPetStat.options.length = 0;
         objDelNote.options.length = 0;
         objValStat.options.length = 0;
         document.getElementById('DEF_PetName').focus();
         var objClaData = document.getElementById('DEF_ClaData');
         var objClaFont = document.getElementById('DEF_ClaFont');
         var objValData = document.getElementById('DEF_ValData');
         var objValFont = document.getElementById('DEF_ValFont');
         var objHisData = document.getElementById('DEF_HisData');
         var objHisFont = document.getElementById('DEF_HisFont');
         var objRow;
         var objCell;
         var strTabCode;
         var objSavAry;
         var objValAry;
         for (var i=objClaData.rows.length-1;i>=0;i--) {
            objClaData.deleteRow(i);
         }
         for (var i=objValData.rows.length-1;i>=0;i--) {
            objValData.deleteRow(i);
         }
         for (var i=objHisData.rows.length-1;i>0;i--) {
            objHisData.deleteRow(i);
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'STA_LIST') {
               objPetStat.options[objPetStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'PET_TYPE') {
               objPetType.options[objPetType.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'DEL_NOTE') {
               objDelNote.options[objDelNote.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'VAL_STATUS') {
               objValStat.options[objValStat.options.length] = new Option(objElements[i].getAttribute('VALTXT'),objElements[i].getAttribute('VALCDE'));
            } else if (objElements[i].nodeName == 'PET') {
                var houText = objElements[i].getAttribute('HOUTEXT')
                if (houText != "** DATA ENTRY **")
                    houText = "(" + makeLink(objElements[i].getAttribute('HOUCODE'),objElements[i].getAttribute('HOUCODE'),"pts_hou_config.asp") + ") " + houText;
               document.getElementById('DEF_PetCode').value = objElements[i].getAttribute('PETCODE');
               document.getElementById('DEF_PetType').value = objElements[i].getAttribute('PETTYPE');
               document.getElementById('DEF_TypText').innerHTML = objElements[i].getAttribute('TYPTEXT');
               document.getElementById('DEF_PetName').value = objElements[i].getAttribute('PETNAME');
               document.getElementById('DEF_HouCode').value = objElements[i].getAttribute('HOUCODE');
               document.getElementById('DEF_HouText').innerHTML = houText;
               document.getElementById('DEF_BthYear').value = objElements[i].getAttribute('BTHYEAR');
               document.getElementById('DEF_FedCmnt').value = objElements[i].getAttribute('FEDCMNT');
               document.getElementById('DEF_HthCmnt').value = objElements[i].getAttribute('HTHCMNT');
               document.getElementById('DEF_CrtDate').innerHTML = objElements[i].getAttribute('CRTDATE');
               strPetStat = objElements[i].getAttribute('PETSTAT');
               strDelNote = objElements[i].getAttribute('DELNOTE');
               cstrHouCode = objElements[i].getAttribute('HOUCODE');
            } else if (objElements[i].nodeName == 'TABLE') {
               objRow = objClaData.insertRow(-1);
               objRow.setAttribute('tabcde','*HEAD');
               objCell = objRow.insertCell(0);
               objCell.colSpan = 3;
               objCell.innerText = objElements[i].getAttribute('TABTXT');
               objCell.className = 'clsLabelFB';
               objCell.style.whiteSpace = 'nowrap';
               strTabCode = objElements[i].getAttribute('TABCDE');
            } else if (objElements[i].nodeName == 'FIELD') {
               objRow = objClaData.insertRow(-1);
               objRow.setAttribute('tabcde',strTabCode);
               objRow.setAttribute('fldcde',objElements[i].getAttribute('FLDCDE'));
               objRow.setAttribute('fldtxt',objElements[i].getAttribute('FLDTXT'));
               objRow.setAttribute('seltyp',objElements[i].getAttribute('SELTYP'));
               objRow.setAttribute('inplen',objElements[i].getAttribute('INPLEN'));
               objRow.setAttribute('savary',new Array());
               objRow.setAttribute('valary',new Array());
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = '<a class="clsSelect" onClick="doDefineClaSelect(\''+objRow.rowIndex+'\');">Select</a>';
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('FLDTXT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(2);
               objCell.colSpan = 1;
               objCell.innerText = '*NONE';
               objCell.className = 'clsLabelFN';
            } else if (objElements[i].nodeName == 'VALUE') {
               objSavAry = objRow.getAttribute('savary');
               objSavAry[objSavAry.length] = new clsClaValue(objElements[i].getAttribute('VALCDE'),objElements[i].getAttribute('VALTXT'));
               objValAry = objRow.getAttribute('valary');
               objValAry[objValAry.length] = new clsClaValue(objElements[i].getAttribute('VALCDE'),objElements[i].getAttribute('VALTXT'));
               if (objValAry.length == 1) {
                  objCell.innerText = '';
                  if (objRow.getAttribute('seltyp') == '*TEXT') {
                     objCell.innerText = objCell.innerText+'"'+objElements[i].getAttribute('VALTXT')+'"';
                  } else {
                     objCell.innerText = objCell.innerText+objElements[i].getAttribute('VALTXT');
                  }
               } else {
                  if (objRow.getAttribute('seltyp') == '*TEXT') {
                     objCell.innerText = objCell.innerText+', "'+objElements[i].getAttribute('VALTXT')+'"';
                  } else {
                     objCell.innerText = objCell.innerText+', '+objElements[i].getAttribute('VALTXT');
                  }
               }
            } else if (objElements[i].nodeName == 'VAL_TYPE') {
               var objNewSelect = objValStat.cloneNode(true);
               objNewSelect.id = "s_"+objElements[i].getAttribute('VALCDE');
               objNewSelect.selectedIndex = objElements[i].getAttribute('VALSEL');
               objRow = objValData.insertRow(-1);
               objRow.setAttribute('valcde',objElements[i].getAttribute('VALCDE'));
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = "<b>" + objElements[i].getAttribute('VALTXT') + "</b>";
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               objCell.appendChild(objNewSelect);
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(2);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('VALPROG');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            } else if (objElements[i].nodeName == 'VAL_HIS') {
               objRow = objHisData.insertRow(-1);
               objCell = objRow.insertCell(0);
               objCell.colSpan = 1;
               objCell.innerHTML = objElements[i].getAttribute('VALTYP');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(1);
               objCell.colSpan = 1;
               objCell.innerHTML = objElements[i].getAttribute('VALREA');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
               objCell = objRow.insertCell(2);
               objCell.colSpan = 1;
               objCell.innerText = objElements[i].getAttribute('VALDAT');
               objCell.className = 'clsLabelFN';
               objCell.style.whiteSpace = 'nowrap';
            }
         }
         objPetStat.selectedIndex = -1;
         for (var i=0;i<objPetStat.length;i++) {
            if (objPetStat.options[i].value == strPetStat) {
               objPetStat.options[i].selected = true;
               break;
            }
         }
         objDelNote.selectedIndex = -1;
         for (var i=0;i<objDelNote.length;i++) {
            if (objDelNote.options[i].value == strDelNote) {
               objDelNote.options[i].selected = true;
               break;
            }
         }
         objClaData.style.display = 'block';
         objClaFont.style.display = 'none';
         if (objClaData.rows.length == 0) {
            objClaData.style.display = 'none';
            objClaFont.style.display = 'block';
         }
         objValData.style.display = 'block';
         objValFont.style.display = 'none';
         if (objValData.rows.length == 0) {
            objValData.style.display = 'none';
            objValFont.style.display = 'block';
         }
         objHisData.style.display = 'block';
         objHisFont.style.display = 'none';
         if (objHisData.rows.length == 1) {
            objHisData.style.display = 'none';
            objHisFont.style.display = 'block';
         }
         
         // Height adjustments
         var targetHeight = document.getElementById("divCla").offsetHeight;
         var valHeight = document.getElementById("divVal").offsetHeight;
         var valHisHeadHeight = document.getElementById("divValHisHead").offsetHeight;
         document.getElementById("divValHisData").style.height = targetHeight - valHeight - valHisHeadHeight - 5;
      }
   }
   function doDefineAccept() {
      if (!processForm()) {return;}
      var objPetStat = document.getElementById('DEF_PetStat');
      var objDelNote = document.getElementById('DEF_DelNote');
      var objClaData = document.getElementById('DEF_ClaData');
      var objValData = document.getElementById('DEF_ValData');
      var objRow;
      var objValAry;
      var strXML = '<?xml version="1.0" encoding="UTF-8"?>';
      strXML = strXML+'<PTS_REQUEST ACTION="*DEFPET"';
      strXML = strXML+' PETCODE="'+fixXML(document.getElementById('DEF_PetCode').value)+'"';
      strXML = strXML+' PETTYPE="'+fixXML(document.getElementById('DEF_PetType').value)+'"';
      strXML = strXML+' PETNAME="'+fixXML(document.getElementById('DEF_PetName').value.toUpperCase())+'"';
      strXML = strXML+' PETSTAT="'+fixXML(objPetStat.options[objPetStat.selectedIndex].value)+'"';
      strXML = strXML+' HOUCODE="'+fixXML(document.getElementById('DEF_HouCode').value)+'"';
      strXML = strXML+' DELNOTE="'+fixXML(objDelNote.options[objDelNote.selectedIndex].value)+'"';
      strXML = strXML+' BTHYEAR="'+fixXML(document.getElementById('DEF_BthYear').value)+'"';
      strXML = strXML+' FEDCMNT="'+fixXML(document.getElementById('DEF_FedCmnt').value.toUpperCase())+'"';
      strXML = strXML+' HTHCMNT="'+fixXML(document.getElementById('DEF_HthCmnt').value.toUpperCase())+'"';
      strXML = strXML+'>';
      for (var i=0;i<objClaData.rows.length;i++) {
         objRow = objClaData.rows[i];
         if (objRow.getAttribute('tabcde') != '*HEAD') {
            objValAry = objRow.getAttribute('valary');
            if (objValAry.length != 0) {
               strXML = strXML+'<CLA_DATA TABCDE="'+objRow.getAttribute('tabcde')+'" FLDCDE="'+objRow.getAttribute('fldcde')+'">';
               for (var j=0;j<objValAry.length;j++) {
                  if (objRow.getAttribute('seltyp') == '*TEXT' || objRow.getAttribute('seltyp') == '*NUMBER') {
                     strXML = strXML+'<VAL_DATA VALCDE="'+objValAry[j].valcde+'" VALTXT="'+fixXML(objValAry[j].valtxt)+'"/>';
                  } else {
                     strXML = strXML+'<VAL_DATA VALCDE="'+objValAry[j].valcde+'" VALTXT=""/>';
                  }
               }
               strXML = strXML+'</CLA_DATA>';
            }
         }
      }
      for (var i=0;i<objValData.rows.length;i++) {
        objRow = objValData.rows[i];
        objSel = document.getElementById("s_" + objRow.getAttribute('valcde'));
        strXML = strXML+'<V_DATA VALCDE="'+objRow.getAttribute('valcde')+'" VALSEL="'+objSel.value+'"/>';
      }
      strXML = strXML+'</PTS_REQUEST>';
      doActivityStart(document.body);
      window.setTimeout('requestDefineAccept(\''+strXML+'\');',10);
   }
   function requestDefineAccept(strXML) {
      doPostRequest('<%=strBase%>pts_pet_config_update.asp',function(strResponse) {checkDefineAccept(strResponse);},false,streamXML(strXML));
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
         displayScreen('dspPrompt');
         document.getElementById('PRO_PetCode').value = '';
         document.getElementById('PRO_PetCode').focus();
      }
   }
   function doDefineCancel() {
      if (checkChange() == false) {return;}
      displayScreen('dspPrompt');
      document.getElementById('PRO_PetCode').value = '';
      document.getElementById('PRO_PetCode').focus();
   }
   function doDefineHousehold() {
      if (!processForm()) {return;}
      startSchInstance('*HOUSEHOLD','Household','pts_hou_search.asp',function() {doDefineHouseholdCancel();},function(strCode,strText) {doDefineHouseholdSelect(strCode,strText);});
   }
   function doBlurHousehold() {
      var objHouCode = document.getElementById('DEF_HouCode');
      if (cstrHouCode != objHouCode.value) {
          var strXML = '<?xml version="1.0" encoding="UTF-8"?><PTS_REQUEST ACTION="*UPDHOU" HOUCODE="'+fixXML(objHouCode.value)+'"/>';
          doPostRequest('<%=strBase%>pts_hou_config_retrieve.asp',function(strResponse) {doHouseholdText(strResponse);},false,streamXML(strXML));
          cstrHouCode = objHouCode.value;
      }
   }
   function doFocusHousehold(strCode) {
      cstrHouCode = strCode;
   }
   function doHouseholdText(strResponse) {
      var objHouText = document.getElementById('DEF_HouText');
      var objHouCode = document.getElementById('DEF_HouCode');
      if (strResponse.substring(0,3) == '*OK') {
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
            objHouCode.focus();
            alert(strMessage);
            return;
         }
         for (var i=0;i<objElements.length;i++) {
            if (objElements[i].nodeName == 'HOUSEHOLD') {
               cstrHouCode = objElements[i].getAttribute('HOUCODE');
               objHouText.innerHTML = "(" + makeLink(cstrHouCode,cstrHouCode,"pts_hou_config.asp") + ") " + objElements[i].getAttribute('CONFNAM') + ", " + objElements[i].getAttribute('LOCSTRT') + ", " + objElements[i].getAttribute('LOCTOWN');
               break;
            } 
         }
      }
      else {
         objHouText.innerText = '** DATA ENTRY **';
      }
   }
   function doDefineHouseholdCancel() {
      displayScreen('dspDefine');
      document.getElementById('DEF_PetName').focus();
   }
   function doDefineHouseholdSelect(strCode,strText) {
      document.getElementById('DEF_HouCode').value = strCode;
      document.getElementById('DEF_HouText').innerText = strText;
      cstrHouCode = strCode;
      displayScreen('dspDefine');
      document.getElementById('DEF_HouCode').focus();
   }
   function doDefineClaSelect(intRow) {
      var objTable = document.getElementById('DEF_ClaData');
      objRow = objTable.rows[intRow];
      var objPetType = document.getElementById('DEF_PetType');
      var strPetType = objPetType.value;
      doClaUpdate(intRow,objRow.getAttribute('tabcde'),objRow.getAttribute('fldcde'),objRow.getAttribute('fldtxt'),objRow.getAttribute('inplen'),objRow.getAttribute('seltyp'),strPetType,objRow.getAttribute('valary'));
   }
   function doDefineClaCancel() {
      displayScreen('dspDefine');
      document.getElementById('DEF_ClaData').focus();
   }
   function doDefineClaAccept(intRowIndex,objValues) {
      var objTable = document.getElementById('DEF_ClaData');
      objRow = objTable.rows[intRowIndex];
      objRow.cells[2].innerText = '*NONE';
      var strSelTyp = objRow.getAttribute('seltyp');
      var objSavAry = objRow.getAttribute('savary');
      var objValAry = objRow.getAttribute('valary');
      objValAry.length = 0;
      var bolChange = false;
      var bolFound = false;
      for (var i=0;i<objValues.length;i++) {
         objValAry[i] = new clsClaValue(objValues[i].valcde,objValues[i].valtxt);
         if (i == 0) {
            objRow.cells[2].innerText = '';
            if (objRow.getAttribute('seltyp') == '*TEXT') {
               objRow.cells[2].innerText = objRow.cells[2].innerText+'"'+objValues[i].valtxt+'"';
            } else {
               objRow.cells[2].innerText = objRow.cells[2].innerText+objValues[i].valtxt;
            }
         } else {
            if (objRow.getAttribute('seltyp') == '*TEXT') {
               objRow.cells[2].innerText = objRow.cells[2].innerText+', "'+objValues[i].valtxt+'"';
            } else {
               objRow.cells[2].innerText = objRow.cells[2].innerText+', '+objValues[i].valtxt;
            }
         }
         if (!bolChange) {
            bolFound = false;
            for (var j=0;j<objSavAry.length;j++) {
               if (strSelTyp == '*NUMBER' || strSelTyp == '*TEXT') {
                  if (objValues[i].valtxt == objSavAry[j].valtxt) {
                     bolFound = true;
                     break;
                  }
               } else {
                  if (objValues[i].valcde == objSavAry[j].valcde) {
                     bolFound = true;
                     break;
                  }
               }
            }
            if (!bolFound) {
               bolChange = true;
            }
         }
      }
      if (objValAry.length != objSavAry.length) {
         bolChange = true;
      }
      if (!bolChange) {
         objRow.cells[2].className = 'clsLabelFN';
      } else {
         objRow.cells[2].className = 'clsLabelFG';
      }
      displayScreen('dspDefine');
      document.getElementById('DEF_ClaData').focus();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<!--#include file="ics_std_number.inc"-->
<!--#include file="ics_std_request.inc"-->
<!--#include file="ics_std_activity.inc"-->
<!--#include file="ics_std_xml.inc"-->
<!--#include file="pts_search_code.inc"-->
<!--#include file="pts_class_code.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pts_pet_config_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();loadFunction();">
   <table id="dspLoad" class="clsGrid02" style="display:block;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0>
      <tr>
      <tr>
         <td id="hedLoad" class="clsFunction" align=center colspan=2 nowrap><nobr>**LOADING**</nobr></td>
      </tr>
   </table>
   <table id="dspPrompt" class="clsGrid02" style="display:none;visibility:visible" width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doPromptEnter();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedPrompt" class="clsFunction" align=center colspan=2 nowrap><nobr>Pet Prompt</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="PRO_PetCode" id="PRO_PetCode" size="10" maxlength="10" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Type:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="PRO_PetType"></select>
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
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCreate();">&nbsp;Create&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptUpdate();">&nbsp;Update&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptCopy();">&nbsp;Copy&nbsp;</a></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doPromptSearch();">&nbsp;Search&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <table id="dspDefine" class="clsGrid02" style="display:none;visibility:visible" height=100% width=100% align=center valign=top cols=2 cellpadding=1 cellspacing=0 onKeyPress="if (event.keyCode == 13) {doDefineAccept();}">
      <tr><td align=center colspan=2 nowrap><nobr><table class="clsPanel" align=center cols=2 cellpadding="0" cellspacing="0">
      <tr>
         <td id="hedDefine" class="clsFunction" align=center valign=center colspan=2 nowrap><nobr>Pet Maintenance</nobr></td>
         <input type="hidden" name="DEF_PetCode" id="DEF_PetCode" value="">
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Type:&nbsp;</nobr></td>
         <td id="DEF_TypText" class="clsLabelBB" align=left valign=center colspan=1 nowrap></td>
         <input type="hidden" name="DEF_PetType" id="DEF_PetType" value="">
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Name:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_PetName" id="DEF_PetName" size="80" maxlength="120" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Pet Status:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_PetStat"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Household Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <table class="clsPanel" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=left valign=center colspan=1 nowrap><nobr><input class="clsInputNN" type="text" name="DEF_HouCode" size="10" maxlength="10" value="" onFocus="setSelect(this);doFocusHousehold(this.value);" onBlur="validateNumber(this,0,false);doBlurHousehold();"></nobr></td>
                  <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                  <td align=left colspan=1 nowrap><nobr>
                     <table class="clsGrid02" align=left valign=top cols=3 cellpadding="0" cellspacing="0">
                        <tr>
                           <td class="clsLabelBB" align=left colspan=1 nowrap><nobr>
                              <table class="clsTable01" align=left cols=1 cellpadding="0" cellspacing="0">
                                 <tr><td align=center colspan=1 nowrap><nobr><a class="clsButton" onClick="doDefineHousehold();">&nbsp;Select&nbsp;</a></nobr></td></tr>
                              </table>
                           </nobr></td>
                           <td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>
                           <td class="clsLabelBB" id="DEF_HouText" align=left valign=center colspan=1 nowrap></td>
                        </tr>
                     </table>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Delete Notifier:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" id="DEF_DelNote"></select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Birth Year:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="DEF_BthYear" id="DEF_BthYear" size="4" maxlength="4" value="" onFocus="setSelect(this);" onBlur="validateNumber(this,0,false);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Feeding Comments:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_FedCmnt" id="DEF_FedCmnt" size="80" maxlength="1000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Health Comments:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DEF_HthCmnt" id="DEF_HthCmnt" size="80" maxlength="1000" value="" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Create Date:&nbsp;</nobr></td>
         <td id="DEF_CrtDate" class="clsLabelBB" align=left valign=center colspan=1 nowrap></td>
      </tr>
      </table></nobr></td></tr>
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Pet Classification Data&nbsp;</nobr></td>
         <td class="clsLabelBB" align=center valign=center colspan=1 nowrap><nobr>&nbsp;Pet Validation Data&nbsp;</nobr></td>
      </tr>
      <tr height=100%>
         <td align=center colspan=1 nowrap style="width:50%;"><nobr>
            <div class="clsScroll01" style="display:block;visibility:visible" id="divCla">
               <table id="DEF_ClaData" class="clsTableBody" style="display:block;visibility:visible" cols=1 align=left cellpadding="2" cellspacing="1"></table>
               <font id="DEF_ClaFont" class="clsLabelWB" style="display:none;visibility:visible;font-size:12pt" align=center>NO CLASSIFICATIONS</font>
            </div>
         </nobr></td>
         <td align=center valign="top" colspan=1 nowrap style="width:50%;">
            <div id="divVal">
                <nobr>
                    <table id="DEF_ValData" class="clsTableBody" style="display:block;visibility:visible;width:100%;border:solid 1px #40414c;border-bottom:none;" cols="1" align="left" cellpadding="1" cellspacing="0"></table>
            	    <font id="DEF_ValFont" class="clsLabelWB" style="display:none;visibility:visible;font-size:12pt" align=center>NO VALIDATION</font>
                </nobr>
            </div>
            <div id="divValHisHead" class="clsLabelBB" style="clear:both;margin-top:5px;text-align:center;white-space:nowrap;"><nobr>&nbsp;Pet Validation History&nbsp;</nobr></div>
           	<div id="divValHisData" class="clsScroll01" style="clear:both;display:block;visibility:visible;border:solid 1px #40414c;overflow:scroll;">
                <table id="DEF_HisData" class="clsTableBody" style="display:block;visibility:visible;width:100%;text-align:left;" cellpadding="2" cellspacing="1">
                    <tr>
                        <td class="clsLabelFN"><b>Validation Type</b></td>
                        <td class="clsLabelFN"><b>Reason</b></td>
                        <td class="clsLabelFN"><b>Allocation Date</b></td>
                    </tr>
                </table>
                <font id="DEF_HisFont" class="clsLabelWB" style="display:none;visibility:visible;font-size:12pt;text-align:center;">NO HISTORY</font>
            </div>
         </td>
      </tr>
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
<!--#include file="pts_search_html.inc"-->
<!--#include file="pts_class_html.inc"-->
<div style="display:none;visibility:hidden;">
    <select class="clsInputBN" id="DEF_ValStat"></select>
</div>
</body>
</html>
<%end sub%>
<!--#include file="ics_std_code.inc"-->