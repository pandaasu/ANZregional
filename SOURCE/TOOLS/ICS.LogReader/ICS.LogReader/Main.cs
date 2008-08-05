using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Threading;

namespace ICS.LogReader
{
    public partial class Main : Form
    {
        #region Private Variables

        private int _fileLineCount;
        private int _filterLineCount;

        private int _totalItems;
        private decimal _averageTime;
        private ICSProcess _longestProcess;

        #endregion

        #region Private Delegates

        private delegate void UpdateProgress(int progress);
        private delegate void ToggleProgress(bool toggle);

        #endregion

        #region Private Constants

        private const int PROGRESS_INC = 5;

        #endregion

        #region Constructor

        public Main()
        {
            InitializeComponent();

            this._fileLineCount = 0;
            this._filterLineCount = 0;

            this._averageTime = decimal.Zero;
        }

        #endregion

        #region Private Methods

        private void LoadFile()
        {
            StringBuilder fileContents = new StringBuilder();
            StreamReader sr = null;

            string path = this.pathLabel.Text;
            string line = null;

            try
            {
                this.ToggleLoadPanel(true);

                sr = new StreamReader(path);

                this._fileLineCount = 0;
                this._filterLineCount = 0;

                while ((line = sr.ReadLine()) != null)
                {
                    if (this.showFileContentsCheckBox.Checked == true)
                    {
                        fileContents.AppendLine(line);
                    }

                    this._fileLineCount++;
                }

                sr.Close();

                if (this.showFileContentsCheckBox.Checked == true)
                {
                    this.outputBox.Text = fileContents.ToString();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
            finally
            {
                if (sr != null)
                {
                    sr.Dispose();
                    sr = null;
                }

                this.ToggleLoadPanel(false);
            }
        }

        private void SearchFile()
        {
            StringBuilder fileOutput = new StringBuilder();
            StreamReader sr = null;

            string path = this.pathLabel.Text;
            string checkString = this.containTextBox.Text;
            string line = null;

            int count = 0;

            try
            {
                this.ToggleProgressBarVisibility(true);
                this.SetProgressBarMax(this._fileLineCount);

                sr = new StreamReader(path);

                if (this.matchCaseCheckBox.Checked == false)
                {
                    checkString = checkString.ToLower();
                }

                while ((line = sr.ReadLine()) != null)
                {
                    if (this.matchCaseCheckBox.Checked == false)
                    {
                        line = line.ToLower();
                    }

                    if (Utilities.ContainsText(line, checkString) == true)
                    {
                        fileOutput.AppendLine(line);
                        this._filterLineCount++;
                    }

                    count++;

                    if (count % PROGRESS_INC == 0)
                    {
                        this.UpdateProgressBar(PROGRESS_INC);
                    }
                }

                sr.Close();

                this.outputBox.Text = fileOutput.ToString();
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
            finally
            {
                if (sr != null)
                {
                    sr.Dispose();
                    sr = null;
                }

                this.ToggleProgressBarVisibility(false);
            }
        }
        
        private void CalculateMaxTime()
        {
            DateTime currDate = DateTime.MinValue;
            DateTime prevDate = DateTime.MinValue;

            ICSProcess currentProcess = null;
            ArrayList processList = null;

            int processId = 0;
            int totalTime = 0;
            int count = 0;

            int hourToCheck = -1;

            try
            {
                processList = new ArrayList();

                if (Utilities.ArrayIsEmpty(this.outputBox.Lines) == true)
                {
                    MessageBox.Show(this, "No data to calculate with!");
                    return;
                }

                if (this.withinHourCheck.Checked == true)
                {
                    hourToCheck = (int)this.withinHourInput.Value;
                }

                processList = new ArrayList();

                this.ToggleProgressBarVisibility(true);
                this.SetProgressBarMax(this.outputBox.Lines.Length);

                foreach (string line in this.outputBox.Lines)
                {
                    if (Utilities.StringIsEmpty(line) == true)
                    {
                        continue;
                    }

                    processId = Utilities.GetProcessId(line);
                    currDate = Utilities.GetDate(line);

                    if (processId == -1 || currDate == DateTime.MinValue)
                    {
                        return;
                    }

                    if (hourToCheck == -1 || currDate.Hour == hourToCheck
                        || (hourToCheck != -1 && prevDate != null && prevDate.Hour == hourToCheck))
                    {
                        if (currentProcess == null || processId != currentProcess.ProcessId)
                        {
                            if (currentProcess != null)
                            {
                                currentProcess.EndDate = prevDate;
                                currentProcess.CalculateTotalTime();

                                totalTime += currentProcess.TotalTime;

                                processList.Add(currentProcess);
                            }

                            if (hourToCheck != -1 && currDate.Hour != hourToCheck)
                            {
                                currentProcess = null;
                            }
                            else
                            {
                                currentProcess = new ICSProcess(processId, currDate);
                            }
                        }
                    }

                    prevDate = currDate;

                    count++;

                    if (count % PROGRESS_INC == 0)
                    {
                        this.UpdateProgressBar(PROGRESS_INC);
                    }
                }

                if (currentProcess != null)
                {
                    currentProcess.EndDate = currDate;
                    currentProcess.CalculateTotalTime();

                    totalTime += currentProcess.TotalTime;

                    processList.Add(currentProcess);
                }

                processList.Sort();
                processList.Reverse();

                if (processList.Count > 0)
                {
                    this._longestProcess = (processList[0] as ICSProcess);
                    this._averageTime = Convert.ToDecimal(((float)totalTime / processList.Count));
                    this._totalItems = processList.Count;
                }
                else
                {
                    this._longestProcess = ICSProcess.Empty;
                    this._averageTime = decimal.Zero;
                    this._totalItems = 0;
                }

                this.ShowLongestProcess();
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.ToString());
            }
            finally
            {
                this.ToggleProgressBarVisibility(false);
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
                this.progressBar.Value += progress;
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

        private void ToggleLoadPanel(bool toggle)
        {
            if (this.InvokeRequired == true)
            {
                this.Invoke(new ToggleProgress(this.ToggleLoadPanel), new object[] { toggle });
            }
            else
            {
                this.loadLabel.Visible = toggle;

                if (toggle == true)
                {
                    this.loadLabel.Refresh();
                }
                else
                {
                    this.Invalidate();
                }
            }
        }

        private void ShowLongestProcess()
        {
            if (this.InvokeRequired == true)
            {
                this.Invoke(new ThreadStart(ShowLongestProcess));
            }
            else
            {
                this.maxTimeDetailLabel.Text = string.Format("Time = {0}sec | Process Id = {1} | Average = {2}sec | Total = {3}"
                    , this._longestProcess.TotalTime
                    , this._longestProcess.ProcessId
                    , this._averageTime
                    , this._totalItems);
            }
        }

        #endregion

        #region Private Events

        private void openButton_Click(object sender, EventArgs e)
        {
            string path = this.pathLabel.Text;

            if (this.openFileDialog.ShowDialog(this) == DialogResult.OK)
            {
                this.outputBox.Clear();

                path = this.openFileDialog.FileName;
                this.pathLabel.Text = path;

                if (Utilities.ValidateFile(path) == true)
                {
                    this.Invoke(new ThreadStart(this.LoadFile));
                }
            }
        }

        private void filterButton_Click(object sender, EventArgs e)
        {
            if (this.containsCheckBox.Checked == true)
            {
                this.Invoke(new ThreadStart(this.SearchFile));
            }           
        }

        private void calculateMaxTime_Click(object sender, EventArgs e)
        {
            this.CalculateMaxTime();
        }

        private void exitButton_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show(this, "Are you sure you want to quit?", "Quit", MessageBoxButtons.YesNo) == DialogResult.Yes)
            {
                this.Close();
            }
        }

        #endregion
    }
}