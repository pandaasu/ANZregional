<script language="javascript">
<!--
   ///////////////////
   // Report script //
   ///////////////////
   var cobjReport;
   var cobjReportParent;
   function doReportOutput(objParent,strName,strQuery) {
      if (cobjReport != null) {
         return;
      }
      cobjReportParent = objParent;
      var strURL = '<%=strBase%>ics_report.asp?Mode=PROMPT&DTA_Name=' + strName + '&DTA_Query=' + strQuer;
      cobjReport = document.createElement('iframe');
      cobjReport.src = strURL;
      cobjReport.style.position = 'absolute';
      cobjReport.style.left = cobjReportParent.offsetLeft+((cobjReportParent.offsetWidth/2)-300);
      cobjReport.style.top = cobjReportParent.offsetTop+((cobjReportParent.offsetHeight/2)-100);
      cobjReport.style.height = 200;
      cobjReport.style.width = 600;
      cobjReport.style.visibility = 'hidden';
      cobjReportParent.appendChild(cobjReport);
   }
   function doReportShow() {
      if (cobjReport != null) {
         cobjReport.style.visibility = 'visible';
      }
   }
   function doReportClose() {
      if (cobjReport != null) {
         cobjReportParent.removeChild(cobjReport);
      }
      cobjReport = null;
      cobjReportParent = null;
   }
// -->
</script>