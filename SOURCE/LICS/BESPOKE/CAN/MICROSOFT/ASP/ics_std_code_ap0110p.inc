<%
'//////////////////////////////
'// Get environment function //
'//////////////////////////////
function GetEnvironment()

   '//
   '// Returns the environment string
   '// (Devp, Test, Prod)
   '//
   GetEnvironment = "Prod" 

end function

'//////////////////////////////
'// Get installation function //
'//////////////////////////////
function GetInstallation()

   '//
   '// Returns the installation string
   '//
   GetInstallation = "CUC" 

end function

'////////////////////////////////
'// Get character set function //
'////////////////////////////////
function GetCharSet()

   '//
   '// Returns the character set string ISO-8859-1, Shift-JIS
   '//
   GetCharSet = "UTF-8" 

end function

'///////////////////////
'// Get base function //
'///////////////////////
function GetBase()

   '//
   '// Returns the base URL string
   '//
   dim strBase
   strBase = "http://" & Request.ServerVariables("SERVER_NAME")
   strBase = strBase & left(Request.ServerVariables("PATH_INFO"), instrRev(Request.ServerVariables("PATH_INFO"), "/"))
   GetBase = strBase

end function

'///////////////////////
'// Get user function //
'///////////////////////
function GetUser()

   '//
   '// Returns the current logon user
   '//
   dim strUser
   strUser = UCase(request.ServerVariables("LOGON_USER"))
   GetUser = replace(replace(replace(strUser,"MARSDOM",""),"/",""),"\","")

end function

'/////////////////////////
'// Get status function //
'/////////////////////////
function GetStatus()

   '//
   '// Returns the current status string
   '//
   dim strStatus
   strStatus = UCase(GetUser()) & " - " & FormatDateTime(Now, 1) & " " & FormatDateTime(Now, 3)
   GetStatus = strStatus 

end function

'////////////////////////
'// Get form procedure //
'////////////////////////
sub GetForm()

   '//
   '// 1. Loads the request form and query string data into the form object
   '// 2. Returns the form object reference
   '//
   dim x
   set objForm = Server.CreateObject("ICS_FORM.Object")
   for each x in Request.Form
      call objForm.AddField(cstr(x), cstr(Request.Form(x)))
   next
   if Request.QueryString <> "" then
      for each x in Request.QueryString
         call objForm.AddField(cstr(x), cstr(Request.QueryString(x)))
      next
   end if

end sub

'///////////////////////////
'// Get security function //
'///////////////////////////
function GetSecurity()

   '//
   '// 1. Initialises the security from the database
   '// 2. Authenticates the current logon user against the security settings
   '// 3. Returns the result string
   '//
   dim strReturn
   set objSecurity = Server.CreateObject("ICS_SECURITY.Object")
   strReturn = objSecurity.Initialise("D:\Inetpub\IISWebs\care.ap.mars\cuc\ics_security.txt")
   GetSecurity = strReturn 

end function

'/////////////////////////////////
'// Get security check function //
'/////////////////////////////////
function GetSecurityCheck(strOption)

   '//
   '// 1. Initialises the security from the database
   '// 2. Authenticates the current logon user and option against the security settings
   '// 3. Returns the result string
   '//
   dim strReturn
   set objSecurity = Server.CreateObject("ICS_SECURITY.Object")
   strReturn = objSecurity.InitialiseCheck("D:\Inetpub\IISWebs\care.ap.mars\cuc\ics_security.txt",GetUser(),strOption)
   GetSecurityCheck = strReturn 

end function

'///////////////////////////
'// Format error function //
'///////////////////////////
function FormatError(strError)

   '//
   '// Replace javascript non-printable characters
   '//
   strError = replace(strError, "\", "\\", 1, -1, 1)
   strError = replace(strError, "?", "\?", 1, -1, 1)
   strError = replace(strError, "'", "\'", 1, -1, 1)
   strError = replace(strError, """", "\""", 1, -1, 1)
   strError = replace(strError, chr(9), "\t", 1, -1, 1)
   strError = replace(strError, chr(10), "\r\n", 1, -1, 1)
   strError = replace(strError, chr(13), "\r\n", 1, -1, 1)

   '//
   '// Return the error
   '//
   FormatError = strError

end function
%>
