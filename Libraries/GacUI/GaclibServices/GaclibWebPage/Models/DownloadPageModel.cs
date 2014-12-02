using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace GaclibWebPage.Models
{
    public class DownloadPageModel : NavigationBarModel
    {
        public DownloadVersionUrls[] Versions { get; private set; }

        public DownloadPageModel()
        {
            this.Versions = new DownloadVersionUrls[] { 
                new DownloadVersionUrls{ Version="0.7.5.0", Url="https://gac.codeplex.com/releases/view/136882" },
                new DownloadVersionUrls{ Version="0.7.4.0", Url="https://gac.codeplex.com/releases/view/125731" },
                new DownloadVersionUrls{ Version="0.7.3.0", Url="https://gac.codeplex.com/releases/view/121919" },
                new DownloadVersionUrls{ Version="0.7.2.0", Url="https://gac.codeplex.com/releases/view/121015" },
                new DownloadVersionUrls{ Version="0.7.1.0", Url="https://gac.codeplex.com/releases/view/120775" },
                new DownloadVersionUrls{ Version="0.7.0.0", Url="https://gac.codeplex.com/releases/view/120100" },
                new DownloadVersionUrls{ Version="0.6.0.0", Url="https://gac.codeplex.com/releases/view/114806" },
                new DownloadVersionUrls{ Version="0.5.5.0", Url="https://gac.codeplex.com/releases/view/113889" },
                new DownloadVersionUrls{ Version="0.5.4.0", Url="https://gac.codeplex.com/releases/view/112090" },
                new DownloadVersionUrls{ Version="0.5.3.0", Url="https://gac.codeplex.com/releases/view/110703" },
                new DownloadVersionUrls{ Version="0.5.2.0", Url="https://gac.codeplex.com/releases/view/108424" },
                new DownloadVersionUrls{ Version="0.5.1.0", Url="https://gac.codeplex.com/releases/view/105044" },
                new DownloadVersionUrls{ Version="0.5.0.0", Url="https://gac.codeplex.com/releases/view/103284" },
                new DownloadVersionUrls{ Version="0.4.3.0", Url="https://gac.codeplex.com/releases/view/100843" },
                new DownloadVersionUrls{ Version="0.4.2.0", Url="https://gac.codeplex.com/releases/view/100843" },
                new DownloadVersionUrls{ Version="0.4.1.0", Url="https://gac.codeplex.com/releases/view/98192" },
                new DownloadVersionUrls{ Version="0.4.0.0", Url="https://gac.codeplex.com/releases/view/96473" },
                new DownloadVersionUrls{ Version="0.3.0.0", Url="https://gac.codeplex.com/releases/view/92292" },
                new DownloadVersionUrls{ Version="0.2.5.0", Url="https://gac.codeplex.com/releases/view/91058" },
                new DownloadVersionUrls{ Version="0.2.0.0", Url="https://gac.codeplex.com/releases/view/89642" },
                new DownloadVersionUrls{ Version="0.1.0.0", Url="https://gac.codeplex.com/releases/view/88533" },
            };
        }
    }

    public class DownloadVersionUrls
    {
        public string Version { get; set; }
        public string Url { get; set; }
    }
}