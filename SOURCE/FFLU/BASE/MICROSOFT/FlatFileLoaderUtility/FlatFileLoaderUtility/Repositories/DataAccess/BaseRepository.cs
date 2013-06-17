using System;
using System.Linq;

namespace FlatFileLoaderUtility.Repositories.DataAccess
{
    public class BaseRepository
    {
        protected RepositoryContainer Container { get; private set; }

        public BaseRepository(RepositoryContainer container)
        {
            this.Container = container;
        }
    }
}