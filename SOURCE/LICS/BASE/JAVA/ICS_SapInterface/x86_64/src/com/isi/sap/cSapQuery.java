/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cSapQuery
 * Author  : Steve Gregan
 * Date    : May 2005
 */
package com.isi.sap;
import java.util.*;

/**
 * This class implements a SAP database query.
 */
public final class cSapQuery {

   //
   // Class variables
   //
   private cSapConnection cobjSapConnection;
   private cSapExecution cobjSapExecution;
   private cSapResultSet cobjSapResultSet;
   
   /**
    * Class constructor
    * @param objSapConnection the SAP connection reference
    * @throws Exception the exception message
    */
   public cSapQuery(cSapConnection objSapConnection) throws Exception {
      cobjSapConnection = objSapConnection;
      cobjSapExecution = null;
      cobjSapResultSet = null;
   }
   
   /**
    * Sets the primary execution for the query
    * @param strNode the execution node
    * @param strTable the execution table name
    * @param strFields the field names to query (* = all)
    * @param strConditions the array of condition clauses for the query
    * @throws Exception the exception message
    */
   public cSapExecution setPrimaryExecution(String strNode, String strTable, String strFields, String[] strConditions) throws Exception {
      if (cobjSapExecution != null) {
         throw new Exception("SAP QUERY - Primary execution has already been set");
      }
      cobjSapExecution = new cSapExecution(strNode, strTable, strFields, strConditions);
      return cobjSapExecution;
   }
   
   /**
    * Executes the query
    * @return cSapResultSet the SAP query result set
    * @throws Exception the exception message
    */
   public cSapResultSet execute() throws Exception {
      if (cobjSapExecution == null) {
         throw new Exception("SAP QUERY - Primary execution has not been set");
      }
      cobjSapResultSet = new cSapResultSet(cobjSapExecution.getNode());
      cobjSapExecution.execute(cobjSapConnection, cobjSapResultSet.getMetaData(), cobjSapResultSet.getPrimaryNode(), null);
      return cobjSapResultSet;
   }

}