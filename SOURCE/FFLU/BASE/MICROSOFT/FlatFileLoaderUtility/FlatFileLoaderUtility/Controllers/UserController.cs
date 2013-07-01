using System;
using System.Linq;
using System.Web.Mvc;
using FlatFileLoaderUtility.Models.Shared;
using FlatFileLoaderUtility.ViewModels;

namespace FlatFileLoaderUtility.Controllers
{
    public class UserController : BaseController
    {
        #region Override Methods

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            filterContext.Controller.ViewBag.IsMenuUser = true;
            base.OnActionExecuting(filterContext);
        }

        #endregion

        #region SwitchUser

        public ActionResult SwitchUser()
        {
            if (!this.Request.IsSecureConnection)
                return this.RedirectToAction("Index", "Uploads");

            return this.View();
        }

        [HttpPost]
        public ActionResult SwitchUser(UserViewModel user)
        {
            var access = Access.Impersonate(this.HttpContext, user.Username, user.Password);
            if (access == null)
            {
                // Authentication with those credentials failed
                var message = string.Empty;
                if (!string.IsNullOrWhiteSpace(user.Username) && !string.IsNullOrWhiteSpace(user.Password))
                    message = "Login failed. Please verify your login details.";
                this.ModelState.AddModelError(string.Empty, message);
            }
            else
            {
                this.Container.Access = access;
                this.ControllerContext.Controller.ViewBag.Access = this.Container.Access;
                return this.RedirectToAction("Index", "Home");
            }

            return View(user);
        }

        #endregion

        #region Logoff

        public ActionResult Logoff()
        {
            this.Session.Clear();
            this.Container.Access = Access.Logoff(this.HttpContext);
            return this.RedirectToAction("SwitchUser");
        }

        #endregion
    }
}
