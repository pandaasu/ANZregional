using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Xml;
using System.Xml.Schema;
using System.Xml.Serialization;
using FlatFileLoaderUtility.Models.Shared;
using FlatFileLoaderUtility.Repositories.DataAccess;

using System.ComponentModel.DataAnnotations;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Connection.cs
    /// 
    /// The Connection class is a simple structure to store the database identification and network
    /// connection information. The application identifier must be unique, and must always remain the same
    /// even if the name of the underlying application changes or the database moves to a new server.
    /// This is because the application identifier is referenced by the AccountReset class, where the user
    /// password reset times are stored per application.
    /// 
    /// Effectively, this class is only used as a way to save & load the connection information to XML.
    /// And make them available to the rest of the application.
    /// </summary>
    [XmlTypeAttribute(AnonymousType = true)]
    [Serializable]
    public class Connection
    {
        #region properties

        [XmlElementAttribute(Form = XmlSchemaForm.Unqualified)]
        [Key]
        public int ConnectionId { get; set; }

        [XmlElementAttribute(Form = XmlSchemaForm.Unqualified)]
        [Required]
        public string ConnectionName { get; set; }

        [XmlElementAttribute(Form = XmlSchemaForm.Unqualified)]
        [Required]
        public string NetworkAlias { get; set; }

        [XmlElementAttribute(Form = XmlSchemaForm.Unqualified)]
        [Required]
        public string Username { get; set; }

        [XmlElementAttribute(Form = XmlSchemaForm.Unqualified)]
        [Required]
        public string Password { get; set; }

        #endregion

        #region constructors

        public Connection()
        {
            this.ConnectionId = 0;
            this.ConnectionName = string.Empty;
            this.NetworkAlias = string.Empty;
            this.Username = string.Empty;
            this.Password = string.Empty;
        }

        #endregion

        #region methods

        public static Connection GetConnection(HttpContextBase context)
        {
            try
            {
                var connectionRepository = new ConnectionRepository();
                var connections = connectionRepository.Get("ConnectionName ASC");
                
                if (context == null)
                    return (connections.Count > 0) ? connections[0] : default(Connection);

                // Retrieve it from session, if available
                var connection = (Connection)context.Session["Connection"];
                if (connection != null)
                    return connection;

                connection = (connections.Count > 0) ? connections[0] : default(Connection);

                context.Session["Connection"] = connection;
                return connection;
            }
            catch (Exception ex)
            {
                Logs.Log(1, ex.ToString());
                return default(Connection);
            }
        }

        public static void SetConnection(HttpContextBase context, Connection connection)
        {
            try
            {
                if (context == null)
                    return;

                context.Session["Connection"] = connection;
            }
            catch (Exception ex)
            {
                Logs.Log(1, ex.ToString());
            }
        }

        #endregion
    }

    [Serializable]
    [XmlTypeAttribute(AnonymousType = true)]
    [XmlRootAttribute(Namespace = "", IsNullable = false)]
    public class Connections
    {
        [XmlElementAttribute("Connection", Form = XmlSchemaForm.Unqualified)]
        public List<Connection> Items { get; set; }
    }
}