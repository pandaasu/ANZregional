<script language="javascript">
<!--
   ///////////////////////////////
   // Generic scrollable script //
   ///////////////////////////////
   function setScrollable(strHead,strBody,strDirection) {
      var objConHead = document.getElementById('con' + strHead);
      var objConBody = document.getElementById('con' + strBody);
      var objTabHead = document.getElementById('tab' + strHead);
      var objTabBody = document.getElementById('tab' + strBody);
      var objHeadRows = objTabHead.rows;
      var objHeadCells = objTabHead.rows(objHeadRows.length-1).cells;
      var objBodyCells = objTabBody.rows(0).cells;
      if (objBodyCells.length == objHeadCells.length-1) {
         for (i=0;i<objHeadCells.length-1;i++) {
            if (objHeadCells[i].offsetWidth > objBodyCells[i].offsetWidth) {
               objBodyCells[i].style.width = objHeadCells[i].offsetWidth;
               objHeadCells[i].style.width = objHeadCells[i].offsetWidth;
            } else {
               objHeadCells[i].style.width = objBodyCells[i].offsetWidth;
               objBodyCells[i].style.width = objBodyCells[i].offsetWidth;
            }
         }
      }
      objHeadCells[objHeadCells.length-1].style.width = objConBody.offsetWidth - objConBody.clientWidth - 7;
      addScrollSync(objConHead,objConBody,strDirection);
   }
   function addScrollSync(objFromElement,objToElement,strDirection) {
      removeScrollSync(objFromElement);
      objFromElement._syncScroll = getOnScrollFunction(objFromElement);
      objFromElement._syncDirection = strDirection;
      objFromElement._syncTo = objToElement;
      objToElement.attachEvent('onscroll',objFromElement._syncScroll);
   }
   function getOnScrollFunction(objElement) {
      return function() {
         if (objElement._syncDirection == 'horizontal' || objElement._syncDirection == 'both')
            objElement.scrollLeft = event.srcElement.scrollLeft;
         if (objElement._syncDirection == 'vertical' || objElement._syncDirection == 'both')
            objElement.scrollTop = event.srcElement.scrollTop;
      };
   }
   function removeScrollSync(objElement) {
      if (objElement._syncTo != null)
         objElement._syncTo.detachEvent('onscroll',objElement._syncScroll);
      objElement._syncTo = null;
      objElement._syncScroll = null;
      objElement._syncDirection = null;
   }
// -->
</script>