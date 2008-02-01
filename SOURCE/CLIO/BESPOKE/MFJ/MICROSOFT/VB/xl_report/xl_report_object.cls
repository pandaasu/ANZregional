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
    '// Control variables
    '//
    Public Event TaskProcessing(ByVal TaskStatus As String, ByRef Cancel As Boolean)
    
    '//
    '// Private batch variables
    '//
    Private Type ctypBatchType
        Action As String
        Value01 As String
        Value02 As String
        Value03 As String
        Value04 As String
        Value05 As String
        Value06 As String
        Value07 As String
        Value08 As String
        Value09 As String
        Value10 As String
        Value11 As String
        Value12 As String
        Value13 As String
        Value14 As String
        Value15 As String
        Value16 As String
        Value17 As String
        Value18 As String
        Value19 As String
        Value20 As String
    End Type
    Private caryBatches() As ctypBatchType
    Private clngBatchCount As Long
    
    '//
    '// Private action variables
    '//
    Private Type ctypActionType
        Action As String
        Value01 As String
        Value02 As String
        Value03 As String
        Value04 As String
        Value05 As String
        Value06 As String
        Value07 As String
        Value08 As String
        Value09 As String
        Value10 As String
        Value11 As String
        Value12 As String
        Value13 As String
        Value14 As String
        Value15 As String
        Value16 As String
        Value17 As String
        Value18 As String
        Value19 As String
        Value20 As String
    End Type
    Private caryActions() As ctypActionType
    Private clngActionCount As Long
    
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
    '// Private connection variables
    '//
    Private cobjConnection As ADODB.Connection
    
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
Private Sub ProcessBatchNode(objNode As MSXML.IXMLDOMNode)

    Dim i As Long
    Dim j As Long
    
    '//
    '// Load the actions array when required
    '//
    Select Case UCase(objNode.nodeName)
        Case "BATCHSTREAM"
            ReDim Preserve caryBatches(clngBatchCount)
            caryBatches(clngBatchCount).Action = "BATCHSTREAM"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "TEXT"
                        caryBatches(clngBatchCount).Value01 = objNode.Attributes(j).Text
                    Case "LOGDIRECTORY"
                        caryBatches(clngBatchCount).Value02 = objNode.Attributes(j).Text
                    Case "LOGNAME"
                        caryBatches(clngBatchCount).Value03 = objNode.Attributes(j).Text
                    Case "CONNECTIONSTRING"
                        caryBatches(clngBatchCount).Value04 = objNode.Attributes(j).Text
                    Case "TARGETSERVER"
                        caryBatches(clngBatchCount).Value05 = objNode.Attributes(j).Text
                    Case "TARGETUSER"
                        caryBatches(clngBatchCount).Value06 = objNode.Attributes(j).Text
                    Case "TARGETPASSWORD"
                        caryBatches(clngBatchCount).Value07 = objNode.Attributes(j).Text
                    Case "TARGETDIRECTORY"
                        caryBatches(clngBatchCount).Value08 = objNode.Attributes(j).Text
                    Case "TARGETFILES"
                        caryBatches(clngBatchCount).Value09 = objNode.Attributes(j).Text
                    Case "TARGETSHELL"
                        caryBatches(clngBatchCount).Value10 = objNode.Attributes(j).Text
                End Select
            Next
            clngBatchCount = clngBatchCount + 1
        Case "BATCHJOB"
            ReDim Preserve caryBatches(clngBatchCount)
            caryBatches(clngBatchCount).Action = "BATCHJOB"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "TEXT"
                        caryBatches(clngBatchCount).Value01 = objNode.Attributes(j).Text
                    Case "JOBSTREAM"
                        caryBatches(clngBatchCount).Value02 = objNode.Attributes(j).Text
                    Case "MONDAY"
                        caryBatches(clngBatchCount).Value03 = objNode.Attributes(j).Text
                    Case "TUESDAY"
                        caryBatches(clngBatchCount).Value04 = objNode.Attributes(j).Text
                    Case "WEDNESDAY"
                        caryBatches(clngBatchCount).Value05 = objNode.Attributes(j).Text
                    Case "THURSDAY"
                        caryBatches(clngBatchCount).Value06 = objNode.Attributes(j).Text
                    Case "FRIDAY"
                        caryBatches(clngBatchCount).Value07 = objNode.Attributes(j).Text
                    Case "SATURDAY"
                        caryBatches(clngBatchCount).Value08 = objNode.Attributes(j).Text
                    Case "SUNDAY"
                        caryBatches(clngBatchCount).Value09 = objNode.Attributes(j).Text
                    Case "PERIODEND"
                        caryBatches(clngBatchCount).Value10 = objNode.Attributes(j).Text
                    Case "PERIODYEAREND"
                        caryBatches(clngBatchCount).Value11 = objNode.Attributes(j).Text
                    Case "MONTHEND"
                        caryBatches(clngBatchCount).Value12 = objNode.Attributes(j).Text
                    Case "MONTHYEAREND"
                        caryBatches(clngBatchCount).Value13 = objNode.Attributes(j).Text
                End Select
            Next
            clngBatchCount = clngBatchCount + 1
    End Select

    '//
    '// Process the any child nodes
    '//
    For i = 0 To objNode.childNodes.Length - 1
        Call ProcessBatchNode(objNode.childNodes(i))
    Next
        
End Sub
Private Sub ProcessOutputNode(objNode As MSXML.IXMLDOMNode)

    Dim i As Long
    Dim j As Long
    
    '//
    '// Process the node attributes when required
    '//
    Select Case UCase(objNode.nodeName)
        Case "W1"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "ADDSHEET"
            clngSheetCount = clngSheetCount + 1
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "S1"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGE"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                    Case "P2"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.Attributes(j).Text
                    Case "P3"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.Attributes(j).Text
                    Case "P4"
                        caryInstructions(clngInstructionCount).Parm04 = objNode.Attributes(j).Text
                    Case "P5"
                        caryInstructions(clngInstructionCount).Parm05 = objNode.Attributes(j).Text
                    Case "P6"
                        caryInstructions(clngInstructionCount).Parm06 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "S2"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGEARRAY"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                    Case "P2"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.Attributes(j).Text
                    Case "P3"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.Attributes(j).Text
                    Case "P4"
                        caryInstructions(clngInstructionCount).Parm04 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SL"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGELINE"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                    Case "P2"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.Attributes(j).Text
                    Case "P3"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.Attributes(j).Text
                    Case "P4"
                        caryInstructions(clngInstructionCount).Parm04 = objNode.Attributes(j).Text
                    Case "P5"
                        caryInstructions(clngInstructionCount).Parm05 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "S3"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGEBORDER"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "S4"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGETYPE"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                    Case "P2"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "S5"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETRANGEFORMAT"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                    Case "P2"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "S6"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETHEADINGBORDER"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                    Case "P2"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "S7"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETROWGROUP"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "S8"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETFREEZECELL"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "S9"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETPRINTDATA"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                    Case "P2"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.Attributes(j).Text
                    Case "P3"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.Attributes(j).Text
                    Case "P4"
                        caryInstructions(clngInstructionCount).Parm04 = objNode.Attributes(j).Text
                    Case "P5"
                        caryInstructions(clngInstructionCount).Parm05 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "SETPRINTOVERRIDE"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "SETPRINTOVERRIDE"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "ORIENTATION"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                    Case "FITWIDTHPAGES"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.Attributes(j).Text
                    Case "ZOOM"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "W2"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "ADDCHART"
            clngChartCount = clngChartCount + 1
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                    Case "P2"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.Attributes(j).Text
                    Case "P3"
                        caryInstructions(clngInstructionCount).Parm03 = objNode.Attributes(j).Text
                    Case "P4"
                        caryInstructions(clngInstructionCount).Parm04 = objNode.Attributes(j).Text
                    Case "P5"
                        caryInstructions(clngInstructionCount).Parm05 = objNode.Attributes(j).Text
                    Case "P6"
                        caryInstructions(clngInstructionCount).Parm06 = objNode.Attributes(j).Text
                End Select
            Next
            clngInstructionCount = clngInstructionCount + 1
        Case "C1"
            ReDim Preserve caryInstructions(clngInstructionCount)
            caryInstructions(clngInstructionCount).Action = "ADDCHARTSERIES"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "P1"
                        caryInstructions(clngInstructionCount).Parm01 = objNode.Attributes(j).Text
                    Case "P2"
                        caryInstructions(clngInstructionCount).Parm02 = objNode.Attributes(j).Text
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
        Call ProcessOutputNode(objNode.childNodes(i))
    Next
        
End Sub
Private Sub ProcessActionNode(objNode As MSXML.IXMLDOMNode)

    Dim i As Long
    Dim j As Long
    
    '//
    '// Load the actions array when required
    '//
    Select Case UCase(objNode.nodeName)
        Case "REPORTSTREAM"
            ReDim Preserve caryActions(clngActionCount)
            caryActions(clngActionCount).Action = "REPORTSTREAM"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "TEXT"
                        caryActions(clngActionCount).Value01 = objNode.Attributes(j).Text
                    Case "LOGDIRECTORY"
                        caryActions(clngActionCount).Value02 = objNode.Attributes(j).Text
                    Case "LOGNAME"
                        caryActions(clngActionCount).Value03 = objNode.Attributes(j).Text
                    Case "OUTPUTDIRECTORY"
                        caryActions(clngActionCount).Value04 = objNode.Attributes(j).Text
                    Case "OUTPUTINITIALISATION"
                        caryActions(clngActionCount).Value05 = objNode.Attributes(j).Text
                    Case "CONNECTIONSTRING"
                        caryActions(clngActionCount).Value06 = objNode.Attributes(j).Text
                    Case "TARGETSERVER"
                        caryActions(clngActionCount).Value07 = objNode.Attributes(j).Text
                    Case "TARGETUSER"
                        caryActions(clngActionCount).Value08 = objNode.Attributes(j).Text
                    Case "TARGETPASSWORD"
                        caryActions(clngActionCount).Value09 = objNode.Attributes(j).Text
                    Case "TARGETDIRECTORY"
                        caryActions(clngActionCount).Value10 = objNode.Attributes(j).Text
                    Case "TARGETINITIALISATION"
                        caryActions(clngActionCount).Value11 = objNode.Attributes(j).Text
                    Case "TARGETSHELL"
                        caryActions(clngActionCount).Value12 = objNode.Attributes(j).Text
                End Select
            Next
            clngActionCount = clngActionCount + 1
        Case "REPORTEXTRACT"
            ReDim Preserve caryActions(clngActionCount)
            caryActions(clngActionCount).Action = "REPORTEXTRACT"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "TEXT"
                        caryActions(clngActionCount).Value01 = objNode.Attributes(j).Text
                    Case "EXTRACTPROCEDURE"
                        caryActions(clngActionCount).Value02 = objNode.Attributes(j).Text
                End Select
            Next
            clngActionCount = clngActionCount + 1
        Case "REPORTOUTPUT"
            ReDim Preserve caryActions(clngActionCount)
            caryActions(clngActionCount).Action = "REPORTOUTPUT"
            For j = 0 To objNode.Attributes.Length - 1
                Select Case UCase(objNode.Attributes(j).nodeName)
                    Case "TEXT"
                        caryActions(clngActionCount).Value01 = objNode.Attributes(j).Text
                    Case "OUTPUTPROCEDURE"
                        caryActions(clngActionCount).Value02 = objNode.Attributes(j).Text
                    Case "OUTPUTNAME"
                        caryActions(clngActionCount).Value03 = objNode.Attributes(j).Text
                    Case "OUTPUTDATEPREFIX"
                        caryActions(clngActionCount).Value04 = objNode.Attributes(j).Text
                End Select
            Next
            clngActionCount = clngActionCount + 1
    End Select

    '//
    '// Process the any child nodes
    '//
    For i = 0 To objNode.childNodes.Length - 1
        Call ProcessActionNode(objNode.childNodes(i))
    Next
        
End Sub

Private Function PerformGeneration(ByVal strOutputDirectory As String, _
                                    ByVal strOutputName As String, _
                                    ByVal strOutputDatePrefix As String, _
                                    ByVal strReplace As String, _
                                    ByVal strLogPath As String) As String

    Dim i As Long
    Dim r As Integer
    Dim c As Integer
    Dim lngRowOffset As Long
    Dim lngColumnOffset As Long
    Dim lngRowCount As Long
    Dim lngColumnCount As Long
    Dim varValues As Variant
    Dim strReturn As String
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
    '// Output directory must be supplied
    '//
    If strOutputDirectory = "" Then
        strReturn = "No output directory specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Output name must be supplied
    '//
    If strOutputName = "" Then
        strReturn = "No output name specified - unable to process"
        GoTo tagExit
    End If
    If UCase(strOutputDatePrefix) = "Y" Then
        strOutputName = Format(Now, "YYYYMMDD") & "_" & strOutputName
    End If
    
    '//
    '// Kill the existing excel spreadsheet when required
    '//
    If UCase(strReplace) = "Y" Then
        On Error Resume Next
        Kill strOutputDirectory & strOutputName
        On Error GoTo tagError
    End If
    
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
    Call FormatStyle(objXLBook)
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
        Open strLogPath For Append As #21
        Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " -------> Generating sheet - Generated Report"
        Close #21
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
                Open strLogPath For Append As #21
                Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " -------> Generating sheet - " & caryInstructions(i).Parm01 & " - Instruction(" & Format(i + 1) & " of " & clngInstructionCount & ")"
                Close #21
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
                If caryInstructions(i).Parm03 <> "" Then
                    objXLRange.Style = objXLBook.Styles(caryInstructions(i).Parm03)
                End If
                Call FormatData(caryInstructions(i).Parm04, objXLRange)
                intWork = 0
                On Error Resume Next
                intWork = CInt(caryInstructions(i).Parm05)
                On Error GoTo tagError
                If intWork > 0 Then
                    objXLRange.IndentLevel = intWork
                End If
            Case Is = "SETRANGEARRAY"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                objXLRange.Value = caryInstructions(i).Data
                Call objXLRange.TextToColumns(, , , , Tab:=True)
                If caryInstructions(i).Parm02 <> "" Then
                    Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm02)
                    objXLRange.Style = objXLBook.Styles(caryInstructions(i).Parm03)
                    Call FormatData(caryInstructions(i).Parm04, objXLRange)
                End If
            Case Is = "SETRANGELINE"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                objXLRange.Value = caryInstructions(i).Data
                Call objXLRange.TextToColumns(, , , , Tab:=True)
                If caryInstructions(i).Parm02 <> "" Then
                    Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm02)
                    objXLRange.Style = objXLBook.Styles(caryInstructions(i).Parm04)
                End If
                If caryInstructions(i).Parm03 <> "" Then
                    Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm03)
                    Call objXLRange.Group
                End If
                intWork = 0
                On Error Resume Next
                intWork = CInt(caryInstructions(i).Parm05)
                On Error GoTo tagError
                If intWork > 0 Then
                    Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                    objXLRange.IndentLevel = intWork
                End If
            Case Is = "SETRANGEBORDER"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                Call objXLRange.BorderAround(Excel.xlContinuous)
            Case Is = "SETRANGETYPE"
                Set objXLRange = objXLSheet.Range(caryInstructions(i).Parm01)
                objXLRange.Style = objXLBook.Styles(caryInstructions(i).Parm02)
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
                strReturn = "Invalid instruction (" & caryInstructions(i).Action & ") specified"
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
    '// Finish and close the excel application
    '//
    Call objXLBook.SaveCopyAs(strOutputDirectory & strOutputName)
    Call objXLBook.Close(False)
    objXLApplication.IgnoreRemoteRequests = False
    Call objXLApplication.Quit
    Set objXLChart = Nothing
    Set objXLChartTitle = Nothing
    Set objXLChartArea = Nothing
    Set objXLPlotArea = Nothing
    Set objXLLegend = Nothing
    Set objXLAxis = Nothing
    Set objXLSeries = Nothing
    Set objXLSeriesCollection = Nothing
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
    '// ADODB connection object present
    '//
    If Not cobjConnection Is Nothing Then
        If cobjConnection.Errors.Count <> 0 Then
            strReturn = ""
            For i = 0 To (cobjConnection.Errors.Count - 1)
                If strReturn <> "" Then
                    strReturn = strReturn & Chr(13) & Chr(10)
                End If
                strReturn = strReturn & cobjConnection.Errors(i).Description
            Next
            cobjConnection.Errors.Clear
            Err.Clear
        End If
    End If
    
    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "Visual Basic Error (PerformGeneration): " & Err.Number & " : " & Err.Description
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
    PerformGeneration = strReturn
    
End Function
Private Function PerformTransfer(ByVal strFromDirectory As String, _
                                 ByVal strTransferServer As String, _
                                 ByVal strTransferUser As String, _
                                 ByVal strTransferPassword As String, _
                                 ByVal strTransferDirectory As String, _
                                 ByVal strTransferFiles As String, _
                                 ByVal strTransferInitialisation As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim strResult As String
    Dim strBuffer As String
    Dim strFile As String
    Dim objXLFTP As XL_FTP.Object
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return string
    '//
    strReturn = "*OK"
    
    '//
    '// From directory must be supplied
    '//
    If strFromDirectory = "" Then
        strReturn = "No from directory specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Transfer server must be supplied
    '//
    If strTransferServer = "" Then
        strReturn = "No transfer server specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Transfer user must be supplied
    '//
    If strTransferUser = "" Then
        strReturn = "No transfer user specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Transfer password must be supplied
    '//
    If strTransferPassword = "" Then
        strReturn = "No transfer password specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Transfer directory must be supplied
    '//
    If strTransferDirectory = "" Then
        strReturn = "No transfer directory specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Transfer files must be supplied
    '//
    If strTransferFiles = "" Then
        strReturn = "No transfer files specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Create the ftp reference
    '//
    Set objXLFTP = New XL_FTP.Object
    
    '//
    '// Open the FTP session
    '// **note** Opened with access = INTERNET_OPEN_TYPE_DIRECT
    '//
    strResult = objXLFTP.OpenSession(strTransferServer, strTransferUser, strTransferPassword, strTransferDirectory, 1)
    If Trim$(strResult) <> "*OK" Then
        strReturn = strResult
        GoTo tagExit
    End If
    
    '//
    '// Initialise (clear) the contents of the FTP directory when required
    '//
    If UCase(strTransferInitialisation) = "Y" Then
    
        '//
        '// List the contents of the FTP directory
        '//
        strResult = objXLFTP.GetDirectory("*.*", strBuffer)
        If Trim$(strResult) <> "*OK" Then
            strReturn = strResult
            GoTo tagExit
        End If
        
        '//
        '// Delete the files in the buffer
        '//
        For i = 1 To Len(strBuffer)
            If (Mid$(strBuffer, i, 1) = Chr$(13) Or Mid$(strBuffer, i, 1) = Chr$(10)) Then
                If strFile <> "" Then
                    strResult = objXLFTP.DeleteFile(strFile)
                    If Trim$(strResult) <> "*OK" Then
                        strReturn = strResult
                        GoTo tagExit
                    End If
                End If
            Else
                strFile = strFile & Mid$(strBuffer, i, 1)
            End If
        Next
        
    End If
    
    '//
    '// Put the files from the output directory to the FTP server
    '//
    strFile = Dir(strFromDirectory & strTransferFiles)
    Do While strFile <> ""
        strResult = objXLFTP.PutFile(strFromDirectory & strFile, strFile)
        If Trim$(strResult) <> "*OK" Then
            strReturn = strResult
            GoTo tagExit
        End If
        strFile = Dir
    Loop
        
    '//
    '// Close the FTP session
    '//
    strResult = objXLFTP.CloseSession
    If Trim$(strResult) <> "*OK" Then
        strReturn = strResult
        GoTo tagExit
    End If
    
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
        strReturn = "Visual Basic Error (PerformTransfer): " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Destroy the ADODB objects
    '//
    Set objXLFTP = Nothing
    
    '//
    '// Return the status
    '//
    PerformTransfer = strReturn
    
End Function
Private Function PerformOutputV2(ByVal strOutputProcedure As String, ByVal strLogPath As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim strResult As String
    Dim strXML As String
    Dim objCommand As ADODB.Command
    Dim objParameter As ADODB.Parameter
    Dim objRecordset As ADODB.Recordset
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
    '// Connection must be available
    '//
    If cobjConnection Is Nothing Then
        strReturn = "Database connection missing - unable to perform output"
        GoTo tagExit
    End If
    
    '//
    '// Output procedure must be supplied
    '//
    If strOutputProcedure = "" Then
        strReturn = "No output procedure specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Clear the instruction array
    '//
    clngInstructionCount = 0
    ReDim caryInstructions(clngInstructionCount)
    clngSheetCount = 0
    clngChartCount = 0
    
    '//
    '// Log the XML generation
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " -------> Generating output XML"
    Close #21
    
    '//
    '// Process the report output
    '// - creates the report output from the extract data into the global temporary table
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "Result"
    objParameter.Type = adVarChar
    objParameter.Size = 2000
    objParameter.Direction = adParamReturnValue
    objCommand.Parameters.Append objParameter
    objCommand.CommandText = "{ ? = call " & strOutputProcedure & " }"
    Call objCommand.Execute
    strResult = objCommand.Parameters("Result").Value
    If Trim$(strResult) <> "*OK" Then
        strReturn = strResult
        GoTo tagExit
    End If
    Set objParameter = Nothing
    Set objCommand = Nothing
    
    '//
    '// Log the XML retrieve
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " -------> Converting output XML"
    Close #21
    
    '//
    '// Set the XML table
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    objCommand.CommandText = "{ call xlxml_object.setTable }"
    Call objCommand.Execute
    Set objCommand = Nothing
    
    '//
    '// Log the XML retrieve
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " -------> Retrieving output XML"
    Close #21
    
    '//
    '// Retrieve the report xml commands
    '//
    strXML = ""
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    objCommand.CommandText = "select xml_data from pld_xml order by xml_indx asc"
    Set objRecordset = objCommand.Execute
    Do While objRecordset.EOF = False
        strXML = strXML & CStr(objRecordset.Fields(0).Value)
        objRecordset.MoveNext
    Loop
    objRecordset.Close
    Set objRecordset = Nothing
    Set objCommand = Nothing
    
    '//
    '// Log the XML parsing
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " -------> Parsing output XML"
    Close #21
    
    '//
    '// Parse the XML output file
    '//
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.loadXML(strXML) = False Then
        strReturn = objXMLDocument.parseError.reason
        GoTo tagExit
    End If
    For i = 0 To objXMLDocument.childNodes.Length - 1
        Call ProcessOutputNode(objXMLDocument.childNodes(i))
    Next
    Set objXMLDocument = Nothing
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:

    '//
    '// ADODB connection object present
    '//
    If Not cobjConnection Is Nothing Then
        If cobjConnection.Errors.Count <> 0 Then
            strReturn = ""
            For i = 0 To (cobjConnection.Errors.Count - 1)
                If strReturn <> "" Then
                    strReturn = strReturn & Chr(13) & Chr(10)
                End If
                strReturn = strReturn & cobjConnection.Errors(i).Description
            Next
            cobjConnection.Errors.Clear
            Err.Clear
        End If
    End If
    
    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "Visual Basic Error (PerformOutputV2): " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Destroy the ADODB objects
    '//
    Set objRecordset = Nothing
    Set objParameter = Nothing
    Set objCommand = Nothing
    
    '//
    '// Return the status
    '//
    PerformOutputV2 = strReturn
    
End Function
Private Function PerformOutputV1(ByVal strOutputProcedure As String, ByVal strLogPath As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim strResult As String
    Dim strXML As String
    Dim objCommand As ADODB.Command
    Dim objParameter As ADODB.Parameter
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
    '// Connection must be available
    '//
    If cobjConnection Is Nothing Then
        strReturn = "Database connection missing - unable to perform output"
        GoTo tagExit
    End If
    
    '//
    '// Output procedure must be supplied
    '//
    If strOutputProcedure = "" Then
        strReturn = "No output procedure specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Clear the instruction array
    '//
    clngInstructionCount = 0
    ReDim caryInstructions(clngInstructionCount)
    clngSheetCount = 0
    clngChartCount = 0
    
    '//
    '// Log the XML generation
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " -------> Generating output XML"
    Close #21
    
    '//
    '// Process the report output
    '// - creates the report output from the extract data into the global temporary table
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "Result"
    objParameter.Type = adVarChar
    objParameter.Size = 2000
    objParameter.Direction = adParamReturnValue
    objCommand.Parameters.Append objParameter
    objCommand.CommandText = "{ ? = call " & strOutputProcedure & " }"
    Call objCommand.Execute
    strResult = objCommand.Parameters("Result").Value
    If Trim$(strResult) <> "*OK" Then
        strReturn = strResult
        GoTo tagExit
    End If
    
    '//
    '// Log the XML retrieve
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " -------> Retrieving output XML"
    Close #21
    
    '//
    '// Retrieve the report xml commands
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "Result"
    objParameter.Type = adVarChar
    objParameter.Size = 4000
    objParameter.Direction = adParamOutput
    objCommand.Parameters.Append objParameter
    objCommand.CommandText = "{ call xlxml_object.getReport(?) }"
    objCommand.Prepared = True
    strXML = ""
    Do
        Call objCommand.Execute
        strResult = objCommand.Parameters("Result").Value
        If strResult <> "**" Then
            strXML = strXML & strResult
        End If
    Loop Until strResult = "**"
    
    '//
    '// Log the XML parsing
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " -------> Parsing output XML"
    Close #21
    
    '//
    '// Parse the XML output file
    '//
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.loadXML(strXML) = False Then
        strReturn = objXMLDocument.parseError.reason
        GoTo tagExit
    End If
    For i = 0 To objXMLDocument.childNodes.Length - 1
        Call ProcessOutputNode(objXMLDocument.childNodes(i))
    Next
    Set objXMLDocument = Nothing
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:

    '//
    '// ADODB connection object present
    '//
    If Not cobjConnection Is Nothing Then
        If cobjConnection.Errors.Count <> 0 Then
            strReturn = ""
            For i = 0 To (cobjConnection.Errors.Count - 1)
                If strReturn <> "" Then
                    strReturn = strReturn & Chr(13) & Chr(10)
                End If
                strReturn = strReturn & cobjConnection.Errors(i).Description
            Next
            cobjConnection.Errors.Clear
            Err.Clear
        End If
    End If
    
    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "Visual Basic Error (PerformOutputV1): " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Destroy the ADODB objects
    '//
    Set objParameter = Nothing
    Set objCommand = Nothing
    
    '//
    '// Return the status
    '//
    PerformOutputV1 = strReturn
    
End Function
Private Function PerformExecute(ByRef strDayNumber As String, _
                                ByRef strPeriodEnd As String, _
                                ByRef strPeriodYearEnd As String, _
                                ByRef strMonthEnd As String, _
                                ByRef strMonthYearEnd As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim objCommand As ADODB.Command
    Dim objParameter As ADODB.Parameter
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return string
    '//
    strReturn = "*OK"
    
    '//
    '// Connection must be available
    '//
    If cobjConnection Is Nothing Then
        strReturn = "Database connection missing - unable to perform execute"
        GoTo tagExit
    End If
    
    '//
    '// Performs the schedule procedure
    '// - Returns the schedule properties for the database system date
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "DayNumber"
    objParameter.Type = adVarChar
    objParameter.Size = 1
    objParameter.Direction = adParamOutput
    objCommand.Parameters.Append objParameter
    
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "PeriodEnd"
    objParameter.Type = adVarChar
    objParameter.Size = 1
    objParameter.Direction = adParamOutput
    objCommand.Parameters.Append objParameter
    
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "PeriodYearEnd"
    objParameter.Type = adVarChar
    objParameter.Size = 1
    objParameter.Direction = adParamOutput
    objCommand.Parameters.Append objParameter
    
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "MonthEnd"
    objParameter.Type = adVarChar
    objParameter.Size = 1
    objParameter.Direction = adParamOutput
    objCommand.Parameters.Append objParameter
    
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "MonthYearEnd"
    objParameter.Type = adVarChar
    objParameter.Size = 1
    objParameter.Direction = adParamOutput
    objCommand.Parameters.Append objParameter
    
    '//
    '// Execute the command and retrieve the output parameter values
    '//
    objCommand.CommandText = "{ call mfjpln_schedule.getToday(?, ?, ?, ?, ?) }"
    Call objCommand.Execute
    strDayNumber = objCommand.Parameters("DayNumber").Value
    strPeriodEnd = objCommand.Parameters("PeriodEnd").Value
    strPeriodYearEnd = objCommand.Parameters("PeriodYearEnd").Value
    strMonthEnd = objCommand.Parameters("MonthEnd").Value
    strMonthYearEnd = objCommand.Parameters("MonthYearEnd").Value
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:

    '//
    '// ADODB connection object present
    '//
    If Not cobjConnection Is Nothing Then
        If cobjConnection.Errors.Count <> 0 Then
            strReturn = ""
            For i = 0 To (cobjConnection.Errors.Count - 1)
                If strReturn <> "" Then
                    strReturn = strReturn & Chr(13) & Chr(10)
                End If
                strReturn = strReturn & cobjConnection.Errors(i).Description
            Next
            cobjConnection.Errors.Clear
            Err.Clear
        End If
    End If
    
    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "Visual Basic Error (PerformExecute): " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Close and destroy the connection
    '//
    Set objParameter = Nothing
    Set objCommand = Nothing
    
    '//
    '// Return the status
    '//
    PerformExecute = strReturn
    
End Function
Private Function PerformExtract(ByVal strExtractProcedure As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim strResult As String
    Dim objCommand As ADODB.Command
    Dim objParameter As ADODB.Parameter
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return string
    '//
    strReturn = "*OK"
    
    '//
    '// Connection must be available
    '//
    If cobjConnection Is Nothing Then
        strReturn = "Database connection missing - unable to perform extract"
        GoTo tagExit
    End If
    
    '//
    '// Extract procedure must be supplied
    '//
    If strExtractProcedure = "" Then
        strReturn = "No extract procedure specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Performs the requested extract procedure
    '// - extracts the report data into a global temporary table or aggregation tables
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "Result"
    objParameter.Type = adVarChar
    objParameter.Size = 2000
    objParameter.Direction = adParamReturnValue
    objCommand.Parameters.Append objParameter
    objCommand.CommandText = "{ ? = call " & strExtractProcedure & " }"
    Call objCommand.Execute
    strResult = objCommand.Parameters("Result").Value
    If Trim$(strResult) <> "*OK" Then
        strReturn = strResult
        GoTo tagExit
    End If
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:

    '//
    '// ADODB connection object present
    '//
    If Not cobjConnection Is Nothing Then
        If cobjConnection.Errors.Count <> 0 Then
            strReturn = ""
            For i = 0 To (cobjConnection.Errors.Count - 1)
                If strReturn <> "" Then
                    strReturn = strReturn & Chr(13) & Chr(10)
                End If
                strReturn = strReturn & cobjConnection.Errors(i).Description
            Next
            cobjConnection.Errors.Clear
            Err.Clear
        End If
    End If
    
    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "Visual Basic Error (PerformExtract): " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Close and destroy the connection
    '//
    Set objParameter = Nothing
    Set objCommand = Nothing
    
    '//
    '// Return the status
    '//
    PerformExtract = strReturn
    
End Function

Private Sub PerformDebug(ByVal strDebugMessage As String)
    
    '//
    '// Output the debug message
    '//
    Open App.Path & "\xl_report_debug.txt" For Append As #22
    Print #22, Format(Now, "YYYYMMDDHHMMSS") & " : " & strDebugMessage
    Close #22
    
End Sub
Private Function PerformConnection(ByVal strConnectionString As String) As String

    Dim i As Long
    Dim strReturn As String
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return string
    '//
    strReturn = "*OK"
    
    '//
    '// Connection string must be supplied
    '//
    If strConnectionString = "" Then
        strReturn = "No connection string specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Close any existing connection
    '//
    If Not cobjConnection Is Nothing Then
        On Error Resume Next
        cobjConnection.Close
        On Error GoTo 0
    End If
    
    '//
    '// Create the connection to the database server
    '//
    Set cobjConnection = New ADODB.Connection
    cobjConnection.ConnectionString = strConnectionString
    cobjConnection.Open
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:

    '//
    '// ADODB connection object present
    '//
    If Not cobjConnection Is Nothing Then
        If cobjConnection.Errors.Count <> 0 Then
            strReturn = ""
            For i = 0 To (cobjConnection.Errors.Count - 1)
                If strReturn <> "" Then
                    strReturn = strReturn & Chr(13) & Chr(10)
                End If
                strReturn = strReturn & cobjConnection.Errors(i).Description
            Next
            cobjConnection.Errors.Clear
            Err.Clear
        End If
    End If
    Set cobjConnection = Nothing
    
    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "Visual Basic Error (PerformConnection): " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:
    
    '//
    '// Return the status
    '//
    PerformConnection = strReturn
    
End Function
Public Function BatchStreamExecution(ByVal strBatchStream As String) As String

    Dim i As Long
    Dim dblReturn As Double
    Dim bolCancel As Boolean
    Dim strReturn As String
    Dim strResult As String
    Dim strExecute As String
    Dim strLogPath As String
    Dim strDayNumber As String
    Dim strPeriodEnd As String
    Dim strPeriodYearEnd As String
    Dim strMonthEnd As String
    Dim strMonthYearEnd As String
    Dim objXMLDocument As MSXML.DOMDocument

    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return string
    '//
    bolCancel = False
    strReturn = "*OK"
    
    '//
    '// Clear the batch array
    '//
    clngBatchCount = 0
    ReDim caryBatches(clngBatchCount)
    
    '//
    '// Parse the XML batch stream file
    '//
    clngBatchCount = 0
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.Load(strBatchStream) = False Then
        strReturn = objXMLDocument.parseError.reason
        GoTo tagExit
    End If
    For i = 0 To objXMLDocument.childNodes.Length - 1
        Call ProcessBatchNode(objXMLDocument.childNodes(i))
    Next
    Set objXMLDocument = Nothing
    
    '//
    '// Batch stream must be valid
    '//
    If clngBatchCount = 0 Then
        strReturn = "Batch stream file does not contain a batch stream tag - unable to process"
        GoTo tagExit
    End If
    If caryBatches(0).Action <> "BATCHSTREAM" Then
        strReturn = "Batch stream file does not contain a batch stream tag - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Log directory must be supplied
    '//
    If caryBatches(0).Value02 = "" Then
        strReturn = "Batch stream log directory not specified - unable to process"
        GoTo tagExit
    End If
    If Mid$(caryBatches(0).Value02, Len(caryBatches(0).Value02), 1) <> "\" Then
        caryBatches(0).Value02 = caryBatches(0).Value02 & "\"
    End If
    
    '//
    '// Log name must be supplied
    '//
    If caryBatches(0).Value03 = "" Then
        strReturn = "Batch stream log name not specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Construct the batch log path name
    '//
    strLogPath = caryBatches(0).Value02 & Format(Now, "YYYYMMDD") & "_" & caryBatches(0).Value03
    
    '//
    '// Connection string must be supplied
    '//
    If caryBatches(0).Value04 = "" Then
        strReturn = "Batch stream connection string not specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Connect to the database
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " **START BATCH STREAM** " & caryBatches(0).Value01
    Close #21
    RaiseEvent TaskProcessing("(CONNECTION) " & caryBatches(0).Value01, bolCancel)
    If bolCancel = True Then
        GoTo tagCancel
    End If
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> START CONNECTION: " & caryBatches(0).Value01
    Close #21
    strResult = PerformConnection(caryBatches(0).Value04)
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> STOP CONNECTION: RESULT: " & strResult
    Close #21
    If strResult <> "*OK" Then
        strReturn = strResult
        GoTo tagExit
    End If
    
    '//
    '// Retrieve the execution properties for the date (database system date)
    '//
    strDayNumber = "0"
    strPeriodEnd = "N"
    strPeriodYearEnd = "N"
    strMonthEnd = "N"
    strMonthYearEnd = "N"
    RaiseEvent TaskProcessing("(DATE EXECUTION) " & caryBatches(0).Value01, bolCancel)
    If bolCancel = True Then
        GoTo tagCancel
    End If
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> START DATE EXECUTION: " & caryBatches(0).Value01
    Close #21
    strResult = PerformExecute(strDayNumber, strPeriodEnd, strPeriodYearEnd, strMonthEnd, strMonthYearEnd)
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> STOP DATE EXECUTION: RESULT: " & strResult
    Close #21
    If strResult <> "*OK" Then
        strReturn = strResult
        GoTo tagExit
    End If
                                
    '//
    '// Execute the batch actions
    '//
    For i = 1 To clngBatchCount - 1
        Select Case caryBatches(i).Action
            Case "BATCHJOB"
                RaiseEvent TaskProcessing("(EXECUTION TEST) " & caryBatches(i).Value01, bolCancel)
                If bolCancel = True Then
                    GoTo tagCancel
                End If
                strExecute = "*NO"
                If strDayNumber = "2" And caryBatches(i).Value03 = "Y" Then
                    strExecute = "*YES"
                End If
                If strDayNumber = "3" And caryBatches(i).Value04 = "Y" Then
                    strExecute = "*YES"
                End If
                If strDayNumber = "4" And caryBatches(i).Value05 = "Y" Then
                    strExecute = "*YES"
                End If
                If strDayNumber = "5" And caryBatches(i).Value06 = "Y" Then
                    strExecute = "*YES"
                End If
                If strDayNumber = "6" And caryBatches(i).Value07 = "Y" Then
                    strExecute = "*YES"
                End If
                If strDayNumber = "7" And caryBatches(i).Value08 = "Y" Then
                    strExecute = "*YES"
                End If
                If strDayNumber = "1" And caryBatches(i).Value09 = "Y" Then
                    strExecute = "*YES"
                End If
                If strPeriodEnd = "Y" And caryBatches(i).Value10 = "Y" Then
                    strExecute = "*YES"
                End If
                If strPeriodYearEnd = "Y" And caryBatches(i).Value11 = "Y" Then
                    strExecute = "*YES"
                End If
                If strMonthEnd = "Y" And caryBatches(i).Value12 = "Y" Then
                    strExecute = "*YES"
                End If
                If strMonthYearEnd = "Y" And caryBatches(i).Value13 = "Y" Then
                    strExecute = "*YES"
                End If
                Open strLogPath For Append As #21
                Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> EXECUTE REPORT STREAM: " & caryBatches(i).Value01 & " RESULT: " & strExecute
                Close #21
                If strExecute = "*YES" Then
                    RaiseEvent TaskProcessing("(EXECUTING) " & caryBatches(i).Value01, bolCancel)
                    If bolCancel = True Then
                        GoTo tagCancel
                    End If
                    Open strLogPath For Append As #21
                    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> START JOB STREAM: " & caryBatches(i).Value01
                    Close #21
                    strResult = ReportStreamExecution(caryBatches(i).Value02)
                    Open strLogPath For Append As #21
                    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> STOP JOB STREAM: RESULT: " & strResult
                    Close #21
                    If strResult = "*CANCELLED" Then
                        GoTo tagCancel
                    End If
                End If
        End Select
    Next
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " **STOP BATCH STREAM** " & caryBatches(0).Value01
    Close #21
    
    '//
    '// FTP the log files when required
    '//
    If caryBatches(0).Value05 <> "" _
    And caryBatches(0).Value06 <> "" _
    And caryBatches(0).Value07 <> "" _
    And caryBatches(0).Value08 <> "" _
    And caryBatches(0).Value09 <> "" Then
        strResult = PerformTransfer(strLogPath, caryBatches(0).Value05, caryBatches(0).Value06, caryBatches(0).Value07, caryBatches(0).Value08, caryBatches(0).Value09, "N")
    End If
    
    '//
    '// Shell command the log files when required
    '//
    If caryBatches(0).Value10 <> "" Then
        dblReturn = Shell(caryBatches(0).Value10, 0)
    End If
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function cancel
'//
tagCancel:

    '//
    '// Output the cancel information
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " **CANCEL BATCH STREAM** " & caryBatches(0).Value01
    Close #21
    strReturn = "*CANCELLED"

'//
'// Function error
'//
tagError:

    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "Visual Basic Error (BatchStreamExecution): " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Clear the batch array
    '//
    clngBatchCount = 0
    ReDim caryBatches(clngBatchCount)
    Set objXMLDocument = Nothing
    
    '//
    '// Return the status
    '//
    BatchStreamExecution = strReturn
    
End Function
Public Function ReportStreamExecution(ByVal strReportStream As String) As String

    Dim i As Long
    Dim dblReturn As Double
    Dim bolCancel As Boolean
    Dim strReturn As String
    Dim strResult As String
    Dim strLogPath As String
    Dim strOutputPath As String
    Dim objXMLDocument As MSXML.DOMDocument

    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return string
    '//
    bolCancel = False
    strReturn = "*OK"
    
    '//
    '// Clear the action array
    '//
    clngActionCount = 0
    ReDim caryActions(clngActionCount)
    
    '//
    '// Parse the XML configuration file
    '//
    clngActionCount = 0
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.Load(strReportStream) = False Then
        strReturn = objXMLDocument.parseError.reason
        GoTo tagExit
    End If
    For i = 0 To objXMLDocument.childNodes.Length - 1
        Call ProcessActionNode(objXMLDocument.childNodes(i))
    Next
    Set objXMLDocument = Nothing
    
    '//
    '// Report stream must be valid
    '//
    If clngActionCount = 0 Then
        strReturn = "Report stream file does not contain a report stream tag - unable to process"
        GoTo tagExit
    End If
    If caryActions(0).Action <> "REPORTSTREAM" Then
        strReturn = "Report stream file does not contain a report stream tag - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Log directory must be supplied
    '//
    If caryActions(0).Value02 = "" Then
        strReturn = "Report stream log directory not specified - unable to process"
        GoTo tagExit
    End If
    If Mid$(caryActions(0).Value02, Len(caryActions(0).Value02), 1) <> "\" Then
        caryActions(0).Value02 = caryActions(0).Value02 & "\"
    End If
    
    '//
    '// Log name must be supplied
    '//
    If caryActions(0).Value03 = "" Then
        strReturn = "Report stream log name not specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Construct the report log path name
    '//
    strLogPath = caryActions(0).Value02 & Format(Now, "YYYYMMDD") & "_" & caryActions(0).Value03
    
    '//
    '// Output directory must be supplied
    '//
    If caryActions(0).Value04 = "" Then
        strReturn = "Report stream output directory not specified - unable to process"
        GoTo tagExit
    End If
    If Mid$(caryActions(0).Value04, Len(caryActions(0).Value04), 1) <> "\" Then
        caryActions(0).Value04 = caryActions(0).Value04 & "\"
    End If
    strOutputPath = caryActions(0).Value04
    
    '//
    '// Initialise (clear) the contents of the output directory when required
    '//
    If UCase(caryActions(0).Value05) = "Y" Then
        On Error Resume Next
        Kill strOutputPath & "*.xls"
        On Error GoTo tagError
    End If
    
    '//
    '// Connection string must be supplied
    '//
    If caryActions(0).Value06 = "" Then
        strReturn = "Report stream connection string not specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Connect to the database
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " **START REPORT STREAM** " & caryActions(0).Value01
    Close #21
    RaiseEvent TaskProcessing("(CONNECTION) " & caryActions(0).Value01, bolCancel)
    If bolCancel = True Then
        GoTo tagCancel
    End If
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> START CONNECTION: " & caryActions(0).Value01
    Close #21
    strResult = PerformConnection(caryActions(0).Value06)
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> STOP CONNECTION: RESULT: " & strResult
    Close #21
    If strResult <> "*OK" Then
        strReturn = strResult
        GoTo tagExit
    End If
    
    '//
    '// Execute the report actions
    '//
    For i = 1 To clngActionCount - 1
        Select Case caryActions(i).Action
            Case "REPORTEXTRACT"
                RaiseEvent TaskProcessing(caryActions(i).Value01, bolCancel)
                If bolCancel = True Then
                    GoTo tagCancel
                End If
                Open strLogPath For Append As #21
                Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> START EXTRACT: " & caryActions(i).Value01
                Close #21
                strResult = PerformExtract(caryActions(i).Value02)
                Open strLogPath For Append As #21
                Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> STOP EXTRACT: RESULT: " & strResult
                Close #21
            Case "REPORTOUTPUT"
                RaiseEvent TaskProcessing("RETRIEVING OUTPUT: " & caryActions(i).Value01, bolCancel)
                If bolCancel = True Then
                    GoTo tagCancel
                End If
                Open strLogPath For Append As #21
                Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> START RETRIEVING OUTPUT: " & caryActions(i).Value01
                Close #21
                strResult = PerformOutputV2(caryActions(i).Value02, strLogPath)
                Open strLogPath For Append As #21
                Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> STOP RETRIEVING OUTPUT: RESULT: " & strResult
                Close #21
                If strResult = "*OK" Then
                    RaiseEvent TaskProcessing("GENERATING OUTPUT: " & caryActions(i).Value01, bolCancel)
                    If bolCancel = True Then
                        GoTo tagCancel
                    End If
                    Open strLogPath For Append As #21
                    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> START GENERATING OUTPUT: " & caryActions(i).Value01
                    Close #21
                    strResult = PerformGeneration(strOutputPath, caryActions(i).Value03, caryActions(i).Value04, "Y", strLogPath)
                    Open strLogPath For Append As #21
                    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> STOP GENERATING OUTPUT: RESULT: " & strResult
                    Close #21
                End If
        End Select
    Next
    
    '//
    '// FTP the output files when required
    '//
    If caryActions(0).Value07 <> "" _
    And caryActions(0).Value08 <> "" _
    And caryActions(0).Value09 <> "" _
    And caryActions(0).Value10 <> "" Then
        RaiseEvent TaskProcessing("TRANSFERING OUTPUT: " & caryActions(0).Value01, bolCancel)
        If bolCancel = True Then
            GoTo tagCancel
        End If
        Open strLogPath For Append As #21
        Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> START TRANSFERING OUTPUT: " & caryActions(0).Value01
        Close #21
        strResult = PerformTransfer(strOutputPath, caryActions(0).Value07, caryActions(0).Value08, caryActions(0).Value09, caryActions(0).Value10, "*.xls", caryActions(0).Value11)
        Open strLogPath For Append As #21
        Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> STOP TRANSFERING OUTPUT: RESULT: " & strResult
        Close #21
    End If
    
    '//
    '// Shell command the output files when required
    '//
    If caryActions(0).Value12 <> "" Then
        RaiseEvent TaskProcessing("TRANSFERING OUTPUT SHELL: " & caryActions(0).Value01, bolCancel)
        If bolCancel = True Then
            GoTo tagCancel
        End If
        Open strLogPath For Append As #21
        Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " ---> START TRANSFERING OUTPUT SHELL: " & caryActions(0).Value01
        Close #21
        dblReturn = Shell(caryActions(0).Value12, 0)
    End If
    
    '//
    '// Close the report stream
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " **STOP REPORT STREAM** " & caryActions(0).Value01
    Close #21
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function cancel
'//
tagCancel:

    '//
    '// Output the cancel information
    '//
    Open strLogPath For Append As #21
    Print #21, Format(Now, "YYYY/MM/DD:HH:MM:SS") & " **CANCEL REPORT STREAM** " & caryActions(0).Value01
    Close #21
    strReturn = "*CANCELLED"

'//
'// Function error
'//
tagError:

    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "Visual Basic Error (ReportStreamExecution): " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Clear the action array
    '//
    clngActionCount = 0
    ReDim caryActions(clngActionCount)
    Set objXMLDocument = Nothing
    
    '//
    '// Return the status
    '//
    ReportStreamExecution = strReturn
    
End Function
Private Sub FormatStyle(objXLBook As Excel.Workbook)

    Dim objXLStyle As Excel.Style
    
    '//
    '// Perform the format setting
    '//
    Set objXLStyle = objXLBook.Styles("Normal")
    objXLStyle.Font.Name = FONT_NAME_NORMAL
    objXLStyle.Font.Size = FONT_SIZE_NORMAL
    objXLStyle.Font.Bold = FONT_BOLD_NORMAL
    
    Set objXLStyle = objXLBook.Styles.Add(TYPE_HEADING_01)
    objXLStyle.Font.Name = FONT_NAME_HEADING_01
    objXLStyle.Font.Size = FONT_SIZE_HEADING_01
    objXLStyle.Font.Bold = FONT_BOLD_HEADING_01
    objXLStyle.Font.Color = COLOR_FOR_HEADING
    objXLStyle.Interior.Color = COLOR_BAC_HEADING
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_HEADING_02)
    objXLStyle.Font.Name = FONT_NAME_HEADING_02
    objXLStyle.Font.Size = FONT_SIZE_HEADING_02
    objXLStyle.Font.Bold = FONT_BOLD_HEADING_02
    objXLStyle.Font.Color = COLOR_FOR_HEADING
    objXLStyle.Interior.Color = COLOR_BAC_HEADING
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_HEADING_03)
    objXLStyle.Font.Name = FONT_NAME_HEADING_03
    objXLStyle.Font.Size = FONT_SIZE_HEADING_03
    objXLStyle.Font.Bold = FONT_BOLD_HEADING_03
    objXLStyle.Font.Color = COLOR_FOR_HEADING
    objXLStyle.Interior.Color = COLOR_BAC_HEADING
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_HEADING_04)
    objXLStyle.Font.Name = FONT_NAME_HEADING_04
    objXLStyle.Font.Size = FONT_SIZE_HEADING_04
    objXLStyle.Font.Bold = FONT_BOLD_HEADING_04
    objXLStyle.Font.Color = COLOR_FOR_HEADING
    objXLStyle.Interior.Color = COLOR_BAC_HEADING
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_HEADING_05)
    objXLStyle.Font.Name = FONT_NAME_HEADING_05
    objXLStyle.Font.Size = FONT_SIZE_HEADING_05
    objXLStyle.Font.Bold = FONT_BOLD_HEADING_05
    objXLStyle.Font.Color = COLOR_FOR_HEADING
    objXLStyle.Interior.Color = COLOR_BAC_HEADING
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_HEADING_06)
    objXLStyle.Font.Name = FONT_NAME_HEADING_06
    objXLStyle.Font.Size = FONT_SIZE_HEADING_06
    objXLStyle.Font.Bold = FONT_BOLD_HEADING_06
    objXLStyle.Font.Color = COLOR_FOR_HEADING
    objXLStyle.Interior.Color = COLOR_BAC_HEADING
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_HEADING_07)
    objXLStyle.Font.Name = FONT_NAME_HEADING_07
    objXLStyle.Font.Size = FONT_SIZE_HEADING_07
    objXLStyle.Font.Bold = FONT_BOLD_HEADING_07
    objXLStyle.Font.Color = COLOR_FOR_HEADING
    objXLStyle.Interior.Color = COLOR_BAC_HEADING
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_HEADING_HI)
    objXLStyle.Font.Name = FONT_NAME_HEADING_HI
    objXLStyle.Font.Size = FONT_SIZE_HEADING_HI
    objXLStyle.Font.Bold = FONT_BOLD_HEADING_HI
    objXLStyle.Font.Color = COLOR_FOR_HEADING_HI
    objXLStyle.Interior.Color = COLOR_BAC_HEADING_HI
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_HEADING_SM)
    objXLStyle.Font.Name = FONT_NAME_HEADING_SM
    objXLStyle.Font.Size = FONT_SIZE_HEADING_SM
    objXLStyle.Font.Bold = FONT_BOLD_HEADING_SM
    objXLStyle.Font.Color = COLOR_FOR_HEADING
    objXLStyle.Interior.Color = COLOR_BAC_HEADING
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_SUMMARY_01)
    objXLStyle.Font.Name = FONT_NAME_SUMMARY_01
    objXLStyle.Font.Size = FONT_SIZE_SUMMARY_01
    objXLStyle.Font.Bold = FONT_BOLD_SUMMARY_01
    objXLStyle.Font.Color = COLOR_FOR_SUMMARY
    objXLStyle.Interior.Color = COLOR_BAC_SUMMARY_01
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_SUMMARY_02)
    objXLStyle.Font.Name = FONT_NAME_SUMMARY_02
    objXLStyle.Font.Size = FONT_SIZE_SUMMARY_02
    objXLStyle.Font.Bold = FONT_BOLD_SUMMARY_02
    objXLStyle.Font.Color = COLOR_FOR_SUMMARY
    objXLStyle.Interior.Color = COLOR_BAC_SUMMARY_02
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_SUMMARY_03)
    objXLStyle.Font.Name = FONT_NAME_SUMMARY_03
    objXLStyle.Font.Size = FONT_SIZE_SUMMARY_03
    objXLStyle.Font.Bold = FONT_BOLD_SUMMARY_03
    objXLStyle.Font.Color = COLOR_FOR_SUMMARY
    objXLStyle.Interior.Color = COLOR_BAC_SUMMARY_03
    
    Set objXLStyle = objXLBook.Styles.Add(TYPE_SUMMARY_04)
    objXLStyle.Font.Name = FONT_NAME_SUMMARY_04
    objXLStyle.Font.Size = FONT_SIZE_SUMMARY_04
    objXLStyle.Font.Bold = FONT_BOLD_SUMMARY_04
    objXLStyle.Font.Color = COLOR_FOR_SUMMARY
    objXLStyle.Interior.Color = COLOR_BAC_SUMMARY_04
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_SUMMARY_05)
    objXLStyle.Font.Name = FONT_NAME_SUMMARY_05
    objXLStyle.Font.Size = FONT_SIZE_SUMMARY_05
    objXLStyle.Font.Bold = FONT_BOLD_SUMMARY_05
    objXLStyle.Font.Color = COLOR_FOR_SUMMARY
    objXLStyle.Interior.Color = COLOR_BAC_SUMMARY_05
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_SUMMARY_06)
    objXLStyle.Font.Name = FONT_NAME_SUMMARY_06
    objXLStyle.Font.Size = FONT_SIZE_SUMMARY_06
    objXLStyle.Font.Bold = FONT_BOLD_SUMMARY_06
    objXLStyle.Font.Color = COLOR_FOR_SUMMARY
    objXLStyle.Interior.Color = COLOR_BAC_SUMMARY_06
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_SUMMARY_07)
    objXLStyle.Font.Name = FONT_NAME_SUMMARY_07
    objXLStyle.Font.Size = FONT_SIZE_SUMMARY_07
    objXLStyle.Font.Bold = FONT_BOLD_SUMMARY_07
    objXLStyle.Font.Color = COLOR_FOR_SUMMARY
    objXLStyle.Interior.Color = COLOR_BAC_SUMMARY_07
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_HEADING)
    objXLStyle.Font.Name = FONT_NAME_HEADING
    objXLStyle.Font.Size = FONT_SIZE_HEADING
    objXLStyle.Font.Bold = FONT_BOLD_HEADING
    objXLStyle.Font.Color = COLOR_FOR_SUB_HEADING
    objXLStyle.Interior.Color = COLOR_BAC_SUB_HEADING
                
    Set objXLStyle = objXLBook.Styles.Add(TYPE_DETAIL)
    objXLStyle.Font.Name = FONT_NAME_DETAIL
    objXLStyle.Font.Size = FONT_SIZE_DETAIL
    objXLStyle.Font.Bold = FONT_BOLD_DETAIL
    objXLStyle.Font.Color = COLOR_FOR_DETAIL
    objXLStyle.Interior.Color = COLOR_BAC_DETAIL

    Set objXLStyle = Nothing
        
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
    '// Create the private variables
    '//
    Set cobjConnection = Nothing
    
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


Private Sub Class_Terminate()

    '//
    '// Destroy the private objects
    '//
    If Not cobjConnection Is Nothing Then
        On Error Resume Next
        cobjConnection.Close
        On Error GoTo 0
    End If
    Set cobjConnection = Nothing
    
End Sub


