using System;
using System.Linq;
using System.Data;
using System.Collections.Generic;
using System.Data.OracleClient;
using FlatFileLoaderUtility.Models;
using FlatFileLoaderUtility.Models.Shared;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace FlatFileLoaderUtility.Repositories.DataAccess
{
    public class MonitorRepository : BaseRepository, IMonitorRepository
    {
        #region constructor

        public MonitorRepository(RepositoryContainer container)
            : base(container)
        { }

        #endregion

        #region interface methods

        public List<Monitor> Load(string interfaceGroupCode, string interfaceTypeCode, string interfaceCode, int? licsId, string icsStatusCode, DateTime? startDate, DateTime? endDate, int startIndex, int pageSize, ref int total)
        {
            var userCode = this.Container.User.UserCode;
            using (var dal = new DataAccessMonitor(this.Container.DataAccess))
                return dal.Load(userCode, interfaceGroupCode, interfaceTypeCode, interfaceCode, licsId, icsStatusCode, startDate, endDate, startIndex, pageSize, ref total);
        }

        public List<Monitor> GetTraceHistory(int licsId)
        {
            var userCode = this.Container.User.UserCode;
            using (var dal = new DataAccessMonitor(this.Container.DataAccess))
                return dal.GetTrace(licsId, userCode);
        }

        public List<IcsError> GetInterfaceErrors(int licsId, int traceId)
        {
            var userCode = this.Container.User.UserCode;
            using (var dal = new DataAccessMonitor(this.Container.DataAccess))
                return dal.GetInterfaceErrors(licsId, traceId, userCode);
        }

        public List<IcsRowData> RowDataLoad(int licsId, int traceId, bool isErrorRowsOnly, int startIndex, int pageSize)
        {
            var userCode = this.Container.User.UserCode;
            using (var dal = new DataAccessMonitor(this.Container.DataAccess))
                return dal.RowDataLoad(userCode, licsId, traceId, isErrorRowsOnly, startIndex, pageSize);
        }

        #endregion

        #region classes

        private class DataAccessMonitor : DataAccess
        {
            #region constructors

            public DataAccessMonitor(DataAccess dataAccess)
                : base(dataAccess)
            {
            }

            #endregion

            #region methods

            public List<Monitor> Load(string userCode, string interfaceGroupCode, string interfaceTypeCode, string interfaceCode, int? licsId, string icsStatusCode, DateTime? startDate, DateTime? endDate, int startIndex, int pageSize, ref int total)
            {
                var result = new List<Monitor>();
                var dataset = new DataSet();

                // Start by getting the count of total rows
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "begin :result := " + Properties.Settings.Default.DatabasePackageName + ".get_xaction_count(:i_user_code, :i_interface_group_code, :i_interface_code, :i_interface_type_code, :i_xaction_seq, :i_xaction_status_code, :i_start_datetime, :i_end_datetime); end;";
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode;
                this.Command.Parameters.Add("i_interface_group_code", OracleType.VarChar, 32).Value = interfaceGroupCode.ToSqlNullable("*");
                this.Command.Parameters.Add("i_interface_code", OracleType.VarChar, 32).Value = interfaceCode.ToSqlNullable();
                this.Command.Parameters.Add("i_interface_type_code", OracleType.VarChar, 10).Value = interfaceTypeCode.ToSqlNullable();
                this.Command.Parameters.Add("i_xaction_seq", OracleType.Int32).Value = licsId.ToSqlNullable<int>();
                this.Command.Parameters.Add("i_xaction_status_code", OracleType.VarChar, 1).Value = icsStatusCode.ToSqlNullable("*");
                this.Command.Parameters.Add("i_start_datetime", OracleType.DateTime).Value = startDate.ToSqlNullable<DateTime>();
                this.Command.Parameters.Add("i_end_datetime", OracleType.DateTime).Value = endDate.ToSqlNullable<DateTime>();
                this.Command.Parameters.Add("result", OracleType.Int32).Direction = ParameterDirection.ReturnValue;
                this.Command.ExecuteNonQuery();

                total = Convert.ToInt32(this.Command.Parameters["result"].Value);

                // Remove the result parameter from the collection so that the other parameters can be re-used
                this.Command.Parameters.RemoveAt(this.Command.Parameters.Count - 1);

                // Now return the results for the requested page
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".get_xaction_list(:i_user_code, :i_interface_group_code, :i_interface_code, :i_interface_type_code, :i_xaction_seq, :i_xaction_status_code, :i_start_datetime, :i_end_datetime, :i_start_row, :i_no_rows))";
                this.Command.Parameters.Add("i_start_row", OracleType.Int32).Value = startIndex + 1;
                this.Command.Parameters.Add("i_no_rows", OracleType.Int32).Value = pageSize;
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                for (var i = 0; i < dataset.Tables[0].Rows.Count; i++)
                {
                    var item = new Monitor();
                    item.LicsId = Convert.ToInt32(dataset.Tables[0].Rows[i]["xaction_seq"]);
                    item.TraceId = Convert.ToInt32(dataset.Tables[0].Rows[i]["xaction_trace_seq"]);
                    item.FileName = dataset.Tables[0].Rows[i]["xaction_filename"].ToString();
                    item.UserCode = dataset.Tables[0].Rows[i]["xaction_user_code"].ToString();
                    item.InterfaceCode = dataset.Tables[0].Rows[i]["xaction_interface_code"].ToString();
                    item.InterfaceName = dataset.Tables[0].Rows[i]["xaction_interface_name"].ToString();
                    item.FileType = dataset.Tables[0].Rows[i]["xaction_filetype"].ToString();
                    item.CsvQualifier = dataset.Tables[0].Rows[i]["xaction_csv_qualifier"].ToString();
                    item.StartTime = dataset.Tables[0].Rows[i]["xaction_start_datetime"].ToNullable<DateTime>();
                    item.EndTime = dataset.Tables[0].Rows[i]["xaction_end_datetime"].ToNullable<DateTime>();
                    item.Status = dataset.Tables[0].Rows[i]["xaction_status"].ToString();
                    item.RecordCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[i]["xaction_row_count"]);
                    item.RowInErrorCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[i]["xaction_rows_in_error"]);
                    item.RowErrorCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[i]["xaction_row_errors"]);
                    item.InterfaceErrorCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[i]["xaction_int_errors"]);
                    result.Add(item);
                }

                return result;
            }

            public List<Monitor> GetTrace(int licsId, string userCode)
            {
                var result = new List<Monitor>();
                var dataset = new DataSet();

                // Start by getting the count of total rows
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".get_xaction_trace_list(:i_user_code, :i_xaction_seq))";
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode;
                this.Command.Parameters.Add("i_xaction_seq", OracleType.Int32).Value = licsId;
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                for (var i = 0; i < dataset.Tables[0].Rows.Count; i++)
                {
                    var item = new Monitor();
                    item.LicsId = Convert.ToInt32(dataset.Tables[0].Rows[i]["xaction_seq"]);
                    item.TraceId = Convert.ToInt32(dataset.Tables[0].Rows[i]["xaction_trace_seq"]);
                    item.FileName = dataset.Tables[0].Rows[i]["xaction_filename"].ToString();
                    item.UserCode = dataset.Tables[0].Rows[i]["xaction_user_code"].ToString();
                    item.InterfaceCode = dataset.Tables[0].Rows[i]["xaction_interface_code"].ToString();
                    item.InterfaceName = dataset.Tables[0].Rows[i]["xaction_interface_name"].ToString();
                    item.FileType = dataset.Tables[0].Rows[i]["xaction_filetype"].ToString();
                    item.CsvQualifier = dataset.Tables[0].Rows[i]["xaction_csv_qualifier"].ToString();
                    item.StartTime = dataset.Tables[0].Rows[i]["xaction_start_datetime"].ToNullable<DateTime>();
                    item.EndTime = dataset.Tables[0].Rows[i]["xaction_end_datetime"].ToNullable<DateTime>();
                    item.Status = dataset.Tables[0].Rows[i]["xaction_status"].ToString();
                    item.RecordCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[i]["xaction_row_count"]);
                    item.RowInErrorCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[i]["xaction_rows_in_error"]);
                    item.RowErrorCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[i]["xaction_row_errors"]);
                    item.InterfaceErrorCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[i]["xaction_int_errors"]);
                    result.Add(item);
                }

                return result;
            }

            public List<IcsError> GetInterfaceErrors(int licsId, int traceId, string userCode)
            {
                var result = new List<IcsError>();
                var dataset = new DataSet();

                // Start by getting the count of total rows
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".get_xaction_errors(:i_user_code, :i_xaction_seq, :i_xaction_trace_seq))";
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode; 
                this.Command.Parameters.Add("i_xaction_seq", OracleType.Int32).Value = licsId;
                this.Command.Parameters.Add("i_xaction_trace_seq", OracleType.Int32).Value = traceId;
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                for (var i = 0; i < dataset.Tables[0].Rows.Count; i++)
                {
                    var item = new IcsError();
                    item.Sequence = Convert.ToInt32(dataset.Tables[0].Rows[i]["xaction_msg_seq"]);
                    item.Message = dataset.Tables[0].Rows[i]["xaction_msg"].ToString();

                    // The message may be in json format and need to be re-built as a string
                    // Best not to ask why. Some things just are.
                    if (item.Message.IndexOf("{") == 0) // Assume json
                    {
                        try
                        {
                            dynamic json = JObject.Parse(item.Message);
                            item.Label = json["label"];
                            item.Value = json["value"];
                            item.Message = json["message"];
                        }
                        catch (Exception ex) 
                        {
                            Logs.Log(5, "Failed to parse json returned from API: " + item.Message + Environment.NewLine + "Exception: " + ex.ToString());
                        }
                    }

                    result.Add(item);
                }

                return result;
            }

            public List<IcsRowData> RowDataLoad(string userCode, int licsId, int traceId, bool isErrorRowsOnly, int startIndex, int pageSize)
            {
                var result = new List<IcsRowData>();
                var dataset = new DataSet();
                var functionName = (isErrorRowsOnly) ? "get_xaction_data_with_errors" : "get_xaction_data";

                // Start by getting the count of total rows
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + "." + functionName + "(:i_user_code, :i_xaction_seq, :i_xaction_trace_seq, :i_start_row, :i_no_rows))";
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode;
                this.Command.Parameters.Add("i_xaction_seq", OracleType.Int32).Value = licsId;
                this.Command.Parameters.Add("i_xaction_trace_seq", OracleType.Int32).Value = traceId;
                this.Command.Parameters.Add("i_start_row", OracleType.Int32).Value = startIndex + 1;
                this.Command.Parameters.Add("i_no_rows", OracleType.Int32).Value = pageSize;
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                for (var i = 0; i < dataset.Tables[0].Rows.Count; i++)
                {
                    var item = new IcsRowData();
                    item.Row = Convert.ToInt32(dataset.Tables[0].Rows[i]["xaction_row"]);
                    item.Data = dataset.Tables[0].Rows[i]["xaction_data"].ToString();
                    item.ErrorCount = Convert.ToInt32(dataset.Tables[0].Rows[i]["xaction_errors"]);
                    result.Add(item);
                }

                if (result.Count == 0)
                    return result;

                // Remove the last two parameters
                this.Command.Parameters.RemoveAt(this.Command.Parameters.Count - 1);
                this.Command.Parameters.RemoveAt(this.Command.Parameters.Count - 1);

                // Clear the dataset
                dataset = new DataSet();

                // Get the first and last datarows
                var firstRow = result.Min(x => x.Row);
                var lastRow = result.Max(x => x.Row);

                // Now return the results for the requested page
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".get_xaction_data_errors_by_pge(:i_user_code, :i_xaction_seq, :i_xaction_trace_seq, :i_from_data_row, :i_to_data_row))";
                this.Command.Parameters.Add("i_from_data_row", OracleType.Int32).Value = firstRow;
                this.Command.Parameters.Add("i_to_data_row", OracleType.Int32).Value = lastRow;
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                for (var i = 0; i < dataset.Tables[0].Rows.Count; i++)
                {
                    var item = new IcsError();
                    item.Sequence = Convert.ToInt32(dataset.Tables[0].Rows[i]["xaction_msg_seq"]);
                    item.Message = dataset.Tables[0].Rows[i]["xaction_msg"].ToString();

                    // The message may be in json format
                    if (item.Message.IndexOf("{") == 0) // Assume json
                    {
                        try
                        {
                            dynamic json = JObject.Parse(item.Message);
                            item.Label = json["label"];
                            item.Value = json["value"];
                            item.Message = json["message"];
                            if (json["column"] != null)
                            {
                                item.Position = Tools.ZeroInvalidInt(json["column"]);
                            }
                            else if (json["position"] != null)
                            {
                                item.Position = Tools.ZeroInvalidInt(json["position"]);
                                item.Length = Tools.ZeroInvalidInt(json["length"]);
                            }
                        }
                        catch (Exception ex)
                        {
                            Logs.Log(5, "Failed to parse json returned from API: " + item.Message + Environment.NewLine + "Exception: " + ex.ToString());
                        }
                    }

                    var rowNumber = Convert.ToInt32(dataset.Tables[0].Rows[i]["xaction_data_row"]);
                    var dataRow = result.Where(x => x.Row == rowNumber).FirstOrDefault();

                    if (dataRow != null)
                        dataRow.Errors.Add(item);
                }

                // The errors have to be ordered by position but there's no guarantee they arrive ordered from the database
                foreach (var row in result)
                {
                    row.Errors = row.Errors.OrderBy(x => x.Position).ToList();
                }

                return result;
            }

            #endregion
        }

        #endregion
    }
}