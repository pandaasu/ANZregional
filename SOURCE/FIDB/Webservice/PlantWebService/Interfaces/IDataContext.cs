using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using PlantWebService.Interfaces.UnitOfWork;

namespace PlantWebService.Interfaces
{
    public interface IDataContext
    {
        IUnitOfWork UnitOfWork { get; set; }
    }
}