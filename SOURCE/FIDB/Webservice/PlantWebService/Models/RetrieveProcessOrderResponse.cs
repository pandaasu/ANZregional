using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ServiceModel;

namespace PlantWebService.Models
{
    [MessageContract(IsWrapped = true)]
    public class RetrieveProcessOrderResponse
    {
        [MessageBodyMember(Namespace = "http://www.wbf.org/xml/B2MML-V0401")]
        public ProductionScheduleType ProductionSchedule { get; set; }
    }
}