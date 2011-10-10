/**
 * Package : ISI ODS
 * Type    : Class
 * Name    : cSapOds01
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.ods;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;
import java.sql.*;

/**
 * This class implements the SAP to ODS document status functionality. This functionality
 * looks up the SAP table and returns rows that do not exist from a list of supplied values.
 */
public final class cSapOds01 implements iSapInterface {
   
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
   String cstrLogging = null;
   String cstrIdoc = "SAPODS01";
   
   /**
    * Processes the SAP to ODS document status extract.
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
      cstrLogging = null;
      
      //
      // Retrieve any interface specific parameters
      //
      String strOdsConnection = (String)objParameters.get("ODSCONNECTION");
      String strOdsUserId = (String)objParameters.get("ODSUSERID");
      String strOdsPassword = (String)objParameters.get("ODSPASSWORD");
      String strOdsCompany = (String)objParameters.get("ODSCOMPANY");
      String strOdsTransactions = (String)objParameters.get("ODSTRANSACTIONS");
      if (strOdsTransactions == null) {
         strOdsTransactions = "*ALL";
      }
      String[] strTransactions = strOdsTransactions.split(",");
      cstrLogging = (String)objParameters.get("LOGGING");

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
         try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cobjOracleConnection = DriverManager.getConnection(strOdsConnection, strOdsUserId, strOdsPassword);
            cobjOracleConnection.setAutoCommit(false);
         } catch(Exception objException) {
            throw new Exception("Oracle connection failed - " + objException.getMessage());
         }
         
         /////////////////////////////////////////////////////////
         // Step 2 - Output the company code to the output file //
         /////////////////////////////////////////////////////////
         
         //
         // Output the company code
         //
         PrintWriter objPrintWriter = new PrintWriter(new FileWriter(cstrOutputFile, cbolAppend));
         objPrintWriter.print("CPY" + strOdsCompany);                      
         objPrintWriter.close();
         cbolAppend = true;
         
         ///////////////////////////////////////////////////
         // Step 2 - Process the ODS transaction requests //
         ///////////////////////////////////////////////////
         
         //
         // Process the transaction requests
         //
         for (int i=0; i<strTransactions.length; i++) {
            if (strTransactions[i].toUpperCase().equals("*SALES_ORDER_DELETED")) {
               retrieveSalesOrderDeleted(strOdsCompany);
            } else if (strTransactions[i].toUpperCase().equals("*PURCHASE_ORDER_DELETED")) {
               retrievePurchaseOrderDeleted(strOdsCompany);
            } else if (strTransactions[i].toUpperCase().equals("*DELIVERY_DELETED")) {
               retrieveDeliveryDeleted(strOdsCompany);
            } else if (strTransactions[i].toUpperCase().equals("*SALES_ORDER_LINE_STATUS")) {
               retrieveSalesOrderLineStatus(strOdsCompany);
            } else if (strTransactions[i].toUpperCase().equals("*DELIVERY_LINE_STATUS")) {
               retrieveDeliveryLineStatus(strOdsCompany);
            }
         }

      } catch(Exception objException) {
         throw new Exception("SAPODS01 - " + objException.getMessage());
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
   private void retrieveSalesOrderDeleted(String strOdsCompany) throws Exception {
        
      //
      // Retrieve the ODS sales order list
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start ODS sales order list retrieval: " + Calendar.getInstance().getTime());
      }
      cobjList = new ArrayList();
      try {
         cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call ods_buffer.create_buffer('select distinct(order_doc_num) from dw_order_base where company_code = ''" + strOdsCompany + "'' and order_line_status = ''*OPEN''') }");
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
         throw new Exception("ODS sales order list query failed - " + objException.getMessage());
      } finally {
         if (cobjOracleStatement != null) {
            cobjOracleStatement.close();
         }
         cobjOracleStatement = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("    ODS sales order list count: " + cobjList.size());
         System.out.println("End ODS sales order list retrieval: " + Calendar.getInstance().getTime());
      }

      //
      // Load the lookup/check arrays
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start ODS sales order lookup/check build: " + Calendar.getInstance().getTime());
      }
      cobjLookup = cSapUtility.getOrConditionsArray(cobjList,"VBELN = '<KEYVALUE></KEYVALUE>'",cintGroup);
      cobjCheck = cSapUtility.getValuesArray(cobjList,cintGroup);
      if (cstrLogging.equals("1")) {
         System.out.println("End ODS sales order lookup/check build: " + Calendar.getInstance().getTime());
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
            if (cstrLogging.equals("1")) {
               System.out.println("==> SAP sales order lookup retrieval (" + (i+1) + "): " + Calendar.getInstance().getTime());
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
   private void retrievePurchaseOrderDeleted(String strOdsCompany) throws Exception {
        
      //
      // Retrieve the ODS purchase order list
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start ODS purchase order list retrieval: " + Calendar.getInstance().getTime());
      }
      cobjList = new ArrayList();
      try {
         cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call ods_buffer.create_buffer('select distinct(purch_order_doc_num) from dw_purch_base where company_code = ''" + strOdsCompany + "'' and purch_order_line_status = ''*OPEN''') }");
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
         throw new Exception("ODS purchase order list query failed - " + objException.getMessage());
      } finally {
         if (cobjOracleStatement != null) {
            cobjOracleStatement.close();
         }
         cobjOracleStatement = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("    ODS purchase order list count: " + cobjList.size());
         System.out.println("End ODS purchase order list retrieval: " + Calendar.getInstance().getTime());
      }

      //
      // Load the lookup/check arrays
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start ODS purchase order lookup/check build: " + Calendar.getInstance().getTime());
      }
      cobjLookup = cSapUtility.getOrConditionsArray(cobjList,"EBELN = '<KEYVALUE></KEYVALUE>'",cintGroup/5);
      cobjCheck = cSapUtility.getValuesArray(cobjList,cintGroup/5);
      if (cstrLogging.equals("1")) {
         System.out.println("End ODS purchase order lookup/check build: " + Calendar.getInstance().getTime());
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
            if (cstrLogging.equals("1")) {
               System.out.println("==> SAP purchase order lookup retrieval (" + (i+1) + "): " + Calendar.getInstance().getTime());
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
   private void retrieveDeliveryDeleted(String strOdsCompany) throws Exception {
      
      //
      // Retrieve the ODS delivery list
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start ODS delivery list retrieval: " + Calendar.getInstance().getTime());
      }
      cobjList = new ArrayList();
      try {
         cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call ods_buffer.create_buffer('select distinct(dlvry_doc_num) from dw_dlvry_base where company_code = ''" + strOdsCompany + "'' and dlvry_line_status = ''*OPEN''') }");
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
         throw new Exception("ODS delivery list query failed - " + objException.getMessage());
      } finally {
         if (cobjOracleStatement != null) {
            cobjOracleStatement.close();
         }
         cobjOracleStatement = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("    ODS delivery list count: " + cobjList.size());
         System.out.println("End ODS delivery list retrieval: " + Calendar.getInstance().getTime());
      }

      //
      // Load the lookup/check arrays
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start ODS delivery lookup/check build: " + Calendar.getInstance().getTime());
      }
      cobjLookup = cSapUtility.getOrConditionsArray(cobjList,"VBELN = '<KEYVALUE></KEYVALUE>'",cintGroup);
      cobjCheck = cSapUtility.getValuesArray(cobjList,cintGroup);
      if (cstrLogging.equals("1")) {
         System.out.println("End ODS delivery lookup/check build: " + Calendar.getInstance().getTime());
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
            if (cstrLogging.equals("1")) {
               System.out.println("==> SAP delivery lookup retrieval (" + (i+1) + "): " + Calendar.getInstance().getTime());
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
   private void retrieveSalesOrderLineStatus(String strOdsCompany) throws Exception {
        
      //
      // Retrieve the ODS sales order list
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start ODS sales order line list retrieval: " + Calendar.getInstance().getTime());
      }
      cobjList = new ArrayList();
      try {
         cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call ods_buffer.create_buffer('select distinct(order_doc_num) from dw_order_base where company_code = ''" + strOdsCompany + "'' and order_line_status = ''*OPEN''') }");
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
         throw new Exception("ODS sales order line list query failed - " + objException.getMessage());
      } finally {
         if (cobjOracleStatement != null) {
            cobjOracleStatement.close();
         }
         cobjOracleStatement = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("    ODS sales order line list count: " + cobjList.size());
         System.out.println("End ODS sales order line list retrieval: " + Calendar.getInstance().getTime());
      }

      //
      // Load the lookup array
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start ODS sales order line line lookup build: " + Calendar.getInstance().getTime());
      }
      cobjLookup = cSapUtility.getOrConditionsArray(cobjList,"VBELN = '<KEYVALUE></KEYVALUE>'",cintGroup/5);
      if (cstrLogging.equals("1")) {
         System.out.println("End ODS sales order line lookup build: " + Calendar.getInstance().getTime());
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
            cobjSapSingleQuery.execute("SALES_ORDER_LINE", "VBUP", "VBELN, POSNR, GBSTA", (String[])cobjLookup.get(i), 0, 0);
            cobjSapSingleResultSet = cobjSapSingleQuery.getResultSet();
            if (!cbolData) {
               cobjSapSingleResultSet.toInterface(cstrOutputFile, cstrIdoc, "SALES_ORDER_LINE_STATUS", cbolAppend);
               cbolAppend = true;
               cbolData = true;
            } else {
               cobjSapSingleResultSet.appendToInterface(cstrOutputFile);
            }
            if (cstrLogging.equals("1")) {
               System.out.println("==> SAP sales order line lookup retrieval (" + (i+1) + "): " + Calendar.getInstance().getTime());
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
   
   /**
    * Processes the delivery line status request.
    * @throws Exception the exception message
    */
   private void retrieveDeliveryLineStatus(String strOdsCompany) throws Exception {
        
      //
      // Retrieve the ODS sales order list
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start ODS delivery line list retrieval: " + Calendar.getInstance().getTime());
      }
      cobjList = new ArrayList();
      try {
         cobjOracleStatement = cobjOracleConnection.prepareCall("{ ? = call ods_buffer.create_buffer('select distinct(dlvry_doc_num) from dw_dlvry_base where company_code = ''" + strOdsCompany + "'' and dlvry_line_status = ''*OPEN''') }");
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
         throw new Exception("ODS delivery line list query failed - " + objException.getMessage());
      } finally {
         if (cobjOracleStatement != null) {
            cobjOracleStatement.close();
         }
         cobjOracleStatement = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("    ODS delivery line list count: " + cobjList.size());
         System.out.println("End ODS delivery line list retrieval: " + Calendar.getInstance().getTime());
      }

      //
      // Load the lookup array
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start ODS delivery line line lookup build: " + Calendar.getInstance().getTime());
      }
      cobjLookup = cSapUtility.getOrConditionsArray(cobjList,"VBELN = '<KEYVALUE></KEYVALUE>'",cintGroup/5);
      if (cstrLogging.equals("1")) {
         System.out.println("End ODS delivery line lookup build: " + Calendar.getInstance().getTime());
      }

      //
      // Perform the SAP sales order lookup
      //
      if (cstrLogging.equals("1")) {
         System.out.println("Start SAP delivery line lookup retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         cbolData = false;
         for (int i=0; i<cobjLookup.size(); i++) {
            cobjSapSingleQuery = new cSapSingleQuery(cobjSapConnection); 
            cobjSapSingleQuery.execute("DELIVERY_LINE", "VBUP", "VBELN, POSNR, GBSTA", (String[])cobjLookup.get(i), 0, 0);
            cobjSapSingleResultSet = cobjSapSingleQuery.getResultSet();
            if (!cbolData) {
               cobjSapSingleResultSet.toInterface(cstrOutputFile, cstrIdoc, "DELIVERY_LINE_STATUS", cbolAppend);
               cbolAppend = true;
               cbolData = true;
            } else {
               cobjSapSingleResultSet.appendToInterface(cstrOutputFile);
            }
            if (cstrLogging.equals("1")) {
               System.out.println("==> SAP delivery line lookup retrieval (" + (i+1) + "): " + Calendar.getInstance().getTime());
            }
         }
      } catch(Exception objException) {
         throw new Exception("SAP delivery line lookup query failed - " + objException.getMessage());
      } finally {
         cobjSapSingleResultSet = null;
         cobjSapSingleQuery = null;
      }
      if (cstrLogging.equals("1")) {
         System.out.println("End SAP delivery line lookup retrieval: " + Calendar.getInstance().getTime());
      }
         
   }

}