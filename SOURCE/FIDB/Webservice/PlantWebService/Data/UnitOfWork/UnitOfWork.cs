using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.Common;
using System.Text;
using System.Threading.Tasks;
using Oracle.ManagedDataAccess;
using Oracle.ManagedDataAccess.Client;
using PlantWebService.Classes;
using PlantWebService.Interfaces.UnitOfWork;

namespace PlantWebService.Data.UnitOfWork
{
    public class UnitOfWork : IUnitOfWork
    {
        #region protected properties

        public OracleConnection OracleConnection { get; set; }
        protected OracleCommand OracleCommand { get; set; }
        protected OracleDataReader OracleReader { get; set; }
        public OracleTransaction OracleTransaction { get; set; }
        protected OracleDataAdapter OracleAdapter { get; set; }
        public SqlConnection SqlConnection { get; set; }
        protected SqlCommand SqlCommand { get; set; }
        protected SqlDataReader SqlReader { get; set; }
        public SqlTransaction SqlTransaction { get; set; }
        protected SqlDataAdapter SqlAdapter { get; set; }
        protected DataSet Dataset { get; set; }

        #endregion

        #region public properties
        
        public bool UseTransaction { get; set; }
        public bool DisposeConnection { get; set; }

        #endregion

        #region constructors

        public UnitOfWork(bool useTransaction)
        {
            this.UseTransaction = useTransaction;

            if (Properties.Settings.Default.UseOracle)
                this.OracleConnection = new OracleConnection(Properties.Settings.Default.OracleConnectionString);
            else
                this.SqlConnection = new SqlConnection(Properties.Settings.Default.SqlConnectionString);

            this.DisposeConnection = true;

            if (useTransaction)
            {
                this.OpenConnection();
            }
        }

        public UnitOfWork(IUnitOfWork unitOfWork)
        {
            this.OracleConnection = unitOfWork.OracleConnection;
            this.OracleTransaction = unitOfWork.OracleTransaction;
            this.SqlConnection = unitOfWork.SqlConnection;
            this.SqlTransaction = unitOfWork.SqlTransaction;

            if ((Properties.Settings.Default.UseOracle && this.OracleConnection.State != ConnectionState.Open) || (!Properties.Settings.Default.UseOracle && this.SqlConnection.State != ConnectionState.Open))
            {
                this.OpenConnection();
            }
        }

        #endregion

        #region destructors

        /// <summary>
        /// IDisposable support
        /// </summary>
        public void Dispose()
        {
            if (Properties.Settings.Default.UseOracle)
            {
                if (this.OracleReader != null)
                    this.OracleReader.Dispose();
                if (this.Dataset != null)
                    this.Dataset.Dispose();
                if (this.OracleAdapter != null)
                    this.OracleAdapter.Dispose();
                if (this.OracleCommand != null)
                    this.OracleCommand.Dispose();
                if (this.DisposeConnection && this.OracleTransaction != null)
                    this.OracleTransaction.Dispose();
                if (this.DisposeConnection && this.OracleConnection != null)
                    this.OracleConnection.Dispose();
            }
            else
            {
                if (this.SqlReader != null)
                    this.SqlReader.Dispose();
                if (this.Dataset != null)
                    this.Dataset.Dispose();
                if (this.SqlAdapter != null)
                    this.SqlAdapter.Dispose();
                if (this.SqlCommand != null)
                    this.SqlCommand.Dispose();
                if (this.DisposeConnection && this.SqlTransaction != null)
                    this.SqlTransaction.Dispose();
                if (this.DisposeConnection && this.SqlConnection != null)
                    this.SqlConnection.Dispose();
            }
        }

        #endregion

        #region public methods

        public void OpenConnection()
        {
            if (Properties.Settings.Default.UseOracle)
            {
                if (this.OracleConnection.State == ConnectionState.Closed)
                {
                    Logger.Log.Debug("Opening connection to database");
                    this.OracleConnection.Open();
                }

                if (UseTransaction)
                {
                    this.OracleTransaction = this.OracleConnection.BeginTransaction();
                }
            }
            else
            {
                if (this.SqlConnection.State == ConnectionState.Closed)
                {
                    Logger.Log.Debug("Opening connection to database");
                    this.SqlConnection.Open();
                }

                if (UseTransaction)
                {
                    this.SqlTransaction = this.SqlConnection.BeginTransaction();
                }
            }
        }

        public void Commit()
        {
            if (this.UseTransaction)
            {
                if (Properties.Settings.Default.UseOracle)
                    this.OracleTransaction.Commit();
                else
                    this.SqlTransaction.Commit();
            }
        }

        public void Rollback()
        {
            if (this.UseTransaction)
            {
                if (Properties.Settings.Default.UseOracle)
                    this.OracleTransaction.Rollback();
                else
                    this.SqlTransaction.Rollback();
            }
        }

        #endregion

        #region private methods

        /// <summary>
        /// Closes connection to database if not already closed.
        /// </summary>
        private void CloseConnection()
        {
            if (Properties.Settings.Default.UseOracle)
            {
                if (this.OracleConnection.State != ConnectionState.Closed)
                {
                    this.OracleConnection.Close();
                }
            }
            else
            {
                if (this.SqlConnection.State != ConnectionState.Closed)
                {
                    this.SqlConnection.Close();
                }
            }
        }

        #endregion

        #region protected methods

        protected void Log()
        {
            if (Properties.Settings.Default.LoggingLevel < 5)
                return;

            var sb = new StringBuilder();

            if (Properties.Settings.Default.UseOracle)
            {
                if (this.OracleCommand != null)
                {
                    sb.AppendLine("Command: " + this.OracleCommand.CommandText);
                }

                if (this.OracleCommand.Parameters.Count > 0)
                {
                    sb.AppendLine("\tParameters:");

                    foreach (DbParameter parameter in this.OracleCommand.Parameters)
                    {
                        sb.Append("\t\t" + parameter.ParameterName + ": ");
                        sb.Append(parameter.Value);
                        sb.AppendLine();
                    }
                }
            }
            else
            {
                if (this.SqlCommand != null)
                {
                    sb.AppendLine("Command: " + this.SqlCommand.CommandText);
                }

                if (this.SqlCommand.Parameters.Count > 0)
                {
                    sb.AppendLine("\tParameters:");

                    foreach (DbParameter parameter in this.SqlCommand.Parameters)
                    {
                        sb.Append("\t\t" + parameter.ParameterName + ": ");
                        sb.Append(parameter.Value);
                        sb.AppendLine();
                    }
                }
            }

            Logger.Log.Debug(sb.ToString());
        }

        #endregion
    }
}
