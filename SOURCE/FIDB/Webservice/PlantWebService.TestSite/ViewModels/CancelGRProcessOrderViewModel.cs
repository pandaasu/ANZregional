using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PlantWebService.TestSite.ViewModels
{
    public class CancelGRProcessOrderViewModel
    {
        public CancelGRProcessOrderViewModel()
        {
            this.DisplayTypes = new List<SelectListItem>();
            this.DisplayTypes.Add(new SelectListItem() { Text = "Screen", Value = "1" });
            this.DisplayTypes.Add(new SelectListItem() { Text = "Download", Value = "2" });
            
        }

        public List<SelectListItem> DisplayTypes { get; set; }

        public int DisplayType { get; set; }
        public string SystemKey { get; set; }
        public string TransactionDate { get; set; }
        public string SenderName { get; set; }
        public string PalletCode { get; set; }
        public string UserID { get; set; }
    }
}