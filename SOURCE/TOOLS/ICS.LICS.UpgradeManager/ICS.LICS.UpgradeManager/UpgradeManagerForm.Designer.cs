namespace ICS.LICS.UpgradeManager
{
    partial class UpgradeManagerForm
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
            this.statusStrip = new System.Windows.Forms.StatusStrip();
            this.progressBar = new System.Windows.Forms.ToolStripProgressBar();
            this.progressLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.versionLabel = new System.Windows.Forms.Label();
            this.buttonPanel = new System.Windows.Forms.Panel();
            this.exitButton = new System.Windows.Forms.Button();
            this.generateButton = new System.Windows.Forms.Button();
            this.mainPanel = new System.Windows.Forms.Panel();
            this.licsAppPathInput = new System.Windows.Forms.TextBox();
            this.licsAppPathLabel = new System.Windows.Forms.Label();
            this.licsPathInput = new System.Windows.Forms.TextBox();
            this.licsPathLabel = new System.Windows.Forms.Label();
            this.removeLicsAppFileButton = new System.Windows.Forms.Button();
            this.addLicsAppFileButton = new System.Windows.Forms.Button();
            this.licsAppFileListBox = new System.Windows.Forms.ListBox();
            this.licsAppFileLabel = new System.Windows.Forms.Label();
            this.removeLicsFileButton = new System.Windows.Forms.Button();
            this.addLicsFileButton = new System.Windows.Forms.Button();
            this.licsFileListBox = new System.Windows.Forms.ListBox();
            this.licsFileLabel = new System.Windows.Forms.Label();
            this.environmentGroupBox = new System.Windows.Forms.GroupBox();
            this.productionCheck = new System.Windows.Forms.RadioButton();
            this.testCheck = new System.Windows.Forms.RadioButton();
            this.databaseInput = new System.Windows.Forms.TextBox();
            this.databaseLabel = new System.Windows.Forms.Label();
            this.browseButton = new System.Windows.Forms.Button();
            this.passwordInput = new System.Windows.Forms.TextBox();
            this.siteListBox = new System.Windows.Forms.ListBox();
            this.pathToGenerateInput = new System.Windows.Forms.TextBox();
            this.versionInput = new System.Windows.Forms.TextBox();
            this.siteLabel = new System.Windows.Forms.Label();
            this.passwordLabel = new System.Windows.Forms.Label();
            this.pathToGenerateLabel = new System.Windows.Forms.Label();
            this.folderBrowserDialog = new System.Windows.Forms.FolderBrowserDialog();
            this.openFileDialog = new System.Windows.Forms.OpenFileDialog();
            this.statusStrip.SuspendLayout();
            this.buttonPanel.SuspendLayout();
            this.mainPanel.SuspendLayout();
            this.environmentGroupBox.SuspendLayout();
            this.SuspendLayout();
            // 
            // statusStrip
            // 
            this.statusStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.progressBar,
            this.progressLabel});
            this.statusStrip.Location = new System.Drawing.Point(0, 371);
            this.statusStrip.Name = "statusStrip";
            this.statusStrip.Size = new System.Drawing.Size(911, 22);
            this.statusStrip.TabIndex = 0;
            // 
            // progressBar
            // 
            this.progressBar.Name = "progressBar";
            this.progressBar.Size = new System.Drawing.Size(250, 16);
            // 
            // progressLabel
            // 
            this.progressLabel.AutoSize = false;
            this.progressLabel.Name = "progressLabel";
            this.progressLabel.Size = new System.Drawing.Size(300, 17);
            // 
            // versionLabel
            // 
            this.versionLabel.Location = new System.Drawing.Point(10, 12);
            this.versionLabel.Name = "versionLabel";
            this.versionLabel.Size = new System.Drawing.Size(107, 23);
            this.versionLabel.TabIndex = 1;
            this.versionLabel.Text = "Version:";
            // 
            // buttonPanel
            // 
            this.buttonPanel.Controls.Add(this.exitButton);
            this.buttonPanel.Controls.Add(this.generateButton);
            this.buttonPanel.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.buttonPanel.Location = new System.Drawing.Point(0, 330);
            this.buttonPanel.Name = "buttonPanel";
            this.buttonPanel.Size = new System.Drawing.Size(911, 41);
            this.buttonPanel.TabIndex = 2;
            // 
            // exitButton
            // 
            this.exitButton.Location = new System.Drawing.Point(466, 11);
            this.exitButton.Name = "exitButton";
            this.exitButton.Size = new System.Drawing.Size(75, 23);
            this.exitButton.TabIndex = 1;
            this.exitButton.Text = "Exit";
            this.exitButton.UseVisualStyleBackColor = true;
            this.exitButton.Click += new System.EventHandler(this.exitButton_Click);
            // 
            // generateButton
            // 
            this.generateButton.Location = new System.Drawing.Point(370, 11);
            this.generateButton.Name = "generateButton";
            this.generateButton.Size = new System.Drawing.Size(75, 23);
            this.generateButton.TabIndex = 0;
            this.generateButton.Text = "Generate";
            this.generateButton.UseVisualStyleBackColor = true;
            this.generateButton.Click += new System.EventHandler(this.generateButton_Click);
            // 
            // mainPanel
            // 
            this.mainPanel.Controls.Add(this.licsAppPathInput);
            this.mainPanel.Controls.Add(this.licsAppPathLabel);
            this.mainPanel.Controls.Add(this.licsPathInput);
            this.mainPanel.Controls.Add(this.licsPathLabel);
            this.mainPanel.Controls.Add(this.removeLicsAppFileButton);
            this.mainPanel.Controls.Add(this.addLicsAppFileButton);
            this.mainPanel.Controls.Add(this.licsAppFileListBox);
            this.mainPanel.Controls.Add(this.licsAppFileLabel);
            this.mainPanel.Controls.Add(this.removeLicsFileButton);
            this.mainPanel.Controls.Add(this.addLicsFileButton);
            this.mainPanel.Controls.Add(this.licsFileListBox);
            this.mainPanel.Controls.Add(this.licsFileLabel);
            this.mainPanel.Controls.Add(this.environmentGroupBox);
            this.mainPanel.Controls.Add(this.databaseInput);
            this.mainPanel.Controls.Add(this.databaseLabel);
            this.mainPanel.Controls.Add(this.browseButton);
            this.mainPanel.Controls.Add(this.passwordInput);
            this.mainPanel.Controls.Add(this.siteListBox);
            this.mainPanel.Controls.Add(this.pathToGenerateInput);
            this.mainPanel.Controls.Add(this.versionInput);
            this.mainPanel.Controls.Add(this.siteLabel);
            this.mainPanel.Controls.Add(this.passwordLabel);
            this.mainPanel.Controls.Add(this.pathToGenerateLabel);
            this.mainPanel.Controls.Add(this.versionLabel);
            this.mainPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.mainPanel.Location = new System.Drawing.Point(0, 0);
            this.mainPanel.Name = "mainPanel";
            this.mainPanel.Size = new System.Drawing.Size(911, 330);
            this.mainPanel.TabIndex = 3;
            // 
            // licsAppPathInput
            // 
            this.licsAppPathInput.Location = new System.Drawing.Point(714, 12);
            this.licsAppPathInput.Name = "licsAppPathInput";
            this.licsAppPathInput.Size = new System.Drawing.Size(157, 20);
            this.licsAppPathInput.TabIndex = 23;
            // 
            // licsAppPathLabel
            // 
            this.licsAppPathLabel.Location = new System.Drawing.Point(601, 12);
            this.licsAppPathLabel.Name = "licsAppPathLabel";
            this.licsAppPathLabel.Size = new System.Drawing.Size(107, 23);
            this.licsAppPathLabel.TabIndex = 22;
            this.licsAppPathLabel.Text = "LICS_APP Path:";
            // 
            // licsPathInput
            // 
            this.licsPathInput.Location = new System.Drawing.Point(419, 12);
            this.licsPathInput.Name = "licsPathInput";
            this.licsPathInput.Size = new System.Drawing.Size(157, 20);
            this.licsPathInput.TabIndex = 21;
            // 
            // licsPathLabel
            // 
            this.licsPathLabel.Location = new System.Drawing.Point(306, 12);
            this.licsPathLabel.Name = "licsPathLabel";
            this.licsPathLabel.Size = new System.Drawing.Size(107, 23);
            this.licsPathLabel.TabIndex = 20;
            this.licsPathLabel.Text = "LICS Path:";
            // 
            // removeLicsAppFileButton
            // 
            this.removeLicsAppFileButton.Location = new System.Drawing.Point(604, 97);
            this.removeLicsAppFileButton.Name = "removeLicsAppFileButton";
            this.removeLicsAppFileButton.Size = new System.Drawing.Size(75, 23);
            this.removeLicsAppFileButton.TabIndex = 19;
            this.removeLicsAppFileButton.Text = "Remove";
            this.removeLicsAppFileButton.UseVisualStyleBackColor = true;
            this.removeLicsAppFileButton.Click += new System.EventHandler(this.removeLicsAppFileButton_Click);
            // 
            // addLicsAppFileButton
            // 
            this.addLicsAppFileButton.Location = new System.Drawing.Point(604, 68);
            this.addLicsAppFileButton.Name = "addLicsAppFileButton";
            this.addLicsAppFileButton.Size = new System.Drawing.Size(75, 23);
            this.addLicsAppFileButton.TabIndex = 16;
            this.addLicsAppFileButton.Text = "Add";
            this.addLicsAppFileButton.UseVisualStyleBackColor = true;
            this.addLicsAppFileButton.Click += new System.EventHandler(this.addLicsAppFileButton_Click);
            // 
            // licsAppFileListBox
            // 
            this.licsAppFileListBox.FormattingEnabled = true;
            this.licsAppFileListBox.Location = new System.Drawing.Point(714, 38);
            this.licsAppFileListBox.Name = "licsAppFileListBox";
            this.licsAppFileListBox.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended;
            this.licsAppFileListBox.Size = new System.Drawing.Size(157, 173);
            this.licsAppFileListBox.TabIndex = 18;
            // 
            // licsAppFileLabel
            // 
            this.licsAppFileLabel.Location = new System.Drawing.Point(601, 38);
            this.licsAppFileLabel.Name = "licsAppFileLabel";
            this.licsAppFileLabel.Size = new System.Drawing.Size(107, 31);
            this.licsAppFileLabel.TabIndex = 17;
            this.licsAppFileLabel.Text = "LICS_APP Upgrade Files:";
            // 
            // removeLicsFileButton
            // 
            this.removeLicsFileButton.Location = new System.Drawing.Point(309, 97);
            this.removeLicsFileButton.Name = "removeLicsFileButton";
            this.removeLicsFileButton.Size = new System.Drawing.Size(75, 23);
            this.removeLicsFileButton.TabIndex = 15;
            this.removeLicsFileButton.Text = "Remove";
            this.removeLicsFileButton.UseVisualStyleBackColor = true;
            this.removeLicsFileButton.Click += new System.EventHandler(this.removeLicsFileButton_Click);
            // 
            // addLicsFileButton
            // 
            this.addLicsFileButton.Location = new System.Drawing.Point(309, 68);
            this.addLicsFileButton.Name = "addLicsFileButton";
            this.addLicsFileButton.Size = new System.Drawing.Size(75, 23);
            this.addLicsFileButton.TabIndex = 2;
            this.addLicsFileButton.Text = "Add";
            this.addLicsFileButton.UseVisualStyleBackColor = true;
            this.addLicsFileButton.Click += new System.EventHandler(this.addLicsFileButton_Click);
            // 
            // licsFileListBox
            // 
            this.licsFileListBox.FormattingEnabled = true;
            this.licsFileListBox.Location = new System.Drawing.Point(419, 38);
            this.licsFileListBox.Name = "licsFileListBox";
            this.licsFileListBox.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended;
            this.licsFileListBox.Size = new System.Drawing.Size(157, 173);
            this.licsFileListBox.TabIndex = 14;
            // 
            // licsFileLabel
            // 
            this.licsFileLabel.Location = new System.Drawing.Point(306, 38);
            this.licsFileLabel.Name = "licsFileLabel";
            this.licsFileLabel.Size = new System.Drawing.Size(107, 23);
            this.licsFileLabel.TabIndex = 13;
            this.licsFileLabel.Text = "LICS Upgrade Files:";
            // 
            // environmentGroupBox
            // 
            this.environmentGroupBox.Controls.Add(this.productionCheck);
            this.environmentGroupBox.Controls.Add(this.testCheck);
            this.environmentGroupBox.Location = new System.Drawing.Point(303, 220);
            this.environmentGroupBox.Name = "environmentGroupBox";
            this.environmentGroupBox.Size = new System.Drawing.Size(171, 48);
            this.environmentGroupBox.TabIndex = 12;
            this.environmentGroupBox.TabStop = false;
            this.environmentGroupBox.Text = "Environment";
            // 
            // productionCheck
            // 
            this.productionCheck.AutoSize = true;
            this.productionCheck.Checked = true;
            this.productionCheck.Location = new System.Drawing.Point(73, 19);
            this.productionCheck.Name = "productionCheck";
            this.productionCheck.Size = new System.Drawing.Size(76, 17);
            this.productionCheck.TabIndex = 1;
            this.productionCheck.TabStop = true;
            this.productionCheck.Text = "Production";
            this.productionCheck.UseVisualStyleBackColor = true;
            this.productionCheck.CheckedChanged += new System.EventHandler(this.radioButton_CheckedChanged);
            // 
            // testCheck
            // 
            this.testCheck.AutoSize = true;
            this.testCheck.Location = new System.Drawing.Point(6, 19);
            this.testCheck.Name = "testCheck";
            this.testCheck.Size = new System.Drawing.Size(46, 17);
            this.testCheck.TabIndex = 0;
            this.testCheck.Text = "Test";
            this.testCheck.UseVisualStyleBackColor = true;
            this.testCheck.CheckedChanged += new System.EventHandler(this.radioButton_CheckedChanged);
            // 
            // databaseInput
            // 
            this.databaseInput.Location = new System.Drawing.Point(123, 249);
            this.databaseInput.Name = "databaseInput";
            this.databaseInput.Size = new System.Drawing.Size(157, 20);
            this.databaseInput.TabIndex = 11;
            // 
            // databaseLabel
            // 
            this.databaseLabel.Location = new System.Drawing.Point(10, 249);
            this.databaseLabel.Name = "databaseLabel";
            this.databaseLabel.Size = new System.Drawing.Size(107, 23);
            this.databaseLabel.TabIndex = 10;
            this.databaseLabel.Text = "Database";
            // 
            // browseButton
            // 
            this.browseButton.Location = new System.Drawing.Point(579, 278);
            this.browseButton.Name = "browseButton";
            this.browseButton.Size = new System.Drawing.Size(27, 20);
            this.browseButton.TabIndex = 9;
            this.browseButton.Text = "...";
            this.browseButton.UseVisualStyleBackColor = true;
            this.browseButton.Click += new System.EventHandler(this.browseButton_Click);
            // 
            // passwordInput
            // 
            this.passwordInput.Location = new System.Drawing.Point(123, 220);
            this.passwordInput.Name = "passwordInput";
            this.passwordInput.PasswordChar = '*';
            this.passwordInput.Size = new System.Drawing.Size(157, 20);
            this.passwordInput.TabIndex = 8;
            // 
            // siteListBox
            // 
            this.siteListBox.FormattingEnabled = true;
            this.siteListBox.Location = new System.Drawing.Point(123, 38);
            this.siteListBox.Name = "siteListBox";
            this.siteListBox.Size = new System.Drawing.Size(157, 173);
            this.siteListBox.TabIndex = 7;
            this.siteListBox.SelectedIndexChanged += new System.EventHandler(this.siteListBox_SelectedIndexChanged);
            // 
            // pathToGenerateInput
            // 
            this.pathToGenerateInput.Location = new System.Drawing.Point(123, 278);
            this.pathToGenerateInput.Name = "pathToGenerateInput";
            this.pathToGenerateInput.Size = new System.Drawing.Size(450, 20);
            this.pathToGenerateInput.TabIndex = 6;
            // 
            // versionInput
            // 
            this.versionInput.Location = new System.Drawing.Point(123, 12);
            this.versionInput.Name = "versionInput";
            this.versionInput.Size = new System.Drawing.Size(157, 20);
            this.versionInput.TabIndex = 5;
            // 
            // siteLabel
            // 
            this.siteLabel.Location = new System.Drawing.Point(10, 38);
            this.siteLabel.Name = "siteLabel";
            this.siteLabel.Size = new System.Drawing.Size(107, 23);
            this.siteLabel.TabIndex = 4;
            this.siteLabel.Text = "Site:";
            // 
            // passwordLabel
            // 
            this.passwordLabel.Location = new System.Drawing.Point(10, 220);
            this.passwordLabel.Name = "passwordLabel";
            this.passwordLabel.Size = new System.Drawing.Size(107, 23);
            this.passwordLabel.TabIndex = 3;
            this.passwordLabel.Text = "LICS Password:";
            // 
            // pathToGenerateLabel
            // 
            this.pathToGenerateLabel.Location = new System.Drawing.Point(10, 278);
            this.pathToGenerateLabel.Name = "pathToGenerateLabel";
            this.pathToGenerateLabel.Size = new System.Drawing.Size(107, 29);
            this.pathToGenerateLabel.TabIndex = 2;
            this.pathToGenerateLabel.Text = "Path to generate upgrade package:";
            // 
            // openFileDialog
            // 
            this.openFileDialog.FileName = "openFileDialog1";
            this.openFileDialog.Filter = "SQL files|*.sql|All files|*.*";
            this.openFileDialog.Multiselect = true;
            // 
            // UpgradeManagerForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(911, 393);
            this.Controls.Add(this.mainPanel);
            this.Controls.Add(this.buttonPanel);
            this.Controls.Add(this.statusStrip);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "UpgradeManagerForm";
            this.Text = "LICS Upgrade Manager";
            this.statusStrip.ResumeLayout(false);
            this.statusStrip.PerformLayout();
            this.buttonPanel.ResumeLayout(false);
            this.mainPanel.ResumeLayout(false);
            this.mainPanel.PerformLayout();
            this.environmentGroupBox.ResumeLayout(false);
            this.environmentGroupBox.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.StatusStrip statusStrip;
        private System.Windows.Forms.ToolStripProgressBar progressBar;
        private System.Windows.Forms.ToolStripStatusLabel progressLabel;
        private System.Windows.Forms.Label versionLabel;
        private System.Windows.Forms.Panel buttonPanel;
        private System.Windows.Forms.Panel mainPanel;
        private System.Windows.Forms.TextBox pathToGenerateInput;
        private System.Windows.Forms.TextBox versionInput;
        private System.Windows.Forms.Label siteLabel;
        private System.Windows.Forms.Label passwordLabel;
        private System.Windows.Forms.Label pathToGenerateLabel;
        private System.Windows.Forms.Button exitButton;
        private System.Windows.Forms.Button generateButton;
        private System.Windows.Forms.Button browseButton;
        private System.Windows.Forms.TextBox passwordInput;
        private System.Windows.Forms.ListBox siteListBox;
        private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog;
        private System.Windows.Forms.TextBox databaseInput;
        private System.Windows.Forms.Label databaseLabel;
        private System.Windows.Forms.GroupBox environmentGroupBox;
        private System.Windows.Forms.RadioButton productionCheck;
        private System.Windows.Forms.RadioButton testCheck;
        private System.Windows.Forms.ListBox licsFileListBox;
        private System.Windows.Forms.Label licsFileLabel;
        private System.Windows.Forms.Button removeLicsFileButton;
        private System.Windows.Forms.Button addLicsFileButton;
        private System.Windows.Forms.OpenFileDialog openFileDialog;
        private System.Windows.Forms.Button removeLicsAppFileButton;
        private System.Windows.Forms.Button addLicsAppFileButton;
        private System.Windows.Forms.ListBox licsAppFileListBox;
        private System.Windows.Forms.Label licsAppFileLabel;
        private System.Windows.Forms.TextBox licsAppPathInput;
        private System.Windows.Forms.Label licsAppPathLabel;
        private System.Windows.Forms.TextBox licsPathInput;
        private System.Windows.Forms.Label licsPathLabel;
    }
}

