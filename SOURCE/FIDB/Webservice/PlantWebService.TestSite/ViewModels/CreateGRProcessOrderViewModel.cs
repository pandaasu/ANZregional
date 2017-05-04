using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PlantWebService.TestSite.ViewModels
{
    public class CreateGRProcessOrderViewModel
    {
        public CreateGRProcessOrderViewModel()
        {
            this.DisplayTypes = new List<SelectListItem>();
            this.DisplayTypes.Add(new SelectListItem() { Text = "Screen", Value = "1" });
            this.DisplayTypes.Add(new SelectListItem() { Text = "Download", Value = "2" });
            
        }

        public List<SelectListItem> DisplayTypes { get; set; }

        public int DisplayType { get; set; }
        public string SystemKey { get; set; }
        public string TransactionDate { get; set; }
        public string PlantCode { get; set; }
        public string SenderName { get; set; }
        public string BatchCode { get; set; }
        public string ProcessOrder { get; set; }
        public string BatchStatus { get; set; } //i_dispn_code
        public string UseByDate { get; set; }
        public string MaterialCode { get; set; }
        public string PalletCode { get; set; }
        public decimal Quantity { get; set; }
        public string FullPallet { get; set; } // Y or N
        public string UserID { get; set; }
        public string LastGRFlag { get; set; } // Y or N
        public string PalletType { get; set; }
        public string StartDate { get; set; }
        public string EndDate { get; set; }
        
        
    }
}