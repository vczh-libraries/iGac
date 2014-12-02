using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using GaclibWebPage.Models;

namespace GaclibWebPage.Controllers
{
    public class DemoPageController : Controller
    {
        public ActionResult ShowDemo()
        {
            string name = this.RouteData.Values["demoId"].ToString();
            IndividualDemoModel model = DemoPageModel.LoadDemo(Server.MapPath(DemoPageModel.DefaultXmlIndexPath), name);
            model.ActiveButton = NavigationButtons.Demos;
            return View(model);
        }
    }
}
