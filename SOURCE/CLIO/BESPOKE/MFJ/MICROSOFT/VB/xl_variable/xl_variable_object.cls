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
    Private cobjSecurity As XL_SECURITY.Object
    Private Type ctypVariableType
        Type As String
        Code As String
    End Type
    Private caryVariable() As ctypVariableType
    Private clngVariableCount As Long
Public Sub SetVariable(ByVal strType As String, ByVal strCode As String)

    '//
    '// Value property
    '//
    ReDim Preserve caryVariable(clngVariableCount)
    caryVariable(clngVariableCount).Type = strType
    caryVariable(clngVariableCount).Code = strCode
    clngVariableCount = clngVariableCount + 1
    
End Sub
Public Property Set Security(objSecurity As XL_SECURITY.Object)

    '//
    '// Security object property
    '//
    Set cobjSecurity = objSecurity
    
End Property
Public Function UpdateDatabase() As String

    Dim i As Long
    Dim strReturn As String
    Dim strWork As String
    Dim objConnection As ADODB.Connection
    Dim objCommand As ADODB.Command
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return value
    '//
    strReturn = "*OK"
    
    '//
    '// Get the connection from the security object
    '//
    Set objConnection = cobjSecurity.GetConnection
    
    '//
    '// Begin the transaction
    '//
    objConnection.BeginTrans
    
    '//
    '// Process the report output
    '// - creates the report output into the XML CLOB
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = objConnection
    objCommand.CommandType = adCmdText
    
    '//
    '// Clear the variable data
    '//
    strWork = "delete from pld_variable"
    objCommand.CommandText = strWork
    Call objCommand.Execute
    
    '//
    '// Insert the variable data
    '//
    For i = 0 To clngVariableCount - 1
        strWork = "insert into pld_variable"
        strWork = strWork & " (var_type, var_code)"
        strWork = strWork & " values('" & cobjSecurity.FixString(caryVariable(i).Type) & "','" & cobjSecurity.FixString(caryVariable(i).Code) & "')"
        objCommand.CommandText = strWork
        Call objCommand.Execute
    Next
    
    '//
    '// Commit the transaction
    '//
    objConnection.CommitTrans
    
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
    If Not objConnection Is Nothing Then
        If objConnection.Errors.Count <> 0 Then
            strReturn = "*ERROR (XL_Variable:UpdateDatabase): "
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
        strReturn = "*ERROR (XL_Variable:UpdateDatabase): Visual Basic Error " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Destroy the local objects
    '//
    Set objCommand = Nothing
    Set objConnection = Nothing
    
    '//
    '// Return the function
    '//
    UpdateDatabase = strReturn
    
End Function

Private Sub Class_Initialize()

    '//
    '// Create the private objects
    '//
    Set cobjSecurity = Nothing
    
    '//
    '// Initialise the private variables
    '//
    clngVariableCount = 0
    ReDim caryVariable(clngVariableCount)
    
End Sub


Private Sub Class_Terminate()

    '//
    '// Destroy the private objects
    '//
    Set cobjSecurity = Nothing
    
End Sub


