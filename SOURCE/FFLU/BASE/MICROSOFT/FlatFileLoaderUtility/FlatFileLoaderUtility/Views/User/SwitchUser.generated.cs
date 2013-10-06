﻿#pragma warning disable 1591
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.1008
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace FlatFileLoaderUtility.Views.User
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Net;
    using System.Text;
    using System.Web;
    using System.Web.Helpers;
    using System.Web.Mvc;
    using System.Web.Mvc.Ajax;
    using System.Web.Mvc.Html;
    using System.Web.Optimization;
    using System.Web.Routing;
    using System.Web.Security;
    using System.Web.UI;
    using System.Web.WebPages;
    using FlatFileLoaderUtility.Models;
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("RazorGenerator", "2.0.0.0")]
    [System.Web.WebPages.PageVirtualPathAttribute("~/Views/User/SwitchUser.cshtml")]
    public partial class SwitchUser : System.Web.Mvc.WebViewPage<FlatFileLoaderUtility.ViewModels.UserViewModel>
    {
        public SwitchUser()
        {
        }
        public override void Execute()
        {
            
            #line 3 "..\..\Views\User\SwitchUser.cshtml"
  
    ViewBag.Title = "Switch User";

            
            #line default
            #line hidden
WriteLiteral("\r\n\r\n");

DefineSection("JavascriptImport", () => {

WriteLiteral("\r\n    <script");

WriteLiteral(" type=\"text/javascript\"");

WriteLiteral(@">
        $(document).ready(function () {
            
            $(""#btnLogin"").click(function () {
                $(this).find(""span"").text(""Authenticating"");
                $(""form :input"").attr(""disabled"", ""disabled"");
                
                $.ajax({
                    type: ""post"",
                    url: ""/User/SwitchUser"",
                    contentType: ""application/json"",
                    data: JSON.stringify({
                        username: $(""#txtusername"").val(),
                        password: $(""#txtPassword"").val()
                    }),
                    xhrFields: {
                        withCredentials: true
                    },
                    success: function (response) {
                        if (response.Result == ""OK"") {
                            $(""#btnCancelDraft span"").text(""Cancelled"");
                            $(""#status"").text(""Cancelled"");
                            isDirty = false;
                        }
                        else {
                            alert(""Error: "" + response.Message);
                            $(""#btnCancelDraft span"").text(""Log in"");
                            $(""form :input"").removeAttr(""disabled"");
                        }
                    }
                });
            });
        });
    </script>
");

});

WriteLiteral("\r\n<div");

WriteLiteral(" class=\"main switch\"");

WriteLiteral(">\r\n    <p>You are currently logged in as <strong>");

            
            #line 45 "..\..\Views\User\SwitchUser.cshtml"
                                         Write(ViewBag.Access.Username);

            
            #line default
            #line hidden
WriteLiteral("</strong>.</p>\r\n    <p>With that login, you are connected to <strong>");

            
            #line 46 "..\..\Views\User\SwitchUser.cshtml"
                                                Write(ViewBag.Connection.ConnectionName);

            
            #line default
            #line hidden
WriteLiteral("</strong> as <strong>");

            
            #line 46 "..\..\Views\User\SwitchUser.cshtml"
                                                                                                       Write(ViewBag.User.UserName);

            
            #line default
            #line hidden
WriteLiteral("</strong>.</p>\r\n    <p>To log in as a different user, enter the credentials below" +
".</p>\r\n\r\n");

            
            #line 49 "..\..\Views\User\SwitchUser.cshtml"
    
            
            #line default
            #line hidden
            
            #line 49 "..\..\Views\User\SwitchUser.cshtml"
     using (Html.BeginForm("SwitchUser", "User", FormMethod.Post, new { autocomplete = "off" }))
    {
        
            
            #line default
            #line hidden
            
            #line 51 "..\..\Views\User\SwitchUser.cshtml"
   Write(Html.ValidationSummary(true, string.Empty));

            
            #line default
            #line hidden
            
            #line 51 "..\..\Views\User\SwitchUser.cshtml"
                                                   

            
            #line default
            #line hidden
WriteLiteral("        <table");

WriteLiteral(" cellspacing=\"12\"");

WriteLiteral(">\r\n            <tr");

WriteLiteral(" valign=\"top\"");

WriteLiteral(">\r\n                <td");

WriteLiteral(" style=\"width:100px;\"");

WriteLiteral(">");

            
            #line 54 "..\..\Views\User\SwitchUser.cshtml"
                                    Write(Html.LabelFor(x => x.Username));

            
            #line default
            #line hidden
WriteLiteral("</td>\r\n                <td>");

            
            #line 55 "..\..\Views\User\SwitchUser.cshtml"
               Write(Html.TextBoxFor(x => x.Username, new { style = "text-transform:uppercase;" }));

            
            #line default
            #line hidden
WriteLiteral("\r\n");

WriteLiteral("                    ");

            
            #line 56 "..\..\Views\User\SwitchUser.cshtml"
               Write(Html.ValidationMessageFor(x => x.Username));

            
            #line default
            #line hidden
WriteLiteral("\r\n                </td>\r\n            </tr>\r\n            <tr");

WriteLiteral(" valign=\"top\"");

WriteLiteral(">\r\n                <td>");

            
            #line 60 "..\..\Views\User\SwitchUser.cshtml"
               Write(Html.LabelFor(x => x.Password));

            
            #line default
            #line hidden
WriteLiteral("</td>\r\n                <td>");

            
            #line 61 "..\..\Views\User\SwitchUser.cshtml"
               Write(Html.PasswordFor(x => x.Password));

            
            #line default
            #line hidden
WriteLiteral("\r\n");

WriteLiteral("                    ");

            
            #line 62 "..\..\Views\User\SwitchUser.cshtml"
               Write(Html.ValidationMessageFor(x => x.Password));

            
            #line default
            #line hidden
WriteLiteral("\r\n                </td>\r\n            </tr>\r\n            <tr");

WriteLiteral(" valign=\"top\"");

WriteLiteral(">\r\n                <td></td>\r\n                <td><button");

WriteLiteral(" type=\"submit\"");

WriteLiteral(">Log in</button></td>\r\n            </tr>\r\n        </table>\r\n");

            
            #line 70 "..\..\Views\User\SwitchUser.cshtml"
    }

            
            #line default
            #line hidden
WriteLiteral("    <br />\r\n    <br />\r\n    <br />\r\n    <br />\r\n    <br />\r\n</div>\r\n<br />\r\n");

        }
    }
}
#pragma warning restore 1591
