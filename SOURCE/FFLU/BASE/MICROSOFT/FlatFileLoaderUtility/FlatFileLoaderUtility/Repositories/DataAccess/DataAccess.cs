using System;
using System.Data;
using System.Data.OracleClient;
using System.Linq;
using System.IO;
using System.Xml;
using FlatFileLoaderUtility.Models.Shared;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Repositories.DataAccess
{
    /// <summary>
    /// This class serves as a data access layer for the application. All calls
    /// to the database should go via this class. It has IDisposable support
    /// so best practice is to reference it within a using block.
    /// 
    /// The DataAccess methods will automatically open the connection upon first use.
    /// 
    /// Usage example:
    /// using (DataAccess dal = new DataAccess())
    /// {
    ///     dal.MethodCallOne();
    ///     dal.MethodCallTwo();
    ///     ...etc
    /// }
    /// 
    /// It is instantiated both from the base controller as part of the repository container,
    /// and also in the individual repositories to access the database.
    /// 
    /// The base instance opens the connection and creates a transaction (necessary for unit testing
    /// of the DAL). It has isConnectionSharing = false, and will commit/dispose of the resources when
    /// disposing of the instance.
    /// 
    /// The instances in the repositories pass the base instance into the constructor for that connection
    /// and transaction to be re-used. This allows all repositories to share the same database connection
    /// (within a controller action) to minmise the number of round-trips to the database. They have
    /// the isConnectionSharing set to true, and will not close the connection when disposing of the instance.
    /// 
    /// Note that all database actions are wrapped in a transaction. If the Access object has 
    /// IsUnitTesting = true, the transaction is rolled back when disposing, otherwise the transaction
    /// is committed.
    /// 
    /// Ideally this would use TransactionScope instead of an OracleTransaction, but TransactionScope
    /// is not supported by the ADO.NET Oracle provider. And, in fact, the ADO.NET Oracle provider has
    /// been deprecated in version 4 of the .NET framework and will undergo no further active development by
    /// Microsoft, so actually it will never be supported. See here for further details:
    /// http://blogs.msdn.com/b/adonet/archive/2009/06/15/system-data-oracleclient-update.aspx
    /// 
    /// Additionally, the ADO.NET does not support pipelined functions. :(
    /// There is a managed version of the ODP.NET driver in development by Oracle, but it's currently in Beta
    /// (and has been for 2 years, so maybe they'll be like Google and just never finish it).
    /// 
    /// </summary>
    public class DataAccess : IDisposable
    {
        #region private members

        private readonly MemoryStream changeStream = null;
        private readonly XmlTextWriter changeWriter = null;
        private readonly bool isConnectionSharing = false;

        #endregion

        #region protected properties

        protected OracleConnection Connection { get; set; }
        protected OracleCommand Command { get; set; }
        protected OracleDataReader Reader { get; set; }
        protected OracleTransaction Transaction { get; set; }
        protected OracleDataAdapter Adapter { get; set; }
        protected DataSet Dataset { get; set; }
        
        #endregion

        #region public properties

        public Access Access { get; set; }
       
        #endregion

        #region constructors

        /// <summary>
        /// Creates a new instance of DataAccess.
        /// </summary>
        /// <param name="keepAlive">True indicates that the connection should 
        /// persist between method calls. False indicates that the connection 
        /// should be closed after the first call.</param>
        public DataAccess(Connection connection)
        {
            this.Access = new Access();
            this.Connection = new OracleConnection("Data Source=" + connection.NetworkAlias + ";User ID=" + connection.Username + ";Password=" + connection.Password);
            this.OpenConnection();
            this.Transaction = this.Connection.BeginTransaction();
        }

        public DataAccess(DataAccess dataAccess)
        {
            this.Access = dataAccess.Access;
            this.Connection = dataAccess.Connection;
            this.Transaction = dataAccess.Transaction;
            this.isConnectionSharing = true;

            if (this.Transaction == null || this.Transaction.Connection == null)
                this.Transaction = this.Connection.BeginTransaction();
        }

        #endregion

        #region destructors

        /// <summary>
        /// IDisposable support
        /// </summary>
        public void Dispose()
        {
            if (!this.isConnectionSharing && this.Transaction != null && this.Transaction.Connection != null)
            {
                if (this.Access.IsUnitTesting)
                    this.Transaction.Rollback();
                else
                    this.Transaction.Commit();
            }

            if (!this.isConnectionSharing)
                this.CloseConnection();

            if (this.changeWriter != null)
                this.changeWriter.Close();
            if (this.changeStream != null)
                this.changeStream.Dispose();
            if (this.Reader != null)
                this.Reader.Dispose();
            if (this.Dataset != null)
                this.Dataset.Dispose();
            if (this.Adapter != null)
                this.Adapter.Dispose();
            if (this.Command != null)
                this.Command.Dispose();
            if (this.Transaction != null && !this.isConnectionSharing)
                this.Transaction.Dispose();
            if (this.Connection != null && !this.isConnectionSharing)
                this.Connection.Dispose();
        }

        #endregion

        #region private methods

        /// <summary>
        /// Opens connection if it is not already open
        /// </summary>
        private void OpenConnection()
        {
            if (this.Connection.State == ConnectionState.Closed)
                this.Connection.Open();
        }

        /// <summary>
        /// Closes connection to database if not already closed.
        /// </summary>
        private void CloseConnection()
        {
            if (this.Connection.State != ConnectionState.Closed)
                this.Connection.Close();
        }

        #endregion

        #region protected methods

        /// <summary>
        /// Converts DateTime.MinValue into DBNull.Value for the provided DateTime.
        /// </summary>
        /// <param name="input">The DateTime to check/convert</param>
        /// <returns>DBNull.Value or a DateTime object</returns>
        protected object NullMinDate(DateTime input)
        {
            if (input == DateTime.MinValue)
                return DBNull.Value;
            else
                return input;
        }

        #endregion
    }
}

