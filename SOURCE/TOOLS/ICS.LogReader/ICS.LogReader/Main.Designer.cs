namespace ICS.LogReader
{
    partial class Main
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
            this.openFileDialog = new System.Windows.Forms.OpenFileDialog();
            this.optionsPanel = new System.Windows.Forms.Panel();
            this.filterGroupBox = new System.Windows.Forms.GroupBox();
            this.maxTimeDetailLabel = new System.Windows.Forms.Label();
            this.calculateMaxTime = new System.Windows.Forms.Button();
            this.matchCaseCheckBox = new System.Windows.Forms.CheckBox();
            this.containsCheckBox = new System.Windows.Forms.CheckBox();
            this.containTextBox = new System.Windows.Forms.TextBox();
            this.buttonPanel = new System.Windows.Forms.Panel();
            this.exitButton = new System.Windows.Forms.Button();
            this.filterButton = new System.Windows.Forms.Button();
            this.outputBox = new System.Windows.Forms.RichTextBox();
            this.infoPanel = new System.Windows.Forms.Panel();
            this.showFileContentsCheckBox = new System.Windows.Forms.CheckBox();
            this.pathLabel = new System.Windows.Forms.Label();
            this.openButton = new System.Windows.Forms.Button();
            this.progressBar = new System.Windows.Forms.ProgressBar();
            this.loadLabel = new System.Windows.Forms.Label();
            this.withinHourCheck = new System.Windows.Forms.CheckBox();
            this.withinHourInput = new System.Windows.Forms.NumericUpDown();
            this.optionsPanel.SuspendLayout();
            this.filterGroupBox.SuspendLayout();
            this.buttonPanel.SuspendLayout();
            this.infoPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.withinHourInput)).BeginInit();
            this.SuspendLayout();
            // 
            // openFileDialog
            // 
            this.openFileDialog.DefaultExt = "*.arc";
            this.openFileDialog.Filter = "Log files|*.arc|All files|*.*";
            // 
            // optionsPanel
            // 
            this.optionsPanel.Controls.Add(this.filterGroupBox);
            this.optionsPanel.Controls.Add(this.buttonPanel);
            this.optionsPanel.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.optionsPanel.Location = new System.Drawing.Point(0, 438);
            this.optionsPanel.Name = "optionsPanel";
            this.optionsPanel.Size = new System.Drawing.Size(792, 128);
            this.optionsPanel.TabIndex = 0;
            // 
            // filterGroupBox
            // 
            this.filterGroupBox.Controls.Add(this.withinHourInput);
            this.filterGroupBox.Controls.Add(this.withinHourCheck);
            this.filterGroupBox.Controls.Add(this.maxTimeDetailLabel);
            this.filterGroupBox.Controls.Add(this.calculateMaxTime);
            this.filterGroupBox.Controls.Add(this.matchCaseCheckBox);
            this.filterGroupBox.Controls.Add(this.containsCheckBox);
            this.filterGroupBox.Controls.Add(this.containTextBox);
            this.filterGroupBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.filterGroupBox.Location = new System.Drawing.Point(0, 0);
            this.filterGroupBox.Name = "filterGroupBox";
            this.filterGroupBox.Size = new System.Drawing.Size(686, 128);
            this.filterGroupBox.TabIndex = 3;
            this.filterGroupBox.TabStop = false;
            this.filterGroupBox.Text = "Filter";
            // 
            // maxTimeDetailLabel
            // 
            this.maxTimeDetailLabel.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.maxTimeDetailLabel.Font = new System.Drawing.Font("Verdana", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.maxTimeDetailLabel.Location = new System.Drawing.Point(146, 42);
            this.maxTimeDetailLabel.Name = "maxTimeDetailLabel";
            this.maxTimeDetailLabel.Size = new System.Drawing.Size(463, 43);
            this.maxTimeDetailLabel.TabIndex = 6;
            this.maxTimeDetailLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // calculateMaxTime
            // 
            this.calculateMaxTime.Location = new System.Drawing.Point(6, 42);
            this.calculateMaxTime.Name = "calculateMaxTime";
            this.calculateMaxTime.Size = new System.Drawing.Size(111, 23);
            this.calculateMaxTime.TabIndex = 2;
            this.calculateMaxTime.Text = "Calculate Max Time";
            this.calculateMaxTime.UseVisualStyleBackColor = true;
            this.calculateMaxTime.Click += new System.EventHandler(this.calculateMaxTime_Click);
            // 
            // matchCaseCheckBox
            // 
            this.matchCaseCheckBox.AutoSize = true;
            this.matchCaseCheckBox.Location = new System.Drawing.Point(593, 19);
            this.matchCaseCheckBox.Name = "matchCaseCheckBox";
            this.matchCaseCheckBox.Size = new System.Drawing.Size(83, 17);
            this.matchCaseCheckBox.TabIndex = 5;
            this.matchCaseCheckBox.Text = "Match Case";
            this.matchCaseCheckBox.UseVisualStyleBackColor = true;
            // 
            // containsCheckBox
            // 
            this.containsCheckBox.AutoSize = true;
            this.containsCheckBox.Checked = true;
            this.containsCheckBox.CheckState = System.Windows.Forms.CheckState.Checked;
            this.containsCheckBox.Location = new System.Drawing.Point(6, 19);
            this.containsCheckBox.Name = "containsCheckBox";
            this.containsCheckBox.Size = new System.Drawing.Size(91, 17);
            this.containsCheckBox.TabIndex = 3;
            this.containsCheckBox.Text = "Contains Text";
            this.containsCheckBox.UseVisualStyleBackColor = true;
            // 
            // containTextBox
            // 
            this.containTextBox.Location = new System.Drawing.Point(103, 16);
            this.containTextBox.Name = "containTextBox";
            this.containTextBox.Size = new System.Drawing.Size(483, 20);
            this.containTextBox.TabIndex = 2;
            this.containTextBox.Text = "ics_inbound_mqft";
            // 
            // buttonPanel
            // 
            this.buttonPanel.Controls.Add(this.exitButton);
            this.buttonPanel.Controls.Add(this.filterButton);
            this.buttonPanel.Dock = System.Windows.Forms.DockStyle.Right;
            this.buttonPanel.Location = new System.Drawing.Point(686, 0);
            this.buttonPanel.Name = "buttonPanel";
            this.buttonPanel.Size = new System.Drawing.Size(106, 128);
            this.buttonPanel.TabIndex = 4;
            // 
            // exitButton
            // 
            this.exitButton.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.exitButton.Location = new System.Drawing.Point(6, 78);
            this.exitButton.Name = "exitButton";
            this.exitButton.Size = new System.Drawing.Size(75, 23);
            this.exitButton.TabIndex = 1;
            this.exitButton.Text = "Exit";
            this.exitButton.UseVisualStyleBackColor = true;
            this.exitButton.Click += new System.EventHandler(this.exitButton_Click);
            // 
            // filterButton
            // 
            this.filterButton.Location = new System.Drawing.Point(6, 6);
            this.filterButton.Name = "filterButton";
            this.filterButton.Size = new System.Drawing.Size(75, 23);
            this.filterButton.TabIndex = 0;
            this.filterButton.Text = "Run Filter";
            this.filterButton.UseVisualStyleBackColor = true;
            this.filterButton.Click += new System.EventHandler(this.filterButton_Click);
            // 
            // outputBox
            // 
            this.outputBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.outputBox.Location = new System.Drawing.Point(0, 58);
            this.outputBox.Name = "outputBox";
            this.outputBox.Size = new System.Drawing.Size(792, 380);
            this.outputBox.TabIndex = 1;
            this.outputBox.Text = "";
            // 
            // infoPanel
            // 
            this.infoPanel.Controls.Add(this.showFileContentsCheckBox);
            this.infoPanel.Controls.Add(this.pathLabel);
            this.infoPanel.Controls.Add(this.openButton);
            this.infoPanel.Dock = System.Windows.Forms.DockStyle.Top;
            this.infoPanel.Location = new System.Drawing.Point(0, 0);
            this.infoPanel.Name = "infoPanel";
            this.infoPanel.Size = new System.Drawing.Size(792, 35);
            this.infoPanel.TabIndex = 2;
            // 
            // showFileContentsCheckBox
            // 
            this.showFileContentsCheckBox.AutoSize = true;
            this.showFileContentsCheckBox.Location = new System.Drawing.Point(623, 10);
            this.showFileContentsCheckBox.Name = "showFileContentsCheckBox";
            this.showFileContentsCheckBox.Size = new System.Drawing.Size(161, 17);
            this.showFileContentsCheckBox.TabIndex = 2;
            this.showFileContentsCheckBox.Text = "Show File Contents On Load";
            this.showFileContentsCheckBox.UseVisualStyleBackColor = true;
            // 
            // pathLabel
            // 
            this.pathLabel.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.pathLabel.Font = new System.Drawing.Font("Verdana", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.pathLabel.Location = new System.Drawing.Point(93, 6);
            this.pathLabel.Name = "pathLabel";
            this.pathLabel.Size = new System.Drawing.Size(516, 23);
            this.pathLabel.TabIndex = 1;
            this.pathLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // openButton
            // 
            this.openButton.Location = new System.Drawing.Point(12, 6);
            this.openButton.Name = "openButton";
            this.openButton.Size = new System.Drawing.Size(75, 23);
            this.openButton.TabIndex = 0;
            this.openButton.Text = "Open";
            this.openButton.UseVisualStyleBackColor = true;
            this.openButton.Click += new System.EventHandler(this.openButton_Click);
            // 
            // progressBar
            // 
            this.progressBar.Dock = System.Windows.Forms.DockStyle.Top;
            this.progressBar.Location = new System.Drawing.Point(0, 35);
            this.progressBar.Name = "progressBar";
            this.progressBar.Size = new System.Drawing.Size(792, 23);
            this.progressBar.TabIndex = 4;
            this.progressBar.Visible = false;
            // 
            // loadLabel
            // 
            this.loadLabel.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.loadLabel.BackColor = System.Drawing.SystemColors.Info;
            this.loadLabel.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.loadLabel.Font = new System.Drawing.Font("Verdana", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.loadLabel.ForeColor = System.Drawing.Color.Blue;
            this.loadLabel.Location = new System.Drawing.Point(268, 244);
            this.loadLabel.Name = "loadLabel";
            this.loadLabel.Size = new System.Drawing.Size(257, 78);
            this.loadLabel.TabIndex = 5;
            this.loadLabel.Text = "Loading ...";
            this.loadLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.loadLabel.Visible = false;
            // 
            // withinHourCheck
            // 
            this.withinHourCheck.AutoSize = true;
            this.withinHourCheck.Location = new System.Drawing.Point(6, 68);
            this.withinHourCheck.Name = "withinHourCheck";
            this.withinHourCheck.Size = new System.Drawing.Size(82, 17);
            this.withinHourCheck.TabIndex = 7;
            this.withinHourCheck.Text = "Within Hour";
            this.withinHourCheck.UseVisualStyleBackColor = true;
            // 
            // withinHourInput
            // 
            this.withinHourInput.Location = new System.Drawing.Point(93, 65);
            this.withinHourInput.Maximum = new decimal(new int[] {
            23,
            0,
            0,
            0});
            this.withinHourInput.Name = "withinHourInput";
            this.withinHourInput.Size = new System.Drawing.Size(51, 20);
            this.withinHourInput.TabIndex = 8;
            // 
            // Main
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(792, 566);
            this.Controls.Add(this.loadLabel);
            this.Controls.Add(this.outputBox);
            this.Controls.Add(this.progressBar);
            this.Controls.Add(this.infoPanel);
            this.Controls.Add(this.optionsPanel);
            this.Name = "Main";
            this.Text = "Log Reader";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.optionsPanel.ResumeLayout(false);
            this.filterGroupBox.ResumeLayout(false);
            this.filterGroupBox.PerformLayout();
            this.buttonPanel.ResumeLayout(false);
            this.infoPanel.ResumeLayout(false);
            this.infoPanel.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.withinHourInput)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.OpenFileDialog openFileDialog;
        private System.Windows.Forms.Panel optionsPanel;
        private System.Windows.Forms.RichTextBox outputBox;
        private System.Windows.Forms.TextBox containTextBox;
        private System.Windows.Forms.Button exitButton;
        private System.Windows.Forms.Button filterButton;
        private System.Windows.Forms.Panel infoPanel;
        private System.Windows.Forms.Label pathLabel;
        private System.Windows.Forms.Button openButton;
        private System.Windows.Forms.Panel buttonPanel;
        private System.Windows.Forms.GroupBox filterGroupBox;
        private System.Windows.Forms.CheckBox containsCheckBox;
        private System.Windows.Forms.CheckBox showFileContentsCheckBox;
        private System.Windows.Forms.CheckBox matchCaseCheckBox;
        private System.Windows.Forms.ProgressBar progressBar;
        private System.Windows.Forms.Label maxTimeDetailLabel;
        private System.Windows.Forms.Button calculateMaxTime;
        private System.Windows.Forms.Label loadLabel;
        private System.Windows.Forms.NumericUpDown withinHourInput;
        private System.Windows.Forms.CheckBox withinHourCheck;
    }
}

