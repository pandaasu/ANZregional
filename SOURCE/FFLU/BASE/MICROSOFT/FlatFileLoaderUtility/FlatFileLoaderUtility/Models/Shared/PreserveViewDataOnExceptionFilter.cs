using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;

namespace FlatFileLoaderUtility.Models.Shared
{
    public class PreserveViewDataOnExceptionFilter : IExceptionFilter
    {
        public void OnException(ExceptionContext filterContext)
        {
            filterContext.Exception.HandleException(filterContext.HttpContext);

            // Copy view data contents from controller to result view
            if (filterContext.Result is ViewResult)
            {
                var viewResult = (ViewResult)filterContext.Result;
                if (viewResult != null)
                {
                    foreach (var value in filterContext.Controller.ViewData)
                    {
                        if (!viewResult.ViewData.ContainsKey(value.Key))
                            viewResult.ViewData[value.Key] = value.Value;
                    }

                    // Add the exception
                    if (filterContext.Exception != null && Properties.Settings.Default.IsTest && viewResult.ViewData["Exception"] == null)
                        viewResult.ViewData.Add("Exception", filterContext.Exception.ToString());
                }
            }
        }

        public static void Register()
        {
            FilterProviders.Providers.Add(new FilterProvider());
        }

        private class FilterProvider : IFilterProvider
        {
            public IEnumerable<Filter> GetFilters(ControllerContext controllerContext, ActionDescriptor actionDescriptor)
            {
                // Attach filter as "first" for all controllers / actions; note: exception filters run in reverse order
                // so this really causes the filter to be the last filter to execute
                yield return new Filter(new PreserveViewDataOnExceptionFilter(), FilterScope.First, null);
            }
        }
    }
}