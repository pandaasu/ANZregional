<script language="javascript">
<!--
   ////////////////////////
   // Spreadsheet script //
   ////////////////////////
   var cobjSpreadsheet;
   var cobjSpreadsheetParent;
   function doSpreadsheetDownload(objParent,strName,strProcedure) {
      if (cobjSpreadsheet != null) {
         return;
      }
      cobjSpreadsheetParent = objParent;
      var strURL = '<%=strBase%>ics_spreadsheet.asp?Mode=GET';
      strURL = strURL + '&DTA_Name=' + strName;
      strURL = strURL + '&DTA_Procedure=' + strProcedure;
      cobjSpreadsheet = document.createElement('iframe');
      cobjSpreadsheet.src = strURL;
      cobjSpreadsheet.style.position = 'absolute';
      cobjSpreadsheet.style.left = cobjSpreadsheetParent.offsetLeft+((cobjSpreadsheetParent.offsetWidth/2)-300);
      cobjSpreadsheet.style.top = cobjSpreadsheetParent.offsetTop+((cobjSpreadsheetParent.offsetHeight/2)-100);
      cobjSpreadsheet.style.height = 200;
      cobjSpreadsheet.style.width = 600;
      cobjSpreadsheet.style.visibility = 'hidden';
      cobjSpreadsheetParent.appendChild(cobjSpreadsheet);
   }
   function doSpreadsheetUpload(objParent,strFile,strProcedure) {
      if (cobjSpreadsheet != null) {
         return;
      }
      cobjSpreadsheetParent = objParent;
      var regTest = /\\/g;
      var strURL = '<%=strBase%>ics_spreadsheet.asp?Mode=SET';
      strURL = strURL + '&DTA_File=' + strFile.replace(regTest,'\\\\');
      strURL = strURL + '&DTA_Procedure=' + strProcedure;
      cobjSpreadsheet = document.createElement('iframe');
      cobjSpreadsheet.src = strURL;
      cobjSpreadsheet.style.position = 'absolute';
      cobjSpreadsheet.style.left = cobjSpreadsheetParent.offsetLeft+((cobjSpreadsheetParent.offsetWidth/2)-300);
      cobjSpreadsheet.style.top = cobjSpreadsheetParent.offsetTop+((cobjSpreadsheetParent.offsetHeight/2)-100);
      cobjSpreadsheet.style.height = 200;
      cobjSpreadsheet.style.width = 600;
      cobjSpreadsheet.style.visibility = 'hidden';
      cobjSpreadsheetParent.appendChild(cobjSpreadsheet);
   }
   function doSpreadsheetShow() {
      doActivityStop();
      if (cobjSpreadsheet != null) {
         cobjSpreadsheet.style.visibility = 'visible';
      }
   }
   function doSpreadsheetClose(bolRefresh) {
      if (cobjSpreadsheet != null) {
         if (bolRefresh) {
            doRefresh();
            return;
         }
      }
      doActivityStop();
      if (cobjSpreadsheet != null) {
         cobjSpreadsheetParent.removeChild(cobjSpreadsheet);
      }
      cobjSpreadsheet = null;
      cobjSpreadsheetParent = null;
   }
// -->
</script>