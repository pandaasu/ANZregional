/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : cSapVds01
 * Author  : Steve Gregan
 * Date    : January 2007
 */
package com.isi.vds;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements the VDS reference data retrieval functionality. This functionality retrieves
 * SAP reference data based on the configuration file.
 */
public final class cSapVds01 implements iSapDualInterface {
   
   /**
    * Processes the SAP validation extract.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSapConnection01, cSapConnection objSapConnection02, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Retrieve any interface specific parameters
      //
      String strVdsQuery = (String)objParameters.get("VDS_QUERY");
      String strVdsTables = (String)objParameters.get("VDS_TABLES");
      String strLogging = (String)objParameters.get("LOGGING");
      if (strVdsQuery == null) {
         throw new Exception("SAPVDS01 - VDS query must be supplied");
      }
      if (strVdsTables == null) {
         throw new Exception("SAPVDS01 - VDS tables must be supplied");
      }
      String[] strTableNames = strVdsTables.split(",");
      if (strLogging == null) {
         strLogging = "0";   
      }
      
      //
      // Pad the validation system and object to the maximum
      //
      char[] chrSpaces = new char[1024];
      Arrays.fill(chrSpaces, ' ');
      String strSpaces = String.valueOf(chrSpaces);
      strVdsQuery = strVdsQuery + strSpaces.substring(0,30-strVdsQuery.length());
      String strIdoc = "SAPVDS01";

      //
      // Instance the loal references
      //
      cSapSingleQuery objSapSingleQuery = null;
      cSapSingleResultSet objSapSingleResultSet = null;
      
      /////////////////////////////////////////////////////////////////
      // Step 1 - Retrieve the reference data from the source server //
      /////////////////////////////////////////////////////////////////
      
      //
      // Perform logging when required
      //
      if (strLogging.equals("1")) {
         System.out.println("Start SAP reference data retrieval: " + Calendar.getInstance().getTime());
      }
      
      //
      // Retrieve the reference data
      //   
      try {
         objSapSingleQuery = new cSapSingleQuery(objSapConnection01);
         for (int i=0; i<strTableNames.length; i++) {
            objSapSingleQuery.execute(strTableNames[i].toUpperCase(), strTableNames[i].toUpperCase(), "*", new String[0],0,0);
         }
         objSapSingleResultSet = objSapSingleQuery.getResultSet();
         objSapSingleResultSet.getMetaData().toInterface(strOutputFile, strIdoc, strVdsQuery, false);
         objSapSingleResultSet.toInterface(strOutputFile, strIdoc, strVdsQuery, true);
      } catch(Exception objException) {
         throw new Exception("SAPVDS01 - SAP query failed - " + objException.getMessage());
      } finally {
         objSapSingleResultSet = null;
         objSapSingleQuery = null;
      }
      
      //
      // Perform logging when required
      //
      if (strLogging.equals("1")) {
         System.out.println("End SAP reference data retrieval: " + Calendar.getInstance().getTime());
      }
      
   }

}