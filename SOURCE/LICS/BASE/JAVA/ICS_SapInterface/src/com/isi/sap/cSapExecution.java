/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cSapExecution
 * Author  : Steve Gregan
 * Date    : May 2005
 */
package com.isi.sap;
import java.util.*;
import com.sap.mw.jco.*;

/**
 * This class implements a SAP database query execution.
 */
public final class cSapExecution {

   //
   // Class variables
   //
   private String cstrNode;
   private String cstrTable;
   private String cstrFields;
   private String[] cstrConditions;
   private ArrayList cobjExecutions;
   private ArrayList cobjFields;
   
   /**
    * Class constructor
    * @param strNode the execution node
    * @param strTable the table name to query
    * @param strFields the field names to query (* = all)
    * @param strConditions the array of condition clauses for the query
    * @throws Exception the exception message
    */
   protected cSapExecution(String strNode, String strTable, String strFields, String[] strConditions) throws Exception {
      if (strNode.length() > 30) {
         throw new Exception("SAP EXECUTION - Node " + strNode + " name exceeds maximum length of 30");
      }
      cstrNode = strNode.toUpperCase();
      cstrTable = strTable;
      cstrFields = strFields;
      cstrConditions = strConditions;
      cobjExecutions = new ArrayList();
      cobjFields = new ArrayList();
      if (!cstrFields.trim().equals("") && !cstrFields.trim().equals("*")) {
         StringTokenizer objTokenizer = new StringTokenizer(cstrFields.trim(),",");
         while (objTokenizer.hasMoreTokens()) {
            cobjFields.add(objTokenizer.nextToken().toUpperCase());
         }
      }
   }
   
   /**
    * Adds a child execution to the execution. Executions should be added in the required execution sequence.
    * @param strNode the execution node
    * @param strTable the table name to query
    * @param strFields the field names to query (* = all)
    * @param strConditions the array of condition clauses for the query
    * @throws Exception the exception message
    */
   public cSapExecution addExecution(String strNode, String strTable, String strFields, String[] strConditions) throws Exception {
      if (strNode.length() > 30) {
         throw new Exception("SAP EXECUTION - Node " + strNode + " name exceeds maximum length of 30");
      }
      for (int i=0;i<cobjExecutions.size();i++) {
         if (((cSapExecution)cobjExecutions.get(i)).getNode().equals(strNode.toUpperCase())) {
            throw new Exception("SAP EXECUTION - Node " + strNode + " already exists in execution stack");
         }
      }
      cSapExecution objSapExecution = new cSapExecution(strNode, strTable, strFields, strConditions);
      cobjExecutions.add(objSapExecution);
      return objSapExecution;
   }
   
   /**
    * Executes the query execution statement
    * @param objSapConnection the SAP connection reference
    * @param objSapResultSetNode the SAP result set node reference
    * @param objParentResultSetRow the parent SAP result set row
    * @throws Exception the exception message
    */
   public void execute(cSapConnection objSapConnection,
                       cSapResultSetMetaData objSapResultSetMetaData,
                       cSapResultSet.cSapResultSetNode objSapResultSetNode,
                       cSapResultSet.cSapResultSetRow objParentResultSetRow) throws Exception {
      
      //
      // Instance the function and set the parameters
      //
      JCO.Function objFunction = objSapConnection.getFunction();
      JCO.ParameterList objImportList = objFunction.getImportParameterList();
      objImportList.setValue(cstrTable,"QUERY_TABLE");
      objImportList.setValue(" ","NO_DATA");
   //   objImportList.setValue(" ","DELIMETER");
   //   objImportList.setValue(9,"ROWSKIPS"); when > 0
   //   objImportList.setValue(9,"ROWCOUNT"); when > 0
      
      //
      // Build and load the fields when requested
      //
      JCO.Table objFields = objFunction.getTableParameterList().getTable("FIELDS");
      for (int i=0;i<cobjFields.size();i++) {
         objFields.appendRow();
         objFields.setValue(((String)cobjFields.get(i)).trim(),"FIELDNAME");
      }
      objFields = null;
      
      //
      // Build and load the conditions when requested
      //
      JCO.Table objOptions = objFunction.getTableParameterList().getTable("OPTIONS");
      for (int i=0;i<cstrConditions.length;i++) {
         if (!cstrConditions[i].trim().equals("")) {
            String strConditions = cstrConditions[i].toString();
            if (cstrConditions[i].indexOf("<SAPVALUE>",0) != -1) {
               String strTag = "<SAPVALUE>";
               String strGat = "</SAPVALUE>";
               int intStart = 0;
               int intEnd = 0;
               int intPointer = 0;
               strConditions = "";
               while (cstrConditions[i].indexOf(strTag,intPointer) != -1) {
                  intStart = cstrConditions[i].indexOf(strTag,intPointer);
                  intEnd = cstrConditions[i].indexOf(strGat,intPointer);
                  if (intEnd == -1) {
                     throw new Exception("SAP EXECUTION - unbalanced " + strTag + " tag found");
                  }
                  strConditions = strConditions + cstrConditions[i].substring(intPointer,intStart);
                  strConditions = strConditions + objParentResultSetRow.getFieldValue(cstrConditions[i].substring(intStart+strTag.length(),intEnd)).trim();
                  intPointer = intEnd + strGat.length();
               }
               strConditions = strConditions + cstrConditions[i].substring(intPointer);
            }
            objOptions.appendRow();
            objOptions.setValue(strConditions.trim(),"TEXT");
         }
      }
      objOptions = null;
      
      //
      // Execute the function
      //
      objSapConnection.execute(objFunction);
      
      //
      // Retrieve and load the result set meta data node columns
      // **note ** meta data is only stored once for a node
      //
      if (objSapResultSetMetaData.addNode(cstrNode)) {
         JCO.Table objMetaData = objFunction.getTableParameterList().getTable("FIELDS");
         for (int i=0;i<objMetaData.getNumRows();i++) {
            objMetaData.setRow(i);
            objSapResultSetMetaData.addColumn(cstrNode, objMetaData.getField("FIELDNAME").getString(), objMetaData.getField("OFFSET").getInt(), objMetaData.getField("LENGTH").getInt(), objMetaData.getField("TYPE").getString());
         }
      }
      
      //
      // Retrieve and load the result set data node rows
      //
      JCO.Table objData = objFunction.getTableParameterList().getTable("DATA");   
      for (int i=0;i<objData.getNumRows();i++) {
         objData.setRow(i);
         objSapResultSetNode.addRow(objData.getField(0).getString());
      }
      objData = null;
      
      //
      // Execute any child executions for each row when required
      // 1. Retrieve the result set data rows
      // 2. Add a new node to the result set data row
      // 3. Execute the child execution
      //
      if (cobjExecutions.size() > 0) {
         for (int i=0;i<objSapResultSetNode.getRowCount();i++) {
            for (int j=0;j<cobjExecutions.size();j++) {
               ((cSapExecution)cobjExecutions.get(j)).execute(objSapConnection,
                                                              objSapResultSetMetaData,
                                                              objSapResultSetNode.getRow(i).addNode(((cSapExecution)cobjExecutions.get(j)).getNode()),
                                                              objSapResultSetNode.getRow(i));
            }
         }
      }
      
   }
   
   /**
    * Gets the execution node name
    * @return String the execution node name
    */
   protected String getNode() {
      return cstrNode;
   }

}