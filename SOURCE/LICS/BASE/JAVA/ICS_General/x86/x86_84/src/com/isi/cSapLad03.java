/**
 * Package : ISI LAD
 * Type    : Class
 * Name    : cSapLad03
 * Author  : Steve Gregan
 * Date    : June 2005
 */
package com.isi.lad;
import com.isi.sap.*;
import java.util.*;

/**
 * This class implements the SAP Customer Hierarchy functionality. This functionality retrieves
 * SAP customer hierarchy information from the SAP KNVH table.
 */
public final class cSapLad03 implements iSapInterface {
   
   /**
    * Retrieves the selected SAP customer hierarchy and loads into Oracle. This method connects
    * to the requested SAP database and retrieves the selected customer hierarchy data.
    * @throws Exception the exception message
    */
   public void process(cSapConnection objSAPConnection, HashMap objParameters, String strOutputFile) throws Exception {
      
      //
      // Retrieve any interface specific interface parameters
      //
      String strSapWhere = (String)objParameters.get("SAPWHERE");
      if (strSapWhere == null) {
         throw new Exception("SAPLAD03 - SAP where clause not supplied");
      }

      //
      // Process the interface request
      //
      cSapQuery objSapQuery = null;
      cSapExecution objKNVHExecution = null;
      cSapResultSet objSapResultSet = null;
      try {
         objSapQuery = new cSapQuery(objSAPConnection);
         objKNVHExecution = objSapQuery.setPrimaryExecution("KNVH", "KNVH", "*", new String[]{strSapWhere});
         objSapResultSet = objSapQuery.execute();
         objSapResultSet.toInterface(strOutputFile, "SAPLAD03", false, false);
      } catch(Exception objException) {
         throw new Exception("SAPLAD03 - SAP query failed - " + objException.getMessage());
      } finally {
         objSapResultSet = null;
         objKNVHExecution = null;
         objSapQuery = null;
      }
      
   }

}