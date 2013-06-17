using System;
using System.Collections.Generic;
using System.Linq;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Repositories
{
    public interface IConnectionRepository
    {
        List<Connection> Get(string sorting);
        Connection Add(Connection item);
        void Update(Connection item);
    }
}
