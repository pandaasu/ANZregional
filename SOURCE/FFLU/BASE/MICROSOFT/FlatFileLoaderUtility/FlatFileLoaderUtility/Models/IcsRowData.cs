using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Model for ICS row data is for "rt_xaction_data" API type. Also includes the column data list (parsed from data) and
    /// the list of errors for the row.
    /// </summary>
    public class IcsRowData
    {
        public int Row { get; set; }
        public string Data { get; set; }
        public int ErrorCount { get; set; }
        public List<IcsError> Errors { get; set; }
        public List<string> ColumnData { get; set; }

        public IcsRowData()
        {
            this.Errors = new List<IcsError>();
            this.ColumnData = new List<string>();
        }
    }
}