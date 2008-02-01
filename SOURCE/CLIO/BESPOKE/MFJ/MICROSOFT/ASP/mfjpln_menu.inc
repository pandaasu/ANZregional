<html>
<script language="javascript">
<!--
   function setStatic() {
      parent.setLocation('http://www.tok.ap.mars/planning');
   }
   function setActions() {
      var strText = '<nobr>&nbsp;<a class="clsButton" href="javascript:doAction(\'Expand\');">Expand</a>&nbsp;';
      strText = strText + '|&nbsp;<a class="clsButton" href="javascript:doAction(\'Collapse\');">Collapse</a>&nbsp;</nobr>';
      parent.setActions(strText);
   }
   function doAction(strAction) {
      if (strAction == 'Expand') {
         explodeTree();
      }
      if (strAction == 'Collapse') {
         collapseTree();
      }
   }
   function selectNode(strRow,strScript) {
      parent.parent.setFrame02Actions('<nobr>&nbsp;Processing request - please wait&nbsp;</nobr>');
      parent.parent.showFrame02('<%=strBase%>' + strScript);
      return;
   }
   var objNodeOpen = new Image();
   objNodeOpen.src = 'tree_boko.gif';
   var objNodeShut = new Image();
   objNodeShut.src = 'tree_boks.gif';
   var objNodeLeaf = new Image();
   objNodeLeaf.src = 'tree_bokl.gif';
   function collapseTree() {<%if objMenu.NodeCount >= 0 then%>
      var objTree = eval('document.all("TRE_Grid")');
      var objLevel = null;
      var objNode = null;
      var objType = null;
      var objImage = null;
      for(i=0;i<=<%=objMenu.NodeCount%>;i++) {
         objLevel = eval('document.all("LVL_' + i  + '")');
         if (objLevel.value-0 > 1) {
            objNode = eval('document.all("NOD_' + i  + '")');
            objType = eval('document.all("TYP_' + i  + '")');
            if (objLevel.value-0 > 2) {
               objNode.style.display = 'none';
            }
            if (objType.value == 'O') {
               objImage = eval('document.all("IMG_' + i  + '")');
               objType.value = 'S';
               objImage.src = objNodeShut.src;
            }
         }
      }
      objTree.style.visibility = 'Visible';<%end if%>
      return;
   }
   function explodeTree() {
      var objTree = eval('document.all("TRE_Grid")');
      var objLevel = null;
      var objNode = null;
      var objType = null;
      var objImage = null;
      for(i=0;i<=<%=objMenu.NodeCount%>;i++) {
         objLevel = eval('document.all("LVL_' + i  + '")');
         objNode = eval('document.all("NOD_' + i  + '")');
         objNode.style.display = 'block';
         objType = eval('document.all("TYP_' + i  + '")');
         if (objType.value == 'S') {
            objImage = eval('document.all("IMG_' + i  + '")');
            objType.value = 'O';
            objImage.src = objNodeOpen.src;
         }
      }
      objTree.style.visibility = 'Visible';
      return;
   }
   function toggleNode(intNode) {
      var objParentType = eval('document.all("TYP_' + intNode  + '")');
      var objParentImage = eval('document.all("IMG_' + intNode  + '")');
      var objParentLevel = eval('document.all("LVL_' + intNode  + '")');
      var objChildLevel = null;
      var objChildNode = null;
      var objChildType = null;
      var objChildImage = null;
      if (objParentType.value == 'O') {
         objParentType.value = 'S';
         objParentImage.src = objNodeShut.src;
         for(i=(intNode-0)+1;i<=<%=objMenu.NodeCount%>;i++) {
            objChildLevel = eval('document.all("LVL_' + i  + '")');
            if (objChildLevel.value-0 > objParentLevel.value-0) {
               objChildNode = eval('document.all("NOD_' + i  + '")');
               objChildType = eval('document.all("TYP_' + i  + '")');
               objChildNode.style.display = 'none';
               if (objChildType.value == 'O') {
                  objChildImage = eval('document.all("IMG_' + i  + '")');
                  objChildType.value = 'S';
                  objChildImage.src = objNodeShut.src;
               }
            } else {
               break;
            }
         }
      } else {
         objParentType.value = 'O';
         objParentImage.src = objNodeOpen.src;
         for(i=(intNode-0)+1;i<=<%=objMenu.NodeCount%>;i++) {
            objChildLevel = eval('document.all("LVL_' + i  + '")');
            if (objChildLevel.value-0 > objParentLevel.value-0) {
               if (objChildLevel.value-0 == (objParentLevel.value-0)+1) {
                  objChildNode = eval('document.all("NOD_' + i  + '")');
                  objChildNode.style.display = 'block';
               }
            } else {
               break;
            }
         }
      }
      return;
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html;charset=Shift-JIS">
   <link rel="stylesheet" type="text/css" href="mfjpln_style.css">
</head>
<body class="clsBody01" scroll="auto" onLoad="setActions();collapseTree();"><% if objMenu.NodeCount >= 0 then%>
   <table id="TRE_Grid" class="clsGrid01" align=left valign=top cellpadding=0 cellspacing=0 cols=1 style="visibility:hidden">
      <%for i = 0 to objMenu.NodeCount%>
         <tr id="NOD_<%=i%>"><td class="clsLabelBN" align=left nowrap><nobr><%for j = 1 to objMenu.NodeLevel(i) - 1%>
            <IMG src="tree_nbsp.gif" align=absmiddle><%next%><%if objMenu.NodeNode(i) = "MENU" or objMenu.NodeNode(i) = "NODE" then%><%if objMenu.NodeChildren(i) = true then%>
            <IMG id="IMG_<%=i%>" class="clsImagePush" src="tree_boko.gif" align=absmiddle onClick="toggleNode('<%=i%>');"><%else%><%if mid(objMenu.NodeText(i),1,8) = "*STATIC*" then%>
            <IMG class="clsImagePush" src="tree_boks.gif" align=absmiddle onClick="setStatic();"><%else%>
            <IMG src="tree_boks.gif" align=absmiddle><%end if%><%end if%><%else%>
            <IMG src="tree_bokl.gif" align=absmiddle><%end if%><font id="COD_<%=i%>" <%if objMenu.NodeNode(i) = "MENU" or objMenu.NodeNode(i) = "NODE" then%>class="clsSelectLBB"<%else%>class="clsSelectLNB"<%end if%> align=left valign=center <%if objMenu.NodeNode(i) = "OPTION" then%>onClick="selectNode('COD_<%=i%>','<%=objMenu.NodeScript(i)%>');"<%end if%>><%if mid(objMenu.NodeText(i),1,8) = "*STATIC*" then%><%=mid(objMenu.NodeText(i),9,len(objMenu.NodeText(i))-8)%><%else%><%=objMenu.NodeText(i)%><%end if%></font>
         </nobr></td></tr>
      <%next%>
   </table>
   <%for i = 0 to objMenu.NodeCount%>
      <input type="hidden" id="LVL_<%=i%>" value="<%=cstr(objMenu.NodeLevel(i))%>"><%if objMenu.NodeChildren(i) = true then%>
      <input type="hidden" id="TYP_<%=i%>" value="O"><%else%>
      <input type="hidden" id="TYP_<%=i%>" value="L"><%end if%>
   <%next%><%else%>
   <table class="clsGrid01" align=center valign=center height="100%" cellpadding=0 cellspacing=0 cols=1>
      <tr><td class="clsLabelBB" align=center nowrap><nobr>MENU NOT DEFINED</nobr></td></tr>
   </table><%end if%>
</body>
</html>