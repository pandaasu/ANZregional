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
      
      //
      // Process the interface request
      //
      cSapQuery objSapQuery = null;
      cSapExecution objExecution = null;
      cSapResultSet objSapResultSet = null;
      boolean bolAppend = false;
      try {
         for (int i=0; i<strTableNames.length; i++) {
            objSapQuery = new cSapQuery(objSAPConnection);
            objExecution = objSapQuery.setPrimaryExecution(strTableNames[i].toUpperCase(), strTableNames[i].toUpperCase(), "*", new String[0]);
            objSapResultSet = objSapQuery.execute();
            objSapResultSet.toInterface(strOutputFile, "SAPLAD02", true, bolAppend);
            bolAppend = true;
         }
      } catch(Exception objException) {
         throw new Exception("SAPLAD02 - SAP query failed - " + objException.getMessage());
      } finally {
         objSapResultSet = null;
         objExecution = null;
         objSapQuery = null;
      }
      
   }

}