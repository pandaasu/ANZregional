using System;
using System.Collections.Generic;
using System.Linq;
using System.ComponentModel.DataAnnotations;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// This represents an interface "job" (careful with that word, it apparently means something different in ICS terminology).
    /// Monitor objects are used to represent the rows in the monitor table, and the trace history table on the details view page.
    /// It is a model for the "rt_xaction_list" API type.
    /// </summary>
    public class Monitor
    {
        public int LicsId { get; set; }
        public int TraceId { get; set; }
        public string FileName { get; set; }
        public string UserCode { get; set; }
        public string InterfaceCode { get; set; }
        public string InterfaceName { get; set; }
        public string FileType { get; set; }
        public string CsvQualifier { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public string Status { get; set; }
        public int RecordCount { get; set; }
        public int RowInErrorCount { get; set; } // Rows with errors (multiple errors on one row counts only as one)
        public int RowErrorCount { get; set; } // Row errors (multiple errors on one row counts multiple times)
        public int InterfaceErrorCount { get; set; }
        public bool HasProcessAccess { get; set; }
        
        // This is working around a limitation in jTable whereby it cannot display time components on dates
        public string StartTimeFormatted
        {
            get
            {
                if (!this.StartTime.HasValue)
                    return string.Empty;
                else
                    return this.StartTime.Value.ToString("dd/MM/yyyy HH:mm:ss");
            }
        }
        public string EndTimeFormatted
        {
            get
            {
                if (!this.EndTime.HasValue)
                    return string.Empty;
                else
                    return this.EndTime.Value.ToString("dd/MM/yyyy HH:mm:ss");
            }
        }

        public void SetProcessAccess(bool hasProcessAccess)
        {
            this.HasProcessAccess = hasProcessAccess;
        }
    }
}