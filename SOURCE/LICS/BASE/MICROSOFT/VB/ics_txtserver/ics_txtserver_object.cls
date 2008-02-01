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
    Private cstrXML As String
Public Property Let XMLString(strXML As String)

    '//
    '// XML string property
    '//
    cstrXML = strXML
    
End Property
Public Property Get XMLString() As String

    '//
    '// XML string property
    '//
    XMLString = cstrXML
    
End Property
Public Property Set Security(objSecurity As ICS_SECURITY.Object)

    '//
    '// Security object property
    '//
    Set cobjSecurity = objSecurity
    
End Property
Public Function SetTextFile(ByVal strProcedure As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim strResult As String
    Dim lngIndex As Long
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
        strReturn = "*ERROR (ICS_TXTSERVER:SetTextfile): No procedure specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// XML string must be supplied
    '//
    If cstrXML = "" Then
        strReturn = "*ERROR (ICS_TXTSERVER:SetTextfile): No XML string specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Get the connection from the security object
    '//
    Set objConnection = cobjSecurity.GetConnection
    
    '//
    '// Load the text file data arrays
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = objConnection
    objCommand.CommandType = adCmdText
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "Buffer"
    objParameter.Type = adVarChar
    objParameter.Size = 2000
    objParameter.Direction = adParamInput
    objCommand.Parameters.Append objParameter
    objCommand.CommandText = "{ call lics_textfile.set_data(?) }"
    objCommand.Prepared = True
    objCommand.Parameters("Buffer").Value = "*STR"
    Call objCommand.Execute
    If Len(cstrXML) <> 0 Then
        lngIndex = 1
        Do
            objCommand.Parameters("Buffer").Value = Mid$(cstrXML, lngIndex, 2000)
            Call objCommand.Execute
            lngIndex = lngIndex + 2000
        Loop Until lngIndex >= Len(cstrXML)
    End If
    objCommand.Parameters("Buffer").Value = "*END"
    Call objCommand.Execute
    
    '//
    '// Process the text file read procedure
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = objConnection
    objCommand.CommandType = adCmdText
    objCommand.CommandText = "{ call lics_textfile.read_textfile('" & cobjSecurity.FixString(strProcedure) & "') }"
    Call objCommand.Execute
    
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
            strReturn = "*ERROR (ICS_TXTSERVER:SetTextfile): "
            For i = 0 To (objConnection.Errors.Count - 1)
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
        strReturn = "*ERROR (ICS_XLSERVER:SetTextfile): Visual Basic Error " & Err.Number & " : " & Err.Description
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
    SetTextFile = strReturn
    
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


