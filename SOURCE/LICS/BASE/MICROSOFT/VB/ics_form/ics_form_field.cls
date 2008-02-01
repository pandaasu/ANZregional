VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Field"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
    '//
    '// Ensure explicit declarations
    '//
    Option Explicit
    
    '//
    '// Private variables
    '//
    Private cstrField As String
    Private caryValues() As String
    Private clngValuesCount As Long
Friend Property Let Field(ByVal strNewValue As String)

    '//
    '// Field property
    '//
    cstrField = strNewValue
    
End Property
Public Property Get ValuesCount() As Long

    '//
    '// Values count reference
    '//
    If cstrField = "" Then
        ValuesCount = 0
    Else
        ValuesCount = clngValuesCount
    End If
    
End Property
Public Function GetValue(ByVal lngValueIndex As Long) As String

    '//
    '// Values property
    '//
    If lngValueIndex >= clngValuesCount Then
        GetValue = ""
        Exit Function
    End If
    GetValue = caryValues(lngValueIndex)
    
End Function

Friend Sub SetValue(ByVal strNewValue As String)

    '//
    '// Values property
    '//
    If clngValuesCount = 0 Then
        Exit Sub
    End If
    caryValues(0) = strNewValue
    
End Sub
Friend Property Let Value(ByVal strNewValue As String)

    '//
    '// Value property
    '//
    ReDim Preserve caryValues(clngValuesCount)
    caryValues(clngValuesCount) = strNewValue
    clngValuesCount = clngValuesCount + 1
    
End Property
Public Property Get Field() As String

    '//
    '// Field property
    '//
    Field = cstrField
    
End Property
Public Property Get Value() As String
Attribute Value.VB_UserMemId = 0

    '//
    '// Value property
    '//
    If clngValuesCount = 0 Then
        Value = ""
        Exit Property
    End If
    Value = caryValues(0)
    
End Property
Private Sub Class_Initialize()

    '//
    '// Initialise the private variables
    '//
    cstrField = ""
    clngValuesCount = 0
    ReDim caryValues(clngValuesCount)
    
End Sub


