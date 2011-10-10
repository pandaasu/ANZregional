/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : cSapVds21
 * Author  : Steve Gregan
 * Date    : March 2010
 */
package com.isi.vds;
import com.isi.ods.*;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;
import java.sql.*;

/**
 * This class implements the SAP reference extract functionality. This functionality
 * extracts the requested reference tables as a full replacement.
 */
public final class cSapVds21 implements iSapVdsExtract {
   
   //
   // Declare the class variable
   //
   cSapConnection cobjSapConnection = null;
   Connection cobjOracleConnection = null;
   String cstrDatReplace;
   int cintDatCount;
   String cstrSapClient;
   String cstrSapUserId;
   String cstrSapPassword;
   String cstrSapLanguage;
   String cstrSapServer;
   String cstrSapSystem;
   String cstrVdsConnection;
   String cstrVdsUserId;
   String cstrVdsPassword;
   String cstrVdsQuery;
   String cstrVdsTables;
   String[] cstrTableNames;
   String cstrLogging = null;
   PrintWriter cobjPrintWriter;
   
   /**
    * Processes the SAP to VDS reference extract.
    * **NOTE**
    * The SAP connection is reestablished at logical points in the processing
    * to overcome SAP internal space issues. The connection is reestablished
    * before the retrieval of the data groups - eg. *FULL100, *DATA1000
    * @throws Exception the exception message
    */
   public void process(HashMap objParameters, String strReplace) throws Exception {
      
      //
      // Initialise the class variables
      //
      cobjSapConnection = null;
      cobjOracleConnection = null;
      cstrLogging = null;
      
      //
      // Retrieve any interface specific parameters
      //
      if (strReplace == null || strReplace.equals("") || strReplace.length() < 5) {
         cstrDatReplace = "*FULL";
         cintDatCount = 1000;
      } else if (strReplace.length() == 5) {
         cstrDatReplace = strReplace.substring(0,5);
         cintDatCount = 1000;
      } else {
         cstrDatReplace = strReplace.substring(0,5);
         try {
            cintDatCount = Integer.parseInt(strReplace.substring(5));
         } catch(Throwable objThrowable) {
            cintDatCount = 1000;
         }
      }
      if (!cstrDatReplace.equals("*META") && !cstrDatReplace.equals("*FULL")) {
         cstrDatReplace = "*FULL";
      }
      cstrSapClient = (String)objParameters.get("SAPCLIENT");
      cstrSapUserId = (String)objParameters.get("SAPUSERID");
      cstrSapPassword = (String)objParameters.get("SAPPASSWORD");
      cstrSapLanguage = (String)objParameters.get("SAPLANGUAGE");
      cstrSapServer = (String)objParameters.get("SAPSERVER");
      cstrSapSystem = (String)objParameters.get("SAPSYSTEM");
      cstrVdsConnection = (String)objParameters.get("VDSCONNECTION");
      cstrVdsUserId = (String)objParameters.get("VDSUSERID");
      cstrVdsPassword = (String)objParameters.get("VDSPASSWORD");
      cstrVdsQuery = (String)objParameters.get("VDS_QUERY");
      cstrVdsTables = (String)objParameters.get("VDS_TABLES");
      cstrLogging = (String)objParameters.get("LOGGING");
      if (cstrSapClient == null) {
         throw new Exception("VDS Reference Extract - SAP connection client not supplied in configuration file");
      }
      if (cstrSapUserId == null) {
         throw new Exception("VDS Reference Extract - SAP connection user id not supplied in configuration file");
      }
      if (cstrSapPassword == null) {
         throw new Exception("VDS Reference Extract - SAP connection password not supplied in configuration file");
      }
      if (cstrSapLanguage == null) {
         throw new Exception("VDS Reference Extract - SAP connection language not supplied in configuration file");
      }
      if (cstrSapServer == null) {
         throw new Exception("VDS Reference Extract - SAP connection server not supplied in configuration file");
      }
      if (cstrSapSystem == null) {
         throw new Exception("VDS Reference Extract - SAP connection system not supplied in configuration file");
      }
      if (cstrVdsConnection == null) {
         throw new Exception("VDS Reference Extract - VDS connection string not supplied in configuration file");
      }
      if (cstrVdsUserId == null) {
         throw new Exception("VDS Reference Extract - VDS user id not supplied in configuration file");
      }
      if (cstrVdsPassword == null) {
         throw new Exception("VDS Reference Extract - VDS password not supplied in configuration file");
      }
      if (cstrVdsQuery == null || cstrVdsQuery.toUpperCase().equals("*NONE")) {
         throw new Exception("VDS Reference Extract - VDS query must be supplied");
      }
      if (cstrVdsTables == null) {
         throw new Exception("VDS Reference Extract - VDS tables must be supplied");
      }
      cstrTableNames = cstrVdsTables.split(",");
      if (cstrLogging != null) {
         cobjPrintWriter = new PrintWriter(new FileWriter(cstrLogging, false));
      }
      
      //
      // Start log
      //
      if (cstrLogging != null) {
         cobjPrintWriter.print("Start VDS Reference Extract ("+strReplace+") becomes ("+cstrDatReplace+" / "+cintDatCount+") : " + Calendar.getInstance().getTime()); 
         cobjPrintWriter.flush();
      }
      
      //
      // Monitor exceptions
      //
      try {

         //////////////////////////////////////////
         // Step 1 - Connect to the ODS database //
         //////////////////////////////////////////
         
         //
         // Create an Oracle thin JDBC connection
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("==> Start VDS Connection: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cobjOracleConnection = DriverManager.getConnection(cstrVdsConnection, cstrVdsUserId, cstrVdsPassword);
            cobjOracleConnection.setAutoCommit(false);
         } catch(Exception objException) {
            throw new Exception("VDS Oracle connection failed - " + objException.getMessage());
         }
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("==> End VDS Connection: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
         ///////////////////////////////////////////
         // Step 2 - Perform the required extract //
         ///////////////////////////////////////////
         
         if (cstrDatReplace.equals("*META")) {
            extractMeta();
         } else {
            extractData();
         }
         
      } catch(Exception objException) {
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("VDS Reference Extract - " + objException.getMessage());
            cobjPrintWriter.close();
         }
         throw new Exception("VDS Reference Extract - " + objException.getMessage());
      } finally {
         if (cobjSapConnection != null) {
            cobjSapConnection.disconnect();
         }
         cobjSapConnection = null;
         if (cobjOracleConnection != null) {
            cobjOracleConnection.close();
         }
         cobjOracleConnection = null;
      }
      
      //
      // End log
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("End VDS Reference Extract: " + Calendar.getInstance().getTime());
         cobjPrintWriter.close();
      }
         
   }
   
   /**
    * Processes the meta request.
    * @throws Exception the exception message
    */
   private void extractMeta() throws Exception {
      
      cSapSingleQuery objSapSingleQuery = null;
      CallableStatement objOracleStatement = null;
      ArrayList objWorkREFNR = null;
      
      //
      // Start REFN meta retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> Start Meta Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
      //
      // Exception trap
      //
      try {
         
         //
         // SAP connection
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start SAP Connection: " + Calendar.getInstance().getTime()); 
            cobjPrintWriter.flush();
         }
         try {
            cobjSapConnection =  new cSapConnection(cstrSapClient, cstrSapUserId, cstrSapPassword, cstrSapLanguage, cstrSapServer, cstrSapSystem);
         } catch(Exception objException) {
            throw new Exception("SAP Connection failed - " + objException.getMessage());
         }
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End SAP Connection: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
         //
         // VDS start meta
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start vds_extract.start_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.start_meta(?)}");
         objOracleStatement.setString(1, cstrVdsQuery);
         objOracleStatement.execute();
         objOracleStatement.close();
         objOracleStatement = null;
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End vds_extract.start_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
         //
         // SAP retrieve meta
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start retrieve SAP meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
         for (int i=0; i<cstrTableNames.length; i++) {
            objSapSingleQuery.execute(cstrTableNames[i].toUpperCase(), cstrTableNames[i].toUpperCase(), "*", new String[0], 0, 1);
         }
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End retrieve SAP meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
         //
         // VDS update meta
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start vds_extract.update_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objWorkREFNR = objSapSingleQuery.getResultSet().getMetaData().toList();
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.update_meta(?,?)}");
         for (int j=0; j<objWorkREFNR.size(); j++) {
            objOracleStatement.setString(1, cstrVdsQuery);
            objOracleStatement.setString(2, (String)objWorkREFNR.get(j));
            objOracleStatement.execute();
         }
         objOracleStatement.close();
         objOracleStatement = null;
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End vds_extract.update_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }

         //
         // VDS final meta
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start vds_extract.final_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.final_meta(?)}");
         objOracleStatement.setString(1, cstrVdsQuery);
         objOracleStatement.execute();
         objOracleStatement.close();
         objOracleStatement = null;
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End vds_extract.final_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
      } catch(Exception objException) {
         throw new Exception("Meta retrieval failed - " + objException.getMessage());
      } finally {
         objSapSingleQuery = null;
         if (cobjSapConnection != null) {
            cobjSapConnection.disconnect();
         }
         cobjSapConnection = null;
         if (objOracleStatement != null) {
            objOracleStatement.close();
         }
         objOracleStatement = null;
      }
      
      //
      // End REFN meta retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> End Meta Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
   }
   
   /**
    * Processes the data request.
    * @throws Exception the exception message
    */
   private void extractData() throws Exception {
      
      cSapSingleQuery objSapSingleQuery = null;
      CallableStatement objOracleStatement = null;
      int intRowSkips = 0;
      int intRowCount = 0;
      boolean bolRead = true;
      ArrayList objWorkREFNR = null;

      //
      // Start REFN data retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> Start Data Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
         
      //
      // Initialise the work array
      //
      objWorkREFNR = new ArrayList();
      
      //
      // Clear the document list
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start vds_extract.clear_list: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      try {
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.clear_list(?)}");
         objOracleStatement.setString(1, cstrVdsQuery);
         objOracleStatement.execute();
      } catch(Exception objException) {
         throw new Exception("Data retrieval failed - " + objException.getMessage());
      } finally {
         if (objOracleStatement != null) {
            objOracleStatement.close();
         }
         objOracleStatement = null;
      }
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> End vds_extract.clear_list: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
         
      //
      // SAP retrieve data
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start SAP extract: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      try {

         //
         // VDS start data
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("======> Start vds_extract.start_data: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.start_data(?)}");
         objOracleStatement.setString(1, cstrVdsQuery);
         objOracleStatement.execute();
         objOracleStatement.close();
         objOracleStatement = null;
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("======> End vds_extract.start_data: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
            
         //
         // SAP extract data
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("======> Start SAP Connection: " + Calendar.getInstance().getTime()); 
            cobjPrintWriter.flush();
         }
         try {
            cobjSapConnection =  new cSapConnection(cstrSapClient, cstrSapUserId, cstrSapPassword, cstrSapLanguage, cstrSapServer, cstrSapSystem);
         } catch(Exception objException) {
            throw new Exception("SAP Connection failed - " + objException.getMessage());
         }

         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("======> End SAP Connection: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.update_data(?,?)}");
         for (int i=0; i<cstrTableNames.length; i++) {
            intRowSkips = 0;
            intRowCount = cintDatCount;
            bolRead = true;
            while (bolRead) {
               objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
               objSapSingleQuery.execute(cstrTableNames[i].toUpperCase(), cstrTableNames[i].toUpperCase(), "*", new String[0], intRowSkips, intRowCount);
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> Start vds_extract.update_data:"+ Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
               }
               objWorkREFNR = objSapSingleQuery.getResultSet().toList();
               for (int j=0; j<objWorkREFNR.size(); j++) {
                  objOracleStatement.setString(1, cstrVdsQuery);
                  objOracleStatement.setString(2, (String)objWorkREFNR.get(j));
                  objOracleStatement.execute();
               }
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> End vds_extract.update_data (" + objWorkREFNR.size() + "):"+ Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
               }
               if (objSapSingleQuery.getResultSet().getRowCount() < intRowCount) {
                  bolRead = false;
               } else {
                  intRowSkips = intRowSkips + intRowCount;
               }
            }
         }  
         if (objOracleStatement != null) {
            objOracleStatement.close();
            objOracleStatement = null;
         }
         
         //
         // VDS final data
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("======> Start vds_extract.final_data: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.final_data(?)}");
         objOracleStatement.setString(1, cstrVdsQuery);
         objOracleStatement.execute();
         objOracleStatement.close();
         objOracleStatement = null;
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("======> End vds_extract.final_data: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
      } catch(Exception objException) {
         throw new Exception("Data retrieval failed - " + objException.getMessage());
      } finally {
         objSapSingleQuery = null;
         if (cobjSapConnection != null) {
            cobjSapConnection.disconnect();
         }
         cobjSapConnection = null;
         if (objOracleStatement != null) {
            objOracleStatement.close();
         }
         objOracleStatement = null;
      }
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> End SAP extract: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
      //
      // End REFN data retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> End Data Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
   }
   
}