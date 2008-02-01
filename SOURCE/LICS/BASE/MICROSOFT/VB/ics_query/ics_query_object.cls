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
    '// Private variables
    '//
    Private cobjSecurity As ICS_SECURITY.Object
    Private Type ctypListType
        caryValue() As String
    End Type
    Private Type ctypExecutionType
        Identifier As String
        caryMeta() As String
        caryList() As ctypListType
        clngMetaCount As Long
        clngListCount As Long
        cbolMore As Boolean
    End Type
    Private caryExecution() As ctypExecutionType
    Private clngExecutionCount As Long
Public Property Set Security(objSecurity As ICS_SECURITY.Object)

    '//
    '// Security object property
    '//
    Set cobjSecurity = objSecurity
    
End Property
Public Function Execute(ByVal strIdentifier As String, _
                        ByVal strQuery As String, _
                        ByVal lngListSize As Long) As String
    
    Dim i As Long
    Dim strReturn As String
    Dim strValue As String
    Dim objConnection As ADODB.Connection
    Dim objCommand As ADODB.Command
    Dim objRecordset As ADODB.Recordset
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return value
    '//
    strReturn = "*OK"
    
    '//
    '// Identifier must be specified
    '//
    If strIdentifier = "" Then
        strReturn = "*ERROR (ICS_QUERY:Execute): No identifier specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Query must be specified
    '//
    If strQuery = "" Then
        strReturn = "*ERROR (ICS_QUERY:Execute): No query specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Initialise the execution list array
    '//
    ReDim Preserve caryExecution(clngExecutionCount)
    caryExecution(clngExecutionCount).Identifier = strIdentifier
    caryExecution(clngExecutionCount).clngMetaCount = 0
    caryExecution(clngExecutionCount).clngListCount = 0
    caryExecution(clngExecutionCount).cbolMore = False
    ReDim caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount)
    ReDim caryExecution(clngExecutionCount).caryMeta(caryExecution(clngExecutionCount).clngMetaCount)
    
    '//
    '// Get the connection from the security object
    '//
    Set objConnection = cobjSecurity.GetConnection
    
    '//
    '// Link the command to the connection and set the type
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = objConnection
    objCommand.CommandType = adCmdText
    Set objRecordset = New ADODB.Recordset
    
    '//
    '// Retrieve the selection rows
    '//
    objCommand.CommandText = strQuery
    Set objRecordset = objCommand.Execute
    If objRecordset.EOF = False Then
        For i = 0 To objRecordset.Fields.Count - 1
            ReDim Preserve caryExecution(clngExecutionCount).caryMeta(caryExecution(clngExecutionCount).clngMetaCount)
            caryExecution(clngExecutionCount).caryMeta(caryExecution(clngExecutionCount).clngMetaCount) = objRecordset.Fields(i).Name
            caryExecution(clngExecutionCount).clngMetaCount = caryExecution(clngExecutionCount).clngMetaCount + 1
        Next
    End If
    Do While objRecordset.EOF = False
        ReDim Preserve caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount)
        ReDim caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).caryValue(caryExecution(clngExecutionCount).clngMetaCount)
        For i = 0 To objRecordset.Fields.Count - 1
            If IsNull(objRecordset.Fields(i).Value) = False Then
                strValue = CStr(objRecordset.Fields(i).Value)
                caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).caryValue(i) = strValue
            End If
        Next
        objRecordset.MoveNext
        If lngListSize = 0 Then
            caryExecution(clngExecutionCount).clngListCount = caryExecution(clngExecutionCount).clngListCount + 1
        Else
            caryExecution(clngExecutionCount).clngListCount = caryExecution(clngExecutionCount).clngListCount + 1
            If caryExecution(clngExecutionCount).clngListCount = lngListSize Then
                If objRecordset.EOF = False Then
                    caryExecution(clngExecutionCount).cbolMore = True
                End If
                Exit Do
            End If
        End If
    Loop
    objRecordset.Close
    
    '//
    '// Increment the execution count
    '//
    clngExecutionCount = clngExecutionCount + 1
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:

    '//
    '// ADODB connection object
    '//
    If Not objConnection Is Nothing Then
        If objConnection.Errors.Count <> 0 Then
            strReturn = "*ERROR (ICS_QUERY:Execute): "
            For i = 0 To (objConnection.Errors.Count - 1)
                If strReturn <> "" Then
                    strReturn = strReturn
                End If
                strReturn = strReturn & objConnection.Errors(i).Description
            Next
            objConnection.Errors.Clear
            Err.Clear
        End If
    End If
    
    '//
    '// Visual basic error
    '//
    If Err.Number <> 0 Then
        strReturn = "*ERROR (ICS_QUERY:Execute): Visual Basic Error " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Destroy the local objects
    '//
    Set objRecordset = Nothing
    Set objCommand = Nothing
    Set objConnection = Nothing
    
    '//
    '// Return the function
    '//
    Execute = strReturn
    
End Function
Public Property Get ListMore(ByVal strIdentifier As String) As Boolean

    '//
    '// List count reference
    '//
    Dim i As Long
    Dim lngExecutionIndex As Long
    lngExecutionIndex = -1
    For i = 0 To clngExecutionCount - 1
        If UCase(caryExecution(i).Identifier) = UCase(strIdentifier) Then
            lngExecutionIndex = i
            Exit For
        End If
    Next
    If lngExecutionIndex = -1 Then
        ListMore = False
        Exit Property
    End If
    ListMore = caryExecution(lngExecutionIndex).cbolMore
    
End Property
Public Property Get MetaUpper(ByVal strIdentifier As String) As Long

    '//
    '// List count reference
    '//
    Dim i As Long
    Dim lngExecutionIndex As Long
    lngExecutionIndex = -1
    For i = 0 To clngExecutionCount - 1
        If UCase(caryExecution(i).Identifier) = UCase(strIdentifier) Then
            lngExecutionIndex = i
            Exit For
        End If
    Next
    If lngExecutionIndex = -1 Then
        MetaUpper = 0
        Exit Property
    End If
    MetaUpper = UBound(caryExecution(lngExecutionIndex).caryMeta)
    
End Property
Public Property Get ListUpper(ByVal strIdentifier As String) As Long

    '//
    '// List count reference
    '//
    Dim i As Long
    Dim lngExecutionIndex As Long
    lngExecutionIndex = -1
    For i = 0 To clngExecutionCount - 1
        If UCase(caryExecution(i).Identifier) = UCase(strIdentifier) Then
            lngExecutionIndex = i
            Exit For
        End If
    Next
    If lngExecutionIndex = -1 Then
        ListUpper = 0
        Exit Property
    End If
    ListUpper = UBound(caryExecution(lngExecutionIndex).caryList)
    
End Property

Public Property Get MetaLower(ByVal strIdentifier As String) As Long

    '//
    '// List count reference
    '//
    Dim i As Long
    Dim lngExecutionIndex As Long
    lngExecutionIndex = -1
    For i = 0 To clngExecutionCount - 1
        If UCase(caryExecution(i).Identifier) = UCase(strIdentifier) Then
            lngExecutionIndex = i
            Exit For
        End If
    Next
    If lngExecutionIndex = -1 Then
        MetaLower = 0
        Exit Property
    End If
    MetaLower = LBound(caryExecution(lngExecutionIndex).caryMeta)
    
End Property
Public Property Get ListLower(ByVal strIdentifier As String) As Long

    '//
    '// List count reference
    '//
    Dim i As Long
    Dim lngExecutionIndex As Long
    lngExecutionIndex = -1
    For i = 0 To clngExecutionCount - 1
        If UCase(caryExecution(i).Identifier) = UCase(strIdentifier) Then
            lngExecutionIndex = i
            Exit For
        End If
    Next
    If lngExecutionIndex = -1 Then
        ListLower = 0
        Exit Property
    End If
    ListLower = LBound(caryExecution(lngExecutionIndex).caryList)
    
End Property
Public Property Get MetaCount(ByVal strIdentifier As String) As Long

    '//
    '// List count reference
    '//
    Dim i As Long
    Dim lngExecutionIndex As Long
    lngExecutionIndex = -1
    For i = 0 To clngExecutionCount - 1
        If UCase(caryExecution(i).Identifier) = UCase(strIdentifier) Then
            lngExecutionIndex = i
            Exit For
        End If
    Next
    If lngExecutionIndex = -1 Then
        MetaCount = 0
        Exit Property
    End If
    MetaCount = caryExecution(lngExecutionIndex).clngMetaCount
    
End Property
Public Property Get ListCount(ByVal strIdentifier As String) As Long

    '//
    '// List count reference
    '//
    Dim i As Long
    Dim lngExecutionIndex As Long
    lngExecutionIndex = -1
    For i = 0 To clngExecutionCount - 1
        If UCase(caryExecution(i).Identifier) = UCase(strIdentifier) Then
            lngExecutionIndex = i
            Exit For
        End If
    Next
    If lngExecutionIndex = -1 Then
        ListCount = 0
        Exit Property
    End If
    ListCount = caryExecution(lngExecutionIndex).clngListCount
    
End Property
Public Property Get ExecutionCount() As Long

    '//
    '// Execution count reference
    '//
    ExecutionCount = clngExecutionCount
    
End Property
Public Property Get MetaName(ByVal strIdentifier As String, ByVal lngMetaIndex As Long) As String

    '//
    '// List value property
    '//
    Dim i As Long
    Dim lngExecutionIndex As Long
    lngExecutionIndex = -1
    For i = 0 To clngExecutionCount - 1
        If UCase(caryExecution(i).Identifier) = UCase(strIdentifier) Then
            lngExecutionIndex = i
            Exit For
        End If
    Next
    If lngExecutionIndex = -1 _
    Or lngMetaIndex < LBound(caryExecution(lngExecutionIndex).caryMeta) _
    Or lngMetaIndex > UBound(caryExecution(lngExecutionIndex).caryMeta) Then
        MetaName = ""
        Exit Property
    End If
    MetaName = caryExecution(lngExecutionIndex).caryMeta(lngMetaIndex)
    
End Property

Public Property Get ListValue(ByVal strIdentifier As String, ByVal lngListIndex As Long, ByVal lngMetaIndex As Long) As String

    '//
    '// List value property
    '//
    Dim i As Long
    Dim lngExecutionIndex As Long
    lngExecutionIndex = -1
    For i = 0 To clngExecutionCount - 1
        If UCase(caryExecution(i).Identifier) = UCase(strIdentifier) Then
            lngExecutionIndex = i
            Exit For
        End If
    Next
    If lngExecutionIndex = -1 _
    Or lngListIndex < LBound(caryExecution(lngExecutionIndex).caryList) _
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) _
    Or lngMetaIndex < LBound(caryExecution(lngExecutionIndex).caryMeta) _
    Or lngMetaIndex > UBound(caryExecution(lngExecutionIndex).caryMeta) Then
        ListValue = ""
        Exit Property
    End If
    ListValue = caryExecution(lngExecutionIndex).caryList(lngListIndex).caryValue(lngMetaIndex)
    
End Property
Private Sub Class_Initialize()

    '//
    '// Create the private objects
    '//
    Set cobjSecurity = Nothing
    
    '//
    '// Initialise the execution array
    '//
    clngExecutionCount = 0
    ReDim caryExecution(clngExecutionCount)
    
End Sub


Private Sub Class_Terminate()

    '//
    '// Destroy the private objects
    '//
    Set cobjSecurity = Nothing
    
End Sub


