using System;
using System.Collections.Generic;
using System.Text;

namespace ICS.LICS.UpgradeManager
{
    public enum DetailType
    {
        Test = 0,
        Prod
    }

    class Site
    {
        private string _code;
        private string _description;

        private DatabaseAccess _testAccess;
        private DatabaseAccess _prodAccess;

        public Site(string code, string description)
        {
            this._code = code;
            this._description = description;

            this._testAccess = null;
            this._prodAccess = null;
        }

        public void AddProdDetails(string database, string password)
        {
            this._prodAccess = new DatabaseAccess(database, password);
        }

        public void AddTestDetails(string database, string password, string licsPassword)
        {
            this._testAccess = new DatabaseAccess(database, password, licsPassword);
        }

        public string Code
        {
            get
            {
                return this._code;
            }
        }

        public string Description
        {
            get
            {
                return this._description;
            }
        }

        public DatabaseAccess TestAccess
        {
            get
            {
                return this._testAccess;
            }
        }

        public DatabaseAccess ProdAccess
        {
            get
            {
                return this._prodAccess;
            }
        }

        public override string ToString()
        {
            return string.Format("{0} ({1})"
                , this._description
                , this._code);
        }
    }

    internal class DatabaseAccess
    {
        private string _database;
        private string _password;
        private string _licsPassword = "<unknown>";

        public DatabaseAccess(string database, string password)
        {
            this._database = database;
            this._password = password;
        }

        public DatabaseAccess(string database, string password, string licsPassword) : this(database, password)
        {
            this._licsPassword = licsPassword;
        }

        public string Database
        {
            get
            {
                return this._database;
            }
        }

        public string Password
        {
            get
            {
                return this._password;
            }
        }

        public string LicsPassword
        {
            get
            {
                return this._licsPassword;
            }
        }
    }
}
