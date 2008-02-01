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
    '// Private action variables
    '//
    Private cobjConnection As ADODB.Connection
    Private Type ctypSecurityType
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
    End Type
    Private carySecurity() As ctypSecurityType
    Private clngSecurityCount As Long
Public Function FixString(ByVal strString As String) As String

    Dim i As Long
    Dim strWork As String
    
    '//
    '// Fix single quotes
    '//
    strWork = ""
    For i = 1 To Len(strString)
        Select Case Mid$(strString, i, 1)
            Case Is = "'"
                strWork = strWork & "''"
            Case Else
                strWork = strWork & Mid$(strString, i, 1)
        End Select
    Next
    FixString = strWork

End Function
Public Function Initialise(ByVal strSecurityFile As String, ByVal strUser As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim bolAuthorised As Boolean
    Dim objXMLDocument As MSXML.DOMDocument
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return value
    '//
    strReturn = "*OK"
    
    '//
    '// Security file must be supplied
    '//
    If strSecurityFile = "" Then
        strReturn = "*ERROR (XL_SECURITY:Initialise): No security file specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// User must be supplied
    '//
    If strUser = "" Then
        strReturn = "*ERROR (XL_SECURITY:Initialise): No user specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Parse the XML security file
    '//
    clngSecurityCount = 0
    ReDim carySecurity(clngSecurityCount)
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.Load(strSecurityFile) = False Then
        strReturn = "*ERROR (XL_SECURITY:Initialise): Security Parsing Error: " & objXMLDocument.parseError.reason
        GoTo tagExit
    End If
    For i = 0 To objXMLDocument.childNodes.length - 1
        Call ProcessSecurityNode(objXMLDocument.childNodes(i))
    Next
    Set objXMLDocument = Nothing
    
    '//
    '// System security must be valid
    '//
    If clngSecurityCount = 0 Then
        strReturn = "*ERROR (XL_SECURITY:Initialise): Security file does not contain a system security tag - unable to process"
        GoTo tagExit
    End If
    If carySecurity(0).Action <> "SYSTEMSECURITY" Then
        strReturn = "*ERROR (XL_SECURITY:Initialise): Security file does not contain a system security tag - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// User must be authorised
    '//
    bolAuthorised = False
    For i = 1 To clngSecurityCount - 1
        If carySecurity(i).Action = "USER" And UCase(carySecurity(i).Value01) = UCase(strUser) Then
            bolAuthorised = True
            Exit For
        End If
    Next
    If bolAuthorised = False Then
        strReturn = "*ERROR (XL_SECURITY:Initialise): User " & strUser & " not authorised - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Create the connection to the database server
    '//
    Set cobjConnection = New ADODB.Connection
    cobjConnection.ConnectionString = carySecurity(0).Value01
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
            strReturn = "*ERROR (XL_SECURITY:Initialise): "
            For i = 0 To (cobjConnection.Errors.Count - 1)
                If strReturn <> "" Then
                    strReturn = strReturn
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
        strReturn = "*ERROR (XL_SECURITY:Initialise): Visual Basic Error " & Err.Number & " : " & Err.Description
    End If

'//
'// Function exit
'//
tagExit:

    '//
    '// Destroy the local objects
    '//
    Set objXMLDocument = Nothing
    
    '//
    '// Return the function
    '//
    Initialise = strReturn
    
End Function
Public Function GetConnection() As ADODB.Connection

    '//
    '// Return the connection
    '//
    Set GetConnection = cobjConnection
    
End Function
Private Sub ProcessSecurityNode(objNode As MSXML.IXMLDOMNode)

    Dim i As Long
    Dim j As Long
    
    '//
    '// Load the actions array when required
    '//
    Select Case UCase(objNode.nodeName)
        Case "SYSTEMSECURITY"
            ReDim Preserve carySecurity(clngSecurityCount)
            carySecurity(clngSecurityCount).Action = "SYSTEMSECURITY"
            For j = 0 To objNode.attributes.length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "CONNECTIONSTRING"
                        carySecurity(clngSecurityCount).Value01 = objNode.attributes(j).Text
                End Select
            Next
            clngSecurityCount = clngSecurityCount + 1
        Case "USER"
            ReDim Preserve carySecurity(clngSecurityCount)
            carySecurity(clngSecurityCount).Action = "USER"
            For j = 0 To objNode.attributes.length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "IDENTIFIER"
                        carySecurity(clngSecurityCount).Value01 = objNode.attributes(j).Text
                End Select
            Next
            clngSecurityCount = clngSecurityCount + 1
    End Select

    '//
    '// Process the any child nodes
    '//
    For i = 0 To objNode.childNodes.length - 1
        Call ProcessSecurityNode(objNode.childNodes(i))
    Next
        
End Sub
Private Sub Class_Initialize()

    '//
    '// Initialise the class objects
    '//
    Set cobjConnection = Nothing
    
End Sub


Private Sub Class_Terminate()

    '//
    '// Destroy the class objects
    '//
    If Not cobjConnection Is Nothing Then
        If cobjConnection.State = adStateOpen Then
            cobjConnection.Close
        End If
    End If
    Set cobjConnection = Nothing
    
End Sub


