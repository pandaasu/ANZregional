<script language="javascript">
<!--
   //////////////////////////
   // Generic child script //
   //////////////////////////
   function openWindow(strParameters) {
      var strRandom = Math.random().toString();
      var strName = 'child' + strRandom.substr(2,strRandom.length-2);
      var strFeatures = 'toolbar=no,location=no,menubar=no,resizable=yes';
      strFeatures = strFeatures + ',width=' + (screen.availWidth - 40);
      strFeatures = strFeatures + ',height=' + (screen.availHeight - 60);
      strFeatures = strFeatures + ',top=16';
      strFeatures = strFeatures + ',left=16';
      window.open('<%=strBase%>ics_child.asp?' + strParameters,strName,'"' + strFeatures + '"',true);
   }
// -->
</script>
 
