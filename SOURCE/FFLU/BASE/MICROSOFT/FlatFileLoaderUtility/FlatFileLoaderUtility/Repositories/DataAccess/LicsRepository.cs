using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.OracleClient;
using System.Web;
using FlatFileLoaderUtility.Models;
using FlatFileLoaderUtility.Models.Shared;

namespace FlatFileLoaderUtility.Repositories.DataAccess
{
    public class LicsRepository : BaseRepository, ILicsRepository
    {
        private const string CacheKey = "Lics";

        #region constructor

        public LicsRepository(RepositoryContainer container)
            : base(container)
        { }

        #endregion

        #region interface methods

        public string GetProcessWorkingConst()
        {
            return HttpRuntime.Cache.GetOrStore(CacheKey + "_PW_" + this.Container.Connection.ConnectionId.ToString(), () => this.RetrieveProcessWorkingConst());
        }

        public string GetProcessWorkingErrorConst()
        {
            return HttpRuntime.Cache.GetOrStore(CacheKey + "_PWE_" + this.Container.Connection.ConnectionId.ToString(), () => this.RetrieveProcessWorkingErrorConst());
        }

        public string GetLoadCompletedConst()
        {
            return HttpRuntime.Cache.GetOrStore(CacheKey + "_LC_" + this.Container.Connection.ConnectionId.ToString(), () => this.RetrieveLoadCompleteConst());
        }

        #endregion

        #region private methods

        private string RetrieveProcessWorkingConst()
        {
            using (var dal = new DataAccessLics(this.Container.DataAccess))
                return dal.LoadProcessWorkingConst();
        }

        private string RetrieveProcessWorkingErrorConst()
        {
            using (var dal = new DataAccessLics(this.Container.DataAccess))
                return dal.LoadProcessWorkingErrorConst();
        }

        private string RetrieveLoadCompleteConst()
        {
            using (var dal = new DataAccessLics(this.Container.DataAccess))
                return dal.LoadLoadCompleteConst();
        }

        #endregion

        #region classes

        private class DataAccessLics : DataAccess
        {
            #region constructors

            public DataAccessLics(DataAccess dataAccess)
                : base(dataAccess)
            {
            }

            #endregion

            #region methods

            public string LoadProcessWorkingConst()
            {
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "begin :result := " + Properties.Settings.Default.DatabasePackageName + ".get_const_process_working(); end;";
                this.Command.Parameters.Add("result", OracleType.VarChar, 50).Direction = ParameterDirection.ReturnValue;
                this.Command.ExecuteNonQuery();
                this.Transaction.Commit();

                return this.Command.Parameters["result"].Value.ToString();
            }

            public string LoadProcessWorkingErrorConst()
            {
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "begin :result := " + Properties.Settings.Default.DatabasePackageName + ".get_const_process_working_err(); end;";
                this.Command.Parameters.Add("result", OracleType.VarChar, 50).Direction = ParameterDirection.ReturnValue;
                this.Command.ExecuteNonQuery();
                this.Transaction.Commit();

                return this.Command.Parameters["result"].Value.ToString();
            }

            public string LoadLoadCompleteConst()
            {
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "begin :result := " + Properties.Settings.Default.DatabasePackageName + ".get_const_load_completed(); end;";
                this.Command.Parameters.Add("result", OracleType.VarChar, 50).Direction = ParameterDirection.ReturnValue;
                this.Command.ExecuteNonQuery();
                this.Transaction.Commit();

                return this.Command.Parameters["result"].Value.ToString();
            }

            #endregion
        }

        #endregion
    }
}