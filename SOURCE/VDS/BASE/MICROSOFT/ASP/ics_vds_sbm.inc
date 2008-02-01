<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_Interface.focus();<%if strError <> "" then%>
      alert('<%=strError%>');<%end if%>
      return;
   }
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
   }
   function doSubmit() {
      if (!processForm()) {return;}
      var strMessage = '';
      var strLogon01 = '';
      var strLogon02 = '';
      if (document.main.INP_Interface.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Interface must be selected';
      }
      if (getLogon01(document.main.INP_Interface.value) == '1') {
         if (document.main.INP_User01.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Primary user must be entered';
         }
         if (document.main.INP_Password01.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Primary password must be entered';
         }
      }
      if (getLogon02(document.main.INP_Interface.value) == '1') {
         if (document.main.INP_User02.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Secondary user must be entered';
         }
         if (document.main.INP_Password02.value == '') {
            if (strMessage != '') {strMessage = strMessage + '\r\n';}
            strMessage = strMessage + 'Secondary password must be entered';
         }
      }
      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      if (confirm('Please confirm that you wish to continue\r\nPress OK to continue\r\nOr press Cancel')) {
         document.main.SLT_Interface.value = document.main.INP_Interface.value;
         document.main.SLT_User01.value = document.main.INP_User01.value;
         document.main.SLT_Password01.value = document.main.INP_Password01.value;
         document.main.SLT_User02.value = document.main.INP_User02.value;
         document.main.SLT_Password02.value = document.main.INP_Password02.value;
         document.main.action = '<%=strBase%><%=strTarget%>';
         document.main.Mode.value = 'SUBMIT';
         document.main.submit();
      }
   }
   function processForm() {
      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   function selectInterface(objSelect) {
      document.main.INP_Interface.value = objSelect.options[objSelect.selectedIndex].value;
   }
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="ics_std_input.inc"-->
<script language="javascript">
<!--
   ///////////////////////
   // Interfaces script //
   ///////////////////////
   var objInterfaces = new Array();<%for i = objSelection.ListLower("INTERFACE") to objSelection.ListUpper("INTERFACE")%>
   objInterfaces[<%=i%>] = new clsInterface('<%=objSelection.ListValue01("INTERFACE",i)%>','<%=replace(objSelection.ListValue02("INTERFACE",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue03("INTERFACE",i)%>','<%=objSelection.ListValue04("INTERFACE",i)%>');<%next%>
   function clsInterface(strInterface,strDescription,strLogon01,strLogon02) {
      this.interface = strInterface;
      this.description = strDescription;
      this.logon01 = strLogon01;
      this.logon02 = strLogon02;
   }
   function getLogon01(strInterface) {
      var strReturn = '0';
      for (i=0;i<objInterfaces.length;i++) {
         if (objInterfaces[i].interface == strInterface) {
            strReturn = objInterfaces[i].logon01;
         }
      }
      return strReturn;
   }
   function getLogon02(strInterface) {
      var strReturn = '0';
      for (i=0;i<objInterfaces.length;i++) {
         if (objInterfaces[i].interface == strInterface) {
            strReturn = objInterfaces[i].logon02;
         }
      }
      return strReturn;
   }
// -->
</script>
<head>
   <meta http-equiv="content-type" content="text/html; charset=<%=strCharset%>">
   <link rel="stylesheet" type="text/css" href="ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('ics_vds_sbm_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Interface:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltInterface" onChange="selectInterface(this);">
               <option value="" selected>** select interface **<%for i = 0 to objSelection.ListCount("INTERFACE") - 1%>
               <option value="<%=objSelection.ListValue01("INTERFACE",i)%>">(<%=objSelection.ListValue01("INTERFACE",i)%>)&nbsp;<%=objSelection.ListValue02("INTERFACE",i)%><%next%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Primary Logon:&nbsp;</td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SAP User:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_User01" size="30" maxlength="30" value="<%=objForm.Fields("SLT_User01").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SAP Password:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="password" name="INP_Password01" size="30" maxlength="30" value="<%=objForm.Fields("SLT_Password01").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Secondary Logon:&nbsp;</td>
         <td class="clsLabelBN" align=left colspan=1 nowrap><nobr>&nbsp;&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SAP User:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_User02" size="30" maxlength="30" value="<%=objForm.Fields("SLT_User02").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBN" align=right valign=center colspan=1 nowrap><nobr>&nbsp;SAP Password:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="password" name="INP_Password02" size="30" maxlength="30" value="<%=objForm.Fields("SLT_Password02").Value%>" onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSubmit();">&nbsp;Submit&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr><%if strConfirm <> "" then%>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center valign=center colspan=2 nowrap><nobr>&nbsp;<%=strConfirm%>&nbsp;</nobr></td>
      </tr><%end if%>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="SLT_Interface" value="<%=objForm.Fields("SLT_Interface").Value%>">
   <input type="hidden" name="INP_Interface" value="<%=objForm.Fields("SLT_Interface").Value%>">
   <input type="hidden" name="SLT_User01" value="<%=objForm.Fields("SLT_User01").Value%>">
   <input type="hidden" name="SLT_Password01" value="<%=objForm.Fields("SLT_Password01").Value%>">
   <input type="hidden" name="SLT_User02" value="<%=objForm.Fields("SLT_User02").Value%>">
   <input type="hidden" name="SLT_Password02" value="<%=objForm.Fields("SLT_Password02").Value%>">
</form>
</body>
</html>