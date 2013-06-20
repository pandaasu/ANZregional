using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using System.Data.OracleClient;
using System.Web;
using FlatFileLoaderUtility.Models;
using FlatFileLoaderUtility.Models.Shared;

namespace FlatFileLoaderUtility.Repositories.DataAccess
{
    public class UploadRepository : BaseRepository, IUploadRepository
    {
        #region constructor

        public UploadRepository(RepositoryContainer container)
            : base(container)
        { }

        #endregion

        #region interface methods

        public int Start(string interfaceCode, string fileName)
        {
            var userCode = this.Container.User.UserCode;
            using (var dal = new DataAccessUpload(this.Container.DataAccess))
                return dal.Start(userCode, interfaceCode, fileName);
        }

        public void LoadSegment(int uploadId, string interfaceCode, string fileName, int segmentNumber, int segmentSize, int segmentRows, string segmentData)
        {
            var userCode = this.Container.User.UserCode;
            using (var dal = new DataAccessUpload(this.Container.DataAccess))
                dal.LoadSegment(uploadId, userCode, interfaceCode, fileName, segmentNumber, segmentSize, segmentRows, segmentData);
        }

        public void Cancel(int uploadId, string interfaceCode, string fileName)
        {
            var userCode = this.Container.User.UserCode;
            using (var dal = new DataAccessUpload(this.Container.DataAccess))
                dal.Cancel(uploadId, userCode, interfaceCode, fileName);
        }

        public void Complete(int uploadId, string interfaceCode, string fileName, int segmentCount, int rowCount)
        {
            var userCode = this.Container.User.UserCode;
            using (var dal = new DataAccessUpload(this.Container.DataAccess))
                dal.Complete(uploadId, userCode, interfaceCode, fileName, segmentCount, rowCount);
        }

        public void GetUploadStatus(int uploadId, ref Status status)
        {
            var userCode = this.Container.User.UserCode; 
            using (var dal = new DataAccessUpload(this.Container.DataAccess))
                dal.GetUploadStatus(uploadId, userCode, ref status);
        }

        public void GetLicsStatus(int licsId, ref Status status)
        {
            var userCode = this.Container.User.UserCode;
            using (var dal = new DataAccessUpload(this.Container.DataAccess))
                dal.GetLicsStatus(licsId, userCode, ref status);
        }

        #endregion

        #region classes

        private class DataAccessUpload : DataAccess
        {
            #region constructors

            public DataAccessUpload(DataAccess dataAccess)
                : base(dataAccess)
            {
            }

            #endregion

            #region methods

            public int Start(string userCode, string interfaceCode, string fileName)
            {
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "begin :result := " + Properties.Settings.Default.DatabasePackageName + ".load_start(:i_user_code, :i_interface_code, :i_file_name); end;";
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode;
                this.Command.Parameters.Add("i_interface_code", OracleType.VarChar, 32).Value = interfaceCode;
                this.Command.Parameters.Add("i_file_name", OracleType.VarChar, 64).Value = fileName;
                this.Command.Parameters.Add("result", OracleType.Int32).Direction = ParameterDirection.ReturnValue;
                this.Command.ExecuteNonQuery();
                this.Transaction.Commit();

                return Convert.ToInt32(this.Command.Parameters["result"].Value);
            }

            public void Complete(int uploadId, string userCode, string interfaceCode, string fileName, int segmentCount, int rowCount)
            {
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.StoredProcedure;
                this.Command.CommandText = Properties.Settings.Default.DatabasePackageName + ".load_complete";
                this.Command.Parameters.Add("i_load_sequence", OracleType.Int32).Value = uploadId;
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode;
                this.Command.Parameters.Add("i_interface_code", OracleType.VarChar, 32).Value = interfaceCode;
                this.Command.Parameters.Add("i_file_name", OracleType.VarChar, 64).Value = fileName;
                this.Command.Parameters.Add("i_seg_count", OracleType.Int32).Value = segmentCount;
                this.Command.Parameters.Add("i_seg_rows", OracleType.Int32).Value = rowCount; 
                this.Command.ExecuteNonQuery();
                this.Transaction.Commit();
            }

            public void Cancel(int uploadId, string userCode, string interfaceCode, string fileName)
            {
                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.StoredProcedure;
                this.Command.CommandText = Properties.Settings.Default.DatabasePackageName + ".load_cancel";
                this.Command.Parameters.Add("i_load_sequence", OracleType.Int32).Value = uploadId; 
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode;
                this.Command.Parameters.Add("i_interface_code", OracleType.VarChar, 32).Value = interfaceCode;
                this.Command.Parameters.Add("i_file_name", OracleType.VarChar, 64).Value = fileName;
                this.Command.ExecuteNonQuery();
                this.Transaction.Commit();
            }

            public void LoadSegment(int uploadId, string userCode, string interfaceCode, string fileName, int segmentNumber, int segmentSize, int segmentRows, string segmentData)
            {
                // Convert to unicode byte array
                var encoding = new UnicodeEncoding();
                var buffer = encoding.GetBytes(segmentData);

                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "declare xx nclob; begin dbms_lob.createtemporary(xx, false, 0); :tempclob := xx; end;";
                this.Command.Parameters.Clear();
                this.Command.Parameters.Add("tempclob", OracleType.NClob).Direction = ParameterDirection.Output;
                this.Command.ExecuteNonQuery();

                var tempLob = (OracleLob)this.Command.Parameters[0].Value;
                tempLob.BeginBatch(OracleLobOpenMode.ReadWrite);
                tempLob.Write(buffer, 0, buffer.Length);
                tempLob.EndBatch();

                this.Command.CommandType = CommandType.StoredProcedure;
                this.Command.CommandText = Properties.Settings.Default.DatabasePackageName + ".load_segment";
                this.Command.Parameters.Clear();
                this.Command.Parameters.Add("i_load_sequence", OracleType.Int32).Value = uploadId;
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode;
                this.Command.Parameters.Add("i_interface_code", OracleType.VarChar, 32).Value = interfaceCode;
                this.Command.Parameters.Add("i_file_name", OracleType.VarChar, 64).Value = fileName;
                this.Command.Parameters.Add("i_seg_count", OracleType.Int32).Value = segmentNumber;
                this.Command.Parameters.Add("i_seg_size", OracleType.Int32).Value = Encoding.UTF8.GetByteCount(segmentData);
                this.Command.Parameters.Add("i_seg_rows", OracleType.Int32).Value = segmentRows;
                this.Command.Parameters.Add("i_seg_data", OracleType.NClob).Value = tempLob;
                this.Command.ExecuteNonQuery();
                this.Transaction.Commit();

                // I don't usually do this... but the below have been very useful for debugging a couple of issues
                // So I'm going to leave them there.
                //using (var streamWriter = new StreamWriter(@"C:\test.csv", true, Encoding.UTF8))
                //{
                //    streamWriter.Write(segmentData);
                //}
                //using (var writer = new FileStream(@"C:\test.csv", FileMode.Create))
                //{
                //    writer.Write(buffer, 0, buffer.Length);
                //}
            }

            public void GetUploadStatus(int uploadId, string userCode, ref Status status)
            {
                var dataset = new DataSet();

                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".load_monitor(:i_user_code, :i_load_sequence))";
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode;
                this.Command.Parameters.Add("i_load_sequence", OracleType.Int32).Value = uploadId;
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                if (dataset.Tables[0].Rows.Count > 0)
                {
                    status.CompletedRowCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[0]["rows_complete"]);
                    status.LicsId = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[0]["lics_int_sequence"]);
                    status.EstimatedSeconds = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[0]["estimated_time"]);
                }
            }

            public void GetLicsStatus(int licsId, string userCode, ref Status status)
            {
                var dataset = new DataSet();

                this.Command = new OracleCommand();
                this.Command.Connection = this.Connection;
                this.Command.Transaction = this.Transaction;
                this.Command.CommandType = CommandType.Text;
                this.Command.CommandText = "select * from table(" + Properties.Settings.Default.DatabasePackageName + ".lics_monitor(:i_user_code, :i_xaction_seq))";
                this.Command.Parameters.Add("i_user_code", OracleType.VarChar, 30).Value = userCode;
                this.Command.Parameters.Add("i_xaction_seq", OracleType.Int32).Value = licsId;
                this.Adapter = new OracleDataAdapter(this.Command);
                this.Adapter.Fill(dataset);

                if (dataset.Tables[0].Rows.Count > 0)
                {
                    status.CompletedRowCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[0]["rows_complete"]);
                    status.InterfaceErrorCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[0]["int_errors"]);
                    status.RowErrorCount = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[0]["rows_in_error"]);
                    status.LicsStatus = dataset.Tables[0].Rows[0]["lics_status"].ToString();
                    status.EstimatedSeconds = Tools.ZeroInvalidInt(dataset.Tables[0].Rows[0]["estimated_time"]);

                    // The TotalRowCount will only be 0 if this is status request from the monitor view page
                    // In which case, it's ok for th TotalRowCount to be 0. It just means the progress bar won't start
                    // but if the percent_complete is 0 then it hasn't started anyway.
                    if (status.TotalRowCount == 0 && Tools.ZeroInvalidInt(dataset.Tables[0].Rows[0]["percent_complete"]) > 0)
                        status.TotalRowCount = (status.CompletedRowCount * 100) / Tools.ZeroInvalidInt(dataset.Tables[0].Rows[0]["percent_complete"]);
                }
            }

            #endregion
        }

        #endregion
    }
}