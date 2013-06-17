using System;
using System.Linq;
using System.ComponentModel.DataAnnotations;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Maps user's options to interfaces. Model of the "rt_user_interface_options" API type.
    /// </summary>
    public class InterfaceOption
    {
        public string UserCode { get; set; }
        public string InterfaceCode { get; set; }
        public string OptionCode { get; set; }
    }
}