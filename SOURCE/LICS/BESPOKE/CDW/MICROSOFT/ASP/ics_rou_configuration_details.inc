<script language="javascript">
<!--
   ///////////////////////////////
   // Routing interfaces script //
   ///////////////////////////////
   var objInterfaces = new Array();
   objInterfaces[0] = new clsInterface('','** select interface **');<%for i = objSelection.ListLower("INTERFACE") to objSelection.ListUpper("INTERFACE")%>
   objInterfaces[<%=i+1%>] = new clsInterface('<%=objSelection.ListValue01("INTERFACE",i)%>','<%=replace(objSelection.ListValue02("INTERFACE",i), "'", "\'", 1, -1, 1)%>');<%next%>
   function clsInterface(strInterface,strDescription) {
      this.interface = strInterface;
      this.description = strDescription;
   }
   var objRoutingDetails = new Array();
   var savRoutingDetails = new Array();
   objRoutingDetails[0] = new clsRoutingDetail('Prefix','Interface');
   function clsRoutingDetail(strPrefix,strInterface) {
      this.prefix = strPrefix;
      this.interface = strInterface;
   }
   function loadRoutingDetails() {<%if strMode <> "INSERT" then%><%if objSelection.ListCount("DETAIL") <> 0 then%><%for i = objSelection.ListLower("DETAIL") to objSelection.ListUpper("DETAIL")%>
      objRoutingDetails[<%=i+1%>] = new clsRoutingDetail('<%=objSelection.ListValue01("DETAIL",i)%>','<%=objSelection.ListValue02("DETAIL",i)%>');<%next%><%end if%><%end if%>
      for (i=0;i<objRoutingDetails.length;i++) {
         savRoutingDetails[i] = new clsRoutingDetail(objRoutingDetails[i].prefix,objRoutingDetails[i].interface);
      }
      paintRoutingDetails();
   }
   function newRoutingDetail() {
      objRoutingDetails[objRoutingDetails.length] = new clsRoutingDetail('','');
      paintRoutingDetails();
   }
   function deleteRoutingDetail(lngIndex) {
      var objTemporarys = new Array();
      var j = 0;
      for (i=0;i<objRoutingDetails.length;i++) {
         if (i != lngIndex) {
            objTemporarys[j] = objRoutingDetails[i];
            j++;
         }
      }
      objRoutingDetails.length = objRoutingDetails.length - 1;
      for (i=0;i<objTemporarys.length;i++) {
         objRoutingDetails[i] = objTemporarys[i];
      }
      paintRoutingDetails();
   }
   function selectPrefix(inpPrefix,lngIndex) {
      objRoutingDetails[lngIndex].prefix = inpPrefix.value;
   }
   function selectInterface(sltInterface,lngIndex) {
      objRoutingDetails[lngIndex].interface = sltInterface.options[sltInterface.selectedIndex].value;
   }
   function checkRoutingDetails() {
      var strReturn = '';
      var objTemporarys = new Array();
      if (objRoutingDetails.length <= 1) {
         strReturn = 'At least one routing detail must be entered';
      }
      for (i=1;i<objRoutingDetails.length;i++) {
         if (objRoutingDetails[i].prefix == '') {
            if (strReturn != '') {strReturn = strReturn + '\r\n';}
            strReturn = strReturn + 'Prefix ' + i + ' must be specified';
         } else {
            if (objRoutingDetails[i].prefix.length != document.main.INP_RouPreLength.value - 0) {
               if (strReturn != '') {strReturn = strReturn + '\r\n';}
               strReturn = strReturn + 'Prefix (' + objRoutingDetails[i].prefix + ') must be ' + document.main.INP_RouPreLength.value + ' long';
            }
         }
         for (j=0;j<objTemporarys.length;j++) {
            if (objRoutingDetails[i].prefix == objTemporarys[j]) {
               if (strReturn != '') {strReturn = strReturn + '\r\n';}
               strReturn = strReturn + 'Prefix (' + objRoutingDetails[i].prefix + ') already specified';
            }
         }
         objTemporarys[objTemporarys.length] = objRoutingDetails[i].prefix;
         if (objRoutingDetails[i].interface == '') {
            if (strReturn != '') {strReturn = strReturn + '\r\n';}
            strReturn = strReturn + 'Interface ' + i + ' must be specified';
         }
      }
      return strReturn;
   }
   function changeRoutingDetails() {
      var bolReturn = false;
      if (objRoutingDetails.length != savRoutingDetails.length) {
         bolReturn = true;
         return bolReturn;
      }
      for (i=1;i<objRoutingDetails.length;i++) {
         if ((objRoutingDetails[i].prefix != savRoutingDetails[i].prefix)
          || (objRoutingDetails[i].interface != savRoutingDetails[i].interface)) {
            bolReturn = true;
            break;
         }
      }
      return bolReturn;
   }
   function paintRoutingDetails() {
      var strText = '<table align=center border=0 cellpadding=0 cellspacing=2 cols=3>';
      strText = strText + '<tr>';
      strText = strText + '<td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;<a class="clsSelect" href="javascript:newRoutingDetail();">Insert</a>&nbsp;</nobr></td>';
      strText = strText + '<td class="clsLabelBB" align=left colspan=1 nowrap><nobr>&nbsp;Prefix&nbsp;</nobr></td>';
      strText = strText + '<td class="clsLabelBB" align=left colspan=1 nowrap><nobr>&nbsp;Interface&nbsp;</nobr></td>';
      strText = strText + '</tr>';
      for (i=1;i<objRoutingDetails.length;i++) {
         strText = strText + '<tr>';
         strText = strText + '<td class="clsLabelBB" align=left colspan=1 valign=center nowrap><nobr>&nbsp;<a class="clsSelect" href="javascript:deleteRoutingDetail(' + i + ');">Delete&nbsp;</a></nobr></td>';
         strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><input class="clsInputNN" style="text-transform:uppercase;" type="text" name="DET_Prefix' + i + '" size="32" maxlength="32" value="' + objRoutingDetails[i].prefix + '" onFocus="setSelect(this);" onBlur="selectPrefix(this,' + i + ');"></nobr></td>';
         strText = strText + '<td class="clsLabelBN" align=left colspan=1 valign=center nowrap><nobr><select class="clsInputBN" name="DET_Interface' + i + '" onChange="selectInterface(this,' + i + ');">';
         for (j=0;j<objInterfaces.length;j++) {
            strText = strText + '<option value="' + objInterfaces[j].interface + '"';
            if (objRoutingDetails[i].interface == objInterfaces[j].interface) {
               strText = strText + ' selected';
            }
            strText = strText + '>' + objInterfaces[j].description;
         }
         strText = strText + '</select></nobr></td>';
         strText = strText + '</tr>';
      }
      strText = strText + '</table>';
      document.all.tabRoutingDetails.innerHTML = strText;
      document.all.DET_Count.value = objRoutingDetails.length - 1;
   }
// -->
</script>