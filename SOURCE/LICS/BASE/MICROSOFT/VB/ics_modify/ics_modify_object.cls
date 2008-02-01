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
'//////////////////////////////////////////////////////////////////////
'// Author: Paul Jacobs                                              //
'// Date: 22/07/2004                                                 //
'// Purpose: To allow for the modification of a table's contents     //
'// using UPDATE, DELETE and INSERT type commands                    //
'//////////////////////////////////////////////////////////////////////
    
    
    '//
    '// Ensure explicit declarations
    '//
    Option Explicit

    '//
    '// Private variables
    '//
    Private cobjSecurity As ICS_SECURITY.Object
Public Property Set Security(objSecurity As ICS_SECURITY.Object)

    '//
    '// Security object property
    '//
    Set cobjSecurity = objSecurity
    
End Property
Public Function Execute(ByVal strQuery As String)
 Dim i As Long
    Dim strReturn As String
    Dim strValue As String
    Dim objConnection As ADODB.Connection
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
    '// Query must be specified
    '//
    If strQuery = "" Then
        strReturn = "*ERROR (ICS_SELECTION:Modify): No query specified - unable to process"
        GoTo tagExit
    End If
    
   
    '//
    '// Get the connection from the security object
    '//
    Set objConnection = cobjSecurity.GetConnection
    
    
    '//
    '// Set up for new transaction to begin
    '//
    objConnection.BeginTrans
    
    
    '//
    '// Link the command to the connection and set the type
    '//
    Set objCommand = New ADODB.Command
    Set objCommand.ActiveConnection = objConnection
    objCommand.CommandType = adCmdText
    Set objRecordset = New ADODB.Recordset
    
    '//
    '// Retrieve the selection rows
    '//
    objCommand.CommandText = strQuery
    Set objRecordset = objCommand.Execute


    '//
    '// Commit Transaction
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
    '// ADODB connection object
    '//
    If Not objConnection Is Nothing Then
        If objConnection.Errors.Count <> 0 Then
            strReturn = "*ERROR (ICS_SELECTION:Modify): "
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
        strReturn = "*ERROR (ICS_SELECTION:Modify): Visual Basic Error " & Err.Number & " : " & Err.Description
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
    Set objConnection = Nothing
    
    '//
    '// Return the function
    '//
    Execute = strReturn
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


