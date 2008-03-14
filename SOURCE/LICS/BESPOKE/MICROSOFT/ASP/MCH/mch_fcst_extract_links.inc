<script language="javascript">
<!--
   //////////////////////////
   // Extract links script //
   //////////////////////////
   function loadExtractLinks() {
      var strExtractType = document.getElementById('INP_ExtractType').value;
      var strExtractVersion = document.getElementById('INP_ExtractVersion').value;
      if (strExtractType != '' && (strExtractVersion != '' && strExtractVersion != '0')) {
         doActivityStart(document.body);
         doGetRequest('<%=strBase%>mch_fcst_extract_load.asp?QRY_ExtractType='+strExtractType+'&QRY_ExtractVersion='+strExtractVersion,function(strResponse) {displayExtractLinks(strResponse);},true);
      }
   }
   function displayExtractLinks(strResponse) {
      var objSltLink = document.getElementById('sltExtractLink');
      var objSltDetail = document.getElementById('sltExtractDetail');
      objSltLink.options.length = 0;
      objSltLink.selectedIndex = -1;
      objSltDetail.options.length = 0;
      objSltDetail.selectedIndex = -1;
      if (strResponse.substring(0,3) != '*OK') {
         alert(strResponse);
      } else {
         var aryReturn = strResponse.substring(3,strResponse.length).split('\n');
         for (var i=0;i<aryReturn.length;i++) {
            var intIdx = aryReturn[i].indexOf('\t');
            if (intIdx != -1) {
               var strValue = aryReturn[i].substring(0,intIdx);
               var strText = aryReturn[i].substring(intIdx+1,aryReturn[i].length);
               if (strValue == '*LOADTYPE') {
                  objSltLink.options[objSltLink.options.length] = new Option(strText,strText+'@*LOADTYPE');
               } else {
                  objSltLink.options[objSltLink.options.length] = new Option('('+strValue.substring(strValue.indexOf('@')+1,strValue.length)+') '+strText,strValue);
               }
            }
         }
      }
      doActivityStop();
   }
   function selectExtractLinks() {
      var objSltLink;
      var objSltDetail;
      var objLink = new Array();
      var intIndex = 0;
      objSltLink = document.getElementById('sltExtractLink');
      objSltDetail = document.getElementById('sltExtractDetail');
      for (var i=0;i<objSltLink.options.length;i++) {
         if (objSltLink.options[i].selected == true && objSltLink[i].value.substring(objSltLink[i].value.indexOf('@')+1,objSltLink[i].value.length) != '*LOADTYPE') {
            objSltDetail.options[objSltDetail.options.length] = new Option(objSltLink[i].text,objSltLink[i].value);
         } else {
            objLink[intIndex] = objSltLink[i];
            intIndex++;
         }
      }
      objSltLink.options.length = 0;
      objSltLink.selectedIndex = -1;
      for (var i=0;i<objLink.length;i++) {
         objSltLink.options[i] = objLink[i];
      }
   }
   function removeExtractLinks() {
      var objSltLink;
      var objSltDetail;
      var objLink = new Array();
      var objDetail = new Array();
      var intIndex = 0;
      objSltLink = document.getElementById('sltExtractLink');
      objSltDetail = document.getElementById('sltExtractDetail');
      for (var i=0;i<objSltLink.options.length;i++) {
         objLink[i] = objSltLink[i];
      }
      for (var i=0;i<objSltDetail.options.length;i++) {
         if (objSltDetail.options[i].selected == true) {
            objLink[objLink.length] = new Option(objSltDetail[i].text,objSltDetail[i].value);
         } else {
            objDetail[intIndex] = objSltDetail[i];
            intIndex++;
         }
      }
      objLink.sort(sortExtractLinks);
      objSltLink.options.length = 0;
      objSltLink.selectedIndex = -1;
      for (var i=0;i<objLink.length;i++) {
         objSltLink.options[i] = objLink[i];
      }
      objSltDetail.options.length = 0;
      objSltDetail.selectedIndex = -1;
      for (var i=0;i<objDetail.length;i++) {
         objSltDetail.options[i] = objDetail[i];
      }
   }
   function sortExtractLinks(obj01, obj02) {
      if (obj01.value < obj02.value) {
         return -1;
      } else if (obj01.value > obj02.value) {
         return 1;
      }
      return 0;
   }
   function checkExtractLinks() {
      var strReturn = '';
      var objHidden = null;
      var objSltDetail = document.getElementById('sltExtractDetail');
      for (var i=0;i<objSltDetail.options.length;i++) {
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_ExtractLink'+(i+1));
         objHidden.setAttribute('value',  objSltDetail.options[i].value.substring(objSltDetail.options[i].value.indexOf('@')+1,objSltDetail.options[i].value.length));
         document.forms['main'].appendChild(objHidden);
      }
      document.getElementById('DET_ExtractLinkCount').value = objSltDetail.options.length;
      return strReturn;
   }
// -->
</script>