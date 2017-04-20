using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using System.ServiceModel.Configuration;

namespace PlantWebService
{
    public class MessageLoggerBehaviorExtension : BehaviorExtensionElement
    {
        const string MyPropertyName = "logFolder";

        public override Type BehaviorType
        {
            get { return typeof(MessageLogger); }
        }

        [ConfigurationProperty(MyPropertyName)]
        public string LogFolder
        {
            get
            {
                return (string)base[MyPropertyName];
            }
            set
            {
                base[MyPropertyName] = value;
            }
        }

        protected override object CreateBehavior()
        {
            return new MessageLogger(this.LogFolder);
        }
    }


}