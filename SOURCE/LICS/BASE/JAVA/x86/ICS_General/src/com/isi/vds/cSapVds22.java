/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : cSapVds22
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
 * This class implements the SAP material extract functionality. This functionality retrieves
 * SAP material data based on supplied filters and then extracts the required material data
 * for new and changed materials.
 */
public final class cSapVds22 implements iSapVdsExtract {
   
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
   String cstrMARAFilter;
   String cstrMARCFilter;
   String cstrMVKEFilter;
   String cstrVdsQuery;
   String cstrVdsMARAColumns;
   String cstrVdsMARMColumns;
   String cstrVdsMAKTColumns;
   String cstrVdsMARCColumns;
   String cstrVdsMVKEColumns;
   String cstrVdsMMOEColumns;
   String cstrVdsMBEWColumns;
   String cstrVdsMARDColumns;
   String cstrVdsINOBColumns;
   String cstrVdsAUSPColumns;
   String cstrVdsMLGNColumns;
   String cstrVdsMLANColumns;
   String cstrLogging = null;
   PrintWriter cobjPrintWriter;
   
   /**
    * Processes the SAP to VDS material extract.
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
      cstrMARAFilter = (String)objParameters.get("MARA_FILTER");
      cstrMARCFilter = (String)objParameters.get("MARC_FILTER");
      cstrMVKEFilter = (String)objParameters.get("MVKE_FILTER");
      cstrVdsQuery = (String)objParameters.get("VDS_QUERY");
      cstrVdsMARAColumns = (String)objParameters.get("VDS_MARA_COLUMNS");
      cstrVdsMARMColumns = (String)objParameters.get("VDS_MARM_COLUMNS");
      cstrVdsMAKTColumns = (String)objParameters.get("VDS_MAKT_COLUMNS");
      cstrVdsMARCColumns = (String)objParameters.get("VDS_MARC_COLUMNS");
      cstrVdsMVKEColumns = (String)objParameters.get("VDS_MVKE_COLUMNS");
      cstrVdsMMOEColumns = (String)objParameters.get("VDS_MMOE_COLUMNS");
      cstrVdsMBEWColumns = (String)objParameters.get("VDS_MBEW_COLUMNS");
      cstrVdsMARDColumns = (String)objParameters.get("VDS_MARD_COLUMNS");
      cstrVdsINOBColumns = (String)objParameters.get("VDS_INOB_COLUMNS");
      cstrVdsAUSPColumns = (String)objParameters.get("VDS_AUSP_COLUMNS");
      cstrVdsMLGNColumns = (String)objParameters.get("VDS_MLGN_COLUMNS");
      cstrVdsMLANColumns = (String)objParameters.get("VDS_MLAN_COLUMNS");
      cstrLogging = (String)objParameters.get("LOGGING");
      if (cstrSapClient == null) {
         throw new Exception("VDS Material Extract - SAP connection client not supplied in configuration file");
      }
      if (cstrSapUserId == null) {
         throw new Exception("VDS Material Extract - SAP connection user id not supplied in configuration file");
      }
      if (cstrSapPassword == null) {
         throw new Exception("VDS Material Extract - SAP connection password not supplied in configuration file");
      }
      if (cstrSapLanguage == null) {
         throw new Exception("VDS Material Extract - SAP connection language not supplied in configuration file");
      }
      if (cstrSapServer == null) {
         throw new Exception("VDS Material Extract - SAP connection server not supplied in configuration file");
      }
      if (cstrSapSystem == null) {
         throw new Exception("VDS Material Extract - SAP connection system not supplied in configuration file");
      }
      if (cstrVdsConnection == null) {
         throw new Exception("VDS Material Extract - VDS connection string not supplied in configuration file");
      }
      if (cstrVdsUserId == null) {
         throw new Exception("VDS Material Extract - VDS user id not supplied in configuration file");
      }
      if (cstrVdsPassword == null) {
         throw new Exception("VDS Material Extract - VDS password not supplied in configuration file");
      }
      if (cstrMARAFilter == null) {
         throw new Exception("VDS Material Extract - MARA filter not supplied in configuration file");
      }
      if (cstrMARCFilter == null) {
         throw new Exception("VDS Material Extract - MARC filter not supplied in configuration file");
      }
      if (cstrMVKEFilter == null) {
         throw new Exception("VDS Material Extract - MVKE not supplied in configuration file");
      }
      if (cstrVdsQuery == null || cstrVdsQuery.toUpperCase().equals("*NONE")) {
         throw new Exception("VDS Material Extract - Validation query must be supplied");
      }
      if (cstrVdsMARAColumns == null) {
         cstrVdsMARAColumns = "*";
      }
      if (cstrVdsMARMColumns == null) {
         cstrVdsMARMColumns = "*";
      }
      if (cstrVdsMAKTColumns == null) {
         cstrVdsMAKTColumns = "*";
      }
      if (cstrVdsMARCColumns == null) {
         cstrVdsMARCColumns = "*";
      }
      if (cstrVdsMVKEColumns == null) {
         cstrVdsMVKEColumns = "*";
      }
      if (cstrVdsMMOEColumns == null) {
         cstrVdsMMOEColumns = "*";
      }
      if (cstrVdsMBEWColumns == null) {
         cstrVdsMBEWColumns = "*";
      }
      if (cstrVdsMARDColumns == null) {
         cstrVdsMARDColumns = "*";
      }
      if (cstrVdsINOBColumns == null) {
         cstrVdsINOBColumns = "*";
      }
      if (cstrVdsAUSPColumns == null) {
         cstrVdsAUSPColumns = "*";
      }
      if (cstrVdsMLGNColumns == null) {
         cstrVdsMLGNColumns = "*";
      }
      if (cstrVdsMLANColumns == null) {
         cstrVdsMLANColumns = "*";
      }
      if (cstrLogging != null) {
         cobjPrintWriter = new PrintWriter(new FileWriter(cstrLogging, false));
      }
      
      //
      // Start log
      //
      if (cstrLogging != null) {
         cobjPrintWriter.print("Start VDS Material Extract ("+strReplace+") becomes ("+cstrDatReplace+" / "+cintDatCount+") : " + Calendar.getInstance().getTime()); 
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
            cobjPrintWriter.print("VDS Material Extract - " + objException.getMessage());
            cobjPrintWriter.close();
         }
         throw new Exception("VDS Material Extract - " + objException.getMessage());
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
         cobjPrintWriter.print("End VDS Material Extract: " + Calendar.getInstance().getTime());
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
      ArrayList objWorkMATNR = null;
      String[] strMATNR = null;
      String[] strOBJEK = null;
 
      //
      // Set the material condition array from the work array
      //
      strMATNR = new String[]{"MATNR = 'NOMATNR'"};
      strOBJEK = new String[]{"OBJEK = 'NOOBJEK'"};
      
      //
      // Start MARA meta retrieval
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
         objSapSingleQuery.execute("MARA", "MARA", cstrVdsMARAColumns, strMATNR,0,0);
         objSapSingleQuery.execute("MARM", "MARM", cstrVdsMARMColumns, strMATNR,0,0);
         objSapSingleQuery.execute("MAKT", "MAKT", cstrVdsMAKTColumns, strMATNR,0,0);
         objSapSingleQuery.execute("MARC", "MARC", cstrVdsMARCColumns, strMATNR,0,0);
         objSapSingleQuery.execute("MVKE", "MVKE", cstrVdsMVKEColumns, strMATNR,0,0);
         objSapSingleQuery.execute("MMOE", "/MARS/MDMOEDATA", cstrVdsMMOEColumns, strMATNR,0,0);
         objSapSingleQuery.execute("MBEW", "MBEW", cstrVdsMBEWColumns, strMATNR,0,0);
         objSapSingleQuery.execute("MARD", "MARD", cstrVdsMARDColumns, strMATNR,0,0);
         objSapSingleQuery.execute("INOB", "INOB", cstrVdsINOBColumns, strOBJEK,0,0);
         objSapSingleQuery.execute("AUSP", "AUSP", cstrVdsAUSPColumns, strOBJEK,0,0);
         objSapSingleQuery.execute("MLGN", "MLGN", cstrVdsMLGNColumns, strMATNR,0,0);
         objSapSingleQuery.execute("MLAN", "MLAN", cstrVdsMLANColumns, strMATNR,0,0);
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
         objWorkMATNR = objSapSingleQuery.getResultSet().getMetaData().toList();
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.update_meta(?,?)}");
         for (int j=0; j<objWorkMATNR.size(); j++) {
            objOracleStatement.setString(1, cstrVdsQuery);
            objOracleStatement.setString(2, (String)objWorkMATNR.get(j));
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
      // End MARA meta retrieval
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
      cSapSingleResultSet objSapSingleResultSet = null;
      CallableStatement objOracleStatement = null;
      int intRowSkips = 0;
      int intRowCount = 0;
      boolean bolRead = true;
      ArrayList objMATNR = null;
      ArrayList objWorkMATNR = null;
      String strBufferData = "";
      int intBufferCount = 0;
      
      //
      // Start MARA data retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> Start Data Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
         
      //
      // Initialise the work array
      //
      objWorkMATNR = new ArrayList();
         
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
      // MARC filters - add to the work array
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start MARC Filters: " + Calendar.getInstance().getTime());
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
            objSapSingleQuery.execute("MARC", "MARC", "MATNR", new String[]{cstrMARCFilter}, intRowSkips, intRowCount);
            objWorkMATNR = objSapSingleQuery.getResultSet().getMergedArray(objWorkMATNR, "MARC", "MATNR");
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
         cobjPrintWriter.print("====> End MARC Filters ("+objWorkMATNR.size()+"): " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }

      //
      // MVKE filters - add to the work array
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start MVKE Filters: " + Calendar.getInstance().getTime());
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
            objSapSingleQuery.execute("MVKE", "MVKE", "MATNR", new String[]{cstrMVKEFilter}, intRowSkips, intRowCount);
            objWorkMATNR = objSapSingleQuery.getResultSet().getMergedArray(objWorkMATNR, "MVKE", "MATNR");
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
         cobjPrintWriter.print("====> End MVKE Filters ("+objWorkMATNR.size()+"): " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
         
      //
      // Set the material condition array from the work array
      //
      objMATNR = cSapUtility.getOrConditionsArray(objWorkMATNR,"MATNR = '<KEYVALUE></KEYVALUE>'",1000);
            
      //
      // MARA listing
      //
      if (objMATNR.size() != 0) {
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start MARA Listing: " + Calendar.getInstance().getTime());
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
            for (int i=0; i<objMATNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
               objSapSingleQuery.execute("MARA", "MARA", "MATNR, LAEDA", cSapUtility.concatenateArray((String[])objMATNR.get(i), new String[]{"AND (" + cstrMARAFilter + ")"}),0,0);
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
            cobjPrintWriter.print("====> End MARA Listing: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
      }
         
      //
      // Initialise the work array
      //
      objWorkMATNR = new ArrayList();
         
      //
      // VDS_DOC_LIST retrieval - material document list changes
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
                  objWorkMATNR.add(objTokenizer.nextToken());
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
      // Set the material condition array from the work array
      //
      objMATNR = cSapUtility.getOrConditionsArray(objWorkMATNR,"MATNR = '<KEYVALUE></KEYVALUE>'",cintDatCount);
      
      //
      // MARA data retrieval
      //
      if (objMATNR.size() == 0) {
         
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> No materials to extract: " + Calendar.getInstance().getTime());
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
            for (int i=0; i<objMATNR.size(); i++) {
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
               objSapSingleQuery.execute("MARA", "MARA", cstrVdsMARAColumns, (String[])objMATNR.get(i),0,0);
               if (objSapSingleQuery.getResultSet().getRowCount("MARA") != 0) {
                  objSapSingleQuery.execute("MARM", "MARM", cstrVdsMARMColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("MAKT", "MAKT", cstrVdsMAKTColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("MARC", "MARC", cstrVdsMARCColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("MVKE", "MVKE", cstrVdsMVKEColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("MMOE", "/MARS/MDMOEDATA", cstrVdsMMOEColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("MBEW", "MBEW", cstrVdsMBEWColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("MARD", "MARD", cstrVdsMARDColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("INOB", "INOB", cstrVdsINOBColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","OBJEK = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  if (objSapSingleQuery.getResultSet().getRowCount("INOB") != 0) {
                     objSapSingleQuery.execute("AUSP", "AUSP", cstrVdsAUSPColumns, objSapSingleQuery.getResultSet().getOrConditions("INOB","OBJEK = '<KEYVALUE>CUOBJ</KEYVALUE>'"),0,0);
                  }
                  objSapSingleQuery.execute("MLGN", "MLGN", cstrVdsMLGNColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("MLAN", "MLAN", cstrVdsMLANColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
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
               objWorkMATNR = objSapSingleQuery.getResultSet().toList();
               for (int j=0; j<objWorkMATNR.size(); j++) {
                  objOracleStatement.setString(1, cstrVdsQuery);
                  objOracleStatement.setString(2, (String)objWorkMATNR.get(j));
                  objOracleStatement.execute();
               }
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> End vds_extract.update_data (" + ((String[])objMATNR.get(i)).length + "):"+ Calendar.getInstance().getTime());
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
      // End MARA data retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> End Data Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
   }
   
}