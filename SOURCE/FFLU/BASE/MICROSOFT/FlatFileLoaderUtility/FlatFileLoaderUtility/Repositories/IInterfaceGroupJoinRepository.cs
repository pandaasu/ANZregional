using System;
using System.Collections.Generic;
using System.Linq;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Repositories
{
    public interface IInterfaceGroupJoinRepository
    {
        List<InterfaceGroupJoin> Get(string sorting);
    }
}
