using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Web;
using PlantWebService.Models;
using PlantWebService.Classes;
using System.Text;
using PlantWebService.Interfaces;
using PlantWebService.Interfaces.UnitOfWork;
using PlantWebService.Interfaces.Repositories;
using PlantWebService.Data.UnitOfWork;

namespace PlantWebService.Data.Repositories
{
    public class BaseRepository : IBaseRepository
    {
        protected IDataContext DataContext { get; private set; }

        #region constructor

        public BaseRepository(IDataContext dataContext)
        {
            this.DataContext = dataContext;
        }

        #endregion
    }
}