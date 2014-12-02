using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Microsoft.WindowsAzure.StorageClient;
using Microsoft.WindowsAzure;

namespace GaclibDataViewer
{
    public partial class MainForm : Form
    {
        private CloudBlobClient currentBlobClient = null;

        public MainForm()
        {
            InitializeComponent();
            textBoxAccessKey.Text = Clipboard.GetText();
            listViewBlobs
                .GetType()
                .GetProperty("DoubleBuffered", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic)
                .SetValue(listViewBlobs, true, new object[] { });
        }

        private void buttonConnect_Click(object sender, EventArgs e)
        {
            var account = new CloudStorageAccount(new StorageCredentialsAccountAndKey(textBoxBlobName.Text, textBoxAccessKey.Text), true);
            var blobClient = new CloudBlobClient(account.BlobEndpoint.AbsoluteUri, account.Credentials);
            this.currentBlobClient = blobClient;
            var containers = blobClient.ListContainers().ToArray();

            comboBoxContainers.Items.Clear();
            comboBoxContainers.Items.AddRange(containers.Select(c => c.Name).ToArray());
            if (comboBoxContainers.Items.Count > 0)
            {
                comboBoxContainers.SelectedIndex = 0;
            }
        }

        private void comboBoxContainers_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (comboBoxContainers.SelectedIndex != -1 && this.currentBlobClient != null)
            {
                listViewBlobs.Items.Clear();
                var container = this.currentBlobClient.GetContainerReference(comboBoxContainers.Text);
                var blobs = container.ListBlobs().ToArray();

                List<ListViewItem> items = new List<ListViewItem>();
                foreach (var blob in blobs)
                {
                    var blobRef = container.GetBlobReference(blob.Uri.ToString());
                    ListViewItem item = new ListViewItem();
                    items.Add(item);

                    item.Text = blobRef.Name;
                    item.SubItems.Add(blobRef.Attributes.Properties.LastModifiedUtc.ToLocalTime().ToString());
                    item.SubItems.Add(blobRef.Attributes.Properties.BlobType.ToString());
                    item.Tag = blob.Uri.ToString();
                }
                listViewBlobs.Items.AddRange(items.ToArray());
            }
        }

        private void listViewBlobs_DoubleClick(object sender, EventArgs e)
        {
            if (listViewBlobs.SelectedIndices.Count == 1 && this.currentBlobClient != null)
            {
                var container = this.currentBlobClient.GetContainerReference(comboBoxContainers.Text);
                var blobRef = container.GetBlobReference(listViewBlobs.SelectedItems[0].Tag.ToString());
                string text = blobRef.DownloadText();

                using (var form = new ContentViewerForm())
                {
                    form.Content = text;
                    form.ShowDialog();
                }
            }
        }
    }
}
