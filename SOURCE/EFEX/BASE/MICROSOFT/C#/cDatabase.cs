/// <summary> 
/// Type   : Class
/// Name   : cDatabase
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

   using System;
   using System.IO;
   using System.Text;
   using System.Data;
   using System.Data.OracleClient;

	/// <summary>
   /// This class implements the database functionality
	/// </summary>
   public class cDatabase {
   
      /// <summary>
      /// Processes the download request
      /// </summary>
      /// <returns>string the download return string</returns>
      /// <param name="strUserName">the request user name</param>
      /// <param name="strPassword">the request password</param>
      /// <param name="strConnectionPath">the request connectionpath</param>
      /// <param name="strTableFunction">the request table function</param>
      protected internal string ProcessDownloadRequest(string strUserName, string strPassword, string strConnectionPath, string strTableFunction) {

         //
         // Local declarations
         //
         OracleConnection objConnection = null;
         OracleCommand objCommand = null;
         OracleDataReader objDataReader = null;
         StringBuilder objReturnStream = null;
         string strExceptionMessage = null;

         //
         // Exception trap
         //
         try {

            //
            // Retrieve the connection string from the file system
            //
            StreamReader objConnectionReader = File.OpenText(strConnectionPath);
            string strConnectionString = objConnectionReader.ReadToEnd();
            objConnectionReader.Close();
            objConnectionReader = null;

            //
            // Attempt to connect to the database
            //
            objConnection = new OracleConnection();
            objConnection.ConnectionString = strConnectionString;
            objConnection.Open();

            //
            // Authenticate the user identifier
            //
            objCommand = new OracleCommand();
            objCommand.Connection = objConnection;
            objCommand.CommandText = "begin :ReturnValue := mobile_data.authenticate_session(:UserName, :Password); end;";
            objCommand.CommandType = CommandType.Text;
            objCommand.Parameters.Add("UserName", OracleType.VarChar, 32).Direction = ParameterDirection.Input;
            objCommand.Parameters.Add("Password", OracleType.VarChar, 32).Direction = ParameterDirection.Input;
            objCommand.Parameters.Add("ReturnValue", OracleType.VarChar, 2000).Direction = ParameterDirection.ReturnValue;
            objCommand.Parameters["UserName"].Value = strUserName;
            objCommand.Parameters["Password"].Value = strPassword;
            objCommand.ExecuteNonQuery();
            if (!objCommand.Parameters["ReturnValue"].Value.ToString().Equals("*OK")) {
               throw new ApplicationException(objCommand.Parameters["ReturnValue"].Value.ToString());
            }
            objCommand.Dispose();
            objCommand = null;

            //
            // Execute the download request
            //
            try {
               objCommand = new OracleCommand();
               objCommand.Connection = objConnection;
               objCommand.CommandType = CommandType.Text;
               objCommand.CommandText = "select * from table(" + strTableFunction + ")";
               objDataReader = objCommand.ExecuteReader();
               objReturnStream = new StringBuilder();
               while (objDataReader.Read()) {
                  objReturnStream.Append((string)objDataReader[0]);
               }
               objDataReader.Close();
               objDataReader.Dispose();
               objCommand.Dispose();
               objDataReader = null;
               objCommand = null;
            } catch (Exception objException) {
               strExceptionMessage = objException.Message + "\n\n(Trace)\n " + objException.StackTrace;
            }

            //
            // Destroy the user session
            //
            try {
               objCommand = new OracleCommand();
               objCommand.Connection = objConnection;
               objCommand.CommandText = "begin mobile_data.destroy_session('*OK'); end;";
               if (strExceptionMessage != null && !strExceptionMessage.Equals("")) {
                  objCommand.CommandText = "begin mobile_data.destroy_session('*FAILED'); end;";
               }
               objCommand.CommandType = CommandType.Text;
               objCommand.ExecuteNonQuery();
               objCommand.Dispose();
               objCommand = null;
            } catch (Exception objException) {
               if (strExceptionMessage != null && !strExceptionMessage.Equals("")) {
                  strExceptionMessage = strExceptionMessage + " (Destroy Session): " + objException.Message + "\n\n(Trace)\n " + objException.StackTrace;
               } else {
                  strExceptionMessage = objException.Message + "\n\n(Trace)\n " + objException.StackTrace;
               }
            }

            //
            // Bubble the exception message when required
            //
            if (strExceptionMessage != null && !strExceptionMessage.Equals("")) {
               throw new ApplicationException(strExceptionMessage);
            }

            //
            // Return the data stream string
            //
            return objReturnStream.ToString();

         } catch (ApplicationException objApplicationException) {
            throw objApplicationException;
         } catch (Exception objException) {
            throw objException;
         } finally {
            if (objConnection != null) {
               if (objConnection.State != ConnectionState.Closed) {
                  objConnection.Close();
               }
               objConnection.Dispose();
            }
            if (objCommand != null) {
               objCommand.Dispose();
            }
            if (objDataReader != null) {
               objDataReader.Dispose();
            }
            objConnection = null;
            objCommand = null;
            objDataReader = null;
         }

      }

      /// <summary>
      /// Processes the upload request
      /// </summary>
      /// <param name="strUserName">the request user name</param>
      /// <param name="strPassword">the request password</param>
      /// <param name="strConnectionPath">the request connection path</param>
      /// <param name="strUploadFunction">the upload function</param>
      /// <param name="strUploadStream">the upload function</param>
      protected internal void ProcessUploadRequest(string strUserName, string strPassword, string strConnectionPath, string strUploadFunction, string strUploadStream) {

         //
         // Local declarations
         //
         OracleConnection objConnection = null;
         OracleCommand objCommand = null;
         string strExceptionMessage = null;

         //
         // Exception trap
         //
         try {

            //
            // Retrieve the connection string from the file system
            //
            StreamReader objConnectionReader = File.OpenText(strConnectionPath);
            string strConnectionString = objConnectionReader.ReadToEnd();
            objConnectionReader.Close();
            objConnectionReader = null;

            //
            // Attempt to connect to the database
            //
            objConnection = new OracleConnection();
            objConnection.ConnectionString = strConnectionString;
            objConnection.Open();

            //
            // Authenticate the user identifier
            //
            objCommand = new OracleCommand();
            objCommand.Connection = objConnection;
            objCommand.CommandText = "begin :ReturnValue := mobile_data.authenticate_session(:UserName, :Password); end;";
            objCommand.CommandType = CommandType.Text;
            objCommand.Parameters.Add("UserName", OracleType.VarChar, 32).Direction = ParameterDirection.Input;
            objCommand.Parameters.Add("Password", OracleType.VarChar, 32).Direction = ParameterDirection.Input;
            objCommand.Parameters.Add("ReturnValue", OracleType.VarChar, 2000).Direction = ParameterDirection.ReturnValue;
            objCommand.Parameters["UserName"].Value = strUserName;
            objCommand.Parameters["Password"].Value = strPassword;
            objCommand.ExecuteNonQuery();
            if (!objCommand.Parameters["ReturnValue"].Value.ToString().Equals("*OK")) {
               throw new ApplicationException(objCommand.Parameters["ReturnValue"].Value.ToString());
            }
            objCommand.Dispose();
            objCommand = null;

            //
            // Process the upload
            //
            try {

               //
               // Upload the data stream
               //
               objCommand = new OracleCommand();
               objCommand.Connection = objConnection;
               objCommand.CommandText = "begin mobile_data.put_buffer(:DataValue); end;";
               objCommand.CommandType = CommandType.Text;
               objCommand.Parameters.Add("DataValue", OracleType.VarChar, 2000).Direction = ParameterDirection.Input;
               objCommand.Prepare();
               objCommand.Parameters["DataValue"].Value = "*STR";
               objCommand.ExecuteNonQuery();
               if (strUploadStream.Length != 0) {
                  int intIndex = 0;
                  int intLength = strUploadStream.Length;
                  int intWork = 0;
                  while (intIndex < strUploadStream.Length) {
                     intWork = 2000;
                     if (intLength < 2000) {
                        intWork = intLength;
                     }
                     objCommand.Parameters["DataValue"].Value = strUploadStream.Substring(intIndex, intWork);
                     objCommand.ExecuteNonQuery();
                     intIndex = intIndex + intWork;
                     intLength = intLength - intWork;
                  }
               }
               objCommand.Dispose();
               objCommand = null;

               //
               // Execute the upload request
               //
               objCommand = new OracleCommand();
               objCommand.Connection = objConnection;
               objCommand.CommandType = CommandType.Text;
               objCommand.CommandText = "begin " + strUploadFunction + "; end;";
               objCommand.ExecuteNonQuery();
               objCommand.Dispose();
               objCommand = null;

            } catch (Exception objException) {
               strExceptionMessage = objException.Message + "\n\n(Trace)\n " + objException.StackTrace;
            }

            //
            // Destroy the user session
            //
            try {
               objCommand = new OracleCommand();
               objCommand.Connection = objConnection;
               objCommand.CommandText = "begin mobile_data.destroy_session('*OK'); end;";
               if (strExceptionMessage != null && !strExceptionMessage.Equals("")) {
                  objCommand.CommandText = "begin mobile_data.destroy_session('*FAILED'); end;";
               }
               objCommand.CommandType = CommandType.Text;
               objCommand.ExecuteNonQuery();
               objCommand.Dispose();
               objCommand = null;
            } catch (Exception objException) {
               if (strExceptionMessage != null && !strExceptionMessage.Equals("")) {
                  strExceptionMessage = strExceptionMessage + " (Destroy Session): " + objException.Message + "\n\n(Trace)\n " + objException.StackTrace;
               } else {
                  strExceptionMessage = objException.Message + "\n\n(Trace)\n " + objException.StackTrace;
               }
            }

            //
            // Bubble the exception message when required
            //
            if (strExceptionMessage != null && !strExceptionMessage.Equals("")) {
               throw new ApplicationException(strExceptionMessage);
            }

         } catch (ApplicationException objApplicationException) {
            throw objApplicationException;
         } catch (Exception objException) {
            throw objException;
         } finally {
            if (objConnection != null) {
               if (objConnection.State != ConnectionState.Closed) {
                  objConnection.Close();
               }
               objConnection.Dispose();
            }
            if (objCommand != null) {
               objCommand.Dispose();
            }
            objConnection = null;
            objCommand = null;
         }

      }
		
   }

}