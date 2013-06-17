using System.Web;
using System.Web.Optimization;

namespace FlatFileLoaderUtility
{
    public class BundleConfig
    {
        // For more information on Bundling, visit http://go.microsoft.com/fwlink/?LinkId=254725
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js",
                        "~/Scripts/jquery-ui-{version}.js",
                        "~/Scripts/jquery.qtip.js",
                        "~/Scripts/validationEngine/jquery.validationEngine*"));

            bundles.Add(new ScriptBundle("~/bundles/site").Include(
                        "~/Scripts/json2.js",
                        "~/Scripts/jtable/jquery.jtable.js",
                        "~/Scripts/jtable/extensions/jquery.jtable.aspnetpagemethods.js",
                        "~/Scripts/menu/menu.js",
                        "~/Scripts/timepicker/jquery.ui.timepicker.js",
                        "~/Scripts/chosen/chosen.jquery.js",
                        "~/Scripts/site.js"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                        "~/Content/site.css",
                        "~/Content/themes/redmond/css",
                        "~/Content/themes/redmond/jquery-ui-{version}.css",
                        "~/Content/jquery.qtip.css",
                        "~/Scripts/validationEngine/validationEngine.jquery.css",
                        "~/Scripts/timepicker/jquery.ui.timepicker.css",
                        "~/Scripts/chosen/chosen.css"));
        }
    }
}