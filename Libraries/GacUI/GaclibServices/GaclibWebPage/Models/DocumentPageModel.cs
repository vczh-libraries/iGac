using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.WindowsAzure;
using Microsoft.WindowsAzure.StorageClient;
using System.Xml.Linq;
using System.IO;
using System.Web.Mvc;
using System.Text.RegularExpressions;

namespace GaclibWebPage.Models
{
    public class DocumentPageModel
    {
        public class IndexNode
        {
            public string Title { get; set; }
            public int Level { get; set; }
            public string UniqueId { get; set; }
            public bool Link { get; set; }
        };

        public class ContentFragment
        {
            public string Text { get; set; }
            public bool IsUniqueId { get; set; }
        }

        public string Title { get; set; }
        public string UniqueId { get; set; }
        public IndexNode[] IndexTree { get; set; }
        public ContentFragment[] Content { get; set; }

        private static Regex regexUniqueId = new Regex(@"\$UNIQUEIDLINK\((?<id>[^)]+)\)");

        public DocumentPageModel(string uniqueId)
        {
            var connectionString = CloudConfigurationManager.GetSetting("DocumentConnectionString");
            var account = CloudStorageAccount.Parse(connectionString);
            var blobClient = new CloudBlobClient(account.BlobEndpoint.AbsoluteUri, account.Credentials);
            var container = blobClient.GetContainerReference("gaclib-meta-doc");
            var blobRef = container.GetBlobReference(uniqueId);
            string xmlText = blobRef.DownloadText();
            xmlText = xmlText.Substring(xmlText.IndexOf("<metaDoc>"));
            XDocument xmlDocument = XDocument.Parse(xmlText);

            this.Title = xmlDocument.Root.Element("title").Value;
            this.UniqueId = xmlDocument.Root.Element("uniqueId").Value;

            var indexNodes = xmlDocument.Root.Element("indexTree").Elements("indexNode").ToArray();
            this.IndexTree = indexNodes
                .Select(e => new IndexNode()
                {
                    Title = e.Element("title").Value,
                    Level = int.Parse(e.Element("level").Value),
                    UniqueId = e.Element("uniqueId").Value,
                    Link = e.Element("link").Value == "true",
                })
                .ToArray();

            string contentString = xmlDocument.Root.Element("content").Value;
            var matches = regexUniqueId.Matches(contentString);
            List<ContentFragment> content = new List<ContentFragment>();

            int index = 0;
            foreach (Match match in matches)
            {
                if (index < match.Index)
                {
                    content.Add(new ContentFragment
                    {
                        Text = contentString.Substring(index, match.Index - index),
                        IsUniqueId = false,
                    });
                }
                content.Add(new ContentFragment
                {
                    Text = match.Groups["id"].Value,
                    IsUniqueId = true,
                });
                index = match.Index + match.Length;
            }
            if (index < contentString.Length)
            {
                content.Add(new ContentFragment
                {
                    Text = contentString.Substring(index, contentString.Length - index),
                    IsUniqueId = false,
                });
            }
            this.Content = content.ToArray();
        }
    }
}