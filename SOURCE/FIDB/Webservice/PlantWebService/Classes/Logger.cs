using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using log4net;

namespace PlantWebService.Classes
{
    public static class Logger
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public static ILog Log
        {
            get
            {
                return log;
            }
        }
    }
}