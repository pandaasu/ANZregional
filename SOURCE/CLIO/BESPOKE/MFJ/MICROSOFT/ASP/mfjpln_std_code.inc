<%
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
   ''strUser = UCase(request.ServerVariables("LOGON_USER"))
   strUser = "Guest"
   GetUser = strUser

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
   set objForm = Server.CreateObject("XL_FORM.Object")
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
   '// 1. Initialises the security from the supplied security XML file path
   '// 2. Authenticates the current logon user against the security settings
   '// 3. Returns the result string
   '//
   dim strReturn
   set objSecurity = Server.CreateObject("XL_Security.Object")
   strReturn = objSecurity.Initialise("e:\data\mfjacc\security.txt", GetUser())
   GetSecurity = strReturn 

end function

'///////////////////////
'// Get menu function //
'///////////////////////
function GetMenu()

   '//
   '// Returns the menu XML file path
   '//
   GetMenu = "e:\data\mfjacc\menu.txt"

end function
%>