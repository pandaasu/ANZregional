<%@ Language=VBScript %>
<% option explicit %>
<%
'///////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                      //
'// Script  : pmx_error_reprocess.asp                             //
'// Author  : Paul Jacobs                                         //
'// Date    : December 2005                                       //
'// Text    : This page allows the users of the promax system to  //
'//           review the erros associated with the system and     //
'//           attempt to reprocess them, if they choose           //
'///////////////////////////////////////////////////////////////////

  '//
  '// Declare the variables
  '//
  Dim strBase		'As String
  Dim strTarget	'As String
  Dim strStatus	'As String
  Dim strReturn	'As String
  Dim strQuery		'As String
  Dim strHeading	'As String 
  Dim objForm
  Dim objSecurity
  Dim objSelection
  Dim objProcedure
  Dim objModify
  Dim lngSize		'As Integer
  Dim i				'As Integer

  Dim v_Status
  Dim v_Mode
  Dim v_intfcType
  Dim v_cmpny_code
  Dim v_div_code
  Dim v_valdtn_div
  Dim v_valdtn_cmpny
  Dim v_bolDirAccess
  Dim v_bol_button_visable 
  
  
  '//
  '// Set initial variables
  '//
  lngSize = 50000
  strTarget = "pmx_error_reprocess.asp"
  strHeading = "Error Review And Reprocess"  
  v_bolDirAccess = False
  v_bol_button_visable = False
  
    
  '//
  '// Set the server script timeout to (10 minutes)
  '// ** allow for network performance issues **
  '//
  server.scriptTimeout = 600
      
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

    '//
    '// Process the form
    '//
    call ProcessForm

  end if
  
 
  '//
  '// Paint response
  '//
  if strReturn <> "*OK" then
    call PaintFatal
  else
    call PaintForm
  end if
  
  
  '//
  '// Destroy references
  '//
  set objForm = nothing
  set objSecurity = nothing
  set objSelection = nothing
  set objModify = nothing


  '//////////////////////////
  '// Process form routine //
  '//////////////////////////
  sub ProcessForm()
    '//
    '// Create the selection object
    '//
    set objSelection = Server.CreateObject("ICS_SELECTION.Object")
    set objSelection.Security = objSecurity
    
    '//
    '// Create the modify object
    '//
    set objModify = Server.CreateObject("ICS_MODIFY.Object")
    set objModify.Security = objSecurity
    
    '//
    '// Create the selection object
    '//        
    set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
    set objProcedure.Security = objSecurity

	 '//
	 '// Retrieve a previce InterfaceType if it exists
	 '//
	 v_intfcType	 = objForm.Fields("intfcType").Value
    v_cmpny_code	 = objForm.Fields("cmpny_code").Value
    v_div_code	    = objForm.Fields("div_code").Value
    v_mode         = objForm.Fields("mode").Value  
    v_bolDirAccess = objForm.Fields("bolDirAccess").Value    
 
    If v_bolDirAccess = "True" Then
      v_bolDirAccess = True
    End If
 
	'//
	'// Check if the query string is complete and if there is No mode value; if this is TRUE
	'// the page must be being accessed directly, i.e. via the link in the invalid item email.
	'//
   If Not Len(v_div_code) = 0 And Not v_div_code = "X" Then 
		If Len(v_mode) = 0 Then
		  v_mode = "GET_INVALID_REC"
		  v_bolDirAccess = True
		End If
   End If
  
    
   Select Case v_mode
      Case "GET_CMPNY"
        '// Get records for drop down list
        strQuery = " SELECT DISTINCT "
        strQuery = strQuery &  "  t1.cmpny_code, "
        strQuery = strQuery &  "  t2.cmpny_desc "
        strQuery = strQuery &  " FROM "
        strQuery = strQuery &  "  pds_email_list t1,"
        strQuery = strQuery &  "  pds_div t2"
        strQuery = strQuery &  " WHERE "
        strQuery = strQuery &  "  t1.cmpny_code = t2.cmpny_code"
        	
		  strReturn = objSelection.Execute("GET_CMPNY", strQuery, lngSize)	
		 
		  '// Get records for drop down list
        strQuery = " SELECT t1.valdtn_type_code, t1.valdtn_type_desc"
        strQuery = strQuery &  " FROM pds_valdtn_type t1"
        	
		  strReturn = objSelection.Execute("VALDTN_TYPES", strQuery, lngSize)	
		  
        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If		  
		  
      Case "GET_DIV"      
       '// Get records for drop down list
        strQuery = " SELECT DISTINCT "
        strQuery = strQuery &  "  t1.cmpny_code, "
        strQuery = strQuery &  "  t2.cmpny_desc "
        strQuery = strQuery &  " FROM "
        strQuery = strQuery &  "  pds_email_list t1,"
        strQuery = strQuery &  "  pds_div t2"
        strQuery = strQuery &  " WHERE "
        strQuery = strQuery &  "  t1.cmpny_code = t2.cmpny_code"
        	
		  strReturn = objSelection.Execute("GET_CMPNY", strQuery, lngSize)	
		 
		  '// Get records for drop down list
        strQuery = " SELECT t1.valdtn_type_code, t1.valdtn_type_desc"
        strQuery = strQuery &  " FROM pds_valdtn_type t1"
        	
		  strReturn = objSelection.Execute("VALDTN_TYPES", strQuery, lngSize)	
		  
		  
        '// Get records for drop down list
        strQuery = " SELECT DISTINCT "
        strQuery = strQuery &  " t1.div_code, "
        strQuery = strQuery &  "	t2.div_desc "
        strQuery = strQuery &  " FROM "
        strQuery = strQuery &  "  pds_email_list t1,"
        strQuery = strQuery &  "  pds_div t2"
        strQuery = strQuery &  " WHERE "
        strQuery = strQuery &  "  t1.cmpny_code = t2.cmpny_code"
        strQuery = strQuery &  "  AND t1.div_code = t2.div_code"
        strQuery = strQuery &  "  AND t2.cmpny_code = " & v_cmpny_code
        	
		  strReturn = objSelection.Execute("GET_DIV", strQuery, lngSize)	
			
        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If
      
      Case "GET_INVALID_REC"
        '// Get records for drop down list for company codes
			strQuery = " SELECT DISTINCT "
			strQuery = strQuery &  "  t1.cmpny_code, "
			strQuery = strQuery &  "  t2.cmpny_desc "
			strQuery = strQuery &  " FROM "
			strQuery = strQuery &  "  pds_email_list t1,"
			strQuery = strQuery &  "  pds_div t2"
			strQuery = strQuery &  " WHERE "
			strQuery = strQuery &  "  t1.cmpny_code = t2.cmpny_code"
				
			strReturn = objSelection.Execute("GET_CMPNY", strQuery, lngSize)	
		
		 
			'// Get records for drop down list validation types
			strQuery = " SELECT t1.valdtn_type_code, t1.valdtn_type_desc"
			strQuery = strQuery &  " FROM pds_valdtn_type t1"
				
			strReturn = objSelection.Execute("VALDTN_TYPES", strQuery, lngSize)	
		  
		  
			'// Get records for drop down list for company divisions
			strQuery = " SELECT DISTINCT "
			strQuery = strQuery &  " t1.div_code, "
			strQuery = strQuery &  "	t2.div_desc "
			strQuery = strQuery &  " FROM "
			strQuery = strQuery &  "  pds_email_list t1,"
			strQuery = strQuery &  "  pds_div t2"
			strQuery = strQuery &  " WHERE "
			strQuery = strQuery &  "  t1.cmpny_code = t2.cmpny_code"
			strQuery = strQuery &  "  AND t1.div_code = t2.div_code"
			strQuery = strQuery &  "  AND t2.cmpny_code = " & v_cmpny_code
				
			strReturn = objSelection.Execute("GET_DIV", strQuery, lngSize)	
		  
			If strReturn <> "*OK" Then
			  call PaintFatal
			  exit sub
			End If
		  
		  ' Select Case used to retrieve the specific values for the interface validation type, 
		  ' the company code and the division.		  
        Select Case v_intfcType
          ' ******************** MATERIALS INTERFACE TYPE ********************
          Case "9"		        			
					'// Used to determine if a legacy code should be used instead of the GRD code
					strQuery = " SELECT "
					strQuery = strQuery &  "   t1.pmx_cmpny_code,"
					strQuery = strQuery &  "   t1.pmx_div_code,"
					strQuery = strQuery &  "   t1.atlas_flag"
					strQuery = strQuery &  " FROM "
					strQuery = strQuery &  "   pds_div t1"
					strQuery = strQuery &  " WHERE "
					strQuery = strQuery &  "   t1.cmpny_code = '" & v_cmpny_code & "'"
					strQuery = strQuery &  "   AND t1.div_code = '" & v_div_code & "'"

					strReturn = objSelection.Execute("GRD_CONV", strQuery, lngSize)			  
	  
					If strReturn <> "*OK" Then
					  call PaintFatal
					  exit sub
					End If
			
			
					'// 
					'// If Company and Division is using legacy codes in the validation table
					'// perform conversion.
					'//			 
					If objSelection.ListValue03("GRD_CONV",0) = "N" Then
					  v_valdtn_cmpny = objSelection.ListValue01("GRD_CONV",0)
					  v_valdtn_div = objSelection.ListValue02("GRD_CONV",0)
					Else
					  ' Company Code is manipulated, as outgoing interfaces using the GRD code will only
					  ' use the last 2 digits. The "%" sign is used by Oracle, to indicate anything can 
					  ' precede 
					  v_valdtn_cmpny = "%" & Mid(v_cmpny_code,2,3)
					  v_valdtn_div = v_div_code
					End If 	


					'// Retrieve INVALID records in the validation tables
					strQuery = " SELECT"
					strQuery = strQuery &  "   t1.item_code_1, "
					strQuery = strQuery &  "   t1.item_code_2 AS cmpny_code,"
					strQuery = strQuery &  "   t1.item_code_3 AS div_code,"
					strQuery = strQuery &  "   t2.valdtn_reasn_dtl_msg AS message,"
					strQuery = strQuery &  "   t2.valdtn_reasn_dtl_svrty AS severity,"
					strQuery = strQuery &  "   t2.valdtn_reasn_dtl_lupdt AS lupdt"
					strQuery = strQuery &  " FROM"
					strQuery = strQuery &  "   pds_valdtn_reasn_hdr t1,"
					strQuery = strQuery &  "   pds_valdtn_reasn_dtl t2"
					strQuery = strQuery &  " WHERE"
					strQuery = strQuery &  "   t1.valdtn_type_code = '09'"
					strQuery = strQuery &  "   AND t1.valdtn_reasn_hdr_code = t2.valdtn_reasn_hdr_code"
					strQuery = strQuery &  "   AND t1.item_code_2 = '" & v_valdtn_cmpny & "'"
					strQuery = strQuery &  "   AND t1.item_code_3 = '" & v_valdtn_div & "'"
					strQuery = strQuery &  " ORDER BY"
					strQuery = strQuery &  "   t1.item_code_1,"
					strQuery = strQuery &  "   t1.item_code_2,"
					strQuery = strQuery &  "   t1.item_code_3,"
					strQuery = strQuery &  "   t1.valdtn_reasn_hdr_code,"
					strQuery = strQuery &  "   t2.valdtn_reasn_dtl_seq"
						               	
					strReturn = objSelection.Execute("RETRIEVE_INVALIDS", strQuery, lngSize)						        
				   
				   v_bol_button_visable = True
			  Case Else
			    
			  
			  
			  
			  If strReturn <> "*OK" Then
				  call PaintFatal
				  exit sub
				End If
			  
			End Select 
	   
	   '// If the reprocess button is hit, the records are updated and resubmitted for processing
	   Case "REPROCESS"	
		  Select Case v_intfcType
          ' ******************** MATERIALS INTERFACE TYPE ********************
          Case "9"		       
		      Response.Write "update SQL required here"		      
		  End Select
		  		   
      Case Else 
         
        '// Get records for drop down list
        strQuery = " SELECT t1.valdtn_type_code, t1.valdtn_type_desc"
        strQuery = strQuery &  " FROM pds_valdtn_type t1"
        	
		  strReturn = objSelection.Execute("VALDTN_TYPES", strQuery, lngSize)	
			
        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If
      
    End Select

  End Sub


  '///////////////////
  '// Fatal routine //
  '///////////////////

  sub PaintFatal()%>
    <!--#include file="../ics_fatal.inc"-->
  <%end sub

  sub PaintForm()
  %>
    <html>
      <script language="javascript">
      <!--
        // SG Code
        function document.onmouseover()
        {
          var objElement = window.event.srcElement;
          if (objElement.className == 'clsButton')
          {
            objElement.className = 'clsButtonX';
          }

          if (objElement.className == 'clsSelect')
          {
             objElement.className = 'clsSelectX';
          }
        }


        // SG Code
        function document.onmouseout()
        {
          var objElement = window.event.srcElement;
          if (objElement.className == 'clsButtonX')
          {
            objElement.className = 'clsButton';
          }

          if (objElement.className == 'clsSelectX')
          {
            objElement.className = 'clsSelect';
          }
        }


        // PJ Code
        function goBack()
        {
          history.go(-1);
        }
 
 
       function getCmpny(objSelect){
				if(objSelect.options[objSelect.selectedIndex].value == 'X'){
					alert("You Need to Select A Interface")
					}
				else {
					document.main.action = '<%=strBase%><%=strTarget & "?intfcType="%>' + objSelect.options[objSelect.selectedIndex].value; 
					document.main.Mode.value = 'GET_CMPNY';
					document.main.cmpny_code.value = 'X';
					document.main.submit();
				}
			}
			
			
		function getDiv(objSelect)
		{
		  if(objSelect.options[objSelect.selectedIndex].value == 'X'){
				alert("You Need to Select A Interface")
				}
			else {
				document.main.action =  '<%=strBase%><%=strTarget%>' + '?intfcType=' + <%=v_intfcType%> + '&cmpny_code=' + objSelect.options[objSelect.selectedIndex].value; 
				document.main.Mode.value = 'GET_DIV';
				document.main.div_code.value = 'X';
				document.main.submit();
			}
		}
      
      
      function getValdtnRec(objSelect)
      {
        if(objSelect.options[objSelect.selectedIndex].value == 'X'){
				alert("You Need to Select A Interface")
				}
			else {
				document.main.action =  '<%=strBase%><%=strTarget%>' + '?intfcType=' + <%=v_intfcType%> + '&cmpny_code=' + <%=v_cmpny_code%> + '&div_code=' + objSelect.options[objSelect.selectedIndex].value; 			
				document.main.Mode.value = 'GET_INVALID_REC';
				document.main.submit();
			}
      }
      
         
 // -->
</script>
	<!--#include file="../ics_std_scrollable.inc"-->
<head>
<meta http-equiv="content-type" content="text/html">
<link rel="stylesheet" type="text/css" href="../ics_style.css">
</head>
 <% If v_bolDirAccess = True Then %>
 <body class="clsBody02" scroll="auto" onLoad="setScrollable('Head','Body','horizontal');">
 <%Else%>
 <body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('/ics_int_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');">
 <%End If%>
 <form name="main" action="<%=strBase%><%=strTarget%>" method="post"> 
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
     	<tr>				 
			<td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Interface Type:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left colspan=1 nowrap width=><nobr>
			<select class="clsInputBN" name="intfcType" onChange="getCmpny(this);" maxlength="25">
               <option value="X"<%if v_intfcType = "" then%> selected<%end if%>><---- Interface Type Identification ----></OPTION><%for i = 0 to objSelection.ListCount("VALDTN_TYPES") - 1%>
               <option value="<%=objSelection.ListValue01("VALDTN_TYPES",i)%>" <%If v_intfcType = objSelection.ListValue01("VALDTN_TYPES",i) Then%> selected <%End If%>><%= objSelection.ListValue02("VALDTN_TYPES",i)%></OPTION><%next%>              
          </select>            
         </nobr></td>
			</td>		
		</tr>			
		<tr>
			<td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Company:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left colspan=1 nowrap width=><nobr>
			<select class="clsInputBN" name="cmpny_code" onChange="getDiv(this);" maxlength="25">
               <option value="X"<%if v_cmpny_code = "" then%> selected<%end if%>><---- Company ----></OPTION><%for i = 0 to objSelection.ListCount("GET_CMPNY") - 1%>
               <option value="<%=objSelection.ListValue01("GET_CMPNY",i)%>" <%If v_cmpny_code = objSelection.ListValue01("GET_CMPNY",i) Then%> selected <%End If%>><%= objSelection.ListValue02("GET_CMPNY",i)%></OPTION><%next%>              
          </select>  			            
         </nobr></td>
			</td>					
      </tr>
      <tr>
			<td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Division:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left colspan=1 nowrap width=><nobr>
			<select class="clsInputBN" name="div_code" onChange="getValdtnRec(this);" maxlength="25">
			       <option value="X"<%if v_div_code = "" then%> selected<%end if%>><---- Company Division ----></OPTION><%for i = 0 to objSelection.ListCount("GET_DIV") - 1%>
			       <option value="<%=objSelection.ListValue01("GET_DIV",i)%>" <%If v_div_code = objSelection.ListValue01("GET_DIV",i) Then%> selected <%End If%>><%= objSelection.ListValue02("GET_DIV",i)%></OPTION><%next%>              
			</select>  			            
			</nobr></td>
			</td>						       	       
      </tr>
     <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
          <% If  v_bol_button_visable = True Then %>  
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr>                             
                  <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPrevious();">&nbsp;Reprocess Errors&nbsp</a></nobr></td>
                  <!--<td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td>                  
                  <td align=right colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doNext();">&nbspNext&nbsp></a></nobr></td>-->                                            
               </tr>
            </table>
            <% End If %>
         </nobr></td>
      </tr>
      <%
        ' Select Case used to retrieve the specific values for the interface validation type, 
		  ' the company code and the division.		  
        Select Case v_intfcType
          ' ******************** MATERIALS INTERFACE TYPE ********************
          Case "9"
      %>      
				<tr height=100% width="80%">
				   <td align=center colspan=2 nowrap width="80%"><nobr>
				      <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
				         <tr>
				            <td align=center colspan=1 nowrap><nobr>
				               <div class="clsFixed" id="conHead">
				               <table class="clsTableHead" id="tabHead" align=left cols=9 cellpadding="0" cellspacing="1">
				                  <tr>
				                     <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Material Code&nbsp;</nobr></td>
				                     <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Severity&nbsp;</nobr></td>
				                     <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Error Message&nbsp;</nobr></td>
				                     <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Date & Time Stamp&nbsp;</nobr></td>                           
				                     <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
				                  </tr>
				               </table>
				               </div>
				            </nobr></td>
				         </tr>
				         <tr height=100%>
				            <td align=center colspan=1 nowrap><nobr>
				               <div class="clsScroll" id="conBody">
				              <table class="clsTableBody" id="tabBody" align=left cols=8 cellpadding="0" cellspacing="1">
				               <%If Not v_mode = "GET_INVALID_REC" Then %>                       
				                   <tr><td class="clsLabelFB" align=center colspan=8 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr>                                                     
				                 <%Else
										 For i = objSelection.ListLower("RETRIEVE_INVALIDS") to objSelection.ListUpper("RETRIEVE_INVALIDS")%>                       
											<tr>									
											   <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("RETRIEVE_INVALIDS",i)%></nobr></td>
											   <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("RETRIEVE_INVALIDS",i)%></nobr></td>
											   <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("RETRIEVE_INVALIDS",i)%></nobr></td>
											   <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("RETRIEVE_INVALIDS",i)%></nobr></td>                                                      
											</tr>
										<%Next
				                End If%>                                 
				                    
				               </table>                        
				              </div>
				            </nobr>
				            </td>
				         </tr>          
			<% Case Else   %>      
				<tr height=100% width="80%">
				   <td align=center colspan=2 nowrap width="80%"><nobr>
				      <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
				         <tr>
				            <td align=center colspan=1 nowrap><nobr>
				               <div class="clsFixed" id="conHead">
				               <table class="clsTableHead" id="tabHead" align=left cols=9 cellpadding="0" cellspacing="1">
				                  <tr>
				                     <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Material Code&nbsp;</nobr></td>
				                     <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Severity&nbsp;</nobr></td>
				                     <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Error Message&nbsp;</nobr></td>
				                     <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Date & Time Stamp&nbsp;</nobr></td>                           
				                     <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp</nobr></td>
				                  </tr>
				               </table>
				               </div>
				            </nobr></td>
				         </tr>
				         <tr height=100%>
				            <td align=center colspan=1 nowrap><nobr>
				               <div class="clsScroll" id="conBody">
				              <table class="clsTableBody" id="tabBody" align=left cols=8 cellpadding="0" cellspacing="1">
				               <%If Not v_mode = "GET_INVALID_REC" Then %>                       
				                   <tr><td class="clsLabelFB" align=center colspan=8 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr>                                                     
				                 <%Else
										 For i = objSelection.ListLower("RETRIEVE_INVALIDS") to objSelection.ListUpper("RETRIEVE_INVALIDS")%>                       
											<tr>									
											   <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("RETRIEVE_INVALIDS",i)%></nobr></td>
											   <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("RETRIEVE_INVALIDS",i)%></nobr></td>
											   <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue04("RETRIEVE_INVALIDS",i)%></nobr></td>
											   <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue06("RETRIEVE_INVALIDS",i)%></nobr></td>                                                      
											</tr>
										<%Next
				                End If%>                                 
				                    
				               </table>                        
				              </div>
				            </nobr>
				            </td>
				         </tr>          
				         
		<% End Select %>
     </table>
   <input type="hidden" name="Mode" value="">
   <input type="hidden" name="bolDirAccess" value="<%=CStr(v_bolDirAccess)%>">
 
 
</form>
</body>
</html>
            
  
<%end sub%>
<!--#include file="../ics_std_code.inc"-->
