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
    public class UserRepository : BaseRepository, IUserRepository
    {
        private const string CacheKey = "User";

        #region constructor

        public UserRepository(RepositoryContainer container)
            : base(container)
        { }

        #endregion

        #region interface methods

        public User Get()
        {
            var username = this.Container.Access.Username;
            if (string.IsNullOrEmpty(username))
                username = "*GUEST";
            return HttpRuntime.Cache.GetOrStore(CacheKey + this.Container.Connection.ConnectionId.ToString() + "_" + username, () => Retrieve(username));
        }

        #endregion

        #region private methods

        private User Retrieve(string username)
        {
            // Get the user details
            var user = default(User);
            using (var dal = new DataAccessUser(this.Container.DataAccess))
                user = dal.Load(username);

            // And get the interface options available for this user
            user.InterfaceOptions = this.Container.InterfaceOptionRepository.Get(string.Empty);

            return user;
        }

        #endregion

        #region classes

        private class DataAccessUser : DataAccess
        {
            #region constructors

            public DataAccessUser(DataAccess dataAccess)
                : base(dataAccess)
            {
            }

            #endregion

            #region methods

            public User Load(string username)
            {
                var result = new User();
                var dataset = new DataSet();

                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".get_authorised_user(:user_code))";
                this.Command.Parameters.Add("user_code", OracleType.VarChar, 50).Value = username;
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                if (dataset.Tables[0].Rows.Count > 0)
                {
                    result.UserCode = dataset.Tables[0].Rows[0]["user_code"].ToString();
                    result.UserName = dataset.Tables[0].Rows[0]["user_name"].ToString();
                }

                return result;
            }

            #endregion
        }

        #endregion
    }
}