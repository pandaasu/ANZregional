<script language="javascript">
<!--
   ///////////////////////////
   // Generic stream script //
   ///////////////////////////
   function loadStreamXML(strPath,strHeader) {
      var objFileSystem = new ActiveXObject('Scripting.FileSystemObject');
      var objFile = objFileSystem.GetFile(strPath);
      var objTextStream = objFile.OpenAsTextStream(1,-2);
      var strLine = '';
      var bolSkip = false;
      if (strHeader == '*YES') {
         bolSkip = true;
      }
      var strText = '<TXTSTREAM>';
      while (!objTextStream.AtEndOfStream) {
         strLine = objTextStream.ReadLine();
         if (!bolSkip) {
            strText = strText + '<XR><![CDATA[' + strLine + ']]></XR>';
         }
         bolSkip = false;
      }
      strText = strText + '</TXTSTREAM>';
      objTextStream.Close();
      objTextStream = null;
      objFile = null;
      objFileSystem = null;
      return strText;
   }
// -->
</script>