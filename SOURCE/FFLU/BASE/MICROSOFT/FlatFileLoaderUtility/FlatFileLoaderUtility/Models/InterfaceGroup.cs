using System;
using System.Linq;
using System.ComponentModel.DataAnnotations;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Model for an interface group is for "rt_interface_group_list" API type.
    /// </summary>
    public class InterfaceGroup
    {
        [Key]
        public string InterfaceGroupCode { get; set; }
        public string InterfaceGroupName { get; set; }
    }
}