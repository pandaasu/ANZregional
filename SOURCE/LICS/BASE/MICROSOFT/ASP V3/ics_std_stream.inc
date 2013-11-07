<script language="javascript">
<!--
   ///////////////////////////
   // Generic stream script //
   ///////////////////////////
   function loadStream(strPath) {
      var objFileSystem = new ActiveXObject('Scripting.FileSystemObject');
      var objFile = objFileSystem.GetFile(strPath);
      var objTextStream = objFile.OpenAsTextStream(1,-2);
      var objHidden;
      var strText;
      var intPart = 0;
      while (!objTextStream.AtEndOfStream) {
         intPart++;
         strText = objTextStream.Read(4000);
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','StreamPart'+intPart);
         objHidden.setAttribute('value',strText);
         document.forms['main'].appendChild(objHidden);
      }
      objTextStream.Close();
      objTextStream = null;
      objFile = null;
      objFileSystem = null;
      objHidden = document.createElement('input');
      objHidden.setAttribute('type','hidden');
      objHidden.setAttribute('name','StreamCount');
      objHidden.setAttribute('value',intPart);
      document.forms['main'].appendChild(objHidden);
   }
// -->
</script>