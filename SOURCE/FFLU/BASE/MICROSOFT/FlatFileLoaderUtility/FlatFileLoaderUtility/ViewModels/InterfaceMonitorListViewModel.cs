using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.ComponentModel.DataAnnotations;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.ViewModels
{
    public class InterfaceMonitorListViewModel
    {
        public IEnumerable<SelectListItem> InterfaceGroups { get; set; }
        public IEnumerable<SelectListItem> Interfaces { get; set; }
        public IEnumerable<SelectListItem> IcsStatuses { get; set; }
        public IEnumerable<SelectListItem> InterfaceTypes { get; set; }
        
        public InterfaceMonitorListViewModel()
        {
        }
    }
}