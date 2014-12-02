using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using DeployLibrary;

namespace DeployClient
{
    public partial class DeployClientForm : Form
    {
        private DeployDatabase deployDatabase;

        private void EnableControls()
        {
            this.Cursor = Cursors.Default;
            foreach (Control control in this.Controls)
            {
                control.Enabled = true;
            }
            timerUpdate.Enabled = true;
        }

        private void DisableControls()
        {
            this.Cursor = Cursors.WaitCursor;
            foreach (Control control in this.Controls)
            {
                control.Enabled = false;
            }
            timerUpdate.Enabled = false;
        }

        private void Async(Action action)
        {
            ThreadPool.QueueUserWorkItem(_ => action());
        }

        private void Sync(Action action)
        {
            this.Invoke(action);
        }

        private void AsyncUpdate(Action action, Action guiAction = null)
        {
            DisableControls();
            Async(() =>
            {
                try
                {
                    action();
                    Sync(() =>
                    {
                        EnableControls();
                        if (guiAction != null) guiAction();
                        UpdateData();
                    });
                }
                catch (Exception ex)
                {
                    Sync(() =>
                    {
                        EnableControls();
                        if (guiAction != null) guiAction();
                        MessageBox.Show(ex.Message, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    });
                }
            });
        }

        private void UpdateData()
        {
            labelServer.Text = string.Format("{0} (version = {1})", this.deployDatabase.ServerName, this.deployDatabase.ServiceMetadataVersion);
            labelLocalDirectory.Text = this.deployDatabase.LocalDirectory;

            listViewServerDirectory.Items.Clear();
            foreach (var blob in this.deployDatabase.ServiceFolder.FlatBlobs)
            {
                var item = new ListViewItem(blob.Name);
                listViewServerDirectory.Items.Add(item);
            }

            listViewDeployments.Items.Clear();
            foreach (var deployment in this.deployDatabase.Deployments)
            {
                var item = new ListViewItem(deployment.DeploymenName);
                item.SubItems.Add(deployment.Version);
                item.SubItems.Add(deployment.HeartBeats);
                item.SubItems.Add(deployment.Status.ToString());
                listViewDeployments.Items.Add(item);
            }
        }

        public DeployClientForm()
        {
            InitializeComponent();
            AsyncUpdate(() => this.deployDatabase = new DeployDatabase(true));
        }

        private void timerUpdate_Tick(object sender, EventArgs e)
        {
            UpdateData();
        }

        private void buttonOpenLocalDirectory_Click(object sender, EventArgs e)
        {
            Process.Start("explorer", "\"" + labelLocalDirectory.Text + "\"");
        }

        private void buttonUpdate_Click(object sender, EventArgs e)
        {
            AsyncUpdate(() => this.deployDatabase.Upload());
        }
    }
}
