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
    Private cstrXML As String
Public Property Get XMLString() As String

    '//
    '// XML string property
    '//
    XMLString = cstrXML
    
End Property
Public Property Set Security(objSecurity As XL_SECURITY.Object)

    '//
    '// Security object property
    '//
    Set cobjSecurity = objSecurity
    
End Property

Public Function Process(ByVal strProcedure As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim strResult As String
    Dim objConnection As ADODB.Connection
    Dim objCommand As ADODB.Command
    Dim objParameter As ADODB.Parameter
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return value
    '//
    strReturn = "*OK"
    
    '//
    '// Procedure must be supplied
    '//
    If strProcedure = "" Then
        strReturn = "*ERROR (XL_SERVER:Process): No procedure specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Get the connection from the security object
    '//
    Set objConnection = cobjSecurity.GetConnection
    
    '//
    '// Process the report output
    '// - creates the report output into the XML CLOB
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = objConnection
    objCommand.CommandType = adCmdText
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "Result"
    objParameter.Type = adVarChar
    objParameter.Size = 512
    objParameter.Direction = adParamReturnValue
    objCommand.Parameters.Append objParameter
    objCommand.CommandText = "{ ? = call " & strProcedure & " }"
    Call objCommand.Execute
    strResult = objCommand.Parameters("Result").Value
    If Trim$(strResult) <> "*OK" Then
        strReturn = "*ERROR (XL_SERVER:Process): " & strResult
        GoTo tagExit
    End If
    
    '//
    '// Retrieve the report XML commands
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = objConnection
    objCommand.CommandType = adCmdText
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "Result"
    objParameter.Type = adVarChar
    objParameter.Size = 4000
    objParameter.Direction = adParamOutput
    objCommand.Parameters.Append objParameter
    objCommand.CommandText = "{ call xlxml_object.getReport(?) }"
    objCommand.Prepared = True
    cstrXML = ""
    Do
        Call objCommand.Execute
        strResult = objCommand.Parameters("Result").Value
        If strResult <> "**" Then
            cstrXML = cstrXML & strResult
        End If
    Loop Until strResult = "**"
    
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
            strReturn = "*ERROR (XL_SERVER:Process): "
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
        strReturn = "*ERROR (XL_SERVER:Process): Visual Basic Error " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Destroy the local objects
    '//
    Set objParameter = Nothing
    Set objCommand = Nothing
    Set objConnection = Nothing
    
    '//
    '// Return the function
    '//
    Process = strReturn
    
End Function

Private Sub Class_Initialize()

    '//
    '// Create the private objects
    '//
    Set cobjSecurity = Nothing
    
End Sub


Private Sub Class_Terminate()

    '//
    '// Destroy the private objects
    '//
    Set cobjSecurity = Nothing
    
End Sub


