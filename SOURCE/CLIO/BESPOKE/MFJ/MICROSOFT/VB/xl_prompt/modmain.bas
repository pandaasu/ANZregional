Attribute VB_Name = "modMain"
    '//
    '// Ensure explicit object declaration
    '//
    Option Explicit
    
    '//
    '// Public variables
    '//
    Public cbolBatch As Boolean
    Public mfrmMain As frmMain



Public Sub Main()

    Dim strReturn As String
    
    '//
    '// Set the batch indicator
    '//
    cbolBatch = False
    
    '//
    '// Create the form and process based on the command line
    '//
    Set mfrmMain = New frmMain
    If Trim$(Command) <> "" Then
        cbolBatch = True
        mfrmMain.cbolCancel = False
        mfrmMain.butCancel.Enabled = True
        mfrmMain.butCancel.Visible = True
        mfrmMain.butProcess.Enabled = False
        mfrmMain.butProcess.Visible = False
        mfrmMain.lblConfiguration.Caption = "Batch Stream:"
        mfrmMain.txtConfiguration.Enabled = False
        mfrmMain.txtConfiguration.Text = Trim$(Command)
        Load mfrmMain
        mfrmMain.Show vbModeless
        mfrmMain.WindowState = 0
        strReturn = mfrmMain.ProcessBatchStream(Trim$(Command))
        If strReturn = "*OK" Or strReturn = "*CANCELLED" Then
            Unload mfrmMain
            Set mfrmMain = Nothing
        End If
    Else
        cbolBatch = False
        mfrmMain.cbolCancel = False
        mfrmMain.butCancel.Enabled = False
        mfrmMain.butCancel.Visible = False
        mfrmMain.butProcess.Enabled = True
        mfrmMain.butProcess.Visible = True
        mfrmMain.lblConfiguration.Caption = "Report Stream:"
        mfrmMain.txtConfiguration.Enabled = True
        mfrmMain.txtConfiguration.Text = ""
        Load mfrmMain
        mfrmMain.Show vbModeless
        mfrmMain.WindowState = 0
    End If
    
    '//
    '// Destroy the base objects
    '//
    Set frmMain = Nothing
    
End Sub
