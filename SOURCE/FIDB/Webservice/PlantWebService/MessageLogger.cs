using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization.Json;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ServiceModel.Description;
using System.ServiceModel.Dispatcher;
using System.Text;
using System.Threading;
using System.Xml;
using System.Xml.Schema;

namespace PlantWebService
{
    public class MessageLogger : IDispatchMessageInspector, IEndpointBehavior
    {
        private const string DefaultMessageLogFolder = @"c:\workspace\";
        private static int messageLogFileIndex = 0;
        private string messageLogFolder;

        public MessageLogger() : this(DefaultMessageLogFolder)
        {
            //this.CreateSchemaSet();
        }

        public MessageLogger(string messageLogFolder)
        {
            this.messageLogFolder = messageLogFolder;
            //this.CreateSchemaSet();
        }

        //private void CreateSchemaSet()
        //{
        //    this.schemaSet = new XmlSchemaSet();
        //    var baseSchema = new Uri(AppDomain.CurrentDomain.BaseDirectory);

        //    var locations = new List<string>();
        //    locations.Add("Schema/messages.xsd");
        //    locations.Add("Schema/envelope.xsd");

        //    foreach (var loc in locations)
        //    {
        //        var location = new Uri(baseSchema, loc).ToString();
        //        using (var reader = new XmlTextReader(location))
        //        {
        //            var schema = XmlSchema.Read(reader, null);
        //            schemaSet.Add(schema);
        //        }
        //    }

        //    this.schemaSet.Compile();
        //}

        public void AddBindingParameters(ServiceEndpoint endpoint, BindingParameterCollection bindingParameters)
        {
        }

        public void ApplyClientBehavior(ServiceEndpoint endpoint, ClientRuntime clientRuntime)
        {
        }

        public void ApplyDispatchBehavior(ServiceEndpoint endpoint, EndpointDispatcher endpointDispatcher)
        {
            endpointDispatcher.DispatchRuntime.MessageInspectors.Add(this);
        }

        public void Validate(ServiceEndpoint endpoint)
        {
        }

        public object AfterReceiveRequest(ref Message request, IClientChannel channel, InstanceContext instanceContext)
        {
            string messageFileName = string.Format("{0}Log{1:yyyyMMddHHmmss}_{2:00000000}_Incoming.txt", this.messageLogFolder, DateTime.Now, Interlocked.Increment(ref messageLogFileIndex));
            Uri requestUri = request.Headers.To;

            if (Properties.Settings.Default.LoggingLevel >= 5)
            {
                using (StreamWriter sw = File.CreateText(messageFileName))
                {
                    HttpRequestMessageProperty httpReq = (HttpRequestMessageProperty)request.Properties[HttpRequestMessageProperty.Name];

                    sw.WriteLine("{0} {1}", httpReq.Method, requestUri);
                    foreach (var header in httpReq.Headers.AllKeys)
                    {
                        sw.WriteLine("{0}: {1}", header, httpReq.Headers[header]);
                    }

                    if (!request.IsEmpty)
                    {
                        sw.WriteLine();
                        sw.WriteLine(this.MessageToString(ref request));
                    }
                }
            }

            return requestUri;
        }

        private Message ChangeString(Message oldMessage, string from, string to)
        {
            var body = string.Empty;

            //using (var ms = new MemoryStream())
            //using (var xw = XmlWriter.Create(ms))
            //{
            //    oldMessage.WriteMessage(xw);
            //    body = Encoding.UTF8.GetString(ms.ToArray());
            //}

            //body = body.Replace(from, to);

            //using (var ms = new MemoryStream(Encoding.UTF8.GetBytes(body)))
            //{
            //    using (var xdr = XmlDictionaryReader.CreateTextReader(ms, new XmlDictionaryReaderQuotas()))
            //    {
            //        var newMessage = Message.CreateMessage(xdr, int.MaxValue, oldMessage.Version);
            //        newMessage.Properties.CopyProperties(oldMessage.Properties);
            //        return newMessage;
            //    }




            //}

            using (var stream = new MemoryStream())
            {
                var serializer = new System.Xml.Serialization.XmlSerializer(typeof(Message));
                var writer = new XmlTextWriterFull(stream);
                serializer.Serialize(writer, oldMessage);

                using (var xdr = XmlDictionaryReader.CreateTextReader(stream, new XmlDictionaryReaderQuotas()))
                {
                    var newMessage = Message.CreateMessage(xdr, int.MaxValue, oldMessage.Version);
                    newMessage.Properties.CopyProperties(oldMessage.Properties);
                    return newMessage;
                }

                //var newMessage = Message.CreateMessage(xdr, int.MaxValue, oldMessage.Version);

                //var result = Encoding.UTF8.GetString(stream.ToArray());
                //Console.WriteLine(result);
            }

        }

        public void BeforeSendReply(ref Message reply, object correlationState)
        {
            if (Properties.Settings.Default.LoggingLevel < 5)
                return;

            // Remove any spaces from self-closing tags, at Rockwell's request
            //reply = this.ChangeString(reply, @" />", @"/>");

            string messageFileName = string.Format("{0}Log{1:yyyyMMddHHmmss}_{2:00000000}_Outgoing.txt", this.messageLogFolder, DateTime.Now, Interlocked.Increment(ref messageLogFileIndex));
            
            using (StreamWriter sw = File.CreateText(messageFileName))
            {
                sw.WriteLine("Response to request to {0}:", (Uri)correlationState);
                if (reply.Properties.ContainsKey(HttpResponseMessageProperty.Name))
                {
                    HttpResponseMessageProperty httpResp = (HttpResponseMessageProperty)reply.Properties[HttpResponseMessageProperty.Name];
                    sw.WriteLine("{0} {1}", (int)httpResp.StatusCode, httpResp.StatusCode);
                }
                else
                {
                    sw.WriteLine("No httpResponse found.");
                }

                if (!reply.IsEmpty)
                {
                    var stringMessage = this.MessageToString(ref reply);

                    sw.WriteLine();
                    sw.WriteLine(stringMessage);

                    //this.Validate(stringMessage);
                }
            }
        }

        XmlSchemaSet schemaSet;

        //private void Validate(string message)
        //{
        //    //message = message.Replace(@"xmlns:s=""http://schemas.xmlsoap.org/soap/envelope/""", @"xmlns:s=""http://schemas.xmlsoap.org/soap/envelope/"" schem");
        //    message = message.Replace("Production", "EE");

        //    var xml = new XmlDocument();
        //    xml.LoadXml(message);
        //    xml.Schemas = this.schemaSet;
        //    xml.Save(@"c:\workspace\x.xml");

        //    var settings = new XmlReaderSettings { CloseInput = true };
        //    settings.ValidationEventHandler += ValidationHandler;
        //    settings.ValidationType = ValidationType.Schema;
        //    settings.Schemas = this.schemaSet;
            
        //    using (var f = new StreamReader(@"c:\workspace\x.xml"))
        //    using (var validatingReader = XmlReader.Create(f, settings))
        //    {
        //        while (validatingReader.Read())
        //        {
        //        }
        //    }

        //    //errors = validationErrors;

        //    //try
        //    //{
        //    //    xml.Validate((sender, e) =>
        //    //    {
        //    //        switch (e.Severity)
        //    //        {
        //    //            case XmlSeverityType.Error:
        //    //               // error = e.Message;
        //    //                break;
        //    //            case XmlSeverityType.Warning:
        //    //                //LogWarning(e.Message);
        //    //                break;
        //    //        }
        //    //    });
        //    //}
        //    //catch (XmlSchemaValidationException e)
        //    //{
        //    //    throw new ValidationFault(e.Message);
        //    //}
        //}

        //private readonly List<string> validationErrors = new List<string>();

        //private void ValidationHandler(object sender, ValidationEventArgs e)
        //{
        //    if (e.Severity != XmlSeverityType.Error)
        //    {
        //        return;
        //    }

        //    validationErrors.Add(string.Format("Line: {0}, Position: {1} \"{2}\"",
        //                                       e.Exception.LineNumber,
        //                                       e.Exception.LinePosition,
        //                                       e.Exception.Message));

        //}

        //void InspectionValidationHandler(object sender, ValidationEventArgs e)
        //{
        //    if (e.Severity == XmlSeverityType.Error)
        //    {
        //        throw new ValidationFault(e.Message);
        //    }
        //}

        private WebContentFormat GetMessageContentFormat(Message message)
        {
            WebContentFormat format = WebContentFormat.Default;
            if (message.Properties.ContainsKey(WebBodyFormatMessageProperty.Name))
            {
                WebBodyFormatMessageProperty bodyFormat;
                bodyFormat = (WebBodyFormatMessageProperty)message.Properties[WebBodyFormatMessageProperty.Name];
                format = bodyFormat.Format;
            }

            return format;
        }

        private string MessageToString(ref Message message)
        {
            WebContentFormat messageFormat = this.GetMessageContentFormat(message);
            MemoryStream ms = new MemoryStream();
            XmlDictionaryWriter writer = null;
            switch (messageFormat)
            {
                case WebContentFormat.Default:
                case WebContentFormat.Xml:
                    writer = XmlDictionaryWriter.CreateTextWriter(ms);
                    break;
                case WebContentFormat.Json:
                    writer = JsonReaderWriterFactory.CreateJsonWriter(ms);
                    break;
                case WebContentFormat.Raw:
                    // special case for raw, easier implemented separately
                    return this.ReadRawBody(ref message);
            }

            message.WriteMessage(writer);
            writer.Flush();
            string messageBody = Encoding.UTF8.GetString(ms.ToArray());

            // Here would be a good place to change the message body, if so desired.

            // now that the message was read, it needs to be recreated.
            ms.Position = 0;

            // if the message body was modified, needs to reencode it, as show below
            // ms = new MemoryStream(Encoding.UTF8.GetBytes(messageBody));

            XmlDictionaryReader reader;
            if (messageFormat == WebContentFormat.Json)
            {
                reader = JsonReaderWriterFactory.CreateJsonReader(ms, XmlDictionaryReaderQuotas.Max);
            }
            else
            {
                reader = XmlDictionaryReader.CreateTextReader(ms, XmlDictionaryReaderQuotas.Max);
            }

            Message newMessage = Message.CreateMessage(reader, int.MaxValue, message.Version);
            newMessage.Properties.CopyProperties(message.Properties);
            message = newMessage;

            return messageBody;
        }

        private string ReadRawBody(ref Message message)
        {
            XmlDictionaryReader bodyReader = message.GetReaderAtBodyContents();
            bodyReader.ReadStartElement("Binary");
            byte[] bodyBytes = bodyReader.ReadContentAsBase64();
            string messageBody = Encoding.UTF8.GetString(bodyBytes);

            // Now to recreate the message
            MemoryStream ms = new MemoryStream();
            XmlDictionaryWriter writer = XmlDictionaryWriter.CreateBinaryWriter(ms);
            writer.WriteStartElement("Binary");
            writer.WriteBase64(bodyBytes, 0, bodyBytes.Length);
            writer.WriteEndElement();
            writer.Flush();
            ms.Position = 0;
            XmlDictionaryReader reader = XmlDictionaryReader.CreateBinaryReader(ms, XmlDictionaryReaderQuotas.Max);
            Message newMessage = Message.CreateMessage(reader, int.MaxValue, message.Version);
            newMessage.Properties.CopyProperties(message.Properties);
            message = newMessage;

            return messageBody;
        }
    }

    class ValidationFault : FaultException
    {
        public ValidationFault(string validationErrorDetail)
            : base(new FaultReason(new FaultReasonText(validationErrorDetail, Thread.CurrentThread.CurrentUICulture)),
                  FaultCode.CreateReceiverFaultCode("SchemaValidationFault", "http://PlantWebService"))
        {
        }
    }
}