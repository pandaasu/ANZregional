using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ServiceModel;

namespace PlantWebService.Models
{
    [MessageContract(IsWrapped = false)]
    public class AcknowledgeProcessOrderRequest
    {
        [MessageBodyMember]
        public string SystemKey;

        [MessageBodyMember]
        public string ProcessOrder;

        [MessageBodyMember]
        public bool Processed;

        [MessageBodyMember]
        public string Message;
    }
}