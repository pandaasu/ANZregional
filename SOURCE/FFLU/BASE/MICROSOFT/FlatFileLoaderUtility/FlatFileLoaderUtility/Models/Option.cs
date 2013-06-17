using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Option values used by ICS
    /// </summary>
    public static class Option
    {
        /// <summary>
        /// Loader option. A user must have access to this option for a given interface to upload data
        /// to that interface.
        /// </summary>
        public static readonly string Loader = "ICS_INT_LOADER";

        /// <summary>
        /// Process option. A user must have access to this option for a given interface to reprocess
        /// that interface.
        /// </summary>
        public static readonly string Process = "ICS_INT_PROCESS";

        /// <summary>
        /// Monitor option. A user must have this option to see the interface on the monitor list page.
        /// </summary>
        public static readonly string Monitor = "ICS_INT_MONITOR";
    }
}