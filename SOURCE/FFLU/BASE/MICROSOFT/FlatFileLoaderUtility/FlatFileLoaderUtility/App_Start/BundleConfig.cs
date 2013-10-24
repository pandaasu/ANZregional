using System.Web;
using System.Web.Optimization;

namespace FlatFileLoaderUtility
{
    public class BundleConfig
    {
        // For more information on Bundling, visit http://go.microsoft.com/fwlink/?LinkId=254725
        public static void RegisterBundles(BundleCollection bundles)
        {
            //BundleTable.EnableOptimizations = false;

            bundles.Add(new ScriptBundle("~/bundles/site").Include(
                        "~/Scripts/jquery-{version}.js",
                        "~/Scripts/jquery-ui-{version}.js",
                        "~/Scripts/jquery.qtip.js",
                        "~/Scripts/validationEngine/jquery.validationEngine*",
                        "~/Scripts/json2.js",
                        "~/Scripts/jquery.hoverintent.js",
                        "~/Scripts/dropit.js",
                        "~/Scripts/placeholders.js",
                        "~/Scripts/timepicker/jquery.ui.timepicker.js",
                        "~/Scripts/chosen/chosen.jquery.js",
                        "~/Scripts/modernizr-{version}.js",
                        "~/Scripts/site.js",
                        "~/Scripts/lzma.js"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                        "~/Content/jquery-ui-1.9.1.css",
                        "~/Content/jtable_standard_base.css",
                        "~/Content/jtable_blue.css",
                        "~/Content/chosen.css", 
                        "~/Content/site.css",
                        "~/Content/jquery.qtip.css",
                        "~/Scripts/validationEngine/validationEngine.jquery.css",
                        "~/Scripts/timepicker/jquery.ui.timepicker.css"));
        }
    }
}