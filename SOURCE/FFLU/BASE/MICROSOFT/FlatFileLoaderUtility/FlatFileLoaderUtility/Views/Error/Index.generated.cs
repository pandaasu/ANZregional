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

namespace FlatFileLoaderUtility.Views.Error
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
    [System.Web.WebPages.PageVirtualPathAttribute("~/Views/Error/Index.cshtml")]
    public partial class Index : System.Web.Mvc.WebViewPage<System.Web.Mvc.HandleErrorInfo>
    {
        public Index()
        {
        }
        public override void Execute()
        {
            
            #line 3 "..\..\Views\Error\Index.cshtml"
  
    ViewBag.Title = "Error";

            
            #line default
            #line hidden
WriteLiteral("\r\n\r\n<hgroup");

WriteLiteral(" class=\"title\"");

WriteLiteral(">\r\n    <h1");

WriteLiteral(" class=\"error\"");

WriteLiteral(">Server Error</h1>\r\n    <h2");

WriteLiteral(" class=\"error\"");

WriteLiteral(">An error occurred while processing your request.</h2>\r\n    <pre");

WriteLiteral(" class=\"exception\"");

WriteLiteral(">\r\n");

WriteLiteral("        ");

            
            #line 11 "..\..\Views\Error\Index.cshtml"
   Write(ViewBag.Exception);

            
            #line default
            #line hidden
WriteLiteral("\r\n    </pre>\r\n</hgroup>\r\n");

        }
    }
}
#pragma warning restore 1591
