using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using GaclibWebPage.Models;

namespace GaclibWebPage.Controllers
{
    public class DocumentPageController : Controller
    {
        public ActionResult ShowDocument()
        {
            string uniqueId = this.RouteData.Values["uniqueId"].ToString();
            DocumentPageModel model = new DocumentPageModel(uniqueId);
            return View(model);
        }
    }
}
