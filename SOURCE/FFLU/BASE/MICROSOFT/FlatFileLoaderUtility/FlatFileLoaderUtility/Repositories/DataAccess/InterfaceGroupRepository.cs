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
    public class InterfaceGroupRepository : BaseRepository, IInterfaceGroupRepository
    {
        private const string CacheKey = "InterfaceGroup";

        #region constructor

        public InterfaceGroupRepository(RepositoryContainer container)
            : base(container)
        { }

        #endregion

        #region interface methods

        public List<InterfaceGroup> Get(string sorting)
        {
            var result = HttpRuntime.Cache.GetOrStore<List<InterfaceGroup>>(CacheKey + this.Container.Connection.ConnectionId.ToString(), () => Retrieve());

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

        private List<InterfaceGroup> Retrieve()
        {
            using (var dal = new DataAccessInterfaceGroup(this.Container.DataAccess))
                return dal.Load();
        }

        #endregion

        #region classes

        private class DataAccessInterfaceGroup : DataAccess
        {
            #region constructors

            public DataAccessInterfaceGroup(DataAccess dataAccess)
                : base(dataAccess)
            {
            }

            #endregion

            #region methods

            public List<InterfaceGroup> Load()
            {
                var result = new List<InterfaceGroup>();
                var dataset = new DataSet();
                
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".get_interface_group_list)";
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                foreach (DataRow row in dataset.Tables[0].Rows)
                {
                    var item = new InterfaceGroup();
                    item.InterfaceGroupCode = row["interface_group_code"].ToString();
                    item.InterfaceGroupName = row["interface_group_name"].ToString();
                    result.Add(item);
                }

                return result;
            }

            #endregion
        }

        #endregion
    }
}