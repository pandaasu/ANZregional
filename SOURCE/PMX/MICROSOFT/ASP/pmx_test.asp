<%@ Language=VBScript %>
<% option explicit %>
<%
'///////////////////////////////////////////////////////////////////
'// System  : ICS (Interface Control System)                      //
'// Script  : ods_local_matl_classn.asp                           //
'// Author  : Gerald Arnold                                       //
'// Date    : August 2004                                         //
'// Text    : This script provides maintenance of the Material to //
'//           Local Classifications.                              //
'///////////////////////////////////////////////////////////////////

  '//
  '// Declare the variables
  '//
  Dim strBase 'As String
  Dim strTarget 'As String
  Dim strStatus 'As String
  Dim strReturn 'As String
  Dim strQuery 'As String
  Dim strHeading 'As String 
  Dim objForm
  Dim objSecurity
  Dim objSelection
  Dim objProcedure
  Dim objModify
  Dim lngSize 'As Integer
  Dim i 'As Integer


  Dim v_MaterialCode
  Dim v_MaterialDesc
  Dim v_BusSegCode
  Dim v_BusSegDesc
  Dim v_BrandEssCode
  Dim v_BrandEssDesc
  Dim v_LocalClassTypeCode
  Dim v_LocalClassTypeDesc
  Dim v_LocalClassCode
  Dim v_LocalClassDesc
  Dim v_oldLocalClassTypeCode
  Dim v_Status
  Dim v_Mode
  Dim v_SubType
  Dim bolStrList
  Dim bolEndList
    
  '//
  '// Set initial variables
  '//
  lngSize = 50000
  strTarget = "ods_local_matl_classn.asp"
  strHeading = "Materials Local Classifications Maintenance"
  v_Mode = " "
  
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

    Select Case objForm.Fields("Mode")
      Case "MATERIAL"
        v_BusSegCode = objForm.Fields("BusSegCode").Value
        v_BrandEssCode = objForm.Fields("BrandEssCode").Value

        v_Mode = "MATERIAL"

        '// Get the materials for this Business Segment and Brand Essence
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   LTRIM(B.MATNR, 0),"
        strQuery = strQuery & "   A.MATL_DESC_EN"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   MATL_DIM    A,"
        strQuery = strQuery & "   SAP_MAT_HDR B"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   A.MATL_CODE = LTRIM(B.MATNR, 0)"

        If (v_BusSegCode <> "__") Then
          strQuery = strQuery & "   AND A.BUS_SGMNT_CODE = "
          strQuery = strQuery & v_BusSegCode
        Else
          strQuery = strQuery & "   AND A.BUS_SGMNT_CODE IS NULL"
        End If

        If (v_BrandEssCode <> "__") Then
          strQuery = strQuery & "   AND A.BRAND_ESSNC_CODE = "
          strQuery = strQuery & v_BrandEssCode
        Else
          strQuery = strQuery & "   AND A.BRAND_ESSNC_CODE IS NULL"
        End If
			
		 ' Response.Write  strQuery
	
        strReturn = objSelection.Execute("Material", strQuery, 0)
	
	
	
        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If

        '// Get the list of the Brand Essences
        If (len(v_BusSegCode) > 0) Then
          strQuery =            " SELECT DISTINCT"
          strQuery = strQuery & "   BUS_SGMNT_DESC,"
          strQuery = strQuery & "   NVL(BRAND_ESSNC_CODE, '__'),"
          strQuery = strQuery & "   NVL(BRAND_ESSNC_DESC, 'UNCLASSIFIED')"
          strQuery = strQuery & " FROM"
          strQuery = strQuery & "   MATL_DIM"
          strQuery = strQuery & " WHERE"
          If (v_BusSegCode <> "__") Then
            strQuery = strQuery & "   BUS_SGMNT_CODE = "
            strQuery = strQuery & v_BusSegCode
          Else
            strQuery = strQuery & "   BUS_SGMNT_CODE IS NULL"
          End If

          strReturn = objSelection.Execute("BrandEss", strQuery, 0)

          If strReturn <> "*OK" Then
            call PaintFatal
            exit sub
          End If
        End If

        '// Get the list of the Business Segments
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   SUBSTR(F.z_data, 4, 2),"
        strQuery = strQuery & "   NVL(SUBSTR(F.z_data, 18, 30), 'UNCLASSIFIED')"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   sap_cla_chr E,"
        strQuery = strQuery & "   sap_ref_dat F"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   E.atnam = 'CLFFERT01'"
        strQuery = strQuery & "   AND F.z_tabname = '/MARS/MD_CHC001'"
        strQuery = strQuery & "   AND E.atwrt = substr(F.z_data , 4, 2)"
        strQuery = strQuery & " UNION"
        strQuery = strQuery & " SELECT"
        strQuery = strQuery & "   '__',"
        strQuery = strQuery & "   'UNCLASSIFIED'"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   DUAL"

        strReturn = objSelection.Execute("BusSeg", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If



      Case "MATERIALLINK"
        v_BusSegCode = objForm.Fields("BusSegCode").Value
        v_BrandEssCode = objForm.Fields("BrandEssCode").Value
        v_MaterialCode = objForm.Fields("MaterialCode").Value
'	Response.Write  v_BusSegCode & " " & v_BrandEssCode & " " & v_MaterialCode
        v_Mode = "MATERIALLINK"

        '// Get the description of the material
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   MATL_DESC_EN"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   MATL_DIM A"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   MATL_CODE = "
        strQuery = strQuery & "   LTRIM('" & v_MaterialCode & "', '0')"

        strReturn = objSelection.Execute("temp", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If

        v_MaterialDesc = objSelection.ListValue01("temp", 0)

        '// Get the materials for this Business Segment and Brand Essence
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   LTRIM(B.MATNR,'0'),"
        strQuery = strQuery & "   A.MATL_DESC_EN"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   MATL_DIM    A,"
        strQuery = strQuery & "   SAP_MAT_HDR B"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   A.MATL_CODE = LTRIM(B.MATNR,'0')"

        If (v_BusSegCode <> "__") Then
          strQuery = strQuery & "   AND A.BUS_SGMNT_CODE = "
          strQuery = strQuery & v_BusSegCode
        Else
          strQuery = strQuery & "   AND A.BUS_SGMNT_CODE IS NULL"
        End If

        If (v_BrandEssCode <> "__") Then
          strQuery = strQuery & "   AND A.BRAND_ESSNC_CODE = "
          strQuery = strQuery & v_BrandEssCode
        Else
          strQuery = strQuery & "   AND A.BRAND_ESSNC_CODE IS NULL"
        End If

        strReturn = objSelection.Execute("Material", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If


        '// Get the description of the Business Segment
        If (len(v_BusSegCode) > 0 And v_BusSegCode <> "__") Then
          strQuery =            " SELECT DISTINCT"
          strQuery = strQuery & "  NVL( BUS_SGMNT_DESC, 'UNCLASSIFIED') AS BUS_SGMNT_DESC "
          strQuery = strQuery & " FROM"
          strQuery = strQuery & "   MATL_DIM"
          strQuery = strQuery & " WHERE"
          strQuery = strQuery & "   BUS_SGMNT_CODE = "
          strQuery = strQuery & v_BusSegCode
          
          strReturn = objSelection.Execute("BusSeg", strQuery, 0)

          If strReturn <> "*OK" Then
            call PaintFatal
            exit sub
          End If

          v_BusSegDesc = objSelection.ListValue01("BusSeg", 0)

        Else
          v_BusSegDesc = "UNCLASSIFIED"
        End If

        '// Get the description of the Brand Essence
        If (len(v_BrandEssCode) > 0 And v_BrandEssCode <> "__") Then
          strQuery =            " SELECT DISTINCT"
          strQuery = strQuery & "   NVL(BRAND_ESSNC_DESC, 'UNCLASSIFIED')"
          strQuery = strQuery & " FROM"
          strQuery = strQuery & "   MATL_DIM"
          strQuery = strQuery & " WHERE"
          strQuery = strQuery & "   BRAND_ESSNC_CODE = "
          strQuery = strQuery & v_BrandEssCode
          
        
          strReturn = objSelection.Execute("BrandEss", strQuery, 0)

          If strReturn <> "*OK" Then
            call PaintFatal
            exit sub
          End If

          v_BrandEssDesc = objSelection.ListValue01("BrandEss", 0)

        Else
          v_BrandEssDesc = "UNCLASSIFIED"
        End If

        '// Get all of the relevant links that this material has to
        '// the local classifications
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   A.LOCAL_CLASSN_TYPE_CODE,"
        strQuery = strQuery & "   B.LOCAL_CLASSN_TYPE_DESC,"
        strQuery = strQuery & "   A.LOCAL_CLASSN_CODE,"
        strQuery = strQuery & "   C.LOCAL_CLASSN_DESC,"
        strQuery = strQuery & "   A.LOCAL_MATL_CLASSN_STATUS"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   LOCAL_MATL_CLASSN A,"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE B,"
        strQuery = strQuery & "   LOCAL_CLASSN      C"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   A.LOCAL_CLASSN_TYPE_CODE = B.LOCAL_CLASSN_TYPE_CODE"
        strQuery = strQuery & "   AND A.LOCAL_CLASSN_CODE = C.LOCAL_CLASSN_CODE"
        strQuery = strQuery & "   AND A.LOCAL_CLASSN_TYPE_CODE = C.LOCAL_CLASSN_TYPE_CODE "
        strQuery = strQuery & "   AND LTRIM(MATL_CODE, 0) = "
        strQuery = strQuery & "   '" & v_MaterialCode & "'"

        strReturn = objSelection.Execute("MatlToLocal", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If
		
		'//
		'// Used for when the user enters a Material number
		'//
		Case "MATNO"
        v_BusSegCode = objForm.Fields("BusSegCode").Value
        v_BrandEssCode = objForm.Fields("BrandEssCode").Value
        v_MaterialCode = Trim(objForm.Fields("MatNo").Value)
   

        '// Get the description of the material
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   MATL_DESC_EN"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   MATL_DIM A"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   MATL_CODE = "
        strQuery = strQuery & "   LTRIM('" & v_MaterialCode & "', '0')"

        strReturn = objSelection.Execute("temp", strQuery, 0)

		  If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If


		'//
		'// Only Produce the following page, if a record is found matching the entered
		'// material number
		'//
		If Not CInt(objSelection.ListCount("temp")) = 0 Then
		  v_Mode = "MATERIALLINK"		      	
      	
        v_MaterialDesc = objSelection.ListValue01("temp", 0)

        '// Get the materials for this Business Segment and Brand Essence
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   LTRIM(B.MATNR,'0'),"
        strQuery = strQuery & "   A.MATL_DESC_EN"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   MATL_DIM    A,"
        strQuery = strQuery & "   SAP_MAT_HDR B"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   A.MATL_CODE = LTRIM(B.MATNR,'0')"
        strQuery = strQuery & "   AND LTRIM(B.MATNR,'0') =  LTRIM('" & v_MaterialCode & "', '0')"
    
        strReturn = objSelection.Execute("Material", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If
        
               
          strQuery =            " SELECT DISTINCT"
          strQuery = strQuery & "  NVL( BUS_SGMNT_DESC, 'UNCLASSIFIED') AS BUS_SGMNT_DESC, BUS_SGMNT_CODE "
          strQuery = strQuery & " FROM"
          strQuery = strQuery & "   MATL_DIM"
          strQuery = strQuery & " WHERE"
          strQuery = strQuery & " LTRIM(MATL_CODE,'0') = "
          strQuery = strQuery & " LTRIM('" & v_MaterialCode & "', '0')"
          
          strReturn = objSelection.Execute("BusSeg", strQuery, 0)

          If strReturn <> "*OK" Then
            call PaintFatal
            exit sub
          End If

          v_BusSegDesc = objSelection.ListValue01("BusSeg", 0)

          strQuery =            " SELECT DISTINCT"
          strQuery = strQuery & "   NVL(BRAND_ESSNC_DESC, 'UNCLASSIFIED'), BRAND_ESSNC_CODE"
          strQuery = strQuery & " FROM"
          strQuery = strQuery & "   MATL_DIM"
          strQuery = strQuery & " WHERE"
          strQuery = strQuery & "   MATL_CODE = "
          strQuery = strQuery & " LTRIM('" & v_MaterialCode & "', '0')"
          
        
          strReturn = objSelection.Execute("BrandEss", strQuery, 0)

          If strReturn <> "*OK" Then
            call PaintFatal
            exit sub
          End If

          v_BrandEssDesc = objSelection.ListValue01("BrandEss", 0)


        '// Get all of the relevant links that this material has to
        '// the local classifications
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   A.LOCAL_CLASSN_TYPE_CODE,"
        strQuery = strQuery & "   B.LOCAL_CLASSN_TYPE_DESC,"
        strQuery = strQuery & "   A.LOCAL_CLASSN_CODE,"
        strQuery = strQuery & "   C.LOCAL_CLASSN_DESC,"
        strQuery = strQuery & "   A.LOCAL_MATL_CLASSN_STATUS"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   LOCAL_MATL_CLASSN A,"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE B,"
        strQuery = strQuery & "   LOCAL_CLASSN      C"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   A.LOCAL_CLASSN_TYPE_CODE = B.LOCAL_CLASSN_TYPE_CODE"
        strQuery = strQuery & "   AND A.LOCAL_CLASSN_CODE = C.LOCAL_CLASSN_CODE"
        strQuery = strQuery & "   AND A.LOCAL_CLASSN_TYPE_CODE = C.LOCAL_CLASSN_TYPE_CODE "
        strQuery = strQuery & "   AND LTRIM(MATL_CODE, 0) = "
        strQuery = strQuery & " LTRIM('" & v_MaterialCode & "', '0')"

        strReturn = objSelection.Execute("MatlToLocal", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If
        
        v_BusSegCode = Trim(objSelection.ListValue02("BusSeg", 0))
        v_BrandEssCode = Trim(objSelection.ListValue02("BrandEss", 0))
        
		'// If no records were found matching the Material Number entered.
		Else
		
		 v_Mode = "NoMatNoFound"		
		End if '// End If for ListCount = 0		

      Case "ALTER"
        v_SubType =  objForm.Fields("SubType").Value
        v_BusSegCode = objForm.Fields("BusSegCode").Value
        v_BusSegDesc = objForm.Fields("BusSegDesc").Value
        v_BrandEssCode = objForm.Fields("BrandEssCode").Value
        v_BrandEssDesc = objForm.Fields("BrandEssDesc").Value
        v_MaterialCode = objForm.Fields("MaterialCode").Value
        v_LocalClassTypeCode = objForm.Fields("LocalClassTypeCode").Value
		
		
		  If Instr(CStr(v_LocalClassTypeCode), "|") > 0 Then
		  	 dim arrClassifications		
		    arrClassifications = split(objForm.Fields("LocalClassTypeCode").Value, "|")
		    v_LocalClassTypeCode = arrClassifications(0)
		    v_LocalClassCode = arrClassifications(1)
		  Else
			 v_LocalClassCode = 0
			 v_oldLocalClassTypeCode = objForm.Fields("oldLocalClassTypeCode").Value
		  End If
		  
		  
	
        If v_SubType = "NEW" Then
          v_Mode = "NEW"
        Else
          v_Mode = "EDIT"         
          v_oldLocalClassTypeCode = objForm.Fields("oldLocalClassTypeCode").Value
          If len(v_oldLocalClassTypeCode) = 0 Or v_oldLocalClassTypeCode = " " Then
	           v_oldLocalClassTypeCode = v_LocalClassTypeCode   
          End If
        End If

        '// Get the description of the material
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   MATL_DESC_EN"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   MATL_DIM"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   MATL_CODE = "
        strQuery = strQuery & "   LTRIM('" & v_MaterialCode & "', '0')"

        strReturn = objSelection.Execute("Material", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If

        v_MaterialDesc = objSelection.ListValue01("Material", 0)


        '// Get the list of the Local Classifiction Types
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE_CODE,"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE_DESC"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE"
       

        strReturn = objSelection.Execute("LocalClassType", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If


        '// Get the list of the Local Classifiction for the
        '// Local Classification Types
        If len(v_LocalClassTypeCode) > 0 And v_LocalClassTypeCode <> "X" Then
          strQuery =            " SELECT DISTINCT"
          strQuery = strQuery & "   LOCAL_CLASSN_CODE,"
          strQuery = strQuery & "   LOCAL_CLASSN_DESC"
          strQuery = strQuery & " FROM"
          strQuery = strQuery & "   LOCAL_CLASSN"
          strQuery = strQuery & " WHERE"
          strQuery = strQuery & "   LOCAL_CLASSN_TYPE_CODE = "
          strQuery = strQuery & v_LocalClassTypeCode
          strQuery = strQuery & "  AND TRIM(LOCAL_CLASSN_STATUS) = 'ACTIVE'"

          strReturn = objSelection.Execute("LocalClass", strQuery, 0)

          If strReturn <> "*OK" Then
            call PaintFatal
            exit sub
          End If

    '      v_LocalClassCode = objSelection.ListValue01("LocalClass", 0)
            
        End If


        '// Get the current status of this link
        If len(v_LocalClassTypeCode) > 0 And v_LocalClassTypeCode <> "X" Then
          strQuery =            " SELECT"
          strQuery = strQuery & "   LOCAL_MATL_CLASSN_STATUS"
          strQuery = strQuery & " FROM"
          strQuery = strQuery & "   LOCAL_MATL_CLASSN A"
          strQuery = strQuery & " WHERE"
          strQuery = strQuery & "   A.LOCAL_CLASSN_TYPE_CODE = "
          strQuery = strQuery & "   " & v_LocalClassTypeCode
          strQuery = strQuery & "   AND LTRIM(MATL_CODE, 0) = "
          strQuery = strQuery & "   '" & v_MaterialCode & "'"

          strReturn = objSelection.Execute("Status", strQuery, 0)

          If strReturn <> "*OK" Then
            call PaintFatal
            exit sub
          End If

          v_Status = objSelection.ListValue01("Status", 0)
        End If



        '// Get all of the relevant links that this material has to
        '// the local classifications
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   A.LOCAL_CLASSN_TYPE_CODE,"
        strQuery = strQuery & "   B.LOCAL_CLASSN_TYPE_DESC,"
        strQuery = strQuery & "   A.LOCAL_CLASSN_CODE,"
        strQuery = strQuery & "   C.LOCAL_CLASSN_DESC,"
        strQuery = strQuery & "   A.LOCAL_MATL_CLASSN_STATUS"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   LOCAL_MATL_CLASSN A,"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE B,"
        strQuery = strQuery & "   LOCAL_CLASSN      C"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   A.LOCAL_CLASSN_TYPE_CODE = B.LOCAL_CLASSN_TYPE_CODE"
        strQuery = strQuery & "   AND A.LOCAL_CLASSN_CODE = C.LOCAL_CLASSN_CODE"
        strQuery = strQuery & "   AND A.LOCAL_CLASSN_TYPE_CODE = C.LOCAL_CLASSN_TYPE_CODE "
        strQuery = strQuery & "   AND LTRIM(MATL_CODE, 0) = "
        strQuery = strQuery & "   '" & v_MaterialCode & "'"

        strReturn = objSelection.Execute("MatlToLocal", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If


      Case "INSERT"
        v_BusSegCode = objForm.Fields("BusSegCode").Value
        v_BusSegDesc = objForm.Fields("BusSegDesc").Value
        v_BrandEssCode = objForm.Fields("BrandEssCode").Value
        v_BrandEssDesc = objForm.Fields("BrandEssDesc").Value
        v_MaterialCode = objForm.Fields("MaterialCode").Value
        v_MaterialDesc = objForm.Fields("MaterialDesc").Value
        v_LocalClassTypeCode = objForm.Fields("LocalClassTypeCode").Value
        v_LocalClassCode = objForm.Fields("LocalClassCode").Value

        v_Mode = "INSERT"


        '// Get the Description of the Local Classification Types
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE_DESC"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE_CODE = "
        strQuery = strQuery & v_LocalClassTypeCode

        strReturn = objSelection.Execute("LocalClassType", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If

        v_LocalClassTypeDesc = objSelection.ListValue01("LocalClassType", 0)


        '// Get the Description of the Local Classifiction
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   LOCAL_CLASSN_DESC"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   LOCAL_CLASSN"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE_CODE = "
        strQuery = strQuery & v_LocalClassTypeCode
        strQuery = strQuery & "   AND LOCAL_CLASSN_CODE = "
        strQuery = strQuery & v_LocalClassCode

        strReturn = objSelection.Execute("LocalClass", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If

        v_LocalClassDesc = objSelection.ListValue01("LocalClass", 0)


        '// Insert this link
        strQuery =            " INSERT INTO"
        strQuery = strQuery & "   LOCAL_MATL_CLASSN"
        strQuery = strQuery & "   ("
        strQuery = strQuery & "   MATL_CODE,"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE_CODE,"
        strQuery = strQuery & "   LOCAL_CLASSN_CODE,"
        strQuery = strQuery & "   LOCAL_MATL_CLASSN_STATUS,"
        strQuery = strQuery & "   LOCAL_MATL_CLASSN_LUPDP,"
        strQuery = strQuery & "   LOCAL_MATL_CLASSN_LUPDT)"
        strQuery = strQuery & " VALUES"
        strQuery = strQuery & "   ("
        strQuery = strQuery & "   DECODE(SIGN(INSTR('1234567890', SUBSTR('" & v_MaterialCode & "', 1,1))), 1, SUBSTR('000000000000000000', 1, 18 - LENGTH('" & v_MaterialCode & "')) || '" & v_MaterialCode & "', '" & v_MaterialCode & "'),"
        strQuery = strQuery & "    " & v_LocalClassTypeCode & ","
        strQuery = strQuery & "    " & v_LocalClassCode & ","
        strQuery = strQuery & "   'ACTIVE',"
        strQuery = strQuery & "   null,"
        strQuery = strQuery & "   null)"

        strReturn = objModify.Execute(strQuery)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If


      Case "UPDATE"
        v_BusSegCode = objForm.Fields("BusSegCode").Value
        v_BusSegDesc = objForm.Fields("BusSegDesc").Value
        v_BrandEssCode = objForm.Fields("BrandEssCode").Value
        v_BrandEssDesc = objForm.Fields("BrandEssDesc").Value
        v_MaterialCode = objForm.Fields("MaterialCode").Value
        v_MaterialDesc = objForm.Fields("MaterialDesc").Value
        v_LocalClassTypeCode = objForm.Fields("LocalClassTypeCode").Value
        v_oldLocalClassTypeCode = objForm.Fields("oldLocalClassTypeCode").Value
        v_LocalClassCode = objForm.Fields("LocalClassCode").Value
        v_Status = objForm.Fields("Status").Value

        v_Mode = "UPDATE"


        '// Get the Description of the Local Classification Types
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE_DESC"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE_CODE = "
        strQuery = strQuery & v_LocalClassTypeCode

        strReturn = objSelection.Execute("LocalClassType", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If

        v_LocalClassTypeDesc = objSelection.ListValue01("LocalClassType", 0)


        '// Get the Description of the Local Classifiction
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   LOCAL_CLASSN_DESC"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   LOCAL_CLASSN"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE_CODE = "
        strQuery = strQuery & v_LocalClassTypeCode
        strQuery = strQuery & "   AND LOCAL_CLASSN_CODE = "
        strQuery = strQuery & v_LocalClassCode

        strReturn = objSelection.Execute("LocalClass", strQuery, 0)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If

        v_LocalClassDesc = objSelection.ListValue01("LocalClass", 0)


        '// Insert this link
        strQuery =            " UPDATE"
        strQuery = strQuery & "   LOCAL_MATL_CLASSN"
        strQuery = strQuery & " SET"
        strQuery = strQuery & "   MATL_CODE = DECODE(SIGN(INSTR('1234567890', SUBSTR('" & v_MaterialCode & "', 1,1))), 1, SUBSTR('000000000000000000', 1, 18 - LENGTH('" & v_MaterialCode & "')) || '" & v_MaterialCode & "', '" & v_MaterialCode & "'),"
      '  strQuery = strQuery & "   MATL_CODE = '" & v_MaterialCode & "',"
        strQuery = strQuery & "   LOCAL_CLASSN_TYPE_CODE = " & v_LocalClassTypeCode & ","
        strQuery = strQuery & "   LOCAL_CLASSN_CODE = " & v_LocalClassCode & ","
        strQuery = strQuery & "   LOCAL_MATL_CLASSN_STATUS = '" & v_Status & "',"
        strQuery = strQuery & "   LOCAL_MATL_CLASSN_LUPDP = null,"
        strQuery = strQuery & "   LOCAL_MATL_CLASSN_LUPDT = null"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   LTRIM(MATL_CODE, 0) = '" & v_MaterialCode & "'"
        strQuery = strQuery & "   AND LOCAL_CLASSN_TYPE_CODE = " & v_oldLocalClassTypeCode

        strReturn = objModify.Execute(strQuery)

        If strReturn <> "*OK" Then
          call PaintFatal
          exit sub
        End If
		
	 Case Else
        '// Get a list of the Brand Essences
        v_BusSegCode = objForm.Fields("BusSegCode").Value

        v_Mode = " "

        If (len(v_BusSegCode) > 0) Then
          strQuery =            " SELECT DISTINCT"
          strQuery = strQuery & "   BUS_SGMNT_DESC,"
          strQuery = strQuery & "   NVL(BRAND_ESSNC_CODE, '__'),"
          strQuery = strQuery & "   NVL(BRAND_ESSNC_DESC, 'UNCLASSIFIED')"
          strQuery = strQuery & " FROM"
          strQuery = strQuery & "   MATL_DIM"
          strQuery = strQuery & " WHERE"
          If (v_BusSegCode <> "__") Then
            strQuery = strQuery & "   BUS_SGMNT_CODE = "
            strQuery = strQuery & v_BusSegCode
          Else
            strQuery = strQuery & "   BUS_SGMNT_CODE IS NULL"
          End If

          strReturn = objSelection.Execute("BrandEss", strQuery, 0)

          If strReturn <> "*OK" Then
            call PaintFatal
            exit sub
          End If
        End If

        '// Get the list of Business Segements
        strQuery =            " SELECT DISTINCT"
        strQuery = strQuery & "   SUBSTR(F.z_data, 4, 2),"
        strQuery = strQuery & "   NVL(SUBSTR(F.z_data, 18, 30), 'UNCLASSIFIED')"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   sap_cla_chr E,"
        strQuery = strQuery & "   sap_ref_dat F"
        strQuery = strQuery & " WHERE"
        strQuery = strQuery & "   E.atnam = 'CLFFERT01'"
        strQuery = strQuery & "   AND F.z_tabname = '/MARS/MD_CHC001'"
        strQuery = strQuery & "   AND E.atwrt = substr(F.z_data , 4, 2)"
        strQuery = strQuery & " UNION"
        strQuery = strQuery & " SELECT"
        strQuery = strQuery & "   '__',"
        strQuery = strQuery & "   'UNCLASSIFIED'"
        strQuery = strQuery & " FROM"
        strQuery = strQuery & "   DUAL"

        strReturn = objSelection.Execute("BusSeg", strQuery, 0)

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


        // GA Code
        // Function to make sure a Business Segment was selected
        function checkSelectedBusSeg()
        {
          // Getting the row that was selected in the Business Segment Droplist
           var colBusSegCode = document.main.BusSegCode

          // Make sure that something was acutally selected
          if ((colBusSegCode.options[colBusSegCode.selectedIndex].value) == 'X')
          {
            alert('You must select a Business Segment to perform this operation')
            return false;
          }

          else
          {
            return true;
          }
        }


        // GA Code
        // Function to make sure a Brand Essence was selected
        function checkSelectedBrandEss()
        {
          // Getting the row that was selected in the Brand Essence Droplist
           var colBrandEssCode = document.main.BrandEssCode

          // Make sure that something was acutally selected
          if ((colBrandEssCode.options[colBrandEssCode.selectedIndex].value) == 'X')
          {
            alert('You must select a Brand Essence to perform this operation')
            return false;
          }

          else
          {
            return true;
          }
        }


        // GA Code
        // Function to make sure a Material was selected
        function checkSelectedMaterial()
        {
          // Make sure that something was acutally selected
          if (document.main.MaterialSelected.value != 1)
          {
            alert('You must select a Material to perform this operation')
            return false;
          }

          else
          {
            return true;
          }
        }


        // GA Code
        // Function to make sure a material was selected
        function checkSelectedDLMaterial()
        {
          // Make sure that something was acutally selected
          if ((document.main.MaterialCode.options[document.main.MaterialCode.selectedIndex].value) == 'X')
          {
            alert('You must select a Material to perform this operation')
            return false;
          }

          else
          {
            return true;
          }
        }


        // GA Code
        // Function to make sure Local Class. Type was selected
        function checkSelectedLocalClassType()
        {
          // Make sure that something was acutally selected
          if ((document.main.LocalClassTypeCode.options[document.main.LocalClassTypeCode.selectedIndex].value) == 'X')
          {
            alert('You must select a Local Classification Type to perform this operation')
            return false;
          }

          else
          {
            return true;
          }
        }


        // GA Code
        // Function to make sure Local Class. was selected
        function checkSelectedLocalClass()
        {
          // Make sure that something was acutally selected
          if ((document.main.LocalClassCode.options[document.main.LocalClassCode.selectedIndex].value) == 'X')
          {
            alert('You must select a Local Classification to perform this operation')
            return false;
          }

          else
          {
            return true;
          }
        }


        // GA Code
        // Function to make sure a Material to Local radio was selected
        function checkSelectedMaterialToLocal()
        {
          // Make sure that something was acutally selected
          if (document.main.MaterialToLocalSelected.value != 1)
          {
            alert('You must select a Local Classification Link to perform this operation')
            return false;
          }

          else
          {
            return true;
          }
        }
		
		
		  function doMatNo()
		  {		  
			 if((document.main.MatNo.value).length !== 0){
				document.main.action = '<%=strBase%><%=strTarget%>';		    
				document.main.Mode.value = 'MATNO';               
				document.main.submit();
			}
			else{
				alert("You Must Enter A Material Number To Search On")
			}
			
		  }

        function doBusSeg()
        {
          if (!checkSelectedBusSeg()) {return;}
          document.main.action = '<%=strBase%><%=strTarget%>';
          document.main.Mode.value = 'BRANDESS';     
          document.main.submit();
        }


        function doBrandEss()
        {
          if (!checkSelectedBrandEss()) {return;}
          document.main.action = '<%=strBase%><%=strTarget%>';
          document.main.Mode.value = 'MATERIAL';     
          document.main.submit();
        }


        function markSelected()
        {
          document.main.MaterialSelected.value = 1
        }


        function markSelectedMatlToLocal()
        {
          document.main.MaterialToLocalSelected.value = 1
        }


        function doMaterial()
        {
          if (!checkSelectedMaterial()) {return;}
          document.main.action = '<%=strBase%><%=strTarget%>';
          document.main.Mode.value = 'MATERIALLINK';     
          document.main.submit();
        }


        function doMaterial2()
        {
          if (!checkSelectedDLMaterial()) {return;}
          document.main.action = '<%=strBase%><%=strTarget%>';
          document.main.Mode.value = 'MATERIALLINK';     
          document.main.submit();
        }


        function doNew()
        {
          document.main.action = '<%=strBase%><%=strTarget%>';
          document.main.Mode.value = 'ALTER';
          document.main.SubType.value = 'NEW';
          document.main.submit();
        }


        function doInsert()
        {
			 if (!checkCurrentRec()) {return;}	
          if (!checkSelectedLocalClassType()) {return;}
          if (!checkSelectedLocalClass()) {return;}
          document.main.action = '<%=strBase%><%=strTarget%>';
          document.main.Mode.value = 'INSERT';
          document.main.submit();
        }


        function doReturn()
        {
          document.main.action = '<%=strBase%><%=strTarget%>';
          document.main.Mode.value = '';
          document.main.BusSegCode.value = null;
          document.main.BrandEssCode.value = null;
          document.main.submit();
        }


        function doEdit()
        {			
          if (!checkSelectedMaterialToLocal()) {return;}
          document.main.action = '<%=strBase%><%=strTarget%>';
          document.main.Mode.value = 'ALTER';
          document.main.SubType.value = 'EDIT';
          document.main.submit();
        }


        function doUpdate()
        {
			 if (!checkCurrentRecEdit()) {return;}	
          if (!checkSelectedLocalClassType) {return;}
          if (!checkSelectedLocalClass) {return;}
          document.main.action = '<%=strBase%><%=strTarget%>';
          document.main.Mode.value = 'UPDATE';   
          document.main.submit();
        }
        
        
        //
        // Written By Paul Jacobs
        // Used to ensure that any new entry is not the same as any pre-existing entry
        // and that only one Local Classification Type is set against any materials. See note on PK.
        //
        function checkCurrentRec()
        {
			// Declare variables
			var intNoInput;
         var colInput;
         var intIndex = 0;
         var objLocalClassTypeCode;
         var objLocalClassCode;
         var strLocalClassTypeCode;
         var strLocalClassCode;
         var strNewValue;
         var bolReturn;
         
         
         // Initialse variables
         colInput = document.all.tags("INPUT");          
         intNoInput = document.all.tags("INPUT").length;
         intIndex = 0;
         bolReturn = true;
         
         
         // Set string 
         objLocalClassTypeCode = document.main.LocalClassTypeCode         
         objLocalClassCode = document.main.LocalClassCode                  
         strLocalClassTypeCode = objLocalClassTypeCode.options[objLocalClassTypeCode.selectedIndex].value
         strLocalClassCode = objLocalClassCode.options[objLocalClassCode.selectedIndex].value    
			strNewValue =  strLocalClassTypeCode  + "/" + strLocalClassCode
        
         // 
         for (x = 0; x < intNoInput; x++) {						
				if(colInput[intIndex].name.substr(0,13) == 'ExistingClass'){
					// The PK on the table is Material number and local classification type code, therefore only one
					// local classification type can exist against one material. Following code is thus required...					
					if(colInput[intIndex].value.substr(0,1) == strLocalClassTypeCode){
						alert('The Local Classification Type selected is already linked to this material and only one local classification can be aligned against it. Please select a new Local Classification Type.')
						bolReturn = false
					}
					// Used to check for pre-existing entry the same as new entry. 	 				 
			/*		
					if(colInput[intIndex].value.match(strNewValue)){
						//alert('The selected Local Classification Type and Local Classification are already linked to this material. Please reselect.')
						bolReturn = false
					}	
					*/ 				 
				}
				intIndex++;
			}			 
			
          return bolReturn;
        } // End of function
      
		  
		  //
		  // and that only one Local Classification Type is set against any materials. See note on PK.
        //
        function checkCurrentRecEdit()
        {
			// Declare variables
			var intNoInput;
         var colInput;
         var intIndex = 0;
         var objLocalClassTypeCode;
         var objLocalClassCode;
         var strLocalClassTypeCode;
         var strLocalClassCode;
         var strNewValue;
         var bolReturn;
         
         
         // Initialse variables
         colInput = document.all.tags("INPUT");          
         intNoInput = document.all.tags("INPUT").length;
         intIndex = 0;
         bolReturn = true;
                  
         // Set string 
         objLocalClassTypeCode = document.main.LocalClassTypeCode         
         objLocalClassCode = document.main.LocalClassCode                  
         strLocalClassTypeCode = objLocalClassTypeCode.options[objLocalClassTypeCode.selectedIndex].value
         strLocalClassCode = objLocalClassCode.options[objLocalClassCode.selectedIndex].value    
			strNewValue =  strLocalClassTypeCode  + "/" + strLocalClassCode
         
               
         for (x = 0; x < intNoInput; x++) {						   
				if(colInput[intIndex].name.substr(0,13) == 'ExistingClass'){
				   	if(document.main.oldLocalClassTypeCode.value !== strLocalClassTypeCode ){									
						// The PK on the table is Material number and local classification type code, therefore only one
						// local classification type can exist against one material. Following code is thus required...					
						if(colInput[intIndex].value.substr(0,1) == strLocalClassTypeCode){
							alert('The Local Classification Type selected is already linked to this material and only one local classification can be aligned against it. Please select a new Local Classification Type.')
							bolReturn = false
						}
					}	
				
								
					// Used to check for pre-existing entry the same as new entry. 	 				 
					if(colInput[intIndex].value.match(strNewValue) && (document.main.oldStatus.value == document.main.Status.value)){
						alert('The selected Local Classification Type and Local Classification are already linked to this material. Please reselect.')
						bolReturn = false
					}	 				 
														
				} // End of IF for ExistingClass
				
				intIndex++;			
			}	// End of For Loop		 
			
          return bolReturn;
        } // End of function
      
      // -->
      </script>
		<!--#include file="../ics_std_scrollable.inc"-->
      <head>
        <meta http-equiv="content-type" content="text/html">
        <link rel="stylesheet" type="text/css" href="/ics_style.css">
      </head>




  <%If v_Mode = "MATERIAL" Then%> 
      <body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('/ics_int_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();setScrollable('Head','Body','horizontal')">
        <form name="main" action="<%=strBase%><%=strTarget%>" method="post">
  <table class="clsGrid02" align="center" valign="top" cols="2" height="100%" width="100%" cellpadding="1" cellspacing="0">
     <table class="clsGrid02" align="center" valign="top" cols="2" height="100%" width="100%" cellpadding="1" cellspacing="0">
     	<tr>
     	 <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Business Segment:&nbsp;</nobr></td>		
		 <td class="clsLabelBN" align="left" colspan="1" nowrap width><nobr>
			 <select class="clsInputBN" name="BusSegCode" onChange="javascript:doBusSeg();">
                  <option value="X"><----business Segment List----></option>
                  <%for i = 1 to objSelection.ListCount("BusSeg")%>
                    <option value="<%=objSelection.ListValue01("BusSeg", i - 1)%>" <%if (objSelection.ListValue01("BusSeg", i - 1) = v_BusSegCode) then%> selected <%end if%>><%= objSelection.ListValue02("BusSeg", i - 1)%></option>
                  <%next%> 
				</select>        
         </nobr>
			</td>		
		</tr>
			
		<tr>
		  <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Brand Essence:&nbsp;</nobr></td>			
			<td class="clsLabelBN" align="left" colspan="1" nowrap width><nobr>
			 <select class="clsInputBN" name="BrandEssCode" onChange="javascript:doBrandEss();">
                  <option value="X"><----brand Essence List----></option>
                  <%for i = 1 to objSelection.ListCount("BrandEss")%>
                    <option value="<%=objSelection.ListValue02("BrandEss", i - 1)%>" <%If objSelection.ListValue02("BrandEss", i - 1) = v_BrandEssCode Then%> selected <%End If%>><%= objSelection.ListValue03("BrandEss", i - 1)%></option>
                  <%next%> 
          </select>          
         </nobr>
			</td>						       	       
      </tr>
      
     <tr>
		  <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Material Number&nbsp;</nobr></td>			
		  <td class="clsLabelBN" align="left" colspan="1" nowrap width><nobr> 
		  <input type="text" id="MatNo" name="MatNo" size="18" Maxlength="18">
		  <img SRC="/CDW/images/gobutton.gif" onclick="javascript:doMatNo();" style="cursor:hand" WIDTH="32" HEIGHT="19">					                    
		  </td>	   
      </tr>
      
      <tr>
         <td class="clsLabelBB" align="center" colspan="2" nowrap><nobr>&nbsp;</td>
      </tr>
    
      <tr>
         <td class="clsLabelUL" align="center" colspan="2" nowrap><nobr>    
				<table class="clsTable01" align="center" cols="1" cellpadding="0" cellspacing="0">
               <tr>
						<td align="center" nowrap><nobr><a class="clsButton" href="javascript:doReturn();">&nbsp;&nbsp;&nbsp;&nbsp;Cancel&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                  <td align="center" colspan="1" nowrap><nobr><a class="clsButton" href="javascript:doMaterial();">&nbsp;&nbsp;&nbsp;&nbsp;Select&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
               </tr>
            </table>     	       
         </nobr>
         </td>
      </tr>
   
      
      <tr height="100%" width="80%">
         <td align="center" colspan="2" nowrap width="80%"><nobr>
         
            <table class="clsTableContainer" align="center" cols="1" height="100%" cellpadding="0" cellspacing="0">
               <tr>
                  <td align="center" colspan="1" nowrap><nobr>
                     <div class="clsFixed" id="conHead">
                     <table class="clsTableHead" id="tabHead" align="left" cols="9" cellpadding="0" cellspacing="1">
                        <tr>                         
								 <td class="clsLabelHB" align="center" colspan="1" nowrap><nobr>&nbsp;Material Code&nbsp;<nobr></td>
								 <td class="clsLabelHB" align="center" colspan="1" nowrap><nobr>&nbsp;Material Description&nbsp;<nobr></td>
								 <td class="clsLabelHB" align="center" colspan="1" nowrap><nobr>&nbsp;Select&nbsp;<nobr></td>
								 <td class="clsLabelHB" align="center" colspan="1" nowrap><nobr>&nbsp;</nobr></td>
								</tr>                 
                     </table>
                     </div>
                  </nobr>
                  </td>
               </tr>
               <tr height="100%">
                  <td align="center" colspan="1" nowrap><nobr>
                     <div class="clsScroll" id="conBody">
                     <table class="clsTableBody" id="tabBody" align="left" cols="8" cellpadding="0" cellspacing="1">
							 <%
                    if (objSelection.ListCount("Material") = 0) then
                    %>               
                      <tr>
                        <td class="clsLabelFB" align="center" colspan="3" nowrap><nobr>
                          &nbsp;NO MATERIALS FOUND&nbsp;
                        </nobr></td>
                      </tr>                    
               
                    <%
                    else                 
                      for i = 0 To objSelection.ListCount("Material") - 1
                    %>                   
                        <tr>
                          <td class="clsLabelFN" align="center" nowrap><nobr><%=objSelection.ListValue01("Material", i)%></nobr></td>
                          <td class="clsLabelFN" align="left" nowrap><nobr><%=objSelection.ListValue02("Material", i)%></nobr></td>
                          <td class="clsLabelFN" align="center" nowrap><nobr><input type="radio" name="MaterialCode" id="MaterialCode<%=i%>" value="<%=objSelection.ListValue01("MATERIAL", i)%>" onClick="markSelected();"></nobr></td> 
                        </tr>                    
                     
                    <%
                      next
                    end if
                    %>           
                     </table>            
                    </div>
                  </nobr></td>
               </tr>
            </table>
         </nobr></td>
      </tr>
            </table>
         </nobr></td>
      </tr>
   </table>



          <input type="hidden" name="Mode" value=" ">
          <input type="hidden" name="MaterialSelected" value="0">
        </form>
      </body>
    </html>




  <%ElseIf v_Mode = "MATERIALLINK" Then%>
      <body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('/ics_int_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();">
        <form name="main" action="<%=strBase%><%=strTarget%>" method="post"> 
          <table class="clsGrid02" align="center" valign="top" cols="2" cellpadding="1" cellspacing="0">
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Business Segment:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <input name="BusSegCode" type="hidden" value="<%=v_BusSegCode%>"><nobr>
                <input name="BusSegDesc" type="hidden" value="<%=v_BusSegDesc%>"><nobr>
                <%=v_BusSegDesc%>
              </nobr></td>
            </tr>
            <tr>
              <td>
               
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Brand Essence:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <input name="BrandEssCode" type="hidden" value="<%=v_BrandEssCode%>"><nobr>
                <input name="BrandEssDesc" type="hidden" value="<%=v_BrandEssDesc%>"><nobr>
                <%=v_BrandEssDesc%>
              </nobr></td>
            </tr>
            <tr>
              <td>
              
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Material:&nbsp;</b></nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                 <%for i = 1 to objSelection.ListCount("Material")%>
                   <%If objSelection.ListValue01("Material", i - 1) = v_MaterialCode Then%> <%= objSelection.ListValue01("Material", i - 1)%> - <%= objSelection.ListValue02("Material", i - 1)%>  <%End If%>
                <%next%>                            
					</nobr>              
              </td>
               <input class="clsInputBN" name="MaterialCode" type="hidden" value="<%=v_MaterialCode%>">   
            </tr>
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
          </table>
			
          <table class="clsGrid02" align="center" valign="top" cols="4" cellpadding="1" cellspacing="0">
            <tr align="center">
              <td align="center" colspan="4" nowrap><font SIZE="3" color="black"><u><b><p>Current Links</p></b></u></font><nobr>
                <div class="clsScroll" id="conBody">
                  <table class="clsTableBody" id="tabBody" align="left" cellpadding="0" cellspacing="1">
                    <tr>
                      <td class="clsLabelHB" align="center" nowrap>Local Classifiction Type Desc.<nobr></td>
                      <td class="clsLabelHB" align="center" nowrap>Local Classifiction Desc.<nobr></td>
                      <td class="clsLabelHB" align="center" nowrap>Status<nobr></td>
                      <td class="clsLabelHB" align="center" nowrap>Select<nobr></td>
                    </tr>
                    <%
                    if (objSelection.ListCount("MatlToLocal") = 0) then
                    %>
                      <tr>
                        <td class="clsLabelFB" align="center" colspan="4" nowrap><nobr>
                          &nbsp;NO LINKS TO THIS MATERIAL FOUND&nbsp;
                        </nobr></td>
                      </tr>
                    <%
                    else
                      for i = 0 To objSelection.ListCount("MatlToLocal") - 1
                    %>
                        <tr>
                          <td class="clsLabelFN" align="left" nowrap><nobr><%=objSelection.ListValue02("MatlToLocal", i)%></nobr></td>
                          <td class="clsLabelFN" align="left" nowrap><nobr><%=objSelection.ListValue04("MatlToLocal", i)%></nobr></td>
                          <td class="clsLabelFN" align="left" nowrap><nobr><%=objSelection.ListValue05("MatlToLocal", i)%></nobr></td>
                          <td class="clsLabelFN" align="center" nowrap><nobr><input type="radio" name="LocalClassTypeCode" id="LocalClassTypeCode<%=i%>" value="<%=objSelection.ListValue01("MatlToLocal", i) & "|" & objSelection.ListValue03("MatlToLocal", i)%>" onClick="markSelectedMatlToLocal();"></nobr></td> 
                        </tr>
                    <%
                      next
                    end if
                    %>
                  </table>            
                </div>
              </nobr></td>
            </tr>
          </table>

          <table class="clsGrid02" align="center" valign="top" cols="2" cellpadding="1" cellspacing="0">  
            <tr>
              <td class="clsLabelUL" align="center" colspan="2" nowrap><nobr>
                <table class="clsTable01" align="center" cols="1" cellpadding="0" cellspacing="0">
                  <tr>
                    <td align="center" nowrap><nobr><a class="clsButton" href="javascript:doReturn();">&nbsp;&nbsp;&nbsp;&nbsp;Cancel&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                    <td align="center" colspan="1" nowrap><nobr><a class="clsButton" href="javascript:doNew();">&nbsp;&nbsp;&nbsp;&nbsp;Create Link&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                    <td align="center" colspan="1" nowrap><nobr><a class="clsButton" href="javascript:doEdit();">&nbsp;&nbsp;&nbsp;&nbsp;Edit Link&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                  </tr>
                </table>
              </nobr></td>
            </tr>
          </table>

          <input type="hidden" name="Mode" value=" ">
          <input type="hidden" name="SubType" value=" ">
          <input type="hidden" name="MaterialToLocalSelected" value="0">
          <input type="hidden" name="oldLocalClassTypeCode" value=" ">
        </form>
      </body>
    </html>




  <%ElseIf v_Mode = "NEW" Or v_Mode = "EDIT" Then%>
      <body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('/ics_int_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();">
        <form name="main" action="<%=strBase%><%=strTarget%>" method="post">
 
          <table class="clsGrid02" align="center" valign="top" cols="2" cellpadding="1" cellspacing="0">
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
            <tr>
              <%
                if v_Mode = "NEW" then
              %>
                <td class="clsLabelBB" align="center" colspan="2" nowrap width="50%"><nobr><font SIZE="2"><b><u>&nbsp;New Link Creation&nbsp;</u></b></font></nobr></td>
              <%
                else
              %>
                <td class="clsLabelBB" align="center" colspan="2" nowrap width="50%"><nobr><font SIZE="2"><b><u>&nbsp;Alter Link&nbsp;</u></b></font></nobr></td>
              <%
                end if
              %>
            </tr>
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Business Segment:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <input name="BusSegCode" type="hidden" value="<%=v_BusSegCode%>"><nobr>
                <input name="BusSegDesc" type="hidden" value="<%=v_BusSegDesc%>"><nobr>
                <%=v_BusSegDesc%>
              </nobr></td>
            </tr>
            <tr>
              <td>
               
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Brand Essence:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <input name="BrandEssCode" type="hidden" value="<%=v_BrandEssCode%>"><nobr>
                <input name="BrandEssDesc" type="hidden" value="<%=v_BrandEssDesc%>"><nobr>
                <%=v_BrandEssDesc%>
              </nobr></td>
            </tr>
            <tr>
              <td>
               
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Material:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <input name="MaterialCode" type="hidden" value="<%=v_MaterialCode%>"><nobr>
                <input name="MaterialDesc" type="hidden" value="<%=v_MaterialDesc%>"><nobr>
                <%=v_MaterialCode & " - " & v_MaterialDesc%>
              </nobr></td>
            </tr>
            <tr>
              <td>
               
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Local Classification Type:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                  <%
                    if v_Mode = "NEW" then
                  %>
                  <select class="clsInputBN" name="LocalClassTypeCode" onChange="javascript:doNew();">
                    <option value="X"><----local Classifiction Type List----></option>
                  <%
                    else
                  %>
                  <select class="clsInputBN" name="LocalClassTypeCode" onChange="javascript:doEdit();">
                  <%
                    end If
                    for i = 1 to objSelection.ListCount("LocalClassType")
                  %>
                    <option value="<%=objSelection.ListValue01("LocalClassType", i - 1)%>" <%If objSelection.ListValue01("LocalClassType", i - 1) = v_LocalClassTypeCode Then%> selected <%End If%>><%= objSelection.ListValue02("LocalClassType", i - 1)%></option>
                  <%
                    next
                  %> 
                </select>
              </nobr></td>
            </tr>
            <tr>
              <td>
               
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Local Classification:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <select class="clsInputBN" name="LocalClassCode">
                  <%
                    if v_Mode = "NEW" then
                  %>
                    <option value="X"><----local Classifiction List----></option>
                  <%
                      for i = 1 to objSelection.ListCount("LocalClass")
                  %>
                        <option value="<%=objSelection.ListValue01("LocalClass", i - 1)%>"> <%= objSelection.ListValue02("LocalClass", i - 1)%></option>
                  <%
                      next
                    Else
                      for i = 1 to objSelection.ListCount("LocalClass")
                  %>
                        <option value="<%=objSelection.ListValue01("LocalClass", i - 1)%>" <%if objSelection.ListValue01("LocalClass", i - 1) = v_LocalClassCode then%> selected <%end if%>><%= objSelection.ListValue02("LocalClass", i - 1)%></option>
                  <%
                      next
                    end if
                  %> 
                </select>
              </nobr></td>
            </tr>
            <%
              if v_Mode = "EDIT" then
            %>
            <tr>
              <td>
               
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Link Status:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <select class="clsInputBN" name="Status">
                  <option value="ACTIVE" <%if v_Status = "ACTIVE" then%> selected <%end if%>>ACTIVE</option> 
                  <option value="INACTIVE" <%if v_Status = "INACTIVE" then%> selected <%end if%>>INACTIVE</option>
                </select>
              </nobr></td>
            </tr>
            <%
              end if
            %>
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
          </table>

          <table class="clsGrid02" align="center" valign="top" cols="2" cellpadding="1" cellspacing="0">  
            <tr>
              <td class="clsLabelUL" align="center" colspan="2" nowrap><nobr>
                <table class="clsTable01" align="center" cols="1" cellpadding="0" cellspacing="0">
                  <tr>
                    <td align="center" nowrap><nobr><a class="clsButton" href="javascript:doReturn();">&nbsp;&nbsp;&nbsp;&nbsp;Cancel&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                    <td align="center" nowrap><nobr><a class="clsButton" href="javascript:doMaterial();">&nbsp;&nbsp;&nbsp;&nbsp;Back&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                  <%
                    if v_Mode = "NEW" then
                  %>
                    <td align="center" colspan="1" nowrap><nobr><a class="clsButton" href="javascript:doInsert();">&nbsp;&nbsp;&nbsp;&nbsp;Create Link&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                  <%
                    else
                  %>
                    <td align="center" colspan="1" nowrap><nobr><a class="clsButton" href="javascript:doUpdate();">&nbsp;&nbsp;&nbsp;&nbsp;Alter Link&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                  <%
                    end if
                  %>
                  </tr>
                </table>
              </nobr></td>
            </tr>
          </table>

          <table class="clsGrid02" align="center" valign="top" cols="3" cellpadding="1" cellspacing="0">
            <tr align="center">
              <td align="center" colspan="3" nowrap><font SIZE="3" color="black"><u><b><p>Current Links</p></b></u></font><nobr>
                <div class="clsScroll" id="conBody">
                  <table class="clsTableBody" id="tabBody" align="left" cellpadding="0" cellspacing="1">
                    <tr>
                      <td class="clsLabelHB" align="center" nowrap>Local Classifiction Type Desc.<nobr></td>
                      <td class="clsLabelHB" align="center" nowrap>Local Classifiction Desc.<nobr></td>
                      <td class="clsLabelHB" align="center" nowrap>Status<nobr></td>
                    </tr>
                    <%
                    if (objSelection.ListCount("MatlToLocal") = 0) then
                    %>
                      <tr>
                        <td class="clsLabelFB" align="center" colspan="3" nowrap><nobr>
                          &nbsp;NO LINKS TO THIS MATERIAL FOUND&nbsp;
                        </nobr></td>
                      </tr>
                    <%
                    else
                      for i = 0 To objSelection.ListCount("MatlToLocal") - 1
                    %>
                        <tr>
                          <td class="clsLabelFN" align="left" nowrap><nobr><%=objSelection.ListValue02("MatlToLocal", i)%></nobr></td>
                          <td class="clsLabelFN" align="left" nowrap><nobr><%=objSelection.ListValue04("MatlToLocal", i)%></nobr></td>
                          <td class="clsLabelFN" align="left" nowrap><nobr><%=objSelection.ListValue05("MatlToLocal", i)%></nobr></td>
                        </tr>
                    <%
                      next
                    end if
                    %>
                  </table>            
                </div>
              </nobr></td>
            </tr>
          </table>
          
			<%for i = 0 To objSelection.ListCount("MatlToLocal") - 1 %>
				<input type="hidden" name="ExistingClass<%=i%>" value="<%=objSelection.ListValue01("MatlToLocal", i)& "/" & objSelection.ListValue03("MatlToLocal", i)%>">                       
         <%Next%>                 	
				
          <input type="hidden" name="Mode" value=" ">
          <input type="hidden" name="MaterialSelected" value="1">
          <%
            if v_Mode = "NEW" then
          %>
            <input type="hidden" name="SubType" value="NEW">
          <%
            else
          %>
            <input type="hidden" name="SubType" value="EDIT">
            <input type="hidden" name="oldLocalClassTypeCode" value="<%= v_oldLocalClassTypeCode%>">            
            <input type="hidden" name="oldLocalClassCode" value="<%=v_LocalClassCode%>">
            <input type="hidden" name="oldStatus" value="<%=v_status%>">            
            <input type="hidden" name="MaterialToLocalSelected" value="1">
          <%
            end if
          %>
        </form>
      </body>
    </html>




  <%ElseIf v_Mode = "INSERT" Or v_Mode = "UPDATE" Then%>
      <body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('/ics_int_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();">
        <form name="main" action="<%=strBase%><%=strTarget%>" method="post">
 
          <table class="clsGrid02" align="center" valign="top" cols="2" cellpadding="1" cellspacing="0">
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Material to Local Classification Link&nbsp;</nobr></td>
              <td class="clsLabelBB" align="left" colspan="1" nowrap width="50%"><nobr>
                <%
                  If v_Mode = "INSERT" Then
                %>
                  Created Successfully
                <%
                  Else
                %>
                  Updated Successfully
                <%
                  End If
                %>
              </nobr></td>
            </tr>
            <tr>
              <td>
               
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Business Segment:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr><input type="hidden" name="BusSegCode" value="<%=v_BusSegCode%>">
                <%=v_BusSegDesc%>
              </nobr></td>
            </tr>
            <tr>
              <td>
               
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Brand Essence:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr><input type="hidden" name="BrandEssCode" value="<%=v_BrandEssCode%>">
                <%=v_BrandEssDesc%>
              </nobr></td>
            </tr>
            <tr>
              <td>
               
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Material:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr><input type="hidden" name="MaterialCode" value="<%=v_MaterialCode%>">
                <%=v_MaterialDesc%>
              </nobr></td>
            </tr>
            <tr>
              <td>
              
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Local Classification Type:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <%=v_LocalClassTypeDesc%>
              </nobr></td>
            </tr>
            <tr>
              <td>
               
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Local Classification:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <%=v_LocalClassDesc%>
              </nobr></td>
            </tr>
            <tr>
              <td>
              
              </td>
            </tr>
            <%
              If v_Mode = "UPDATE" Then
            %>
              <tr>
                <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Link Status:&nbsp;</nobr></td>
                <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                  <%=v_Status%>
                </nobr></td>
              </tr>
              <tr>
                <td>
                  &nbsp;
                </td>
              </tr>
            <%
              End If
            %>
          </table>

          <table class="clsGrid02" align="center" valign="top" cols="2" cellpadding="1" cellspacing="0">  
            <tr>
              <td class="clsLabelUL" align="center" colspan="2" nowrap><nobr>
                <table class="clsTable01" align="center" cols="1" cellpadding="0" cellspacing="0">
                  <tr>
                    <td align="center" nowrap><nobr><a class="clsButton" href="javascript:doReturn();">&nbsp;&nbsp;&nbsp;&nbsp;Return To Start&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                    <td align="center" nowrap><nobr><a class="clsButton" href="javascript:doMaterial();">&nbsp;&nbsp;&nbsp;&nbsp;Alter/Create Another Link&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                  </tr>
                </table>
              </nobr></td>
            </tr>
          </table>

          <input type="hidden" name="Mode" value=" ">
          <input type="hidden" name="MaterialSelected" value="1">
        </form>
      </body>
    </html>
     <%ElseIf v_Mode = "NoMatNoFound" Then%>
      <body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('/ics_int_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();">
        <form name="main" action="<%=strBase%><%=strTarget%>" method="post">
 
          <table class="clsGrid02" align="center" valign="top" cols="2" cellpadding="1" cellspacing="0">
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><center><font size="5"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No Records Found&nbsp;</font></center></nobr></td>           
              </nobr></td>
            </tr>
              
              <tr>
                <td>
                  &nbsp;
                </td>
              </tr>            
          </table>
          
          <table class="clsGrid02" align="center" valign="top" cols="2" cellpadding="1" cellspacing="0">  
            <tr>
              <td class="clsLabelUL" align="center" colspan="2" nowrap><nobr>
                <table class="clsTable01" align="center" cols="1" cellpadding="0" cellspacing="0">
                  <tr>
                    <td align="center" nowrap><nobr><a class="clsButton" href="javascript:doReturn();">&nbsp;&nbsp;&nbsp;&nbsp;Return To Start&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                   
                  </tr>
                </table>
              </nobr></td>
            </tr>
          </table>
			 <input name="BusSegCode" type="hidden" value><nobr>
          <input name="BrandEssCode" type="hidden" value><nobr>
          <input type="hidden" name="Mode" value=" ">
          <input type="hidden" name="MaterialSelected" value="1">
        </form>
      </body>
    </html>
    
  <%Else%>
      <body class="clsBody02" scroll="auto" onLoad="parent.setStatus('<%=strStatus%>');parent.setHelp('/ics_int_monitor_help.htm');parent.setHeading('<%=strHeading%>');parent.showContent();">
        <form name="main" action="<%=strBase%><%=strTarget%>" method="post">
 
          <table class="clsGrid02" align="center" valign="top" cols="2" width="100%" cellpadding="1" cellspacing="0">
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
           
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Business Segment:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <select class="clsInputBN" name="BusSegCode" onChange="javascript:doBusSeg();">
                  <option value="X"><----business Segment List----></option>
                  <%for i = 1 to objSelection.ListCount("BusSeg")%>
                    <option value="<%=objSelection.ListValue01("BusSeg", i - 1)%>" <%if (objSelection.ListValue01("BusSeg", i - 1) = v_BusSegCode) then%> selected <%end if%>><%= objSelection.ListValue02("BusSeg", i - 1)%></option>
                  <%next%> 
                </select>
              </nobr></td>
            </tr>
           
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
           
            <tr>
              <td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Brand Essence:&nbsp;</nobr></td>
              <td class="clsLabelBN" align="left" colspan="1" nowrap width="50%"><nobr>
                <select class="clsInputBN" name="BrandEssCode" onChange="javascript:doBrandEss();">
                  <option value="X"><----brand Essence List----></option>
                  <%for i = 1 to objSelection.ListCount("BrandEss")%>
                    <option value="<%=objSelection.ListValue02("BrandEss", i - 1)%>"> <%= objSelection.ListValue03("BrandEss", i - 1)%></option>
                  <%next%> 
                </select>
              </nobr></td>
            </tr>
           
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
           
             <tr>
					<td class="clsLabelBB" align="right" colspan="1" nowrap width="50%"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Material Number&nbsp;</nobr></td>			
					<td class="clsLabelBN" align="left" colspan="1" nowrap width><nobr> 
					<input type="text" id="MatNo" name="MatNo" size="18" Maxlength="18">
					<img SRC="/CDW/images/gobutton.gif" onclick="javascript:doMatNo();" style="cursor:hand" WIDTH="32" HEIGHT="19">					                    
					</td>	   
             </tr>
                </table>  
                
					
					 </nobr>
					</nobr></td>						       	       
				</tr>
				
            <tr>
              <td>
                &nbsp;
              </td>
            </tr>
            
            <tr>
              <td class="clsLabelUL" align="center" colspan="2" nowrap><nobr>
                <table class="clsTable01" align="center" cols="1" cellpadding="0" cellspacing="0">
                  <tr>
                  <% If (len(v_BusSegCode) > 0) Then %>                  
                    <td align="center" nowrap><nobr><a class="clsButton" href="javascript:doReturn();">&nbsp;&nbsp;&nbsp;&nbsp;Cancel&nbsp;&nbsp;&nbsp;&nbsp;</a></nobr></td>
                 <% End If %> 
                  </tr>
                </table>                 
             </td>
            </tr>      
                  
            
				
          </table>

          <input type="hidden" name="Mode" value=" ">
        </form>
      </body>
    </html>
        
    
  <%End If%>
<%end sub%>
<!--#include file="../ics_std_code.inc"-->
