<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : PMX (PROMAX)                                       //
'// Script  : pmx_arclaims_removal.asp                           //
'// Author  : Rebekah Arnold                                     //
'// Date    : September 2005                                     //
'// Text    : This script implements the interface for           //
'//           AR Claims Removal functionality                    //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim strBase
   dim strTarget
   dim strStatus
   dim strReturn
   dim strHeading
   dim strMode
   dim objForm
   dim objSecurity
   dim objSelection
   dim objModify

   '//
   '// Set the server script timeout to (10 minutes)
   '// ** potentially long running process **
   '//
   server.scriptTimeout = 600

   '//
   '// Initialise the script
   '//
   strTarget = "pmx_arclaims_removal.asp"
   strHeading = "AR Claims Removal"

   '//
   '// Get the base string
   '//
   strBase = GetBase()

   '//
   '// Get the status
   '//
   strStatus = GetStatus()

   '//
   '// Retrieve the security information
   '//
   strReturn = GetSecurity()
   if strReturn = "*OK" then

      '//
      '// Get the form data
      '//
      GetForm()
      strMode = objForm.Fields("Mode").Value

      '//
      '// Process the form data
      '//
      call ProcessSearch

   end if

   '//
   '// Paint response
   '//
   select case strMode
      case "FATAL"
         call PaintFatal
      case else
         call PaintSearch
   end select
 
   '//
   '// Destroy references
   '//
   set objForm = nothing
   set objSecurity = nothing
   set objSelection = nothing
   set objModify = nothing

'/////////////////////////////////
'// Process search load routine //
'/////////////////////////////////
sub ProcessSearch()

   '//
   '// Create the selection object
   '//
   set objSelection = Server.CreateObject("ICS_SELECTION.Object")
   set objSelection.Security = objSecurity

   '//
   '// Initialise the data fields
   '//
   call objForm.AddField("INP_VarAcctgDocNum", "")
   call objForm.AddField("INP_VarCustCode", "")
   call objForm.AddField("INP_VarClaimRef", "")
   call objForm.AddField("INP_IntCmpnyCode", 147) ' default value
   call objForm.AddField("INP_IntDivCode", "")
   
   '// Populate the company codes
   call ProcessCompyCodes()

   '// Populate the division codes
   call ProcessDivCodes(objForm.Fields("INP_IntCmpnyCode").Value)
    
   select case strMode
      case "DELETE_LOAD"
         call ProcessDeleteLoad
      case "DELETE_ACCEPT"
         call ProcessDeleteAccept
      case else
         strReturn = "*ERROR: Invalid processing mode " & objForm.Fields("Mode").Value & " specified"
   end select
   
end sub

sub ProcessCompyCodes()

   dim strQuery
   dim lngSize
 
   '//
   '// Retrieve Job Type Descriptions
   '//
   lngSize = 0
   strQuery = "select distinct"
   strQuery = strQuery & " t01.cmpny_code"
   'strQuery = strQuery & " t01.cmpny_code_desc"
   strQuery = strQuery & " from pds_div t01"
   strQuery = strQuery & " order by t01.cmpny_code asc"
   strReturn = objSelection.Execute("COMPYCODES", strQuery, lngSize)
  
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if
   
end sub

sub ProcessDivCodes(IntCmpnyCode)

   dim strQuery
   dim lngSize
 
   '//
   '// Retrieve Job Type Descriptions
   '//
   lngSize = 0
   strQuery = "select distinct"
   strQuery = strQuery & " t01.div_code"
   'strQuery = strQuery & " t01.div_code_desc"
   strQuery = strQuery & " from pds_div t01"
   strQuery = strQuery & " where t01.cmpny_code=" & IntCmpnyCode
   strQuery = strQuery & " order by t01.div_code asc"
   strReturn = objSelection.Execute("DIVCODES", strQuery, lngSize)
   
   if strReturn <> "*OK" then
      strMode = "FATAL"
   end if
   
end sub

'/////////////////////////////////
'// Process update load routine //
'/////////////////////////////////
sub ProcessDeleteLoad()

   dim strQuery
   dim lngSize

   '//
   '// Retrieve the job data
   '//
   lngSize = 0
   strQuery = "select *"
   strQuery = strQuery & " from pds_ar_claims t01"
   strQuery = strQuery & " where t01.acctg_doc_num = '" & objSecurity.FixString(objForm.Fields("INP_VarAcctgDocNum").Value) & "'"
   strQuery = strQuery & " and t01.cust_code = '" & objSecurity.FixString(objForm.Fields("INP_VarCustCode").Value) & "'"
   strQuery = strQuery & " and t01.claim_ref = '" & objSecurity.FixString(objForm.Fields("INP_VarClaimRef").Value) & "'"
   strQuery = strQuery & " and t01.cmpny_code = " & objForm.Fields("INP_IntCmpnyCode").Value
   strQuery = strQuery & " and t01.div_code = " & objForm.Fields("INP_IntDivCode").Value
   strQuery = strQuery & " and t01.valdtn_status = 'INVALID'"
   strReturn = objSelection.Execute("CLAIM", strQuery, lngSize)

   if strReturn <> "*OK" then
      strMode = ""
      strReturn = FormatError(strReturn)
      exit sub
   end if
   
   call objForm.AddField("DEL_VarAcctgDocNum", objSelection.ListValue01("CLAIM",1))
   call objForm.AddField("DEL_VarCustCode", objSelection.ListValue12("CLAIM",1))
   call objForm.AddField("DEL_VarClaimRef", objSelection.ListValue17("CLAIM",1))
   call objForm.AddField("DEL_IntCmpnyCode", objSelection.ListValue09("CLAIM",1))
   call objForm.AddField("DEL_IntDivCode", objSelection.ListValue11("CLAIM",1))

   
   '//
   '// Set the mode
   '//
   strMode = "DELETE"

end sub

'///////////////////////////////////
'// Process update accept routine //
'///////////////////////////////////
sub ProcessDeleteAccept()

   dim strQuery

   '//
   '// Create the modify object
   '//
   Set objModify = Server.CreateObject("ICS_MODIFY.Object")
   Set objModify.Security = objSecurity

   '//
   '// Update the job
   '//
   strQuery = "UPDATE pds_ar_claims t01"
   strQuery = strQuery & " SET "
   strQuery = strQuery & " valdtn_status = 'DELETED'"
   strQuery = strQuery & " where t01.acctg_doc_num = '" & objSecurity.FixString(objForm.Fields("INP_VarAcctgDocNum").Value) & "'"
   strQuery = strQuery & " and t01.cust_code = '" & objSecurity.FixString(objForm.Fields("INP_VarCustCode").Value) & "'"
   strQuery = strQuery & " and t01.claim_ref = '" & objSecurity.FixString(objForm.Fields("INP_VarClaimRef").Value) & "'"
   strQuery = strQuery & " and t01.cmpny_code = " & objForm.Fields("INP_IntCmpnyCode").Value
   strQuery = strQuery & " and t01.div_code = " & objForm.Fields("INP_IntDivCode").Value
   strQuery = strQuery & " and t01.valdtn_status = 'INVALID'"
   strReturn = objModify.Execute(strQuery)

   if strReturn <> "*OK" then
      strMode = "DELETE"
      strReturn = FormatError(strReturn)
      exit sub
   end if

   '//
   '// Set the mode
   '//
   strMode = "SEARCH"

end sub

'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="../ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint prompt routine //
'//////////////////////////
sub PaintSearch()%>
<html>
<script language="javascript">
<!--
   function showError() {
      document.main.INP_VarAcctgDocNum.focus();<%if strReturn <> "*OK" then%>
      alert('<%=strReturn%>');<%else%>return;<%end if%>
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

   function doSearch() {
      if (!processForm()) {return;}
      var strMessage = '';
      
      if (document.main.INP_VarAcctgDocNum.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Acctg Document Number must be entered';
      }
      if (document.main.INP_VarAcctgDocNum.value.indexOf(' ') != -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Acctg Document Number must not have spaces';
      }
      if (document.main.INP_VarCustCode.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Customer Code must be entered';
      }
      if (document.main.INP_VarCustCode.value.indexOf(' ') != -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Customer Code must not have spaces';
      }
      if (document.main.INP_VarClaimRef.value == '') {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Claim Reference must be entered';
      }
      if (document.main.INP_VarClaimRef.value.indexOf(' ') != -1) {
         if (strMessage != '') {strMessage = strMessage + '\r\n';}
         strMessage = strMessage + 'Claim Reference must not have spaces';
      }

      if (strMessage != '') {
         alert(strMessage);
         return;
      }
      
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'DELETE_LOAD';
      document.main.submit();
   }

   function doDelete() {
      // set list variables
	  document.main.INP_IntCmpnyCode.value = document.main.sltCmpnyCode.options[document.main.sltCmpnyCode.selectedIndex].value;
      document.main.INP_IntDivCode.value = document.main.sltDivCode.options[document.main.sltDivCode.selectedIndex].value;
      
      if (confirm("Are you sure that you want to delete the claim?")) {
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = 'DELETE_ACCEPT';
      document.main.submit();
      }
   }
   
   function processForm() {
	  // set list variables
	  document.main.INP_IntCmpnyCode.value = document.main.sltCmpnyCode.options[document.main.sltCmpnyCode.selectedIndex].value;
      document.main.INP_IntDivCode.value = document.main.sltDivCode.options[document.main.sltDivCode.selectedIndex].value;

      if (checkInput() == true) {
         alert('Input data errors exist');
         return false;
      }
      return true;
   }
   
   function selectCmpnyCode(objSelect) {
      if (!processForm()) {return;}
     
      alert("Reloading page with division code list... please wait.");
      
      document.main.action = '<%=strBase%><%=strTarget%>';
      document.main.Mode.value = '';
      document.main.submit();
   }
   
   function setSelect(objInput) {
      objInput.select();
   }
// -->
</script>
<!--#include file="../ics_std_input.inc"-->
<!--#include file="../ics_std_number.inc"-->
<head>
   <meta http-equiv="content-type" content="text/html">
   <link rel="stylesheet" type="text/css" href="../ics_style.css">
</head>
<body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('pmx_arclaims_removal_help.htm');parent.setHeading('<%=strHeading%> - Search');parent.showContent();showError();">
<form name="main" action="<%=strBase%><%=strTarget%>" method="post">
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;ACCTG Document Number:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VarAcctgDocNum" size="20" maxlength="10" value="<%=objForm.Fields("INP_VarAcctgDocNum").Value%>" onFocus="setSelect(this);">
         </nobr></td>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Company Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltCmpnyCode" onChange="selectCmpnyCode(this);">
			   <%if objSelection.ListCount("COMPYCODES") = 0 then%>
			   <option value="NULL" selected>Nothing retreived
               <%else%>
               <%for i = objSelection.ListLower("COMPANYCODES") to objSelection.ListUpper("COMPYCODES")%>
               <option value=<%=objSelection.ListValue01("COMPYCODES",i)%><%if objForm.Fields("INP_IntCmpnyCode").Value = objSelection.ListValue01("COMPYCODES",i) then%> selected<%end if%>><%=objSelection.ListValue01("COMPYCODES",i)%>
               <%next%>
               <%end if%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Customer Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VarCustCode" size="20" maxlength="10" value="<%=objForm.Fields("INP_VarCustCode").Value%>" onFocus="setSelect(this);">
         </nobr></td>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Division Code:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr>
            <select class="clsInputBN" name="sltDivCode">
               <%if objSelection.ListCount("DIVCODES") = 0 then%>
			   <option selected>Nothing retreived
               <%else%>
               <%for i = objSelection.ListLower("DIVCODES") to objSelection.ListUpper("DIVCODES")%>
               <option value=<%=objSelection.ListValue01("DIVCODES",i)%><%if objForm.Fields("INP_IntDivCode").Value = objSelection.ListValue01("DIVCODES",i) then%> selected<%end if%>><%=objSelection.ListValue01("DIVCODES",i)%>
               <%next%>
               <%end if%>
            </select>
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;Claim Reference:&nbsp;</nobr></td>
         <td class="clsLabelBN" align=left valign=center colspan=3 nowrap><nobr>
            <input class="clsInputNN" type="text" name="INP_VarClaimRef" size="20" maxlength="12" value='<%=objForm.Fields("INP_VarClaimRef").Value%>' onFocus="setSelect(this);">
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=4 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=4 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doSearch();">&nbsp;Search&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="<%=objForm.Fields("Mode").Value%>">
   <input type="hidden" name="INP_IntCmpnyCode" value="<%=objForm.Fields("INP_IntCmpnyCode").Value%>">
   <input type="hidden" name="INP_IntDivCode" value="<%=objForm.Fields("INP_IntDivCode").Value%>">
   <nobr>
   <hr width=95%>
   <%if objForm.Fields("Mode").Value = "DELETE_LOAD" then
	PaintDelete()
   end if%>
</form>
</body>
</html>
<%end sub

'//////////////////////////
'// Paint delete routine //
'//////////////////////////
sub PaintDelete()%>
   <table class="clsGrid02" align=center valign=top cols=2 cellpadding="1" cellspacing="0">
		<%if objSelection.ListCount("CLAIM") = 1 then%>
        <tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;ACCTG_DOC_NUM:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("CLAIM",0)%></nobr></td>
			<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;AR_CLAIMS_LUPDP:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;AR_CLAIMS_LUPDT:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;AR_CLAIMS_SEQ:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;ASSIGNMNT_NUM:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;BUS_PRTNR_REF2:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;CLAIM_AMT:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;CLAIM_REF:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue08("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;CMPNY_CODE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue09("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;CUST_CODE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue10("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;DIV_CODE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue11("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;FISCL_YEAR:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue12("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;IDOC_DATE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue13("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;IDOC_NUM:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue14("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;IDOC_TYPE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue15("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;INTFC_BATCH_CODE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue16("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;LINE_ITEM_NUM:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue17("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;PERIOD_NUM:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue18("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;POSTNG_DATE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue19("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;PROCG_STATUS:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue20("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;PROMAX_AR_APPRVL_DATE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue21("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;PROMAX_AR_LOAD_DATE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue22("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;PROMAX_CUST_CODE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue23("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;PROMAX_CUST_VNDR_CODE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue24("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;REASN_CODE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue25("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;TAX_AMT:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue26("CLAIM",0)%></nobr></td>
		</tr>
		<tr>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;TAX_CODE:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue27("CLAIM",0)%></nobr></td>
		 	<td>&nbsp;</td>
		 	<td class="clsLabelBB" align=right valign=center colspan=1 nowrap><nobr>&nbsp;VALDTN_STATUS:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left valign=center colspan=1 nowrap><nobr><%=objSelection.ListValue28("CLAIM",0)%></nobr></td>
    	</tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=5 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=5 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doDelete();">&nbsp;Delete&nbsp;</a></nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
      <%else%>
    	<%if objSelection.ListCount("CLAIM") = 0 then%>
    	<tr>
			<td class="clsError" align=center colspan=2 nowrap><nobr>&nbsp;No claim found to match your search.</td>
        </tr>
        <%else%>
        <%if objSelection.ListCount("CLAIM") > 1 then%>
    	<tr>
			<td class="clsError" align=center colspan=2 nowrap><nobr>&nbsp;ERROR - more than one valid claim was found. This is really really BAD and should not be possible!!!</td>
		</tr>
		<%end if%>
	  <%end if%>
   <%end if%>
   </table>
   <input type="hidden" name="DEL_VarAcctgDocNum" value="<%=objSelection.ListValue01("CLAIM",0)%>">
   <input type="hidden" name="DEL_VarCustCode" value="<%=objSelection.ListValue10("CLAIM",0)%>">
   <input type="hidden" name="DEL_VarClaimRef" value="<%=objSelection.ListValue08("CLAIM",0)%>">
   <input type="hidden" name="DEL_IntCmpnyCode" value="<%=objSelection.ListValue09("CLAIM",0)%>">
   <input type="hidden" name="DEL_IntDivCode" value="<%=objSelection.ListValue11("CLAIM",0)%>">
<%end sub%>
<!--#include file="../ics_std_code.inc"-->