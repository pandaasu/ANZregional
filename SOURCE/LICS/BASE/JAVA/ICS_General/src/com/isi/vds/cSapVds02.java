/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : cSapVds02
 * Author  : Steve Gregan
 * Date    : January 2007
 */
package com.isi.vds;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements the SAP material change functionality. This functionality retrieves
 * SAP material data based on changes to SAP table MARA within the specified data range.
 */
public final class cSapVds02 implements iSapDualInterface {
   
   /**
    * Processes the SAP validation extract.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSapConnection01, cSapConnection objSapConnection02, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Retrieve any interface specific interface parameters
      //
      if (objSapConnection02 == null) {
         throw new Exception("SAPVDS02 - Timezone connection must be supplied");
      }
      
      //
      // Retrieve any interface specific interface parameters
      //
      String strGlobalMARADateRange = (String)objParameters.get("GLOBAL_MARA_DATERANGE");
      String strGlobalMARAFilter = (String)objParameters.get("GLOBAL_MARA_FILTER");
      String strTimezoneMARCFilter = (String)objParameters.get("TIMEZONE_MARC_FILTER");
      String strTimezoneMVKEFilter = (String)objParameters.get("TIMEZONE_MVKE_FILTER");
      String strVdsGlobalQuery = (String)objParameters.get("VDS_GLOBAL_QUERY");
      String strVdsTimezoneQuery = (String)objParameters.get("VDS_TIMEZONE_QUERY");
      String strVdsMARAColumns = (String)objParameters.get("VDS_MARA_COLUMNS");
      String strVdsMARMColumns = (String)objParameters.get("VDS_MARM_COLUMNS");
      String strVdsMAKTColumns = (String)objParameters.get("VDS_MAKT_COLUMNS");
      String strVdsMARCColumns = (String)objParameters.get("VDS_MARC_COLUMNS");
      String strVdsMVKEColumns = (String)objParameters.get("VDS_MVKE_COLUMNS");
      String strVdsINOBColumns = (String)objParameters.get("VDS_INOB_COLUMNS");
      String strVdsAUSPColumns = (String)objParameters.get("VDS_AUSP_COLUMNS");
      String strLogging = (String)objParameters.get("LOGGING");
      if (strVdsGlobalQuery == null || strVdsGlobalQuery.toUpperCase().equals("*NONE")) {
         throw new Exception("SAPVDS02 - Global validation query must be supplied");
      }
      if (strVdsTimezoneQuery == null) {
         strVdsTimezoneQuery = "*NONE";   
      }
      if (strGlobalMARADateRange == null) {
         throw new Exception("SAPVDS02 - Global MARA date range must be supplied");
      }
      if (strVdsMARAColumns == null) {
         strVdsMARAColumns = "*";
      }
      if (strVdsMARMColumns == null) {
         strVdsMARMColumns = "*";
      }
      if (strVdsMAKTColumns == null) {
         strVdsMAKTColumns = "*";
      }
      if (strVdsMARCColumns == null) {
         strVdsMARCColumns = "*";
      }
       if (strVdsMVKEColumns == null) {
         strVdsMVKEColumns = "*";
      }
      if (strVdsINOBColumns == null) {
         strVdsINOBColumns = "*";
      }
      if (strVdsAUSPColumns == null) {
         strVdsAUSPColumns = "*";
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
      strVdsTimezoneQuery = strVdsTimezoneQuery + strSpaces.substring(0,30-strVdsTimezoneQuery.length());
      String strIdoc = "SAPVDS02";
      
      //
      // Retrieve the date range from the parameter value
      //
      GregorianCalendar objCalendar = new GregorianCalendar();
      int intRoll = 0;
      try {
         intRoll = Integer.parseInt(strGlobalMARADateRange.substring(5,strGlobalMARADateRange.length()));
      } catch(Exception objException) {
         intRoll = 0;
      }
      if (intRoll != 0) {
         objCalendar.roll(Calendar.DAY_OF_YEAR, intRoll);
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
      strGlobalMARADateRange = strYear + strMonth + strDay;
      if (strLogging.equals("1")) {
         System.out.println("Global MARA date range: " + strGlobalMARADateRange);
      }

      //
      // Instance the loal references
      //
      cSapSingleQuery objSapSingleQuery = null;
      cSapSingleResultSet objSapSingleResultSet = null;
      boolean bolAppend = false;
      
      ///////////////////////////////////////////////////////////////////////
      // Step 1 - Retrieve the material change list from the source server //
      ///////////////////////////////////////////////////////////////////////
      
      //
      // Perform logging when required
      //
      if (strLogging.equals("1")) {
         System.out.println("Start Global change list retrieval: " + Calendar.getInstance().getTime());
      }
      
      //
      // Retrieve the list of MARA changes for the data range
      //
      ArrayList objMATNR = null;
      String[] strFilter = null;
      if (strGlobalMARAFilter == null) {
         strFilter = new String[]{"LAEDA >= '" + strGlobalMARADateRange + "'"};
      } else {
         strFilter = new String[]{"LAEDA >= '" + strGlobalMARADateRange + "'","AND (" + strGlobalMARAFilter + ")"};
      }
      try {
         objSapSingleQuery = new cSapSingleQuery(objSapConnection01);
         objSapSingleQuery.execute("MARA", "MARA", "MATNR", strFilter,0,0);
         objMATNR = objSapSingleQuery.getResultSet().getOrConditionsArray("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'",100);
         if (strLogging.equals("1")) {
            System.out.println("Global change list count: " + objSapSingleQuery.getResultSet().getRowCount("MARA"));
         }
      } catch(Exception objException) {
         throw new Exception("SAPVDS02 - Global MARA query failed - " + objException.getMessage());
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
      
      //////////////////////////////////////////////////////////////////////
      // Step 2 - Check the material change list with the timezone server //
      //////////////////////////////////////////////////////////////////////

      //
      // Process when material changes found
      //
      ArrayList objTimezoneMATNR = new ArrayList();
      if (objMATNR.size() != 0) {
            
         //
         // Apply the timezone filters to the material list
         //
         try {
            for (int i=0; i<objMATNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(objSapConnection02);
               try {
                  if (strTimezoneMARCFilter == null) {
                     objSapSingleQuery.execute("MARC", "MARC", "MATNR, WERKS", (String[])objMATNR.get(i),0,0);
                  } else {
                     objSapSingleQuery.execute("MARC", "MARC", "MATNR, WERKS", cSapUtility.concatenateArray((String[])objMATNR.get(i), new String[]{"AND (" + strTimezoneMARCFilter + ")"}),0,0);
                  }
                  objTimezoneMATNR = objSapSingleQuery.getResultSet().getMergedArray(objTimezoneMATNR, "MARC", "MATNR");
               } catch(Exception objException) {
                  throw new Exception("SAPVDS02 - Timezone MARC query failed - " + objException.getMessage());
               }
               try {
                  if (strTimezoneMVKEFilter == null) {
                     objSapSingleQuery.execute("MVKE", "MVKE", "MATNR, VKORG", (String[])objMATNR.get(i),0,0);
                  } else {
                     objSapSingleQuery.execute("MVKE", "MVKE", "MATNR, VKORG", cSapUtility.concatenateArray((String[])objMATNR.get(i), new String[]{"AND (" + strTimezoneMVKEFilter + ")"}),0,0);
                  }
                  objTimezoneMATNR = objSapSingleQuery.getResultSet().getMergedArray(objTimezoneMATNR, "MVKE", "MATNR");
               } catch(Exception objException) {
                  throw new Exception("SAPVDS02 - Timezone MVKE query failed - " + objException.getMessage());
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
            System.out.println("Timezone filter list count: " + objTimezoneMATNR.size());
            System.out.println("End timezone filter retrieval: " + Calendar.getInstance().getTime());
         }

         //
         // Reset the material array from the timezone data
         //
         objMATNR = cSapUtility.getOrConditionsArray(objTimezoneMATNR,"MATNR = '<KEYVALUE></KEYVALUE>'",100);

         //
         // Retrieve the timezone query when required
         //
         if (!strVdsTimezoneQuery.trim().toUpperCase().equals("*NONE") && objMATNR.size() != 0) {
            if (strLogging.equals("1")) {
               System.out.println("Start timezone data retrieval: " + Calendar.getInstance().getTime());
            }
            try {
               for (int i=0; i<objMATNR.size(); i++) {
                  objSapSingleQuery = new cSapSingleQuery(objSapConnection02);
                  objSapSingleQuery.execute("MARA", "MARA", strVdsMARAColumns, (String[])objMATNR.get(i),0,0);
                  objSapSingleQuery.execute("MARM", "MARM", strVdsMARMColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("MAKT", "MAKT", strVdsMAKTColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("MARC", "MARC", strVdsMARCColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("MVKE", "MVKE", strVdsMVKEColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("INOB", "INOB", strVdsINOBColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","OBJEK = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
                  objSapSingleQuery.execute("AUSP", "AUSP", strVdsAUSPColumns, objSapSingleQuery.getResultSet().getOrConditions("INOB","OBJEK = '<KEYVALUE>CUOBJ</KEYVALUE>'"),0,0);
                  objSapSingleResultSet = objSapSingleQuery.getResultSet();
                  if (i == 0) {
                     objSapSingleResultSet.getMetaData().toInterface(strOutputFile,strIdoc, strVdsTimezoneQuery, bolAppend);
                     bolAppend = true;
                     objSapSingleResultSet.toInterface(strOutputFile, strIdoc, strVdsTimezoneQuery, true);
                  } else {
                     objSapSingleResultSet.appendToInterface(strOutputFile);
                  }
               }
            } catch(Exception objException) {
               throw new Exception("SAPVDS02 - Timezone data query failed - " + objException.getMessage());
            } finally {
               objSapSingleResultSet = null;
               objSapSingleQuery = null;
            }
            if (strLogging.equals("1")) {
               System.out.println("End timezone data retrieval: " + Calendar.getInstance().getTime());
            }
         }
 
      }
      
      //////////////////////////////////////////////////////////////////////////
      // Step 3 - Retrieve the material interface data from the source server //
      //////////////////////////////////////////////////////////////////////////
      
      //
      // Retrieve the SAP query when required
      //
      if (objMATNR.size() != 0) {
         if (strLogging.equals("1")) {
            System.out.println("Start Global data retrieval: " + Calendar.getInstance().getTime());
         }
         try {
            for (int i=0; i<objMATNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(objSapConnection01);
               objSapSingleQuery.execute("MARA", "MARA", strVdsMARAColumns, (String[])objMATNR.get(i),0,0);
               objSapSingleQuery.execute("MARM", "MARM", strVdsMARMColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
               objSapSingleQuery.execute("MAKT", "MAKT", strVdsMAKTColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
               objSapSingleQuery.execute("MARC", "MARC", strVdsMARCColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
               objSapSingleQuery.execute("MVKE", "MVKE", strVdsMVKEColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","MATNR = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
               objSapSingleQuery.execute("INOB", "INOB", strVdsINOBColumns, objSapSingleQuery.getResultSet().getOrConditions("MARA","OBJEK = '<KEYVALUE>MATNR</KEYVALUE>'"),0,0);
               objSapSingleQuery.execute("AUSP", "AUSP", strVdsAUSPColumns, objSapSingleQuery.getResultSet().getOrConditions("INOB","OBJEK = '<KEYVALUE>CUOBJ</KEYVALUE>'"),0,0);
               objSapSingleResultSet = objSapSingleQuery.getResultSet();
               if (i == 0) {
                  objSapSingleResultSet.getMetaData().toInterface(strOutputFile, strIdoc, strVdsGlobalQuery, bolAppend);
                  bolAppend = true;
                  objSapSingleResultSet.toInterface(strOutputFile, strIdoc, strVdsGlobalQuery, true);
               } else {
                  objSapSingleResultSet.appendToInterface(strOutputFile);
               }
            }
         } catch(Exception objException) {
            throw new Exception("SAPVDS02 - Global data query failed - " + objException.getMessage());
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