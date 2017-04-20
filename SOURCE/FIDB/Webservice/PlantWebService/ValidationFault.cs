using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.Threading;

namespace PlantWebService
{
    class RequestValidationFault : FaultException
    {
        public RequestValidationFault(string validationErrorDetail)
            : base(new FaultReason(new FaultReasonText(validationErrorDetail, Thread.CurrentThread.CurrentUICulture)),
                  FaultCode.CreateSenderFaultCode("SchemaValidationFault", "http://PlantWebService"))
        {
        }
    }

    class ReplyValidationFault : FaultException
    {
        public ReplyValidationFault(string validationErrorDetail)
            : base(new FaultReason(new FaultReasonText(validationErrorDetail, Thread.CurrentThread.CurrentUICulture)),
                  FaultCode.CreateReceiverFaultCode("SchemaValidationFault", "http://PlantWebService"))
        {
        }
    }
}
