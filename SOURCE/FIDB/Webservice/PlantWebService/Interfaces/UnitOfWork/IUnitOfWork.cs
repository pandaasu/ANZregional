using System;
using System.Threading.Tasks;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using System.Data.SqlClient;

namespace PlantWebService.Interfaces.UnitOfWork
{
    public partial interface IUnitOfWork : IDisposable
    {
        void OpenConnection();
        void Commit();
        void Rollback();

        OracleConnection OracleConnection { get; set; }
        OracleTransaction OracleTransaction { get; set; }
        SqlConnection SqlConnection { get; set; }
        SqlTransaction SqlTransaction { get; set; }
    }
}
