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
    Private cstrStream As String
    Private clngSidx As Long
    Private cstrLines() As String
    Private clngLidx As Long
    Private cbolEOS As Boolean
Public Sub ClearStream()

    '//
    '// Clear the stream
    '//
    cstrStream = ""
    clngSidx = 0
    ReDim cstrLines(0)
    clngLidx = 0
    cbolEOS = True
    
End Sub
Public Function EndOfStream() As Boolean

    '//
    '// Return the end of stream value
    '//
    EndOfStream = cbolEOS
    
End Function
Public Sub AddToStream(ByVal strData As String)

    '//
    '// Add the data to the stream
    '//
    cstrStream = cstrStream & strData
    
End Sub
Public Sub OpenStream()

    '//
    '// Initialise the stream index and end value
    '//
    clngSidx = 0
    clngLidx = 0
    cbolEOS = True
    If cstrStream <> "" Then
        clngSidx = 1
        cstrLines = Split(cstrStream, vbCrLf, -1, vbTextCompare)
        clngLidx = 0
        cbolEOS = False
    End If
    
End Sub
Public Function ReadLine() As String

    Dim strData As String
    
    '//
    '// Retrieve the stream data line
    '//
    strData = ""
    If cbolEOS = False Then
        strData = cstrLines(clngLidx)
        clngLidx = clngLidx + 1
        If clngLidx >= UBound(cstrLines) Then
            cbolEOS = True
        End If
    End If
    
    '//
    '// Return the stream data line
    '//
    ReadLine = strData
    
End Function
Public Function ReadData(ByVal intSize As Integer) As String

    Dim strData As String
    
    '//
    '// Retrieve the stream data
    '//
    strData = ""
    If cbolEOS = False And intSize > 0 Then
        strData = Mid$(cstrStream, clngSidx, intSize)
        clngSidx = clngSidx + intSize
        If clngSidx > Len(cstrStream) Then
            cbolEOS = True
        End If
    End If
    
    '//
    '// Return the stream data
    '//
    ReadData = strData
    
End Function
