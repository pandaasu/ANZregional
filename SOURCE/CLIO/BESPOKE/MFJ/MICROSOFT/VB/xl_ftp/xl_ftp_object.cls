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
    Private cbolOpen As Boolean
    Private hOpen As Long
    Private hConnection As Long
    Private Const MAX_PATH = 260
    Private Const NO_ERROR = 0
    Private Const FILE_ATTRIBUTE_READONLY = &H1
    Private Const FILE_ATTRIBUTE_HIDDEN = &H2
    Private Const FILE_ATTRIBUTE_SYSTEM = &H4
    Private Const FILE_ATTRIBUTE_DIRECTORY = &H10
    Private Const FILE_ATTRIBUTE_ARCHIVE = &H20
    Private Const FILE_ATTRIBUTE_NORMAL = &H80
    Private Const FILE_ATTRIBUTE_TEMPORARY = &H100
    Private Const FILE_ATTRIBUTE_COMPRESSED = &H800
    Private Const FILE_ATTRIBUTE_OFFLINE = &H1000
    
    Private Type FILETIME
        dwLowDateTime As Long
        dwHighDateTime As Long
    End Type
    
    Private Type WIN32_FIND_DATA
        dwFileAttributes As Long
        ftCreationTime As FILETIME
        ftLastAccessTime As FILETIME
        ftLastWriteTime As FILETIME
        nFileSizeHigh As Long
        nFileSizeLow As Long
        dwReserved0 As Long
        dwReserved1 As Long
        cFileName As String * MAX_PATH
        cAlternate As String * 14
    End Type
    
    
    Private Const ERROR_NO_MORE_FILES = 18
    
    Private Declare Function InternetFindNextFile Lib "wininet.dll" Alias "InternetFindNextFileA" (ByVal hFind As Long, lpvFindData As WIN32_FIND_DATA) As Long
    Private Declare Function FtpFindFirstFile Lib "wininet.dll" Alias "FtpFindFirstFileA" (ByVal hFtpSession As Long, ByVal lpszSearchFile As String, lpFindFileData As WIN32_FIND_DATA, ByVal dwFlags As Long, ByVal dwContent As Long) As Long
    Private Declare Function FtpGetFile Lib "wininet.dll" Alias "FtpGetFileA" (ByVal hFtpSession As Long, ByVal lpszRemoteFile As String, ByVal lpszNewFile As String, ByVal fFailIfExists As Boolean, ByVal dwFlagsAndAttributes As Long, ByVal dwFlags As Long, ByVal dwContext As Long) As Boolean
    Private Declare Function FtpPutFile Lib "wininet.dll" Alias "FtpPutFileA" (ByVal hFtpSession As Long, ByVal lpszLocalFile As String, ByVal lpszRemoteFile As String, ByVal dwFlags As Long, ByVal dwContext As Long) As Boolean
    Private Declare Function FtpOpenFile Lib "wininet.dll" Alias "FtpOpenFileA" (ByVal hFtpSession As Long, ByVal sFileName As String, ByVal lAccess As Long, ByVal lFlags As Long, ByVal lContext As Long) As Long
    Private Declare Function FtpDeleteFile Lib "wininet.dll" Alias "FtpDeleteFileA" (ByVal hFtpSession As Long, ByVal lpszFileName As String) As Boolean
    Private Declare Function FtpRenameFile Lib "wininet.dll" Alias "FtpRenameFileA" (ByVal hFtpSession As Long, ByVal lpszRemoteFile As String, ByVal lpszNewFile As String) As Boolean
    Private Declare Function FtpSetCurrentDirectory Lib "wininet.dll" Alias "FtpSetCurrentDirectoryA" (ByVal hFtpSession As Long, ByVal lpszDirectory As String) As Boolean
    Private Declare Function FtpCreateDirectory Lib "wininet.dll" Alias "FtpCreateDirectoryA" (ByVal hFtpSession As Long, ByVal lpszDirectory As String) As Boolean
    Private Declare Function FtpRemoveDirectory Lib "wininet.dll" Alias "FtpRemoveDirectoryA" (ByVal hFtpSession As Long, ByVal lpszDirectory As String) As Boolean
    Private Declare Function InternetOpen Lib "wininet.dll" Alias "InternetOpenA" (ByVal sAgent As String, ByVal lAccessType As Long, ByVal sProxyName As String, ByVal sProxyBypass As String, ByVal lFlags As Long) As Long

    ' User agent constant.
    Private Const scUserAgent = "vb wininet"
    
    ' Use registry access settings.
    Private Const INTERNET_OPEN_TYPE_PRECONFIG = 0
    Private Const INTERNET_OPEN_TYPE_DIRECT = 1
    Private Const INTERNET_OPEN_TYPE_PROXY = 3
    Private Const INTERNET_INVALID_PORT_NUMBER = 0
    
    Private Const FTP_TRANSFER_TYPE_BINARY = &H2
    Private Const FTP_TRANSFER_TYPE_ASCII = &H1
    Private Const INTERNET_FLAG_PASSIVE = &H8000000
    
    Private Declare Function InternetConnect Lib "wininet.dll" Alias "InternetConnectA" (ByVal hInternetSession As Long, ByVal sServerName As String, ByVal nServerPort As Integer, ByVal sUsername As String, ByVal sPassword As String, ByVal lService As Long, ByVal lFlags As Long, ByVal lContext As Long) As Long
                    
    Private Const ERROR_INTERNET_EXTENDED_ERROR = 12003
    Private Declare Function InternetGetLastResponseInfo Lib "wininet.dll" Alias "InternetGetLastResponseInfoA" (lpdwError As Long, ByVal lpszBuffer As String, lpdwBufferLength As Long) As Boolean
    
    ' Number of the TCP/IP port on the server to connect to.
    Private Const INTERNET_DEFAULT_FTP_PORT = 21
    Private Const INTERNET_DEFAULT_GOPHER_PORT = 70
    Private Const INTERNET_DEFAULT_HTTP_PORT = 80
    Private Const INTERNET_DEFAULT_HTTPS_PORT = 443
    Private Const INTERNET_DEFAULT_SOCKS_PORT = 1080
    
    Private Const INTERNET_OPTION_CONNECT_TIMEOUT = 2
    Private Const INTERNET_OPTION_RECEIVE_TIMEOUT = 6
    Private Const INTERNET_OPTION_SEND_TIMEOUT = 5
    
    Private Const INTERNET_OPTION_USERNAME = 28
    Private Const INTERNET_OPTION_PASSWORD = 29
    Private Const INTERNET_OPTION_PROXY_USERNAME = 43
    Private Const INTERNET_OPTION_PROXY_PASSWORD = 44
    
    ' Type of service to access.
    Private Const INTERNET_SERVICE_FTP = 1
    Private Const INTERNET_SERVICE_GOPHER = 2
    Private Const INTERNET_SERVICE_HTTP = 3
    
    ' Opens an HTTP request handle.
    Private Declare Function HttpOpenRequest Lib "wininet.dll" Alias "HttpOpenRequestA" (ByVal hHttpSession As Long, ByVal sVerb As String, ByVal sObjectName As String, ByVal sVersion As String, ByVal sReferer As String, ByVal something As Long, ByVal lFlags As Long, ByVal lContext As Long) As Long
    
    ' Brings the data across the wire even if it locally cached.
    Private Const INTERNET_FLAG_RELOAD = &H80000000
    Private Const INTERNET_FLAG_KEEP_CONNECTION = &H400000
    Private Const INTERNET_FLAG_MULTIPART = &H200000
    
    Private Const GENERIC_READ = &H80000000
    Private Const GENERIC_WRITE = &H40000000
    
    ' Sends the specified request to the HTTP server.
    Private Declare Function HttpSendRequest Lib "wininet.dll" Alias "HttpSendRequestA" (ByVal hHttpRequest As Long, ByVal sHeaders As String, ByVal lHeadersLength As Long, ByVal sOptional As String, ByVal lOptionalLength As Long) As Integer
    
    
    ' Queries for information about an HTTP request.
    Private Declare Function HttpQueryInfo Lib "wininet.dll" Alias "HttpQueryInfoA" (ByVal hHttpRequest As Long, ByVal lInfoLevel As Long, ByRef sBuffer As Any, ByRef lBufferLength As Long, ByRef lIndex As Long) As Integer
    
    ' The possible values for the lInfoLevel parameter include:
    Private Const HTTP_QUERY_CONTENT_TYPE = 1
    Private Const HTTP_QUERY_CONTENT_LENGTH = 5
    Private Const HTTP_QUERY_EXPIRES = 10
    Private Const HTTP_QUERY_LAST_MODIFIED = 11
    Private Const HTTP_QUERY_PRAGMA = 17
    Private Const HTTP_QUERY_VERSION = 18
    Private Const HTTP_QUERY_STATUS_CODE = 19
    Private Const HTTP_QUERY_STATUS_TEXT = 20
    Private Const HTTP_QUERY_RAW_HEADERS = 21
    Private Const HTTP_QUERY_RAW_HEADERS_CRLF = 22
    Private Const HTTP_QUERY_FORWARDED = 30
    Private Const HTTP_QUERY_SERVER = 37
    Private Const HTTP_QUERY_USER_AGENT = 39
    Private Const HTTP_QUERY_SET_COOKIE = 43
    Private Const HTTP_QUERY_REQUEST_METHOD = 45
    Private Const HTTP_STATUS_DENIED = 401
    Private Const HTTP_STATUS_PROXY_AUTH_REQ = 407
    
    ' Add this flag to the about flags to get request header.
    Private Const HTTP_QUERY_FLAG_REQUEST_HEADERS = &H80000000
    Private Const HTTP_QUERY_FLAG_NUMBER = &H20000000
    ' Reads data from a handle opened by the HttpOpenRequest function.
    Private Declare Function InternetReadFile Lib "wininet.dll" (ByVal hFile As Long, ByVal sBuffer As String, ByVal lNumBytesToRead As Long, lNumberOfBytesRead As Long) As Integer
    Private Declare Function InternetWriteFile Lib "wininet.dll" (ByVal hFile As Long, ByVal sBuffer As String, ByVal lNumberOfBytesToRead As Long, lNumberOfBytesRead As Long) As Integer
    Private Declare Function InternetSetOption Lib "wininet.dll" Alias "InternetSetOptionA" (ByVal hInternet As Long, ByVal lOption As Long, ByRef sBuffer As Any, ByVal lBufferLength As Long) As Integer
    Private Declare Function InternetSetOptionStr Lib "wininet.dll" Alias "InternetSetOptionA" (ByVal hInternet As Long, ByVal lOption As Long, ByVal sBuffer As String, ByVal lBufferLength As Long) As Integer
    
    ' Closes a single Internet handle or a subtree of Internet handles.
    Private Declare Function InternetCloseHandle Lib "wininet.dll" (ByVal hInet As Long) As Integer
    
    ' Queries an Internet option on the specified handle
    Private Declare Function InternetQueryOption Lib "wininet.dll" Alias "InternetQueryOptionA" (ByVal hInternet As Long, ByVal lOption As Long, ByRef sBuffer As Any, ByRef lBufferLength As Long) As Integer

    ' Returns the version number of Wininet.dll.
    Private Const INTERNET_OPTION_VERSION = 40
    
    ' Contains the version number of the DLL that contains the Windows Internet
    ' functions (Wininet.dll). This structure is used when passing the
    ' INTERNET_OPTION_VERSION flag to the InternetQueryOption function.
    Private Type tWinInetDLLVersion
        lMajorVersion As Long
        lMinorVersion As Long
    End Type
    
    ' Adds one or more HTTP request headers to the HTTP request handle.
    Private Declare Function HttpAddRequestHeaders Lib "wininet.dll" Alias "HttpAddRequestHeadersA" (ByVal hHttpRequest As Long, ByVal sHeaders As String, ByVal lHeadersLength As Long, ByVal lModifiers As Long) As Integer
    
    ' Flags to modify the semantics of this function. Can be a combination of these values:
    
    ' Adds the header only if it does not already exist; otherwise, an error is returned.
    Private Const HTTP_ADDREQ_FLAG_ADD_IF_NEW = &H10000000
    
    ' Adds the header if it does not exist. Used with REPLACE.
    Private Const HTTP_ADDREQ_FLAG_ADD = &H20000000
    
    ' Replaces or removes a header. If the header value is empty and the header is found,
    ' it is removed. If not empty, the header value is replaced
    Private Const HTTP_ADDREQ_FLAG_REPLACE = &H80000000
    Public Function PutFile(ByVal strFromFile As String, ByVal strToFile As String) As String

    Dim bRet As Boolean
    Dim dwIntError As Long
    Dim dwLength As Long
    Dim strError As String
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the function
    '//
    PutFile = "*OK"
    
    '//
    '// FTP session closed
    '//
    If cbolOpen = False Then
        PutFile = "*ERROR (XL_FTP:PutFile) failed: Session not open"
        GoTo tagExit
    End If
    
    '//
    '// Execute the FTP command
    '//
    bRet = FtpPutFile(hConnection, strFromFile, strToFile, FTP_TRANSFER_TYPE_ASCII, 0)
    If bRet = False Then
        If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
            InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
            strError = String(dwLength + 1, 0)
            InternetGetLastResponseInfo dwIntError, strError, dwLength
            PutFile = "*ERROR (XL_FTP:PutFile) failed: FtpPutFile" & " Error: " & dwIntError & " " & strError
        Else
            PutFile = "*ERROR (XL_FTP:PutFile) failed: FtpPutFile" & " Error: " & Err.LastDllError
        End If
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
    '// Return the error message
    '//
    PutFile = "*ERROR (XL_FTP:PutFile) failed: Visual Basic Error " & Err.Number & " : " & Err.Description
    
'//
'// Function exit
'//
tagExit:

    Exit Function
    
End Function
Public Function RenameFile(ByVal strFromFile As String, ByVal strToFile As String) As String

    Dim bRet As Boolean
    Dim dwIntError As Long
    Dim dwLength As Long
    Dim strError As String
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the function
    '//
    RenameFile = "*OK"
    
    '//
    '// FTP session closed
    '//
    If cbolOpen = False Then
        RenameFile = "*ERROR (XL_FTP:RenameFile) failed: Session not open"
        GoTo tagExit
    End If
    
    '//
    '// Execute the FTP command
    '//
    bRet = FtpRenameFile(hConnection, strFromFile, strToFile)
    If bRet = False Then
        If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
            InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
            strError = String(dwLength + 1, 0)
            InternetGetLastResponseInfo dwIntError, strError, dwLength
            RenameFile = "*ERROR (XL_FTP:RenameFile) failed: FtpRenameFile" & " Error: " & dwIntError & " " & strError
        Else
            RenameFile = "*ERROR (XL_FTP:RenameFile) failed: FtpRenameFile" & " Error: " & Err.LastDllError
        End If
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
    '// Return the error message
    '//
    RenameFile = "*ERROR (XL_FTP:RenameFile) failed: Visual Basic Error " & Err.Number & " : " & Err.Description
    
'//
'// Function exit
'//
tagExit:

    Exit Function
    
End Function

Public Function DeleteFile(ByVal strFromFile As String) As String

    Dim bRet As Boolean
    Dim dwIntError As Long
    Dim dwLength As Long
    Dim strError As String
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the function
    '//
    DeleteFile = "*OK"
    
    '//
    '// FTP session closed
    '//
    If cbolOpen = False Then
        DeleteFile = "*ERROR (XL_FTP:DeleteFile) failed: Session not open"
        GoTo tagExit
    End If
    
    '//
    '// Execute the FTP command
    '//
    bRet = FtpDeleteFile(hConnection, strFromFile)
    If bRet = False Then
        If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
            InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
            strError = String(dwLength + 1, 0)
            InternetGetLastResponseInfo dwIntError, strError, dwLength
            DeleteFile = "*ERROR (XL_FTP:DeleteFile) failed: FtpDeleteFile" & " Error: " & dwIntError & " " & strError
        Else
            DeleteFile = "*ERROR (XL_FTP:DeleteFile) failed: FtpDeleteFile" & " Error: " & Err.LastDllError
        End If
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
    '// Return the error message
    '//
    DeleteFile = "*ERROR (XL_FTP:DeleteFile) failed: Visual Basic Error " & Err.Number & " : " & Err.Description
    
'//
'// Function exit
'//
tagExit:

    Exit Function
    
End Function
Public Function GetFile(ByVal strFromFile As String, ByVal strToFile As String) As String

    Dim bRet As Boolean
    Dim dwIntError As Long
    Dim dwLength As Long
    Dim strError As String
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the function
    '//
    GetFile = "*OK"
    
    '//
    '// FTP session closed
    '//
    If cbolOpen = False Then
        GetFile = "*ERROR (XL_FTP:GetFile) failed: Session not open"
        GoTo tagExit
    End If
    
    '//
    '// Execute the FTP command
    '//
    bRet = FtpGetFile(hConnection, strFromFile, strToFile, True, FILE_ATTRIBUTE_NORMAL, FTP_TRANSFER_TYPE_ASCII, 0)
    If bRet = False Then
        If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
            InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
            strError = String(dwLength + 1, 0)
            InternetGetLastResponseInfo dwIntError, strError, dwLength
            GetFile = "*ERROR (XL_FTP:GetFile) failed: FtpGetFile" & " Error: " & dwIntError & " " & strError
        Else
            GetFile = "*ERROR (XL_FTP:GetFile) failed: FtpGetFile" & " Error: " & Err.LastDllError
        End If
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
    '// Return the error message
    '//
    GetFile = "*ERROR (XL_FTP:GetFile) failed: Visual Basic Error " & Err.Number & " : " & Err.Description
    
'//
'// Function exit
'//
tagExit:

    Exit Function
    
End Function
Public Function GetDirectory(ByVal strDirectory As String, strBuffer As String) As String

    Dim bRet As Boolean
    Dim dwIntError As Long
    Dim dwLength As Long
    Dim strError As String
    Dim hFind As Long
    Dim nLastError As Long
    Dim dError As Long
    Dim pData As WIN32_FIND_DATA
    Dim strItemName As String
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the function
    '//
    GetDirectory = "*OK"
    
    '//
    '// FTP session closed
    '//
    If cbolOpen = False Then
        GetDirectory = "*ERROR (XL_FTP:GetDirectory) failed: Session not open"
        GoTo tagExit
    End If
    
    '//
    '// Execute the FTP command
    '//
    pData.cFileName = String(MAX_PATH, 0)
    hFind = FtpFindFirstFile(hConnection, strDirectory, pData, 0, 0)
    nLastError = Err.LastDllError
    If hFind = 0 Then
        If (nLastError = ERROR_NO_MORE_FILES) Then
            strBuffer = ""
        Else
            If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
                InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
                strError = String(dwLength + 1, 0)
                InternetGetLastResponseInfo dwIntError, strError, dwLength
                GetDirectory = "*ERROR (XL_FTP:GetDirectory) failed: FtpFindFirstFile" & " Error: " & dwIntError & " " & strError
            Else
                GetDirectory = "*ERROR (XL_FTP:GetDirectory) failed: FtpFindFirstFile" & " Error: " & Err.LastDllError
            End If
        End If
        Exit Function
    End If
    
    '//
    '// Retrieve the directory data
    '//
    dError = NO_ERROR
    strBuffer = strBuffer & Left(pData.cFileName, InStr(1, pData.cFileName, String(1, 0), vbBinaryCompare) - 1) & Chr$(10)
    Do
        pData.cFileName = String(MAX_PATH, 0)
        bRet = InternetFindNextFile(hFind, pData)
        If bRet = False Then
            dError = Err.LastDllError
            If dError = ERROR_NO_MORE_FILES Then
                Exit Do
            Else
                If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
                    InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
                    strError = String(dwLength + 1, 0)
                    InternetGetLastResponseInfo dwIntError, strError, dwLength
                    GetDirectory = "*ERROR (XL_FTP:GetDirectory) failed: InternetFindNextFile" & " Error: " & dwIntError & " " & strError
                Else
                    GetDirectory = "*ERROR (XL_FTP:GetDirectory) failed: InternetFindNextFile" & " Error: " & Err.LastDllError
                End If
                InternetCloseHandle (hFind)
                Exit Function
            End If
        Else
            strBuffer = strBuffer & Left(pData.cFileName, InStr(1, pData.cFileName, String(1, 0), vbBinaryCompare) - 1) & Chr$(10)
       End If
    Loop
    InternetCloseHandle (hFind)
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:

    '//
    '// Return the error message
    '//
    GetDirectory = "*ERROR (XL_FTP:GetDirectory) failed: Visual Basic Error " & Err.Number & " : " & Err.Description
    
'//
'// Function exit
'//
tagExit:

    Exit Function
    
End Function
Public Function RemoveDirectory(ByVal strDirectory As String) As String
    
    Dim bRet As Boolean
    Dim dwIntError As Long
    Dim dwLength As Long
    Dim strError As String
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the function
    '//
    RemoveDirectory = "*OK"
    
    '//
    '// FTP session closed
    '//
    If cbolOpen = False Then
        RemoveDirectory = "*ERROR (XL_FTP:RemoveDirectory) failed: Session not open"
        GoTo tagExit
    End If
    
    '//
    '// Remove the FTP directory
    '//
    bRet = FtpRemoveDirectory(hConnection, strDirectory)
    If bRet = False Then
        If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
            InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
            strError = String(dwLength + 1, 0)
            InternetGetLastResponseInfo dwIntError, strError, dwLength
            RemoveDirectory = "*ERROR (XL_FTP:RemoveDirectory) failed: FtpRemoveDirectory" & " Error: " & dwIntError & " " & strError
        Else
            RemoveDirectory = "*ERROR (XL_FTP:RemoveDirectory) failed: FtpRemoveDirectory" & " Error: " & Err.LastDllError
        End If
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
    '// Return the error message
    '//
    RemoveDirectory = "*ERROR (XL_FTP:RemoveDirectory) failed: Visual Basic Error " & Err.Number & " : " & Err.Description
    
'//
'// Function exit
'//
tagExit:

    Exit Function
    
End Function
Public Function CreateDirectory(ByVal strDirectory As String) As String
    
    Dim bRet As Boolean
    Dim dwIntError As Long
    Dim dwLength As Long
    Dim strError As String
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the function
    '//
    CreateDirectory = "*OK"
    
    '//
    '// FTP session closed
    '//
    If cbolOpen = False Then
        CreateDirectory = "*ERROR (XL_FTP:CreateDirectory) failed: Session not open"
        GoTo tagExit
    End If
    
    '//
    '// Create the FTP directory
    '//
    bRet = FtpCreateDirectory(hConnection, strDirectory)
    If bRet = False Then
        If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
            InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
            strError = String(dwLength + 1, 0)
            InternetGetLastResponseInfo dwIntError, strError, dwLength
            CreateDirectory = "*ERROR (XL_FTP:CreateDirectory) failed: FtpCreateDirectory" & " Error: " & dwIntError & " " & strError
        Else
            CreateDirectory = "*ERROR (XL_FTP:CreateDirectory) failed: FtpCreateDirectory" & " Error: " & Err.LastDllError
        End If
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
    '// Return the error message
    '//
    CreateDirectory = "*ERROR (XL_FTP:CreateDirectory) failed: Visual Basic Error " & Err.Number & " : " & Err.Description
    
'//
'// Function exit
'//
tagExit:

    Exit Function
    
End Function

Public Function OpenSession(ByVal strServer As String, _
                            ByVal strUser As String, _
                            ByVal strPassword As String, _
                            ByVal strPath As String, _
                            ByVal intAccess As Integer) As String
    
    Dim bRet As Boolean
    Dim dwIntError As Long
    Dim dwLength As Long
    Dim strError As String
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the function
    '//
    OpenSession = "*OK"
    
    '//
    '// FTP session already open
    '//
    If cbolOpen = True Then
        OpenSession = "*ERROR (XL_FTP:OpenSession) failed: Session already open"
        GoTo tagExit
    End If
    
    '//
    '// Open the internet handle
    '//
    Select Case intAccess
        Case Is = 0
            hOpen = InternetOpen(scUserAgent, INTERNET_OPEN_TYPE_PRECONFIG, vbNullString, vbNullString, 0)
        Case Is = 1
            hOpen = InternetOpen(scUserAgent, INTERNET_OPEN_TYPE_DIRECT, vbNullString, vbNullString, 0)
        Case Else
            hOpen = InternetOpen(scUserAgent, INTERNET_OPEN_TYPE_PRECONFIG, vbNullString, vbNullString, 0)
    End Select
    If hOpen = 0 Then
        If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
            InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
            strError = String(dwLength + 1, 0)
            InternetGetLastResponseInfo dwIntError, strError, dwLength
            OpenSession = "*ERROR (XL_FTP:OpenSession) failed: InternetOpen" & " Error: " & dwIntError & " " & strError
        Else
            OpenSession = "*ERROR (XL_FTP:OpenSession) failed: InternetOpen" & " Error: " & Err.LastDllError
        End If
        GoTo tagExit
    End If
    
    '//
    '// Connect to the FTP server
    '//
    hConnection = InternetConnect(hOpen, strServer, INTERNET_INVALID_PORT_NUMBER, strUser, strPassword, INTERNET_SERVICE_FTP, INTERNET_FLAG_PASSIVE, 0)
    If hConnection = 0 Then
        If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
            InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
            strError = String(dwLength + 1, 0)
            InternetGetLastResponseInfo dwIntError, strError, dwLength
            OpenSession = "*ERROR (XL_FTP:OpenSession) failed: InternetConnect" & " Error: " & dwIntError & " " & strError
        Else
            OpenSession = "*ERROR (XL_FTP:OpenSession) failed: InternetConnect" & " Error: " & Err.LastDllError
        End If
        GoTo tagExit
    End If
    
    '//
    '// Change to the FTP directory
    '//
    bRet = FtpSetCurrentDirectory(hConnection, strPath)
    If bRet = False Then
        If Err.LastDllError = ERROR_INTERNET_EXTENDED_ERROR Then
            InternetGetLastResponseInfo dwIntError, vbNullString, dwLength
            strError = String(dwLength + 1, 0)
            InternetGetLastResponseInfo dwIntError, strError, dwLength
            OpenSession = "*ERROR (XL_FTP:OpenSession) failed: FtpSetCurrentDirectory" & " Error: " & dwIntError & " " & strError
        Else
            OpenSession = "*ERROR (XL_FTP:OpenSession) failed: FtpSetCurrentDirectory" & " Error: " & Err.LastDllError
        End If
        GoTo tagExit
    End If
    
    '//
    '// Session open
    '//
    cbolOpen = True
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:

    '//
    '// Return the error message
    '//
    OpenSession = "*ERROR (XL_FTP:OpenSession) failed: Visual Basic Error " & Err.Number & " : " & Err.Description
    
'//
'// Function exit
'//
tagExit:

    Exit Function
    
End Function

Public Function CloseSession() As String
    
    '//
    '// Start error trap
    '//
    On Error GoTo tagError
    
    '//
    '// Initialise the function
    '//
    CloseSession = "*OK"
    
    '//
    '// Close the internet handle
    '//
    If hConnection <> 0 Then
        InternetCloseHandle (hConnection)
    End If
    If hOpen <> 0 Then
        InternetCloseHandle (hOpen)
    End If
    hConnection = 0
    hOpen = 0
    
    '//
    '// Disconnect to the FTP server
    '//
    If hConnection <> 0 Then
        InternetCloseHandle (hConnection)
    End If
    hConnection = 0
    
    '//
    '// Session closed
    '//
    cbolOpen = False
    
    '//
    '// Exit the function
    '//
    GoTo tagExit
    
'//
'// Function error
'//
tagError:

    '//
    '// Return the error message
    '//
    CloseSession = "*ERROR (XL_FTP:CloseSession) failed: Visual Basic Error " & Err.Number & " : " & Err.Description
    
'//
'// Function exit
'//
tagExit:

    Exit Function
    
End Function


Private Sub Class_Initialize()

    '//
    '// Initialise private variables
    '//
    cbolOpen = False
    
End Sub

Private Sub Class_Terminate()

    Dim strReturn As String
    
    '//
    '// Close the session
    '//
    strReturn = CloseSession
    
End Sub


