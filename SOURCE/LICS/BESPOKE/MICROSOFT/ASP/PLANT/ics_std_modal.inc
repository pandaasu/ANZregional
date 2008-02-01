<script language="javascript">
<!--
   //////////////////////////
   // Generic modal script //
   //////////////////////////
   function openDialog(strURL) {
      var strRandom = Math.random().toString();
      var strName = 'child' + strRandom.substr(2,strRandom.length-2);
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=yes';
      strFeatures = strFeatures + ',width=' + (screen.availWidth/2);
      strFeatures = strFeatures + ',height=' + (screen.availHeight/2);
      strFeatures = strFeatures + ',top=' + (screen.availHeight-(screen.availHeight/2))/2;
      strFeatures = strFeatures + ',left=' + (screen.availWidth-(screen.availWidth/2))/2;
      window.open(strURL,strName,'"' + strFeatures + '"',true);
   }
// -->
</script>
 
