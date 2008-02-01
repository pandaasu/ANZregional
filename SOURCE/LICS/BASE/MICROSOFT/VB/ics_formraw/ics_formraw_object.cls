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
    Private cobjFields As ICS_FORMRAW.Fields

Public Sub AddPost(byrArray() As Byte)
    
    '//
    '// Add a field to the collection
    '//
    Call cobjFields.Add(strField, strValue)
    
End Sub
Public Sub AddField(strField As String, strValue As String)
    
    '//
    '// Add a field to the collection
    '//
    Call cobjFields.Add(strField, strValue)
    
End Sub
Public Sub UpdateField(strField As String, strValue As String)
    
    '//
    '// Update the field in the collection
    '//
    Call cobjFields.Update(strField, strValue)
    
End Sub
Public Property Get FieldsCount() As Long

    '//
    '// Collection count reference
    '//
    FieldsCount = cobjFields.Count
    
End Property

Public Property Get Fields() As ICS_FORMRAW.Fields

    '//
    '// Collection reference
    '//
    Set Fields = cobjFields
    
End Property
Private Sub Class_Initialize()

    '//
    '// Create the private objects
    '//
    Set cobjFields = New ICS_FORMRAW.Fields
    
End Sub
Private Sub Class_Terminate()
    
    '//
    '// Destroy the private objects
    '//
    Set cobjFields = Nothing
    
End Sub



















