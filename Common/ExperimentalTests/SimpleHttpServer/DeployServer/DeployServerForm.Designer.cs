namespace DeployServer
{
    partial class DeployServerForm
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
            this.tableMain = new System.Windows.Forms.TableLayoutPanel();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.listViewDeployment = new System.Windows.Forms.ListView();
            this.columnHeader1 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader2 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.buttonOpenDeploymentDirectory = new System.Windows.Forms.Button();
            this.labelDeploymentDirectory = new System.Windows.Forms.Label();
            this.buttonStartServices = new System.Windows.Forms.Button();
            this.buttonStopServices = new System.Windows.Forms.Button();
            this.listViewServices = new System.Windows.Forms.ListView();
            this.columnHeader3 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader4 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader5 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader6 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.timerUpdate = new System.Windows.Forms.Timer(this.components);
            this.tableMain.SuspendLayout();
            this.SuspendLayout();
            // 
            // tableMain
            // 
            this.tableMain.ColumnCount = 3;
            this.tableMain.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tableMain.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableMain.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tableMain.Controls.Add(this.label1, 0, 1);
            this.tableMain.Controls.Add(this.label2, 0, 3);
            this.tableMain.Controls.Add(this.label3, 0, 0);
            this.tableMain.Controls.Add(this.listViewDeployment, 0, 2);
            this.tableMain.Controls.Add(this.buttonOpenDeploymentDirectory, 2, 0);
            this.tableMain.Controls.Add(this.labelDeploymentDirectory, 1, 0);
            this.tableMain.Controls.Add(this.buttonStartServices, 2, 4);
            this.tableMain.Controls.Add(this.buttonStopServices, 2, 5);
            this.tableMain.Controls.Add(this.listViewServices, 0, 4);
            this.tableMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableMain.Location = new System.Drawing.Point(0, 0);
            this.tableMain.Name = "tableMain";
            this.tableMain.RowCount = 7;
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableMain.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableMain.Size = new System.Drawing.Size(750, 558);
            this.tableMain.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.tableMain.SetColumnSpan(this.label1, 3);
            this.label1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label1.Location = new System.Drawing.Point(8, 36);
            this.label1.Margin = new System.Windows.Forms.Padding(8);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(734, 12);
            this.label1.TabIndex = 0;
            this.label1.Text = "Deployment Status: ";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.tableMain.SetColumnSpan(this.label2, 3);
            this.label2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label2.Location = new System.Drawing.Point(8, 292);
            this.label2.Margin = new System.Windows.Forms.Padding(8);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(734, 12);
            this.label2.TabIndex = 1;
            this.label2.Text = "Services Status: ";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label3.Location = new System.Drawing.Point(8, 8);
            this.label3.Margin = new System.Windows.Forms.Padding(8);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(137, 12);
            this.label3.TabIndex = 1;
            this.label3.Text = "Deployment Directory: ";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // listViewDeployment
            // 
            this.listViewDeployment.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.columnHeader1,
            this.columnHeader2});
            this.tableMain.SetColumnSpan(this.listViewDeployment, 3);
            this.listViewDeployment.Dock = System.Windows.Forms.DockStyle.Fill;
            this.listViewDeployment.FullRowSelect = true;
            this.listViewDeployment.GridLines = true;
            this.listViewDeployment.Location = new System.Drawing.Point(3, 59);
            this.listViewDeployment.Name = "listViewDeployment";
            this.listViewDeployment.Size = new System.Drawing.Size(744, 222);
            this.listViewDeployment.TabIndex = 2;
            this.listViewDeployment.UseCompatibleStateImageBehavior = false;
            this.listViewDeployment.View = System.Windows.Forms.View.Details;
            // 
            // columnHeader1
            // 
            this.columnHeader1.Text = "Property";
            this.columnHeader1.Width = 120;
            // 
            // columnHeader2
            // 
            this.columnHeader2.Text = "Value";
            this.columnHeader2.Width = 480;
            // 
            // buttonOpenDeploymentDirectory
            // 
            this.buttonOpenDeploymentDirectory.AutoSize = true;
            this.buttonOpenDeploymentDirectory.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.buttonOpenDeploymentDirectory.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonOpenDeploymentDirectory.Location = new System.Drawing.Point(558, 3);
            this.buttonOpenDeploymentDirectory.Name = "buttonOpenDeploymentDirectory";
            this.buttonOpenDeploymentDirectory.Size = new System.Drawing.Size(189, 22);
            this.buttonOpenDeploymentDirectory.TabIndex = 3;
            this.buttonOpenDeploymentDirectory.Text = "Open Deployment Directory ...";
            this.buttonOpenDeploymentDirectory.UseVisualStyleBackColor = true;
            this.buttonOpenDeploymentDirectory.Click += new System.EventHandler(this.buttonOpenDeploymentDirectory_Click);
            // 
            // labelDeploymentDirectory
            // 
            this.labelDeploymentDirectory.AutoSize = true;
            this.labelDeploymentDirectory.Dock = System.Windows.Forms.DockStyle.Fill;
            this.labelDeploymentDirectory.Location = new System.Drawing.Point(161, 8);
            this.labelDeploymentDirectory.Margin = new System.Windows.Forms.Padding(8);
            this.labelDeploymentDirectory.Name = "labelDeploymentDirectory";
            this.labelDeploymentDirectory.Size = new System.Drawing.Size(386, 12);
            this.labelDeploymentDirectory.TabIndex = 4;
            this.labelDeploymentDirectory.Text = "<Deployment Directory>";
            this.labelDeploymentDirectory.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // buttonStartServices
            // 
            this.buttonStartServices.AutoSize = true;
            this.buttonStartServices.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.buttonStartServices.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonStartServices.Enabled = false;
            this.buttonStartServices.Location = new System.Drawing.Point(558, 315);
            this.buttonStartServices.Name = "buttonStartServices";
            this.buttonStartServices.Size = new System.Drawing.Size(189, 22);
            this.buttonStartServices.TabIndex = 5;
            this.buttonStartServices.Text = "Start Services";
            this.buttonStartServices.UseVisualStyleBackColor = true;
            this.buttonStartServices.Click += new System.EventHandler(this.buttonStartServices_Click);
            // 
            // buttonStopServices
            // 
            this.buttonStopServices.AutoSize = true;
            this.buttonStopServices.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.buttonStopServices.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonStopServices.Location = new System.Drawing.Point(558, 343);
            this.buttonStopServices.Name = "buttonStopServices";
            this.buttonStopServices.Size = new System.Drawing.Size(189, 22);
            this.buttonStopServices.TabIndex = 6;
            this.buttonStopServices.Text = "Stop Services";
            this.buttonStopServices.UseVisualStyleBackColor = true;
            this.buttonStopServices.Click += new System.EventHandler(this.buttonStopServices_Click);
            // 
            // listViewServices
            // 
            this.listViewServices.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.columnHeader3,
            this.columnHeader4,
            this.columnHeader5,
            this.columnHeader6});
            this.tableMain.SetColumnSpan(this.listViewServices, 2);
            this.listViewServices.Dock = System.Windows.Forms.DockStyle.Fill;
            this.listViewServices.FullRowSelect = true;
            this.listViewServices.GridLines = true;
            this.listViewServices.Location = new System.Drawing.Point(3, 315);
            this.listViewServices.Name = "listViewServices";
            this.tableMain.SetRowSpan(this.listViewServices, 3);
            this.listViewServices.Size = new System.Drawing.Size(549, 240);
            this.listViewServices.TabIndex = 7;
            this.listViewServices.UseCompatibleStateImageBehavior = false;
            this.listViewServices.View = System.Windows.Forms.View.Details;
            // 
            // columnHeader3
            // 
            this.columnHeader3.Text = "Name";
            this.columnHeader3.Width = 120;
            // 
            // columnHeader4
            // 
            this.columnHeader4.Text = "Status";
            this.columnHeader4.Width = 120;
            // 
            // columnHeader5
            // 
            this.columnHeader5.Text = "Url";
            this.columnHeader5.Width = 240;
            // 
            // columnHeader6
            // 
            this.columnHeader6.Text = "Error";
            this.columnHeader6.Width = 240;
            // 
            // timerUpdate
            // 
            this.timerUpdate.Interval = 5000;
            this.timerUpdate.Tick += new System.EventHandler(this.timerUpdate_Tick);
            // 
            // DeployServerForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(750, 558);
            this.Controls.Add(this.tableMain);
            this.Name = "DeployServerForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Vczh Services Deployment Server";
            this.tableMain.ResumeLayout(false);
            this.tableMain.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TableLayoutPanel tableMain;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ListView listViewDeployment;
        private System.Windows.Forms.ColumnHeader columnHeader1;
        private System.Windows.Forms.ColumnHeader columnHeader2;
        private System.Windows.Forms.Timer timerUpdate;
        private System.Windows.Forms.Button buttonOpenDeploymentDirectory;
        private System.Windows.Forms.Label labelDeploymentDirectory;
        private System.Windows.Forms.Button buttonStartServices;
        private System.Windows.Forms.Button buttonStopServices;
        private System.Windows.Forms.ListView listViewServices;
        private System.Windows.Forms.ColumnHeader columnHeader3;
        private System.Windows.Forms.ColumnHeader columnHeader4;
        private System.Windows.Forms.ColumnHeader columnHeader5;
        private System.Windows.Forms.ColumnHeader columnHeader6;
    }
}

