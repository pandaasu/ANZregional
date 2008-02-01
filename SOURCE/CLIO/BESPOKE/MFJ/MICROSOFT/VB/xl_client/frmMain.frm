VERSION 5.00
Begin VB.Form frmMain 
   BackColor       =   &H00400000&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   600
   ClientLeft      =   12
   ClientTop       =   12
   ClientWidth     =   6084
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   600
   ScaleWidth      =   6084
   StartUpPosition =   1  'CenterOwner
   Begin VB.Label lblProgress 
      Alignment       =   2  'Center
      BackColor       =   &H00400000&
      Caption         =   "Generating Excel Spreadsheet 0% completed"
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
      Height          =   372
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
    Private cobjClient As XL_CLIENT.Object
    Private cstrReturn As String
Friend Property Get ReturnStatus() As String

    '//
    '// Return status property
    '//
    ReturnStatus = cstrReturn
    
End Property
Public Property Set Client(objClient As XL_CLIENT.Object)

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
    '// Perform the generation
    '//
    cstrReturn = cobjClient.ReportGeneration()
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
    Me.lblProgress.Caption = "Generating Excel Spreadsheet 0% completed"
    
End Sub

Private Sub Form_Terminate()

    '//
    '// Destroy the private references
    '//
    Set cobjClient = Nothing
    
End Sub


