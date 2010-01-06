/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : cSapVds04
 * Author  : Steve Gregan
 * Date    : August 2009
 */
package com.isi.vds;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements the SAP vendor change functionality. This functionality retrieves
 * SAP vendor data based on changes to SAP table LFA1 within the specified data range.
 */
public final class cSapVds04 implements iSapDualInterface {
   
   /**
    * Processes the SAP validation extract.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSapConnection01, cSapConnection objSapConnection02, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Retrieve any interface specific interface parameters
      //
      String strGlobalLFA1DateRange = (String)objParameters.get("GLOBAL_LFA1_DATERANGE");
      String strGlobalLFB1Filter = (String)objParameters.get("GLOBAL_LFB1_FILTER");
      String strGlobalLFM1Filter = (String)objParameters.get("GLOBAL_LFM1_FILTER");
      String strVdsGlobalQuery = (String)objParameters.get("VDS_GLOBAL_QUERY");                
      String strVdsLFA1Columns = (String)objParameters.get("VDS_LFA1_COLUMNS");
      String strVdsLFB1Columns = (String)objParameters.get("VDS_LFB1_COLUMNS");
      String strVdsLFBKColumns = (String)objParameters.get("VDS_LFBK_COLUMNS");
      String strVdsLFM1Columns = (String)objParameters.get("VDS_LFM1_COLUMNS");
      String strVdsLFM2Columns = (String)objParameters.get("VDS_LFM2_COLUMNS");
      String strVdsWYT3Columns = (String)objParameters.get("VDS_WYT3_COLUMNS");
      String strLogging = (String)objParameters.get("LOGGING");
      if (strVdsGlobalQuery == null || strVdsGlobalQuery.toUpperCase().equals("*NONE")) {
         throw new Exception("SAPVDS04 - Global validation query must be supplied");
      }
      if (strGlobalLFA1DateRange == null) {
         throw new Exception("SAPVDS04 - Global LFA1 date range must be supplied");
      }
      if (strVdsLFA1Columns == null) {
         strVdsLFA1Columns = "*";
      }
      if (strVdsLFB1Columns == null) {
         strVdsLFB1Columns = "*";
      }
      if (strVdsLFBKColumns == null) {
         strVdsLFBKColumns = "*";
      }
      if (strVdsLFM1Columns == null) {
         strVdsLFM1Columns = "*";
      }
      if (strVdsLFM2Columns == null) {
         strVdsLFM2Columns = "*";
      }
      if (strVdsWYT3Columns == null) {
         strVdsWYT3Columns = "*";
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
      String strIdoc = "SAPVDS04";
      String strTable = null;
      
      //
      // Retrieve the date range from the parameter value
      //
      GregorianCalendar objCalendar = new GregorianCalendar();
      int intRoll = 0;
      try {
         intRoll = Integer.parseInt(strGlobalLFA1DateRange.substring(5,strGlobalLFA1DateRange.length()));
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
      strGlobalLFA1DateRange = strYear + strMonth + strDay;
      if (strLogging.equals("1")) {
         System.out.println("Global LFA1 date range: " + strGlobalLFA1DateRange);
      }

      //
      // Instance the loal references
      //
      cSapSingleQuery objSapSingleQuery = null;
      cSapSingleResultSet objSapSingleResultSet = null;
      boolean bolAppend = false;
      
      /////////////////////////////////////////////////////////////////////
      // Step 1 - Retrieve the vendor change list from the source server //
      /////////////////////////////////////////////////////////////////////
      
      //
      // Perform logging when required
      //
      if (strLogging.equals("1")) {
         System.out.println("Start Global change list retrieval: " + Calendar.getInstance().getTime());
      }
      
      //
      // Retrieve the list of LFA1 changes for the data range
      //
      ArrayList objLIFNR = null;
      String[] strFilter = null;
      strFilter = new String[]{"ERDAT >= '" + strGlobalLFA1DateRange + "'"};
      try {
         objSapSingleQuery = new cSapSingleQuery(objSapConnection01);
         objSapSingleQuery.execute("LFA1", "LFA1", "LIFNR", strFilter,0,0);
         objLIFNR = objSapSingleQuery.getResultSet().getOrConditionsArray("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'",1000);
         if (strLogging.equals("1")) {
            System.out.println("Global change list count: " + objSapSingleQuery.getResultSet().getRowCount("LFA1"));
         }
      } catch(Exception objException) {
         throw new Exception("SAPVDS04 - Global LFA1 query failed - " + objException.getMessage());
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
      
      ///////////////////////////////////////////////////////////////
      // Step 2 - Check the vendor change list with the GRD server //
      ///////////////////////////////////////////////////////////////

      //
      // Process when vendor changes found
      //
      ArrayList objGlobalLIFNR= new ArrayList();
      if (objLIFNR.size() != 0) {
            
         //
         // Apply the global filters to the vendor list
         //
         try {
            for (int i=0; i<objLIFNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(objSapConnection01);
               try {
                  if (strGlobalLFB1Filter == null) {
                     objSapSingleQuery.execute("LFB1", "LFB1", "LIFNR", (String[])objLIFNR.get(i),0,0);
                  } else {
                     objSapSingleQuery.execute("LFB1", "LFB1", "LIFNR", cSapUtility.concatenateArray((String[])objLIFNR.get(i), new String[]{"AND (" + strGlobalLFB1Filter + ")"}),0,0);
                  }
                  objGlobalLIFNR = objSapSingleQuery.getResultSet().getMergedArray(objGlobalLIFNR, "LFB1", "LIFNR");
               } catch(Exception objException) {
                  throw new Exception("SAPVDS04 - Global LFB1 query failed - " + objException.getMessage());
               }
               try {
                  if (strGlobalLFM1Filter == null) {
                     objSapSingleQuery.execute("LFM1", "LFM1", "LIFNR", (String[])objLIFNR.get(i),0,0);
                  } else {
                     objSapSingleQuery.execute("LFM1", "LFM1", "LIFNR", cSapUtility.concatenateArray((String[])objLIFNR.get(i), new String[]{"AND (" + strGlobalLFM1Filter + ")"}),0,0);
                  }
                  objGlobalLIFNR = objSapSingleQuery.getResultSet().getMergedArray(objGlobalLIFNR, "LFM1", "LIFNR");
               } catch(Exception objException) {
                  throw new Exception("SAPVDS04 - Global LFM1 query failed - " + objException.getMessage());
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
            System.out.println("Global filter list count: " + objGlobalLIFNR.size());
            System.out.println("End global filter retrieval: " + Calendar.getInstance().getTime());
         }
         
         //
         // Reset the vendor array from the global data
         //
         objLIFNR = cSapUtility.getOrConditionsArray(objGlobalLIFNR,"LIFNR = '<KEYVALUE></KEYVALUE>'",1000);
         
      }
          
      ////////////////////////////////////////////////////////////////////////
      // Step 3 - Retrieve the vendor interface data from the source server //
      ////////////////////////////////////////////////////////////////////////
      
      //
      // Retrieve the SAP query when required
      //
      if (objLIFNR.size() != 0) {
         if (strLogging.equals("1")) {
            System.out.println("Start Global data retrieval: " + Calendar.getInstance().getTime());
         }
         try {
            for (int i=0; i<objLIFNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(objSapConnection01);
               strTable = "LFA1";
               objSapSingleQuery.execute("LFA1", "LFA1", strVdsLFA1Columns, (String[])objLIFNR.get(i),0,0);
               strTable = "LFB1";
               objSapSingleQuery.execute("LFB1", "LFB1", strVdsLFB1Columns, objSapSingleQuery.getResultSet().getOrConditions("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'"),0,0);
               strTable = "LFBK";
               objSapSingleQuery.execute("LFBK", "LFBK", strVdsLFBKColumns, objSapSingleQuery.getResultSet().getOrConditions("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'"),0,0);
               strTable = "LFM1";
               objSapSingleQuery.execute("LFM1", "LFM1", strVdsLFM1Columns, objSapSingleQuery.getResultSet().getOrConditions("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'"),0,0);
               strTable = "LFM2";
               objSapSingleQuery.execute("LFM2", "LFM2", strVdsLFM2Columns, objSapSingleQuery.getResultSet().getOrConditions("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'"),0,0);
               strTable = "WYT3";
               objSapSingleQuery.execute("WYT3", "WYT3", strVdsWYT3Columns, objSapSingleQuery.getResultSet().getOrConditions("LFA1","LIFNR = '<KEYVALUE>LIFNR</KEYVALUE>'"),0,0);
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
            throw new Exception("SAPVDS04 - Global data query failed - " + strTable + " - " + objException.getMessage());
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