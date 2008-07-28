<script language="javascript">
<!--
   ////////////////////
   // Cookie script //
   ////////////////////
   function setCookie(strName,strValue,intExpiry) {
      var strExpiry = ';';
      if (intExpiry) {
         var varDate = new Date();
         varDate.setTime(varDate.getTime()+(intExpiry*86400000));
         strExpiry = '; expires='+varDate.toGMTString()+';';
      }
      document.cookie = strName+'='+escape(strValue)+strExpiry;
   }
   function getCookie(strName) {
      strName = strName+'=';
      strValue = '';
      var aryCookie = document.cookie.split(';');
      for (var i=0;i<aryCookie.length;i++) {
         var strCookie = aryCookie[i];
         while (strCookie.charAt(0) == ' ') {
            strCookie = strCookie.substring(1,strCookie.length);
         }
         if (strCookie.indexOf(strName) == 0) {
            strValue = unescape(strCookie.substring(strName.length,strCookie.length));
            break;
         }
      }
      return strValue;
   }
   function killCookie(strName) {
      setCookie(strName,'NULL',-1);
   }
// -->
</script>