using System;
using System.Linq;
using System.ComponentModel.DataAnnotations;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Maps interfaces to interface groups. This exists because interfaces can belong to multiple interface groups.
    /// Used for "rt_interface_group_join" API type.
    /// </summary>
    public class InterfaceGroupJoin
    {
        public string InterfaceCode { get; set; }
        public string InterfaceGroupCode { get; set; }
    }
}