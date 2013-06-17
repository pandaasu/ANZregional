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
    public class InterfaceOptionRepository : BaseRepository, IInterfaceOptionRepository
    {
        private const string CacheKey = "InterfaceOption";

        #region constructor

        public InterfaceOptionRepository(RepositoryContainer container)
            : base(container)
        { }

        #endregion

        #region interface methods

        public List<InterfaceOption> Get(string sorting)
        {
            var username = this.Container.Access.Username;
            if (string.IsNullOrEmpty(username))
                username = "*GUEST";
            var result = HttpRuntime.Cache.GetOrStore<List<InterfaceOption>>(CacheKey + this.Container.Connection.ConnectionId.ToString() + "_" + username, () => Retrieve(username));

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

        #endregion

        #region private methods

        private List<InterfaceOption> Retrieve(string username)
        {
            using (var dal = new DataAccessInterfaceOption(this.Container.DataAccess))
                return dal.Load(username);
        }

        #endregion

        #region classes

        private class DataAccessInterfaceOption : DataAccess
        {
            #region constructors

            public DataAccessInterfaceOption(DataAccess dataAccess)
                : base(dataAccess)
            {
            }

            #endregion

            #region methods

            public List<InterfaceOption> Load(string username)
            {
                var result = new List<InterfaceOption>();
                var dataset = new DataSet();
                
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".get_user_interface_options(:user_code))";
                this.Command.Parameters.Add("user_code", OracleType.VarChar, 50).Value = username;
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                foreach (DataRow row in dataset.Tables[0].Rows)
                {
                    var item = new InterfaceOption();
                    item.UserCode = row["user_code"].ToString();
                    item.InterfaceCode = row["interface_code"].ToString();
                    item.OptionCode = row["option_code"].ToString();
                    result.Add(item);
                }

                return result;
            }

            #endregion
        }

        #endregion
    }
}