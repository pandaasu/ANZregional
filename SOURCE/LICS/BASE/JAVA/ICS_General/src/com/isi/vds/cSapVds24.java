/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : cSapVds24
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
 * This class implements the SAP vendor extract functionality. This functionality retrieves
 * SAP vendor data based on supplied filters and then extracts the required vendor data
 * for new and changed vendors.
 */
public final class cSapVds24 implements iSapVdsExtract {
   
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
   String cstrLFB1Filter;
   String cstrLFM1Filter;
   String cstrVdsQuery;
   String cstrVdsLFA1Columns;
   String cstrVdsLFB1Columns;
   String cstrVdsLFBKColumns;
   String cstrVdsLFM1Columns;
   String cstrVdsLFM2Columns;
   String cstrVdsWYT3Columns;
   String cstrLogging = null;
   PrintWriter cobjPrintWriter;
   
   /**
    * Processes the SAP to VDS vendor extract.
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
      cstrLFB1Filter = (String)objParameters.get("LFB1_FILTER");
      cstrLFM1Filter = (String)objParameters.get("LFM1_FILTER");
      cstrVdsQuery = (String)objParameters.get("VDS_QUERY");
      cstrVdsLFA1Columns = (String)objParameters.get("VDS_LFA1_COLUMNS");
      cstrVdsLFB1Columns = (String)objParameters.get("VDS_LFB1_COLUMNS");
      cstrVdsLFBKColumns = (String)objParameters.get("VDS_LFBK_COLUMNS");
      cstrVdsLFM1Columns = (String)objParameters.get("VDS_LFM1_COLUMNS");
      cstrVdsLFM2Columns = (String)objParameters.get("VDS_LFM2_COLUMNS");
      cstrVdsWYT3Columns = (String)objParameters.get("VDS_WYT3_COLUMNS");
      cstrLogging = (String)objParameters.get("LOGGING");
      if (cstrSapClient == null) {
         throw new Exception("VDS Vendor Extract - SAP connection client not supplied in configuration file");
      }
      if (cstrSapUserId == null) {
         throw new Exception("VDS Vendor Extract - SAP connection user id not supplied in configuration file");
      }
      if (cstrSapPassword == null) {
         throw new Exception("VDS Vendor Extract - SAP connection password not supplied in configuration file");
      }
      if (cstrSapLanguage == null) {
         throw new Exception("VDS Vendor Extract - SAP connection language not supplied in configuration file");
      }
      if (cstrSapServer == null) {
         throw new Exception("VDS Vendor Extract - SAP connection server not supplied in configuration file");
      }
      if (cstrSapSystem == null) {
         throw new Exception("VDS Vendor Extract - SAP connection system not supplied in configuration file");
      }
      if (cstrVdsConnection == null) {
         throw new Exception("VDS Vendor Extract - VDS connection string not supplied in configuration file");
      }
      if (cstrVdsUserId == null) {
         throw new Exception("VDS Vendor Extract - VDS user id not supplied in configuration file");
      }
      if (cstrVdsPassword == null) {
         throw new Exception("VDS Vendor Extract - VDS password not supplied in configuration file");
      }
      if (cstrLFB1Filter == null) {
         throw new Exception("VDS Vendor Extract - LFB1 filter not supplied in configuration file");
      }
      if (cstrLFM1Filter == null) {
         throw new Exception("VDS Vendor Extract - LFM1 filter not supplied in configuration file");
      }
      if (cstrVdsQuery == null || cstrVdsQuery.toUpperCase().equals("*NONE")) {
         throw new Exception("VDS Vendor Extract - Validation query must be supplied");
      }
      if (cstrVdsLFA1Columns == null) {
         cstrVdsLFA1Columns = "*";
      }
      if (cstrVdsLFA1Columns == null) {
         cstrVdsLFA1Columns = "*";
      }
      if (cstrVdsLFB1Columns == null) {
         cstrVdsLFB1Columns = "*";
      }
      if (cstrVdsLFBKColumns == null) {
         cstrVdsLFBKColumns = "*";
      }
      if (cstrVdsLFM1Columns == null) {
         cstrVdsLFM1Columns = "*";
      }
      if (cstrVdsLFM2Columns == null) {
         cstrVdsLFM2Columns = "*";
      }
      if (cstrVdsWYT3Columns == null) {
         cstrVdsWYT3Columns = "*";
      }
      if (cstrLogging != null) {
         cobjPrintWriter = new PrintWriter(new FileWriter(cstrLogging, false));
      }
      
      //
      // Start log
      //
      if (cstrLogging != null) {
         cobjPrintWriter.print("Start VDS Vendor Extract ("+strReplace+") becomes ("+cstrDatReplace+" / "+cintDatCount+") : " + Calendar.getInstance().getTime()); 
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
            cobjPrintWriter.print("VDS Vendor Extract - " + objException.getMessage());
            cobjPrintWriter.close();
         }
         throw new Exception("VDS Vendor Extract - " + objException.getMessage());
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
         cobjPrintWriter.print("End VDS Vendor Extract: " + Calendar.getInstance().getTime());
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
      ArrayList objWorkLIFNR = null;
      String[] strLIFNR = null;
 
      //
      // Set the vendor condition array from the work array
      //
      strLIFNR = new String[]{"LIFNR = 'NOLIFNR'"};
      
      //
      // LFA1 meta retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> Start Meta Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
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
         objSapSingleQuery.execute("LFA1", "LFA1", cstrVdsLFA1Columns, strLIFNR,0,0);
         objSapSingleQuery.execute("LFB1", "LFB1", cstrVdsLFB1Columns, strLIFNR,0,0);
         objSapSingleQuery.execute("LFBK", "LFBK", cstrVdsLFBKColumns, strLIFNR,0,0);
         objSapSingleQuery.execute("LFM1", "LFM1", cstrVdsLFM1Columns, strLIFNR,0,0);
         objSapSingleQuery.execute("LFM2", "LFM2", cstrVdsLFM2Columns, strLIFNR,0,0);
         objSapSingleQuery.execute("WYT3", "WYT3", cstrVdsWYT3Columns, strLIFNR,0,0);
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
         objWorkLIFNR = objSapSingleQuery.getResultSet().getMetaData().toList();
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.update_meta(?,?)}");
         for (int j=0; j<objWorkLIFNR.size(); j++) {
            objOracleStatement.setString(1, cstrVdsQuery);
            objOracleStatement.setString(2, (String)objWorkLIFNR.get(j));
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
         cobjPrintWriter.print("End Meta Retrieval: " + Calendar.getInstance().getTime());
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
      ArrayList objLIFNR = null;
      ArrayList objWorkLIFNR = null;
      String strBufferData = "";
      int intBufferCount = 0;
         
      //
      // Initialise the work array
      //
      objWorkLIFNR = new ArrayList();
      
      //
      // Start LFA1 data retrieval
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
      // LFB1 filters - add to the work array
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start LFB1 Filters: " + Calendar.getInstance().getTime());
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
            objSapSingleQuery.execute("LFB1", "LFB1", "LIFNR", new String[]{cstrLFB1Filter}, intRowSkips, intRowCount);
            objWorkLIFNR = objSapSingleQuery.getResultSet().getMergedArray(objWorkLIFNR, "LFB1", "LIFNR");
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
         cobjPrintWriter.print("====> End LFB1 Filters ("+objWorkLIFNR.size()+"): " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }

      //
      // LFM1 filters - add to the work array
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start LFM1 Filters: " + Calendar.getInstance().getTime());
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
            objSapSingleQuery.execute("LFM1", "LFM1", "LIFNR", new String[]{cstrLFM1Filter}, intRowSkips, intRowCount);
            objWorkLIFNR = objSapSingleQuery.getResultSet().getMergedArray(objWorkLIFNR, "LFM1", "LIFNR");
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
         cobjPrintWriter.print("====> End LFM1 Filters ("+objWorkLIFNR.size()+"): " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
         
      //
      // Set the vendor condition array from the work array
      //
      objLIFNR = cSapUtility.getOrConditionsArray(objWorkLIFNR,"LIFNR = '<KEYVALUE></KEYVALUE>'",1000);
            
      //
      // LFA1 listing
      //
      if (objLIFNR.size() != 0) {
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start LFA1 Listing: " + Calendar.getInstance().getTime());
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
            for (int i=0; i<objLIFNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
               objSapSingleQuery.execute("LFA1", "LFA1", "LIFNR, ERDAT", (String[])objLIFNR.get(i),0,0);
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
            cobjPrintWriter.print("====> End LFA1 Listing: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
      }
         
      //
      // Initialise the work array
      //
      objWorkLIFNR = new ArrayList();
         
      //
      // VDS_DOC_LIST retrieval - vendor document list changes
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
                  objWorkLIFNR.add(objTokenizer.nextToken());
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
      // Set the vendor condition array from the work array
      //
      objLIFNR = cSapUtility.getOrConditionsArray(objWorkLIFNR,"LIFNR = '<KEYVALUE></KEYVALUE>'",cintDatCount);
      
      //
      // LFA1 retrieval
      //
      if (objLIFNR.size() == 0) {
         
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> No vendors to extract: " + Calendar.getInstance().getTime());
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
            for (int i=0; i<objLIFNR.size(); i++) {
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
               objSapSingleQuery.execute("LFA1", "LFA1", cstrVdsLFA1Columns, (String[])objLIFNR.get(i),0,0);
               if (objSapSingleQuery.getResultSet().getRowCount("LFA1") != 0) {
                  objSapSingleQuery.execute("LFB1", "LFB1", cstrVdsLFB1Columns, objSapSingleQuery.getResultSet().getOrConditions("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("LFBK", "LFBK", cstrVdsLFBKColumns, objSapSingleQuery.getResultSet().getOrConditions("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("LFM1", "LFM1", cstrVdsLFM1Columns, objSapSingleQuery.getResultSet().getOrConditions("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("LFM2", "LFM2", cstrVdsLFM2Columns, objSapSingleQuery.getResultSet().getOrConditions("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("WYT3", "WYT3", cstrVdsWYT3Columns, objSapSingleQuery.getResultSet().getOrConditions("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'"),0,0);
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
               objWorkLIFNR = objSapSingleQuery.getResultSet().toList();
               for (int j=0; j<objWorkLIFNR.size(); j++) {
                  objOracleStatement.setString(1, cstrVdsQuery);
                  objOracleStatement.setString(2, (String)objWorkLIFNR.get(j));
                  objOracleStatement.execute();
               }
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> End vds_extract.update_data (" + ((String[])objLIFNR.get(i)).length + "):"+ Calendar.getInstance().getTime());
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
      // End LFA1 data retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> End Data Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
   }

}