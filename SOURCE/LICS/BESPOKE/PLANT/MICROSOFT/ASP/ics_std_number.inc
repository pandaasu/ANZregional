<script language="javascript">
<!--
   ///////////////////////////
   // Generic number script //
   ///////////////////////////
   function validateNumber(objInput,intDecimals,bolNegative) {
      var fltWork;
      var bolDecimal = false;
      var bolError = false;
      deleteInput(objInput.name);
      if (objInput.value == '') {
         objInput.style.background = '#ffffff';
         return;
      }
      for (i=0;i<objInput.value.length;i++) {
         if (objInput.value.substring(i,i+1) == '-') {
            if (i != 0) {bolError = true; break;}
         } else if (objInput.value.substring(i,i+1) == '.') {
            if (bolDecimal == true) {bolError = true; break;}
            bolDecimal = true;  
         } else if ((objInput.value.substring(i,i+1) < '0') || (objInput.value.substring(i,i+1) > '9')) {
            bolError = true; break;
         }
      }
      if (bolError == false) {
         fltWork = parseFloat(objInput.value);
         if (bolNegative == false && fltWork < 0) {fltWork = -fltWork;}
         objInput.style.background = '#ffffff';
         objInput.value = roundNumber(fltWork,intDecimals);
      } else {
         objInput.style.background = '#ffb6c1';
         addInput(objInput.name);
      }
      return;     
   }
   function roundNumber(fltNumber,intDecimals) {
      var strNumber;
      var intWork;
      var regTest = /\./;
      intDecimals = (!intDecimals?0:intDecimals);
      fltNumber = Math.round((fltNumber*Math.pow(10,intDecimals)))/Math.pow(10,intDecimals);
      strNumber = fltNumber.toString();
      if (intDecimals != 0) {
         intWork = strNumber.search(regTest);
         if (intWork == -1) {strNumber = strNumber + '.'; intWork = intDecimals;} else {intWork = intDecimals - ((strNumber.length - 1) - intWork);}
         for (d=1;d<=intWork;d++) {strNumber = strNumber + '0';}
      }
      return strNumber;
   }
// -->
</script>