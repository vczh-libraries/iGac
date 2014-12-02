namespace DeployClient
{
    partial class DeployClientForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.timerUpdate = new System.Windows.Forms.Timer(this.components);
            this.tableMain = new System.Windows.Forms.TableLayoutPanel();
            this.label1 = new System.Windows.Forms.Label();
            this.buttonUpdate = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.buttonOpenLocalDirectory = new System.Windows.Forms.Button();
            this.labelServer = new System.Windows.Forms.Label();
            this.labelLocalDirectory = new System.Windows.Forms.Label();
            this.listViewServerDirectory = new System.Windows.Forms.ListView();
            this.columnHeader1 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.listViewDeployments = new System.Windows.Forms.ListView();
            this.columnHeader2 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader3 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader5 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader4 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.tableMain.SuspendLayout();
            this.SuspendLayout();
            // 
            // timerUpdate
            // 
            this.timerUpdate.Interval = 5000;
            this.timerUpdate.Tick += new System.EventHandler(this.timerUpdate_Tick);
            // 
            // tableMain
            // 
            this.tableMain.ColumnCount = 3;
            this.tableMain.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tableMain.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableMain.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tableMain.Controls.Add(this.label1, 0, 0);
            this.tableMain.Controls.Add(this.buttonUpdate, 2, 0);
            this.tableMain.Controls.Add(this.label2, 0, 1);
            this.tableMain.Controls.Add(this.label3, 0, 2);
            this.tableMain.Controls.Add(this.label4, 0, 4);
            this.tableMain.Controls.Add(this.buttonOpenLocalDirectory, 2, 1);
            this.tableMain.Controls.Add(this.labelServer, 1, 0);
            this.tableMain.Controls.Add(this.labelLocalDirectory, 1, 1);
            this.tableMain.Controls.Add(this.listViewServerDirectory, 0, 3);
            this.tableMain.Controls.Add(this.listViewDeployments, 0, 5);
            this.tableMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableMain.Location = new System.Drawing.Point(0, 0);
            this.tableMain.Name = "tableMain";
            this.tableMain.RowCount = 6;
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableMain.Size = new System.Drawing.Size(801, 595);
            this.tableMain.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label1.Location = new System.Drawing.Point(8, 8);
            this.label1.Margin = new System.Windows.Forms.Padding(8);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(113, 12);
            this.label1.TabIndex = 0;
            this.label1.Text = "Server: ";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // buttonUpdate
            // 
            this.buttonUpdate.AutoSize = true;
            this.buttonUpdate.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.buttonUpdate.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonUpdate.Location = new System.Drawing.Point(621, 3);
            this.buttonUpdate.Name = "buttonUpdate";
            this.buttonUpdate.Size = new System.Drawing.Size(177, 22);
            this.buttonUpdate.TabIndex = 1;
            this.buttonUpdate.Text = "Update";
            this.buttonUpdate.UseVisualStyleBackColor = true;
            this.buttonUpdate.Click += new System.EventHandler(this.buttonUpdate_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label2.Location = new System.Drawing.Point(8, 36);
            this.label2.Margin = new System.Windows.Forms.Padding(8);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(113, 12);
            this.label2.TabIndex = 2;
            this.label2.Text = "Local Directory: ";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label3.Location = new System.Drawing.Point(8, 64);
            this.label3.Margin = new System.Windows.Forms.Padding(8);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(113, 12);
            this.label3.TabIndex = 3;
            this.label3.Text = "Server Directory: ";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label4.Location = new System.Drawing.Point(8, 333);
            this.label4.Margin = new System.Windows.Forms.Padding(8);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(113, 12);
            this.label4.TabIndex = 4;
            this.label4.Text = "Deployments: ";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // buttonOpenLocalDirectory
            // 
            this.buttonOpenLocalDirectory.AutoSize = true;
            this.buttonOpenLocalDirectory.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.buttonOpenLocalDirectory.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonOpenLocalDirectory.Location = new System.Drawing.Point(621, 31);
            this.buttonOpenLocalDirectory.Name = "buttonOpenLocalDirectory";
            this.buttonOpenLocalDirectory.Size = new System.Drawing.Size(177, 22);
            this.buttonOpenLocalDirectory.TabIndex = 5;
            this.buttonOpenLocalDirectory.Text = "Explore Local Directory ...";
            this.buttonOpenLocalDirectory.UseVisualStyleBackColor = true;
            this.buttonOpenLocalDirectory.Click += new System.EventHandler(this.buttonOpenLocalDirectory_Click);
            // 
            // labelServer
            // 
            this.labelServer.AutoSize = true;
            this.labelServer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.labelServer.Location = new System.Drawing.Point(137, 8);
            this.labelServer.Margin = new System.Windows.Forms.Padding(8);
            this.labelServer.Name = "labelServer";
            this.labelServer.Size = new System.Drawing.Size(473, 12);
            this.labelServer.TabIndex = 6;
            this.labelServer.Text = "<Server Name>";
            this.labelServer.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // labelLocalDirectory
            // 
            this.labelLocalDirectory.AutoSize = true;
            this.labelLocalDirectory.Dock = System.Windows.Forms.DockStyle.Fill;
            this.labelLocalDirectory.Location = new System.Drawing.Point(137, 36);
            this.labelLocalDirectory.Margin = new System.Windows.Forms.Padding(8);
            this.labelLocalDirectory.Name = "labelLocalDirectory";
            this.labelLocalDirectory.Size = new System.Drawing.Size(473, 12);
            this.labelLocalDirectory.TabIndex = 7;
            this.labelLocalDirectory.Text = "<Local Directory>";
            this.labelLocalDirectory.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // listViewServerDirectory
            // 
            this.listViewServerDirectory.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.columnHeader1});
            this.tableMain.SetColumnSpan(this.listViewServerDirectory, 3);
            this.listViewServerDirectory.Dock = System.Windows.Forms.DockStyle.Fill;
            this.listViewServerDirectory.FullRowSelect = true;
            this.listViewServerDirectory.GridLines = true;
            this.listViewServerDirectory.Location = new System.Drawing.Point(3, 87);
            this.listViewServerDirectory.Name = "listViewServerDirectory";
            this.listViewServerDirectory.Size = new System.Drawing.Size(795, 235);
            this.listViewServerDirectory.TabIndex = 8;
            this.listViewServerDirectory.UseCompatibleStateImageBehavior = false;
            this.listViewServerDirectory.View = System.Windows.Forms.View.Details;
            // 
            // columnHeader1
            // 
            this.columnHeader1.Text = "Path";
            this.columnHeader1.Width = 480;
            // 
            // listViewDeployments
            // 
            this.listViewDeployments.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.columnHeader2,
            this.columnHeader3,
            this.columnHeader5,
            this.columnHeader4});
            this.tableMain.SetColumnSpan(this.listViewDeployments, 3);
            this.listViewDeployments.Dock = System.Windows.Forms.DockStyle.Fill;
            this.listViewDeployments.FullRowSelect = true;
            this.listViewDeployments.GridLines = true;
            this.listViewDeployments.Location = new System.Drawing.Point(3, 356);
            this.listViewDeployments.Name = "listViewDeployments";
            this.listViewDeployments.Size = new System.Drawing.Size(795, 236);
            this.listViewDeployments.TabIndex = 9;
            this.listViewDeployments.UseCompatibleStateImageBehavior = false;
            this.listViewDeployments.View = System.Windows.Forms.View.Details;
            // 
            // columnHeader2
            // 
            this.columnHeader2.Text = "Name";
            this.columnHeader2.Width = 240;
            // 
            // columnHeader3
            // 
            this.columnHeader3.Text = "Version";
            this.columnHeader3.Width = 120;
            // 
            // columnHeader5
            // 
            this.columnHeader5.Text = "Heart Beats";
            this.columnHeader5.Width = 180;
            // 
            // columnHeader4
            // 
            this.columnHeader4.Text = "Status";
            this.columnHeader4.Width = 120;
            // 
            // DeployClientForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(801, 595);
            this.Controls.Add(this.tableMain);
            this.Name = "DeployClientForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Vczh Services Deployment Client";
            this.tableMain.ResumeLayout(false);
            this.tableMain.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Timer timerUpdate;
        private System.Windows.Forms.TableLayoutPanel tableMain;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button buttonUpdate;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Button buttonOpenLocalDirectory;
        private System.Windows.Forms.Label labelServer;
        private System.Windows.Forms.Label labelLocalDirectory;
        private System.Windows.Forms.ListView listViewServerDirectory;
        private System.Windows.Forms.ColumnHeader columnHeader1;
        private System.Windows.Forms.ListView listViewDeployments;
        private System.Windows.Forms.ColumnHeader columnHeader2;
        private System.Windows.Forms.ColumnHeader columnHeader3;
        private System.Windows.Forms.ColumnHeader columnHeader4;
        private System.Windows.Forms.ColumnHeader columnHeader5;
    }
}

