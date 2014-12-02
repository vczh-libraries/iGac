using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.WindowsAzure;
using Microsoft.WindowsAzure.StorageClient;

namespace AzureStorageFacadeLibrary
{
    public class AzureQueueServer
    {
        public CloudQueueClient RawQueueClient { get; private set; }

        internal AzureQueueServer(CloudStorageAccount account)
        {
            this.RawQueueClient = new CloudQueueClient(account.QueueEndpoint.AbsoluteUri, account.Credentials);
        }

        public IEnumerable<AzureQueue> Queues
        {
            get
            {
                return this.RawQueueClient.ListQueues().Select(q => new AzureQueue(this, q));
            }
        }

        public AzureQueue this[string name]
        {
            get
            {
                return new AzureQueue(this, this.RawQueueClient.GetQueueReference(name));
            }
        }
    }

    public class AzureQueue
    {
        public AzureQueueServer Server { get; private set; }
        public CloudQueue RawQueue { get; private set; }

        private AzureQueueMessage CreateMessage(CloudQueueMessage message)
        {
            return message == null ? null : new AzureQueueMessage(this, message);
        }

        internal AzureQueue(AzureQueueServer server, CloudQueue rawQueue)
        {
            this.Server = server;
            this.RawQueue = rawQueue;
        }

        public string Name
        {
            get
            {
                return this.RawQueue.Name;
            }
        }

        public Uri Uri
        {
            get
            {
                return this.RawQueue.Uri;
            }
        }

        public AzureLazy CreateQueue()
        {
            return new AzureLazy(this.RawQueue.Create, this.RawQueue.BeginCreate, this.RawQueue.EndCreate);
        }

        public AzureLazy<bool> CreateQueueIfNotExist()
        {
            return new AzureLazy<bool>(this.RawQueue.CreateIfNotExist, this.RawQueue.BeginCreateIfNotExist, this.RawQueue.EndCreateIfNotExist);
        }

        public AzureLazy DeleteQueue()
        {
            return new AzureLazy(this.RawQueue.Delete, this.RawQueue.BeginDelete, this.RawQueue.EndDelete);
        }

        public AzureLazy<bool> DoesQueueExist()
        {
            return new AzureLazy<bool>(this.RawQueue.Exists, this.RawQueue.BeginExists, this.RawQueue.EndExists);
        }

        public AzureLazy ClearMessages()
        {
            return new AzureLazy(this.RawQueue.Clear, this.RawQueue.BeginClear, this.RawQueue.EndClear);
        }

        public AzureLazy PushMessage(string message, TimeSpan? timeToLive = null, TimeSpan? initialVisibilityDelay = null)
        {
            return new AzureLazy(
                () => this.RawQueue.AddMessage(new CloudQueueMessage(message), timeToLive, initialVisibilityDelay),
                (ac, st) => this.RawQueue.BeginAddMessage(new CloudQueueMessage(message), timeToLive, initialVisibilityDelay, ac, st),
                this.RawQueue.EndAddMessage
                );
        }

        public AzureLazy PushMessage(byte[] message, TimeSpan? timeToLive = null, TimeSpan? initialVisibilityDelay = null)
        {
            return new AzureLazy(
                () => this.RawQueue.AddMessage(new CloudQueueMessage(message), timeToLive, initialVisibilityDelay),
                (ac, st) => this.RawQueue.BeginAddMessage(new CloudQueueMessage(message), timeToLive, initialVisibilityDelay, ac, st),
                this.RawQueue.EndAddMessage
                );
        }

        public AzureLazy<AzureQueueMessage> PopMessage()
        {
            return new AzureLazy<AzureQueueMessage>(
                () => CreateMessage(this.RawQueue.GetMessage()),
                this.RawQueue.BeginGetMessage,
                ar => CreateMessage(this.RawQueue.EndGetMessage(ar))
                );
        }

        public AzureLazy<IEnumerable<AzureQueueMessage>> PopMessages(int messageCount)
        {
            return new AzureLazy<IEnumerable<AzureQueueMessage>>(
                () => this.RawQueue.GetMessages(messageCount).Select(m => CreateMessage(m)),
                (ac, st) => this.RawQueue.BeginGetMessages(messageCount, ac, st),
                ar => this.RawQueue.EndGetMessages(ar).Select(m => CreateMessage(m))
                );
        }

        public AzureLazy<AzureQueueMessage> PeekMessage()
        {
            return new AzureLazy<AzureQueueMessage>(
                () => CreateMessage(this.RawQueue.PeekMessage()),
                this.RawQueue.BeginPeekMessage,
                ar => CreateMessage(this.RawQueue.EndPeekMessage(ar))
                );
        }

        public AzureLazy<IEnumerable<AzureQueueMessage>> PeekMessages(int messageCount)
        {
            return new AzureLazy<IEnumerable<AzureQueueMessage>>(
                () => this.RawQueue.PeekMessages(messageCount).Select(m => CreateMessage(m)),
                (ac, st) => this.RawQueue.BeginPeekMessages(messageCount, ac, st),
                ar => this.RawQueue.EndPeekMessages(ar).Select(m => CreateMessage(m))
                );
        }

        public AzureLazy DeleteMessage(AzureQueueMessage message)
        {
            return new AzureLazy(
                () => this.RawQueue.DeleteMessage(message.RawMessage),
                (ac, st) => this.RawQueue.BeginDeleteMessage(message.RawMessage, ac, st),
                ar => this.RawQueue.EndDeleteMessage(ar)
                );
        }

        public AzureLazy DeleteMessage(string messageId, string popReceipt)
        {
            return new AzureLazy(
                () => this.RawQueue.DeleteMessage(messageId, popReceipt),
                (ac, st) => this.RawQueue.BeginDeleteMessage(messageId, popReceipt, ac, st),
                ar => this.RawQueue.EndDeleteMessage(ar)
                );
        }
    }

    public class AzureQueueMessage
    {
        public AzureQueue Queue { get; private set; }
        public CloudQueueMessage RawMessage { get; private set; }

        internal AzureQueueMessage(AzureQueue queue, CloudQueueMessage message)
        {
            this.Queue = queue;
            this.RawMessage = message;
        }

        public byte[] AsBytes
        {
            get
            {
                return this.RawMessage.AsBytes;
            }
        }

        public string AsString
        {
            get
            {
                return this.RawMessage.AsString;
            }
        }

        public int DequeueCount
        {
            get
            {
                return this.RawMessage.DequeueCount;
            }
        }

        public DateTime? ExpirationTime
        {
            get
            {
                return this.RawMessage.ExpirationTime;
            }
        }

        public DateTime? InsertionTime
        {
            get
            {
                return this.RawMessage.InsertionTime;
            }
        }

        public DateTime? NextVisibleTime
        {
            get
            {
                return this.RawMessage.NextVisibleTime;
            }
        }

        public string Id
        {
            get
            {
                return this.RawMessage.Id;
            }
        }

        public string PopReceipt
        {
            get
            {
                return this.RawMessage.PopReceipt;
            }
        }

        public AzureLazy UpdateMessage(TimeSpan visibilityTimeout)
        {
            return new AzureLazy(
                () => this.Queue.RawQueue.UpdateMessage(this.RawMessage, visibilityTimeout, MessageUpdateFields.Visibility),
                (ac, st) => this.Queue.RawQueue.BeginUpdateMessage(this.RawMessage, visibilityTimeout, MessageUpdateFields.Visibility, ac, st),
                this.Queue.RawQueue.EndUpdateMessage
                );
        }

        public AzureLazy UpdateMessage(TimeSpan visibilityTimeout, string message)
        {
            this.RawMessage.SetMessageContent(message);
            return new AzureLazy(
                () => this.Queue.RawQueue.UpdateMessage(this.RawMessage, visibilityTimeout, MessageUpdateFields.Visibility | MessageUpdateFields.Content),
                (ac, st) => this.Queue.RawQueue.BeginUpdateMessage(this.RawMessage, visibilityTimeout, MessageUpdateFields.Visibility, ac, st),
                this.Queue.RawQueue.EndUpdateMessage
                );
        }

        public AzureLazy UpdateMessage(TimeSpan visibilityTimeout, byte[] message)
        {
            this.RawMessage.SetMessageContent(message);
            return new AzureLazy(
                () => this.Queue.RawQueue.UpdateMessage(this.RawMessage, visibilityTimeout, MessageUpdateFields.Visibility | MessageUpdateFields.Content),
                (ac, st) => this.Queue.RawQueue.BeginUpdateMessage(this.RawMessage, visibilityTimeout, MessageUpdateFields.Visibility, ac, st),
                this.Queue.RawQueue.EndUpdateMessage
                );
        }
    }
}
