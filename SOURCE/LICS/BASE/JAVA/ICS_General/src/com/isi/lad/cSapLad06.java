/**
 * Package : ISI LADS
 * Type    : Class
 * Name    : cSapLad06
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.lad;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements the SAP to LADS Contract functionality. This functionality
 * downloads the EKKO and EKPO tables from SAP.
 *  Note that 
 */
public final class cSapLad06 implements iSapInterface {
   
   //
   // Declare the class variable
   //
   cSapConnection cobjSapConnection = null;
   
   /**
    * Processes the SAP to LADS Contract extract.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSapConnection, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Initialise the class variables
      //
      cSapSingleQuery objEKKOQuery = null;
      cSapSingleResultSet objEKKOResultSet = null;
      cSapSingleQuery objEKPOQuery = null;
      cSapSingleResultSet objEKPOResultSet = null;
      int intGroup = 1000;
      ArrayList objEBELN = new ArrayList();
      String strLogging = null;
      String strIdoc = "SAPLAD02";
      cobjSapConnection = objSapConnection;
      
      //
      // Retrieve the current date
      //
      GregorianCalendar objCalendar = new GregorianCalendar();
      DecimalFormat objDecimalFormat = new DecimalFormat();
      objDecimalFormat.setGroupingSize(0);
      objDecimalFormat.setMinimumFractionDigits(0);
      objDecimalFormat.setMinimumIntegerDigits(4);
      String strYear = objDecimalFormat.format((long)objCalendar.get(Calendar.YEAR));
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strMonth = objDecimalFormat.format((long)objCalendar.get(Calendar.MONTH)+1);
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strDay = objDecimalFormat.format((long)objCalendar.get(Calendar.DATE));
      String strSapDate = strYear + strMonth + strDay;
         
      //
      // Retrieve any interface specific parameters
      //
      String strEKKOFilters = (String)objParameters.get("EKKOFILTERS");
      if (strEKKOFilters == null) {
         strEKKOFilters = "KDATE >= '" + strSapDate + "'";
      } else {
         strEKKOFilters = strEKKOFilters + " AND KDATE >= '" + strSapDate + "'";
      }
      String strEKKOFields = (String)objParameters.get("EKKOFIELDS");
      if (strEKKOFields == null) {
         strEKKOFields = "*";
      }
      String strEKPOFields = (String)objParameters.get("EKPOFIELDS");
      if (strEKPOFields == null) {
         strEKPOFields = "*";
      }
      strLogging = (String)objParameters.get("LOGGING");
    
      //
      // Start the logging when required
      //
      if (strLogging.equals("1")) {
         System.out.println("Start SAPLAD06 Contract retrieval: " + Calendar.getInstance().getTime());
      }
      
      ///////////////////////////////////////////////
      // Step 1 - Retrieve the SAP EKKO table rows //
      ///////////////////////////////////////////////
         
      //
      // Perform the SAP EKKO table retrieval
      //
      if (strLogging.equals("1")) {
         System.out.println("Start EKKO retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         boolean bolData = false;
         int intRowSkips = 0;
         int intRowCount = 10000;
         boolean bolRead = true;
         while (bolRead) {
            objEKKOQuery = new cSapSingleQuery(cobjSapConnection);
            objEKKOQuery.execute("EKKO", "EKKO", strEKKOFields, new String[]{strEKKOFilters}, intRowSkips, intRowCount);
            objEKKOResultSet = objEKKOQuery.getResultSet();
            if (!bolData) {
               objEKKOResultSet.toInterfaceMeta(strOutputFile, strIdoc, "EKKO", false);
               bolData = true;
            } else {
               objEKKOResultSet.appendToInterface(strOutputFile);
            }
            if (strLogging.equals("1")) {
               System.out.println("EKKO rows (" + objEKKOResultSet.getRowCount() + ") retrieved and output: " + Calendar.getInstance().getTime());
            }
            appendEKKOConditions(objEKKOResultSet,objEBELN,intGroup);
            if (strLogging.equals("1")) {
               System.out.println("EKKO rows (" + objEKKOResultSet.getRowCount() + ") appended to filters: " + Calendar.getInstance().getTime());
            }
            if (objEKKOResultSet.getRowCount() < intRowCount) {
               bolRead = false;
            } else {
               intRowSkips = intRowSkips + intRowCount;
            }
         }     
      } catch(Exception objException) {
         throw new Exception("SAPLAD06 - EKKO retrieval failed - " + objException.getMessage());
      } finally {
         objEKKOResultSet = null;
         objEKKOQuery = null;
      }
      if (strLogging.equals("1")) {
         System.out.println("End EKKO retrieval: " + Calendar.getInstance().getTime());
      }
      
      ///////////////////////////////////////////////
      // Step 2 - Retrieve the SAP EKPO table rows //
      ///////////////////////////////////////////////
         
      //
      // Perform the SAP EKPO table retrieval
      //
      if (strLogging.equals("1")) {
         System.out.println("Start EKPO retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         boolean bolData = false;
         for (int i=0; i<objEBELN.size(); i++) {
            objEKPOQuery = new cSapSingleQuery(cobjSapConnection);
            objEKPOQuery.execute("EKPO", "EKPO", strEKPOFields, (String[])objEBELN.get(i), 0, 0);
            objEKPOResultSet = objEKPOQuery.getResultSet();
            if (!bolData) {
               objEKPOResultSet.toInterfaceMeta(strOutputFile, strIdoc, "EKPO", true);
               bolData = true;
            } else {
               objEKPOResultSet.appendToInterface(strOutputFile);
            }
            if (strLogging.equals("1")) {
               System.out.println("==> EKPO retrieval group (" + (i+1) + ") rows (" + objEKPOResultSet.getRowCount() + ") retrieved and output: " + Calendar.getInstance().getTime());
            }
         }
      } catch(Exception objException) {
         throw new Exception("SAPLAD06 - EKPO retrieval failed - " + objException.getMessage());
      } finally {
         objEKPOResultSet = null;
         objEKPOQuery = null;
      }
      if (strLogging.equals("1")) {
         System.out.println("End EKPO retrieval: " + Calendar.getInstance().getTime());
      }
      
      /////////////////
      // End extract //
      /////////////////
      
      //
      // End the logging when required
      //
      if (strLogging.equals("1")) {
         System.out.println("End SAPLAD06 Contract retrieval: " + Calendar.getInstance().getTime());
      }
      
   }
   
   /**
    * Retrieves the EKKO condition statements
    * @param objEKKOResultSet the EKKO table result set
    * @param objEBELN the EKKO condtion array list
    * @param intGroup the result grouping
    * @throws Exception the exception message
    */
   public void appendEKKOConditions(cSapSingleResultSet objEKKOResultSet, ArrayList objEBELN, int intGroup) throws Exception {
      
      //
      // Remove duplicates from the source
      //
      String[] strEKKO = new String[objEKKOResultSet.getRowCount()];
      for (int i=0; i<objEKKOResultSet.getRowCount(); i++) {
         strEKKO[i] = objEKKOResultSet.getFieldValue(i,"EBELN");
      }
      Arrays.sort(strEKKO);
      ArrayList objEKKO = new ArrayList();
      String strSAVE = "**START**";
      for (int i=0; i<strEKKO.length; i++) {
         if (!strEKKO[i].equals(strSAVE)) {
            strSAVE = strEKKO[i];
            objEKKO.add(strEKKO[i]);
         }
      }

      //
      // Load the EKKO keys array
      //
      String[] strKeys = null;
      int intTotal = objEKKO.size();
      int intCount = intGroup - 1;
      for (int i=0; i<objEKKO.size(); i++) {
         if ((intCount + 1) == intGroup) {
            if (((intTotal-i)-intGroup) > 0) {
               strKeys = new String[intGroup];
            } else {
               strKeys = new String[(intTotal-i)];
            }
            objEBELN.add(strKeys);
            intCount = 0;
         } else {
            intCount++;
         }
         if (intCount == 0) {
            strKeys[intCount] = "(EBELN = '" + ((String)objEKKO.get(i)).trim() + "'";
         } else {
            strKeys[intCount] = "OR EBELN = '" + ((String)objEKKO.get(i)).trim() + "'";
            if (intCount == (strKeys.length-1)) {
               strKeys[intCount] = strKeys[intCount] + ")";
            }
         }
      }
      strKeys = null;
      
   }

}