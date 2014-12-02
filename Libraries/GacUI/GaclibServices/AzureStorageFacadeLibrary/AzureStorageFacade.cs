using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.WindowsAzure;

namespace AzureStorageFacadeLibrary
{
    public static class AzureStorageFacade
    {
        public const string DevelopmentStorageConnectionString = "UseDevelopmentStorage=true";
        public const string ProductionStorageConnectionString = "DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1}";

        public static string CreateConnectionString(string account, string key)
        {
            return string.Format(ProductionStorageConnectionString, account, key);
        }

        public static AzureQueueServer ConnectQueueServer(string connectionString)
        {
            return new AzureQueueServer(CloudStorageAccount.Parse(connectionString));
        }

        public static AzureBlobServer ConnectBlobServer(string connectionString)
        {
            return new AzureBlobServer(CloudStorageAccount.Parse(connectionString));
        }

        public static AzureTableServer ConnectTableServer(string connectionString)
        {
            return new AzureTableServer(CloudStorageAccount.Parse(connectionString));
        }
    }
}
