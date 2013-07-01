using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using FlatFileLoaderUtility.Models.Shared;
using FlatFileLoaderUtility.App_Start;

namespace FlatFileLoaderUtility
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();

            WebApiConfig.Register(GlobalConfiguration.Configuration);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            // Working around a bug in MVC.NET
            // http://stackoverflow.com/questions/9577375/how-can-i-handle-large-json-input-from-postmark-in-my-mvc-application
            ValueProviderFactories.Factories.Remove(ValueProviderFactories.Factories.OfType<JsonValueProviderFactory>().FirstOrDefault());
            ValueProviderFactories.Factories.Add(new JsonDotNetValueProviderFactory());

            PreserveViewDataOnExceptionFilter.Register();
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            // Note: any MVC errors will be handled by BaseController.OnException
            // The only exceptions that should reach here are from outside the MVC pipeline (eg 404 error)

            var exception = this.Server.GetLastError();

            if (exception != null)
                exception.HandleException(new HttpContextWrapper(this.Context));
        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            if (!HttpContext.Current.Request.IsSecureConnection && Properties.Settings.Default.UseSsl)
            {
                Response.Redirect("https://" + Request.ServerVariables["HTTP_HOST"] + HttpContext.Current.Request.RawUrl);
            }
        }
    }
}