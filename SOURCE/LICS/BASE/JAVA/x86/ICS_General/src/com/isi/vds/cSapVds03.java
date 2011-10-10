/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : cSapVds03
 * Author  : Steve Gregan
 * Date    : August 2009
 */
package com.isi.vds;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements the SAP customer change functionality. This functionality retrieves
 * SAP customer data based on changes to SAP table KNA1 within the specified data range.
 */
public final class cSapVds03 implements iSapDualInterface {
   
   /**
    * Processes the SAP validation extract.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSapConnection01, cSapConnection objSapConnection02, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Retrieve any interface specific interface parameters
      //                
      String strGlobalKNA1DateRange = (String)objParameters.get("GLOBAL_KNA1_DATERANGE");
      String strGlobalKNB1Filter = (String)objParameters.get("GLOBAL_KNB1_FILTER");
      String strGlobalKNVVFilter = (String)objParameters.get("GLOBAL_KNVV_FILTER");
      String strVdsGlobalQuery = (String)objParameters.get("VDS_GLOBAL_QUERY");                
      String strVdsKNA1Columns = (String)objParameters.get("VDS_KNA1_COLUMNS");
      String strVdsKNB1Columns = (String)objParameters.get("VDS_KNB1_COLUMNS");
      String strVdsKNVIColumns = (String)objParameters.get("VDS_KNVI_COLUMNS");
      String strVdsKNVVColumns = (String)objParameters.get("VDS_KNVV_COLUMNS");
      String strLogging = (String)objParameters.get("LOGGING");
      if (strVdsGlobalQuery == null || strVdsGlobalQuery.toUpperCase().equals("*NONE")) {
         throw new Exception("SAPVDS03 - Global validation query must be supplied");
      }
      if (strGlobalKNA1DateRange == null) {
         throw new Exception("SAPVDS03 - Global KNA1 date range must be supplied");
      }
      if (strVdsKNA1Columns == null) {
         strVdsKNA1Columns = "*";
      }
      if (strVdsKNB1Columns == null) {
         strVdsKNB1Columns = "*";
      }
      if (strVdsKNVIColumns == null) {
         strVdsKNVIColumns = "*";
      }
      if (strVdsKNVVColumns == null) {
         strVdsKNVVColumns = "*";
      }
      if (strLogging == null) {
         strLogging = "0";   
      }
      
      //
      // Pad the validation system and object to the maximum
      //
      char[] chrSpaces = new char[1024];
      Arrays.fill(chrSpaces, ' ');
      String strSpaces = String.valueOf(chrSpaces);
      strVdsGlobalQuery = strVdsGlobalQuery + strSpaces.substring(0,30-strVdsGlobalQuery.length());
      String strIdoc = "SAPVDS03";
      String strTable = null;
      
      //
      // Retrieve the date range from the parameter value
      //
      GregorianCalendar objCalendar = new GregorianCalendar();
      int intRoll = 0;
      try {
         intRoll = Integer.parseInt(strGlobalKNA1DateRange.substring(5,strGlobalKNA1DateRange.length()));
      } catch(Exception objException) {
         intRoll = 0;
      }
      if (intRoll != 0) {
         long lngThisTime = objCalendar.getTimeInMillis();
         objCalendar.roll(Calendar.DAY_OF_YEAR, intRoll);
         long lngNextTime = objCalendar.getTimeInMillis();
         if (lngNextTime > lngThisTime) {
            objCalendar.roll(Calendar.YEAR, -1);
         }
      }
      DecimalFormat objDecimalFormat = new DecimalFormat();
      objDecimalFormat.setGroupingSize(0);
      objDecimalFormat.setMinimumFractionDigits(0);
      objDecimalFormat.setMinimumIntegerDigits(4);
      String strYear = objDecimalFormat.format((long)objCalendar.get(Calendar.YEAR));
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strMonth = objDecimalFormat.format((long)objCalendar.get(Calendar.MONTH)+1);
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strDay = objDecimalFormat.format((long)objCalendar.get(Calendar.DATE));
      strGlobalKNA1DateRange = strYear + strMonth + strDay;
      if (strLogging.equals("1")) {
         System.out.println("Global KNA1 date range: " + strGlobalKNA1DateRange);
      }

      //
      // Instance the loal references
      //
      cSapSingleQuery objSapSingleQuery = null;
      cSapSingleResultSet objSapSingleResultSet = null;
      boolean bolAppend = false;
      
      ///////////////////////////////////////////////////////////////////////
      // Step 1 - Retrieve the customer change list from the source server //
      ///////////////////////////////////////////////////////////////////////
      
      //
      // Perform logging when required
      //
      if (strLogging.equals("1")) {
         System.out.println("Start Global change list retrieval: " + Calendar.getInstance().getTime());
      }
      
      //
      // Retrieve the list of KNA1 changes for the data range
      //
      ArrayList objKUNNR = null;
      String[] strFilter = null;
      strFilter = new String[]{"ERDAT >= '" + strGlobalKNA1DateRange + "'"};
      try {
         objSapSingleQuery = new cSapSingleQuery(objSapConnection01);
         objSapSingleQuery.execute("KNA1", "KNA1", "KUNNR", strFilter,0,0);
         objKUNNR = objSapSingleQuery.getResultSet().getOrConditionsArray("KNA1","KUNNR = '<KEYVALUE>KUNNR</KEYVALUE>'",1000);
         if (strLogging.equals("1")) {
            System.out.println("Global change list count: " + objSapSingleQuery.getResultSet().getRowCount("KNA1"));
         }
      } catch(Exception objException) {
         throw new Exception("SAPVDS03 - Global KNA1 query failed - " + objException.getMessage());
      } finally {
         objSapSingleResultSet = null;
         objSapSingleQuery = null;
      }
      strFilter = null;
      
      //
      // Perform logging when required
      //
      if (strLogging.equals("1")) {
         System.out.println("End Global change list retrieval: " + Calendar.getInstance().getTime());
      }
      
      /////////////////////////////////////////////////////////////////
      // Step 2 - Check the customer change list with the GRD server //
      /////////////////////////////////////////////////////////////////

      //
      // Process when customer changes found
      //
      ArrayList objGlobalKUNNR= new ArrayList();
      if (objKUNNR.size() != 0) {
            
         //
         // Apply the global filters to the vendor list
         //
         try {
            for (int i=0; i<objKUNNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(objSapConnection01);
               try {
                  if (strGlobalKNB1Filter == null) {
                     objSapSingleQuery.execute("KNB1", "KNB1", "KUNNR", (String[])objKUNNR.get(i),0,0);
                  } else {
                     objSapSingleQuery.execute("KNB1", "KNB1", "KUNNR", cSapUtility.concatenateArray((String[])objKUNNR.get(i), new String[]{"AND (" + strGlobalKNB1Filter + ")"}),0,0);
                  }
                  objGlobalKUNNR = objSapSingleQuery.getResultSet().getMergedArray(objGlobalKUNNR, "KNB1", "KUNNR");
               } catch(Exception objException) {
                  throw new Exception("SAPVDS03 - Global KNB1 query failed - " + objException.getMessage());
               }
               try {
                  if (strGlobalKNVVFilter == null) {
                     objSapSingleQuery.execute("KNVV", "KNVV", "KUNNR", (String[])objKUNNR.get(i),0,0);
                  } else {
                     objSapSingleQuery.execute("KNVV", "KNVV", "KUNNR", cSapUtility.concatenateArray((String[])objKUNNR.get(i), new String[]{"AND (" + strGlobalKNVVFilter + ")"}),0,0);
                  }
                  objGlobalKUNNR = objSapSingleQuery.getResultSet().getMergedArray(objGlobalKUNNR, "KNVV", "KUNNR");
               } catch(Exception objException) {
                  throw new Exception("SAPVDS03 - Global KNVV query failed - " + objException.getMessage());
               }
            }
         } catch(Exception objException) {
            throw objException;
         } finally {
            objSapSingleResultSet = null;
            objSapSingleQuery = null;
         }

         //
         // Perform logging when required
         //
         if (strLogging.equals("1")) {
            System.out.println("Global filter list count: " + objGlobalKUNNR.size());
            System.out.println("End global filter retrieval: " + Calendar.getInstance().getTime());
         }
         
         //
         // Reset the customer array from the global data
         //
         objKUNNR = cSapUtility.getOrConditionsArray(objGlobalKUNNR,"KUNNR = '<KEYVALUE></KEYVALUE>'",1000);
         
      }
          
      //////////////////////////////////////////////////////////////////////////
      // Step 3 - Retrieve the customer interface data from the source server //
      //////////////////////////////////////////////////////////////////////////
      
      //
      // Retrieve the SAP query when required
      //
      if (objKUNNR.size() != 0) {
         if (strLogging.equals("1")) {
            System.out.println("Start Global data retrieval: " + Calendar.getInstance().getTime());
         }
         try {
            for (int i=0; i<objKUNNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(objSapConnection01);
               strTable = "KNA1";
               objSapSingleQuery.execute("KNA1", "KNA1", strVdsKNA1Columns, (String[])objKUNNR.get(i),0,0);
               strTable = "KNB1";
               objSapSingleQuery.execute("KNB1", "KNB1", strVdsKNB1Columns, objSapSingleQuery.getResultSet().getOrConditions("KNA1","KUNNR = '<KEYVALUE>KUNNR</KEYVALUE>'"),0,0);
               strTable = "KNVI";
               objSapSingleQuery.execute("KNVI", "KNVI", strVdsKNVIColumns, objSapSingleQuery.getResultSet().getOrConditions("KNA1","KUNNR = '<KEYVALUE>KUNNR</KEYVALUE>'"),0,0);
               strTable = "KNVV";
               objSapSingleQuery.execute("KNVV", "KNVV", strVdsKNVVColumns, objSapSingleQuery.getResultSet().getOrConditions("KNA1","KUNNR = '<KEYVALUE>KUNNR</KEYVALUE>'"),0,0);
               objSapSingleResultSet = objSapSingleQuery.getResultSet();
               if (i == 0) {
                  objSapSingleResultSet.getMetaData().toInterface(strOutputFile, strIdoc, strVdsGlobalQuery, bolAppend);
                  bolAppend = true;
                  objSapSingleResultSet.appendToInterface(strOutputFile);
               } else {
                  objSapSingleResultSet.appendToInterface(strOutputFile);
               }
            }
         } catch(Exception objException) {
            throw new Exception("SAPVDS03 - Global data query failed - " + strTable + " - " + objException.getMessage());
         } finally {
            objSapSingleResultSet = null;
            objSapSingleQuery = null;
         }
         if (strLogging.equals("1")) {
            System.out.println("End Global data retrieval: " + Calendar.getInstance().getTime());
         }
      }
         
   }

}