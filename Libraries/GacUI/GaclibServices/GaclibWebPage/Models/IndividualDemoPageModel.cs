using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace GaclibWebPage.Models
{
    public class IndividualDemoModel : NavigationBarModel
    {
        public string Title { get; set; }
        public string Name { get; set; }
        public string[] Images { get; set; }
        public DateTime UpdateDate { get; set; }
        public string Description { get; set; }
        public Dictionary<string, string> CppCodes { get; set; }

        public IndividualDemoModel()
        {
            this.Title = "";
            this.Images = new string[0];
            this.CppCodes = new Dictionary<string, string>();
        }
    }

    public class IndividualDemoCategoryModel : NavigationBarModel
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public IndividualDemoModel[] Demos { get; set; }
    }
}