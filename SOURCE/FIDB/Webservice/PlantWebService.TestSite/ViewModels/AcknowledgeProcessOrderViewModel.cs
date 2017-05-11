using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PlantWebService.TestSite.ViewModels
{
    public class AcknowledgeProcessOrderViewModel
    {
        public AcknowledgeProcessOrderViewModel()
        {
            this.DisplayTypes = new List<SelectListItem>();
            this.DisplayTypes.Add(new SelectListItem() { Text = "Screen", Value = "1" });
            this.DisplayTypes.Add(new SelectListItem() { Text = "Download", Value = "2" });

            this.ProcessedFlags = new List<SelectListItem>();
            this.ProcessedFlags.Add(new SelectListItem() { Text = "Yes", Value = "Y" });
            this.ProcessedFlags.Add(new SelectListItem() { Text = "No", Value = "N" });
        }

        public List<SelectListItem> DisplayTypes { get; set; }
        public List<SelectListItem> ProcessedFlags { get; set; }

        public int DisplayType { get; set; }
        public string SystemKey { get; set; }
        public string Message { get; set; }
        public string Processed { get; set; }
        public string SenderName { get; set; }
        public string ProcessOrder { get; set; }
    }
}