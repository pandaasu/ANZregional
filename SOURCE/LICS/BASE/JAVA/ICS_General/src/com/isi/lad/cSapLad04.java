/**
 * Package : ISI VDS
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
 * table and returns rows that do not exist.
 */
public final class cSapLad04 implements iSapInterface {
   
   /**
    * Processes the SAP validation extract.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSapConnection, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Retrieve any interface specific parameters
      //
      String strLadsConnection = (String)objParameters.get("LADSCONNECTION");
      String strLadsUserId = (String)objParameters.get("LADSUSERID");
      String strLadsPassword = (String)objParameters.get("LADSPASSWORD");
      String strLadsHistoryDays = (String)objParameters.get("LADSHISTORYDAYS");
      String strLogging = (String)objParameters.get("LOGGING");
      if (strLadsHistoryDays == null) {
         strLadsHistoryDays = "*ALL";
      }
      
      //
      // Initialise the local variables
      //
      char[] chrSpaces = new char[1024];
      Arrays.fill(chrSpaces, ' ');
      String strSpaces = String.valueOf(chrSpaces);
      String strIdoc = "SAPLAD04";

      //
      // Instance the loal references
      //
      Connection objOracleConnection = null;
      CallableStatement objOracleStatement = null;
      cSapSingleQuery objSapSingleQuery = null;
      cSapSingleResultSet objSapSingleResultSet = null;
      boolean bolAppend = false;
      boolean bolData = false;
      int intGroup = 1000;
      int intCount = 0;
      ArrayList objList = null;
      ArrayList objLookup = null;
      ArrayList objCheck = null;
      String[] strTest = null;
      String[] strKeys = null;
      
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
            objOracleConnection = DriverManager.getConnection(strLadsConnection, strLadsUserId, strLadsPassword);
            objOracleConnection.setAutoCommit(false);
         } catch(Exception objException) {
            throw new Exception("Oracle connection failed - " + objException.getMessage());
         }
         
         //////////////////////////////////////////////////////
         // Step 2 - Check sales order data deleted from SAP //
         //////////////////////////////////////////////////////
         
         //
         // Retrieve the LADS sales order list
         //
         if (strLogging.equals("1")) {
            System.out.println("Start LADS sales order list retrieval: " + Calendar.getInstance().getTime());
         }
         objList = new ArrayList();
         try {
            if (strLadsHistoryDays.equals("*ALL")) {
               objOracleStatement = objOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select belnr from lads_sal_ord_hdr') }");
            } else {
               objOracleStatement = objOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select belnr from lads_sal_ord_hdr where lads_date >= (sysdate - " + strLadsHistoryDays + ")') }");
            }
            objOracleStatement.registerOutParameter(1, Types.CLOB);
            objOracleStatement.execute();
            Clob objReturn = objOracleStatement.getClob(1);
            String strData = null;
            BufferedReader objReader = new BufferedReader(objReturn.getCharacterStream());
            while((strData = objReader.readLine()) != null) {
               if (!strData.equals("")) {
                  StringTokenizer objTokenizer = new StringTokenizer(strData,",");
                  while (objTokenizer.hasMoreTokens()) {
                     objList.add(objTokenizer.nextToken());
                  }
               }
            }
            objReader.close();
         } catch(Exception objException) {
            throw new Exception("LADS sales order list query failed - " + objException.getMessage());
         } finally {
            if (objOracleStatement != null) {
               objOracleStatement.close();
            }
            objOracleStatement = null;
         }
         if (strLogging.equals("1")) {
            System.out.println("    LADS sales order list count: " + objList.size());
            System.out.println("End LADS sales order list retrieval: " + Calendar.getInstance().getTime());
         }
         
         //
         // Load the lookup/Check arrays
         //
         if (strLogging.equals("1")) {
            System.out.println("Start LADS sales order lookup/check build: " + Calendar.getInstance().getTime());
         }
         objLookup = cSapUtility.getOrConditionsArray(objList,"VBELN = '<KEYVALUE></KEYVALUE>'",intGroup);
         objCheck = cSapUtility.getValuesArray(objList,intGroup);
         if (strLogging.equals("1")) {
            System.out.println("End LADS sales order lookup/check build: " + Calendar.getInstance().getTime());
         }
         
         //
         // Perform the SAP sales order lookup
         //
         if (strLogging.equals("1")) {
            System.out.println("Start SAP sales order lookup retrieval: " + Calendar.getInstance().getTime());
         }
         try {
            bolData = false;
            for (int i=0; i<objLookup.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(objSapConnection);
               objSapSingleQuery.execute("SALES_ORDER", "VBAK", "VBELN", (String[])objLookup.get(i), (String[])objCheck.get(i));
               objSapSingleResultSet = objSapSingleQuery.getResultSet();
               if (!bolData) {
                  objSapSingleResultSet.toInterface(strOutputFile, strIdoc, "SALES_ORDER", bolAppend);
                  bolAppend = true;
                  bolData = true;
               } else {
                  objSapSingleResultSet.appendToInterface(strOutputFile);
               }
            }
         } catch(Exception objException) {
            throw new Exception("SAP sales order lookup query failed - " + objException.getMessage());
         } finally {
            objSapSingleResultSet = null;
            objSapSingleQuery = null;
         }
         if (strLogging.equals("1")) {
            System.out.println("End SAP sales order lookup retrieval: " + Calendar.getInstance().getTime());
         }
         
         ///////////////////////////////////////////////////
         // Step 3 - Check delivery data deleted from SAP //
         ///////////////////////////////////////////////////
         
         //
         // Retrieve the LADS delivery list
         //
         if (strLogging.equals("1")) {
            System.out.println("Start LADS delivery list retrieval: " + Calendar.getInstance().getTime());
         }
         objList = new ArrayList();
         try {
            if (strLadsHistoryDays.equals("*ALL")) {
               objOracleStatement = objOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select vbeln from lads_del_hdr') }");
            } else {
               objOracleStatement = objOracleConnection.prepareCall("{ ? = call lads_buffer.create_buffer('select vbeln from lads_del_hdr where lads_date >= (sysdate - " + strLadsHistoryDays + ")') }");
            }
            objOracleStatement.registerOutParameter(1, Types.CLOB);
            objOracleStatement.execute();
            Clob objReturn = objOracleStatement.getClob(1);
            String strData = null;
            BufferedReader objReader = new BufferedReader(objReturn.getCharacterStream());
            while((strData = objReader.readLine()) != null) {
               if (!strData.equals("")) {
                  StringTokenizer objTokenizer = new StringTokenizer(strData,",");
                  while (objTokenizer.hasMoreTokens()) {
                     objList.add(objTokenizer.nextToken());
                  }
               }
            }
            objReader.close();
         } catch(Exception objException) {
            throw new Exception("LADS delivery list query failed - " + objException.getMessage());
         } finally {
            if (objOracleStatement != null) {
               objOracleStatement.close();
            }
            objOracleStatement = null;
         }
         if (strLogging.equals("1")) {
            System.out.println("    LADS delivery list count: " + objList.size());
            System.out.println("End LADS delivery list retrieval: " + Calendar.getInstance().getTime());
         }
         
         //
         // Load the lookup/Check arrays
         //
         if (strLogging.equals("1")) {
            System.out.println("Start LADS delivery lookup/check build: " + Calendar.getInstance().getTime());
         }
         objLookup = cSapUtility.getOrConditionsArray(objList,"VBELN = '<KEYVALUE></KEYVALUE>'",intGroup);
         objCheck = cSapUtility.getValuesArray(objList,intGroup);
         if (strLogging.equals("1")) {
            System.out.println("End LADS delivery lookup/check build: " + Calendar.getInstance().getTime());
         }
         
         //
         // Perform the SAP delivery lookup
         //
         if (strLogging.equals("1")) {
            System.out.println("Start SAP delivery lookup retrieval: " + Calendar.getInstance().getTime());
         }
         try {
            bolData = false;
            for (int i=0; i<objLookup.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(objSapConnection);
               objSapSingleQuery.execute("DELIVERY", "LIKP", "VBELN", (String[])objLookup.get(i), (String[])objCheck.get(i));
               objSapSingleResultSet = objSapSingleQuery.getResultSet(); 
               if (!bolData) {
                  objSapSingleResultSet.toInterface(strOutputFile, strIdoc, "DELIVERY", bolAppend);
                  bolAppend = true;
                  bolData = true;
               } else {
                  objSapSingleResultSet.appendToInterface(strOutputFile);
               }
            }
         } catch(Exception objException) {
            throw new Exception("SAP delivery lookup query failed - " + objException.getMessage());
         } finally {
            objSapSingleResultSet = null;
            objSapSingleQuery = null;
         }
         if (strLogging.equals("1")) {
            System.out.println("End SAP delivery lookup retrieval: " + Calendar.getInstance().getTime());
         }
         
      } catch(Exception objException) {
         throw new Exception("SAPLAD04 - " + objException.getMessage());
      } finally {
         if (objOracleConnection != null) {
            objOracleConnection.close();
         }
         objOracleConnection = null;
      }
 
   }

}