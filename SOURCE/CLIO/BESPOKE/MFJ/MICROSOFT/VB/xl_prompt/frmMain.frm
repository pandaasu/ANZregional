VERSION 5.00
Begin VB.Form frmMain 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "MFJ Planning Report Generator"
   ClientHeight    =   3624
   ClientLeft      =   36
   ClientTop       =   420
   ClientWidth     =   9216
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3624
   ScaleWidth      =   9216
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton butCancel 
      Caption         =   "Cancel"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   372
      Left            =   4080
      TabIndex        =   4
      Top             =   960
      Width           =   1092
   End
   Begin VB.TextBox txtConfiguration 
      CausesValidation=   0   'False
      Height          =   288
      Left            =   1560
      MaxLength       =   128
      TabIndex        =   0
      Top             =   360
      Width           =   7452
   End
   Begin VB.CommandButton butProcess 
      Caption         =   "Process"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   372
      Left            =   7920
      TabIndex        =   1
      Top             =   960
      Width           =   1092
   End
   Begin VB.Label lblReturn 
      Height          =   2052
      Left            =   240
      TabIndex        =   3
      Top             =   1440
      Width           =   8772
      WordWrap        =   -1  'True
   End
   Begin VB.Label lblConfiguration 
      Caption         =   "Report Stream:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   252
      Left            =   240
      TabIndex        =   2
      Top             =   360
      UseMnemonic     =   0   'False
      Width           =   1332
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
    '// Ensure explicit declarations
    '//
    Option Explicit
    
    '//
    '// Private variables
    '//
    Public cbolCancel As Boolean
    Private WithEvents cobjXLReport As XL_REPORT.Object
Attribute cobjXLReport.VB_VarHelpID = -1
Private Sub butCancel_Click()
    
    '//
    '// Set the cancel indicator
    '//
    cbolCancel = True
    
End Sub

Private Sub butProcess_Click()

    Static sbolHere As Boolean
    
    '//
    '// Exit when already here
    '//
    If sbolHere = True Then
        Exit Sub
    End If
    sbolHere = True
    
    '//
    '// Process the configuration file
    '//
    If cbolBatch = False Then
        If Trim$(Me.txtConfiguration.Text) <> "" Then
            Me.butProcess.Enabled = False
            Me.butCancel.Enabled = True
            Me.butCancel.Visible = True
            Me.txtConfiguration.Enabled = False
            Call Me.ProcessReportStream(Me.txtConfiguration.Text)
            Me.butCancel.Visible = False
            Me.butCancel.Enabled = True
            Me.txtConfiguration.Enabled = True
            Me.butProcess.Enabled = True
        End If
    End If
    sbolHere = False
    
End Sub


Private Sub cobjXLReport_TaskProcessing(ByVal TaskStatus As String, Cancel As Boolean)

    '//
    '// Show the current task status
    '//
    Me.lblReturn.Caption = TaskStatus
    Me.lblReturn.Refresh
    DoEvents
    If cbolCancel = True Then
        Cancel = True
    End If
    
End Sub

Private Sub Form_Terminate()

    '//
    '// Destroy any remaining object references
    '//
    Set cobjXLReport = Nothing
    
End Sub

Public Function ProcessBatchStream(strBatchStream As String) As String
    
    Dim strReturn As String
    
    '//
    '// Process the configuration file
    '//
    Screen.MousePointer = vbHourglass
    Set cobjXLReport = New XL_REPORT.Object
    strReturn = cobjXLReport.BatchStreamExecution(strBatchStream)
    Me.lblReturn.Caption = strReturn
    Screen.MousePointer = vbDefault
    Set cobjXLReport = Nothing
    ProcessBatchStream = strReturn
    
End Function
Public Sub ProcessReportStream(strReportStream As String)
    
    Dim strReturn As String
    
    '//
    '// Process the report stream file
    '//
    Screen.MousePointer = vbHourglass
    Set cobjXLReport = New XL_REPORT.Object
    strReturn = cobjXLReport.ReportStreamExecution(strReportStream)
    Me.lblReturn.Caption = strReturn
    Screen.MousePointer = vbDefault
    Set cobjXLReport = Nothing
    
End Sub

