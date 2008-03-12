<script language="javascript">
<!--
   //////////////////////////
   // Extract links script //
   //////////////////////////
   var objExtractTypes = new Array();<%for i = objSelection.ListLower("EXTRACT_LOAD") to objSelection.ListUpper("EXTRACT_LOAD")%>
   objExtractTypes[<%=i%>] = new clsExtractType('<%=objSelection.ListValue01("EXTRACT_LOAD",i)%>','<%=objSelection.ListValue02("EXTRACT_LOAD",i)%>');<%next%>
   function clsExtractType(strExtractType,strLoadType) {
      this.extractType = strExtractType;
      this.loadType = strLoadType;
      this.selectCount = 0;
   }
   var objLinks = new Array();<%for i = objSelection.ListLower("LOAD") to objSelection.ListUpper("LOAD")%>
   objLinks[<%=i%>] = new clsLink('<%=objSelection.ListValue01("LOAD",i)%>','<%=replace(objSelection.ListValue02("LOAD",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue03("LOAD",i)%>','<%=objSelection.ListValue04("LOAD",i)%>');<%next%>
   function clsLink(strIdentifier,strDescription,strLoadType,strLoadVersion) {
      this.identifier = strIdentifier;
      this.description = strDescription;
      this.loadType = strLoadType;
      this.loadVersion = strLoadVersion;
   }
   function loadExtractLinks() {
      var objSltLink = document.getElementById('sltExtractLink');
      var objSltDetail = document.getElementById('sltExtractDetail');
      var strExtractType = document.getElementById('INP_ExtractType').value;
      var strExtractVersion = document.getElementById('INP_ExtractVersion').value;
      objSltLink.options.length = 0;
      objSltLink.selectedIndex = -1;
      objSltDetail.options.length = 0;
      objSltDetail.selectedIndex = -1;
      for (var i=0;i<objLinks.length;i++) {
         for (var j=0;j<objExtractTypes.length;j++) {
            if (strExtractType != '' && strExtractVersion != '') {
               if (objExtractTypes[j].extractType == strExtractType && objLinks[i].loadVersion == strExtractVersion && objExtractTypes[j].loadType == objLinks[i].loadType) {
                  objSltLink.options[objSltLink.options.length] = new Option(objLinks[i].loadType+' / '+objLinks[i].loadVersion+' / ('+objLinks[i].identifier+') '+objLinks[i].description,objLinks[i].identifier);
               }
            } else if (strExtractType != '') {
               if (objExtractTypes[j].extractType == strExtractType && objExtractTypes[j].loadType == objLinks[i].loadType) {
                  objSltLink.options[objSltLink.options.length] = new Option(objLinks[i].loadType+' / '+objLinks[i].loadVersion+' / ('+objLinks[i].identifier+') '+objLinks[i].description,objLinks[i].identifier);
               }
            } else if (strExtractVersion != '') {
               if (objLinks[i].loadVersion == strExtractVersion && objExtractTypes[j].loadType == objLinks[i].loadType) {
                  objSltLink.options[objSltLink.options.length] = new Option(objLinks[i].loadType+' / '+objLinks[i].loadVersion+' / ('+objLinks[i].identifier+') '+objLinks[i].description,objLinks[i].identifier);
               }
            }
         }
      }
   }
   function selectExtractLinks() {
      var objSltLink;
      var objSltDetail;
      var objLink = new Array();
      var intIndex = 0;
      objSltLink = document.getElementById('sltExtractLink');
      objSltDetail = document.getElementById('sltExtractDetail');
      for (var i=0;i<objSltLink.options.length;i++) {
         if (objSltLink.options[i].selected == true) {
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
      var strExtractType = document.getElementById('INP_ExtractType').value;
      for (var i=0;i<objExtractTypes.length;i++) {
         objExtractTypes[i].selectCount = 0;
         if (objExtractTypes[i].extractType == strExtractType) {
            for (var j=0;j<objLinks.length;j++) {
               if (objExtractTypes[i].loadType == objLinks[j].loadType) {
                  for (var k=0;k<objSltDetail.options.length;k++) {
                     if (objLinks[j].identifier == objSltDetail.options[k].value) {
                        objExtractTypes[i].selectCount++;
                     }
                  }
               }
            }
         }
      }
      for (var i=0;i<objExtractTypes.length;i++) {
         if (objExtractTypes[i].extractType == strExtractType) {
            if (objExtractTypes[i].selectCount == 0 ) {
               strReturn = 'Forecast extract load type (' + objExtractTypes[i].loadType + ') has no forecast load selected';
            }
            if (objExtractTypes[i].selectCount > 1) {
               strReturn = 'Forecast extract load type (' + objExtractTypes[i].loadType + ') has more than one forecast load selected';
            }
         }
      }
      if (strReturn == '') {
         for (var i=0;i<objSltDetail.options.length;i++) {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_ExtractLink'+(i+1));
            objHidden.setAttribute('value',objSltDetail.options[i].value);
            document.forms['main'].appendChild(objHidden);
         }
         document.getElementById('DET_ExtractLinkCount').value = objSltDetail.options.length;
      }
      return strReturn;
   }
// -->
</script>