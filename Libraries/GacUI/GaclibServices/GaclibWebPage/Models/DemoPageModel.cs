using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.Linq;
using System.IO;

namespace GaclibWebPage.Models
{
    public class DemoPageModel : NavigationBarModel
    {
        public const string DefaultXmlIndexPath = "~/Content/Demos/Index.xml";

        public static IndividualDemoCategoryModel[] LoadCategories(string xmlIndexPath)
        {
            XDocument xmlIndex = XDocument.Load(xmlIndexPath);
            List<IndividualDemoCategoryModel> categories = new List<IndividualDemoCategoryModel>();
            foreach (var xmlCategory in xmlIndex.Root.Elements("category"))
            {
                List<IndividualDemoModel> demos = new List<IndividualDemoModel>();
                string category = xmlCategory.Attribute("name").Value;
                foreach (var xmlDemo in xmlCategory.Elements("demo"))
                {
                    string title = xmlDemo.Attribute("name").Value;
                    IndividualDemoModel demo = new IndividualDemoModel
                    {
                        Title = title,
                        Name = category + "." + title,
                        Images = xmlDemo.Elements("image").Select(e => e.Attribute("src").Value).ToArray(),
                        UpdateDate = DateTime.Parse(xmlDemo.Element("date").Value),
                        Description = xmlDemo.Element("description").Value,
                        CppCodes = xmlDemo.Elements("cpp").Select(e => e.Attribute("src").Value).ToDictionary(s => s, s => ""),
                    };
                    demos.Add(demo);
                }
                categories.Add(new IndividualDemoCategoryModel
                {
                    Name = category,
                    Description = xmlCategory.Element("description").Value,
                    Demos = demos.ToArray(),
                });
            }
            return categories.ToArray();
        }

        public static IndividualDemoModel LoadDemo(string xmlIndexPath, string name)
        {
            IndividualDemoModel page = LoadCategories(xmlIndexPath)
                .SelectMany(c => c.Demos)
                .Where(d => d.Name == name)
                .First();
            string[] cppFiles = page.CppCodes.Keys.ToArray();
            page.CppCodes = cppFiles
                .ToDictionary(
                    s => s,
                    s => File.ReadAllText(string.Format("{0}/{1}/{2}", Path.GetDirectoryName(xmlIndexPath), page.Name, s))
                    );
            return page;
        }

        public IndividualDemoCategoryModel[] DemoCategories { get; set; }

        public DemoPageModel(string xmlIndexPath)
        {
            this.DemoCategories = LoadCategories(xmlIndexPath);
        }
    }
}