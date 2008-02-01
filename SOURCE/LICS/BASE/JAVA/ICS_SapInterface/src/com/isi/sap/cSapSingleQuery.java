/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cSapSingleQuery
 * Author  : Steve Gregan
 * Date    : February 2007
 */
package com.isi.sap;
import java.util.*;
import com.sap.mw.jco.*;

/**
 * This class implements a SAP single database query.
 */
public final class cSapSingleQuery {

   //
   // Class variables
   //
   private cSapConnection cobjSapConnection;
   private cSapSingleResultSet cobjSapSingleResultSet;
   
   /**
    * Class constructor
    * @param objSapConnection the SAP connection reference
    * @throws Exception the exception message
    */
   public cSapSingleQuery(cSapConnection objSapConnection) throws Exception { 
      cobjSapConnection = objSapConnection;
      cobjSapSingleResultSet = new cSapSingleResultSet();
   }
   
   /**
    * Gets the result set reference
    * @return cSapSingleResultSet the result set reference
    */
   public cSapSingleResultSet getResultSet() {
      return cobjSapSingleResultSet;
   }
   
   /**
    * Executes the query execution statement
    * @param strNode the query node
    * @param strTable the table name to query
    * @param strFields the field names to query (* = all)
    * @param strConditions the array of condition clauses for the query
    * @param intRowSkips the number of rows to skip
    * @param intRowCount the number of rows to include
    * @throws Exception the exception message
    */
   public void execute(String strNode, String strTable, String strFields, String[] strConditions, int intRowSkips, int intRowCount) throws Exception {
      
      //
      // Validate the parameters
      //
      if (strNode.length() > 30) {
         throw new Exception("SAP SINGLE QUERY - Node " + strNode + " name exceeds maximum length of 30");
      }
      
      //
      // Instance the function and set the parameters
      //
      JCO.Function objFunction = cobjSapConnection.getFunction();
      JCO.ParameterList objImportList = objFunction.getImportParameterList();
      objImportList.setValue(strTable,"QUERY_TABLE");
      objImportList.setValue(" ","NO_DATA");
      objImportList.setValue(intRowSkips,"ROWSKIPS");
      objImportList.setValue(intRowCount,"ROWCOUNT");
      
      //
      // Build and load the fields when requested
      //
      JCO.Table objFields = objFunction.getTableParameterList().getTable("FIELDS");
      if (!strFields.trim().equals("") && !strFields.trim().equals("*")) {
         StringTokenizer objTokenizer = new StringTokenizer(strFields.trim(),",");
         while (objTokenizer.hasMoreTokens()) {
            objFields.appendRow();
            objFields.setValue(objTokenizer.nextToken().toUpperCase().trim(),"FIELDNAME");
         }
      }
      objFields = null;
      
      //
      // Build and load the conditions when requested
      //
      JCO.Table objOptions = objFunction.getTableParameterList().getTable("OPTIONS");
      for (int i=0;i<strConditions.length;i++) {
         if (!strConditions[i].trim().equals("")) {
            objOptions.appendRow();
            objOptions.setValue(strConditions[i].trim(),"TEXT");
         }
      }
      objOptions = null;
      
      //
      // Execute the function
      //
      cobjSapConnection.execute(objFunction);
      
      //
      // Retrieve and load the result set meta data node columns
      // **note ** meta data is only stored once for a node
      //
      if (cobjSapSingleResultSet.getMetaData().addNode(strNode.toUpperCase())) {
         JCO.Table objMetaData = objFunction.getTableParameterList().getTable("FIELDS");
         for (int i=0;i<objMetaData.getNumRows();i++) {
            objMetaData.setRow(i);
            cobjSapSingleResultSet.getMetaData().addColumn(strNode.toUpperCase(), objMetaData.getField("FIELDNAME").getString(), objMetaData.getField("OFFSET").getInt(), objMetaData.getField("LENGTH").getInt(), objMetaData.getField("TYPE").getString());
         }
      }
      
      //
      // Retrieve and load the result set data rows when required
      //
      JCO.Table objData = objFunction.getTableParameterList().getTable("DATA");
      for (int i=0;i<objData.getNumRows();i++) {
         objData.setRow(i);
         cobjSapSingleResultSet.addRow(strNode.toUpperCase(), objData.getField(0).getString());
      }
      objData = null;
  
   }
   
   /**
    * Executes the query execution statement
    * @param strNode the query node
    * @param strTable the table name to query
    * @param strField the field name to query
    * @param strConditions the array of condition clauses for the query
    * @param strExclusionValues the array of key exlusion values
    * @throws Exception the exception message
    */
   public void execute(String strNode, String strTable, String strField, String[] strConditions, String[] strExclusionValues) throws Exception {
      
      //
      // Validate the parameters
      //
      if (strNode.length() > 30) {
         throw new Exception("SAP SINGLE QUERY - Node " + strNode + " name exceeds maximum length of 30");
      }
      if (strField.trim().equals("")) {
         throw new Exception("SAP SINGLE QUERY - Field must be supplied");
      }
      
      //
      // Instance the function and set the parameters
      //
      JCO.Function objFunction = cobjSapConnection.getFunction();
      JCO.ParameterList objImportList = objFunction.getImportParameterList();
      objImportList.setValue(strTable,"QUERY_TABLE");
      objImportList.setValue(" ","NO_DATA");
      objImportList.setValue(0,"ROWSKIPS");
      objImportList.setValue(0,"ROWCOUNT");
      
      //
      // Build and load the fields
      //
      JCO.Table objFields = objFunction.getTableParameterList().getTable("FIELDS");
      objFields.appendRow();
      objFields.setValue(strField.toUpperCase().trim(),"FIELDNAME");
      objFields = null;
      
      //
      // Build and load the conditions when requested
      //
      JCO.Table objOptions = objFunction.getTableParameterList().getTable("OPTIONS");
      for (int i=0;i<strConditions.length;i++) {
         if (!strConditions[i].trim().equals("")) {
            objOptions.appendRow();
            objOptions.setValue(strConditions[i].trim(),"TEXT");
         }
      }
      objOptions = null;
      
      //
      // Execute the function
      //
      cobjSapConnection.execute(objFunction);
      
      //
      // Retrieve and load the result set meta data node columns
      // **note ** meta data is only stored once for a node
      //
      if (cobjSapSingleResultSet.getMetaData().addNode(strNode.toUpperCase())) {
         JCO.Table objMetaData = objFunction.getTableParameterList().getTable("FIELDS");
         for (int i=0;i<objMetaData.getNumRows();i++) {
            objMetaData.setRow(i);
            cobjSapSingleResultSet.getMetaData().addColumn(strNode.toUpperCase(), objMetaData.getField("FIELDNAME").getString(), objMetaData.getField("OFFSET").getInt(), objMetaData.getField("LENGTH").getInt(), objMetaData.getField("TYPE").getString());
         }
      }
       
      //
      // Retrieve and load the result set data rows when required
      //
      Arrays.sort(strExclusionValues);
      int[] intWork = new int[strExclusionValues.length];
      int intWidx = 0;
      JCO.Table objData = objFunction.getTableParameterList().getTable("DATA");
      for (int i=0;i<objData.getNumRows();i++) {
         objData.setRow(i);
         intWidx = Arrays.binarySearch(strExclusionValues, objData.getField(0).getString().trim());
         if (intWidx >= 0) {
            intWork[intWidx] = 1;
         }
      }
      
      //
      // Load the result set data rows for missing exclusion values
      //
      for (int i=0;i<intWork.length;i++) {
         if (intWork[i] != 1) {
            cobjSapSingleResultSet.addRow(strNode.toUpperCase(), strExclusionValues[i]);
         }
      }
  
   }
   
}