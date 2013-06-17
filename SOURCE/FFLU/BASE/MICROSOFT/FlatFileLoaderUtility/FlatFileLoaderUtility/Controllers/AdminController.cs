using System;
using System.Linq;
using System.Collections;
using System.Web;
using System.Web.Mvc;
using FlatFileLoaderUtility.Models;
using FlatFileLoaderUtility.Models.Shared;
using System.Collections.Generic;

namespace FlatFileLoaderUtility.Controllers
{
    public class AdminController : BaseController
    {
        #region Override Methods

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            filterContext.Controller.ViewBag.IsMenuAdmin = true;
            base.OnActionExecuting(filterContext);
        }

        #endregion
        
        #region Flush Cache

        public ActionResult FlushCache()
        {
            //if (!this.Container.Access.IsSuperAdmin)
            //{
            //    return this.RedirectToAction("AccessDenied", "Admin");
            //}

            List<string> toRemove = new List<string>();
            foreach (DictionaryEntry cacheItem in HttpRuntime.Cache)
            {
                toRemove.Add(cacheItem.Key.ToString());
            }
            foreach (string key in toRemove)
            {
                HttpRuntime.Cache.Remove(key);
            }

            return this.View();
        }

        #endregion
    }
}
