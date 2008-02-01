<script language="javascript">
<!--
   ///////////////////////
   // Menu links script //
   ///////////////////////
   var objMenuDetails = new Array();
   var objOptionDetails = new Array();
   function loadMenuLinks() {
      var objSltMenuLink = document.getElementById('sltMenuLink');<%for i = objSelection.ListLower("MENULINK") to objSelection.ListUpper("MENULINK")%>
      objSltMenuLink.options[<%=i%>] = new Option('(<%=objSelection.ListValue01("MENULINK",i)%>) <%=replace(objSelection.ListValue02("MENULINK",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue01("MENULINK",i)%>');<%next%><%if objForm.Fields("Mode").Value = "UPDATE_LOAD" and objSelection.ListCount("MENUDETAIL") > 0 then%>
      var objSltMenuDetail = document.getElementById('sltMenuDetail');<%for i = objSelection.ListLower("MENUDETAIL") to objSelection.ListUpper("MENUDETAIL")%>
      objSltMenuDetail.options[<%=i%>] = new Option('(<%=objSelection.ListValue01("MENUDETAIL",i)%>) <%=replace(objSelection.ListValue02("MENUDETAIL",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue01("MENUDETAIL",i)%>');<%next%>
      for (var i=0;i<objSltMenuDetail.options.length;i++) {
         objMenuDetails[i] = objSltMenuDetail[i].value;
      }<%end if%>
      var objSltOptionLink = document.getElementById('sltOptionLink');<%for i = objSelection.ListLower("OPTIONLINK") to objSelection.ListUpper("OPTIONLINK")%>
      objSltOptionLink.options[<%=i%>] = new Option('(<%=objSelection.ListValue01("OPTIONLINK",i)%>) <%=replace(objSelection.ListValue02("OPTIONLINK",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue01("OPTIONLINK",i)%>');<%next%><%if objForm.Fields("Mode").Value = "UPDATE_LOAD" and objSelection.ListCount("OPTIONDETAIL") > 0 then%>
      var objSltOptionDetail = document.getElementById('sltOptionDetail');<%for i = objSelection.ListLower("OPTIONDETAIL") to objSelection.ListUpper("OPTIONDETAIL")%>
      objSltOptionDetail.options[<%=i%>] = new Option('(<%=objSelection.ListValue01("OPTIONDETAIL",i)%>) <%=replace(objSelection.ListValue02("OPTIONDETAIL",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue01("OPTIONDETAIL",i)%>');<%next%>
      for (var i=0;i<objSltOptionDetail.options.length;i++) {
         objOptionDetails[i] = objSltOptionDetail[i].value;
      }<%end if%>
   }
   function selectMenuLinks(strType) {
      var objSltLink;
      var objSltDetail;
      var objLink = new Array();
      var intIndex = 0;
      if (strType == '*MNU') {
         objSltLink = document.getElementById('sltMenuLink');
         objSltDetail = document.getElementById('sltMenuDetail');
      } else {
         objSltLink = document.getElementById('sltOptionLink');
         objSltDetail = document.getElementById('sltOptionDetail');
      }
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
   function removeMenuLinks(strType) {
      var objSltLink;
      var objSltDetail;
      var objLink = new Array();
      var objDetail = new Array();
      var intIndex = 0;
      if (strType == '*MNU') {
         objSltLink = document.getElementById('sltMenuLink');
         objSltDetail = document.getElementById('sltMenuDetail');
      } else {
         objSltLink = document.getElementById('sltOptionLink');
         objSltDetail = document.getElementById('sltOptionDetail');
      }
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
      objLink.sort(sortMenuLinks);
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
   function upMenuLinks(strType) {
      var intSelect = 0;
      var intIndex = -1;
      var objSltDetail;
      if (strType == '*MNU') {
         objSltDetail = document.getElementById('sltMenuDetail');
      } else {
         objSltDetail = document.getElementById('sltOptionDetail');
      }
      for (var i=0;i<objSltDetail.options.length;i++) {
         if (objSltDetail.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one detail can be selected to move up');
         return;
      }
      if (intSelect == 1 && intIndex > 0) {
         var strAValue = objSltDetail.options[intIndex-1].value;
         var strAText = objSltDetail.options[intIndex-1].text;
         var strBValue = objSltDetail.options[intIndex].value;
         var strBText = objSltDetail.options[intIndex].text;
         objSltDetail.options[intIndex-1].value = strBValue;
         objSltDetail.options[intIndex-1].text = strBText;
         objSltDetail.options[intIndex-1].selected = true;
         objSltDetail.options[intIndex].value = strAValue;
         objSltDetail.options[intIndex].text = strAText;
         objSltDetail.options[intIndex].selected = false;
      }
   }
   function downMenuLinks(strType) {
      var intSelect = 0;
      var intIndex = -1;
      var objSltDetail;
      if (strType == '*MNU') {
         objSltDetail = document.getElementById('sltMenuDetail');
      } else {
         objSltDetail = document.getElementById('sltOptionDetail');
      }
      for (var i=0;i<objSltDetail.options.length;i++) {
         if (objSltDetail.options[i].selected == true) {
            intSelect++;
            intIndex = i;
         }
      }
      if (intSelect > 1) {
         alert('Only one detail can be selected to move down');
         return;
      }
      if (intSelect == 1 && intIndex < objSltDetail.options.length-1) {
         var strAValue = objSltDetail.options[intIndex+1].value;
         var strAText = objSltDetail.options[intIndex+1].text;
         var strBValue = objSltDetail.options[intIndex].value;
         var strBText = objSltDetail.options[intIndex].text;
         objSltDetail.options[intIndex+1].value = strBValue;
         objSltDetail.options[intIndex+1].text = strBText;
         objSltDetail.options[intIndex+1].selected = true;
         objSltDetail.options[intIndex].value = strAValue;
         objSltDetail.options[intIndex].text = strAText;
         objSltDetail.options[intIndex].selected = false;
      }
   }
   function sortMenuLinks(obj01, obj02) {
      if (obj01.value < obj02.value) {
         return -1;
      } else if (obj01.value > obj02.value) {
         return 1;
      }
      return 0;
   }
   function checkMenuLinks() {
      var strReturn = '';
      var objHidden = null;
      var objSltMenuDetail = document.getElementById('sltMenuDetail');
      var objSltOptionDetail = document.getElementById('sltOptionDetail');
      if (objSltMenuDetail.options.length == 0 && objSltOptionDetail.options.length == 0) {
         strReturn = 'At least one link must be selected';
      } else {
         for (var i=0;i<objSltMenuDetail.options.length;i++) {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_LinkMenu'+(i+1));
            objHidden.setAttribute('value',objSltMenuDetail.options[i].value);
            document.forms['main'].appendChild(objHidden);
         }
         document.getElementById('DET_LinkMenuCount').value = objSltMenuDetail.options.length;
         for (var i=0;i<objSltOptionDetail.options.length;i++) {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_LinkOption'+(i+1));
            objHidden.setAttribute('value',objSltOptionDetail.options[i].value);
            document.forms['main'].appendChild(objHidden);
         }
         document.getElementById('DET_LinkOptionCount').value = objSltOptionDetail.options.length; 
      }
      return strReturn;
   }
   function changeMenuLinks() {
      var bolReturn = false;
      var objSltMenuDetail = document.getElementById('sltMenuDetail');
      var objSltOptionDetail = document.getElementById('sltOptionDetail');
      if (objMenuDetails.length != objSltMenuDetail.options.length) {
         bolReturn = true;
      } else {
         for (var i=0;i<objMenuDetails.length;i++) {
            if (objMenuDetails[i] != objSltMenuDetail.options[i].value) {
               bolReturn = true;
               break;
            }
         }
      }
      if (objOptionDetails.length != objSltOptionDetail.options.length) {
         bolReturn = true;
      } else {
         for (var i=0;i<objOptionDetails.length;i++) {
            if (objOptionDetails[i] != objSltOptionDetail.options[i].value) {
               bolReturn = true;
               break;
            }
         }
      }
      return bolReturn;
   }
// -->
</script>