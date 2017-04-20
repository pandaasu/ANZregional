using PlantWebService.Interfaces;
using PlantWebService.Interfaces.UnitOfWork;
using System.Threading.Tasks;

namespace PlantWebService.Data.UnitOfWork
{
    public class UnitOfWorkManager : IUnitOfWorkManager
    {
        public IDataContext DataContext { get; set; }

        public UnitOfWorkManager(IDataContext dataContext)
        {
            this.DataContext = dataContext;
        }

        public IUnitOfWork NewUnitOfWork(bool useTransaction)
        {
            var unitOfWork = new UnitOfWork(useTransaction);
            
            this.DataContext.UnitOfWork = unitOfWork;

            return unitOfWork;
        }
    }
}
