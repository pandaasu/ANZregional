VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Fields"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder" ,"Yes"
Attribute VB_Ext_KEY = "Collection" ,"Node"
Attribute VB_Ext_KEY = "Member0" ,"Node"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
    '//
    '// Ensure explicit declarations
    '//
    Option Explicit
    
    '//
    '// Local collection definition
    '//
    Private colFields As Collection
Friend Sub Add(strField As String, strValue As String)

    Dim objField As ICS_FORM.Field
    
    '//
    '// Retrieve or create the new object
    '//
    On Error Resume Next
    Set objField = colFields(strField)
    On Error GoTo 0
    If objField Is Nothing Then
        Set objField = New ICS_FORM.Field
        objField.Field = strField
        colFields.Add objField, strField
    End If

    '//
    '// Set the value property
    '//
    objField.Value = strValue

    '//
    '// Return the new object reference
    '//
    Set objField = Nothing
    Exit Sub

End Sub
Friend Sub Update(strField As String, strValue As String)

    Dim objField As ICS_FORM.Field

    '//
    '// Reference the object
    '//
    On Error GoTo UpdateMissing
    Set objField = colFields(strField)
    On Error GoTo 0

    '//
    '// Update the value
    '//
    Call objField.SetValue(strValue)
    
    '//
    '// Destroy the local object
    '//
    Set objField = Nothing
    Exit Sub
    
'//
'// Function error
'//
UpdateMissing:
    Set objField = Nothing

End Sub
Public Property Get Item(vntIndexKey As Variant) As ICS_FORM.Field
Attribute Item.VB_UserMemId = 0
   
    '//
    '// Collection object reference
    '//
    On Error GoTo ItemMissing
    Set Item = colFields(vntIndexKey)
    On Error GoTo 0
    Exit Property
    
'//
'// Function error
'//
ItemMissing:
    Set Item = colFields("")
    
End Property



Friend Property Get Count() As Long
    
    '//
    '// Collection object count
    '//
    Count = colFields.Count
    
End Property


Friend Sub Remove(vntIndexKey As Variant)
    
    '//
    '// Remove the object reference
    '//
    colFields.Remove vntIndexKey
    
End Sub
Friend Sub Clear()
    
    Dim i As Long
    
    '//
    '// Clear the collection
    '//
    For i = 1 To colFields.Count
        colFields.Remove 1
    Next
    
End Sub

Private Sub Class_Initialize()
    
    '//
    '// Create the collection
    '//
    Set colFields = New Collection
    
    '//
    '// Create the null entry
    '//
    Call Add("", "")
    
End Sub


Private Sub Class_Terminate()
    
    '//
    '// Destroy the collection
    '//
    Set colFields = Nothing
    
End Sub

