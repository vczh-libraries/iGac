using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using NestleDatabase;

namespace NestleSpider
{
    public static class Spider
    {
        private const string Username = "geniusvczh_apptest";
        private const string Password = "fuckkula";
        private const string ApiKey = "e1424eb84b6d4169a10c03fb1e73e140";
        private const string ApiSecret = "9814021f20054b558105fca1df6559a7";
        private static NestleDatabaseServer nestleServer = null;

        private static Cookie GetSession()
        {
            string body = string.Format("api_key={0}&api_secret={1}&username={2}&password={3}", ApiKey, ApiSecret, Username, Password);
            string url = "https://www.niaowo.me/account/token/";
            byte[] bodyBytes = Encoding.UTF8.GetBytes(body);

            HttpWebRequest request = HttpWebRequest.CreateHttp(url);
            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            request.ContentLength = bodyBytes.Length;
            request.GetRequestStream().Write(bodyBytes, 0, bodyBytes.Length);
            request.CookieContainer = new CookieContainer();

            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            {
                return response.Cookies[0];
            }
        }

        private static XDocument GetXml(string path, Cookie cookie)
        {
            string url = string.Format("https://www.niaowo.me{0}", path);

            HttpWebRequest request = HttpWebRequest.CreateHttp(url);
            request.Method = "GET";
            request.CookieContainer = new CookieContainer();
            request.CookieContainer.Add(cookie);

            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            {
                return XDocument.Load(response.GetResponseStream());
            }
        }

        private static string Hex(byte[] bytes)
        {
            return new string(
                bytes
                    .SelectMany(b => new char[] {
                        "0123456789ABCDEF"[b / 16],
                        "0123456789ABCDEF"[b % 16],
                        })
                    .ToArray()
                );
        }

        public static void Run()
        {
            if (nestleServer == null)
            {
                nestleServer = new NestleDatabaseServer();
            }

            Console.WriteLine("*********************************************");
            Console.WriteLine("Downloading");
            Console.WriteLine("*********************************************");

            Cookie cookie = GetSession();
            var firstPage = GetXml("/topics.xml", cookie);
            int totalPages = int.Parse(firstPage.Root.Element("page").Element("total-pages").Value);
            List<Topic> fullTopics = new List<Topic>();
            List<Comment> fullComments = new List<Comment>();

            for (int i = 1; i <= totalPages; i++)
            {
                var topicPage = firstPage;
                if (i > 1)
                {
                    topicPage = GetXml(string.Format("/topics/page/{0}.xml", i), cookie);
                }
                Console.WriteLine("Downloading Page: {0}/{1}", i, totalPages);

                var topicIds = topicPage
                    .Root
                    .Element("topics")
                    .Elements("topic")
                    .Select(e => int.Parse(e.Element("id").Value))
                    .ToArray();

                for (int j = 0; j < topicIds.Length; j++)
                {
                    int id = topicIds[j];
                    var topicXml = GetXml(string.Format("/topics/{0}.xml?output=markdown", id), cookie);
                    var topic = new Topic(topicXml.Root.Element("topic"));
                    fullTopics.Add(topic);
                    fullComments.AddRange(topicXml.Root.Element("comments").Elements("comment").Select(x => new Comment(x, topic)).ToArray());
                    Console.WriteLine("Downloading Topic: {0}/{1} - {2}/{3}", i, totalPages, j + 1, topicIds.Length);
                }
            }

            Console.WriteLine("*********************************************");
            Console.WriteLine("Analyzing");
            Console.WriteLine("*********************************************");

            NestleData data = new NestleData(null);
            data.Topics = fullTopics.ToDictionary(x => x.Id, x => x);
            data.Comments = fullComments.ToDictionary(x => x.Id, x => x);
            data.AuthorTopics = fullTopics.Select(x => new AuthorWork(null) { Author = x.Author, id = x.Id }).ToArray();
            data.AuthorComments = fullComments.Select(x => new AuthorWork(null) { Author = x.Author, id = x.Id }).ToArray();
            nestleServer.Data = data;

            Console.WriteLine("*********************************************");
            Console.WriteLine("Finished");
            Console.WriteLine("*********************************************");
        }
    }
}
