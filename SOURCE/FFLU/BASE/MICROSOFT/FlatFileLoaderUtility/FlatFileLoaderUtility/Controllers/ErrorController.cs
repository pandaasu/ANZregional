using System;
using System.Linq;
using System.Web.Mvc;
using FlatFileLoaderUtility.Models.Shared;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Controllers
{
    /// <summary>
    /// Note: this controller is used only for exceptions that happen outside the MVC pipeline, such as 404 errors,
    /// which are handled by Application_Error in Global.asax.cs
    /// </summary>
    public class ErrorController : BaseController
    {
        #region Override Methods

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var connection = Connection.GetConnection(this.HttpContext);
            filterContext.Controller.ViewBag.Access = Access.GetAccess(this.HttpContext);
            filterContext.Controller.ViewBag.Connection = connection;
            filterContext.Controller.ViewBag.Connections = this.GetConnections(true, connection.ConnectionId);
            filterContext.Controller.ViewBag.User = new User();
            filterContext.Controller.ViewBag.IsTest = Properties.Settings.Default.IsTest;
            filterContext.Controller.ViewBag.IsSecure = this.Request.IsSecureConnection;

            //base.OnActionExecuting(filterContext);
        }

        #endregion

        #region Index

        public ActionResult Index()
        {
            this.HttpContext.Response.StatusCode = 500;
            this.HttpContext.Response.TrySkipIisCustomErrors = true;

            var ex = (Exception)this.Session["exception"];
            if (ex != null && Properties.Settings.Default.IsTest)
                this.ViewBag.Exception = ex.ToString();

            return this.View();
        }

        #endregion

        #region Http404

        public ActionResult Http404()
        {
            return this.View();
        }

        #endregion
    }
}