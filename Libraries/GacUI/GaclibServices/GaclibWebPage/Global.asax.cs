using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace GaclibWebPage
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }

        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                "Default",
                "",
                new { controller = "Home", action = "Index" }
            );

            routes.MapRoute(
                "TopNavigationPage",
                "{action}.html",
                new { controller = "Home" }
            );

            routes.MapRoute(
                "IndividualDemoPage",
                "Demos/{demoId}/Demo.html",
                new { controller = "DemoPage", action = "ShowDemo" }
            );

            routes.MapRoute(
                "DocumentPage",
                "Document/{uniqueId}.html",
                new { controller = "DocumentPage", action = "ShowDocument" }
            );
        }

        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();

            RegisterGlobalFilters(GlobalFilters.Filters);
            RegisterRoutes(RouteTable.Routes);
        }
    }
}