using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using AzureStorageFacadeLibrary;
using Microsoft.WindowsAzure.StorageClient;

namespace NestleDatabase
{
    public class NestleDatabaseServer
    {
        private AzureBlobServer blobServer = null;

        public AzureTable Topics { get; set; }
        public AzureTable Comments { get; set; }
        public AzureTable AuthorTopics { get; set; }
        public AzureTable AuthorComments { get; set; }
        public AzureBlobContainer Bodies { get; set; }

        public NestleDatabaseServer()
        {
            XDocument configuration = XDocument.Load("StorageConfiguration.xml");
            string account = configuration.Root.Element("account").Value;
            string key = configuration.Root.Element("key").Value;
            string container = configuration.Root.Element("container").Value;

            this.blobServer = AzureStorageFacade.ConnectBlobServer(AzureStorageFacade.CreateConnectionString(account, key));
            this.Bodies = this.blobServer["nestle-topic-comment-bodies"];
            this.Bodies.CreateContainerIfNotExist().Sync();
        }

        public NestleData Data
        {
            get
            {
                if (this.Bodies.GetBlob("rawData").DoesBlobExist().Sync())
                {
                    return new NestleData(XElement.Parse(this.Bodies.GetBlob("rawData").AsString));
                }
                else
                {
                    return null;
                }
            }
            set
            {
                this.Bodies.GetBlob("rawData").AsString = value.ToXml().ToString();
                this.UpdateDateTime = DateTime.Now;
            }
        }

        public DateTime UpdateDateTime
        {
            get
            {
                var blob = this.Bodies.GetBlob("rawDateUpdateDateTime");
                if (blob.DoesBlobExist().Sync())
                {
                    return DateTime.Parse(blob.AsString);
                }
                else
                {
                    return new DateTime(0);
                }
            }
            set
            {
                this.Bodies.GetBlob("rawDateUpdateDateTime").AsString = value.ToString();
            }
        }
    }

    public class Topic
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Author { get; set; }
        public string Body { get; set; }
        public DateTime CreateDateTime { get; set; }

        public Topic(XElement xml)
        {
            this.Id = int.Parse(xml.Element("id").Value);
            this.Title = xml.Element("title").Value;
            this.Description = xml.Element("desc").Value;
            this.Author = xml.Element("author").Value;
            this.Body = xml.Element("body").Value;
            this.CreateDateTime = DateTime.Parse(xml.Element("created").Value);
        }

        public XElement ToXml()
        {
            return new XElement("topic",
                new XElement("id", this.Id),
                new XElement("title", this.Title),
                new XElement("desc", this.Description),
                new XElement("author", this.Author),
                new XElement("body", this.Body),
                new XElement("created", this.CreateDateTime)
                );
        }
    }

    public class Comment
    {
        public int TopicId { get; set; }
        public int Id { get; set; }
        public string Author { get; set; }
        public string Body { get; set; }
        public string BodyMD5 { get; set; }
        public DateTime CreateDateTime { get; set; }

        public Comment(XElement xml, Topic topic)
        {
            if (topic == null)
            {
                this.Id = int.Parse(xml.Element("topic").Value);
            }
            else
            {
                this.TopicId = topic.Id;
            }
            this.Id = int.Parse(xml.Element("id").Value);
            this.Author = xml.Element("author").Value;
            this.Body = xml.Element("body").Value;
            this.CreateDateTime = DateTime.Parse(xml.Element("created").Value);
        }

        public XElement ToXml()
        {
            return new XElement("comment",
                new XElement("topic", this.TopicId),
                new XElement("id", this.Id),
                new XElement("author", this.Author),
                new XElement("body", this.Body),
                new XElement("created", this.CreateDateTime)
                );
        }
    }

    public class AuthorWork
    {
        public int id { get; set; }
        public string Author;

        public AuthorWork(XElement xml)
        {
            if (xml != null)
            {
                this.id = int.Parse(xml.Element("id").Value);
                this.Author = xml.Element("author").Value;
            }
        }

        public XElement ToXml()
        {
            return new XElement("authorWork",
                new XElement("author", this.Author),
                new XElement("id", this.id)
                );
        }
    }

    public class NestleData
    {
        public Dictionary<int, Topic> Topics { get; set; }
        public Dictionary<int, Comment> Comments { get; set; }
        public AuthorWork[] AuthorTopics { get; set; }
        public AuthorWork[] AuthorComments { get; set; }

        public NestleData(XElement xml)
        {
            if (xml != null)
            {
                this.Topics = xml.Element("topics").Elements("topic").Select(x => new Topic(x)).ToDictionary(x => x.Id, x => x);
                this.Comments = xml.Element("comments").Elements("comment").Select(x => new Comment(x, null)).ToDictionary(x => x.Id, x => x);
                this.AuthorTopics = xml.Element("authorTopics").Elements("authorTopic").Select(x => new AuthorWork(x)).ToArray();
                this.AuthorComments = xml.Element("authorComments").Elements("authorComment").Select(x => new AuthorWork(x)).ToArray();
            }
        }

        public XElement ToXml()
        {
            return new XElement("nestleData",
                new XElement("topics", this.Topics.Values.Select(t => t.ToXml()).ToArray()),
                new XElement("comments", this.Comments.Values.Select(c => c.ToXml()).ToArray()),
                new XElement("authorTopics", this.AuthorTopics.Select(a => a.ToXml()).ToArray()),
                new XElement("authorComments", this.AuthorComments.Select(a => a.ToXml()).ToArray())
                );
        }
    }
}
