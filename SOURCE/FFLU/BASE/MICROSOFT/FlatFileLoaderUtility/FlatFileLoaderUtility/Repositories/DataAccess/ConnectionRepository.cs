using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Xml;
using System.Xml.Schema;
using System.Xml.Serialization;
using System.Data;
using System.Data.OracleClient;
using System.Web;
using FlatFileLoaderUtility.Models;
using FlatFileLoaderUtility.Models.Shared;

namespace FlatFileLoaderUtility.Repositories.DataAccess
{
    public class ConnectionRepository : BaseRepository, IConnectionRepository
    {
        private const string CacheKey = "Connection";

        #region constructor

        public ConnectionRepository(RepositoryContainer container)
            : base(container)
        { }

        #endregion

        #region interface methods

        public List<Connection> Get(string sorting)
        {
            var result = HttpRuntime.Cache.GetOrStore<List<Connection>>(CacheKey, () => Retrieve());

            // Sort, if required
            if (!string.IsNullOrWhiteSpace(sorting))
            {
                var sortParts = sorting.Split(' ');
                if (sortParts.Last() == "ASC")
                    result = result.OrderBy(x => x.GetType().GetProperty(sortParts.First()).GetValue(x, null)).ToList();
                else
                    result = result.OrderByDescending(x => x.GetType().GetProperty(sortParts.First()).GetValue(x, null)).ToList();
            }

            return result;
        }

        public Connection Add(Connection item)
        {
            var connections = this.Get(string.Empty);

            Logs.Log(5, "Saving connection data to xml. Total list length: " + connections.Count.ToString());

            var xmlDoc = Tools.GetEntityXml("Connections", connections);

            Logs.Log(5, "Connection xml total nodes: " + xmlDoc.DocumentElement.ChildNodes.Count.ToString());

            using (var filestream = new FileStream(HttpContext.Current.Request.PhysicalApplicationPath + @"\Config\Connections.xml", FileMode.Create, FileAccess.Write))
            {
                xmlDoc.Save(filestream);
            }

            HttpRuntime.Cache.Remove(CacheKey);

            return item;
        }

        public void Update(Connection item)
        {
            // Remove the old
            var connections = this.Get(string.Empty);
            var connection = (from x in connections where x.ConnectionName == item.ConnectionName select x).FirstOrDefault();
            if (connection != null)
                connections.Remove(connection);

            // Add the replacement
            this.Add(item);
        }

        public void ResetPackage()
        {
            using (var dal = new DataAccessConnection(this.Container.DataAccess))
                dal.ResetPackage();
        }

        #endregion

        #region private methods

        private List<Connection> Retrieve()
        {
            var xmlDoc = new XmlDocument();

            using (var filestream = new FileStream(HttpContext.Current.Request.PhysicalApplicationPath + @"\Config\Connections.xml", FileMode.Open, FileAccess.Read))
            {
                // Get the schema for the AOW data model
                var xmlSchema = XmlSchema.Read(new XmlTextReader(HttpContext.Current.Request.PhysicalApplicationPath + @"\Config\ConnectionSchema.xsd"), new ValidationEventHandler(SchemaValidationError));

                // Create reader settings so the XML file can be validated
                var settings = new XmlReaderSettings();
                settings.ValidationType = ValidationType.Schema;
                settings.Schemas.Add(xmlSchema);
                settings.ValidationEventHandler += new ValidationEventHandler(XmlValidationError);

                // Create a reader to read the stream
                using (var reader = XmlReader.Create(filestream, settings))
                {
                    // Load the validated XML
                    xmlDoc.Load(reader);
                }
            }

            // Prepare for deserialisation
            var xmlSerializer = new XmlSerializer(typeof(Connections));
            var xmlParserContext = new XmlParserContext(null, null, null, XmlSpace.None);
            var xmlTextReader = new XmlTextReader(xmlDoc.InnerXml, XmlNodeType.Document, xmlParserContext);

            // Deserialize the XML
            return ((Connections)xmlSerializer.Deserialize(xmlTextReader)).Items;
        }

        private static void SchemaValidationError(object sender, EventArgs e)
        {
            Logs.Log(1, "ConnectionSchema.xsd invalid.");
            throw new Exception("ConnectionSchema.xsd invalid.");
        }

        private static void XmlValidationError(object sender, EventArgs e)
        {
            Logs.Log(1, "Connections.xml invalid.");
            throw new Exception("Connections.xml invalid.");
        }

        private class DataAccessConnection : DataAccess
        {
            #region constructors

            public DataAccessConnection(DataAccess dataAccess)
                : base(dataAccess)
            {
            }

            #endregion

            #region methods

            public void ResetPackage()
            {
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.StoredProcedure;
                this.Command.CommandText = "dbms_session.reset_package";
                this.Command.ExecuteNonQuery();
            }

            #endregion
        }

        #endregion
    }
}