using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ServiceModel;

namespace PlantWebService.Models
{
    [MessageContract(IsWrapped = false)]
    public class CreateBlendRequest
    {
        [MessageBodyMember(Namespace = "http://www.wbf.org/xml/B2MML-V0401")]
        public ProductionPerformanceType ProductionPerformance;

        [MessageBodyMember]
        public string SystemKey;
    }
}