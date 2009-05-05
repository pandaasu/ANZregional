<script language="javascript">
<!--
   ////////////////////
   // Request script //
   ////////////////////
   function doGetRequest(strUrl,strCallback,bolAsynchronous) {
      var objSelf = this;
      if (window.XMLHttpRequest) {
         objSelf.objRequest = new XMLHttpRequest();
      } else if (window.ActiveXObject) {
         objSelf.objRequest = new ActiveXObject("Microsoft.XMLHTTP");
      }
      objSelf.funCallback = strCallback;
      objSelf.objRequest.onreadystatechange = function() {doRequestCallback(objSelf)}
      objSelf.objRequest.open("GET",strUrl,bolAsynchronous);
      objSelf.objRequest.send(null);
   }
   function doPostRequest(strUrl,strCallback,bolAsynchronous,strData) {
      var objSelf = this;
      if (window.XMLHttpRequest) {
         objSelf.objRequest = new XMLHttpRequest();
      } else if (window.ActiveXObject) {
         objSelf.objRequest = new ActiveXObject("Microsoft.XMLHTTP");
      }
      objSelf.funCallback = strCallback;
      objSelf.objRequest.onreadystatechange = function() {doRequestCallback(objSelf)}
      objSelf.objRequest.open("POST",strUrl,bolAsynchronous);
      objSelf.objRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=utf-8");
      objSelf.objRequest.setRequestHeader("Content-Length",strData.length);
      objSelf.objRequest.setRequestHeader("Connection","close");
      objSelf.objRequest.send(strData);
   }
   function doRequestCallback(objSelf) {
      if (objSelf.objRequest.readyState == 4) {
         if (objSelf.objRequest.status == 200) {
            if (objSelf.funCallback == null) {
               alert('Request response - '+objSelf.objRequest.responseText);
            } else {
               objSelf.funCallback(objSelf.objRequest.responseText);
            }
         } else {
            alert('Request failed - status - '+objSelf.objRequest.status);
         }
      }
   }
// -->
</script>