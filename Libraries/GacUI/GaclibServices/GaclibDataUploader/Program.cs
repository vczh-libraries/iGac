using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using Microsoft.WindowsAzure;
using Microsoft.WindowsAzure.StorageClient;
using System.Windows.Forms;
using System.Threading;

namespace GaclibDataUploader
{
    class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            string metaDocFolder = @"..\..\..\..\Public\Temp\StaticMetaDoc";
            string[] files = Directory.GetFiles(metaDocFolder).OrderBy(s => s.ToUpper()).Select(p => Path.GetFullPath(p)).ToArray();

            string connectinString = Clipboard.GetText();
            Console.WriteLine("Your key is: " + connectinString);
            Console.Write("Press enter to continue:");
            Console.ReadLine();

            var account = CloudStorageAccount.Parse(connectinString);
            var blobClient = new CloudBlobClient(account.BlobEndpoint.AbsoluteUri, account.Credentials);

            Console.WriteLine("Clearning container...");
            var container = blobClient.GetContainerReference("gaclib-meta-doc");
            try
            {
                container.Delete();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }

            Console.WriteLine("Creating container...");
            while (true)
            {
                try
                {
                    container = blobClient.GetContainerReference("gaclib-meta-doc");
                    container.CreateIfNotExist();
                    break;
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                    Thread.Sleep(1000);
                }
            }

            Console.WriteLine("Uploading files...");
            int index = 0;
            foreach (var file in files)
            {
                string blobKey = Path.GetFileNameWithoutExtension(file);
                var blobRef = container.GetBlobReference(blobKey);
                blobRef.UploadFile(file);
                Console.WriteLine("{0}/{1}", ++index, files.Length);
            }

            Console.WriteLine("Checking files...");
            string[] urls = container.ListBlobs().Select(b => b.Uri.ToString()).ToArray();

            Console.WriteLine("Writing data...");
            Console.WriteLine("Done!");
        }
    }
}
