using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using AzureStorageFacadeLibrary;
using Microsoft.WindowsAzure.StorageClient;

namespace AzureStorageFacadeLibraryTest
{
    [TestClass]
    public class TableTest
    {
        private AzureTableServer tableServer = null;

        [TestInitialize]
        public void PrepareTable()
        {
            this.tableServer = AzureStorageFacade.ConnectTableServer(AzureStorageFacade.DevelopmentStorageConnectionString);
            foreach (var blobContainer in this.tableServer.Tables)
            {
                blobContainer.DeleteTable().Sync();
            }
        }

        [TestMethod]
        public void TestCreateDeleteTable()
        {
            Assert.AreEqual(0, this.tableServer.Tables.Count());
            for (int i = 0; i < 10; i++)
            {
                this.tableServer["Table" + i.ToString()].CreateTable().Sync();
            }

            var tables = this.tableServer.Tables.ToArray();
            Assert.AreEqual(10, tables.Length);
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual("Table" + i.ToString(), tables[i].Name);
            }

            for (int i = 0; i < 5; i++)
            {
                this.tableServer["Table" + i.ToString()].DeleteTable().Sync();
            }
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual(i >= 5, this.tableServer["Table" + i.ToString()].DoesTableExist().Sync());
            }
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual(i < 5, this.tableServer["Table" + i.ToString()].CreateTableIfNotExist().Sync());
            }

            for (int i = 0; i < 5; i++)
            {
                this.tableServer["Table" + i.ToString()].DeleteTable().Sync();
            }
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual(i >= 5, this.tableServer["Table" + i.ToString()].DeleteTableIfExist().Sync());
            }
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual(false, this.tableServer["Table" + i.ToString()].DoesTableExist().Sync());
            }
        }

        class TestEntity : TableServiceEntity
        {
            public int Number { get; set; }
            public int Square { get; set; }
        }

        [TestMethod]
        public void TestAddDeleteUpdateObject()
        {
            var table = this.tableServer["AzureStorageFacadeLibraryTest"];
            table.CreateTable().Sync();

            for (int i = 0; i < 10; i++)
            {
                table.AddEntity(new TestEntity()
                {
                    PartitionKey = "",
                    RowKey = Guid.NewGuid().ToString(),
                    Number = i,
                    Square = i * i,
                });
            }
            table.Server.SaveChanges().Sync();
            {
                var entities = table.Query<TestEntity>().Execute().OrderBy(e => e.Number).ToArray();
                Assert.AreEqual(10, entities.Length);
                for (int i = 0; i < 10; i++)
                {
                    Assert.AreEqual(i, entities[i].Number);
                    Assert.AreEqual(i * i, entities[i].Square);
                }
            }

            foreach (var entity in table.Query<TestEntity>())
            {
                entity.Square *= 2;
                table.UpdateEntity(entity);
            }
            table.Server.SaveChanges().Sync();
            {
                var entities = table.Query<TestEntity>().Execute().OrderBy(e => e.Number).ToArray();
                Assert.AreEqual(10, entities.Length);
                for (int i = 0; i < 10; i++)
                {
                    Assert.AreEqual(i, entities[i].Number);
                    Assert.AreEqual(i * i * 2, entities[i].Square);
                }
            }

            foreach (var entity in table.Query<TestEntity>().Where(t => t.Number >= 5))
            {
                table.DeleteEntity(entity);
            }
            table.Server.SaveChanges().Sync();
            {
                var entities = table.Query<TestEntity>().Execute().OrderBy(e => e.Number).ToArray();
                Assert.AreEqual(5, entities.Length);
                for (int i = 0; i < 5; i++)
                {
                    Assert.AreEqual(i, entities[i].Number);
                    Assert.AreEqual(i * i * 2, entities[i].Square);
                }
            }
        }
    }
}
