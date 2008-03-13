<html>
<script language="javascript">
<!--
   ///////////////////////////
   // Generic stream script //
   ///////////////////////////
   function loadStreamXML(strPath) {
      var objFileSystem = new ActiveXObject('Scripting.FileSystemObject');
      var objFile = objFileSystem.GetFile(strPath);
      var objTextStream = objFile.OpenAsTextStream(1,-2);
      var strText = '<TXTSTREAM>';
      while (!objTextStream.AtEndOfStream) {
         strText = strText + '<XR><![CDATA[' + objTextStream.ReadLine() + ']]></XR>';
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