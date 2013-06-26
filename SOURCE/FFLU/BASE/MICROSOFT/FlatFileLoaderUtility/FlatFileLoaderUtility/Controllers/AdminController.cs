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
            List<string> toRemove = new List<string>();
            foreach (DictionaryEntry cacheItem in HttpRuntime.Cache)
            {
                toRemove.Add(cacheItem.Key.ToString());
            }
            foreach (string key in toRemove)
            {
                HttpRuntime.Cache.Remove(key);
            }

            // It would seem that Oracle is re-using sessions across connections.
            // ie, when viewing the results from select * from v$session where username = 'FFLU_EXECUTOR'
            // it seems that a single session is being re-used even though the connection to the
            // database from the web app is being terminated at the end of each call to a controller.
            // Consequently, some data seems to be cached by Oracle, and weird things happen...
            // The fix for this is apparently to call dbms_session.reset_package.

            this.Container.ConnectionRepository.ResetPackage();

            return this.View();
        }

        #endregion
    }
}
