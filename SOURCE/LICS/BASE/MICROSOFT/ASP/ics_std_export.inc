<script language="javascript">
<!--
   ///////////////////
   // Export script //
   ///////////////////
   var cobjExport;
   var cobjExportParent;
   function doExportOutput(objParent,strName,strFormat,strQuery) {
      if (cobjExport != null) {
         return;
      }
      cobjExportParent = objParent;
      var strURL = '<%=strBase%>ics_export.asp?Mode=PROMPT&DTA_Name=' + strName + '&DTA_Format=' + strFormat + '&DTA_Query=' + strQuery;
      cobjExport = document.createElement('iframe');
      cobjExport.src = strURL;
      cobjExport.style.position = 'absolute';
      cobjExport.style.left = cobjExportParent.offsetLeft+((cobjExportParent.offsetWidth/2)-300);
      cobjExport.style.top = cobjExportParent.offsetTop+((cobjExportParent.offsetHeight/2)-100);
      cobjExport.style.height = 200;
      cobjExport.style.width = 600;
      cobjExport.style.visibility = 'hidden';
      cobjExportParent.appendChild(cobjExport);
   }
   function doExportShow() {
      if (cobjExport != null) {
         cobjExport.style.visibility = 'visible';
      }
   }
   function doExportClose() {
      if (cobjExport != null) {
         cobjExportParent.removeChild(cobjExport);
      }
      cobjExport = null;
      cobjExportParent = null;
   }
// -->
</script>