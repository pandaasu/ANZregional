VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Object"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
    '//
    '// Ensure explicit declarations
    '//
    Option Explicit
    
    '//
    '// Progress form
    '//
    Private cobjMain As frmMain
    
    '//
    '// Interface - IObjectSafety
    '// **note** MAX_GUIDLEN must be 40 for NT
    '//
    Implements IObjectSafety
    Private cbolMakeSafeForScripting As Boolean
    Private Const IID_IDispatch = "{00020400-0000-0000-C000-000000000046}"
    Private Const IID_IPersistStorage = "{0000010A-0000-0000-C000-000000000046}"
    Private Const IID_IPersistStream = "{00000109-0000-0000-C000-000000000046}"
    Private Const IID_IPersistPropertyBag = "{37D84F60-42CB-11CE-8135-00AA004BB851}"
    Private Const INTERFACESAFE_FOR_UNTRUSTED_CALLER = &H1
    Private Const INTERFACESAFE_FOR_UNTRUSTED_DATA = &H2
    Private Const E_NOINTERFACE = &H80004002
    Private Const E_FAIL = &H80004005
    Private Const MAX_GUIDLEN = 40
    Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (pDest As Any, pSource As Any, ByVal ByteLen As Long)
    Private Declare Function StringFromGUID2 Lib "ole32.dll" (rguid As Any, ByVal lpstrClsId As Long, ByVal cbMax As Integer) As Long
    Private Type typGUID
        Data1 As Long
        Data2 As Integer
        Data3 As Integer
        Data4(7) As Byte
    End Type
    
    '//
    '// Private instruction variables
    '//
    Private Type ctypInstructionType
        Action As String
        Parm01 As String
        Parm02 As String
        Parm03 As String
        Parm04 As String
        Parm05 As String
        Parm06 As String
        Parm07 As String
        Parm08 As String
        Parm09 As String
        Data As String
    End Type
    Private caryInstructions() As ctypInstructionType
    Private clngInstructionCount As Long
    Private clngSheetCount As Long
    Private clngChartCount As Long
    
    '//
    '// Type constants
    '//
    Private Const TYPE_HEADING_01 As String = "H1"
    Private Const TYPE_HEADING_02 As String = "H2"
    Private Const TYPE_HEADING_03 As String = "H3"
    Private Const TYPE_HEADING_04 As String = "H4"
    Private Const TYPE_HEADING_05 As String = "H5"
    Private Const TYPE_HEADING_06 As String = "H6"
    Private Const TYPE_HEADING_07 As String = "H7"
    Private Const TYPE_HEADING_HI As String = "HH"
    Private Const TYPE_HEADING_SM As String = "HS"
    Private Const TYPE_SUMMARY_01 As String = "S1"
    Private Const TYPE_SUMMARY_02 As String = "S2"
    Private Const TYPE_SUMMARY_03 As String = "S3"
    Private Const TYPE_SUMMARY_04 As String = "S4"
    Private Const TYPE_SUMMARY_05 As String = "S5"
    Private Const TYPE_SUMMARY_06 As String = "S6"
    Private Const TYPE_SUMMARY_07 As String = "S7"
    Private Const TYPE_HEADING As String = "HE"
    Private Const TYPE_DETAIL As String = "DE"
    
    '//
    '// Format constants
    '//
    Private Const FORMAT_LEFT As String = "HL"
    Private Const FORMAT_CENTRE As String = "HC"
    Private Const FORMAT_RIGHT As String = "HR"
    Private Const FORMAT_NUMBER_00 As String = "#,##0;-#,##0"
    Private Const FORMAT_NUMBER_01 As String = "#,##0.0;-#,##0.0"
    Private Const FORMAT_NUMBER_02 As String = "#,##0.00;-#,##0.00"
    Private Const FORMAT_NUMBER_03 As String = "#,##0.000;-#,##0.000"
    Private Const FORMAT_NUMBER_04 As String = "#,##0.0000;-#,##0.0000"
    Private Const FORMAT_NUMBER_05 As String = "#,##0.00000;-#,##0.00000"
    Private Const FORMAT_NUMBER_06 As String = "#,##0.000000;-#,##0.000000"
    Private Const FORMAT_NUMBER_07 As String = "#,##0.0000000;-#,##0.0000000"
    Private Const FORMAT_NUMBER_08 As String = "#,##0.00000000;-#,##0.00000000"
    Private Const FORMAT_NUMBER_09 As String = "#,##0.000000000;-#,##0.000000000"
    Private Const FORMAT_NUMBER_51 As String = "yyyy-mm-dd"
    
    '//
    '// Font constants
    '//
    Private Const FONT_NAME_HEADING_01 As String = "Arial"
    Private Const FONT_SIZE_HEADING_01 As Integer = 12
    Private Const FONT_BOLD_HEADING_01 As Boolean = True
    Private Const FONT_NAME_HEADING_02 As String = "Arial"
    Private Const FONT_SIZE_HEADING_02 As Integer = 10
    Private Const FONT_BOLD_HEADING_02 As Boolean = True
    Private Const FONT_NAME_HEADING_03 As String = "Arial"
    Private Const FONT_SIZE_HEADING_03 As Integer = 10
    Private Const FONT_BOLD_HEADING_03 As Boolean = True
    Private Const FONT_NAME_HEADING_04 As String = "Arial"
    Private Const FONT_SIZE_HEADING_04 As Integer = 10
    Private Const FONT_BOLD_HEADING_04 As Boolean = True
    Private Const FONT_NAME_HEADING_05 As String = "Arial"
    Private Const FONT_SIZE_HEADING_05 As Integer = 10
    Private Const FONT_BOLD_HEADING_05 As Boolean = True
    Private Const FONT_NAME_HEADING_06 As String = "Arial"
    Private Const FONT_SIZE_HEADING_06 As Integer = 10
    Private Const FONT_BOLD_HEADING_06 As Boolean = True
    Private Const FONT_NAME_HEADING_07 As String = "Arial"
    Private Const FONT_SIZE_HEADING_07 As Integer = 10
    Private Const FONT_BOLD_HEADING_07 As Boolean = False
    Private Const FONT_NAME_HEADING_HI As String = "Arial"
    Private Const FONT_SIZE_HEADING_HI As Integer = 10
    Private Const FONT_BOLD_HEADING_HI As Boolean = True
    Private Const FONT_NAME_HEADING_SM As String = "Arial"
    Private Const FONT_SIZE_HEADING_SM As Integer = 8
    Private Const FONT_BOLD_HEADING_SM As Boolean = False
    Private Const FONT_NAME_SUMMARY_01 As String = "Arial"
    Private Const FONT_SIZE_SUMMARY_01 As Integer = 10
    Private Const FONT_BOLD_SUMMARY_01 As Boolean = True
    Private Const FONT_NAME_SUMMARY_02 As String = "Arial"
    Private Const FONT_SIZE_SUMMARY_02 As Integer = 10
    Private Const FONT_BOLD_SUMMARY_02 As Boolean = True
    Private Const FONT_NAME_SUMMARY_03 As String = "Arial"
    Private Const FONT_SIZE_SUMMARY_03 As Integer = 10
    Private Const FONT_BOLD_SUMMARY_03 As Boolean = True
    Private Const FONT_NAME_SUMMARY_04 As String = "Arial"
    Private Const FONT_SIZE_SUMMARY_04 As Integer = 10
    Private Const FONT_BOLD_SUMMARY_04 As Boolean = True
    Private Const FONT_NAME_SUMMARY_05 As String = "Arial"
    Private Const FONT_SIZE_SUMMARY_05 As Integer = 10
    Private Const FONT_BOLD_SUMMARY_05 As Boolean = True
    Private Const FONT_NAME_SUMMARY_06 As String = "Arial"
    Private Const FONT_SIZE_SUMMARY_06 As Integer = 10
    Private Const FONT_BOLD_SUMMARY_06 As Boolean = True
    Private Const FONT_NAME_SUMMARY_07 As String = "Arial"
    Private Const FONT_SIZE_SUMMARY_07 As Integer = 10
    Private Const FONT_BOLD_SUMMARY_07 As Boolean = True
    Private Const FONT_NAME_HEADING As String = "Arial"
    Private Const FONT_SIZE_HEADING As Integer = 10
    Private Const FONT_BOLD_HEADING As Boolean = True
    Private Const FONT_NAME_DETAIL As String = "Arial"
    Private Const FONT_SIZE_DETAIL As Integer = 10
    Private Const FONT_BOLD_DETAIL As Boolean = False
    Private Const FONT_NAME_NORMAL As String = "Arial"
    Private Const FONT_SIZE_NORMAL As Integer = 10
    Private Const FONT_BOLD_NORMAL As Boolean = False
    
    '//
    '// Color variables
    '//
    Private COLOR_BAC_HEADING As Variant
    Private COLOR_FOR_HEADING As Variant
    Private COLOR_BOR_HEADING As Variant
    Private COLOR_BAC_HEADING_HI As Variant
    Private COLOR_FOR_HEADING_HI As Variant
    Private COLOR_BAC_SUMMARY_01 As Variant
    Private COLOR_BAC_SUMMARY_02 As Variant
    Private COLOR_BAC_SUMMARY_03 As Variant
    Private COLOR_BAC_SUMMARY_04 As Variant
    Private COLOR_BAC_SUMMARY_05 As Variant
    Private COLOR_BAC_SUMMARY_06 As Variant
    Private COLOR_BAC_SUMMARY_07 As Variant
    Private COLOR_FOR_SUMMARY As Variant
    Private COLOR_BAC_SUB_HEADING As Variant
    Private COLOR_FOR_SUB_HEADING As Variant
    Private COLOR_BAC_DETAIL As Variant
    Private COLOR_FOR_DETAIL As Variant
Private Function GetIIDFromPTR(ByVal riid As Long) As String

    Dim Rc As Long
    Dim rClsId As typGUID
    Dim bIID() As Byte

    '//
    '// Validate pointer to interface id
    '// - copy interface GUID to structure
    '// - pre-allocate the byte array
    '// - get the class id frm the GUID structure
    '// - check for trailing null characters
    '// - trim nulls and uppercase for comparison
    '//
    If (riid <> 0) Then
        CopyMemory rClsId, ByVal riid, Len(rClsId)
        bIID = String$(MAX_GUIDLEN, 0)
        Rc = StringFromGUID2(rClsId, VarPtr(bIID(0)), MAX_GUIDLEN)
        Rc = InStr(1, bIID, vbNullChar) - 1
        GetIIDFromPTR = Left$(UCase(bIID), Rc)
    End If

End Function
Private Sub Class_Terminate()

    '//
    '// Destroy the progress form
    '//
    If Not cobjMain Is Nothing Then
        Unload cobjMain
    End If
    Set cobjMain = Nothing
    
End Sub

Private Sub IObjectSafety_GetInterfaceSafetyOptions(ByVal riid As Long, pdwSupportedOptions As Long, pdwEnabledOptions As Long)

    Dim strIID As String

    '//
    '// Set the supported object safty features
    '//
    pdwSupportedOptions = INTERFACESAFE_FOR_UNTRUSTED_CALLER Or INTERFACESAFE_FOR_UNTRUSTED_DATA
    
    '//
    '// Get the interface identifier string from the pointer
    '//
    strIID = GetIIDFromPTR(riid)
    
    '//
    '// Check the requesting interface and set the enabled features
    '//
    Select Case strIID
        Case IID_IDispatch
            pdwEnabledOptions = INTERFACESAFE_FOR_UNTRUSTED_DATA
            Exit Sub
        Case IID_IPersistStorage, IID_IPersistStream, IID_IPersistPropertyBag
            pdwEnabledOptions = pdwEnabledOptions Or INTERFACESAFE_FOR_UNTRUSTED_CALLER
            Exit Sub
        Case Else
            Err.Raise E_NOINTERFACE
    End Select
    
    '//
    '// Interface not supported
    '//
    Err.Raise E_FAIL

End Sub
Private Sub IObjectSafety_SetInterfaceSafetyOptions(ByVal riid As Long, ByVal dwOptionsSetMask As Long, ByVal dwEnabledOptions As Long)

    Dim lngSettings As Long
    Dim strIID As String

    '//
    '// Set the safty settings flag
    '//
    lngSettings = (dwEnabledOptions And dwOptionsSetMask)
    
    '//
    '// Get the interface identifier string from the pointer
    '//
    strIID = GetIIDFromPTR(riid)
    
    '//
    '// Check the requesting interface
    '//
    Select Case strIID
        Case IID_IDispatch
            If (lngSettings = INTERFACESAFE_FOR_UNTRUSTED_CALLER) Then
                cbolMakeSafeForScripting = True
                Exit Sub
            End If
        Case IID_IPersistStorage, IID_IPersistStream, IID_IPersistPropertyBag
            If (lngSettings = INTERFACESAFE_FOR_UNTRUSTED_DATA) Then
                Exit Sub
            End If
        Case Else
            Err.Raise E_NOINTERFACE
    End Select
    
    '//
    '// Interface not supported
    '//
    Err.Raise E_FAIL

End Sub

Private Sub ProcessDataNode(objNode As MSXML.IXMLDOMNode)

    Dim i As Long
    Dim j As Long
    
    '//
    '// Process the node attributes when required
    '//
    Select Case UCase(objNode.nodeName)
        Case "ADDSHEET"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "ADDSHEET"
            clngSheetCount = clngSheetCount + 1
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "NAME"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETRANGE"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGE"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "RANGE"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                    Case "MERGERANGE"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.attributes(j).Text
                    Case "TYPE"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.attributes(j).Text
                    Case "FORMAT"
                        caryInstructions(clngInstructionCount).Parm04 = objNode.attributes(j).Text
                    Case "INDENT"
                        caryInstructions(clngInstructionCount).Parm05 = objNode.attributes(j).Text
                    Case "BULLET"
                        caryInstructions(clngInstructionCount).Parm06 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETRANGEARRAY"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGEARRAY"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "RANGE"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                    Case "FORMATRANGE"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.attributes(j).Text
                    Case "TYPE"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.attributes(j).Text
                    Case "FORMAT"
                        caryInstructions(clngInstructionCount).Parm04 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETRANGEBORDER"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGEBORDER"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "RANGE"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETRANGETYPE"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGETYPE"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "RANGE"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                    Case "TYPE"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETRANGEFORMAT"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGEFORMAT"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "RANGE"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                    Case "FORMAT"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETHEADINGBORDER"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETHEADINGBORDER"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "RANGE"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                    Case "BORDERS"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETROWGROUP"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETROWGROUP"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "RANGE"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETFREEZECELL"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETFREEZECELL"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "RANGE"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETPRINTDATA"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETPRINTDATA"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "ROWRANGE"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                    Case "COLUMNRANGE"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.attributes(j).Text
                    Case "ORIENTATION"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.attributes(j).Text
                    Case "FITWIDTHPAGES"
                        caryInstructions(clngInstructionCount).Parm04 = objNode.attributes(j).Text
                    Case "ZOOM"
                        caryInstructions(clngInstructionCount).Parm05 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETPRINTOVERRIDE"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETPRINTOVERRIDE"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "ORIENTATION"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                    Case "FITWIDTHPAGES"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.attributes(j).Text
                    Case "ZOOM"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "ADDCHART"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "ADDCHART"
            clngChartCount = clngChartCount + 1
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "NAME"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                    Case "TITLE"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.attributes(j).Text
                    Case "XTITLE"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.attributes(j).Text
                    Case "XNAMES"
                        caryInstructions(clngInstructionCount).Parm04 = objNode.attributes(j).Text
                    Case "YTITLE"
                        caryInstructions(clngInstructionCount).Parm05 = objNode.attributes(j).Text
                    Case "ORIENTATION"
                        caryInstructions(clngInstructionCount).Parm06 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "ADDCHARTSERIES"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "ADDCHARTSERIES"
            For j = 0 To objNode.attributes.Length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "NAME"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.attributes(j).Text
                    Case "VALUES"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "#CDATA-SECTION"
            caryInstructions(clngInstructionCount - 1).Data = objNode.Text
    End Select

    '//
    '// Process the any child nodes
    '//
    For i = 0 To objNode.childNodes.Length - 1
        Call ProcessDataNode(objNode.childNodes(i))
    Next
        
End Sub
Friend Function ReportGeneration() As String

    Dim i As Long
    Dim strReturn As String
    Dim lngWork As Long
    Dim intWork As Integer
    Dim lngSheetCount As Long
    Dim lngChartCount As Long
    Dim strChartTitle As String
    Dim strChartXTitle As String
    Dim strChartXNames As String
    Dim strChartYTitle As String
    Dim intChartOrientation As Integer
    Dim objXLApplication As Excel.Application
    Dim objXLBook As Excel.Workbook
    Dim objXLSheet As Excel.Worksheet
    Dim objXLRange As Excel.Range
    Dim objXLStyle As Excel.Style
    Dim objXLChart As Excel.Chart
    Dim objXLChartTitle As Excel.ChartTitle
    Dim objXLChartArea As Excel.ChartArea
    Dim objXLPlotArea As Excel.PlotArea
    Dim objXLLegend As Excel.Legend
    Dim objXLAxis As Excel.Axis
    Dim objXLSeriesCollection As Excel.SeriesCollection
    Dim objXLSeries As Excel.Series
    Dim objXLObject As Collection
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return string
    '//
    strReturn = "*OK"
    
    '//
    '// Create an instance of Excel application
    '// *note* can use early binds because excel is an out of process server
    '//
    Set objXLObject = New Collection
    Set objXLApplication = New Excel.Application
    objXLApplication.IgnoreRemoteRequests = True
    objXLApplication.DisplayAlerts = False
    objXLApplication.Visible = False
    objXLApplication.SheetsInNewWorkbook = 1
    Set objXLBook = objXLApplication.Workbooks.Add()
    Set objXLStyle = objXLBook.Styles("Normal")
    objXLStyle.Font.Name = FONT_NAME_NORMAL
    objXLStyle.Font.Size = FONT_SIZE_NORMAL
    objXLStyle.Font.Bold = FONT_BOLD_NORMAL
    Call objXLBook.Activate
    
    '//
    '// Create the default worksheet when none specified
    '// *note* specification does not contain an <AddSheet>
    '//
    If clngSheetCount = 0 Then
        Set objXLSheet = objXLBook.Worksheets(1)
        Call objXLObject.Add(objXLSheet)
        Call objXLSheet.Activate
        objXLSheet.Visible = True
        objXLSheet.Outline.SummaryRow = Excel.xlSummaryAbove
        objXLSheet.Outline.SummaryColumn = Excel.xlSummaryOnLeft
        objXLSheet.Name = "Generated Report"
        objXLSheet.PageSetup.HeaderMargin = 36
        objXLSheet.PageSetup.FooterMargin = 18
        objXLSheet.PageSetup.TopMargin = 36
        objXLSheet.PageSetup.BottomMargin = 36
        objXLSheet.PageSetup.LeftMargin = 18
        objXLSheet.PageSetup.RightMargin = 18
        objXLSheet.PageSetup.CenterHorizontally = True
        objXLSheet.PageSetup.LeftFooter = "&D"
        objXLSheet.PageSetup.CenterFooter = "Page &P"
        objXLSheet.PageSetup.RightFooter = "&Z&F"
    End If
    
    '//
    '// Create the first chart when charts required
    '// *note* specification contains an <AddChart>
    '//        required to overcome the Range.MergeCell association bug
    '//
    If clngChartCount > 0 Then
        Set objXLChart = objXLBook.Charts.Add()
    End If
    
    '//
    '// Execute the excel instructions
    '//
    lngSheetCount = 0
    lngChartCount = 0
    For i = 0 To clngInstructionCount - 1
    
        '//
        '// Update the report progress
        '//
        lngWork = (i * 100) \ clngInstructionCount
        cobjMain.lblProgress.Caption = "Generating Excel Spreadsheet " & Format(lngWork, "0") & "% completed"
        cobjMain.lblProgress.Refresh
        
        '//
        '// Perform the action
        '//
        Select Case caryInstructions(i).Action
            Case Is = "ADDSHEET"
                If lngSheetCount = 0 Then
                    Set objXLSheet = objXLBook.Worksheets(1)
                Else
                    Set objXLSheet = objXLBook.Worksheets.Add()
                End If
                If objXLObject.Count <> 0 Then
                    Call objXLSheet.Move(, objXLObject(objXLObject.Count))
                End If
                lngSheetCount = lngSheetCount + 1
                Call objXLObject.Add(objXLSheet)
                Call objXLSheet.Activate
                objXLSheet.Visible = True
                objXLSheet.Outline.SummaryRow = Excel.xlSummaryAbove
                objXLSheet.Outline.SummaryColumn = Excel.xlSummaryOnLeft
                objXLSheet.Name = caryInstructions(i).Parm01
                objXLSheet.PageSetup.HeaderMargin = 36
                objXLSheet.PageSetup.FooterMargin = 18
                objXLSheet.PageSetup.TopMargin = 36
                objXLSheet.PageSetup.BottomMargin = 36
                objXLSheet.PageSetup.LeftMargin = 18
                objXLSheet.PageSetup.RightMargin = 18
                objXLSheet.PageSetup.CenterHorizontally = True
                objXLSheet.PageSetup.LeftFooter = "&D"
                objXLSheet.PageSetup.CenterFooter = "Page &P"
                objXLSheet.PageSetup.RightFooter = "&Z&F"
            Case Is = "SETRANGE"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                'If caryInstructions(i).Parm06 = "1" Then
                '    caryInstructions(i).Data = Chr(149) & " " & caryInstructions(i).Data
                'End If
                objXLRange.Value = caryInstructions(i).Data
                If caryInstructions(i).Parm02 <> "" Then
                    Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm02)
                    objXLRange.MergeCells = True
                End If
                intWork = 0
                On Error Resume Next
                intWork = CInt(caryInstructions(i).Parm05)
                On Error GoTo tagError
                If intWork > 0 Then
                    objXLRange.IndentLevel = intWork
                End If
                Call FormatType(caryInstructions(i).Parm03, objXLRange)
                Call FormatData(caryInstructions(i).Parm04, objXLRange)
            Case Is = "SETRANGEARRAY"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                objXLRange.Value = caryInstructions(i).Data
                Call objXLRange.TextToColumns(, , , , Tab:=True)
                If caryInstructions(i).Parm02 <> "" Then
                    Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm02)
                    Call FormatType(caryInstructions(i).Parm03, objXLRange)
                    Call FormatData(caryInstructions(i).Parm04, objXLRange)
                End If
            Case Is = "SETRANGEBORDER"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                Call objXLRange.BorderAround(Excel.xlContinuous)
            Case Is = "SETRANGETYPE"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                Call FormatType(caryInstructions(i).Parm02, objXLRange)
            Case Is = "SETRANGEFORMAT"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                Call FormatData(caryInstructions(i).Parm02, objXLRange)
            Case Is = "SETHEADINGBORDER"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                Select Case caryInstructions(i).Parm02
                    Case Is = "ALL"
                        objXLRange.Borders(xlEdgeLeft).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeLeft).Color = COLOR_BOR_HEADING
                        objXLRange.Borders(xlEdgeRight).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeRight).Color = COLOR_BOR_HEADING
                        objXLRange.Borders(xlEdgeTop).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeTop).Color = COLOR_BOR_HEADING
                        objXLRange.Borders(xlEdgeBottom).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeBottom).Color = COLOR_BOR_HEADING
                    Case Is = "TLR"
                        objXLRange.Borders(xlEdgeLeft).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeLeft).Color = COLOR_BOR_HEADING
                        objXLRange.Borders(xlEdgeRight).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeRight).Color = COLOR_BOR_HEADING
                        objXLRange.Borders(xlEdgeTop).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeTop).Color = COLOR_BOR_HEADING
                    Case Is = "BLR"
                        objXLRange.Borders(xlEdgeLeft).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeLeft).Color = COLOR_BOR_HEADING
                        objXLRange.Borders(xlEdgeRight).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeRight).Color = COLOR_BOR_HEADING
                        objXLRange.Borders(xlEdgeBottom).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeBottom).Color = COLOR_BOR_HEADING
                    Case Is = "TB"
                        objXLRange.Borders(xlEdgeTop).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeTop).Color = COLOR_BOR_HEADING
                        objXLRange.Borders(xlEdgeBottom).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeBottom).Color = COLOR_BOR_HEADING
                    Case Is = "LR"
                        objXLRange.Borders(xlEdgeLeft).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeLeft).Color = COLOR_BOR_HEADING
                        objXLRange.Borders(xlEdgeRight).LineStyle = Excel.xlDouble
                        objXLRange.Borders(xlEdgeRight).Color = COLOR_BOR_HEADING
                End Select
            Case Is = "SETROWGROUP"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                Call objXLRange.Group
            Case Is = "SETFREEZECELL"
                Call objXLSheet.Activate
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                objXLRange.Activate
                objXLApplication.ActiveWindow.FreezePanes = True
            Case Is = "SETPRINTDATA"
                If caryInstructions(i).Parm01 <> "" Then
                    objXLSheet.PageSetup.PrintTitleRows = caryInstructions(i).Parm01
                End If
                If caryInstructions(i).Parm02 <> "" Then
                    objXLSheet.PageSetup.PrintTitleColumns = caryInstructions(i).Parm02
                End If
                objXLSheet.PageSetup.Orientation = Excel.xlPortrait
                intWork = 0
                On Error Resume Next
                intWork = CInt(caryInstructions(i).Parm03)
                On Error GoTo tagError
                If intWork = 1 Then
                    objXLSheet.PageSetup.Orientation = Excel.xlPortrait
                End If
                If intWork = 2 Then
                    objXLSheet.PageSetup.Orientation = Excel.xlLandscape
                End If
                intWork = 0
                On Error Resume Next
                intWork = CInt(caryInstructions(i).Parm04)
                On Error GoTo tagError
                If intWork > 0 Then
                    objXLSheet.PageSetup.Zoom = False
                    objXLSheet.PageSetup.FitToPagesWide = intWork
                    objXLSheet.PageSetup.FitToPagesTall = False
                End If
                intWork = 0
                On Error Resume Next
                intWork = CInt(caryInstructions(i).Parm05)
                On Error GoTo tagError
                If intWork > 0 And intWork <= 100 Then
                    objXLSheet.PageSetup.FitToPagesWide = False
                    objXLSheet.PageSetup.FitToPagesTall = False
                    objXLSheet.PageSetup.Zoom = intWork
                End If
            Case Is = "SETPRINTOVERRIDE"
                intWork = 0
                On Error Resume Next
                intWork = CInt(caryInstructions(i).Parm01)
                On Error GoTo tagError
                If intWork = 1 Then
                    objXLSheet.PageSetup.Orientation = Excel.xlPortrait
                End If
                If intWork = 2 Then
                    objXLSheet.PageSetup.Orientation = Excel.xlLandscape
                End If
                intWork = 0
                On Error Resume Next
                intWork = CInt(caryInstructions(i).Parm02)
                On Error GoTo tagError
                If intWork > 0 Then
                    objXLSheet.PageSetup.Zoom = False
                    objXLSheet.PageSetup.FitToPagesWide = intWork
                    objXLSheet.PageSetup.FitToPagesTall = False
                End If
                intWork = 0
                On Error Resume Next
                intWork = CInt(caryInstructions(i).Parm03)
                On Error GoTo tagError
                If intWork > 0 And intWork <= 100 Then
                    objXLSheet.PageSetup.FitToPagesWide = False
                    objXLSheet.PageSetup.FitToPagesTall = False
                    objXLSheet.PageSetup.Zoom = intWork
                End If
            Case Is = "ADDCHART"
                If lngChartCount > 0 Then
                    Set objXLSeriesCollection = objXLChart.SeriesCollection
                    If objXLSeriesCollection.Count = 0 Then
                        objXLChart.Delete
                    Else
                        Set objXLAxis = objXLChart.Axes(Excel.xlCategory)
                        objXLAxis.HasTitle = True
                        objXLAxis.AxisTitle.Text = strChartXTitle
                        objXLAxis.HasMajorGridlines = True
                        objXLAxis.HasMinorGridlines = False
                        objXLAxis.MajorTickMark = Excel.xlTickMarkCross
                        objXLAxis.CategoryNames = strChartXNames
                        Set objXLAxis = objXLChart.Axes(Excel.xlValue)
                        objXLAxis.HasTitle = True
                        objXLAxis.AxisTitle.Text = strChartYTitle
                        objXLChart.HasLegend = True
                        Set objXLLegend = objXLChart.Legend
                        objXLLegend.Position = Excel.xlLegendPositionBottom
                        objXLChart.HasTitle = True
                        Set objXLChartTitle = objXLChart.ChartTitle
                        objXLChartTitle.Caption = strChartTitle
                        Set objXLPlotArea = objXLChart.PlotArea
                        objXLPlotArea.Interior.Color = RGB(255, 255, 255)
                        Set objXLChartArea = objXLChart.ChartArea
                        objXLChartArea.Interior.Color = RGB(255, 255, 255)
                        If intChartOrientation = 1 Then
                            objXLChart.PageSetup.Orientation = Excel.xlPortrait
                        End If
                        If intChartOrientation = 2 Then
                            objXLChart.PageSetup.Orientation = Excel.xlLandscape
                        End If
                    End If
                    Set objXLChart = objXLBook.Charts.Add()
                End If
                lngChartCount = lngChartCount + 1
                Call objXLChart.Location(xlLocationAsNewSheet, caryInstructions(i).Parm01)
                 If objXLObject.Count <> 0 Then
                    Call objXLChart.Move(, objXLObject(objXLObject.Count))
                End If
                Call objXLObject.Add(objXLChart)
                Call objXLChart.Activate
                objXLChart.Visible = True
                objXLChart.PageSetup.HeaderMargin = 36
                objXLChart.PageSetup.FooterMargin = 18
                objXLChart.PageSetup.TopMargin = 36
                objXLChart.PageSetup.BottomMargin = 36
                objXLChart.PageSetup.LeftMargin = 18
                objXLChart.PageSetup.RightMargin = 18
                objXLChart.PageSetup.CenterHorizontally = True
                objXLChart.PageSetup.LeftFooter = "&D"
                objXLChart.PageSetup.CenterFooter = "Page &P"
                objXLChart.PageSetup.RightFooter = "&Z&F"
                objXLChart.PageSetup.Orientation = Excel.xlLandscape
                objXLChart.ChartType = Excel.xlLineMarkers
                strChartTitle = caryInstructions(i).Parm02
                strChartXTitle = caryInstructions(i).Parm03
                strChartXNames = caryInstructions(i).Parm04
                strChartYTitle = caryInstructions(i).Parm05
                intChartOrientation = 1
                On Error Resume Next
                intChartOrientation = CInt(caryInstructions(i).Parm06)
                On Error GoTo tagError
            Case Is = "ADDCHARTSERIES"
                If Not objXLChart Is Nothing Then
                    Set objXLSeriesCollection = objXLChart.SeriesCollection
                    Set objXLSeries = objXLSeriesCollection.NewSeries
                    objXLSeries.Name = caryInstructions(i).Parm01
                    objXLSeries.Values = caryInstructions(i).Parm02
                    objXLSeries.HasDataLabels = False
                End If
            Case Else
                strReturn = "*ERROR (XL_CLIENT:ReportGeneration): Invalid instruction (" & caryInstructions(i).Action & ") specified"
                GoTo tagExit
        End Select

    Next
    
    '//
    '// Finalise the last chart when required
    '//
    If lngChartCount > 0 Then
        Set objXLSeriesCollection = objXLChart.SeriesCollection
        If objXLSeriesCollection.Count = 0 Then
            objXLChart.Delete
        Else
            Set objXLAxis = objXLChart.Axes(Excel.xlCategory)
            objXLAxis.HasTitle = True
            objXLAxis.AxisTitle.Text = strChartXTitle
            objXLAxis.HasMajorGridlines = True
            objXLAxis.HasMinorGridlines = False
            objXLAxis.MajorTickMark = Excel.xlTickMarkCross
            objXLAxis.CategoryNames = strChartXNames
            Set objXLAxis = objXLChart.Axes(Excel.xlValue)
            objXLAxis.HasTitle = True
            objXLAxis.AxisTitle.Text = strChartYTitle
            objXLChart.HasLegend = True
            Set objXLLegend = objXLChart.Legend
            objXLLegend.Position = Excel.xlLegendPositionBottom
            objXLChart.HasTitle = True
            Set objXLChartTitle = objXLChart.ChartTitle
            objXLChartTitle.Caption = strChartTitle
            Set objXLPlotArea = objXLChart.PlotArea
            objXLPlotArea.Interior.Color = RGB(255, 255, 255)
            Set objXLChartArea = objXLChart.ChartArea
            objXLChartArea.Interior.Color = RGB(255, 255, 255)
            If intChartOrientation = 1 Then
                objXLChart.PageSetup.Orientation = Excel.xlPortrait
            End If
            If intChartOrientation = 2 Then
                objXLChart.PageSetup.Orientation = Excel.xlLandscape
            End If
        End If
    End If
    
    '//
    '// Finalise the worksheets
    '// ** note ** margins are measured in standard 72 point groups
    '//
    For i = 1 To objXLBook.Worksheets.Count
        If TypeOf objXLBook.Worksheets(i) Is Excel.Worksheet Then
            Set objXLSheet = objXLBook.Worksheets(i)
            Call objXLSheet.Activate
            objXLApplication.ActiveWindow.DisplayGridlines = False
            Call objXLSheet.Columns.AutoFit
        End If
    Next
    
    '//
    '// Set the final progress string
    '//
    cobjMain.lblProgress.Caption = "Generating Excel Spreadsheet 100% completed"
    cobjMain.lblProgress.Refresh
    
    '//
    '// Finish and close the excel application
    '//
    objXLApplication.IgnoreRemoteRequests = False
    objXLApplication.DisplayAlerts = True
    objXLApplication.Visible = True
    Set objXLChart = Nothing
    Set objXLChartTitle = Nothing
    Set objXLChartArea = Nothing
    Set objXLPlotArea = Nothing
    Set objXLLegend = Nothing
    Set objXLAxis = Nothing
    Set objXLSeries = Nothing
    Set objXLSeriesCollection = Nothing
    Set objXLStyle = Nothing
    Set objXLRange = Nothing
    Set objXLSheet = Nothing
    Set objXLBook = Nothing
    Set objXLApplication = Nothing
    Set objXLObject = Nothing
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:
    
    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "*ERROR (XL_CLIENT:ReportGeneration): Visual Basic Error " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:
    
    '//
    '// Close and destroy the application
    '//
    Set objXLChart = Nothing
    Set objXLChartTitle = Nothing
    Set objXLChartArea = Nothing
    Set objXLPlotArea = Nothing
    Set objXLLegend = Nothing
    Set objXLAxis = Nothing
    Set objXLSeries = Nothing
    Set objXLSeriesCollection = Nothing
    Set objXLStyle = Nothing
    Set objXLRange = Nothing
    Set objXLSheet = Nothing
    If Not objXLBook Is Nothing Then
        Call objXLBook.Close(False)
    End If
    Set objXLBook = Nothing
    If Not objXLApplication Is Nothing Then
        objXLApplication.IgnoreRemoteRequests = False
        Call objXLApplication.Quit
    End If
    Set objXLApplication = Nothing
    Set objXLObject = Nothing
    
    '//
    '// Clear the instruction array
    '//
    clngInstructionCount = 0
    ReDim caryInstructions(clngInstructionCount)
    
    '//
    '// Return the status
    '//
    ReportGeneration = strReturn
    
End Function
Public Function ExecuteXMLStream(ByVal strXML As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim objXMLDocument As MSXML.DOMDocument
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return string
    '//
    strReturn = "*OK"
    
    '//
    '// Parse the XML output file
    '//
    clngInstructionCount = 0
    ReDim caryInstructions(clngInstructionCount)
    clngSheetCount = 0
    clngChartCount = 0
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.loadXML(strXML) = False Then
        strReturn = "*ERROR (XL_CLIENT:ExecuteXMLStream): XML Parsing Error: " & objXMLDocument.parseError.reason
        GoTo tagExit
    End If
    For i = 0 To objXMLDocument.childNodes.Length - 1
        Call ProcessDataNode(objXMLDocument.childNodes(i))
    Next
    Set objXMLDocument = Nothing
    
    '//
    '// Create and show the progress form
    '//
    Set cobjMain = New frmMain
    Load cobjMain
    Set cobjMain.Client = Me
    cobjMain.Show vbModal
    strReturn = cobjMain.ReturnStatus
    Set cobjMain = Nothing
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:
    
    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "*ERROR (XL_CLIENT:ExecuteXMLStream): Visual Basic Error " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Destroy the objects
    '//
    Set objXMLDocument = Nothing
    
    '//
    '// Return the status
    '//
    ExecuteXMLStream = strReturn
    
End Function
Private Sub FormatType(ByVal strType As String, objXLRange As Excel.Range)

    Dim intFormat As Integer
    
    '//
    '// Perform the type setting
    '//
    Select Case strType
        Case Is = TYPE_HEADING_01
            objXLRange.Font.Name = FONT_NAME_HEADING_01
            objXLRange.Font.Size = FONT_SIZE_HEADING_01
            objXLRange.Font.Bold = FONT_BOLD_HEADING_01
            objXLRange.Font.Color = COLOR_FOR_HEADING
            objXLRange.Interior.Color = COLOR_BAC_HEADING
        Case Is = TYPE_HEADING_02
            objXLRange.Font.Name = FONT_NAME_HEADING_02
            objXLRange.Font.Size = FONT_SIZE_HEADING_02
            objXLRange.Font.Bold = FONT_BOLD_HEADING_02
            objXLRange.Font.Color = COLOR_FOR_HEADING
            objXLRange.Interior.Color = COLOR_BAC_HEADING
        Case Is = TYPE_HEADING_03
            objXLRange.Font.Name = FONT_NAME_HEADING_03
            objXLRange.Font.Size = FONT_SIZE_HEADING_03
            objXLRange.Font.Bold = FONT_BOLD_HEADING_03
            objXLRange.Font.Color = COLOR_FOR_HEADING
            objXLRange.Interior.Color = COLOR_BAC_HEADING
        Case Is = TYPE_HEADING_04
            objXLRange.Font.Name = FONT_NAME_HEADING_04
            objXLRange.Font.Size = FONT_SIZE_HEADING_04
            objXLRange.Font.Bold = FONT_BOLD_HEADING_04
            objXLRange.Font.Color = COLOR_FOR_HEADING
            objXLRange.Interior.Color = COLOR_BAC_HEADING
        Case Is = TYPE_HEADING_05
            objXLRange.Font.Name = FONT_NAME_HEADING_05
            objXLRange.Font.Size = FONT_SIZE_HEADING_05
            objXLRange.Font.Bold = FONT_BOLD_HEADING_05
            objXLRange.Font.Color = COLOR_FOR_HEADING
            objXLRange.Interior.Color = COLOR_BAC_HEADING
        Case Is = TYPE_HEADING_06
            objXLRange.Font.Name = FONT_NAME_HEADING_06
            objXLRange.Font.Size = FONT_SIZE_HEADING_06
            objXLRange.Font.Bold = FONT_BOLD_HEADING_06
            objXLRange.Font.Color = COLOR_FOR_HEADING
            objXLRange.Interior.Color = COLOR_BAC_HEADING
        Case Is = TYPE_HEADING_07
            objXLRange.Font.Name = FONT_NAME_HEADING_07
            objXLRange.Font.Size = FONT_SIZE_HEADING_07
            objXLRange.Font.Bold = FONT_BOLD_HEADING_07
            objXLRange.Font.Color = COLOR_FOR_HEADING
            objXLRange.Interior.Color = COLOR_BAC_HEADING
        Case Is = TYPE_HEADING_HI
            objXLRange.Font.Name = FONT_NAME_HEADING_HI
            objXLRange.Font.Size = FONT_SIZE_HEADING_HI
            objXLRange.Font.Bold = FONT_BOLD_HEADING_HI
            objXLRange.Font.Color = COLOR_FOR_HEADING_HI
            objXLRange.Interior.Color = COLOR_BAC_HEADING_HI
        Case Is = TYPE_HEADING_SM
            objXLRange.Font.Name = FONT_NAME_HEADING_SM
            objXLRange.Font.Size = FONT_SIZE_HEADING_SM
            objXLRange.Font.Bold = FONT_BOLD_HEADING_SM
            objXLRange.Font.Color = COLOR_FOR_HEADING
            objXLRange.Interior.Color = COLOR_BAC_HEADING
        Case Is = TYPE_SUMMARY_01
            objXLRange.Font.Name = FONT_NAME_SUMMARY_01
            objXLRange.Font.Size = FONT_SIZE_SUMMARY_01
            objXLRange.Font.Bold = FONT_BOLD_SUMMARY_01
            objXLRange.Font.Color = COLOR_FOR_SUMMARY
            objXLRange.Interior.Color = COLOR_BAC_SUMMARY_01
        Case Is = TYPE_SUMMARY_02
            objXLRange.Font.Name = FONT_NAME_SUMMARY_02
            objXLRange.Font.Size = FONT_SIZE_SUMMARY_02
            objXLRange.Font.Bold = FONT_BOLD_SUMMARY_02
            objXLRange.Font.Color = COLOR_FOR_SUMMARY
            objXLRange.Interior.Color = COLOR_BAC_SUMMARY_02
        Case Is = TYPE_SUMMARY_03
            objXLRange.Font.Name = FONT_NAME_SUMMARY_03
            objXLRange.Font.Size = FONT_SIZE_SUMMARY_03
            objXLRange.Font.Bold = FONT_BOLD_SUMMARY_03
            objXLRange.Font.Color = COLOR_FOR_SUMMARY
            objXLRange.Interior.Color = COLOR_BAC_SUMMARY_03
        Case Is = TYPE_SUMMARY_04
            objXLRange.Font.Name = FONT_NAME_SUMMARY_04
            objXLRange.Font.Size = FONT_SIZE_SUMMARY_04
            objXLRange.Font.Bold = FONT_BOLD_SUMMARY_04
            objXLRange.Font.Color = COLOR_FOR_SUMMARY
            objXLRange.Interior.Color = COLOR_BAC_SUMMARY_04
        Case Is = TYPE_SUMMARY_05
            objXLRange.Font.Name = FONT_NAME_SUMMARY_05
            objXLRange.Font.Size = FONT_SIZE_SUMMARY_05
            objXLRange.Font.Bold = FONT_BOLD_SUMMARY_05
            objXLRange.Font.Color = COLOR_FOR_SUMMARY
            objXLRange.Interior.Color = COLOR_BAC_SUMMARY_05
        Case Is = TYPE_SUMMARY_06
            objXLRange.Font.Name = FONT_NAME_SUMMARY_06
            objXLRange.Font.Size = FONT_SIZE_SUMMARY_06
            objXLRange.Font.Bold = FONT_BOLD_SUMMARY_06
            objXLRange.Font.Color = COLOR_FOR_SUMMARY
            objXLRange.Interior.Color = COLOR_BAC_SUMMARY_06
        Case Is = TYPE_SUMMARY_07
            objXLRange.Font.Name = FONT_NAME_SUMMARY_07
            objXLRange.Font.Size = FONT_SIZE_SUMMARY_07
            objXLRange.Font.Bold = FONT_BOLD_SUMMARY_07
            objXLRange.Font.Color = COLOR_FOR_SUMMARY
            objXLRange.Interior.Color = COLOR_BAC_SUMMARY_07
        Case Is = TYPE_HEADING
            objXLRange.Font.Name = FONT_NAME_HEADING
            objXLRange.Font.Size = FONT_SIZE_HEADING
            objXLRange.Font.Bold = FONT_BOLD_HEADING
            objXLRange.Font.Color = COLOR_FOR_SUB_HEADING
            objXLRange.Interior.Color = COLOR_BAC_SUB_HEADING
        Case Is = TYPE_DETAIL
            objXLRange.Font.Name = FONT_NAME_DETAIL
            objXLRange.Font.Size = FONT_SIZE_DETAIL
            objXLRange.Font.Bold = FONT_BOLD_DETAIL
            objXLRange.Font.Color = COLOR_FOR_DETAIL
            objXLRange.Interior.Color = COLOR_BAC_DETAIL
    End Select
        
End Sub
Private Sub FormatData(ByVal strFormat As String, objXLRange As Excel.Range)

    Dim intFormat As Integer
    
    '//
    '// Perform the format setting
    '//
    intFormat = -9
    On Error Resume Next
    intFormat = CInt(strFormat)
    On Error GoTo 0
    Select Case intFormat
        Case Is = -1
            objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignLeft
        Case Is = -2
            objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignCenter
        Case Is = -3
            objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
        Case Else
            Select Case intFormat
                Case Is = 0
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
                    objXLRange.NumberFormat = FORMAT_NUMBER_00
                Case Is = 1
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
                    objXLRange.NumberFormat = FORMAT_NUMBER_01
                Case Is = 2
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
                    objXLRange.NumberFormat = FORMAT_NUMBER_02
                Case Is = 3
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
                    objXLRange.NumberFormat = FORMAT_NUMBER_03
                Case Is = 4
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
                    objXLRange.NumberFormat = FORMAT_NUMBER_04
                Case Is = 5
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
                    objXLRange.NumberFormat = FORMAT_NUMBER_05
                Case Is = 6
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
                    objXLRange.NumberFormat = FORMAT_NUMBER_06
                Case Is = 7
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
                    objXLRange.NumberFormat = FORMAT_NUMBER_07
                Case Is = 8
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
                    objXLRange.NumberFormat = FORMAT_NUMBER_08
                Case Is = 9
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight
                    objXLRange.NumberFormat = FORMAT_NUMBER_09
                Case Is = 51
                    objXLRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignLeft
                    objXLRange.NumberFormat = FORMAT_NUMBER_51
            End Select
    End Select
        
End Sub
Private Sub Class_Initialize()

    '//
    '// Initialise the progress form
    '//
    Set cobjMain = Nothing
    
    '//
    '// Initialise the scripting variable
    '//
    cbolMakeSafeForScripting = False
    
    '//
    '// Initialise the color variables
    '//
    COLOR_BAC_HEADING = RGB(102, 102, 153)
    COLOR_FOR_HEADING = RGB(255, 255, 255)
    COLOR_BOR_HEADING = RGB(204, 204, 255)
    COLOR_BAC_HEADING_HI = RGB(0, 64, 0)
    COLOR_FOR_HEADING_HI = RGB(255, 255, 255)
    COLOR_BAC_SUMMARY_01 = RGB(255, 153, 204)
    COLOR_BAC_SUMMARY_02 = RGB(204, 153, 255)
    COLOR_BAC_SUMMARY_03 = RGB(153, 204, 255)
    COLOR_BAC_SUMMARY_04 = RGB(255, 204, 153)
    COLOR_BAC_SUMMARY_05 = RGB(204, 255, 204)
    COLOR_BAC_SUMMARY_06 = RGB(255, 255, 153)
    COLOR_BAC_SUMMARY_07 = RGB(204, 255, 255)
    COLOR_FOR_SUMMARY = RGB(0, 0, 0)
    COLOR_BAC_SUB_HEADING = RGB(0, 0, 96)
    COLOR_FOR_SUB_HEADING = RGB(255, 255, 255)
    COLOR_BAC_DETAIL = RGB(255, 255, 255)
    COLOR_FOR_DETAIL = RGB(0, 0, 0)
    
End Sub


