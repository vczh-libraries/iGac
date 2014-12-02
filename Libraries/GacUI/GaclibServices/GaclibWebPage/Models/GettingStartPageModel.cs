using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace GaclibWebPage.Models
{
    public class GettingStartPageModel : NavigationBarModel
    {
        public string[] TutorialTitles { get; private set; }

        public GettingStartPageModel()
        {
            this.TutorialTitles = new string[]{
                "Create a Visual C++ Project will GacUI source code.",
                "Write your first GacUI program using C++.",
                "Write your second GacUI program using XML.",
                "Build and run!",
                "Applying MVVM (Model-View-ViewModel) pattern.",
                "Precompile your XML resource to enhance the performance.",
            };
        }
    }
}