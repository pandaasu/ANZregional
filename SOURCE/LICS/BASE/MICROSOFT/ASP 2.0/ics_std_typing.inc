<script language="javascript">
<!--
   ///////////////////////////////
   // Generic type ahead script //
   ///////////////////////////////
   function typeAhead() {
      var objElement = window.event.srcElement;
      var chrCode = window.event.keyCode;
      var newChar = String.fromCharCode(charCode).toUpperCase();


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


var typeAheadInfo = {last:0, 
                     accumString:"", 
                     delay:1000,
                     timeout:null, 
                     reset:function() {this.last=0; this.accumString=""}
                    };
// function invoked by select element's onkeydown event handler
function typeAhead() {
   // limit processing to IE event model supporter; don't trap Ctrl+keys
   if (window.event && !window.event.ctrlKey) {
      // timer for current event
      var now = new Date();
      // process for an empty accumString or an event within [delay] ms of last
      if (typeAheadInfo.accumString == "" || now - typeAheadInfo.last < typeAheadInfo.delay) {
         // make shortcut event object reference
         var evt = window.event;
         // get reference to the select element
         var selectElem = evt.srcElement;
         // get typed character ASCII value
         var charCode = evt.keyCode;
         // get the actual character, converted to uppercase
         var newChar =  String.fromCharCode(charCode).toUpperCase();
         // append new character to accumString storage
         typeAheadInfo.accumString += newChar;
         // grab all select element option objects as an array
         var selectOptions = selectElem.options;
         // prepare local variables for use inside loop
         var txt, nearest;
         // look through all options for a match starting with accumString
         for (var i=0; i<selectOptions.length; i++) {
            // convert each item's text to uppercase to facilitate comparison
            // (use value property if you want match to be for hidden option value)
            strText = selectOptions[i].text.toUpperCase();
            // record nearest lowest index, if applicable

            if (typeAheadInfo.accumString > strText.substr(0, typeAheadInfo.accumString.length)) {
               intIndex = i;
            }


            intIndex = (typeAheadInfo.accumString > strText.substr(0, typeAheadInfo.accumString.length)) ? i : intIndex;
            // process if accumString is at start of option text
            if (strText.indexOf(typeAheadInfo.accumString) == 0) {
               // stop any previous timeout timer
               clearTimeout(typeAheadInfo.timeout);
               // store current event's time in object 
               typeAheadInfo.last = now;
               // reset typeAhead properties in [delay] ms unless cleared beforehand
               typeAheadInfo.timeout = setTimeout("typeAheadInfo.reset()", typeAheadInfo.delay);
               // visibly select the matching item
               selectElem.selectedIndex = i;
               // prevent default event actions and propagation
               evt.cancelBubble = true;
               evt.returnValue = false;
               // exit function
               return false;   
            }            
         }
         // if a next lowest match exists, select it
         if (nearest != null) {
            selectElem.selectedIndex = nearest;
         }
      } else {
         // not a desired event, so clear timeout
         clearTimeout(typeAheadInfo.timeout);
      }
      // reset global object
      typeAheadInfo.reset();
   }
   return true;
}
</SCRIPT>

<SELECT id=states1 onkeydown="typeAhead();" name=states1></SELECT>

<SELECT id=states2 onkeydown="typeAhead();" size=10 name=states2></SELECT> 

