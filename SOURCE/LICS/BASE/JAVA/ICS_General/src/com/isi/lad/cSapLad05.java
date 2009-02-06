/**
 * Package : ISI LADS
 * Type    : Class
 * Name    : cSapLad05
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.lad;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements the SAP to ODS document status functionality. This functionality
 * looks up the SAP table and returns rows that do not exist from a list of supplied values.
 */
public final class cSapLad05 implements iSapInterface {
   
   //
   // Declare the class variable
   //
   cSapConnection cobjSapConnection = null;
   
   /**
    * Processes the SAP to LADS Factory BOM extract.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSapConnection, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Initialise the class variables
      //
      cSapSingleQuery objMASTQuery = null;
      cSapSingleResultSet objMASTResultSet = null;
      cSapSingleQuery objSTKOQuery = null;
      cSapSingleResultSet objSTKOResultSet = null;
      cSapSingleQuery objSTASQuery = null;
      cSapSingleResultSet objSTASResultSet = null;
      cSapSingleQuery objSTPOQuery = null;
      cSapSingleResultSet objSTPOResultSet = null;
      int intGroup = 1000;
      ArrayList objSTLNR = null;
      String strLogging = null;
      String strIdoc = "SAPLAD05";
      cobjSapConnection = objSapConnection;
      
      ///////////////////
      // Start extract //
      ///////////////////
      
      //
      // Retrieve any interface specific parameters
      //
      String strMASTFilters = (String)objParameters.get("MASTFILTERS");
      if (strMASTFilters == null) {
         strMASTFilters = "*NONE";
      }
      strLogging = (String)objParameters.get("LOGGING");
      
      //
      // Start the logging when required
      //
      if (strLogging.equals("1")) {
         System.out.println("Start SAPLAD05 Factory BOM retrieval: " + Calendar.getInstance().getTime());
      }
      
      ///////////////////////////////////////////////
      // Step 1 - Retrieve the SAP MAST table rows //
      ///////////////////////////////////////////////
         
      //
      // Perform the SAP MAST table retrieval
      //
      if (strLogging.equals("1")) {
         System.out.println("Start MAST retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         objMASTQuery = new cSapSingleQuery(cobjSapConnection);
         objMASTQuery.execute("MAST", "MAST", "STLNR,STLAL,MATNR,WERKS,STLAN", new String[]{strMASTFilters}, 0, 0);
         objMASTResultSet = objMASTQuery.getResultSet();
         objMASTResultSet.toInterface(strOutputFile, strIdoc, "MAST", false);
         if (strLogging.equals("1")) {
               System.out.println("MAST rows (" + objMASTResultSet.getRowCount() + ") retrieved and output: " + Calendar.getInstance().getTime());
            }
         objSTLNR = getMASTConditions(objMASTResultSet,intGroup);
         if (strLogging.equals("1")) {
            System.out.println("MAST rows (" + objMASTResultSet.getRowCount() + ") filtered: " + Calendar.getInstance().getTime());
         }
      } catch(Exception objException) {
         throw new Exception("SAPLAD05 - MAST retrieval failed - " + objException.getMessage());
      } finally {
         objMASTResultSet = null;
         objMASTQuery = null;
      }
      if (strLogging.equals("1")) {
         System.out.println("End MAST retrieval: " + Calendar.getInstance().getTime());
      }
      
      ///////////////////////////////////////////////
      // Step 2 - Retrieve the SAP STKO table rows //
      ///////////////////////////////////////////////
         
      //
      // Perform the SAP STKO table retrieval
      //
      if (strLogging.equals("1")) {
         System.out.println("Start STKO retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         for (int i=0; i<objSTLNR.size(); i++) {
            objSTKOQuery = new cSapSingleQuery(cobjSapConnection);
            objSTKOQuery.execute("STKO", "STKO", "STLNR,STLAL,DATUV,BMENG,BMEIN,STLST", (String[])objSTLNR.get(i), 0, 0);
            objSTKOResultSet = objSTKOQuery.getResultSet();
            objSTKOResultSet.appendToInterface(strOutputFile);
            if (strLogging.equals("1")) {
               System.out.println("==> STKO retrieval group (" + (i+1) + ") rows (" + objSTKOResultSet.getRowCount() + ") retrieved and output: " + Calendar.getInstance().getTime());
            }
         }
      } catch(Exception objException) {
         throw new Exception("SAPLAD05 - STKO retrieval failed - " + objException.getMessage());
      } finally {
         objSTKOResultSet = null;
         objSTKOQuery = null;
      }
      if (strLogging.equals("1")) {
         System.out.println("End STKO retrieval: " + Calendar.getInstance().getTime());
      }
      
      ///////////////////////////////////////////////
      // Step 3 - Retrieve the SAP STAS table rows //
      ///////////////////////////////////////////////
         
      //
      // Perform the SAP STAS table retrieval
      //
      if (strLogging.equals("1")) {
         System.out.println("Start STAS retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         for (int i=0; i<objSTLNR.size(); i++) {
            objSTASQuery = new cSapSingleQuery(cobjSapConnection);
            objSTASQuery.execute("STAS", "STAS", "STLNR,STLAL,STLKN", (String[])objSTLNR.get(i), 0, 0);
            objSTASResultSet = objSTASQuery.getResultSet();
            objSTASResultSet.appendToInterface(strOutputFile);
            if (strLogging.equals("1")) {
               System.out.println("==> STAS retrieval group (" + (i+1) + ") rows (" + objSTASResultSet.getRowCount() + ") retrieved and output: " + Calendar.getInstance().getTime());
            }
         }
      } catch(Exception objException) {
         throw new Exception("SAPLAD05 - STAS retrieval failed - " + objException.getMessage());
      } finally {
         objSTASResultSet = null;
         objSTASQuery = null;
      }
      if (strLogging.equals("1")) {
         System.out.println("End STAS retrieval: " + Calendar.getInstance().getTime());
      }
      
      ///////////////////////////////////////////////
      // Step 4 - Retrieve the SAP STPO table rows //
      ///////////////////////////////////////////////
         
      //
      // Perform the SAP STPO table retrieval
      //
      if (strLogging.equals("1")) {
         System.out.println("Start STPO retrieval: " + Calendar.getInstance().getTime());
      }
      try {
         for (int i=0; i<objSTLNR.size(); i++) {
            objSTPOQuery = new cSapSingleQuery(cobjSapConnection);
            objSTPOQuery.execute("STPO", "STPO", "STLNR,STLKN,POSNR,POSTP,IDNRK,MENGE,MEINS,DATUV", (String[])objSTLNR.get(i), 0, 0);
            objSTPOResultSet = objSTPOQuery.getResultSet();
            objSTPOResultSet.appendToInterface(strOutputFile);
            if (strLogging.equals("1")) {
               System.out.println("==> STPO retrieval group (" + (i+1) + ") rows (" + objSTPOResultSet.getRowCount() + ") retrieved and output: " + Calendar.getInstance().getTime());
            }
         }
      } catch(Exception objException) {
         throw new Exception("SAPLAD05 - STPO retrieval failed - " + objException.getMessage());
      } finally {
         objSTPOResultSet = null;
         objSTPOQuery = null;
      }
      if (strLogging.equals("1")) {
         System.out.println("End STPO retrieval: " + Calendar.getInstance().getTime());
      }
      
      /////////////////
      // End extract //
      /////////////////
      
      //
      // End the logging when required
      //
      if (strLogging.equals("1")) {
         System.out.println("End SAPLAD05 Factory BOM retrieval: " + Calendar.getInstance().getTime());
      }
      
   }
   
   /**
    * Retrieves the MAST condition statements
    * @param objMASTResultSet the MAST table result set
    * @param intGroup the result grouping
    * @return ArrayList the condition array
    * @throws Exception the exception message
    */
   public ArrayList getMASTConditions(cSapSingleResultSet objMASTResultSet, int intGroup) throws Exception {
      
      //
      // Remove duplicates from the source
      //
      String[] strMAST = new String[objMASTResultSet.getRowCount()];
      for (int i=0; i<objMASTResultSet.getRowCount(); i++) {
         strMAST[i] = objMASTResultSet.getFieldValue(i,"STLNR");
      }
      Arrays.sort(strMAST);
      ArrayList objMAST = new ArrayList();
      String strSAVE = "**START**";
      for (int i=0; i<strMAST.length; i++) {
         if (!strMAST[i].equals(strSAVE)) {
            strSAVE = strMAST[i];
            objMAST.add(strMAST[i]);
         }
      }

      //
      // Load the keys array
      //
      ArrayList objKeys = new ArrayList();
      String[] strKeys = null;
      int intTotal = objMAST.size();
      int intCount = intGroup - 1;
      for (int i=0; i<objMAST.size(); i++) {
         if ((intCount + 1) == intGroup) {
            if (((intTotal-i)-intGroup) > 0) {
               strKeys = new String[intGroup];
            } else {
               strKeys = new String[(intTotal-i)];
            }
            objKeys.add(strKeys);
            intCount = 0;
         } else {
            intCount++;
         }
         if (intCount == 0) {
            strKeys[intCount] = "(STLNR = '" + ((String)objMAST.get(i)).trim() + "'";
         } else {
            strKeys[intCount] = "OR STLNR = '" + ((String)objMAST.get(i)).trim() + "'";
            if (intCount == (strKeys.length-1)) {
               strKeys[intCount] = strKeys[intCount] + ")";
            }
         }
      }
      strKeys = null;
      
      //
      // Return the condition array
      //
      return objKeys;
      
   }
   
   
}