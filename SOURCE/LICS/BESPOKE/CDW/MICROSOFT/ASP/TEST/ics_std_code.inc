<%
'////////////////////////////////
'// Get character set function //
'////////////////////////////////
function GetCharSet()

   '//
   '// Returns the character set string ISO-8859-1, Shift-JIS, UTF-8
   '//
   GetCharSet = "ISO-8859-1" 

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
   strBase = strBase & ":" & Request.ServerVariables("SERVER_PORT")
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
   strUser = UCase(Request.ServerVariables("LOGON_USER"))
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

'////////////////////////
'// Get sites function //
'////////////////////////
function GetSites()

   '//
   '// 1. Retrieves the sites from the supplied security XML file path
   '// 2. Returns the result string
   '//
   dim strReturn
   set objSecurity = Server.CreateObject("ICS_SECURITY.Object")
   strReturn = objSecurity.GetSites(Server.MapPath("/ics_security.txt"))
   GetSites = strReturn

end function

'///////////////////////////
'// Get security function //
'///////////////////////////
function GetSecurity()

   '//
   '// 1. Initialises the security from the supplied security XML file path
   '// 2. Authenticates the current logon user against the security settings
   '// 3. Returns the result string
   '//
   dim strReturn
   set objSecurity = Server.CreateObject("ICS_SECURITY.Object")
   strReturn = objSecurity.InitialiseSite(Server.MapPath("/ics_security.txt"),session("ics_site_code"))
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
   strReturn = objSecurity.InitialiseSiteCheck(Server.MapPath("/ics_security.txt"),session("ics_site_code"),GetUser(),strOption)
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