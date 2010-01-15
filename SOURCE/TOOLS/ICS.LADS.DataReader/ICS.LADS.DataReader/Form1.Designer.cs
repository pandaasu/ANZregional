namespace ICS.LADS.DataReader
{
    partial class MainForm
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
            this.progressBar = new System.Windows.Forms.ProgressBar();
            this.structureTextBox = new System.Windows.Forms.RichTextBox();
            this.inputPanel = new System.Windows.Forms.Panel();
            this.contentsGroupBox = new System.Windows.Forms.GroupBox();
            this.contentTextBox = new System.Windows.Forms.RichTextBox();
            this.filePanel = new System.Windows.Forms.Panel();
            this.fileTextBox = new System.Windows.Forms.TextBox();
            this.browseButton = new System.Windows.Forms.Button();
            this.fileLabel = new System.Windows.Forms.Label();
            this.structureGroupBox = new System.Windows.Forms.GroupBox();
            this.buttonPanel = new System.Windows.Forms.Panel();
            this.quitButton = new System.Windows.Forms.Button();
            this.runButton = new System.Windows.Forms.Button();
            this.editPanel = new System.Windows.Forms.Panel();
            this.lineInput = new System.Windows.Forms.NumericUpDown();
            this.applyFilterButton = new System.Windows.Forms.Button();
            this.filterTextBox = new System.Windows.Forms.TextBox();
            this.filterLabel = new System.Windows.Forms.Label();
            this.attachButton = new System.Windows.Forms.Button();
            this.positionLabel = new System.Windows.Forms.Label();
            this.copyAllButton = new System.Windows.Forms.Button();
            this.copyButton = new System.Windows.Forms.Button();
            this.nextButton = new System.Windows.Forms.Button();
            this.prevButton = new System.Windows.Forms.Button();
            this.resultGroupBox = new System.Windows.Forms.GroupBox();
            this.resultTextBox = new System.Windows.Forms.RichTextBox();
            this.openFileDialog = new System.Windows.Forms.OpenFileDialog();
            this.inputPanel.SuspendLayout();
            this.contentsGroupBox.SuspendLayout();
            this.filePanel.SuspendLayout();
            this.structureGroupBox.SuspendLayout();
            this.buttonPanel.SuspendLayout();
            this.editPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.lineInput)).BeginInit();
            this.resultGroupBox.SuspendLayout();
            this.SuspendLayout();
            // 
            // progressBar
            // 
            this.progressBar.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.progressBar.Location = new System.Drawing.Point(0, 704);
            this.progressBar.Name = "progressBar";
            this.progressBar.Size = new System.Drawing.Size(1041, 23);
            this.progressBar.TabIndex = 0;
            this.progressBar.Visible = false;
            // 
            // structureTextBox
            // 
            this.structureTextBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.structureTextBox.Location = new System.Drawing.Point(3, 16);
            this.structureTextBox.Name = "structureTextBox";
            this.structureTextBox.Size = new System.Drawing.Size(521, 339);
            this.structureTextBox.TabIndex = 2;
            this.structureTextBox.Text = "";
            // 
            // inputPanel
            // 
            this.inputPanel.Controls.Add(this.contentsGroupBox);
            this.inputPanel.Controls.Add(this.structureGroupBox);
            this.inputPanel.Dock = System.Windows.Forms.DockStyle.Top;
            this.inputPanel.Location = new System.Drawing.Point(0, 0);
            this.inputPanel.Name = "inputPanel";
            this.inputPanel.Padding = new System.Windows.Forms.Padding(5);
            this.inputPanel.Size = new System.Drawing.Size(1041, 368);
            this.inputPanel.TabIndex = 3;
            // 
            // contentsGroupBox
            // 
            this.contentsGroupBox.Controls.Add(this.contentTextBox);
            this.contentsGroupBox.Controls.Add(this.filePanel);
            this.contentsGroupBox.Dock = System.Windows.Forms.DockStyle.Right;
            this.contentsGroupBox.Location = new System.Drawing.Point(528, 5);
            this.contentsGroupBox.Name = "contentsGroupBox";
            this.contentsGroupBox.Size = new System.Drawing.Size(508, 358);
            this.contentsGroupBox.TabIndex = 4;
            this.contentsGroupBox.TabStop = false;
            this.contentsGroupBox.Text = "Contents";
            // 
            // contentTextBox
            // 
            this.contentTextBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.contentTextBox.Location = new System.Drawing.Point(3, 40);
            this.contentTextBox.Name = "contentTextBox";
            this.contentTextBox.Size = new System.Drawing.Size(502, 315);
            this.contentTextBox.TabIndex = 2;
            this.contentTextBox.Text = "";
            // 
            // filePanel
            // 
            this.filePanel.Controls.Add(this.fileTextBox);
            this.filePanel.Controls.Add(this.browseButton);
            this.filePanel.Controls.Add(this.fileLabel);
            this.filePanel.Dock = System.Windows.Forms.DockStyle.Top;
            this.filePanel.Location = new System.Drawing.Point(3, 16);
            this.filePanel.Name = "filePanel";
            this.filePanel.Size = new System.Drawing.Size(502, 24);
            this.filePanel.TabIndex = 3;
            // 
            // fileTextBox
            // 
            this.fileTextBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.fileTextBox.Location = new System.Drawing.Point(23, 0);
            this.fileTextBox.Name = "fileTextBox";
            this.fileTextBox.Size = new System.Drawing.Size(436, 20);
            this.fileTextBox.TabIndex = 1;
            // 
            // browseButton
            // 
            this.browseButton.Dock = System.Windows.Forms.DockStyle.Right;
            this.browseButton.Location = new System.Drawing.Point(459, 0);
            this.browseButton.Name = "browseButton";
            this.browseButton.Size = new System.Drawing.Size(43, 24);
            this.browseButton.TabIndex = 2;
            this.browseButton.Text = "...";
            this.browseButton.UseVisualStyleBackColor = true;
            this.browseButton.Click += new System.EventHandler(this.browseButton_Click);
            // 
            // fileLabel
            // 
            this.fileLabel.AutoSize = true;
            this.fileLabel.Dock = System.Windows.Forms.DockStyle.Left;
            this.fileLabel.Location = new System.Drawing.Point(0, 0);
            this.fileLabel.Name = "fileLabel";
            this.fileLabel.Size = new System.Drawing.Size(23, 13);
            this.fileLabel.TabIndex = 0;
            this.fileLabel.Text = "File";
            // 
            // structureGroupBox
            // 
            this.structureGroupBox.Controls.Add(this.structureTextBox);
            this.structureGroupBox.Dock = System.Windows.Forms.DockStyle.Left;
            this.structureGroupBox.Location = new System.Drawing.Point(5, 5);
            this.structureGroupBox.Name = "structureGroupBox";
            this.structureGroupBox.Size = new System.Drawing.Size(527, 358);
            this.structureGroupBox.TabIndex = 3;
            this.structureGroupBox.TabStop = false;
            this.structureGroupBox.Text = "Structure";
            // 
            // buttonPanel
            // 
            this.buttonPanel.Controls.Add(this.quitButton);
            this.buttonPanel.Controls.Add(this.runButton);
            this.buttonPanel.Dock = System.Windows.Forms.DockStyle.Top;
            this.buttonPanel.Location = new System.Drawing.Point(0, 368);
            this.buttonPanel.Name = "buttonPanel";
            this.buttonPanel.Size = new System.Drawing.Size(1041, 39);
            this.buttonPanel.TabIndex = 4;
            // 
            // quitButton
            // 
            this.quitButton.Location = new System.Drawing.Point(103, 8);
            this.quitButton.Name = "quitButton";
            this.quitButton.Size = new System.Drawing.Size(75, 23);
            this.quitButton.TabIndex = 1;
            this.quitButton.Text = "Quit";
            this.quitButton.UseVisualStyleBackColor = true;
            this.quitButton.Click += new System.EventHandler(this.quitButton_Click);
            // 
            // runButton
            // 
            this.runButton.Location = new System.Drawing.Point(22, 8);
            this.runButton.Name = "runButton";
            this.runButton.Size = new System.Drawing.Size(75, 23);
            this.runButton.TabIndex = 0;
            this.runButton.Text = "Run";
            this.runButton.UseVisualStyleBackColor = true;
            this.runButton.Click += new System.EventHandler(this.runButton_Click);
            // 
            // editPanel
            // 
            this.editPanel.Controls.Add(this.lineInput);
            this.editPanel.Controls.Add(this.applyFilterButton);
            this.editPanel.Controls.Add(this.filterTextBox);
            this.editPanel.Controls.Add(this.filterLabel);
            this.editPanel.Controls.Add(this.attachButton);
            this.editPanel.Controls.Add(this.positionLabel);
            this.editPanel.Controls.Add(this.copyAllButton);
            this.editPanel.Controls.Add(this.copyButton);
            this.editPanel.Controls.Add(this.nextButton);
            this.editPanel.Controls.Add(this.prevButton);
            this.editPanel.Dock = System.Windows.Forms.DockStyle.Right;
            this.editPanel.Location = new System.Drawing.Point(913, 407);
            this.editPanel.Name = "editPanel";
            this.editPanel.Size = new System.Drawing.Size(128, 297);
            this.editPanel.TabIndex = 5;
            // 
            // lineInput
            // 
            this.lineInput.Location = new System.Drawing.Point(6, 9);
            this.lineInput.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.lineInput.Name = "lineInput";
            this.lineInput.Size = new System.Drawing.Size(51, 20);
            this.lineInput.TabIndex = 11;
            this.lineInput.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.lineInput.ValueChanged += new System.EventHandler(this.lineInput_ValueChanged);
            // 
            // applyFilterButton
            // 
            this.applyFilterButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.applyFilterButton.Location = new System.Drawing.Point(6, 190);
            this.applyFilterButton.Name = "applyFilterButton";
            this.applyFilterButton.Size = new System.Drawing.Size(114, 23);
            this.applyFilterButton.TabIndex = 10;
            this.applyFilterButton.Text = "Apply Filter";
            this.applyFilterButton.UseVisualStyleBackColor = true;
            this.applyFilterButton.Click += new System.EventHandler(this.applyFilterButton_Click);
            // 
            // filterTextBox
            // 
            this.filterTextBox.Location = new System.Drawing.Point(6, 164);
            this.filterTextBox.Name = "filterTextBox";
            this.filterTextBox.Size = new System.Drawing.Size(111, 20);
            this.filterTextBox.TabIndex = 9;
            // 
            // filterLabel
            // 
            this.filterLabel.AutoSize = true;
            this.filterLabel.Location = new System.Drawing.Point(3, 148);
            this.filterLabel.Name = "filterLabel";
            this.filterLabel.Size = new System.Drawing.Size(64, 13);
            this.filterLabel.TabIndex = 8;
            this.filterLabel.Text = "Filter Tables";
            // 
            // attachButton
            // 
            this.attachButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.attachButton.Location = new System.Drawing.Point(6, 122);
            this.attachButton.Name = "attachButton";
            this.attachButton.Size = new System.Drawing.Size(114, 23);
            this.attachButton.TabIndex = 7;
            this.attachButton.Text = "Attach Description";
            this.attachButton.UseVisualStyleBackColor = true;
            // 
            // positionLabel
            // 
            this.positionLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.positionLabel.AutoSize = true;
            this.positionLabel.Location = new System.Drawing.Point(63, 16);
            this.positionLabel.Name = "positionLabel";
            this.positionLabel.Size = new System.Drawing.Size(25, 13);
            this.positionLabel.TabIndex = 6;
            this.positionLabel.Text = "of 1";
            this.positionLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // copyAllButton
            // 
            this.copyAllButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.copyAllButton.Location = new System.Drawing.Point(6, 93);
            this.copyAllButton.Name = "copyAllButton";
            this.copyAllButton.Size = new System.Drawing.Size(114, 23);
            this.copyAllButton.TabIndex = 5;
            this.copyAllButton.Text = "Copy All";
            this.copyAllButton.UseVisualStyleBackColor = true;
            // 
            // copyButton
            // 
            this.copyButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.copyButton.Location = new System.Drawing.Point(6, 64);
            this.copyButton.Name = "copyButton";
            this.copyButton.Size = new System.Drawing.Size(114, 23);
            this.copyButton.TabIndex = 4;
            this.copyButton.Text = "Copy";
            this.copyButton.UseVisualStyleBackColor = true;
            // 
            // nextButton
            // 
            this.nextButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.nextButton.Location = new System.Drawing.Point(66, 35);
            this.nextButton.Name = "nextButton";
            this.nextButton.Size = new System.Drawing.Size(54, 23);
            this.nextButton.TabIndex = 3;
            this.nextButton.Text = ">";
            this.nextButton.UseVisualStyleBackColor = true;
            this.nextButton.Click += new System.EventHandler(this.nextButton_Click);
            // 
            // prevButton
            // 
            this.prevButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.prevButton.Location = new System.Drawing.Point(6, 35);
            this.prevButton.Name = "prevButton";
            this.prevButton.Size = new System.Drawing.Size(54, 23);
            this.prevButton.TabIndex = 2;
            this.prevButton.Text = "<";
            this.prevButton.UseVisualStyleBackColor = true;
            this.prevButton.Click += new System.EventHandler(this.prevButton_Click);
            // 
            // resultGroupBox
            // 
            this.resultGroupBox.Controls.Add(this.resultTextBox);
            this.resultGroupBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.resultGroupBox.Location = new System.Drawing.Point(0, 407);
            this.resultGroupBox.Name = "resultGroupBox";
            this.resultGroupBox.Size = new System.Drawing.Size(913, 297);
            this.resultGroupBox.TabIndex = 6;
            this.resultGroupBox.TabStop = false;
            this.resultGroupBox.Text = "Results";
            // 
            // resultTextBox
            // 
            this.resultTextBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.resultTextBox.Location = new System.Drawing.Point(3, 16);
            this.resultTextBox.Name = "resultTextBox";
            this.resultTextBox.Size = new System.Drawing.Size(907, 278);
            this.resultTextBox.TabIndex = 0;
            this.resultTextBox.Text = "";
            // 
            // openFileDialog
            // 
            this.openFileDialog.FileName = "openFileDialog";
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1041, 727);
            this.Controls.Add(this.resultGroupBox);
            this.Controls.Add(this.editPanel);
            this.Controls.Add(this.buttonPanel);
            this.Controls.Add(this.inputPanel);
            this.Controls.Add(this.progressBar);
            this.Name = "MainForm";
            this.Text = "LADS Data Reader";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.inputPanel.ResumeLayout(false);
            this.contentsGroupBox.ResumeLayout(false);
            this.filePanel.ResumeLayout(false);
            this.filePanel.PerformLayout();
            this.structureGroupBox.ResumeLayout(false);
            this.buttonPanel.ResumeLayout(false);
            this.editPanel.ResumeLayout(false);
            this.editPanel.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.lineInput)).EndInit();
            this.resultGroupBox.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ProgressBar progressBar;
        private System.Windows.Forms.RichTextBox structureTextBox;
        private System.Windows.Forms.Panel inputPanel;
        private System.Windows.Forms.GroupBox contentsGroupBox;
        private System.Windows.Forms.RichTextBox contentTextBox;
        private System.Windows.Forms.Panel filePanel;
        private System.Windows.Forms.TextBox fileTextBox;
        private System.Windows.Forms.Button browseButton;
        private System.Windows.Forms.Label fileLabel;
        private System.Windows.Forms.GroupBox structureGroupBox;
        private System.Windows.Forms.Panel buttonPanel;
        private System.Windows.Forms.Button runButton;
        private System.Windows.Forms.Button quitButton;
        private System.Windows.Forms.Panel editPanel;
        private System.Windows.Forms.Label positionLabel;
        private System.Windows.Forms.Button copyAllButton;
        private System.Windows.Forms.Button copyButton;
        private System.Windows.Forms.Button nextButton;
        private System.Windows.Forms.Button prevButton;
        private System.Windows.Forms.Button attachButton;
        private System.Windows.Forms.GroupBox resultGroupBox;
        private System.Windows.Forms.RichTextBox resultTextBox;
        private System.Windows.Forms.OpenFileDialog openFileDialog;
        private System.Windows.Forms.Button applyFilterButton;
        private System.Windows.Forms.TextBox filterTextBox;
        private System.Windows.Forms.Label filterLabel;
        private System.Windows.Forms.NumericUpDown lineInput;
    }
}

