<html>
<script language="javascript">
<!--
   /////////////////////////
   // Generic file script //
   /////////////////////////
   function loadFile(strPath) {
      var strText;
      var objFileSystem = new ActiveXObject('Scripting.FileSystemObject');
      var objFile = objFileSystem.GetFile(strPath);
      var objTextStream = objFile.OpenAsTextStream(1,-2);
      var strLine;
      var intLine = 0;
      while (!objTextStream.AtEndOfStream) {
         intLine++;
         strLine = objTextStream.ReadLine();
         strText = strText + '<input type="hidden" name="FileLine' + intLine + '" value="' + strLine + '">';
      }
      objTextStream.Close();
      objTextStream = null;
      objFile = null;
      objFileSystem = null;
      document.all.hidLines.innerHTML = strText;
      document.all.LIN_Count.value = intLine;
   }
// -->
</script>