<script language="javascript">
<!--
   /////////////////////////////
   // Group interfaces script //
   /////////////////////////////
   var objInterfaces = new Array();<%for i = clng(objSelection.ListLower("INTERFACE")) to clng(objSelection.ListUpper("INTERFACE"))%>
   objInterfaces[<%=i%>] = new clsInterface('<%=objSelection.ListValue01("INTERFACE",i)%>','(<%=objSelection.ListValue01("INTERFACE",i)%>) <%=replace(objSelection.ListValue02("INTERFACE",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue03("INTERFACE",i)%>');<%next%>
   function clsInterface(strInterface,strDescription,strSelected) {
      this.interface = strInterface;
      this.description = strDescription;
      this.oldSelected = strSelected;
      this.newSelected = strSelected;
   }
   function selectGroupDetails() {
      var objSltInterface = document.getElementById('sltInterface');
      for (var i=0;i<objSltInterface.options.length;i++) {
         if (objSltInterface.options[i].selected == true) {
            for (var j=0;j<objInterfaces.length;j++) {
               if (objInterfaces[j].interface == objSltInterface.options[i].value) {
                  objInterfaces[j].newSelected = '1';
                  break;
               }
            }
         }
      }
      paintGroupDetails();
   }
   function removeGroupDetails() {
      var objSltDetail = document.getElementById('sltDetail');
      for (var i=0;i<objSltDetail.options.length;i++) {
         if (objSltDetail.options[i].selected == true) {
            for (var j=0;j<objInterfaces.length;j++) {
               if (objInterfaces[j].interface == objSltDetail.options[i].value) {
                  objInterfaces[j].newSelected = '0';
                  break;
               }
            }
         }
      }
      paintGroupDetails();
   }
   function checkGroupDetails() {
      var strReturn = '';
      var strSelect = '0';
      var objHidden = null;
      for (var i=0;i<objInterfaces.length;i++) {
         if (objInterfaces[i].newSelected == '1') {
            strSelect = '1';
         }
      }
      if (strSelect == '0') {
         strReturn = 'At least one interface must be selected';
      } else {
         var objSltDetail = document.getElementById('sltDetail');
         for (var i=0;i<objSltDetail.options.length;i++) {
            objHidden = document.createElement('input');
            objHidden.setAttribute('type','hidden');
            objHidden.setAttribute('name','DET_Interface'+(i+1));
            objHidden.setAttribute('value',objSltDetail.options[i].value);
            document.forms['main'].appendChild(objHidden);
         }
         document.getElementById('DET_Count').value = objSltDetail.options.length; 
      }
      return strReturn;
   }
   function changeGroupDetails() {
      var bolReturn = false;
      for (var i=0;i<objInterfaces.length;i++) {
         if (objInterfaces[i].oldSelected != objInterfaces[i].newSelected) {
            bolReturn = true;
            break;
         }
      }
      return bolReturn;
   }
   function paintGroupDetails() {
      var intInterfaceCount = -1;
      var objSltInterface = document.getElementById('sltInterface');
      objSltInterface.options.length = 0;
      objSltInterface.selectedIndex = -1;
      for (var i=0;i<objInterfaces.length;i++) {
         if (objInterfaces[i].newSelected == '0') {
            intInterfaceCount++;
            objSltInterface.options[intInterfaceCount] = new Option(objInterfaces[i].description,objInterfaces[i].interface);
         }
      }
      var intDetailCount = -1;
      var objSltDetail = document.getElementById('sltDetail');
      objSltDetail.options.length = 0;
      objSltDetail.selectedIndex = -1;
      for (var i=0;i<objInterfaces.length;i++) {
         if (objInterfaces[i].newSelected == '1') {
            intDetailCount++;
            objSltDetail.options[intDetailCount] = new Option(objInterfaces[i].description,objInterfaces[i].interface);
         }
      }
   }
// -->
</script>