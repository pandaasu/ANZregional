/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : cSapVds23
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
 * This class implements the SAP customer extract functionality. This functionality retrieves
 * SAP customer data based on supplied filters and then extracts the required customer data
 * for new and changed customers.
 */
public final class cSapVds23 implements iSapVdsExtract {
   
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
   String cstrKNB1Filter;
   String cstrKNVVFilter;
   String cstrVdsQuery;
   String cstrVdsKNA1Columns;
   String cstrVdsKNB1Columns;
   String cstrVdsKNVIColumns;
   String cstrVdsKNVVColumns;
   String cstrLogging = null;
   PrintWriter cobjPrintWriter;
   
   /**
    * Processes the SAP to VDS customer extract.
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
         cstrDatReplace = "*DATA";
         cintDatCount = 100;
      } else if (strReplace.length() == 5) {
         cstrDatReplace = strReplace.substring(0,5);
         cintDatCount = 100;
      } else {
         cstrDatReplace = strReplace.substring(0,5);
         try {
            cintDatCount = Integer.parseInt(strReplace.substring(5));
         } catch(Throwable objThrowable) {
            cintDatCount = 100;
         }
      }
      if (!cstrDatReplace.equals("*META") && !cstrDatReplace.equals("*DATA") && !cstrDatReplace.equals("*FULL")) {
         cstrDatReplace = "*DATA";
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
      cstrKNB1Filter = (String)objParameters.get("KNB1_FILTER");
      cstrKNVVFilter = (String)objParameters.get("KNVV_FILTER"); 
      cstrVdsQuery = (String)objParameters.get("VDS_QUERY");
      cstrVdsKNA1Columns = (String)objParameters.get("VDS_KNA1_COLUMNS");
      cstrVdsKNB1Columns = (String)objParameters.get("VDS_KNB1_COLUMNS");
      cstrVdsKNVIColumns = (String)objParameters.get("VDS_KNVI_COLUMNS");
      cstrVdsKNVVColumns = (String)objParameters.get("VDS_KNVV_COLUMNS");
      cstrLogging = (String)objParameters.get("LOGGING");
      if (cstrSapClient == null) {
         throw new Exception("VDS Customer Extract - SAP connection client not supplied in configuration file");
      }
      if (cstrSapUserId == null) {
         throw new Exception("VDS Customer Extract - SAP connection user id not supplied in configuration file");
      }
      if (cstrSapPassword == null) {
         throw new Exception("VDS Customer Extract - SAP connection password not supplied in configuration file");
      }
      if (cstrSapLanguage == null) {
         throw new Exception("VDS Customer Extract - SAP connection language not supplied in configuration file");
      }
      if (cstrSapServer == null) {
         throw new Exception("VDS Customer Extract - SAP connection server not supplied in configuration file");
      }
      if (cstrSapSystem == null) {
         throw new Exception("VDS Customer Extract - SAP connection system not supplied in configuration file");
      }
      if (cstrVdsConnection == null) {
         throw new Exception("VDS Customer Extract - VDS connection string not supplied in configuration file");
      }
      if (cstrVdsUserId == null) {
         throw new Exception("VDS Customer Extract - VDS user id not supplied in configuration file");
      }
      if (cstrVdsPassword == null) {
         throw new Exception("VDS Customer Extract - VDS password not supplied in configuration file");
      }
      if (cstrKNB1Filter == null) {
         throw new Exception("VDS Customer Extract - KNB1 filter not supplied in configuration file");
      }
      if (cstrKNVVFilter == null) {
         throw new Exception("VDS Customer Extract - KNVV filter not supplied in configuration file");
      }
      if (cstrVdsQuery == null || cstrVdsQuery.toUpperCase().equals("*NONE")) {
         throw new Exception("VDS Customer Extract - Validation query must be supplied");
      }
      if (cstrVdsKNA1Columns == null) {
         cstrVdsKNA1Columns = "*";
      }
      if (cstrVdsKNB1Columns == null) {
         cstrVdsKNB1Columns = "*";
      }
      if (cstrVdsKNVIColumns == null) {
         cstrVdsKNVIColumns = "*";
      }
      if (cstrVdsKNVVColumns == null) {
         cstrVdsKNVVColumns = "*";
      }
      if (cstrLogging != null) {
         cobjPrintWriter = new PrintWriter(new FileWriter(cstrLogging, false));
      }
      
      //
      // Start log
      //
      if (cstrLogging != null) {
         cobjPrintWriter.print("Start VDS Customer Extract ("+strReplace+") becomes ("+cstrDatReplace+" / "+cintDatCount+") : " + Calendar.getInstance().getTime()); 
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
            cobjPrintWriter.print("VDS Customer Extract - " + objException.getMessage());
            cobjPrintWriter.close();
         }
         throw new Exception("VDS Customer Extract - " + objException.getMessage());
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
         cobjPrintWriter.print("End VDS Customer Extract: " + Calendar.getInstance().getTime());
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
      ArrayList objWorkKUNNR = null;
      String[] strKUNNR = null;
 
      //
      // Set the customer condition array from the work array
      //
      strKUNNR = new String[]{"KUNNR = 'NOKUNNR'"};
      
      //
      // KNA1 meta retrieval
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
            cobjPrintWriter.print("====> Start vds_extract.start_query: " + Calendar.getInstance().getTime());
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
         objSapSingleQuery.execute("KNA1", "KNA1", cstrVdsKNA1Columns, strKUNNR,0,0);
         objSapSingleQuery.execute("KNB1", "KNB1", cstrVdsKNB1Columns, strKUNNR,0,0);
         objSapSingleQuery.execute("KNVI", "KNVI", cstrVdsKNVIColumns, strKUNNR,0,0);
         objSapSingleQuery.execute("KNVV", "KNVV", cstrVdsKNVVColumns, strKUNNR,0,0);
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
         objWorkKUNNR = objSapSingleQuery.getResultSet().getMetaData().toList();
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.update_meta(?,?)}");
         for (int j=0; j<objWorkKUNNR.size(); j++) {
            objOracleStatement.setString(1, cstrVdsQuery);
            objOracleStatement.setString(2, (String)objWorkKUNNR.get(j));
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
      cSapSingleResultSet objSapSingleResultSet = null;
      CallableStatement objOracleStatement = null;
      int intRowSkips = 0;
      int intRowCount = 0;
      boolean bolRead = true;
      ArrayList objKUNNR = null;
      ArrayList objWorkKUNNR = null;
      String strBufferData = "";
      int intBufferCount = 0;
         
      //
      // Initialise the work array
      //
      objWorkKUNNR = new ArrayList();
      
      //
      // Start KNA1 data retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> Start Data Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
      //
      // Clear the document list when *FULL replacement required
      //
      if (cstrDatReplace.equals("*FULL")) {
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
      }
         
      //
      // KNB1 filters - add to the work array
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start KNB1 Filters: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      try {
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
         intRowSkips = 0;
         intRowCount = 1000;
         bolRead = true;
         while (bolRead) {
            objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
            objSapSingleQuery.execute("KNB1", "KNB1", "KUNNR", new String[]{cstrKNB1Filter}, intRowSkips, intRowCount);
               objWorkKUNNR = objSapSingleQuery.getResultSet().getMergedArray(objWorkKUNNR, "KNB1", "KUNNR");
            if (objSapSingleQuery.getResultSet().getRowCount() < intRowCount) {
               bolRead = false;
            } else {
               intRowSkips = intRowSkips + intRowCount;
            }
         }       
      } catch(Exception objException) {
         throw new Exception("Data retrieval failed - " + objException.getMessage());
      } finally {
         objSapSingleQuery = null;
         if (cobjSapConnection != null) {
            cobjSapConnection.disconnect();
         }
         cobjSapConnection = null;
      }
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> End KNB1 Filters ("+objWorkKUNNR.size()+"): " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }

      //
      // KNVV filters - add to the work array
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start KNVV Filters: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      try {
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
         intRowSkips = 0;
         intRowCount = 1000;
         bolRead = true;
         while (bolRead) {
            objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
            objSapSingleQuery.execute("KNVV", "KNVV", "KUNNR", new String[]{cstrKNVVFilter}, intRowSkips, intRowCount);
            objWorkKUNNR = objSapSingleQuery.getResultSet().getMergedArray(objWorkKUNNR, "KNVV", "KUNNR");
            if (objSapSingleQuery.getResultSet().getRowCount() < intRowCount) {
               bolRead = false;
            } else {
               intRowSkips = intRowSkips + intRowCount;
            }
         }
      } catch(Exception objException) {
         throw new Exception("Data retrieval failed - " + objException.getMessage());
      } finally {
         objSapSingleQuery = null;
         if (cobjSapConnection != null) {
            cobjSapConnection.disconnect();
         }
         cobjSapConnection = null;
      }
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> End KNVV Filters ("+objWorkKUNNR.size()+"): " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
         
      //
      // Set the customer condition array from the work array
      //
      objKUNNR = cSapUtility.getOrConditionsArray(objWorkKUNNR,"KUNNR = '<KEYVALUE></KEYVALUE>'",1000);
            
      //
      // KNA1 listing
      //
      if (objKUNNR.size() != 0) {
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start KNA1 Listing: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         try {
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
            objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.update_list(?,?)}");
            intBufferCount = 0;
            strBufferData = "";
            for (int i=0; i<objKUNNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
               objSapSingleQuery.execute("KNA1", "KNA1", "KUNNR, ERDAT", (String[])objKUNNR.get(i),0,0);
               objSapSingleResultSet = objSapSingleQuery.getResultSet();
               for (int j=0; j<objSapSingleResultSet.getRowCount(); j++) {
                  intBufferCount++;
                  strBufferData = strBufferData + objSapSingleResultSet.getFieldValue(j, 0) + "," + objSapSingleResultSet.getFieldValue(j, 1) + ";";
                  if (intBufferCount >= 50) {
                     objOracleStatement.setString(1, cstrVdsQuery);
                     objOracleStatement.setString(2, strBufferData);
                     objOracleStatement.execute();
                     strBufferData = "";
                     intBufferCount = 0;
                  }
               }
               if (intBufferCount > 0) {
                  objOracleStatement.setString(1, cstrVdsQuery);
                  objOracleStatement.setString(2, strBufferData);
                  objOracleStatement.execute();
               }
            }
         } catch(Exception objException) {
            throw new Exception("Data retrieval failed - " + objException.getMessage());
         } finally {
            objSapSingleQuery = null;
            objSapSingleResultSet = null;
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
            cobjPrintWriter.print("====> End KNA1 Listing: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
      }
         
      //
      // Initialise the work array
      //
      objWorkKUNNR = new ArrayList();
         
      //
      // VDS_DOC_LIST retrieval - customer document list changes
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start VDS_DOC_LIST retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      try {
         objOracleStatement = cobjOracleConnection.prepareCall("{ ? = call vds_extract.create_buffer('select vdl_number from vds_doc_list where vdl_query = ''"+cstrVdsQuery+"'' and vdl_status = ''*CHANGED'' order by vdl_number asc') }");
         objOracleStatement.registerOutParameter(1, Types.CLOB);
         objOracleStatement.execute();
         Clob objReturn = objOracleStatement.getClob(1);
         String strData = null;
         BufferedReader objReader = new BufferedReader(objReturn.getCharacterStream());
         while((strData = objReader.readLine()) != null) {
            if (!strData.equals("")) {
               StringTokenizer objTokenizer = new StringTokenizer(strData,",");
               while (objTokenizer.hasMoreTokens()) {
                  objWorkKUNNR.add(objTokenizer.nextToken());
               }
            }
         }
         objReader.close();
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
         cobjPrintWriter.print("====> End VDS_DOC_LIST retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
      //
      // Set the customer condition array from the work array
      //
      objKUNNR = cSapUtility.getOrConditionsArray(objWorkKUNNR,"KUNNR = '<KEYVALUE></KEYVALUE>'",cintDatCount);
      
      //
      // KNA1 retrieval
      //
      if (objKUNNR.size() == 0) {
         
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> No customers to extract: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
      } else {
         
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
            objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.update_data(?,?)}");
            for (int i=0; i<objKUNNR.size(); i++) {
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
               objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
               objSapSingleQuery.execute("KNA1", "KNA1", cstrVdsKNA1Columns, (String[])objKUNNR.get(i),0,0);
               if (objSapSingleQuery.getResultSet().getRowCount("KNA1") != 0) {
                  objSapSingleQuery.execute("KNB1", "KNB1", cstrVdsKNB1Columns, objSapSingleQuery.getResultSet().getOrConditions("KNA1","KUNNR = '<KEYVALUE>KUNNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("KNVI", "KNVI", cstrVdsKNVIColumns, objSapSingleQuery.getResultSet().getOrConditions("KNA1","KUNNR = '<KEYVALUE>KUNNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("KNVV", "KNVV", cstrVdsKNVVColumns, objSapSingleQuery.getResultSet().getOrConditions("KNA1","KUNNR = '<KEYVALUE>KUNNR</KEYVALUE>'"),0,0);
               }
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> Start SAP disconnect: " + Calendar.getInstance().getTime()); 
                  cobjPrintWriter.flush();
               }
               cobjSapConnection.disconnect();
               cobjSapConnection = null;
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> End SAP disconnect: " + Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
               }
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> Start vds_extract.update_data:"+ Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
               }
               objWorkKUNNR = objSapSingleQuery.getResultSet().toList();
               for (int j=0; j<objWorkKUNNR.size(); j++) {
                  objOracleStatement.setString(1, cstrVdsQuery);
                  objOracleStatement.setString(2, (String)objWorkKUNNR.get(j));
                  objOracleStatement.execute();
               }
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> End vds_extract.update_data (" + ((String[])objKUNNR.get(i)).length + "):"+ Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
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
            objSapSingleResultSet = null;
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
      }
      
      //
      // End KNA1 data retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> End Data Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
   }

}