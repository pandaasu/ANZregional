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
    Private cstrMenu As String
    
    Private Type ctypSiteType
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
    Private carySite() As ctypSiteType
    Private clngSiteCount As Long

    Private Type ctypNodeType
        Level As Integer
        ObjType As String
        ObjCode As String
        ObjText As String
        ObjStatus As String
        LnkSequence As Integer
        LnkType As String
        LnkCode As String
        LnkText As String
        LnkScript As String
        LnkStatus As String
    End Type
    Private caryNode() As ctypNodeType
    Private clngNodeCount As Long
Public Property Get NodeCount() As Long

    '//
    '// Node count reference
    '//
    NodeCount = clngNodeCount - 1
    
End Property
Public Property Get NodeLevel(ByVal lngIndex As Long) As Integer

    '//
    '// Node level property
    '//
    NodeLevel = caryNode(lngIndex).Level
    
End Property
Public Property Get NodeObjectType(ByVal lngIndex As Long) As String

    '//
    '// Node object type property
    '//
    NodeObjectType = caryNode(lngIndex).ObjType
    
End Property
Public Property Get NodeObjectCode(ByVal lngIndex As Long) As String

    '//
    '// Node object code property
    '//
    NodeObjectCode = caryNode(lngIndex).ObjCode
    
End Property
Public Property Get NodeObjectText(ByVal lngIndex As Long) As String

    '//
    '// Node object text property
    '//
    NodeObjectText = caryNode(lngIndex).ObjText
    
End Property
Public Property Get NodeObjectStatus(ByVal lngIndex As Long) As String

    '//
    '// Node object status property
    '//
    NodeObjectStatus = caryNode(lngIndex).ObjStatus
    
End Property
Public Property Get NodeLinkSequence(ByVal lngIndex As Long) As Integer

    '//
    '// Node link sequence property
    '//
    NodeLinkSequence = caryNode(lngIndex).LnkSequence
    
End Property
Public Property Get NodeLinkType(ByVal lngIndex As Long) As String

    '//
    '// Node link type property
    '//
    NodeLinkType = caryNode(lngIndex).LnkType
    
End Property
Public Property Get NodeLinkCode(ByVal lngIndex As Long) As String

    '//
    '// Node link code property
    '//
    NodeLinkCode = caryNode(lngIndex).LnkCode
    
End Property
Public Property Get NodeLinkText(ByVal lngIndex As Long) As String

    '//
    '// Node link text property
    '//
    NodeLinkText = caryNode(lngIndex).LnkText
    
End Property
Public Property Get NodeLinkScript(ByVal lngIndex As Long) As String

    '//
    '// Node link script property
    '//
    NodeLinkScript = caryNode(lngIndex).LnkScript
    
End Property
Public Property Get NodeLinkStatus(ByVal lngIndex As Long) As String

    '//
    '// Node link status property
    '//
    NodeLinkStatus = caryNode(lngIndex).LnkStatus
    
End Property
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
Public Function InitialiseCheck(ByVal strSecurityFile As String, ByVal strUser As String, ByVal strOption As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim strResult As String
    Dim objXMLDocument As MSXML.DOMDocument
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
    '// Security file must be supplied
    '//
    If strSecurityFile = "" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseCheck): No security file specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// User must be supplied
    '//
    If strUser = "" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseCheck): No user specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Option must be supplied
    '//
    If strOption = "" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseCheck): No option specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Parse the XML security file
    '//
    clngSecurityCount = 0
    ReDim carySecurity(clngSecurityCount)
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.Load(strSecurityFile) = False Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseCheck): Security Parsing Error: " & objXMLDocument.parseError.reason
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
        strReturn = "*ERROR (ICS_SECURITY:InitialiseCheck): Security file does not contain a security tag - unable to process"
        GoTo tagExit
    End If
    If carySecurity(0).Action <> "SECURITY" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseCheck): Security file does not contain a security tag - unable to process"
        GoTo tagExit
    End If
    If carySecurity(0).Value02 <> "" Then
        carySecurity(0).Value01 = Replace(carySecurity(0).Value01, "..PWD..", PasswordUnEncrypt(carySecurity(0).Value02), 1, -1, 1)
    End If
    
    '//
    '// Create the connection to the database server
    '//
    Set cobjConnection = New ADODB.Connection
    cobjConnection.ConnectionString = carySecurity(0).Value01
    cobjConnection.Open
    
    '//
    '// Execute the security check function
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "Result"
    objParameter.Type = adVarChar
    objParameter.Size = 4000
    objParameter.Direction = adParamReturnValue
    objCommand.Parameters.Append objParameter
    objCommand.CommandText = "{ ? = call lics_security.check_security('" & strUser & "','" & strOption & "') }"
    Call objCommand.Execute
    strResult = objCommand.Parameters("Result").Value
    If Trim$(strResult) <> "*OK" Then
        strReturn = strResult
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
            strReturn = "*ERROR (ICS_SECURITY:InitialiseCheck): "
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
        strReturn = "*ERROR (ICS_SECURITY:InitialiseCheck): Visual Basic Error " & Err.Number & " : " & Err.Description
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
    InitialiseCheck = strReturn
    
End Function
Public Function InitialiseSiteCheck(ByVal strSecurityFile As String, ByVal strSite As String, ByVal strUser As String, ByVal strOption As String) As String

    Dim i As Long
    Dim bolSite As Boolean
    Dim strConnectionString As String
    Dim strReturn As String
    Dim strResult As String
    Dim objXMLDocument As MSXML.DOMDocument
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
    '// Security file must be supplied
    '//
    If strSecurityFile = "" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSite): No security file specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Site must be supplied
    '//
    If strSite = "" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSiteCheck): No site specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// User must be supplied
    '//
    If strUser = "" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSiteCheck): No user specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Option must be supplied
    '//
    If strOption = "" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSiteCheck): No option specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Parse the XML security file
    '//
    clngSecurityCount = 0
    ReDim carySecurity(clngSecurityCount)
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.Load(strSecurityFile) = False Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSiteCheck): Security Parsing Error: " & objXMLDocument.parseError.reason
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
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSiteCheck): Security file does not contain any security data - unable to process"
        GoTo tagExit
    End If
    If carySecurity(0).Action <> "SECURITY" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSiteCheck): Security file does not contain a security tag - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Site must exist
    '//
    bolSite = False
    strConnectionString = ""
    For i = 0 To clngSecurityCount - 1
        If carySecurity(i).Action = "SITE" And UCase(carySecurity(i).Value01) = UCase(strSite) Then
            bolSite = True
            strConnectionString = carySecurity(i).Value05
            If carySecurity(i).Value06 <> "" Then
                strConnectionString = Replace(strConnectionString, "..PWD..", PasswordUnEncrypt(carySecurity(i).Value06), 1, -1, 1)
            End If
            Exit For
        End If
    Next
    If bolSite = False Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSiteCheck): Site " & strSite & " is not configured"
    End If
    
    '//
    '// Create the connection to the database server
    '//
    Set cobjConnection = New ADODB.Connection
    cobjConnection.ConnectionString = strConnectionString
    cobjConnection.Open
    
    '//
    '// Execute the security check function
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    Set objParameter = New ADODB.Parameter
    objParameter.Name = "Result"
    objParameter.Type = adVarChar
    objParameter.Size = 4000
    objParameter.Direction = adParamReturnValue
    objCommand.Parameters.Append objParameter
    objCommand.CommandText = "{ ? = call lics_security.check_security('" & strUser & "','" & strOption & "') }"
    Call objCommand.Execute
    strResult = objCommand.Parameters("Result").Value
    If Trim$(strResult) <> "*OK" Then
        strReturn = strResult
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
            strReturn = "*ERROR (ICS_SECURITY:InitialiseSiteCheck): "
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
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSiteCheck): Visual Basic Error " & Err.Number & " : " & Err.Description
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
    InitialiseSiteCheck = strReturn
    
End Function
Public Function Initialise(ByVal strSecurityFile As String) As String

    Dim i As Long
    Dim strReturn As String
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
        strReturn = "*ERROR (ICS_SECURITY:Initialise): No security file specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Parse the XML security file
    '//
    clngSecurityCount = 0
    ReDim carySecurity(clngSecurityCount)
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.Load(strSecurityFile) = False Then
        strReturn = "*ERROR (ICS_SECURITY:Initialise): Security Parsing Error: " & objXMLDocument.parseError.reason
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
        strReturn = "*ERROR (ICS_SECURITY:Initialise): Security file does not contain a security tag - unable to process"
        GoTo tagExit
    End If
    If carySecurity(0).Action <> "SECURITY" Then
        strReturn = "*ERROR (ICS_SECURITY:Initialise): Security file does not contain a security tag - unable to process"
        GoTo tagExit
    End If
    If carySecurity(0).Value02 <> "" Then
        carySecurity(0).Value01 = Replace(carySecurity(0).Value01, "..PWD..", PasswordUnEncrypt(carySecurity(0).Value02), 1, -1, 1)
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
            strReturn = "*ERROR (ICS_SECURITY:Initialise): "
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
        strReturn = "*ERROR (ICS_SECURITY:Initialise): Visual Basic Error " & Err.Number & " : " & Err.Description
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
Public Function InitialiseSite(ByVal strSecurityFile As String, ByVal strSite As String) As String

    Dim i As Long
    Dim bolSite As Boolean
    Dim strConnectionString As String
    Dim strReturn As String
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
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSite): No security file specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Site must be supplied
    '//
    If strSite = "" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSite): No site specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Parse the XML security file
    '//
    clngSecurityCount = 0
    ReDim carySecurity(clngSecurityCount)
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.Load(strSecurityFile) = False Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSite): Security Parsing Error: " & objXMLDocument.parseError.reason
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
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSite): Security file does not contain any security data - unable to process"
        GoTo tagExit
    End If
    If carySecurity(0).Action <> "SECURITY" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSite): Security file does not contain a security tag - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Site must exist
    '//
    bolSite = False
    strConnectionString = ""
    For i = 0 To clngSecurityCount - 1
        If carySecurity(i).Action = "SITE" And UCase(carySecurity(i).Value01) = UCase(strSite) Then
            bolSite = True
            strConnectionString = carySecurity(i).Value05
            If carySecurity(i).Value06 <> "" Then
                strConnectionString = Replace(strConnectionString, "..PWD..", PasswordUnEncrypt(carySecurity(i).Value06), 1, -1, 1)
            End If
            Exit For
        End If
    Next
    If bolSite = False Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSite): Site " & strSite & " is not configured"
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
            strReturn = "*ERROR (ICS_SECURITY:InitialiseSite): "
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
        strReturn = "*ERROR (ICS_SECURITY:InitialiseSite): Visual Basic Error " & Err.Number & " : " & Err.Description
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
    InitialiseSite = strReturn
    
End Function
Public Function GetSites(ByVal strSecurityFile As String) As String

    Dim i As Long
    Dim strReturn As String
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
        strReturn = "*ERROR (ICS_SECURITY:GetSites): No security file specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Parse the XML security file
    '//
    clngSiteCount = 0
    ReDim carySite(clngSiteCount)
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.Load(strSecurityFile) = False Then
        strReturn = "*ERROR (ICS_SECURITY:GetSites): Security Parsing Error: " & objXMLDocument.parseError.reason
        GoTo tagExit
    End If
    For i = 0 To objXMLDocument.childNodes.length - 1
        Call ProcessSiteNode(objXMLDocument.childNodes(i))
    Next
    Set objXMLDocument = Nothing
    
    '//
    '// Site must be valid
    '//
    If clngSiteCount = 0 Then
        strReturn = "*ERROR (ICS_SECURITY:GetSites): Security file does not contain any site data - unable to process"
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
        strReturn = "*ERROR (ICS_SECURITY:GetSites): Visual Basic Error " & Err.Number & " : " & Err.Description
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
    GetSites = strReturn
    
End Function
Public Function CheckOption(ByVal strUser As String, ByVal strOption As String) As String

    Dim i As Long
    Dim strReturn As String
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
    '// User must be supplied
    '//
    If strUser = "" Then
        strReturn = "*ERROR (ICS_SECURITY:CheckOption): No user specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Identifier must be specified
    '//
    If cobjConnection Is Nothing Then
        strReturn = "*ERROR (ICS_SECURITY:CheckOption): No connection - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Initialise the menu array
    '//
    clngNodeCount = 0
    ReDim caryNode(clngNodeCount)
    
    '//
    '// Link the command to the connection and set the type
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    Set objRecordset = New ADODB.Recordset
    
    '//
    '// Retrieve the menu data
    '//
    objCommand.CommandText = "select * from table(lics_security.get_security('" & strUser & "'))"
    Set objRecordset = objCommand.Execute
    Do While objRecordset.EOF = False
        ReDim Preserve caryNode(clngNodeCount)
        caryNode(clngNodeCount).Level = CInt(objRecordset.Fields(0).Value)
        caryNode(clngNodeCount).ObjType = CStr(objRecordset.Fields(1).Value)
        caryNode(clngNodeCount).ObjCode = CStr(objRecordset.Fields(2).Value)
        caryNode(clngNodeCount).ObjText = CStr(objRecordset.Fields(3).Value)
        caryNode(clngNodeCount).ObjStatus = CStr(objRecordset.Fields(4).Value)
        caryNode(clngNodeCount).LnkSequence = CInt(objRecordset.Fields(5).Value)
        caryNode(clngNodeCount).LnkType = CStr(objRecordset.Fields(6).Value)
        caryNode(clngNodeCount).LnkCode = CStr(objRecordset.Fields(7).Value)
        caryNode(clngNodeCount).LnkText = CStr(objRecordset.Fields(8).Value)
        caryNode(clngNodeCount).LnkScript = CStr(objRecordset.Fields(9).Value)
        caryNode(clngNodeCount).LnkStatus = CStr(objRecordset.Fields(10).Value)
        clngNodeCount = clngNodeCount + 1
        objRecordset.MoveNext
    Loop
    objRecordset.Close
    
    '//
    '// Node must be valid
    '//
    If clngNodeCount = 0 Then
        strReturn = "*ERROR (ICS_SECURITY:CheckOption): User does not exist - access denied"
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
    '// ADODB connection object
    '//
    If Not cobjConnection Is Nothing Then
        If cobjConnection.Errors.Count <> 0 Then
            strReturn = "*ERROR (ICS_SECURITY:CheckOption): "
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
        strReturn = "*ERROR (ICS_SECURITY:CheckOption): Visual Basic Error " & Err.Number & " : " & Err.Description
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
    
    '//
    '// Return the function
    '//
    CheckOption = strReturn
    
End Function
Public Function GetMenu(ByVal strUser As String) As String

    Dim i As Long
    Dim strReturn As String
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
    '// User must be supplied
    '//
    If strUser = "" Then
        strReturn = "*ERROR (ICS_SECURITY:GetMenu): No user specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Identifier must be specified
    '//
    If cobjConnection Is Nothing Then
        strReturn = "*ERROR (ICS_SECURITY:GetMenu): No connection - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Initialise the menu array
    '//
    clngNodeCount = 0
    ReDim caryNode(clngNodeCount)
    
    '//
    '// Link the command to the connection and set the type
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = cobjConnection
    objCommand.CommandType = adCmdText
    Set objRecordset = New ADODB.Recordset
    
    '//
    '// Retrieve the menu data
    '//
    objCommand.CommandText = "select * from table(lics_security.get_security('" & strUser & "'))"
    Set objRecordset = objCommand.Execute
    Do While objRecordset.EOF = False
        ReDim Preserve caryNode(clngNodeCount)
        caryNode(clngNodeCount).Level = CInt(objRecordset.Fields(0).Value)
        caryNode(clngNodeCount).ObjType = CStr(objRecordset.Fields(1).Value)
        caryNode(clngNodeCount).ObjCode = CStr(objRecordset.Fields(2).Value)
        caryNode(clngNodeCount).ObjText = CStr(objRecordset.Fields(3).Value)
        caryNode(clngNodeCount).ObjStatus = CStr(objRecordset.Fields(4).Value)
        caryNode(clngNodeCount).LnkSequence = CInt(objRecordset.Fields(5).Value)
        caryNode(clngNodeCount).LnkType = CStr(objRecordset.Fields(6).Value)
        caryNode(clngNodeCount).LnkCode = CStr(objRecordset.Fields(7).Value)
        caryNode(clngNodeCount).LnkText = CStr(objRecordset.Fields(8).Value)
        caryNode(clngNodeCount).LnkScript = CStr(objRecordset.Fields(9).Value)
        caryNode(clngNodeCount).LnkStatus = CStr(objRecordset.Fields(10).Value)
        clngNodeCount = clngNodeCount + 1
        objRecordset.MoveNext
    Loop
    objRecordset.Close
    
    '//
    '// Node must be valid
    '//
    If clngNodeCount = 0 Then
        strReturn = "*ERROR (ICS_SECURITY:GetMenu): User does not exist - access denied"
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
    '// ADODB connection object
    '//
    If Not cobjConnection Is Nothing Then
        If cobjConnection.Errors.Count <> 0 Then
            strReturn = "*ERROR (ICS_SECURITY:GetMenu): "
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
        strReturn = "*ERROR (ICS_SECURITY:GetMenu): Visual Basic Error " & Err.Number & " : " & Err.Description
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
    
    '//
    '// Return the function
    '//
    GetMenu = strReturn
    
End Function
Public Function GetMenuXML() As String

    '//
    '// Return the connection
    '//
    GetMenuXML = cstrMenu
    
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
        Case "SECURITY"
            ReDim Preserve carySecurity(clngSecurityCount)
            carySecurity(clngSecurityCount).Action = "SECURITY"
            For j = 0 To objNode.attributes.length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "CONNECTIONSTRING"
                        carySecurity(clngSecurityCount).Value01 = objNode.attributes(j).Text
                    Case "ENCRYPTEDPASSWORD"
                        carySecurity(clngSecurityCount).Value02 = objNode.attributes(j).Text
                End Select
            Next
            clngSecurityCount = clngSecurityCount + 1
        Case "SITE"
            ReDim Preserve carySecurity(clngSecurityCount)
            carySecurity(clngSecurityCount).Action = "SITE"
            For j = 0 To objNode.attributes.length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "CODE"
                        carySecurity(clngSecurityCount).Value01 = objNode.attributes(j).Text
                    Case "TEXT"
                        carySecurity(clngSecurityCount).Value02 = objNode.attributes(j).Text
                    Case "ENVIRONMENT"
                        carySecurity(clngSecurityCount).Value03 = objNode.attributes(j).Text
                    Case "INSTALLATION"
                        carySecurity(clngSecurityCount).Value04 = objNode.attributes(j).Text
                    Case "CONNECTIONSTRING"
                        carySecurity(clngSecurityCount).Value05 = objNode.attributes(j).Text
                    Case "ENCRYPTEDPASSWORD"
                        carySecurity(clngSecurityCount).Value06 = objNode.attributes(j).Text
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
                    Case "MENU"
                        carySecurity(clngSecurityCount).Value02 = objNode.attributes(j).Text
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
Private Sub ProcessSiteNode(objNode As MSXML.IXMLDOMNode)

    Dim i As Long
    Dim j As Long
    
    '//
    '// Load the site array when required
    '//
    Select Case UCase(objNode.nodeName)
        Case "SITE"
            ReDim Preserve carySite(clngSiteCount)
            For j = 0 To objNode.attributes.length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "CODE"
                        carySite(clngSiteCount).Value01 = objNode.attributes(j).Text
                    Case "TEXT"
                        carySite(clngSiteCount).Value02 = objNode.attributes(j).Text
                    Case "ENVIRONMENT"
                        carySite(clngSiteCount).Value03 = objNode.attributes(j).Text
                    Case "INSTALLATION"
                        carySite(clngSiteCount).Value04 = objNode.attributes(j).Text
                    Case "CONNECTIONSTRING"
                        carySite(clngSiteCount).Value05 = objNode.attributes(j).Text
                    Case "ENCRYPTEDPASSWORD"
                        carySite(clngSiteCount).Value06 = objNode.attributes(j).Text
                End Select
            Next
            clngSiteCount = clngSiteCount + 1
    End Select

    '//
    '// Process the any child nodes
    '//
    For i = 0 To objNode.childNodes.length - 1
        Call ProcessSiteNode(objNode.childNodes(i))
    Next
        
End Sub
Public Property Get SiteCode(ByVal lngIndex As Long) As String

    '//
    '// Site code property
    '//
    SiteCode = carySite(lngIndex).Value01
    
End Property
Public Property Get SiteCount() As Long

    '//
    '// Site count reference
    '//
    SiteCount = clngSiteCount - 1
    
End Property
Public Property Get SiteEnvironment(ByVal lngIndex As Long) As String

    '//
    '// Site environment property
    '//
    SiteEnvironment = carySite(lngIndex).Value03
    
End Property
Public Property Get SiteInstallation(ByVal lngIndex As Long) As String

    '//
    '// Site installation property
    '//
    SiteInstallation = carySite(lngIndex).Value04
    
End Property
Public Property Get SiteText(ByVal lngIndex As Long) As String

    '//
    '// Site text property
    '//
    SiteText = carySite(lngIndex).Value02
    
End Property
Public Property Get SiteConnectionString(ByVal lngIndex As Long) As String

    '//
    '// Site connection string property
    '//
    SiteConnectionString = carySite(lngIndex).Value05
    
End Property
Public Function InitialiseXML(ByVal strSecurityFile As String, ByVal strUser As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim bolAuthorised As Boolean
    Dim strGuest As String
    Dim objXMLDocument As MSXML.DOMDocument
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the return value
    '//
    strReturn = "*OK"
    cstrMenu = ""
    strGuest = ""
    
    '//
    '// Security file must be supplied
    '//
    If strSecurityFile = "" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseXML): No security file specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// User must be supplied
    '//
    If strUser = "" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseXML): No user specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Parse the XML security file
    '//
    clngSecurityCount = 0
    ReDim carySecurity(clngSecurityCount)
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.Load(strSecurityFile) = False Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseXML): Security Parsing Error: " & objXMLDocument.parseError.reason
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
        strReturn = "*ERROR (ICS_SECURITY:InitialiseXML): Security file does not contain a security tag - unable to process"
        GoTo tagExit
    End If
    If carySecurity(0).Action <> "SECURITY" Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseXML): Security file does not contain a security tag - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// User must be authorised
    '//
    bolAuthorised = False
    For i = 1 To clngSecurityCount - 1
        If carySecurity(i).Action = "USER" And UCase(carySecurity(i).Value01) = UCase(strUser) Then
            bolAuthorised = True
            cstrMenu = carySecurity(i).Value02
            Exit For
        End If
        If carySecurity(i).Action = "USER" And UCase(carySecurity(i).Value01) = "*GUEST" Then
            bolAuthorised = True
            strGuest = carySecurity(i).Value02
        End If
    Next
    If bolAuthorised = False Then
        strReturn = "*ERROR (ICS_SECURITY:InitialiseXML): User " & strUser & " is not authorised"
    End If
    
    '//
    '// Set the menu
    '//
    If cstrMenu = "" Then
        cstrMenu = strGuest
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
            strReturn = "*ERROR (ICS_SECURITY:InitialiseXML): "
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
        strReturn = "*ERROR (ICS_SECURITY:InitialiseXML): Visual Basic Error " & Err.Number & " : " & Err.Description
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
    InitialiseXML = strReturn
    
End Function
Public Function PasswordEncrypt(strPassword) As String

    Dim i As Long
    Dim strWork As String
    Dim strPart1 As String
    Dim strPart2 As String
    Dim strString As String
    Dim strHex As String
    Dim intAscii As Integer
    
    '//
    '// Initialise the function
    '//
    PasswordEncrypt = ""
    
    '//
    '// Encrypt the password string
    '//
    strWork = ""
    For i = Len(strPassword) To 1 Step -1
        intAscii = Asc(Mid$(strPassword, i, 1))
        If intAscii >= 128 Then
            intAscii = intAscii - 128
        Else
            intAscii = intAscii + 128
        End If
        strHex = Hex$(intAscii)
        If Len(strHex) < 2 Then
            strHex = "0" & strHex
        End If
        strWork = strWork & strHex
    Next
    strString = ""
    For i = 1 To Len(strWork)
        Select Case Mid$(strWork, i, 1)
            Case "A"
                strString = strString & "U"
            Case "B"
                strString = strString & "V"
            Case "C"
                strString = strString & "W"
            Case "D"
                strString = strString & "X"
            Case "E"
                strString = strString & "Y"
            Case "F"
                strString = strString & "Z"
            Case Else
                strString = strString & Mid$(strWork, i, 1)
        End Select
    Next
    strPart1 = ""
    strPart2 = ""
    For i = 1 To Len(strString)
        If (i Mod 2) = 0 Then
            strPart2 = strPart2 & Mid$(strString, i, 1)
        Else
            strPart1 = strPart1 & Mid$(strString, i, 1)
        End If
    Next
    PasswordEncrypt = strPart1 & strPart2
    
End Function
Private Function PasswordUnEncrypt(strPassword) As String

    Dim i As Long
    Dim strWork As String
    Dim strPart1 As String
    Dim strPart2 As String
    Dim strConcat As String
    Dim strString As String
    Dim intAscii As Integer
    
    '//
    '// Initialise the function
    '//
    PasswordUnEncrypt = ""
    
    '//
    '// UnEncrypt the password string
    '//
    strConcat = ""
    strPart1 = Mid$(strPassword, 1, (Len(strPassword) / 2))
    strPart2 = Mid$(strPassword, (Len(strPassword) / 2) + 1, (Len(strPassword) / 2))
    For i = 1 To (Len(strPassword) / 2)
        strConcat = strConcat & Mid$(strPart1, i, 1) & Mid$(strPart2, i, 1)
    Next
    strString = ""
    For i = 1 To Len(strConcat)
        Select Case Mid$(strConcat, i, 1)
            Case "U"
                strString = strString & "A"
            Case "V"
                strString = strString & "B"
            Case "W"
                strString = strString & "C"
            Case "X"
                strString = strString & "D"
            Case "Y"
                strString = strString & "E"
            Case "Z"
                strString = strString & "F"
            Case Else
                strString = strString & Mid$(strConcat, i, 1)
        End Select
    Next
    strWork = ""
    For i = (Len(strString) - 1) To 1 Step -2
        intAscii = "&H" & Mid$(strString, i, 2)
        If intAscii >= 128 Then
            intAscii = intAscii - 128
        Else
            intAscii = intAscii + 128
        End If
        strWork = strWork & Chr$(intAscii)
    Next
    PasswordUnEncrypt = strWork

End Function
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


