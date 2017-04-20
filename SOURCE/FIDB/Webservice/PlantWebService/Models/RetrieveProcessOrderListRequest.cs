﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ServiceModel;

namespace PlantWebService.Models
{
    [MessageContract(IsWrapped = false)]
    public class RetrieveProcessOrderListRequest
    {
        [MessageBodyMember]
        public string SystemKey;

        [MessageBodyMember]
        public RetrieveMode Mode;
    }
}