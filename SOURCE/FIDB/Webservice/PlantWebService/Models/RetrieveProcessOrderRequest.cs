using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ServiceModel;

namespace PlantWebService.Models
{
    [MessageContract(IsWrapped = true)]
    public class RetrieveProcessOrderRequest
    {
        [MessageBodyMember]
        public string SystemKey;

        [MessageBodyMember]
        public string ProcessOrder;
    }
}