/**
 * Package : ISI LAD
 * Type    : Class
 * Name    : cSapLad01
 * Author  : Steve Gregan
 * Date    : June 2005
 */
package com.isi.lad;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements the SAP Audit Trail functionality. This functionality retrieves
 * SAP change audit trail information from the SAP cdhdr and cdpos tables. This information
 * can be retrieved for various controls such as SAP object (eg. MATERIAL) and date.
 */
public final class cSapLad01 implements iSapInterface {
   
   /**
    * Retrieves the selected SAP audit trail and loads into Oracle. This method connects
    * to the requested SAP database and retrieves the selected audit trail data. A connection is
    * then made to the requested Oracle database and the audit trail data is inserted.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSAPConnection, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Retrieve any interface specific interface parameters
      //
      String strSapEnvironment = (String)objParameters.get("SAPENVIRONMENT");
      String strSapObject = (String)objParameters.get("SAPOBJECT");
      String strSapDate = (String)objParameters.get("SAPDATE");
      if (strSapEnvironment == null) {
         throw new Exception("SAPLAD01 - SAP environment not supplied");
      }
      if (strSapObject == null) {
         throw new Exception("SAPLAD01 - SAP audit object not supplied");
      }
      if (strSapDate == null) {
         throw new Exception("SAPLAD01 - SAP audit date not supplied");
      }
      if (strSapDate.toUpperCase().equals("TODAY") ||
          strSapDate.toUpperCase().equals("TODAY-1") ||
          strSapDate.toUpperCase().equals("TODAY-2") ||
          strSapDate.toUpperCase().equals("TODAY-3") ||
          strSapDate.toUpperCase().equals("TODAY-4") ||
          strSapDate.toUpperCase().equals("TODAY-5") ||
          strSapDate.toUpperCase().equals("TODAY-6") ||
          strSapDate.toUpperCase().equals("TODAY-7")) {
         GregorianCalendar objCalendar = new GregorianCalendar();
         if (strSapDate.toUpperCase().equals("TODAY-1")) {
            objCalendar.roll(Calendar.DAY_OF_YEAR, -1);
         } else if (strSapDate.toUpperCase().equals("TODAY-2")) {
            objCalendar.roll(Calendar.DAY_OF_YEAR, -2);
         } else if (strSapDate.toUpperCase().equals("TODAY-3")) {
            objCalendar.roll(Calendar.DAY_OF_YEAR, -3);
         } else if (strSapDate.toUpperCase().equals("TODAY-4")) {
            objCalendar.roll(Calendar.DAY_OF_YEAR, -4);
         } else if (strSapDate.toUpperCase().equals("TODAY-5")) {
            objCalendar.roll(Calendar.DAY_OF_YEAR, -5);
         } else if (strSapDate.toUpperCase().equals("TODAY-6")) {
            objCalendar.roll(Calendar.DAY_OF_YEAR, -6);
         } else if (strSapDate.toUpperCase().equals("TODAY-7")) {
            objCalendar.roll(Calendar.DAY_OF_YEAR, -7);
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
         strSapDate = strYear + strMonth + strDay;
      }
      
      //
      // Process the interface request
      //
      cSapQuery objSapQuery = null;
      cSapExecution objCDHDRExecution = null;
      cSapExecution objCDPOSExecution = null;
      cSapResultSet objSapResultSet = null;
      try {
         objSapQuery = new cSapQuery(objSAPConnection);
         objCDHDRExecution = objSapQuery.setPrimaryExecution("CDHDR", "CDHDR", "*", new String[]{"OBJECTCLAS = '" + strSapObject.toUpperCase() + "'"," AND UDATE = '" + strSapDate + "'"});
         objCDPOSExecution = objCDHDRExecution.addExecution("CDPOS", "CDPOS", "*", new String[]{"OBJECTCLAS = '" + strSapObject.toUpperCase() + "'"," AND OBJECTID = '<SAPVALUE>OBJECTID</SAPVALUE>'"," AND CHANGENR = '<SAPVALUE>CHANGENR</SAPVALUE>'"});
         objSapResultSet = objSapQuery.execute();
         objSapResultSet.toInterface(strOutputFile, strSapEnvironment.toUpperCase(), false, false);
      } catch(Exception objException) {
         throw new Exception("SAPLAD01 - SAP query failed - " + objException.getMessage());
      } finally {
         objSapResultSet = null;
         objCDPOSExecution = null;
         objCDHDRExecution = null;
         objSapQuery = null;
      }
      
   }

}