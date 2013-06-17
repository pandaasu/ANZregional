using System;
using System.Linq;
using System.ComponentModel.DataAnnotations;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Model for an interface is for "rt_interface_list" API type.
    /// </summary>
    public class Interface
    {
        [Key]
        public string InterfaceCode { get; set; }
        public string InterfaceName { get; set; }
        public string InterfaceTypeCode { get; set; }
        public string InterfaceThreadCode { get; set; }
        public string FileType { get; set; }
        public string CsvQualifier { get; set; }
    }
}