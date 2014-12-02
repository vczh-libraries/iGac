using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace GaclibWebPage.Models
{
    public enum NavigationButtons
    {
        Home,
        GettingStart,
        Demos,
        Download,
        Document,
        Contact,
    }

    public class NavigationBarModel
    {
        public NavigationButtons ActiveButton { get; set; }
    }
}