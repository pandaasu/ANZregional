using System;
using System.Collections.Generic;
using System.Linq;
using System.ComponentModel.DataAnnotations;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// User model for "rt_user_list" API type.
    /// </summary>
    public class User
    {
        [Key]
        public string UserCode { get; set; }
        public string UserName { get; set; }

        public List<InterfaceOption> InterfaceOptions { get; set; }

        public User()
        {
            this.InterfaceOptions = new List<InterfaceOption>();
        }
    }
}