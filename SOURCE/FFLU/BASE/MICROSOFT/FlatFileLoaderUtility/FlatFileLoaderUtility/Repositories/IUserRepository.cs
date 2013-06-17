using System;
using System.Collections.Generic;
using System.Linq;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Repositories
{
    public interface IUserRepository
    {
        User Get();
    }
}
