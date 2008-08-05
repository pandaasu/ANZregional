using System;
using System.Collections.Generic;
using System.Text;

namespace ICS.LogReader
{
    public enum ProcessSortType
    {
        None = -1,
        TotalTime = 0,
        Process = 1
    }

    class ICSProcess : IComparable
    {
        #region Private Variables

        private int _processId;
        private int _totalTime;

        private DateTime _startDate;
        private DateTime _endDate;

        private ProcessSortType _sortType;

        #endregion

        #region Private Statis Variables

        private static ICSProcess _empty;

        #endregion

        #region Constructor

        public ICSProcess(int processId, DateTime startDate)
        {
            this._processId = processId;
            this._startDate = startDate;

            this._totalTime = 0;
            this._sortType = ProcessSortType.TotalTime;
        }

        #endregion

        #region Public Static Properties

        public static ICSProcess Empty
        {
            get
            {
                if (_empty == null)
                {
                    _empty = new ICSProcess(0, DateTime.MinValue);
                    _empty.EndDate = DateTime.MinValue;

                    _empty.CalculateTotalTime();
                }

                return _empty;
            }
        }

        #endregion

        #region Public Properties

        public int ProcessId
        {
            get
            {
                return this._processId;
            }
        }

        public int TotalTime
        {
            get
            {
                return this._totalTime;
            }
        }

        public DateTime StartDate
        {
            get
            {
                return this._startDate;
            }
        }

        public DateTime EndDate
        {
            get
            {
                return this._endDate;
            }
            set
            {
                this._endDate = value;
            }
        }

        public ProcessSortType SortType
        {
            get
            {
                return this._sortType;
            }
            set
            {
                this._sortType = value;
            }
        }

        #endregion

        #region Public Methods

        public void CalculateTotalTime()
        {
            TimeSpan span = this._endDate - this._startDate;
            this._totalTime = Convert.ToInt32(span.TotalSeconds);
        }

        #endregion

        #region IComparable Members

        public int CompareTo(object obj)
        {
            int result = -1;

            if (obj is ICSProcess)
            {
                if (this.SortType == ProcessSortType.Process)
                {
                    result = this._processId.CompareTo((obj as ICSProcess).ProcessId);
                }
                else if (this.SortType == ProcessSortType.TotalTime)
                {
                    result = this._totalTime.CompareTo((obj as ICSProcess).TotalTime);
                }
            }
            else if (obj is int)
            {
                result = this._processId.CompareTo((int)obj);
            }

            return result;
        }

        #endregion
    }
}
