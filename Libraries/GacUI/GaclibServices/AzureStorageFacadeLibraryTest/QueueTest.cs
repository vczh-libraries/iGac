using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using AzureStorageFacadeLibrary;
using System.Threading;

namespace AzureStorageFacadeLibraryTest
{
    [TestClass]
    public class QueueTest
    {
        private AzureQueueServer queueServer = null;

        [TestInitialize]
        public void PrepareQueue()
        {
            this.queueServer = AzureStorageFacade.ConnectQueueServer(AzureStorageFacade.DevelopmentStorageConnectionString);
            foreach (var queue in this.queueServer.Queues)
            {
                queue.DeleteQueue().Sync();
            }
        }

        [TestMethod]
        public void TestCreateDeleteQueue()
        {
            Assert.AreEqual(0, this.queueServer.Queues.Count());
            for (int i = 0; i < 10; i++)
            {
                this.queueServer["queue-" + i.ToString()].CreateQueue().Sync();
            }

            var queues = this.queueServer.Queues.ToArray();
            Assert.AreEqual(10, queues.Length);
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual("queue-" + i.ToString(), queues[i].Name);
            }

            for (int i = 0; i < 5; i++)
            {
                this.queueServer["queue-" + i.ToString()].DeleteQueue().Sync();
            }
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual(i >= 5, this.queueServer["queue-" + i.ToString()].DoesQueueExist().Sync());
            }
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual(i < 5, this.queueServer["queue-" + i.ToString()].CreateQueueIfNotExist().Sync());
            }
        }

        [TestMethod]
        public void TestPushPeekPopSingleMessage()
        {
            var queue = this.queueServer["azure-storage-facade-library-test"];
            queue.CreateQueue().Sync();
            for (int i = 0; i < 10; i++)
            {
                queue.PushMessage("Message " + i.ToString()).Sync();
            }
            Assert.AreEqual("Message 0", queue.PeekMessage().Sync().AsString);
            Assert.AreEqual("Message 0", queue.PopMessage().Sync().AsString);
            Assert.AreEqual("Message 1", queue.PeekMessage().Sync().AsString);
            Assert.AreEqual("Message 1", queue.PopMessage().Sync().AsString);
            queue.ClearMessages().Sync();
            Assert.IsNull(queue.PeekMessage().Sync());
            Assert.IsNull(queue.PopMessage().Sync());
        }

        [TestMethod]
        public void TestPushPeekPopMultipleMessage()
        {
            var queue = this.queueServer["azure-storage-facade-library-test"];
            queue.CreateQueue().Sync();
            for (int i = 0; i < 10; i++)
            {
                queue.PushMessage("Message " + i.ToString()).Sync();
            }
            {
                var messages = queue.PeekMessages(10).Sync().ToArray();
                Assert.AreEqual(10, messages.Length);
                for (int i = 0; i < 10; i++)
                {
                    Assert.AreEqual("Message " + i.ToString(), messages[i].AsString);
                }
            }
            {
                var messages = queue.PopMessages(10).Sync().ToArray();
                Assert.AreEqual(10, messages.Length);
                for (int i = 0; i < 10; i++)
                {
                    Assert.AreEqual("Message " + i.ToString(), messages[i].AsString);
                }
            }
            {
                var messages = queue.PeekMessages(10).Sync().ToArray();
                Assert.AreEqual(0, messages.Length);
            }
            {
                var messages = queue.PopMessages(10).Sync().ToArray();
                Assert.AreEqual(0, messages.Length);
            }
        }

        [TestMethod]
        public void TestUpdateDeleteMessage()
        {
            var queue = this.queueServer["azure-storage-facade-library-test"];
            queue.CreateQueue().Sync();
            for (int i = 0; i < 10; i++)
            {
                queue.PushMessage("Message " + i.ToString()).Sync();
            }
            {
                var messages = queue.PopMessages(10).Sync().ToArray();
                Assert.AreEqual(10, messages.Length);
                for (int i = 0; i < 10; i++)
                {
                    Assert.AreEqual("Message " + i.ToString(), messages[i].AsString);
                    messages[i].UpdateMessage(new TimeSpan(0), "New Message " + i.ToString()).Sync();
                }
            }
            {
                var messages = queue.PopMessages(10).Sync().ToArray();
                Assert.AreEqual(10, messages.Length);
                for (int i = 0; i < 10; i++)
                {
                    Assert.AreEqual("New Message " + i.ToString(), messages[i].AsString);
                    if (i < 5)
                    {
                        queue.DeleteMessage(messages[i]).Sync();
                    }
                    else
                    {
                        queue.DeleteMessage(messages[i].Id, messages[i].PopReceipt).Sync();
                    }
                }
            }
            {
                var messages = queue.PeekMessages(10).Sync().ToArray();
                Assert.AreEqual(0, messages.Length);
            }
        }
    }
}
