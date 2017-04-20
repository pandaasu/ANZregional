using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PlantWebService.Models
{
    public enum Result
    {
        Success = 0,
        Failure = 1,
        Error = 2,
        Timeout = 3
    }
}