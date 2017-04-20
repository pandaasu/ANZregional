using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using PlantWebService.Interfaces;
using PlantWebService.Interfaces.UnitOfWork;
using PlantWebService.Data.UnitOfWork;

namespace PlantWebService.Data
{
    public class DataContext : IDataContext
    {
        public IUnitOfWork UnitOfWork { get; set; }
    }
}