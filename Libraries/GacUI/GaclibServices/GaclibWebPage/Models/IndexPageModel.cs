using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace GaclibWebPage.Models
{
    public class IndexPageModel : NavigationBarModel
    {
        public IndividualDemoModel LatestUpdateDemo { get; set; }

        public IndexPageModel(string xmlIndexPath)
        {
            this.LatestUpdateDemo = new DemoPageModel(xmlIndexPath)
                .DemoCategories
                .SelectMany(c=>c.Demos)
                .OrderBy(d => d.UpdateDate)
                .Last();
        }
    }

    public class IndexPageMirrorSite
    {
        public string Url { get; set; }
        public string Description { get; set; }
    }
}