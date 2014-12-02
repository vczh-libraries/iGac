using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.WindowsAzure;
using Microsoft.WindowsAzure.StorageClient;
using System.IO;

namespace AzureStorageFacadeLibrary
{
    public class AzureBlobServer
    {
        public CloudBlobClient RawContainerClient { get; private set; }

        protected internal AzureBlobServer(CloudStorageAccount account)
        {
            this.RawContainerClient = new CloudBlobClient(account.BlobEndpoint.AbsoluteUri, account.Credentials);
        }

        public IEnumerable<AzureBlobContainer> Containers
        {
            get
            {
                return this.RawContainerClient.ListContainers().Select(c => new AzureBlobContainer(this, c));
            }
        }

        public AzureBlobContainer this[string name]
        {
            get
            {
                return new AzureBlobContainer(this, this.RawContainerClient.GetContainerReference(name));
            }
        }
    }

    public abstract class AzureBlobDirectoryBase
    {
        public abstract Uri Uri { get; }
        public abstract string Name { get; }
        public abstract IEnumerable<AzureBlobDirectory> Directories { get; }
        public abstract IEnumerable<AzureBlob> Blobs { get; }
        public abstract IEnumerable<AzureBlob> FlatBlobs { get; }
        public abstract AzureBlobDirectory GetDirectory(string name);
        public abstract AzureBlob GetBlob(string name);
    }

    public class AzureBlobContainer : AzureBlobDirectoryBase
    {
        public AzureBlobServer Server { get; private set; }
        public CloudBlobContainer RawContainer { get; private set; }

        internal AzureBlobContainer(AzureBlobServer server, CloudBlobContainer rawContainer)
        {
            this.Server = server;
            this.RawContainer = rawContainer;
        }

        public AzureLazy CreateContainer()
        {
            return new AzureLazy(this.RawContainer.Create, this.RawContainer.BeginCreate, this.RawContainer.EndCreate);
        }

        public AzureLazy<bool> CreateContainerIfNotExist()
        {
            return new AzureLazy<bool>(this.RawContainer.CreateIfNotExist, this.RawContainer.BeginCreateIfNotExist, this.RawContainer.EndCreateIfNotExist);
        }

        public AzureLazy DeleteContainer()
        {
            return new AzureLazy(this.RawContainer.Delete, this.RawContainer.BeginDelete, this.RawContainer.EndDelete);
        }

        public AzureLazy<bool> DoesContainerExist()
        {
            return new AzureLazy<bool>(
                () =>
                {
                    try
                    {
                        this.RawContainer.FetchAttributes();
                        return true;
                    }
                    catch (StorageClientException e)
                    {
                        if (e.ErrorCode == StorageErrorCode.ResourceNotFound)
                        {
                            return false;
                        }
                        else
                        {
                            throw;
                        }
                    }
                }
                );
        }

        public override string Name
        {
            get
            {
                return this.RawContainer.Name;
            }
        }

        public override Uri Uri
        {
            get
            {
                return this.RawContainer.Uri;
            }
        }

        public override IEnumerable<AzureBlobDirectory> Directories
        {
            get
            {
                return this.RawContainer
                    .ListBlobs(new BlobRequestOptions() { UseFlatBlobListing = false })
                    .Select(i => i as CloudBlobDirectory)
                    .Where(d => d != null)
                    .Select(d => new AzureBlobDirectory(this, null, d));
            }
        }

        public override IEnumerable<AzureBlob> Blobs
        {
            get
            {
                return this.RawContainer
                    .ListBlobs(new BlobRequestOptions() { UseFlatBlobListing = false })
                    .Select(i => i as CloudBlob)
                    .Where(b => b != null)
                    .Select(b => new AzureBlob(this, null, b));
            }
        }

        public override IEnumerable<AzureBlob> FlatBlobs
        {
            get
            {
                return this.RawContainer
                    .ListBlobs(new BlobRequestOptions() { UseFlatBlobListing = true })
                    .Select(i => i as CloudBlob)
                    .Where(b => b != null)
                    .Select(b => new AzureBlob(this, null, b));
            }
        }

        public override AzureBlobDirectory GetDirectory(string name)
        {
            return new AzureBlobDirectory(this, null, this.RawContainer.GetDirectoryReference(name));
        }

        public override AzureBlob GetBlob(string name)
        {
            return new AzureBlob(this, null, this.RawContainer.GetBlobReference(name));
        }
    }

    public class AzureBlobDirectory : AzureBlobDirectoryBase
    {
        public AzureBlobContainer Container { get; private set; }
        public AzureBlobDirectory Directory { get; private set; }
        public CloudBlobDirectory RawDirectory { get; private set; }

        internal AzureBlobDirectory(AzureBlobContainer container, AzureBlobDirectory directory, CloudBlobDirectory rawDirectory)
        {
            this.Container = container;
            this.Directory = directory;
            this.RawDirectory = rawDirectory;
        }

        public override Uri Uri
        {
            get
            {
                return this.RawDirectory.Uri;
            }
        }

        public override string Name
        {
            get
            {
                string name = "";
                if (this.Directory != null)
                {
                    name = this.RawDirectory.Uri.ToString().Substring(this.Directory.Uri.ToString().Length);
                }
                else
                {
                    name = this.RawDirectory.Uri.ToString().Substring(this.Container.Uri.ToString().Length + 1);
                }
                return name.Substring(0, name.Length - this.Container.Server.RawContainerClient.DefaultDelimiter.Length);
            }
        }

        public override IEnumerable<AzureBlobDirectory> Directories
        {
            get
            {
                return this.RawDirectory
                    .ListBlobs(new BlobRequestOptions() { UseFlatBlobListing = false })
                    .Select(i => i as CloudBlobDirectory)
                    .Where(d => d != null)
                    .Select(d => new AzureBlobDirectory(this.Container, this, d));
            }
        }

        public override IEnumerable<AzureBlob> Blobs
        {
            get
            {
                return this.RawDirectory
                    .ListBlobs(new BlobRequestOptions() { UseFlatBlobListing = false })
                    .Select(i => i as CloudBlob)
                    .Where(b => b != null)
                    .Select(b => new AzureBlob(this.Container, this, b));
            }
        }

        public override IEnumerable<AzureBlob> FlatBlobs
        {
            get
            {
                return this.RawDirectory
                    .ListBlobs(new BlobRequestOptions() { UseFlatBlobListing = true })
                    .Select(i => i as CloudBlob)
                    .Where(b => b != null)
                    .Select(b => new AzureBlob(this.Container, this, b));
            }
        }

        public override AzureBlobDirectory GetDirectory(string name)
        {
            return new AzureBlobDirectory(this.Container, this, this.RawDirectory.GetSubdirectory(name));
        }

        public override AzureBlob GetBlob(string name)
        {
            return new AzureBlob(this.Container, this, this.RawDirectory.GetBlobReference(name));
        }
    }

    public class AzureBlob
    {
        public AzureBlobContainer Container { get; private set; }
        public AzureBlobDirectory Directory { get; private set; }
        public CloudBlob RawBlob { get; private set; }

        internal AzureBlob(AzureBlobContainer container, AzureBlobDirectory directory, CloudBlob rawBlob)
        {
            this.Container = container;
            this.Directory = directory;
            this.RawBlob = rawBlob;
        }

        public string Name
        {
            get
            {
                if (this.Directory != null)
                {
                    return this.RawBlob.Uri.ToString().Substring(this.Directory.Uri.ToString().Length);
                }
                else
                {
                    return this.RawBlob.Uri.ToString().Substring(this.Container.Uri.ToString().Length + 1);
                }
            }
        }

        public AzureLazy<bool> DoesBlobExist()
        {
            return new AzureLazy<bool>(
                () =>
                {
                    try
                    {
                        this.RawBlob.FetchAttributes();
                        return true;
                    }
                    catch (StorageClientException e)
                    {
                        if (e.ErrorCode == StorageErrorCode.ResourceNotFound)
                        {
                            return false;
                        }
                        else
                        {
                            throw;
                        }
                    }
                }
                );
        }

        public byte[] AsBytes
        {
            get
            {
                return this.RawBlob.DownloadByteArray();
            }
            set
            {
                this.RawBlob.UploadByteArray(value);
            }
        }

        public string AsString
        {
            get
            {
                return this.RawBlob.DownloadText();
            }
            set
            {
                this.RawBlob.UploadText(value);
            }
        }

        public AzureLazy CopyFromBlob(AzureBlob source)
        {
            return new AzureLazy(
                () => this.RawBlob.CopyFromBlob(source.RawBlob),
                (ac, st) => this.RawBlob.BeginCopyFromBlob(source.RawBlob, ac, st),
                this.RawBlob.EndCopyFromBlob
                );
        }

        public AzureLazy<AzureBlob> CreateSnapshot()
        {
            return new AzureLazy<AzureBlob>(
                () => new AzureBlob(this.Container, this.Directory, this.RawBlob.CreateSnapshot()),
                this.RawBlob.BeginCreateSnapshot,
                ar => new AzureBlob(this.Container, this.Directory, this.RawBlob.EndCreateSnapshot(ar))
                );
        }

        public AzureLazy Delete()
        {
            return new AzureLazy(this.RawBlob.Delete, this.RawBlob.BeginDelete, this.RawBlob.EndDelete);
        }

        public AzureLazy<bool> DeleteIfExists()
        {
            return new AzureLazy<bool>(this.RawBlob.DeleteIfExists, this.RawBlob.BeginDeleteIfExists, this.RawBlob.EndDeleteIfExists);
        }

        public AzureLazy DownloadToStream(Stream target)
        {
            return new AzureLazy(
                () => this.RawBlob.DownloadToStream(target),
                (ac, st) => this.RawBlob.BeginDownloadToStream(target, ac, st),
                this.RawBlob.EndDownloadToStream
                );
        }

        public AzureLazy UploadFromStream(Stream source)
        {
            return new AzureLazy(
                () => this.RawBlob.DownloadToStream(source),
                (ac, st) => this.RawBlob.BeginDownloadToStream(source, ac, st),
                this.RawBlob.EndDownloadToStream
                );
        }

        public AzureLazy DownloadToFile(string fileName)
        {
            return new AzureLazy(
                () => this.RawBlob.DownloadToFile(fileName)
                );
        }

        public AzureLazy UploadFromFile(string fileName)
        {
            return new AzureLazy(
                () => this.RawBlob.UploadFile(fileName)
                );
        }

        public BlobStream OpenRead()
        {
            return this.RawBlob.OpenRead();
        }

        public BlobStream OpenWrite()
        {
            return this.RawBlob.OpenWrite();
        }
    }
}
