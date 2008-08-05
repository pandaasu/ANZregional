using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.IO;
using System.Windows.Forms;

namespace DirectoryReader
{
    public partial class DirectoryReaderForm : Form
    {
        public DirectoryReaderForm()
        {
            InitializeComponent();
        }

        private void browseButton_Click(object sender, EventArgs e)
        {
            try
            {
                if (this.folderBrowserDialog.ShowDialog(this) == DialogResult.OK)
                {
                    this.pathInput.Text = this.folderBrowserDialog.SelectedPath;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void viewButton_Click(object sender, EventArgs e)
        {
            string[] fileList = null;
            string directory = this.pathInput.Text;
            string pattern = this.patternInput.Text;

            StringBuilder result = new StringBuilder();

            try
            {
                if (Directory.Exists(directory) == false)
                {
                    MessageBox.Show(this, "Directory does not exist!");
                    return;
                }

                this.fileTextBox.Clear();

                fileList = Directory.GetFiles(directory, pattern, SearchOption.TopDirectoryOnly);

                if (fileList == null || fileList.Length == 0)
                {
                    MessageBox.Show(this, "No files found.");
                }
                else
                {
                    Array.Sort(fileList);

                    foreach (string file in fileList)
                    {
                        result.Append(Path.GetFileName(file) + "\n");
                    }

                    this.fileTextBox.Text = result.ToString();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void exitButton_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}