using System;
using System.Collections.Generic;
using System.Web.Caching;
using System.Linq;
using System.Web;
using System.Threading;
using FlatFileLoaderUtility.Models.Shared;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Model for an ics status if for "rt_xaction_status_list" API type.
    /// </summary>
    public class IcsStatus
    {
        public string IcsStatusCode { get; set; }
        public string IcsStatusName { get; set; }
    }
}