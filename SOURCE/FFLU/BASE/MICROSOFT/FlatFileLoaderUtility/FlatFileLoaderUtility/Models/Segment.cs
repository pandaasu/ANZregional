using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Represents a segment of file data uploaded from the user's browser
    /// </summary>
    public class Segment
    {
        public bool IsProcessed { get; set; }
        public string Data { get; set; }
        public int Lines { get; set; }

        public Segment(string data)
        {
            this.Data = data;
        }
    }
}