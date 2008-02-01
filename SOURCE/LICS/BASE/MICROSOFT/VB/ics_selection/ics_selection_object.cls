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
        Value21 As String
        Value22 As String
        Value23 As String
        Value24 As String
        Value25 As String
        Value26 As String
        Value27 As String
        Value28 As String
        Value29 As String
        Value30 As String
    End Type
    Private Type ctypExecutionType
        Identifier As String
        caryList() As ctypListType
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
        strReturn = "*ERROR (ICS_SELECTION:Execute): No identifier specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Query must be specified
    '//
    If strQuery = "" Then
        strReturn = "*ERROR (ICS_SELECTION:Execute): No query specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Initialise the execution list array
    '//
    ReDim Preserve caryExecution(clngExecutionCount)
    caryExecution(clngExecutionCount).Identifier = strIdentifier
    caryExecution(clngExecutionCount).clngListCount = 0
    caryExecution(clngExecutionCount).cbolMore = False
    ReDim caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount)
    
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
    If objRecordset.Fields.Count > 30 Then
        objRecordset.Close
        strReturn = "*ERROR (ICS_SELECTION:Execute): Query returns more than maximum supported columns (30) - unable to process"
        GoTo tagExit
    End If
    Do While objRecordset.EOF = False
        ReDim Preserve caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount)
        For i = 0 To objRecordset.Fields.Count - 1
            If IsNull(objRecordset.Fields(i).Value) = False Then
                strValue = CStr(objRecordset.Fields(i).Value)
                Select Case i
                    Case Is = 0
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value01 = strValue
                    Case Is = 1
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value02 = strValue
                    Case Is = 2
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value03 = strValue
                    Case Is = 3
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value04 = strValue
                    Case Is = 4
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value05 = strValue
                    Case Is = 5
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value06 = strValue
                    Case Is = 6
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value07 = strValue
                    Case Is = 7
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value08 = strValue
                    Case Is = 8
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value09 = strValue
                    Case Is = 9
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value10 = strValue
                    Case Is = 10
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value11 = strValue
                    Case Is = 11
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value12 = strValue
                    Case Is = 12
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value13 = strValue
                    Case Is = 13
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value14 = strValue
                    Case Is = 14
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value15 = strValue
                    Case Is = 15
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value16 = strValue
                    Case Is = 16
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value17 = strValue
                    Case Is = 17
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value18 = strValue
                    Case Is = 18
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value19 = strValue
                    Case Is = 19
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value20 = strValue
                    Case Is = 20
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value21 = strValue
                    Case Is = 21
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value22 = strValue
                    Case Is = 22
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value23 = strValue
                    Case Is = 23
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value24 = strValue
                    Case Is = 24
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value25 = strValue
                    Case Is = 25
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value26 = strValue
                    Case Is = 26
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value27 = strValue
                    Case Is = 27
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value28 = strValue
                    Case Is = 28
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value29 = strValue
                    Case Is = 29
                        caryExecution(clngExecutionCount).caryList(caryExecution(clngExecutionCount).clngListCount).Value30 = strValue
                End Select
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
            strReturn = "*ERROR (ICS_SELECTION:Execute): "
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
        strReturn = "*ERROR (ICS_SELECTION:Execute): Visual Basic Error " & Err.Number & " : " & Err.Description
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
Public Property Get ListValue02(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 02 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue02 = ""
        Exit Property
    End If
    ListValue02 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value02
    
End Property
Public Property Get ListValue03(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 03 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue03 = ""
        Exit Property
    End If
    ListValue03 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value03
    
End Property
Public Property Get ListValue04(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 04 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue04 = ""
        Exit Property
    End If
    ListValue04 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value04
    
End Property
Public Property Get ListValue05(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 05 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue05 = ""
        Exit Property
    End If
    ListValue05 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value05
    
End Property
Public Property Get ListValue06(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 06 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue06 = ""
        Exit Property
    End If
    ListValue06 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value06
    
End Property
Public Property Get ListValue07(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 07 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue07 = ""
        Exit Property
    End If
    ListValue07 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value07
    
End Property
Public Property Get ListValue08(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 08 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue08 = ""
        Exit Property
    End If
    ListValue08 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value08
    
End Property
Public Property Get ListValue10(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 10 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue10 = ""
        Exit Property
    End If
    ListValue10 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value10
    
End Property
Public Property Get ListValue11(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 11 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue11 = ""
        Exit Property
    End If
    ListValue11 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value11
    
End Property
Public Property Get ListValue12(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 12 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue12 = ""
        Exit Property
    End If
    ListValue12 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value12
    
End Property
Public Property Get ListValue13(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 13 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue13 = ""
        Exit Property
    End If
    ListValue13 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value13
    
End Property
Public Property Get ListValue14(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 14 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue14 = ""
        Exit Property
    End If
    ListValue14 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value14
    
End Property
Public Property Get ListValue15(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 15 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue15 = ""
        Exit Property
    End If
    ListValue15 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value15
    
End Property
Public Property Get ListValue16(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 16 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue16 = ""
        Exit Property
    End If
    ListValue16 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value16
    
End Property
Public Property Get ListValue17(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 17 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue17 = ""
        Exit Property
    End If
    ListValue17 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value17
    
End Property
Public Property Get ListValue18(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 18 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue18 = ""
        Exit Property
    End If
    ListValue18 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value18
    
End Property
Public Property Get ListValue19(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 19 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue19 = ""
        Exit Property
    End If
    ListValue19 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value19
    
End Property
Public Property Get ListValue20(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 20 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue20 = ""
        Exit Property
    End If
    ListValue20 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value20
    
End Property
Public Property Get ListValue21(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 21 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue21 = ""
        Exit Property
    End If
    ListValue21 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value21
    
End Property
Public Property Get ListValue22(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 22 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue22 = ""
        Exit Property
    End If
    ListValue22 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value22
    
End Property
Public Property Get ListValue23(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 23 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue23 = ""
        Exit Property
    End If
    ListValue23 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value23
    
End Property
Public Property Get ListValue24(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 24 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue24 = ""
        Exit Property
    End If
    ListValue24 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value24
    
End Property
Public Property Get ListValue25(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 25 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue25 = ""
        Exit Property
    End If
    ListValue25 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value25
    
End Property
Public Property Get ListValue26(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 26 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue26 = ""
        Exit Property
    End If
    ListValue26 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value26
    
End Property
Public Property Get ListValue27(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 27 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue27 = ""
        Exit Property
    End If
    ListValue27 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value27
    
End Property
Public Property Get ListValue28(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 28 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue28 = ""
        Exit Property
    End If
    ListValue28 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value28
    
End Property
Public Property Get ListValue29(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 29 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue29 = ""
        Exit Property
    End If
    ListValue29 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value29
    
End Property
Public Property Get ListValue30(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 30 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue30 = ""
        Exit Property
    End If
    ListValue30 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value30
    
End Property
Public Property Get ListValue09(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 09 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue09 = ""
        Exit Property
    End If
    ListValue09 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value09
    
End Property
Public Property Get ListValue01(ByVal strIdentifier As String, ByVal lngListIndex As Long) As String

    '//
    '// List value 01 property
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
    Or lngListIndex > UBound(caryExecution(lngExecutionIndex).caryList) Then
        ListValue01 = ""
        Exit Property
    End If
    ListValue01 = caryExecution(lngExecutionIndex).caryList(lngListIndex).Value01
    
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


