VERSION 5.00
Begin VB.Form frmMain 
   BackColor       =   &H00400000&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   444
   ClientLeft      =   12
   ClientTop       =   12
   ClientWidth     =   6084
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   444
   ScaleWidth      =   6084
   StartUpPosition =   1  'CenterOwner
   Begin VB.Label lblProgress 
      Alignment       =   2  'Center
      BackColor       =   &H00400000&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFC0&
      Height          =   252
      Left            =   120
      TabIndex        =   0
      Top             =   120
      UseMnemonic     =   0   'False
      Width           =   5772
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
    '//
    '// Ensure explicit declarations
    '//
    Option Explicit
    
    '//
    '// Private variables
    '//
    Private cobjClient As ICS_XLCLIENT.Object
    Private cstrAction As String
    Private cstrReturn As String
Friend Property Get ReturnStatus() As String

    '//
    '// Return status property
    '//
    ReturnStatus = cstrReturn
    
End Property
Friend Property Let ProcessAction(strAction As String)

    '//
    '// Process action property
    '//
    cstrAction = strAction
    
End Property
Public Property Set Client(objClient As ICS_XLCLIENT.Object)

    '//
    '// Client object property
    '//
    Set cobjClient = objClient
    
End Property
Private Sub Form_Activate()
   
    '//
    '// Refresh the form
    '//
    Me.Refresh
    
    '//
    '// Set the mouse pointer
    '//
    Screen.MousePointer = vbArrowHourglass
    
    '//
    '// Perform the process action
    '//
    Select Case cstrAction
        Case "*GETXL"
            cstrReturn = cobjClient.ReadSpreadsheet()
        Case "*SETXL"
            cstrReturn = cobjClient.WriteSpreadsheet()
        Case "*GETTX"
            cstrReturn = cobjClient.ReadTextFile()
    End Select
    Set cobjClient = Nothing
    
    '//
    '// Reset the mouse pointer
    '//
    Screen.MousePointer = vbDefault
    
    '//
    '// Unload the form
    '//
    Unload Me
    
End Sub

Private Sub Form_Initialize()

    '//
    '// Initialise the form
    '//
    Set cobjClient = Nothing
    Me.Caption = ""
    Me.lblProgress.Caption = ""
    cstrAction = ""
    cstrReturn = ""
    
End Sub

Private Sub Form_Terminate()

    '//
    '// Destroy the private references
    '//
    Set cobjClient = Nothing
    
End Sub


