using System;
using System.Collections.Generic;
using System.Linq;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Repositories
{
    public interface IInterfaceRepository
    {
        List<Interface> Get(string sorting);
        void Reprocess(int licsId, string interfaceCode);
    }
}
