using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PlantWebService.TestSite.ViewModels
{
    public class RetrieveMarsCalendarViewModel
    {
        public RetrieveMarsCalendarViewModel()
        {
            this.Modes = new List<SelectListItem>();
            this.Modes.Add(new SelectListItem() { Text = "Delta", Value = "1" });
            this.Modes.Add(new SelectListItem() { Text = "Full", Value = "2" });
            this.Modes.Add(new SelectListItem() { Text = "Reset", Value = "3" });

            this.DisplayTypes = new List<SelectListItem>();
            this.DisplayTypes.Add(new SelectListItem() { Text = "Screen", Value = "1" });
            this.DisplayTypes.Add(new SelectListItem() { Text = "Download", Value = "2" });
        }

        public List<SelectListItem> Modes { get; set; }
        public List<SelectListItem> DisplayTypes { get; set; }

        public DateTime? Date { get; set; }
        public int HistoryYears { get; set; }
        public int Mode { get; set; }
        public string SystemKey { get; set; }
    }
}