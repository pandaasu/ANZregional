using System;
using System.Collections.Generic;
using System.Linq;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Repositories
{
    public interface ILicsRepository
    {
        string GetProcessWorkingConst();
        string GetProcessWorkingErrorConst(); 
        string GetLoadCompletedConst();
    }
}
