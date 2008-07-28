<html>
<script language="javascript">
<!--
   function setActions() {
      var strText = '<a class="clsButton" href="javascript:doAction(\'Refresh\');">&nbsp;Refresh&nbsp;</a>';
      strText = strText + '&nbsp;<a class="clsButton" href="javascript:doAction(\'Expand\');">&nbsp;Expand&nbsp;</a>';
      strText = strText + '&nbsp;<a class="clsButton" href="javascript:doAction(\'Collapse\');">&nbsp;Collapse&nbsp;</a>';
      parent.setMenuHeading(strText);
   }
   function doAction(strAction) {
      if (strAction == 'Refresh') {
         parent.refreshMenu();
      }
      if (strAction == 'Expand') {
         explodeTree();
      }
      if (strAction == 'Collapse') {
         collapseTree();
      }
   }
   function selectNode(strScript) {
      parent.setContent('<%=strBase%>' + strScript);
      return;
   }
   var objNodeOpen = new Image();
   objNodeOpen.src = 'tree_boko.gif';
   var objNodeShut = new Image();
   objNodeShut.src = 'tree_boks.gif';
   var objNodeLeaf = new Image();
   objNodeLeaf.src = 'tree_bokl.gif';
   function collapseTree() {<%if objSecurity.NodeCount >= 0 then%>
      var objTree = eval('document.all("TRE_Grid")');
      var objLevel = null;
      var objNode = null;
      var objType = null;
      var objImage = null;
      for(i=1;i<=<%=objSecurity.NodeCount%>;i++) {
         objLevel = eval('document.all("LVL_' + i  + '")');
         if (objLevel.value-0 > 0) {
            objNode = eval('document.all("NOD_' + i  + '")');
            objType = eval('document.all("TYP_' + i  + '")');
            if (objLevel.value-0 > 1) {
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
      for(i=1;i<=<%=objSecurity.NodeCount%>;i++) {
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
         for(i=(intNode-0)+1;i<=<%=objSecurity.NodeCount%>;i++) {
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
         for(i=(intNode-0)+1;i<=<%=objSecurity.NodeCount%>;i++) {
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
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody01" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_help.htm');setActions();collapseTree();"><% if objSecurity.NodeCount >= 0 then%>
   <table id="TRE_Grid" class="clsGrid01" align=left valign=top cellpadding=0 cellspacing=0 cols=1 style="visibility:hidden">
      <%for i = 0 to objSecurity.NodeCount%>
         <tr id="NOD_<%=i%>"><td class="clsLabelBN" align=left nowrap><nobr><%for j = 1 to objSecurity.NodeLevel(i)%>
            <IMG src="tree_nbsp.gif" align=absmiddle><%next%><%if objSecurity.NodeLinkType(i) = "*TOP" then%>
            <IMG id="IMG_<%=i%>" src="<%if objSecurity.NodeObjectStatus(i) = "1" then%>tree_boks.gif<%else%>tree_uoff.gif<%end if%>" align=absmiddle><%else%><%if objSecurity.NodeLinkType(i) = "*MNU" then%>
            <IMG id="IMG_<%=i%>" class="clsImagePush" src="tree_boko.gif" align=absmiddle onClick="toggleNode('<%=i%>');"><%else%>
            <IMG src="<%if objSecurity.NodeLinkStatus(i) = "1" then%>tree_bokl.gif<%else%>tree_boff.gif<%end if%>" align=absmiddle><%end if%><%end if%><font <%if objSecurity.NodeLinkType(i) = "*TOP" or objSecurity.NodeLinkType(i) = "*MNU" then%>class="clsSelectLBB"<%else%>class="<%if objSecurity.NodeLinkStatus(i) = "1" then%>clsSelectLNB<%else%>clsSelectLNX<%end if%>"<%end if%> align=left valign=center<%if objSecurity.NodeLinkType(i) = "*OPT" then%><%if objSecurity.NodeLinkStatus(i) = "1" then%> onClick="selectNode('<%=objSecurity.NodeLinkScript(i)%>');<%end if%>"<%end if%>><%if objSecurity.NodeLinkType(i) = "*TOP" then%>(<%=objSecurity.NodeObjectText(i)%>)&nbsp;-&nbsp;<%end if%><%=objSecurity.NodeLinkText(i)%></font>
         </nobr></td></tr>
      <%next%>
   </table>
   <%for i = 0 to objSecurity.NodeCount%>
      <input type="hidden" id="LVL_<%=i%>" value="<%=cstr(objSecurity.NodeLevel(i))%>"><%if objSecurity.NodeLinkType(i) = "*TOP" or objSecurity.NodeLinkType(i) = "*MNU" then%>
      <input type="hidden" id="TYP_<%=i%>" value="O"><%else%>
      <input type="hidden" id="TYP_<%=i%>" value="L"><%end if%>
   <%next%><%else%>
   <table class="clsGrid01" align=center valign=center height="100%" cellpadding=0 cellspacing=0 cols=1>
      <tr><td class="clsLabelBB" align=center nowrap><nobr>USER NOT DEFINED</nobr></td></tr>
   </table><%end if%>
</body>
</html>