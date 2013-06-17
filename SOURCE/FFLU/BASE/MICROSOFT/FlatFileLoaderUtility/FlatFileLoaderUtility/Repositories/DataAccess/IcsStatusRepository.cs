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
    public class IcsStatusRepository : BaseRepository, IIcsStatusRepository
    {
        private const string CacheKey = "IcsStatus";

        #region constructor

        public IcsStatusRepository(RepositoryContainer container)
            : base(container)
        { }

        #endregion

        #region interface methods

        public List<IcsStatus> Get(string sorting)
        {
            var result = HttpRuntime.Cache.GetOrStore<List<IcsStatus>>(CacheKey + this.Container.Connection.ConnectionId.ToString(), () => Retrieve());

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

        private List<IcsStatus> Retrieve()
        {
            using (var dal = new DataAccessIcsStatus(this.Container.DataAccess))
                return dal.Load();
        }

        #endregion

        #region classes

        private class DataAccessIcsStatus : DataAccess
        {
            #region constructors

            public DataAccessIcsStatus(DataAccess dataAccess)
                : base(dataAccess)
            {
            }

            #endregion

            #region methods

            public List<IcsStatus> Load()
            {
                var result = new List<IcsStatus>();
                var dataset = new DataSet();
                
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".get_xaction_status_list())";
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                foreach (DataRow row in dataset.Tables[0].Rows)
                {
                    var item = new IcsStatus();
                    item.IcsStatusCode = row["xaction_status_code"].ToString();
                    item.IcsStatusName = row["xaction_status_name"].ToString();
                    result.Add(item);
                }

                return result;
            }

            #endregion
        }

        #endregion
    }
}