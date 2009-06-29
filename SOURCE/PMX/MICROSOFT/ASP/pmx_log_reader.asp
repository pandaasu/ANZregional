<%@ language = VBScript%>
<% option explicit %>
<%
'//////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                     //
'// Script  : ics_log_reader.asp                                 //
'// Author  : Paul Jacobs                                        //
'// Date    : July 2004                                          //
'// Text    : This script implements log reader functionality    //
'//										                                //
'//////////////////////////////////////////////////////////////////

   '//
   '// Declare the variables
   '//
   dim i
   dim strBase
   dim strTarget
   dim strStatus
   dim strReturn
   dim objForm
   dim objSecurity
   dim objSelection
   Dim objProcedure
	Dim strHeading 
	dim strQuery	
	Dim lngSize
	Dim bolStrList 
   Dim bolEndList
	
	Dim bolSessionEndList
	dim x
	dim v_sessionID
	dim v_log_lvl	
	Dim strStatement
	Dim v_jobType
	dim v_strPrimaryKeys
	Dim v_PKArray
	Dim v_LastListedSession		
	Dim v_MoreRequested
	
				
		
	'//
	'// Set initial variables
	'//
	lngSize = 100
	strTarget = "pmx_log_reader.asp"
   strHeading = "Log Reader"
	v_MoreRequested = false
	
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
   
   
	'//////////////////////////
	'// Process form routine //
	'//////////////////////////
	sub ProcessForm()
		'//
		'// Create the selection object
		'//
		set objSelection = Server.CreateObject("ICS_SELECTION.Object")
		set objSelection.Security = objSecurity
	
	
		v_log_lvl = objForm.Fields("LogLevel").Value
		If len(v_log_lvl) = 0 Then
			v_log_lvl = objForm.Fields("HidLogLevel").Value
		End If
		
		v_sessionID = objForm.Fields("SessionID").Value
		v_jobType	= objForm.Fields("JobType").Value
		
		'//
		'// 
		'//
		If Not Instr(1, v_sessionID, "|") = 0 Then
			v_MoreRequested = true
		Else 
			v_MoreRequested = objForm.Fields("MoreRequested").Value
		End If	
		
		Select Case objForm.Fields("Mode").Value
			Case "SEARCH"
				'//
				'// If statement used to determine if search is being performed to simply bring back
				'// more records or actually retrieve all records for a specified session.
				'//
				If Instr(1, v_sessionID, "|") = 0 Then
					strQuery = "SELECT JOB_TYPE_DESC, DATA_TYPE, SORT_FIELD, LOG_TEXT, LOG_LUPDT, SESSION_ID, LOG_LEVEL, LOG_SEQ"
					strQuery = strQuery & " FROM PDS_LOG, PDS_JOB_TYPE"
					strQuery = strQuery & " WHERE PDS_LOG.SESSION_ID = " & v_sessionID
					strQuery = strQuery & " AND PDS_LOG.JOB_TYPE_CODE = PDS_JOB_TYPE.JOB_TYPE_CODE"	
					strQuery = strQuery & " ORDER BY PDS_LOG.LOG_SEQ"				
					
					strReturn = objSelection.Execute("LIST", strQuery, lngSize)						
				Else
					'// Get records to populate table based on Job Type		
					strQuery = "SELECT  JOB_TYPE_DESC, DATA_TYPE, SORT_FIELD, LOG_TEXT, LOG_LUPDT, SESSION_ID, LOG_LEVEL, LOG_SEQ"
					strQuery = strQuery & " FROM PDS_LOG, PDS_JOB_TYPE"			
					strQuery = strQuery & " WHERE PDS_LOG.JOB_TYPE_CODE = PDS_JOB_TYPE.JOB_TYPE_CODE"				
				
					strReturn = objSelection.Execute("LIST", strQuery, lngSize)		
				End If						
												
				if strReturn <> "*OK" then
					exit sub
				end if
								
			Case "NEXT"
				'//
				'// Create the selection object
				'//				
				set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
				set objProcedure.Security = objSecurity		
								
				v_PKArray = Split(objForm.Fields("HidLOG_HIGH").Value,"|")
			
				strQuery = "SELECT JOB_TYPE_DESC, DATA_TYPE, SORT_FIELD, LOG_TEXT, LOG_LUPDT, SESSION_ID, LOG_LEVEL, LOG_SEQ"
				strQuery = strQuery & " FROM PDS_LOG, PDS_JOB_TYPE"
				strQuery = strQuery & " WHERE SESSION_ID = " & v_sessionID
				strQuery = strQuery & " AND PDS_LOG.JOB_TYPE_CODE = " & v_jobType				
				strQuery = strQuery & " AND PDS_LOG.LOG_SEQ > " & v_PKArray(1)				
				strQuery = strQuery & " AND PDS_LOG.JOB_TYPE_CODE = PDS_JOB_TYPE.JOB_TYPE_CODE"	
				strQuery = strQuery & " ORDER BY PDS_LOG.LOG_SEQ ASC"
				'Response.Write strQuery
				strReturn = objSelection.Execute("LIST", strQuery, lngSize)	
					
				v_LastListedSession = objForm.Fields("LastListedSession").Value
			Case "PREVIOUS"
				'//
				'// Create the selection object
				'//				
				set objProcedure = Server.CreateObject("ICS_PROCEDURE.Object")
				set objProcedure.Security = objSecurity		
								
				v_PKArray = Split(objForm.Fields("HidLOG_LOW").Value,"|")
			
				strQuery = "SELECT JOB_TYPE_DESC, DATA_TYPE, SORT_FIELD, LOG_TEXT, LOG_LUPDT, SESSION_ID, LOG_LEVEL, LOG_SEQ"
				strQuery = strQuery & " FROM PDS_LOG, PDS_JOB_TYPE"
				strQuery = strQuery & " WHERE SESSION_ID = " & v_sessionID
				strQuery = strQuery & " AND PDS_LOG.JOB_TYPE_CODE = " & v_jobType				
				strQuery = strQuery & " AND PDS_LOG.LOG_SEQ < " & v_PKArray(1)
				strQuery = strQuery & " AND PDS_LOG.JOB_TYPE_CODE = PDS_JOB_TYPE.JOB_TYPE_CODE"	
				strQuery = strQuery & " ORDER BY PDS_LOG.LOG_SEQ DESC"
				'Response.Write strQuery			
				v_LastListedSession = objForm.Fields("LastListedSession").Value
				
				strReturn = objSelection.Execute("LIST", strQuery, lngSize)		
								
			Case Else			
	
				'// Get records for drop down list			
				strQuery = "SELECT  JOB_TYPE_DESC, DATA_TYPE, SORT_FIELD, LOG_TEXT, LOG_LUPDT, SESSION_ID, LOG_LEVEL, LOG_SEQ"
				strQuery = strQuery & " FROM PDS_LOG, PDS_JOB_TYPE"			
				strQuery = strQuery & " WHERE PDS_LOG.JOB_TYPE_CODE = PDS_JOB_TYPE.JOB_TYPE_CODE"	
				strQuery = strQuery & " AND PDS_LOG.JOB_TYPE_CODE = NULL"			
				
				strReturn = objSelection.Execute("LIST", strQuery, lngSize)		
				

		End Select
		
		'strReturn = objSelection.Execute("LIST", strQuery, lngSize)	
				
		'// Distinct list of job types
		strQuery = " SELECT DISTINCT JOB_TYPE_CODE, JOB_TYPE_DESC"
		strQuery = strQuery &  "   FROM PDS_JOB_TYPE"

		strReturn = objSelection.Execute("JOBTYPE", strQuery, lngSize)	

		
		'//
		'// If statement ensure the session ID list is populated with the appropriate numbers
		'// if 
		'//		 
		If v_MoreRequested = "True" Then				
			strQuery = " SELECT DISTINCT SESSION_ID"
			strQuery = strQuery &  " FROM PDS_LOG"
			strQuery = strQuery &  " WHERE JOB_TYPE_CODE = " & objForm.Fields("JobType").Value
			strQuery = strQuery &  " AND SESSION_ID < " & objForm.Fields("LastListedSession").Value
			strQuery = strQuery &  " ORDER BY SESSION_ID DESC"
	
			strReturn = objSelection.Execute("SESSIONID", strQuery, lngSize)	
								
			v_LastListedSession = objSelection.ListValue01("SESSIONID", objSelection.ListCount("SESSIONID") - 1)
		Else				
			strQuery = " SELECT DISTINCT SESSION_ID"
			strQuery = strQuery &  " FROM PDS_LOG"
			If len(objForm.Fields("JobType").Value) = 0 Then
				'// Used to populate SessionID list with nothing, so nothing is seen in the list
				'// before the user selects a jobType 
				strQuery = strQuery &  " WHERE JOB_TYPE_CODE = NULL"				
			Else
				strQuery = strQuery &  " WHERE JOB_TYPE_CODE = " & objForm.Fields("JobType").Value
			End If 
			strQuery = strQuery &  " ORDER BY SESSION_ID DESC"

			strReturn = objSelection.Execute("SESSIONID", strQuery, lngSize)		

			v_LastListedSession = objSelection.ListValue01("SESSIONID", objSelection.ListCount("SESSIONID") - 1)
									
		End If						
								

			
		if strReturn <> "*OK" then
			exit sub
		end if
			
				
		'//
		'// Set the list start and end indicators
		'//
		bolStrList = true
		bolEndList = true
		if objSelection.ListCount("LIST") <> 0 then
		   select case objForm.Fields("Mode").Value
		      case "SEARCH"
		         bolStrList = true
		         if objSelection.ListMore("LIST") = true then
		            bolEndList = false
		         end if
		      case "PREVIOUS"
		         if objSelection.ListMore("LIST") = true then
		            bolStrList = false
		         end if
		         bolEndList = false
		      case "NEXT"
		         bolStrList = false
		         if objSelection.ListMore("LIST") = true then
		            bolEndList = false
		         end if
		   end select
		end if
		
		
		'//
		'// Set the Session list for indicator if there are more session available
		'//
		bolSessionEndList = false
		if objSelection.ListCount("SESSIONID") <> 0 then
			If objSelection.ListMore("SESSIONID") = true then
				bolSessionEndList = True
			end if		   
		end if
		         
		end sub
		    
  
 
'///////////////////
'// Fatal routine //
'///////////////////
sub PaintFatal()%>
<!--#include file="../ics_fatal.inc"-->
<%end sub

'//////////////////////////
'// Paint form routine //
'//////////////////////////
sub PaintForm()
%>
<html>
<script language="javascript">
<!--
   function document.onmouseover() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButton') {
         objElement.className = 'clsButtonX';
      }
      if (objElement.className == 'clsSelect') {
         objElement.className = 'clsSelectX';
      }
   }
   function document.onmouseout() {
      var objElement = window.event.srcElement;
      if (objElement.className == 'clsButtonX') {
         objElement.className = 'clsButton';
      }
      if (objElement.className == 'clsSelectX') {
         objElement.className = 'clsSelect';
      }
   }
   
   
   function doSearch() {
		objSelectSessionID = document.main.SessionID;
			
		var x=document.getElementById("SessionID")
	
		if(objSelectSessionID.options[objSelectSessionID.selectedIndex].value !== 'more|'){
			document.main.LastListedSession.value = '<%=objForm.Fields("LastListedSession").Value%>' 			 
		}		
		
		objSelect = document.main.JobType;
	
		if((objSelect.options[objSelect.selectedIndex].value == 'X') || (objSelectSessionID.options[objSelectSessionID.selectedIndex].value == 'X')) {
			alert("You must select both a Job Type & a Session ID From the lists above")
		}
		else {
      document.main.action =  '<%=strBase%><%=strTarget%>';    
      document.main.Mode.value = 'SEARCH';
      document.main.submit();
      }
   }
   
   
   function getSessions(objSelect){
   	if(objSelect.options[objSelect.selectedIndex].value == 'X'){
			alert("You must select a Job Type From the list")
			}
		else {
			document.main.action =  '<%=strBase%><%=strTarget%>'; 
			document.main.submit();
		}
   }
   
   function doPrevious() {
      document.main.action =  '<%=strBase%><%=strTarget%>';          
      document.main.Mode.value = 'PREVIOUS';
      document.main.submit();
   }
   function doNext() {
      document.main.action =  '<%=strBase%><%=strTarget%>';    
      document.main.Mode.value = 'NEXT';      
      document.main.submit();
   }
   
    
// -->
</script>
<!--#include file="../ics_std_scrollable.inc"-->


<head>
   <meta http-equiv="content-type" content="text/html">
   <link rel="stylesheet" type="text/css" href="../ics_style.css">
</head>
 <body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('/ics_int_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal');">
 <form name="main" action="<%=strBase%><%=strTarget%>" method="post">
 
   <table class="clsGrid02" align=center valign=top cols=2 height=100% width=100% cellpadding="1" cellspacing="0">
     	<tr>				 
			<td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Job Type:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left colspan=1 nowrap width=><nobr>
			<select class="clsInputBN" name="JobType" onChange="getSessions(this);" maxlength="25">
               <option value="X"<%if v_jobType = "" then%> selected<%end if%>><---- Job Type Identification ----></OPTION><%for i = 0 to objSelection.ListCount("JOBTYPE") - 1%>
               <option value="<%=objSelection.ListValue01("JOBTYPE",i)%>" <%If v_jobType = objSelection.ListValue01("JOBTYPE",i) Then%> selected <%End If%>><%= objSelection.ListValue02("JOBTYPE",i)%></OPTION><%next%>              
          </select>            
         </nobr></td>
			</td>		
			</tr>
			
		<tr>
			<td class="clsLabelBB" align=right colspan=1 nowrap><nobr>&nbsp;Session Identification:&nbsp;</nobr></td>
			<td class="clsLabelBN" align=left colspan=1 nowrap width=><nobr>
			<select class="clsInputBN" name="SessionID" onChange="doSearch();" maxlength="25">
               <option value="X"<%if v_sessionID = "" then%> selected<%end if%>>&nbsp;<---- Session Identification ----></OPTION><%for i = 0 to objSelection.ListCount("SESSIONID") - 1%>
               <option value="<%=objSelection.ListValue01("SESSIONID",i)%>" <%If v_sessionID = objSelection.ListValue01("SESSIONID",i) Then%> selected <%End If%>><%= objSelection.ListValue01("SESSIONID",i)%></OPTION><%next%>              
               <%If bolSessionEndList = true Then%><option value="more|"><---- List More Sessions ----></OPTION><%End If%>
          </select>             
         </nobr></td>
			</td>						       	       
      </tr>
     
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelUL" align=center colspan=2 nowrap><nobr>
           
			 <table class="clsTable01" align=center cols=1 cellpadding="0" cellspacing="0">
               <tr>             
               </tr>
            </table>           
         </nobr></td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>&nbsp;</td>
      </tr>
      <tr>
         <td class="clsLabelBB" align=center colspan=2 nowrap><nobr>
            <table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0">
               <tr><%if bolStrList = true then%>
                  <td align=left colspan=1 nowrap><nobr><font class="clsButtonD"><&nbsp;Prev&nbsp</font></nobr></td><%else%>
                  <td align=left colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPrevious();"><&nbsp;Prev&nbsp</a></nobr></td><%end if%>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbsp</font></nobr></td><%if bolEndList = true then%>
                  <td align=right colspan=1 nowrap><nobr><font class="clsButtonD">&nbspNext&nbsp></font></nobr></td><%else%>
                  <td align=right colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doNext();">&nbspNext&nbsp></a></nobr></td><%end if%>                                    
               </tr>
            </table>
         </nobr></td>
      </tr>
      <tr height=100% width="80%">
         <td align=center colspan=2 nowrap width="80%"><nobr>
            <table class="clsTableContainer" align=center cols=1 height=100% cellpadding="0" cellspacing="0">
               <tr>
                  <td align=center colspan=1 nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align=left cols=9 cellpadding="0" cellspacing="1">
                        <tr>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Log Level.&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Job Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Data Type&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Sort Field&nbsp;</nobr></td>
                           <td class="clsLabelHB" align=center colspan=1 nowrap><nobr>&nbsp;Log Text&nbsp;</nobr></td>
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
                     <table class="clsTableBody" id="tabBody" align=left cols=8 cellpadding="0" cellspacing="1"><%if objSelection.ListCount("LIST") = 0 then%>
                        <tr><td class="clsLabelFB" align=center colspan=8 nowrap><nobr>&nbsp;NO DETAIL FOUND&nbsp</nobr></td></tr><%else%>  <%if objForm.Fields("Mode").Value <> "PREVIOUS" then%>
                        <%for i = objSelection.ListLower("LIST") to objSelection.ListUpper("LIST")%>                       
                        <tr>									
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr>
                           <%for x = 0 to CInt(objSelection.ListValue07("LIST",i)) -1 
										Response.Write "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
                           Next                           
                           Response.Write objSelection.ListValue04("LIST",i)
                           %></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>                           
                        </tr><%next%><%else%><%for i = objSelection.ListUpper("LIST") to objSelection.ListLower("LIST") step -1%>
                        <tr>                        	
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue07("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue01("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue02("LIST",i)%></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue03("LIST",i)%></nobr></td>                      
                           <td class="clsLabelFN" align=left colspan=1 nowrap><nobr>
                            <%for x = 0 to CInt(objSelection.ListValue07("LIST",i)) -1 
										Response.Write "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
										Next                           
										Response.Write objSelection.ListValue04("LIST",i)
                           %></nobr></td>
                           <td class="clsLabelFN" align=center colspan=1 nowrap><nobr><%=objSelection.ListValue05("LIST",i)%></nobr></td>                                                                          
                        </tr>
                        <%next%><%end if%><%end if%>
                     </table>            
                    </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
   </table>
   <input type="hidden" name="Mode" value="">
   <input type="hidden" name="HidLogLevel" value="<%=v_log_lvl%>"> 
   <input type="hidden" name="LastListedSession" value="<%=v_LastListedSession%>"> 
   <input type="hidden" name="MoreRequested" value="<%=v_MoreRequested%>"> 
   <%If objForm.Fields("Mode").Value = "NEXT" OR objForm.Fields("Mode").Value = "SEARCH" Then %>
   <input type="hidden" name="HidLOG_LOW" value="<%=objSelection.ListValue06("LIST",objSelection.ListLower("LIST")) & "|" & objSelection.ListValue08("LIST",objSelection.ListLower("LIST")) %>">
   <input type="hidden" name="HidLOG_HIGH" value="<%=objSelection.ListValue06("LIST",objSelection.ListUpper("LIST")) & "|" & objSelection.ListValue08("LIST",objSelection.ListUpper("LIST")) %>">
   <%ELSE %>
    <input type="hidden" name="HidLOG_HIGH" value="<%=objSelection.ListValue06("LIST",objSelection.ListLower("LIST")) & "|" & objSelection.ListValue08("LIST",objSelection.ListLower("LIST")) %>">
   <input type="hidden" name="HidLOG_LOW" value="<%=objSelection.ListValue06("LIST",objSelection.ListUpper("LIST")) & "|" & objSelection.ListValue08("LIST",objSelection.ListUpper("LIST")) %>">
   <%End If%>
</form>
</body>
</html>
<%
end sub%>

<!--#include file="../ics_std_code.inc"-->
