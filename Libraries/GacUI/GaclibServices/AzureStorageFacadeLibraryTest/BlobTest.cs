using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using AzureStorageFacadeLibrary;

namespace AzureStorageFacadeLibraryTest
{
    // wad-control-container

    [TestClass]
    public class BlobTest
    {
        private AzureBlobServer blobServer = null;

        [TestInitialize]
        public void PrepareBlob()
        {
            this.blobServer = AzureStorageFacade.ConnectBlobServer(AzureStorageFacade.DevelopmentStorageConnectionString);
            foreach (var blobContainer in this.blobServer.Containers)
            {
                blobContainer.DeleteContainer().Sync();
            }
        }

        [TestMethod]
        public void TestCreateDeleteContainer()
        {
            Assert.AreEqual(0, this.blobServer.Containers.Count());
            for (int i = 0; i < 10; i++)
            {
                this.blobServer["container-" + i.ToString()].CreateContainer().Sync();
            }

            var blobContainers = this.blobServer.Containers.ToArray();
            Assert.AreEqual(10, blobContainers.Length);
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual("container-" + i.ToString(), blobContainers[i].Name);
            }

            for (int i = 0; i < 5; i++)
            {
                this.blobServer["container-" + i.ToString()].DeleteContainer().Sync();
            }
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual(i >= 5, this.blobServer["container-" + i.ToString()].DoesContainerExist().Sync());
            }
            for (int i = 0; i < 10; i++)
            {
                Assert.AreEqual(i < 5, this.blobServer["container-" + i.ToString()].CreateContainerIfNotExist().Sync());
            }
        }

        [TestMethod]
        public void TestUploadText()
        {
            var container = this.blobServer["azure-storage-facade-library-test"];
            Assert.IsFalse(container.DoesContainerExist().Sync());
            container.CreateContainer().Sync();
            Assert.IsTrue(container.DoesContainerExist().Sync());

            Assert.AreEqual(0, container.Directories.Count());
            Assert.AreEqual(0, container.Blobs.Count());
            Assert.AreEqual(0, container.FlatBlobs.Count());

            var blob = container.GetBlob("vczh");
            Assert.IsFalse(blob.DoesBlobExist().Sync());
            blob.AsString = "genius";
            Assert.IsTrue(blob.DoesBlobExist().Sync());
            Assert.AreEqual("genius", blob.AsString);

            Assert.AreEqual(0, container.Directories.Count());
            Assert.AreEqual(1, container.Blobs.Count());
            Assert.AreEqual(1, container.FlatBlobs.Count());
            Assert.AreEqual("vczh", container.Blobs.First().Name);
            Assert.AreEqual("vczh", container.FlatBlobs.First().Name);

            blob.Delete().Sync();
            Assert.IsFalse(blob.DeleteIfExists().Sync());

            Assert.AreEqual(0, container.Directories.Count());
            Assert.AreEqual(0, container.Blobs.Count());
            Assert.AreEqual(0, container.FlatBlobs.Count());
        }

        [TestMethod]
        public void TestDirectory()
        {
            var container = this.blobServer["azure-storage-facade-library-test"];
            Assert.IsFalse(container.DoesContainerExist().Sync());
            container.CreateContainer().Sync();
            Assert.IsTrue(container.DoesContainerExist().Sync());

            Assert.AreEqual(0, container.Directories.Count());
            Assert.AreEqual(0, container.Blobs.Count());
            Assert.AreEqual(0, container.FlatBlobs.Count());

            container.GetBlob("vczh").AsString = "genius";
            container.GetDirectory("DirectoryA").GetBlob("FileA").AsString = "geniusAA";
            container.GetDirectory("DirectoryA").GetBlob("FileB").AsString = "geniusAB";
            container.GetDirectory("DirectoryB").GetBlob("FileA").AsString = "geniusBA";
            container.GetDirectory("DirectoryB").GetBlob("FileB").AsString = "geniusBB";

            {
                var directories = container.Directories.ToArray();
                var blobs = container.Blobs.ToArray();
                var flatBlobs = container.FlatBlobs.ToArray();

                Assert.AreEqual(2, directories.Length);
                Assert.AreEqual("DirectoryA", directories[0].Name);
                {
                    var directoriesA = directories[0].Directories.ToArray();
                    var blobsA = directories[0].Blobs.ToArray();
                    var flatBlobsA = directories[0].FlatBlobs.ToArray();

                    Assert.AreEqual(0, directoriesA.Length);
                    Assert.AreEqual(2, blobsA.Length);
                    Assert.AreEqual("FileA", blobsA[0].Name);
                    Assert.AreEqual("geniusAA", blobsA[0].AsString);
                    Assert.AreEqual("FileB", blobsA[1].Name);
                    Assert.AreEqual("geniusAB", blobsA[1].AsString);
                    Assert.AreEqual(2, flatBlobsA.Length);
                    Assert.AreEqual("FileA", flatBlobsA[0].Name);
                    Assert.AreEqual("geniusAA", flatBlobsA[0].AsString);
                    Assert.AreEqual("FileB", flatBlobsA[1].Name);
                    Assert.AreEqual("geniusAB", flatBlobsA[1].AsString);
                }
                Assert.AreEqual("DirectoryB", directories[1].Name);
                {
                    var directoriesB = directories[1].Directories.ToArray();
                    var blobsB = directories[1].Blobs.ToArray();
                    var flatBlobsB = directories[1].FlatBlobs.ToArray();

                    Assert.AreEqual(0, directoriesB.Length);
                    Assert.AreEqual(2, blobsB.Length);
                    Assert.AreEqual("FileA", blobsB[0].Name);
                    Assert.AreEqual("geniusBA", blobsB[0].AsString);
                    Assert.AreEqual("FileB", blobsB[1].Name);
                    Assert.AreEqual("geniusBB", blobsB[1].AsString);
                    Assert.AreEqual(2, flatBlobsB.Length);
                    Assert.AreEqual("FileA", flatBlobsB[0].Name);
                    Assert.AreEqual("geniusBA", flatBlobsB[0].AsString);
                    Assert.AreEqual("FileB", flatBlobsB[1].Name);
                    Assert.AreEqual("geniusBB", flatBlobsB[1].AsString);
                }
                Assert.AreEqual(1, blobs.Length);
                Assert.AreEqual("vczh", blobs[0].Name);
                Assert.AreEqual("genius", blobs[0].AsString);
                Assert.AreEqual(5, flatBlobs.Length);
                Assert.AreEqual("DirectoryA/FileA", flatBlobs[0].Name);
                Assert.AreEqual("geniusAA", flatBlobs[0].AsString);
                Assert.AreEqual("DirectoryA/FileB", flatBlobs[1].Name);
                Assert.AreEqual("geniusAB", flatBlobs[1].AsString);
                Assert.AreEqual("DirectoryB/FileA", flatBlobs[2].Name);
                Assert.AreEqual("geniusBA", flatBlobs[2].AsString);
                Assert.AreEqual("DirectoryB/FileB", flatBlobs[3].Name);
                Assert.AreEqual("geniusBB", flatBlobs[3].AsString);
                Assert.AreEqual("vczh", flatBlobs[4].Name);
                Assert.AreEqual("genius", flatBlobs[4].AsString);
            }

            container.GetBlob("vczh").Delete().Sync();
            container.GetDirectory("DirectoryA").GetBlob("FileA").Delete().Sync();
            container.GetDirectory("DirectoryA").GetBlob("FileB").Delete().Sync();
            {
                var directories = container.Directories.ToArray();
                var blobs = container.Blobs.ToArray();
                var flatBlobs = container.FlatBlobs.ToArray();

                Assert.AreEqual(1, directories.Length);
                Assert.AreEqual("DirectoryB", directories[0].Name);
                {
                    var directoriesB = directories[0].Directories.ToArray();
                    var blobsB = directories[0].Blobs.ToArray();
                    var flatBlobsB = directories[0].FlatBlobs.ToArray();

                    Assert.AreEqual(0, directoriesB.Length);
                    Assert.AreEqual(2, blobsB.Length);
                    Assert.AreEqual("FileA", blobsB[0].Name);
                    Assert.AreEqual("geniusBA", blobsB[0].AsString);
                    Assert.AreEqual("FileB", blobsB[1].Name);
                    Assert.AreEqual("geniusBB", blobsB[1].AsString);
                    Assert.AreEqual(2, flatBlobsB.Length);
                    Assert.AreEqual("FileA", flatBlobsB[0].Name);
                    Assert.AreEqual("geniusBA", flatBlobsB[0].AsString);
                    Assert.AreEqual("FileB", flatBlobsB[1].Name);
                    Assert.AreEqual("geniusBB", flatBlobsB[1].AsString);
                }
                Assert.AreEqual(0, blobs.Length);
                Assert.AreEqual(2, flatBlobs.Length);
                Assert.AreEqual("DirectoryB/FileA", flatBlobs[0].Name);
                Assert.AreEqual("geniusBA", flatBlobs[0].AsString);
                Assert.AreEqual("DirectoryB/FileB", flatBlobs[1].Name);
                Assert.AreEqual("geniusBB", flatBlobs[1].AsString);
            }
        }
    }
}
