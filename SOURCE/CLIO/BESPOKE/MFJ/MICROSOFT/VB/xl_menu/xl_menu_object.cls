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
    Private Type ctypMenuType
        Node As String
        Children As Boolean
        Level As Integer
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
    Private caryMenu() As ctypMenuType
    Private clngMenuCount As Long
    Private cintMenuLevel As Integer
Public Property Get NodeCount() As Long

    '//
    '// Menu count reference
    '//
    NodeCount = clngMenuCount - 1
    
End Property
Public Property Get NodeChildren(ByVal lngIndex As Long) As Boolean

    '//
    '// Menu children property
    '//
    NodeChildren = caryMenu(lngIndex).Children
    
End Property
Public Property Get NodeText(ByVal lngIndex As Long) As String

    '//
    '// Menu text property
    '//
    NodeText = caryMenu(lngIndex).Value01
    
End Property
Public Property Get NodeScript(ByVal lngIndex As Long) As String

    '//
    '// Menu script property
    '//
    NodeScript = caryMenu(lngIndex).Value02
    
End Property

Public Property Get NodeNode(ByVal lngIndex As Long) As String

    '//
    '// Menu node property
    '//
    NodeNode = caryMenu(lngIndex).Node
    
End Property
Public Property Get NodeLevel(ByVal lngIndex As Long) As Integer

    '//
    '// Menu level property
    '//
    NodeLevel = caryMenu(lngIndex).Level
    
End Property
Private Sub ProcessMenuNode(objNode As MSXML.IXMLDOMNode)

    Dim i As Long
    Dim j As Long
    
    '//
    '// Increment the menu level
    '//
    cintMenuLevel = cintMenuLevel + 1
    
    '//
    '// Load the actions array when required
    '//
    Select Case UCase(objNode.nodeName)
        Case "MENU"
            ReDim Preserve caryMenu(clngMenuCount)
            caryMenu(clngMenuCount).Node = "MENU"
            caryMenu(clngMenuCount).Children = objNode.hasChildNodes
            caryMenu(clngMenuCount).Level = cintMenuLevel
            For j = 0 To objNode.attributes.length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "TEXT"
                        caryMenu(clngMenuCount).Value01 = objNode.attributes(j).Text
                End Select
            Next
            clngMenuCount = clngMenuCount + 1
        Case "NODE"
            ReDim Preserve caryMenu(clngMenuCount)
            caryMenu(clngMenuCount).Node = "NODE"
            caryMenu(clngMenuCount).Children = objNode.hasChildNodes
            caryMenu(clngMenuCount).Level = cintMenuLevel
            For j = 0 To objNode.attributes.length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "TEXT"
                        caryMenu(clngMenuCount).Value01 = objNode.attributes(j).Text
                End Select
            Next
            clngMenuCount = clngMenuCount + 1
        Case "OPTION"
            ReDim Preserve caryMenu(clngMenuCount)
            caryMenu(clngMenuCount).Node = "OPTION"
            caryMenu(clngMenuCount).Children = False
            caryMenu(clngMenuCount).Level = cintMenuLevel
            For j = 0 To objNode.attributes.length - 1
                Select Case UCase(objNode.attributes(j).nodeName)
                    Case "TEXT"
                        caryMenu(clngMenuCount).Value01 = objNode.attributes(j).Text
                    Case "SCRIPT"
                        caryMenu(clngMenuCount).Value02 = objNode.attributes(j).Text
                End Select
            Next
            clngMenuCount = clngMenuCount + 1
    End Select

    '//
    '// Process the any child nodes
    '//
    For i = 0 To objNode.childNodes.length - 1
        Call ProcessMenuNode(objNode.childNodes(i))
    Next
    
    '//
    '// Decrement the menu level
    '//
    cintMenuLevel = cintMenuLevel - 1
        
End Sub

Public Function Initialise(ByVal strMenuFile As String) As String

    Dim i As Long
    Dim strReturn As String
    Dim strResult As String
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
    '// Menu file must be supplied
    '//
    If strMenuFile = "" Then
        strReturn = "*ERROR (XL_MENU:Initialise): No menu file specified - unable to process"
        GoTo tagExit
    End If
    
    '//
    '// Parse the XML menu file
    '//
    clngMenuCount = 0
    cintMenuLevel = 0
    ReDim caryMenu(clngMenuCount)
    Set objXMLDocument = New MSXML.DOMDocument
    If objXMLDocument.Load(strMenuFile) = False Then
        strReturn = "*ERROR (XL_MENU:Initialise): Menu Parsing Error: " & objXMLDocument.parseError.reason
        GoTo tagExit
    End If
    For i = 0 To objXMLDocument.childNodes.length - 1
        Call ProcessMenuNode(objXMLDocument.childNodes(i))
    Next
    Set objXMLDocument = Nothing
    
    '//
    '// Menu must be valid
    '//
    If clngMenuCount = 0 Then
        strReturn = "*ERROR (XL_MENU:Initialise): Menu file does not contain a menu tag - unable to process"
        GoTo tagExit
    End If
    If caryMenu(0).Node <> "MENU" Then
        strReturn = "*ERROR (XL_MENU:Initialise): Menu file does not contain a menu tag - unable to process"
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
        strReturn = "*ERROR (XL_MENU:Initialise): Visual Basic Error " & Err.Number & " : " & Err.Description
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

