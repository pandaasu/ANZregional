using System;
using System.Linq;
using System.Web.Mvc;

namespace FlatFileLoaderUtility.Controllers
{
    public class HomeController : BaseController
    {
        public ActionResult Index()
        {
            return this.RedirectToAction("Index", "Uploads");
        }
    }
}
