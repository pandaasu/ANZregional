<script language="javascript">
<!--
   //////////////////////////////
   // Generic timestamp script //
   //////////////////////////////
   function validateTimestamp(objInput) {
      var bolError = false;
      deleteInput(objInput.name);
      if (objInput.value == '') {
         objInput.style.background = '#ffffff';
         return;
      }
      if (objInput.maxLength != 14 &&
          objInput.maxLength != 12 &&
          objInput.maxLength != 10 &&
          objInput.maxLength != 8) {
         bolError = true;
      }
      if (objInput.value.length < 8) {
         bolError = true;
      }
      if (!bolError) {
         if (objInput.value.length != objInput.maxLength) {
            var intWork = objInput.maxLength-objInput.value.length;
            for (p=1;p<=intWork;p++) {objInput.value = objInput.value + '0';}
         }
         if (objInput.value.substring(0,4) < '2000' || objInput.value.substring(0,4) > '2050') {bolError = true;}
         if (objInput.value.substring(4,6) < '01' || objInput.value.substring(4,6) > '12') {bolError = true;}
         if (objInput.value.substring(6,8) < '01' || objInput.value.substring(6,8) > '31') {bolError = true;}
         if (objInput.maxLength == 10 || objInput.maxLength == 12 || objInput.maxLength == 14) {
            if (objInput.value.substring(8,10) < '00' || objInput.value.substring(8,10) > '23') {bolError = true;}
         }
         if (objInput.maxLength == 12 || objInput.maxLength == 14) {
            if (objInput.value.substring(10,12) < '00' || objInput.value.substring(10,12) > '59') {bolError = true;}
         }
         if (objInput.maxLength == 14) {
            if (objInput.value.substring(12,14) < '00' || objInput.value.substring(12,14) > '59') {bolError = true;}
         }
         if (bolError == false) {
            if (objInput.value.substring(4,6) == '01' && objInput.value.substring(6,8)  > '31') {bolError = true;}
            if (objInput.value.substring(4,6) == '02') {
               if (objInput.value.substring(0,4) % 4 != 0) {
                  if (objInput.value.substring(6,8)  > '28') {bolError = true;}
               } else {
                  if (objInput.value.substring(6,8)  > '29') {bolError = true;}
               }
            }
            if (objInput.value.substring(4,6) == '03' && objInput.value.substring(6,8)  > '31') {bolError = true;}
            if (objInput.value.substring(4,6) == '04' && objInput.value.substring(6,8)  > '30') {bolError = true;}
            if (objInput.value.substring(4,6) == '05' && objInput.value.substring(6,8)  > '31') {bolError = true;}
            if (objInput.value.substring(4,6) == '06' && objInput.value.substring(6,8)  > '30') {bolError = true;}
            if (objInput.value.substring(4,6) == '07' && objInput.value.substring(6,8)  > '31') {bolError = true;}
            if (objInput.value.substring(4,6) == '08' && objInput.value.substring(6,8)  > '31') {bolError = true;}
            if (objInput.value.substring(4,6) == '09' && objInput.value.substring(6,8)  > '30') {bolError = true;}
            if (objInput.value.substring(4,6) == '10' && objInput.value.substring(6,8)  > '31') {bolError = true;}
            if (objInput.value.substring(4,6) == '11' && objInput.value.substring(6,8)  > '30') {bolError = true;}
            if (objInput.value.substring(4,6) == '12' && objInput.value.substring(6,8)  > '31') {bolError = true;}
         }
      }
      if (bolError == false) {
         objInput.style.background = '#ffffff';
      } else {
         objInput.style.background = '#ffb6c1';
         addInput(objInput.name);
      }
      return;     
   }
// -->
</script>