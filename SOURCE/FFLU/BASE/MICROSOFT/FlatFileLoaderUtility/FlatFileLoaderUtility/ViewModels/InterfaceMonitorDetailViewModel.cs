using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.ComponentModel.DataAnnotations;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.ViewModels
{
    public class InterfaceMonitorDetailViewModel
    {
        public Monitor Record { get; set; }
        public List<Monitor> Monitors { get; set; }
        public List<IcsError> InterfaceErrors { get; set; }
        public int ColumnCount { get; set; }
        public bool HasProcessAccess { get; set; }
        
        public InterfaceMonitorDetailViewModel()
        {
            this.Monitors = new List<Monitor>();
            this.InterfaceErrors = new List<IcsError>();
        }
    }
}