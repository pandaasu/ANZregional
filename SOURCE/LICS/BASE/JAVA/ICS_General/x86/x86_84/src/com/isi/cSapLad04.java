/**
 * Package : ISI LAD
 * Type    : Class
 * Name    : cSapLad04
 * Author  : Steve Gregan
 * Date    : February 2007
 */
package com.isi.lad;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;
import java.sql.*;

/**
 * This class implements the SAP lookup functionality. This functionality looks up the SAP
 * table and returns rows that do not exist from a list of supplied values.
 */
public final class cSapLad04 implements iSapInterface {
   
   //
   // Declare the class variable
   //
   cSapConnection cobjSapConnection = null;
   Connection cobjOracleConnection = null;
   CallableStatement cobjOracleStatement = null;
   cSapSingleQuery cobjSapSingleQuery = null;
   cSapSingleResultSet cobjSapSingleResultSet = null;
   boolean cbolAppend = false;
   boolean cbolData = false;
   int cintGroup = 1000;
   ArrayList cobjList = null;
   ArrayList cobjLookup = null;
   ArrayList cobjCheck = null;
   String[] cstrTest = null;
   String cstrOutputFile = null;
   String cstrLadsHistoryDays = null;
   String cstrLogging = null;
   String cstrIdoc = "SAPLAD04";
   
   /**
    * Processes the SAP validation extract.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSapConnection, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Initialise the class variables
      //
      cobjSapConnection = objSapConnection;
      cstrOutputFile = strOutputFile;
      cobjOracleConnection = null;
      cobjOracleStatement = null;
      cobjSapSingleQuery = null;
      cobjSapSingleResultSet = null;
      cbolAppend = false;
      cbolData = false;
      cintGroup = 1000;
      cobjList = null;
      cobjLookup = null;
      cobjCheck = null;
      cstrTest = null;
      cstrLadsHistoryDays = null;
      cstrLogging = null;
      
      //
      // Retrieve any interface specific parameters
      //
      String strLadsConnection = (String)objParameters.get("LADSCONNECTION");
      String strLadsUserId = (String)objParameters.get("LADSUSERID");
      String strLadsPassword = (String)objParameters.get("LADSPASSWORD");
      String strLadsTransactions = (String)objParameters.get("LADSTRANSACTIONS");
      if (strLadsTransactions == null) {
         strLadsTransactions = "*ALL";
      }
      String[] strTransactions = strLadsTransactions.split(",");
      cstrLadsHistoryDays = (String)objParameters.get("LADSHISTORYDAYS");
      if (cstrLadsHistoryDays == null) {
         cstrLadsHistoryDays = "*ALL";
      }
      cstrLogging = (String)objParameters.get("LOGGING");

      //
      // Monitor exceptions
      //
      try {
         
         ///////////////////////////////////////////
         // Step 1 - Connect to the LADS database //
         ///////////////////////////////////////////
         
         //
         // Create an Oracle thin JDBC connection
         //
         try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cobjOracleConnection = DriverManager.getConnection(strLadsConnection, strLadsUserId, strLadsPassword);
            cobjOracleConnection.setAutoCommit(false);
         } catch(Exception objException) {
            throw new Exception("Oracle connection failed - " + objException.getMessage());
         }
         
         ////////////////////////////////////////////////////
         // Step 2 - Process the LADS transaction requests //
         ////////////////////////////////////////////////////
         
         //
         // Process the transaction requests
         //
         for (int i=0; i<strTransactions.length; i++) {
            if (strTransactions[i].toUpperCase().equals("*SALES_ORDER_DELETED")) {
               retrieveSalesOrderDeleted();
            } else if (strTransactions[i].toUpperCase().equals("*PURCHASE_ORDER_DELETED")) {
               retrievePurchaseOrderDeleted();
            } else if (strTransactions[i].toUpperCase().equals("*DELIVERY_DELETED")) {
               retrieveDeliveryDeleted();
            } else if (strTransactions[i].toUpperCase().equals("*SALES_ORDER_LINE_STATUS")) {
               retrieveSalesOrderLineStatus();
            }
         }

      } catch(Exception objException) {
         throw new Exception("SAPLAD04 - " + objException.getMessage());
      } finally {
         if (cobjOracleConnection != null) {
            cobjOracleConnection.close();
         }
         cobjOracleConnection = null;
      }
      
   }
   
   /**
    * Processes the sales order deleted request.
    * @throws Exception the exception message
    */
   private void retrieveSalesOrderDeleted() throws Exception {
        
      //
      // Retrieve the LADS sales order list
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start LADS sales order list retrieval: " + Calendar.getInstance().getTime());
      }
      cobjList = new ArrayList();
      try {
         if (cstrLadsHistoryDays.equals("*ALL")) {
            cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select belnr from lads_sal_ord_hdr') }");
         } else {
            cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select belnr from lads_sal_ord_hdr where lads_status != ''4'' and lads_date >= (sysdate - " + cstrLadsHistoryDays + ")') }");
         }
         cobjOracleStatement.registerOutParameter(1, Types.CLOB);
         cobjOracleStatement.execute();
         Clob objReturn = cobjOracleStatement.getClob(1);
         String strData = null;
         BufferedReader objReader = new BufferedReader(objReturn.getCharacterStream());
         while((strData = objReader.readLine()) != null) {
            if (!strData.equals("")) {
               StringTokenizer objTokenizer = new StringTokenizer(strData,",");
               while (objTokenizer.hasMoreTokens()) {
                  cobjList.add(objTokenizer.nextToken());
               }
            }
         }
         objReader.close();
      } catch(Exception objException) {
         throw new Exception("LADS sales order list query failed - " + objException.getMessage());
      } finally {
         if (cobjOracleStatement != null) {
            cobjOracleStatement.close();
         }
         cobjOracleStatement = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("    LADS sales order list count: " + cobjList.size());
         System.out.println("End LADS sales order list retrieval: " + Calendar.getInstance().getTime());
      }

      //
      // Load the lookup/check arrays
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start LADS sales order lookup/check build: " + Calendar.getInstance().getTime());
      }
      cobjLookup = cSapUtility.getOrConditionsArray(cobjList,"VBELN = '<KEYVALUE></KEYVALUE>'",cintGroup);
      cobjCheck = cSapUtility.getValuesArray(cobjList,cintGroup);
      if (cstrLogging.equals("1")) {
         System.out.println("End LADS sales order lookup/check build: " + Calendar.getInstance().getTime());
      }

      //
      // Perform the SAP sales order lookup
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start SAP sales order lookup retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         cbolData = false;
         for (int i=0; i<cobjLookup.size(); i++) {
            cobjSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
            cobjSapSingleQuery.execute("SALES_ORDER", "VBAK", "VBELN", (String[])cobjLookup.get(i), (String[])cobjCheck.get(i));
            cobjSapSingleResultSet = cobjSapSingleQuery.getResultSet();
            if (!cbolData) {
               cobjSapSingleResultSet.toInterface(cstrOutputFile, cstrIdoc, "SALES_ORDER_DELETED", cbolAppend);
               cbolAppend = true;
               cbolData = true;
            } else {
               cobjSapSingleResultSet.appendToInterface(cstrOutputFile);
            }
         }
      } catch(Exception objException) {
         throw new Exception("SAP sales order lookup query failed - " + objException.getMessage());
      } finally {
         cobjSapSingleResultSet = null;
         cobjSapSingleQuery = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("End SAP sales order lookup retrieval: " + Calendar.getInstance().getTime());
      }
         
   }
   
   /**
    * Processes the purchase order deleted request.
    * @throws Exception the exception message
    */
   private void retrievePurchaseOrderDeleted() throws Exception {
        
      //
      // Retrieve the LADS purchase order list
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start LADS purchase order list retrieval: " + Calendar.getInstance().getTime());
      }
      cobjList = new ArrayList();
      try {
         if (cstrLadsHistoryDays.equals("*ALL")) {
            cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select belnr from lads_sto_po_hdr where lads_status != ''4''') }");
         } else {
            cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select belnr from lads_sto_po_hdr where lads_status != ''4'' and lads_date >= (sysdate - " + cstrLadsHistoryDays + ")') }");
         }
         cobjOracleStatement.registerOutParameter(1, Types.CLOB);
         cobjOracleStatement.execute();
         Clob objReturn = cobjOracleStatement.getClob(1);
         String strData = null;
         BufferedReader objReader = new BufferedReader(objReturn.getCharacterStream());
         while((strData = objReader.readLine()) != null) {
            if (!strData.equals("")) {
               StringTokenizer objTokenizer = new StringTokenizer(strData,",");
               while (objTokenizer.hasMoreTokens()) {
                  cobjList.add(objTokenizer.nextToken());
               }
            }
         }
         objReader.close();
      } catch(Exception objException) {
         throw new Exception("LADS purchase order list query failed - " + objException.getMessage());
      } finally {
         if (cobjOracleStatement != null) {
            cobjOracleStatement.close();
         }
         cobjOracleStatement = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("    LADS purchase order list count: " + cobjList.size());
         System.out.println("End LADS purchase order list retrieval: " + Calendar.getInstance().getTime());
      }

      //
      // Load the lookup/check arrays
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start LADS purchase order lookup/check build: " + Calendar.getInstance().getTime());
      }
      cobjLookup = cSapUtility.getOrConditionsArray(cobjList,"EBELN = '<KEYVALUE></KEYVALUE>'",cintGroup);
      cobjCheck = cSapUtility.getValuesArray(cobjList,cintGroup);
      if (cstrLogging.equals("1")) {
         System.out.println("End LADS purchase order lookup/check build: " + Calendar.getInstance().getTime());
      }

      //
      // Perform the SAP sales order lookup
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start SAP purchase order lookup retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         cbolData = false;
         for (int i=0; i<cobjLookup.size(); i++) {
            cstrTest = cSapUtility.concatenateArray((String[])cobjLookup.get(i), new String[]{" AND LOEKZ <> 'L'"});
            cobjSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
            cobjSapSingleQuery.execute("PURCHASE_ORDER", "EKPO", "EBELN", cstrTest, (String[])cobjCheck.get(i));
            cobjSapSingleResultSet = cobjSapSingleQuery.getResultSet();
            if (!cbolData) {
               cobjSapSingleResultSet.toInterface(cstrOutputFile, cstrIdoc, "PURCHASE_ORDER_DELETED", cbolAppend);
               cbolAppend = true;
               cbolData = true;
            } else {
               cobjSapSingleResultSet.appendToInterface(cstrOutputFile);
            }
         }
      } catch(Exception objException) {
         throw new Exception("SAP purchase order lookup query failed - " + objException.getMessage());
      } finally {
         cobjSapSingleResultSet = null;
         cobjSapSingleQuery = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("End SAP purchase order lookup retrieval: " + Calendar.getInstance().getTime());
      }
 
   }
   
   /**
    * Processes the delivery deleted request.
    * @throws Exception the exception message
    */
   private void retrieveDeliveryDeleted() throws Exception {
      
      //
      // Retrieve the LADS delivery list
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start LADS delivery list retrieval: " + Calendar.getInstance().getTime());
      }
      cobjList = new ArrayList();
      try {
         if (cstrLadsHistoryDays.equals("*ALL")) {
            cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select vbeln from lads_del_hdr') }");
         } else {
            cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select vbeln from lads_del_hdr where lads_status != ''4'' and lads_date >= (sysdate - " + cstrLadsHistoryDays + ")') }");
         }
         cobjOracleStatement.registerOutParameter(1, Types.CLOB);
         cobjOracleStatement.execute();
         Clob objReturn = cobjOracleStatement.getClob(1);
         String strData = null;
         BufferedReader objReader = new BufferedReader(objReturn.getCharacterStream());
         while((strData = objReader.readLine()) != null) {
            if (!strData.equals("")) {
               StringTokenizer objTokenizer = new StringTokenizer(strData,",");
               while (objTokenizer.hasMoreTokens()) {
                  cobjList.add(objTokenizer.nextToken());
               }
            }
         }
         objReader.close();
      } catch(Exception objException) {
         throw new Exception("LADS delivery list query failed - " + objException.getMessage());
      } finally {
         if (cobjOracleStatement != null) {
            cobjOracleStatement.close();
         }
         cobjOracleStatement = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("    LADS delivery list count: " + cobjList.size());
         System.out.println("End LADS delivery list retrieval: " + Calendar.getInstance().getTime());
      }

      //
      // Load the lookup/check arrays
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start LADS delivery lookup/check build: " + Calendar.getInstance().getTime());
      }
      cobjLookup = cSapUtility.getOrConditionsArray(cobjList,"VBELN = '<KEYVALUE></KEYVALUE>'",cintGroup);
      cobjCheck = cSapUtility.getValuesArray(cobjList,cintGroup);
      if (cstrLogging.equals("1")) {
         System.out.println("End LADS delivery lookup/check build: " + Calendar.getInstance().getTime());
      }

      //
      // Perform the SAP delivery lookup
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start SAP delivery lookup retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         cbolData = false;
         for (int i=0; i<cobjLookup.size(); i++) {
            cobjSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
            cobjSapSingleQuery.execute("DELIVERY", "LIKP", "VBELN", (String[])cobjLookup.get(i), (String[])cobjCheck.get(i));
            cobjSapSingleResultSet = cobjSapSingleQuery.getResultSet(); 
            if (!cbolData) {
               cobjSapSingleResultSet.toInterface(cstrOutputFile, cstrIdoc, "DELIVERY_DELETED", cbolAppend);
               cbolAppend = true;
               cbolData = true;
            } else {
               cobjSapSingleResultSet.appendToInterface(cstrOutputFile);
            }
         }
      } catch(Exception objException) {
         throw new Exception("SAP delivery lookup query failed - " + objException.getMessage());
      } finally {
         cobjSapSingleResultSet = null;
         cobjSapSingleQuery = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("End SAP delivery lookup retrieval: " + Calendar.getInstance().getTime());
      }
 
   }
   
   /**
    * Processes the sales order line status request.
    * @throws Exception the exception message
    */
   private void retrieveSalesOrderLineStatus() throws Exception {
        
      //
      // Retrieve the LADS sales order list
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start LADS sales order line list retrieval: " + Calendar.getInstance().getTime());
      }
      cobjList = new ArrayList();
      try {
         if (cstrLadsHistoryDays.equals("*ALL")) {
            cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select belnr from lads_sal_ord_hdr') }");
         } else {
            cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select belnr from lads_sal_ord_hdr where lads_status != ''4'' and lads_date >= (sysdate - " + cstrLadsHistoryDays + ")') }");
         }
         cobjOracleStatement.registerOutParameter(1, Types.CLOB);
         cobjOracleStatement.execute();
         Clob objReturn = cobjOracleStatement.getClob(1);
         String strData = null;
         BufferedReader objReader = new BufferedReader(objReturn.getCharacterStream());
         while((strData = objReader.readLine()) != null) {
            if (!strData.equals("")) {
               StringTokenizer objTokenizer = new StringTokenizer(strData,",");
               while (objTokenizer.hasMoreTokens()) {
                  cobjList.add(objTokenizer.nextToken());
               }
            }
         }
         objReader.close();
      } catch(Exception objException) {
         throw new Exception("LADS sales order line list query failed - " + objException.getMessage());
      } finally {
         if (cobjOracleStatement != null) {
            cobjOracleStatement.close();
         }
         cobjOracleStatement = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("    LADS sales order line list count: " + cobjList.size());
         System.out.println("End LADS sales order line list retrieval: " + Calendar.getInstance().getTime());
      }

      //
      // Load the lookup array
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start LADS sales order line line lookup build: " + Calendar.getInstance().getTime());
      }
      cobjLookup = cSapUtility.getOrConditionsArray(cobjList,"VBELN = '<KEYVALUE></KEYVALUE>'",cintGroup);
      if (cstrLogging.equals("1")) {
         System.out.println("End LADS sales order line lookup build: " + Calendar.getInstance().getTime());
      }

      //
      // Perform the SAP sales order lookup
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start SAP sales order line lookup retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         cbolData = false;
         for (int i=0; i<cobjLookup.size(); i++) {
            cobjSapSingleQuery = new cSapSingleQuery(cobjSapConnection); 
            cobjSapSingleQuery.execute("SALES_ORDER_LINE", "VBUP", "VBELN, POSNR, LFSTA", (String[])cobjLookup.get(i), 0, 0);
            cobjSapSingleResultSet = cobjSapSingleQuery.getResultSet();
            if (!cbolData) {
               cobjSapSingleResultSet.toInterface(cstrOutputFile, cstrIdoc, "SALES_ORDER_LINE_STATUS", cbolAppend);
               cbolAppend = true;
               cbolData = true;
            } else {
               cobjSapSingleResultSet.appendToInterface(cstrOutputFile);
            }
         }
      } catch(Exception objException) {
         throw new Exception("SAP sales order line lookup query failed - " + objException.getMessage());
      } finally {
         cobjSapSingleResultSet = null;
         cobjSapSingleQuery = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("End SAP sales order line lookup retrieval: " + Calendar.getInstance().getTime());
      }
         
   }

}