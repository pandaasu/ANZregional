using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.DirectoryServices.AccountManagement;

namespace FlatFileLoaderUtility.Models.Shared
{
    /// <summary>
    /// Access class for determining who a user is based upon Windows authentication.
    /// It uses an LDAP lookup to confirm the user's identity. (Could optionally be extended
    /// to also check Active Directory group access.)
    /// </summary>
    [Serializable]
    public class Access
    {
        #region Properties

        public string Username { get; set; }
        public bool IsUnitTesting { get; set; }
        public bool IsImpersonating { get; set; }

        #endregion

        #region Constructors

        public Access()
        {
            this.Username = string.Empty;
            this.IsUnitTesting = false;
            this.IsImpersonating = false;
        }

        #endregion

        #region Static Methods

        /// <summary>
        /// Returns an Access object
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public static Access GetAccess(HttpContextBase context)
        {
            try
            {
                if (Properties.Settings.Default.IsDev)
                {
                    var devAccess = new Access();
                    devAccess.Username = Properties.Settings.Default.DevUser;
                    return devAccess;
                }

                if (context == null || context.User == null || context.User.Identity == null)
                    return new Access();

                // Retrieve it from session, if available
                var access = (Access)context.Session["Access"];
                if (access != null)
                    return access;

                access = new Access();
                access.Username = context.User.Identity.Name.Split('\\').Last().ToUpper();
                access.IsImpersonating = false;

                context.Session["Access"] = access;
                return access;
            }
            catch (Exception ex)
            {
                Logs.Log(1, ex.ToString());
                return new Access();
            }
        }

        public static Access Impersonate(HttpContextBase context, string username, string password)
        {
            try
            {
                if (context == null
                    || string.IsNullOrWhiteSpace(username)
                    || string.IsNullOrWhiteSpace(password)
                    || !IsValid(username, password))
                {
                    return null;
                }

                // Retrieve it from session, if available
                var access = new Access();
                access.Username = username.ToUpper();
                access.IsImpersonating = true;

                context.Session["Access"] = access;
                return access;
            }
            catch (Exception ex)
            {
                Logs.Log(1, ex.ToString());
                return new Access();
            }
        }

        public static Access Logoff(HttpContextBase context)
        {
            context.Session["Access"] = null;
            return GetAccess(context);
        }

        private static bool IsValid(string username, string password)
        {
            using (var domain = new PrincipalContext(ContextType.Domain, Properties.Settings.Default.LdapServer))
            {
                return domain.ValidateCredentials(username.ToUpper(), password);
            }
        }

        #endregion
    }
}