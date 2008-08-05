using System;
using System.IO;
using System.Collections.Generic;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace ICS.LICS.UpgradeManager
{
    public enum ProjectType
    {
        Lics = 0,
        LicsApp = 1
    }

    public partial class UpgradeManagerForm : Form
    {
        private ArrayList _siteList;
        private ArrayList _licsFileList;
        private ArrayList _licsAppFileList;

        private IOManager _ioManager;
        private Site _activeSite;
        private DatabaseAccess _activeDbAccess;

        public UpgradeManagerForm()
        {
            this._siteList = new ArrayList();
            this._licsFileList = new ArrayList();
            this._licsAppFileList = new ArrayList();

            this._ioManager = new IOManager();
            this._activeSite = null;
            this._activeDbAccess = null;

            InitializeComponent();
        }

        protected override void OnLoad(EventArgs e)
        {
            try
            {
                this._siteList = this._ioManager.LoadSiteList();
                this.PopulateList(this._siteList, this.siteListBox);
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }

            base.OnLoad(e);
        }

        private void PopulateList(ArrayList list, ListBox listBox)
        {
            listBox.Items.Clear();
            listBox.Items.AddRange(list.ToArray());
        }

        private void LoadUpdateFiles(ArrayList list, ListBox listBox, ProjectType type)
        {
            string[] fileNames = null;

            string fileName = null;
            string directory = null;

            bool added = false;

            if (this.openFileDialog.ShowDialog(this) == DialogResult.OK)
            {
                if (this.openFileDialog.FileNames == null)
                {
                    fileNames = new string[] { this.openFileDialog.FileName };
                }
                else
                {
                    fileNames = this.openFileDialog.FileNames;
                }

                if (fileNames != null)
                {
                    foreach (string path in fileNames)
                    {
                        this._ioManager.ExtractPathInfo(path, out directory, out fileName);

                        if (list.BinarySearch(fileName) < 0)
                        {
                            list.Add(fileName);
                            list.Sort();

                            added = true;

                            if (type == ProjectType.Lics)
                            {
                                this.SetPathDetails(this.licsPathInput, directory);
                            }
                            else
                            {
                                this.SetPathDetails(this.licsAppPathInput, directory);
                            }
                        }
                    }

                    if (added == true)
                    {
                        this.PopulateList(list, listBox);
                    }
                }
            }
        }

        private void SetPathDetails(TextBox pathInput, string directory)
        {
            if (pathInput.Text == null || pathInput.Text == string.Empty)
            {
                pathInput.Text = directory;
            }
        }

        private void UpdateDatabaseAccess()
        {
            Site selectedSite = null;

            try
            {
                selectedSite = (this.siteListBox.SelectedItem as Site);

                if (selectedSite != null)
                {
                    if (testCheck.Checked == true)
                    {
                        this._activeDbAccess = selectedSite.TestAccess;
                    }
                    else
                    {
                        this._activeDbAccess = selectedSite.ProdAccess;
                    }

                    this.SetDatabaseAccess(this._activeDbAccess);
                }

                this._activeSite = selectedSite;
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void SetDatabaseAccess(DatabaseAccess access)
        {
            this.passwordInput.Text = access.Password;
            this.databaseInput.Text = access.Database;
        }

        private void RemoveListItems(ArrayList list, ListBox listBox)
        {
            ArrayList selectedIndices = null;
            string fileName = string.Empty;

            if (listBox.SelectedIndices == null)
            {
                selectedIndices = new ArrayList();
                selectedIndices.Add(listBox.SelectedIndex);
            }
            else
            {
                selectedIndices = new ArrayList(listBox.SelectedIndices);
                selectedIndices.Sort();
                selectedIndices.Reverse();
            }

            foreach (int index in selectedIndices)
            {
                fileName = (string)listBox.Items[index];

                list.Remove(fileName);
                listBox.Items.RemoveAt(index); 
            }
        }

        private void GenerateUpgradePackage(ProjectType type, ArrayList list, string sourcePath)
        {
            string installPath = this.pathToGenerateInput.Text;

            installPath = this._ioManager.ValidatePath(installPath);
            sourcePath = this._ioManager.ValidatePath(sourcePath);

            this._ioManager.GenerateScript(type, list, installPath, sourcePath, this._activeDbAccess);
        }

        private void generateButton_Click(object sender, EventArgs e)
        {
            try
            {
                this.UpdateDatabaseAccess();

                if (this._activeSite == null || this._activeDbAccess == null)
                {
                    MessageBox.Show(this, "Site not selected or invalid.");
                    return;
                }                               

                if (this._licsFileList.Count > 0)
                {
                    this.GenerateUpgradePackage(ProjectType.Lics, this._licsFileList, this.licsPathInput.Text);
                }

                if (this._licsAppFileList.Count > 0)
                {
                    this.GenerateUpgradePackage(ProjectType.LicsApp, this._licsAppFileList, this.licsAppPathInput.Text);
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

        private void browseButton_Click(object sender, EventArgs e)
        {
            try
            {
                if ( this.folderBrowserDialog.ShowDialog(this) == DialogResult.OK )
                {
                    this.pathToGenerateInput.Text = this.folderBrowserDialog.SelectedPath;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void addLicsFileButton_Click(object sender, EventArgs e)
        {
            try
            {
                this.LoadUpdateFiles(this._licsFileList, this.licsFileListBox, ProjectType.Lics);
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void removeLicsFileButton_Click(object sender, EventArgs e)
        {
            try
            {
                if (this.licsFileListBox.SelectedIndex < 0)
                {
                    MessageBox.Show("Please select a LICS item to remove.");
                    return;
                }

                this.RemoveListItems(this._licsFileList, this.licsFileListBox);               
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void addLicsAppFileButton_Click(object sender, EventArgs e)
        {
            try
            {
                this.LoadUpdateFiles(this._licsAppFileList, this.licsAppFileListBox, ProjectType.LicsApp);
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void removeLicsAppFileButton_Click(object sender, EventArgs e)
        {
            try
            {
                if (this.licsAppFileListBox.SelectedIndex < 0)
                {
                    MessageBox.Show("Please select a LICS_APP item to remove.");
                    return;
                }

                this.RemoveListItems(this._licsAppFileList, this.licsAppFileListBox);
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void siteListBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.UpdateDatabaseAccess();
        }

        private void radioButton_CheckedChanged(object sender, EventArgs e)
        {
            this.UpdateDatabaseAccess();
        }
    }
}