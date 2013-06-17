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
    public class InterfaceRepository : BaseRepository, IInterfaceRepository
    {
        private const string CacheKey = "Interface";

        #region constructor

        public InterfaceRepository(RepositoryContainer container)
            : base(container)
        { }

        #endregion

        #region interface methods

        public List<Interface> Get(string sorting)
        {
            var result = HttpRuntime.Cache.GetOrStore<List<Interface>>(CacheKey + this.Container.Connection.ConnectionId.ToString(), () => Retrieve());

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

        public void Reprocess(int uploadId, string interfaceCode)
        {
            var userCode = this.Container.User.UserCode;
            using (var dal = new DataAccessInterface(this.Container.DataAccess))
                dal.Reprocess(uploadId, userCode, interfaceCode);
        }

        #endregion

        #region private methods

        private List<Interface> Retrieve()
        {
            using (var dal = new DataAccessInterface(this.Container.DataAccess))
                return dal.Load();
        }

        #endregion

        #region classes

        private class DataAccessInterface : DataAccess
        {
            #region constructors

            public DataAccessInterface(DataAccess dataAccess)
                : base(dataAccess)
            {
            }

            #endregion

            #region methods

            public List<Interface> Load()
            {
                var result = new List<Interface>();
                var dataset = new DataSet();
                
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".get_interface_list)";
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                foreach (DataRow row in dataset.Tables[0].Rows)
                {
                    var item = new Interface();
                    item.InterfaceCode = row["interface_code"].ToString();
                    item.InterfaceName = row["interface_name"].ToString();
                    item.InterfaceTypeCode = row["interface_type_code"].ToString();
                    item.InterfaceThreadCode = row["interface_thread_code"].ToString();
                    item.FileType = row["interface_filetype"].ToString();
                    item.CsvQualifier = row["interface_csv_qual"].ToString();
                    result.Add(item);
                }

                return result;
            }

            public void Reprocess(int licsId, string userCode, string interfaceCode)
            {
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.StoredProcedure;
                this.Command.CommandText = Properties.Settings.Default.DatabasePackageName + ".reprocess_interface";
                this.Command.Parameters.Add("i_xaction_seq", OracleType.Int32).Value = licsId;
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode;
                this.Command.Parameters.Add("i_interface_code", OracleType.VarChar, 32).Value = interfaceCode;
                this.Command.ExecuteNonQuery();
            }

            #endregion
        }

        #endregion
    }
}