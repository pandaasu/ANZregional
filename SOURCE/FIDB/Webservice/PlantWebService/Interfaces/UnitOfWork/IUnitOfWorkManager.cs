using System;
using PlantWebService.Data.UnitOfWork;
using System.Threading.Tasks;

namespace PlantWebService.Interfaces.UnitOfWork
{
    public partial interface IUnitOfWorkManager
    {
        IDataContext DataContext { get; set; }
        IUnitOfWork NewUnitOfWork(bool useTransaction);
    }
}
