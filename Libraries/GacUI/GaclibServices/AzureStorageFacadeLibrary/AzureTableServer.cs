using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.WindowsAzure;
using Microsoft.WindowsAzure.StorageClient;
using System.Data.Services.Client;

namespace AzureStorageFacadeLibrary
{
    public class AzureTableServer
    {
        public CloudTableClient RawQueueClient { get; private set; }
        public TableServiceContext RawContext { get; private set; }

        protected internal AzureTableServer(CloudStorageAccount account)
        {
            this.RawQueueClient = new CloudTableClient(account.TableEndpoint.AbsoluteUri, account.Credentials);
            this.RawContext = this.RawQueueClient.GetDataServiceContext();
        }

        public IEnumerable<AzureTable> Tables
        {
            get
            {
                return this.RawQueueClient.ListTables().Select(n => new AzureTable(this, n));
            }
        }

        public AzureTable this[string name]
        {
            get
            {
                return new AzureTable(this, name);
            }
        }

        public AzureLazy<DataServiceResponse> SaveChanges()
        {
            return new AzureLazy<DataServiceResponse>(
                this.RawContext.SaveChanges,
                this.RawContext.BeginSaveChanges,
                this.RawContext.EndSaveChanges
                );
        }
    }

    public class AzureTable
    {
        public AzureTableServer Server { get; private set; }
        public string Name { get; private set; }

        internal AzureTable(AzureTableServer server, string name)
        {
            this.Server = server;
            this.Name = name;
        }

        public AzureLazy CreateTable()
        {
            return new AzureLazy(
                () => this.Server.RawQueueClient.CreateTable(this.Name),
                (ac, st) => this.Server.RawQueueClient.BeginCreateTable(this.Name, ac, st),
                this.Server.RawQueueClient.EndCreateTable
                );
        }

        public AzureLazy<bool> CreateTableIfNotExist()
        {
            return new AzureLazy<bool>(
                () => this.Server.RawQueueClient.CreateTableIfNotExist(this.Name),
                (ac, st) => this.Server.RawQueueClient.BeginCreateTableIfNotExist(this.Name, ac, st),
                this.Server.RawQueueClient.EndCreateTableIfNotExist
                );
        }

        public AzureLazy DeleteTable()
        {
            return new AzureLazy(
                () => this.Server.RawQueueClient.DeleteTable(this.Name),
                (ac, st) => this.Server.RawQueueClient.BeginDeleteTable(this.Name, ac, st),
                this.Server.RawQueueClient.EndDeleteTable
                );
        }

        public AzureLazy<bool> DeleteTableIfExist()
        {
            return new AzureLazy<bool>(
                () => this.Server.RawQueueClient.DeleteTableIfExist(this.Name),
                (ac, st) => this.Server.RawQueueClient.BeginDeleteTableIfExist(this.Name, ac, st),
                this.Server.RawQueueClient.EndDeleteTableIfExist
                );
        }

        public AzureLazy<bool> DoesTableExist()
        {
            return new AzureLazy<bool>(
                () => this.Server.RawQueueClient.DoesTableExist(this.Name),
                (ac, st) => this.Server.RawQueueClient.BeginDoesTableExist(this.Name, ac, st),
                this.Server.RawQueueClient.EndDoesTableExist
                );
        }

        public void AddEntity(TableServiceEntity entity)
        {
            this.Server.RawContext.AddObject(this.Name, entity);
        }

        public void DeleteEntity(TableServiceEntity entity)
        {
            this.Server.RawContext.DeleteObject(entity);
        }

        public void UpdateEntity(TableServiceEntity entity)
        {
            this.Server.RawContext.UpdateObject(entity);
        }

        public DataServiceQuery<T> Query<T>()
            where T : TableServiceEntity
        {
            return this.Server.RawContext.CreateQuery<T>(this.Name);
        }

        public AzureLazy<IEnumerable<U>> Query<T, U>(Func<DataServiceQuery<T>, DataServiceQuery<U>> query)
            where T : TableServiceEntity
            where U : TableServiceEntity
        {
            var result = query(Query<T>());
            return new AzureLazy<IEnumerable<U>>(
                result.Execute,
                result.BeginExecute,
                result.EndExecute
                );
        }
    }
}
