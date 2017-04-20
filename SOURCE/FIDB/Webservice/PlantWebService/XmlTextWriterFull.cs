using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml;
using System.IO;
using System.Text;

namespace PlantWebService
{
    public class XmlTextWriterFull : XmlTextWriter
    {
        public XmlTextWriterFull(Stream stream) : base(stream, Encoding.UTF8) { }

        public XmlTextWriterFull(TextWriter sink) : base(sink) { }

        public override void WriteEndElement()
        {
            base.WriteFullEndElement();
        }
    }
}