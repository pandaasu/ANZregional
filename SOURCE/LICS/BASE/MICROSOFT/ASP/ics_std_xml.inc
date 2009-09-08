<script language="javascript">
<!--
   ////////////////
   // XML script //
   ////////////////
   function streamXML(strXML) {
      var aryStream;
      var strStream = '';
      var intPart = 0;
      aryStream = strXML.match(RegExp('.{1,2000}','g'));
      for (var i=0;i<aryStream.length;i++) {
         intPart++;
         if (intPart > 1) {strStream = strStream + '&';}
         strStream = strStream + 'StreamPart'+intPart+'=' + escape(aryStream[i]);
      }
      if (intPart > 0) {strStream = strStream + '&';}
      strStream = strStream + 'StreamCount=' + intPart;
      return strStream;
   }
   function loadXML(strXML) {
      var objDocument = null;
      try {
         objDocument = new ActiveXObject("Microsoft.XMLDOM");
         objDocument.async = 'false';
         objDocument.loadXML(strXML);
         return objDocument;
      } catch(objException) {
         try {
            var xmlParser = new DOMParser();
            objDocument = xmlParser.parseFromString(strXML,'text/xml');
            return objDocument;
         } catch(objException) {
            alert(objException.message);
         }
      }
      return objDocument;
   }
   function fixXML(strXML) {
      var strReturn = strXML;
      strReturn = strReturn.replace(/&/g,'&amp;');
      strReturn = strReturn.replace(/</g,'&lt;');
      strReturn = strReturn.replace(/>/g,'&gt;');
      strReturn = strReturn.replace(/"/g,'&#34;');
      strReturn = strReturn.replace(/'/g,'&#39;');
      strReturn = strReturn.replace(/\+/g,'&#43;');
      return strReturn;
   }
// -->
</script>