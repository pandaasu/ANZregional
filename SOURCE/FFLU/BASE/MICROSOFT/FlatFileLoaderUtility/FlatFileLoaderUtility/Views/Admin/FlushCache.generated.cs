#pragma warning disable 1591
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.1008
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace FlatFileLoaderUtility.Views.Admin
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
    [System.Web.WebPages.PageVirtualPathAttribute("~/Views/Admin/FlushCache.cshtml")]
    public partial class FlushCache : System.Web.Mvc.WebViewPage<dynamic>
    {
        public FlushCache()
        {
        }
        public override void Execute()
        {
            
            #line 1 "..\..\Views\Admin\FlushCache.cshtml"
  
    ViewBag.Title = "Cache Flushed";

            
            #line default
            #line hidden
WriteLiteral("\r\n<br />\r\n<p>\r\n    The File Loader Utility application cache has been flushed.\r\n<" +
"/p>\r\n<p>\r\n    And dbms_session.package_reset has been called on the Oracle sessi" +
"on.\r\n</p>\r\n<br />\r\n<br />\r\n<br />");

        }
    }
}
#pragma warning restore 1591
