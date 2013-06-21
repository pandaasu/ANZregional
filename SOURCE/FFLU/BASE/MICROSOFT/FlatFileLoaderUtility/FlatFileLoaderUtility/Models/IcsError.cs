using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Model for ICS error is for "rt_xaction_error" API type, but it also includes position and length
    /// that are parsed out of the json returned in the message. Used for highlighting column (for CSV type) or
    /// characters (fixed width file type) where the error occurred.
    /// </summary>
    public class IcsError
    {
        public int Sequence { get; set; }
        public string Message { get; set; }
        public string Label { get; set; }
        public string Value { get; set; }
        public int Position { get; set; }
        public int Length { get; set; }
    }
}