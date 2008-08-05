namespace DirectoryReader
{
    partial class DirectoryReaderForm
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
            this.pathInput = new System.Windows.Forms.TextBox();
            this.browseButton = new System.Windows.Forms.Button();
            this.fileTextBox = new System.Windows.Forms.RichTextBox();
            this.viewButton = new System.Windows.Forms.Button();
            this.exitButton = new System.Windows.Forms.Button();
            this.buttonPanel = new System.Windows.Forms.Panel();
            this.pathLabel = new System.Windows.Forms.Label();
            this.fileLabel = new System.Windows.Forms.Label();
            this.folderBrowserDialog = new System.Windows.Forms.FolderBrowserDialog();
            this.patternLabel = new System.Windows.Forms.Label();
            this.patternInput = new System.Windows.Forms.TextBox();
            this.buttonPanel.SuspendLayout();
            this.SuspendLayout();
            // 
            // pathInput
            // 
            this.pathInput.Location = new System.Drawing.Point(98, 12);
            this.pathInput.Name = "pathInput";
            this.pathInput.Size = new System.Drawing.Size(240, 20);
            this.pathInput.TabIndex = 0;
            // 
            // browseButton
            // 
            this.browseButton.Location = new System.Drawing.Point(344, 9);
            this.browseButton.Name = "browseButton";
            this.browseButton.Size = new System.Drawing.Size(27, 23);
            this.browseButton.TabIndex = 1;
            this.browseButton.Text = "...";
            this.browseButton.UseVisualStyleBackColor = true;
            this.browseButton.Click += new System.EventHandler(this.browseButton_Click);
            // 
            // fileTextBox
            // 
            this.fileTextBox.Location = new System.Drawing.Point(98, 64);
            this.fileTextBox.Name = "fileTextBox";
            this.fileTextBox.Size = new System.Drawing.Size(428, 258);
            this.fileTextBox.TabIndex = 2;
            this.fileTextBox.Text = "";
            // 
            // viewButton
            // 
            this.viewButton.Location = new System.Drawing.Point(181, 8);
            this.viewButton.Name = "viewButton";
            this.viewButton.Size = new System.Drawing.Size(75, 23);
            this.viewButton.TabIndex = 3;
            this.viewButton.Text = "View";
            this.viewButton.UseVisualStyleBackColor = true;
            this.viewButton.Click += new System.EventHandler(this.viewButton_Click);
            // 
            // exitButton
            // 
            this.exitButton.Location = new System.Drawing.Point(279, 8);
            this.exitButton.Name = "exitButton";
            this.exitButton.Size = new System.Drawing.Size(75, 23);
            this.exitButton.TabIndex = 4;
            this.exitButton.Text = "Exit";
            this.exitButton.UseVisualStyleBackColor = true;
            this.exitButton.Click += new System.EventHandler(this.exitButton_Click);
            // 
            // buttonPanel
            // 
            this.buttonPanel.Controls.Add(this.viewButton);
            this.buttonPanel.Controls.Add(this.exitButton);
            this.buttonPanel.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.buttonPanel.Location = new System.Drawing.Point(0, 328);
            this.buttonPanel.Name = "buttonPanel";
            this.buttonPanel.Size = new System.Drawing.Size(535, 38);
            this.buttonPanel.TabIndex = 5;
            // 
            // pathLabel
            // 
            this.pathLabel.AutoSize = true;
            this.pathLabel.Location = new System.Drawing.Point(16, 15);
            this.pathLabel.Name = "pathLabel";
            this.pathLabel.Size = new System.Drawing.Size(32, 13);
            this.pathLabel.TabIndex = 6;
            this.pathLabel.Text = "Path:";
            // 
            // fileLabel
            // 
            this.fileLabel.AutoSize = true;
            this.fileLabel.Location = new System.Drawing.Point(16, 67);
            this.fileLabel.Name = "fileLabel";
            this.fileLabel.Size = new System.Drawing.Size(31, 13);
            this.fileLabel.TabIndex = 7;
            this.fileLabel.Text = "Files:";
            // 
            // patternLabel
            // 
            this.patternLabel.AutoSize = true;
            this.patternLabel.Location = new System.Drawing.Point(16, 41);
            this.patternLabel.Name = "patternLabel";
            this.patternLabel.Size = new System.Drawing.Size(81, 13);
            this.patternLabel.TabIndex = 9;
            this.patternLabel.Text = "Search Pattern:";
            // 
            // patternInput
            // 
            this.patternInput.Location = new System.Drawing.Point(98, 38);
            this.patternInput.Name = "patternInput";
            this.patternInput.Size = new System.Drawing.Size(118, 20);
            this.patternInput.TabIndex = 8;
            this.patternInput.Text = "*.*";
            // 
            // DirectoryReaderForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(535, 366);
            this.Controls.Add(this.patternLabel);
            this.Controls.Add(this.patternInput);
            this.Controls.Add(this.fileLabel);
            this.Controls.Add(this.pathLabel);
            this.Controls.Add(this.buttonPanel);
            this.Controls.Add(this.fileTextBox);
            this.Controls.Add(this.browseButton);
            this.Controls.Add(this.pathInput);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "DirectoryReaderForm";
            this.Text = "Directory Reader";
            this.buttonPanel.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox pathInput;
        private System.Windows.Forms.Button browseButton;
        private System.Windows.Forms.RichTextBox fileTextBox;
        private System.Windows.Forms.Button viewButton;
        private System.Windows.Forms.Button exitButton;
        private System.Windows.Forms.Panel buttonPanel;
        private System.Windows.Forms.Label pathLabel;
        private System.Windows.Forms.Label fileLabel;
        private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog;
        private System.Windows.Forms.Label patternLabel;
        private System.Windows.Forms.TextBox patternInput;
    }
}

