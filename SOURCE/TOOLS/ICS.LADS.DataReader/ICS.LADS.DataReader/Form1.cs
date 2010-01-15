using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Collections;

namespace ICS.LADS.DataReader
{
    public partial class MainForm : Form
    {
        private ArrayList _resultList;
        private ArrayList _initalList;

        private int _position;
        private int _totalToProcess;
        private int _currProgress;

        private delegate void UpdateProgress(int progress);
        private delegate void ToggleProgress(bool toggle);

        public MainForm()
        {
            InitializeComponent();

            this._resultList = new ArrayList();
            this._position = int.MinValue;

            this._totalToProcess = 0;
            this._currProgress = 0;
        }

        private void UpdateResult()
        {
            LineResult lineValue = null;

            if (this._position == int.MinValue || this._resultList == null || this._position-1 >= this._resultList.Count )
            {
                return;
            }

            lineValue = (LineResult)this._resultList[this._position-1];

            this.resultTextBox.Text = lineValue.ToString();
        }

        private void SetTotalLabel()
        {
            this.lineInput.Maximum = this._resultList.Count;
            this.positionLabel.Text = string.Format("of {0}", this._resultList.Count-1);
        }

        private void IncrementPosition()
        {
            int currPos = this._position;

            if (this._resultList != null && this._position == this._resultList.Count - 1)
            {
                this._position = 1;
            }
            else
            {
                this._position++;
            }

            if (this._position != currPos)
            {
                this.lineInput.Value = this._position;
                this.UpdateResult();
            }
        }

        private void DecrementPosition()
        {
            int currPos = this._position;

            if (this._position == 1)
            {
                if (this._resultList != null)
                {
                    this._position = this._resultList.Count-1;
                }
            }
            else
            {
                this._position--;
            }

            if (this._position != currPos)
            {
                this.lineInput.Value = this._position;
                this.UpdateResult();
            }
        }

        private void UpdateProgressBar(int progress)
        {
            if (this.InvokeRequired == true)
            {
                this.Invoke(new UpdateProgress(this.UpdateProgressBar), new object[] { progress });
            }
            else
            {
                this.progressBar.Value = progress;
                this.progressBar.Invalidate();
            }
        }

        private void SetProgressBarMax(int max)
        {
            if (this.InvokeRequired == true)
            {
                this.Invoke(new UpdateProgress(this.SetProgressBarMax), new object[] { max });
            }
            else
            {
                this.progressBar.Maximum = max;

                this.progressBar.Minimum = 0;
                this.progressBar.Value = 0;

                this.progressBar.Invalidate();
            }
        }

        private void ToggleProgressBarVisibility(bool toggle)
        {
            if (this.InvokeRequired == true)
            {
                this.Invoke(new ToggleProgress(this.ToggleProgressBarVisibility), new object[] { toggle });
            }
            else
            {
                this.progressBar.Visible = toggle;

                if (toggle == true)
                {
                    this.progressBar.Invalidate();
                }
                else
                {
                    this.Invalidate();
                }
            }
        }

        private void quitButton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void browseButton_Click(object sender, EventArgs e)
        {
            StreamReader reader = null;
            StringBuilder fileContents = null;

            string fileName = string.Empty;
            string line = string.Empty;

            try
            {
                if (this.openFileDialog.ShowDialog(this) == DialogResult.OK)
                {
                    fileName = this.openFileDialog.FileName;

                    if (fileName == null || fileName == string.Empty)
                    {
                        MessageBox.Show(this, "Invalid file selected.");
                    }
                    else
                    {
                        this.fileTextBox.Text = fileName;

                        reader = new StreamReader(fileName);
                        fileContents = new StringBuilder();

                        while ((line = reader.ReadLine()) != null )
                        {
                            fileContents.AppendLine(line);
                        }

                        this.contentTextBox.Text = fileContents.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
            finally
            {
                if ( reader != null )
                {
                    reader.Dispose();
                    reader = null;
                }
            }
        }

        private void runButton_Click(object sender, EventArgs e)
        {
            ResultBuilder results = null;

            try
            {
                if (this.structureTextBox.Text == null || this.structureTextBox.Text == string.Empty)
                {
                    MessageBox.Show(this, "No structure defined.");
                    return;
                }

                if (this.contentTextBox.Text == null || this.contentTextBox.Text == string.Empty)
                {
                    MessageBox.Show(this, "No contents defined.");
                    return;
                }

                this._totalToProcess = this.structureTextBox.Lines.Length;
                this._currProgress = 0;

                results = new ResultBuilder(this.structureTextBox.Lines, this.contentTextBox.Lines);
                results.UpdateProgress += new EventHandler(results_UpdateProgress);
                results.StructureComplete += new EventHandler(results_StructureComplete);

                this.ToggleProgressBarVisibility(true);
                this.SetProgressBarMax(this._totalToProcess);

                this._resultList = results.BuildResultList();
                this._initalList = (ArrayList)this._resultList.Clone();
                this._position = 1;

                this.ToggleProgressBarVisibility(false);
                this.SetTotalLabel();
                this.UpdateResult();
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void results_UpdateProgress(object sender, EventArgs e)
        {
            try
            {
                this._currProgress++;

                if (this._currProgress % 5 == 0)
                {
                    this.UpdateProgressBar(this._currProgress);
                }
            }             
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void results_StructureComplete(object sender, EventArgs e)
        {
            try
            {
                this._currProgress = 0;
                this._totalToProcess = this.contentTextBox.Lines.Length;

                this.SetProgressBarMax(this._totalToProcess);
                this.UpdateProgressBar(this._currProgress);
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void prevButton_Click(object sender, EventArgs e)
        {
            try
            {
                this.DecrementPosition();
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void nextButton_Click(object sender, EventArgs e)
        {
            try
            {
                this.IncrementPosition();
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void applyFilterButton_Click(object sender, EventArgs e)
        {
            string filter = this.filterTextBox.Text;

            try
            {
                if (filter == null || filter == string.Empty)
                {
                    this._resultList = (ArrayList)this._initalList.Clone();
                }
                else
                {

                    this._resultList.Clear();
                    filter = filter.ToUpper();

                    foreach (LineResult result in this._initalList)
                    {
                        if (result.Table != LadsTable.Empty && string.Compare(result.Table.Name, filter) == 0)
                        {
                            this._resultList.Add(result);
                        }
                    }
                }

                this._position = 1;

                this.SetTotalLabel();
                this.UpdateResult();
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
        }

        private void lineInput_ValueChanged(object sender, EventArgs e)
        {
            this._position = Convert.ToInt32(this.lineInput.Value);
            this.UpdateResult();
        }
    }
}