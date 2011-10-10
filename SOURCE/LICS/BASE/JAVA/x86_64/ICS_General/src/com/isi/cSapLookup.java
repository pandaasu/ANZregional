/**
 * Package : ISI LAD
 * Type    : Class
 * Name    : cSapLookup
 * Author  : Steve Gregan
 * Date    : November 2005
 */
package com.isi.lad;
import com.isi.sap.*;
import java.util.*;
import java.io.*;
import java.sql.*;

/** This class implements the SAP Audit Trail functionality. This functionality retrieves
 * SAP change audit trail information from the SAP cdhdr and cdpos tables. This information
 * can be retrieved for various controls such as SAP object (eg. MATERIAL) and date.
 *
 */
public final class cSapLookup {
   
   /** Retrieves the selected SAP audit trail and loads into Oracle. This method connects
    * to the requested SAP database and retrieves the selected audit trail data. A connection is
    * then made to the requested Oracle database and the audit trail data is inserted.
    * @param strSapClient the SAP connection client
    * @param strSapUserId the SAP connection user identifier
    * @param strSapPassword the SAP connection password
    * @param strSapLanguage the SAP connection language
    * @param strSapSystem the SAP connection system
    * @param strSapEnvironment the SAP environment for Oracle database
    * @param strSapObject the SAP object for retrieval
    * @param strSapDate the SAP data for retrieval (YYYYMMDD)
    * @param strOracleServer the Oracle connection server
    * @param strOracleDatabase the Oracle connection database
    * @param strOracleUserId the Oracle connection user identifier
    * @param strOraclePassword the Oracle connection password
    * @throws Exception the exception message
    *
    */
   public void lookupLIKP(String strSapClient, String strSapUserId, String strSapPassword, String strSapLanguage, String strSapServer, String strSapSystem, String strOracleServer, String strOracleDatabase, String strOracleUserId, String strOraclePassword) throws Exception {
      
      //
      // Local variables
      //
      cSapConnection objSAPConnection = null;
      cSapQuery objSapQuery = null;
      cSapExecution objLIKPExecution = null;
      cSapResultSet objSapResultSet = null;
      Connection objOracleConnection = null;
      PreparedStatement objOracleSelectStatement = null;
      PreparedStatement objOracleUpdateStatement = null;
      ResultSet objResultSet = null;
      String SELECT_LADS_DEL_HDR =
      "select vbeln from lads_del_hdr where vbeln in ('7080892157','7080892158','7080892159','7080892160')";
  //    "select vbeln from lads_del_hdr where lads_status != '4' and vbeln = '7080892157'";
      String UPDATE_LADS_DEL_HDR =
      "update lads_del_hdr set lads_status where vbeln = ?";
      
      //
      // Process the delivery data
      //
      try {
      
         //
         // Create a new Oracle thin JDBC connection
         //
         DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
         objOracleConnection = DriverManager.getConnection("jdbc:oracle:thin:@" + strOracleServer + ":1521:" + strOracleDatabase, strOracleUserId, strOraclePassword);
         objOracleConnection.setAutoCommit(false);

         //
         // Create a new SAP connection
         //
         objSAPConnection =  new cSapConnection(strSapClient, strSapUserId, strSapPassword, strSapLanguage, strSapServer, strSapSystem);
System.out.println(Calendar.getInstance().getTime());
         //
         // Retrieve the delivery list from the LADS database
         //
         objOracleSelectStatement = objOracleConnection.prepareStatement(SELECT_LADS_DEL_HDR);
         objOracleUpdateStatement = objOracleConnection.prepareStatement(UPDATE_LADS_DEL_HDR);
         objResultSet = objOracleSelectStatement.executeQuery();
         while (objResultSet.next()) {

            //
            // Lookup SAP for a corresponding delivery code on LIKP
            //
            objSapQuery = new cSapQuery(objSAPConnection);
            objLIKPExecution = objSapQuery.setPrimaryExecution("LIKP", "LIKP", "VBELN", new String[]{"VBELN = '" + objResultSet.getString(1) + "'"});
            objSapResultSet = objSapQuery.execute();
            objSapResultSet.setHierarchy();

            //
            // Update the LADS delivery status to delete when not found in SAP
            //
            if (!objSapResultSet.getNextRow()) {
             //  objOracleUpdateStatement.setString(1, objResultSet.getString(1));
             //  objOracleUpdateStatement.executeUpdate();
             //  objOracleConnection.commit();
               System.out.println("NOT FOUND: " + objResultSet.getString(1));
            } else {
               System.out.println("FOUND: " + objResultSet.getString(1));
            }

         }
System.out.println(Calendar.getInstance().getTime());
      } catch(Exception objException) {
         throw objException;
         
      } finally {
         if (objSAPConnection != null) {
            objSAPConnection.disconnect();
         }
         if (objOracleSelectStatement != null) {
            objOracleSelectStatement.close();
         }
         if (objOracleUpdateStatement != null) {
            objOracleUpdateStatement.close();
         }
         if (objOracleConnection != null) {
            objOracleConnection.close();
         }
         objSapResultSet = null;
         objLIKPExecution = null;
         objSapQuery = null;
         objSAPConnection = null;
         objOracleSelectStatement = null;
         objOracleUpdateStatement = null;
         objOracleConnection = null;
      }
      
   }
   
   /** Usage and terminate method
    *
    */
   protected static void usageAndTerminate() {
      System.out.println("Usage: com.isi.sap.cSapAuditTrail [-action *LOAD_TO_ORACLE -connection connection_property_file]");
      System.exit(1);
   }
   
   /** Main method - provides an entry point to the application. This method currently supports
    * the following combination of arguments:
    * 1. -action = *LOAD_TO_ORACLE
    * 2. -connection = the connection property file
    * @param args the command line arguments
    *
    */
   public static void main(String[] args) {
      
      //
      // Local variables
      //
      cSapLookup objSapLookup;
      
      //
      // Process the entry point request
      //
      try {
         
         //
         // Retrieve the command line arguments
         //
         String strAction = null;
         String strConnection = null;
         try {
            for (int i=0;i<args.length;i++) {
               if (args[i].equals("-action")) {
                  strAction = args[++i];
               } else if (args[i].equals("-connection")) {
                  strConnection = args[++i];
               }
            }
         } catch(ArrayIndexOutOfBoundsException e) {
            usageAndTerminate();
         }
         
         //
         // Check for valid argument combinations
         //
     //    if (!strAction.equals("*LOAD_TO_ORACLE")) {
     //       usageAndTerminate();
     //       if (strAction.equals("*LOAD_TO_ORACLE") && strConnection == null) {
     //          usageAndTerminate();
     //       }
     //    }
         
         //
         // Process the load to oracle request
         //
     //    if (strAction.equals("*LOAD_TO_ORACLE")) {
    //        ResourceBundle cobjResource = ResourceBundle.getBundle(strConnection);
    //        String strSapClient = cobjResource.getString("SapClient");
     //       String strSapUserId = cobjResource.getString("SapUserId");
     //       String strSapPassword = cobjResource.getString("SapPassword");
     //       String strSapLanguage = cobjResource.getString("SapLanguage");
     //       String strSapServer = cobjResource.getString("SapServer");
    //        String strSapSystem = cobjResource.getString("SapSystem");
    //        String strSapEnvironment = cobjResource.getString("SapEnvironment");
    //        String strSapObject = cobjResource.getString("SapObject");
    //        String strSapDate = cobjResource.getString("SapDate");
    //        String strOracleServer = cobjResource.getString("OracleServer");
     //       String strOracleDatabase = cobjResource.getString("OracleDatabase");
     //       String strOracleUserId = cobjResource.getString("OracleUserId");
     //       String strOraclePassword = cobjResource.getString("OraclePassword");
      //      objSapLookup = new cSapLookup();
      //      objSapLookup.lookupLIKP(strSapClient,
      //      strSapUserId,
      //      strSapPassword,
       //     strSapLanguage,
       //     strSapServer,
       //     strSapSystem,
       //     strSapEnvironment,
       //     strSapObject,
       //     strSapDate,
       //     strOracleServer,
       //     strOracleDatabase,
       //     strOracleUserId,
       //     strOraclePassword);
       //  }
         
         String strSapClient = "002";
         String strSapUserId = "hendemeg";
         String strSapPassword = "crapola1";
         String strSapLanguage = "EN";
         String strSapServer = "sapapb.na.mars";
         String strSapSystem = "02";
         String strOracleServer = "WODU003.AP.MARS";
         String strOracleDatabase = "AP0052T";
         String strOracleUserId = "LADS_APP";
         String strOraclePassword = "LADICE";
         objSapLookup = new cSapLookup();
         System.out.println(Calendar.getInstance().getTime());
         objSapLookup.lookupLIKP(strSapClient,
         strSapUserId,
         strSapPassword,
         strSapLanguage,
         strSapServer,
         strSapSystem,
         strOracleServer,
         strOracleDatabase,
         strOracleUserId,
         strOraclePassword);
         System.out.println(Calendar.getInstance().getTime());
         
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
      } finally {
         objSapLookup = null;
      }
      
   }
   
}

