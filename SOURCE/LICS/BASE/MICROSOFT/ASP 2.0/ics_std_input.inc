<script language="javascript">
<!--
   //////////////////////////
   // Generic input script //
   //////////////////////////
   var objInputs = new Array();
   function checkInput() {
      if (objInputs.length == 0) {
         return false;
      }
      return true;
   }
   function addInput(strName) {
      objInputs[objInputs.length] = strName;
   }
   function deleteInput(strName) {
      if (objInputs.length == 0) {
         return;
      }
      var objStupni = new Array();
      var j = 0;
      for (i=0;i<objInputs.length;i++) {
         if (objInputs[i] != strName) {
            objStupni[j] = objInputs[i];
            j++;
         }
      }
      objInputs.length = objInputs.length - 1;
      for (i=0;i<objStupni.length;i++) {
         objInputs[i] = objStupni[i];
      }
   }
// -->
</script>