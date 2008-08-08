/**
 * Package : ISI LAD
 * Type    : Class
 * Name    : cSapLad02
 * Author  : Steve Gregan
 * Date    : June 2005
 */
package com.isi.lad;
import com.isi.sap.*;
import java.util.*;
import java.io.*;

/**
 * This class implements a SAP interface.
 */
public final class cSapLad02 implements iSapInterface {
   
   /**
    * Retrieves the selected SAP table and loads into Oracle. This method connects
    * to the requested SAP database and retrieves the selected table data. A connection is
    * then made to the requested Oracle database and the table data is inserted.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSAPConnection, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Retrieve any interface specific interface parameters
      //
      String strSapTables = (String)objParameters.get("SAPTABLES");
      if (strSapTables == null) {
         throw new Exception("SAPLAD02 - SAP tables not supplied");
      }
      String[] strTableNames = strSapTables.split(",");
      String strSapFilters = (String)objParameters.get("SAPFILTERS");
      if (strSapFilters == null) {
         throw new Exception("SAPLAD02 - SAP filters not supplied");
      }
      String[] strTableFilters = strSapFilters.split(",");
      String strRetrievalMode = (String)objParameters.get("RETRIEVALMODE");
      if (strRetrievalMode == null) {
         strRetrievalMode = "*ALL";
      }
      strRetrievalMode = strRetrievalMode.toUpperCase();
      if (!strRetrievalMode.equals("*ALL") && !strRetrievalMode.equals("*BATCH")) {
         throw new Exception("SAPLAD02 - Retrieval mode must be *ALL or *BATCH");
      }
      
      //
      // Process the interface request
      //
      cSapSingleQuery objSapSingleQuery = null;
      cSapSingleResultSet objSapSingleResultSet = null;
      boolean bolAppend = false;
      try {
         for (int i=0; i<strTableNames.length; i++) {
            if (strRetrievalMode.equals("*BATCH")) {
               boolean bolData = false;
               int intRowSkips = 0;
               int intRowCount = 10000;
               boolean bolRead = true;
               while (bolRead) {
                  objSapSingleQuery = new cSapSingleQuery(objSAPConnection);
                  objSapSingleQuery.execute(strTableNames[i].toUpperCase(), strTableNames[i].toUpperCase(), "*", new String[]{strTableFilters[i]}, intRowSkips, intRowCount);
                  objSapSingleResultSet = objSapSingleQuery.getResultSet();
                  if (!bolData) {
                     objSapSingleResultSet.toInterfaceMeta(strOutputFile, "SAPLAD02", strTableNames[i].toUpperCase(), bolAppend);
                     bolAppend = true;
                     bolData = true;
                  } else {
                     objSapSingleResultSet.appendToInterface(strOutputFile);
                  }
                  if (objSapSingleResultSet.getRowCount() < intRowCount) {
                     bolRead = false;
                  } else {
                     intRowSkips = intRowSkips + intRowCount;
                  }
               }
            } else {
               objSapSingleQuery = new cSapSingleQuery(objSAPConnection);
               objSapSingleQuery.execute(strTableNames[i].toUpperCase(), strTableNames[i].toUpperCase(), "*", new String[]{strTableFilters[i]}, 0, 0);
               objSapSingleResultSet = objSapSingleQuery.getResultSet();
               objSapSingleResultSet.toInterfaceMeta(strOutputFile, "SAPLAD02", strTableNames[i].toUpperCase(), bolAppend);
            }
            bolAppend = true;
         }
      } catch(Exception objException) {
         throw new Exception("SAPLAD02 - SAP query failed - " + objException.getMessage());
      } finally {
         objSapSingleResultSet = null;
         objSapSingleQuery = null;
      }
      
   }

}