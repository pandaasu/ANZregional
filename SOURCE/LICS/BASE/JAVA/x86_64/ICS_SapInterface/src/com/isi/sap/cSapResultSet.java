/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cSapResultSet
 * Author  : Steve Gregan
 * Date    : May 2005
 */
package com.isi.sap;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements a SAP result set.
 */
public final class cSapResultSet {

   //
   // Class variables
   //
   private cSapResultSetMetaData cobjResultSetMetaData;
   private cSapResultSetNode cobjResultSetNode;
   private ArrayList cobjResultSetHierarchy;
   private int cintRowIndex;
   private String cstrSpaces;
   
   /**
    * Class constructor
    * @param strNode the result set node name
    * @throws Exception the exception message
    */
   protected cSapResultSet(String strNode) throws Exception {
      cobjResultSetMetaData = new cSapResultSetMetaData();
      cobjResultSetNode = new cSapResultSetNode(strNode, 0);
      cobjResultSetHierarchy = new ArrayList();
      cintRowIndex = -1;
      char[] chrSpaces = new char[1024];
      Arrays.fill(chrSpaces, ' ');
      cstrSpaces = String.valueOf(chrSpaces);
   }
   
   /**
    * Gets the result set meta data reference
    * @return cSapResultSetMetaData the result set meta data reference
    */
   public cSapResultSetMetaData getMetaData() {
      return cobjResultSetMetaData;
   }
   
   /**
    * Gets the result set node data reference
    * @return cSapResultSetNode the result set top data node reference
    */
   protected cSapResultSetNode getPrimaryNode() {
      return cobjResultSetNode;
   }
   
   /**
    * Writes the result set to the specified file
    * @param strFileName the target file path and name
    * @param bolAppend append data o the target file
    * @throws Exception the exception message
    */
   public void toFile(String strFileName, boolean bolAppend) throws Exception {
      PrintWriter objPrintWriter = new PrintWriter(new FileWriter(strFileName, bolAppend));
      objPrintWriter.println("RESULT SET START : " + Calendar.getInstance().getTime());
      cobjResultSetNode.toFile(objPrintWriter);
      objPrintWriter.println("");
      objPrintWriter.println("RESULT SET END : " + Calendar.getInstance().getTime());
      objPrintWriter.close();
   }
   
   /**
    * Writes the result set to the specified interface file
    * @param strFileName the target file path and name
    * @param strIdocName the target IDOC name
    * @param bolMetaData the meta data include indicator
    * @param bolAppend append data o the target file
    * @throws Exception the exception message
    */
   public void toInterface(String strFileName, String strIdocName, boolean bolMetaData, boolean bolAppend) throws Exception {
      PrintWriter objPrintWriter = new PrintWriter(new FileWriter(strFileName, bolAppend));
      DecimalFormat objDecimalFormat = new DecimalFormat();
      objDecimalFormat.setGroupingSize(0);
      objDecimalFormat.setMinimumFractionDigits(0);
      GregorianCalendar objCalendar = new GregorianCalendar();
      objCalendar.setTimeInMillis(Calendar.getInstance().getTimeInMillis());
      objDecimalFormat.setMinimumIntegerDigits(4);
      String strYear = objDecimalFormat.format((long)objCalendar.get(Calendar.YEAR));
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strMonth = objDecimalFormat.format((long)objCalendar.get(Calendar.MONTH)+1);
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strDay = objDecimalFormat.format((long)objCalendar.get(Calendar.DATE));
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strHour = objDecimalFormat.format((long)objCalendar.get(Calendar.HOUR_OF_DAY));
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strMinute = objDecimalFormat.format((long)objCalendar.get(Calendar.MINUTE));
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strSecond = objDecimalFormat.format((long)objCalendar.get(Calendar.SECOND));
      String strTimestamp = strYear + strMonth + strDay + strHour + strMinute + strSecond;
      if (bolAppend) {
         objPrintWriter.println();
      }
      objPrintWriter.print("CTL" + strIdocName + cstrSpaces.substring(0,30-strIdocName.length()) + "9999999999999999" + strTimestamp);                      
      cobjResultSetNode.toInterface(objPrintWriter, bolMetaData);
      objPrintWriter.close();
   }
   
   /**
    * Appends the result set to the specified interface file
    * @param strFileName the target file path and name
    * @throws Exception the exception message
    */
   public void appendToInterface(String strFileName) throws Exception {
      PrintWriter objPrintWriter = new PrintWriter(new FileWriter(strFileName, true));                 
      cobjResultSetNode.appendToInterface(objPrintWriter);
      objPrintWriter.close();
   }
   
   /**
    * Sets the hierarchy for the result set
    * @throws Exception the exception message
    */
   public void setHierarchy() throws Exception {
      cobjResultSetHierarchy.clear();
      cobjResultSetNode.toHierarchy();
      cintRowIndex = -1;
   }
   
   /**
    * Sets the result set to the next row
    * @return boolean the end of result set indicator
    */
   public boolean getNextRow() {
      cintRowIndex++;
      if (cintRowIndex < cobjResultSetHierarchy.size()) {
         return true;
      }
      return false;
   }
   
   /**
    * Gets the name of the current result set node
    * @return String the current result set node name
    */
   public String getNodeName() {
      return ((cSapResultSetRow)cobjResultSetHierarchy.get(cintRowIndex)).getNodeName();
   }
   
   /**
    * Gets the depth of the current result set node
    * @return int the current result set node depth
    */
   public int getNodeDepth() {
      return ((cSapResultSetRow)cobjResultSetHierarchy.get(cintRowIndex)).getNodeDepth();
   }
   
   /**
    * Gets the field count of the current result set node row
    * @return Int the current result set node row field count
    */
   public int getFieldCount() {
      return ((cSapResultSetRow)cobjResultSetHierarchy.get(cintRowIndex)).getFieldCount();
   }
   
   /**
    * Gets the field value of the current result set node row at the specified column index
    * @param intIndex the field index
    * @return String the current result set node row field value
    */
   public String getFieldValue(int intIndex) {
      return ((cSapResultSetRow)cobjResultSetHierarchy.get(cintRowIndex)).getFieldValue(intIndex);
   }
   
   /**
    * Gets the field value of the current result set node row for the specified column name
    * @param strColumn the column name
    * @return String the current result set node row field value
    */
   public String getFieldValue(String strColumn) {
      return ((cSapResultSetRow)cobjResultSetHierarchy.get(cintRowIndex)).getFieldValue(strColumn);
   }
   
   /**
    * Gets the field name of the current result set node row at the specified column index
    * @param intIndex the field index
    * @return String the current result set node row field name
    */
   public String getFieldName(int intIndex) {
      return ((cSapResultSetRow)cobjResultSetHierarchy.get(cintRowIndex)).getFieldName(intIndex);
   }
   
   /**
    * Gets the field type of the current result set node row at the specified column index
    * @param intIndex the field index
    * @return String the current result set node row field type
    */
   public String getFieldType(int intIndex) {
      return ((cSapResultSetRow)cobjResultSetHierarchy.get(cintRowIndex)).getFieldType(intIndex);
   }
   
   /**
    *******************************
    * Result set node inner class *
    *******************************
    */
   protected class cSapResultSetNode {

      //
      // Class variables
      //
      private String cstrNode;
      private int cintDepth;
      private ArrayList cobjRows;

      /**
       * Class constructor
       * @param strNode the result set node name
       * @param intDepth the result set node depth
       */
      private cSapResultSetNode(String strNode, int intDepth) {
         cstrNode = strNode;
         cintDepth = intDepth;
         cobjRows = new ArrayList();
      }
      
      /**
       * Adds a row to the result set node.
       * @param strRowData the result set row data
       * @throws Exception the exception message
       */
      protected void addRow(String strRowData) throws Exception {
         cobjRows.add(new cSapResultSetRow(cstrNode, cintDepth, strRowData));
      }
      
      /**
       * Gets the node row count
       * @return int the node row count
       */
      protected int getRowCount() {
         return cobjRows.size();
      }
      
      /**
       * Gets the result set row for the specified row index
       * @param intIndex the row index to retrieve
       * @return cSapResultSetRow the result set row reference
       */
      protected cSapResultSetRow getRow(int intIndex) {
         return (cSapResultSetRow)cobjRows.get(intIndex);
      }
      
      /**
       * Outputs the node to the file writer
       * @param objPrintWriter the output file writer
       * @throws Exception the exception message
       */
      protected void toFile(PrintWriter objPrintWriter) throws Exception {
         objPrintWriter.println("");
         objPrintWriter.println(cstrSpaces.substring(0,(cintDepth*3)) + "NODE START - " + cstrNode + " Rows(" + cobjRows.size() + ") : " + Calendar.getInstance().getTime());
         for (int i=0; i<cobjRows.size(); i++) {
            ((cSapResultSetRow)cobjRows.get(i)).toFile(objPrintWriter);
         }
      }
      
      /**
       * Outputs the node to the interface writer
       * @param objPrintWriter the output file writer
       * @param bolMetaData the meta data include indicator
       * @throws Exception the exception message
       */
      protected void toInterface(PrintWriter objPrintWriter, boolean bolMetaData) throws Exception {
         if (cintDepth == 0) {
            objPrintWriter.println();
            objPrintWriter.print("NOD" + cstrNode + cstrSpaces.substring(0,30-cstrNode.length()));
         }
         if (bolMetaData) {
            cobjResultSetMetaData.toInterface(cstrNode, objPrintWriter);
         }
         for (int i=0; i<cobjRows.size(); i++) {
            ((cSapResultSetRow)cobjRows.get(i)).toInterface(objPrintWriter, bolMetaData);
         }
      }
      
      /**
       * Appends the node to the interface writer
       * @param objPrintWriter the output file writer
       * @throws Exception the exception message
       */
      protected void appendToInterface(PrintWriter objPrintWriter) throws Exception {
         for (int i=0; i<cobjRows.size(); i++) {
            ((cSapResultSetRow)cobjRows.get(i)).appendToInterface(objPrintWriter);
         }
      }
      
      /**
       * Sets the hierarchy for the result set node
       * @throws Exception the exception message
       */
      protected void toHierarchy() throws Exception {
         for (int i=0; i<cobjRows.size(); i++) {
            cobjResultSetHierarchy.add(cobjRows.get(i));
            ((cSapResultSetRow)cobjRows.get(i)).toHierarchy();
         }
      }
      
   }
   
   /**
    ******************************
    * Result set row inner class *
    ******************************
    */
   protected class cSapResultSetRow {

      //
      // Class variables
      //
      private String cstrNode;
      private int cintDepth;
      private String[] cstrValues;
      private ArrayList cobjNodes;

      /**
       * Class constructor
       * @param strNode the result set node name
       * @param intDepth the result set node depth
       * @param strRowData the result set row data
       */
      private cSapResultSetRow(String strNode, int intDepth, String strRowData) {
         cstrNode = strNode;
         cintDepth = intDepth;
         int intBindex = 0;
         int intEindex = 0;
         String strFieldData = null;
         cstrValues = new String[cobjResultSetMetaData.getColumnCount(strNode)];
         for (int i=0;i<cstrValues.length;i++) {
            intBindex = cobjResultSetMetaData.getColumnOffset(strNode,i);
            intEindex = intBindex + cobjResultSetMetaData.getColumnLength(strNode,i);
            if (intEindex > strRowData.length()) {
               intEindex = strRowData.length();
            }
            strFieldData = "";
            if (intBindex < intEindex) {
               strFieldData = strRowData.substring(intBindex, intEindex);
            }
            cstrValues[i] = strFieldData;
            if (cstrValues[i].length() < cobjResultSetMetaData.getColumnLength(strNode,i)) {
               cstrValues[i] = cstrValues[i] + cstrSpaces.substring(0,cobjResultSetMetaData.getColumnLength(strNode,i)-cstrValues[i].length());
            }
         }
         cobjNodes = null;     
      }
      
      /**
       * Gets the parent node name
       * @return String the parent node name
       */
      protected String getNodeName() {
         return cstrNode;
      }
      
      /**
       * Gets the parent node depth
       * @return int the parent node depth
       */
      protected int getNodeDepth() {
         return cintDepth;
      }
      
      /**
       * Gets the node row column count
       * @return int the node row column count
       */
      protected int getFieldCount() {
         return cstrValues.length;
      }

      /**
       * Gets the row field value at the specified column index
       * @param intIndex the index of the column
       * @return String the field value
       */
      protected String getFieldValue(int intIndex) {
         if (intIndex < 0 || intIndex >= cstrValues.length) {
            return null;
         }
         return cstrValues[intIndex];
      }
      
      /**
       * Gets the row field value at the specified column name
       * @param strColumn the name of the column
       * @return String the field value
       */
      protected String getFieldValue(String strColumn) {
         int intIndex = cobjResultSetMetaData.getColumnIndex(cstrNode, strColumn.toUpperCase());
         if (intIndex < 0 || intIndex >= cstrValues.length) {
            return null;
         }
         return cstrValues[intIndex];
      }
      
      /**
       * Gets the row field name at the specified column index
       * @param intIndex the index of the column
       * @return String the field name
       */
      protected String getFieldName(int intIndex) {
         return cobjResultSetMetaData.getColumnName(cstrNode, intIndex);
      }
      
      /**
       * Gets the row field type at the specified column index
       * @param intIndex the index of the column
       * @return String the field type
       */
      protected String getFieldType(int intIndex) {
         return cobjResultSetMetaData.getColumnType(cstrNode, intIndex);
      }

      /**
       * Adds a node to the result set node row.
       * @param strNode the result set node name
       * @returns cSapResultSetNode the new result set node reference
       * @throws Exception the exception message
       */
      protected cSapResultSetNode addNode(String strNode) throws Exception {
         if (cobjNodes == null) {
            cobjNodes = new ArrayList();
         }
         cSapResultSetNode objSapResultSetNode = new cSapResultSetNode(strNode, cintDepth+1);
         cobjNodes.add(objSapResultSetNode);
         return objSapResultSetNode;      
      }
      
      /**
       * Gets the node row node count
       * @return int the node row node count
       */
      protected int getNodeCount() {
         if (cobjNodes == null) {
            return 0;
         }
         return cobjNodes.size();
      }
      
      /**
       * Gets the node row node at the specified index
       * @param intIndex the node row node index
       * @return cSapResultSetNode the result set node reference
       */
      protected cSapResultSetNode getNode(int intIndex) {
         if (cobjNodes == null) {
            return null;
         }
         if (intIndex < 0 || intIndex >= cobjNodes.size()) {
            return null;
         }
         return (cSapResultSetNode)cobjNodes.get(intIndex);
      }
      
      /**
       * Outputs the node row to the file writer
       * @param objPrintWriter the output file writer
       * @throws Exception the exception message
       */
      protected void toFile(PrintWriter objPrintWriter) throws Exception {
         objPrintWriter.println("");
         objPrintWriter.println(cstrSpaces.substring(0,(cintDepth*3)) + "FIELD                          DATA");
         objPrintWriter.println(cstrSpaces.substring(0,(cintDepth*3)) + "-----                          ----");
         for (int i=0; i<cstrValues.length; i++) {
            objPrintWriter.println(cstrSpaces.substring(0,(cintDepth*3)) + cobjResultSetMetaData.getColumnName(cstrNode,i) + cstrSpaces.substring(0,31-cobjResultSetMetaData.getColumnName(cstrNode,i).length()) + cstrValues[i]);
         }
         if (cobjNodes != null) {
            for (int i=0; i<cobjNodes.size(); i++) {
               ((cSapResultSetNode)cobjNodes.get(i)).toFile(objPrintWriter);
            }
         }
      }
      
      /**
       * Outputs the node row to the interface writer
       * @param objPrintWriter the output interface writer
       * @param bolMetaData the meta data include indicator
       * @throws Exception the exception message
       */
      protected void toInterface(PrintWriter objPrintWriter, boolean bolMetaData) throws Exception {
         StringBuffer strOutput = new StringBuffer();
         strOutput.append("DAT" + cstrNode + cstrSpaces.substring(0,30-cstrNode.length()));
         for (int i=0; i<cstrValues.length; i++) {
            strOutput.append(cstrValues[i]);
         }
         objPrintWriter.println();
         objPrintWriter.print(strOutput.toString());
         if (cobjNodes != null) {
            for (int i=0; i<cobjNodes.size(); i++) {
               ((cSapResultSetNode)cobjNodes.get(i)).toInterface(objPrintWriter, bolMetaData);
            }
         }
      }
      
      /**
       * Append the node row to the interface writer
       * @param objPrintWriter the output interface writer
       * @throws Exception the exception message
       */
      protected void appendToInterface(PrintWriter objPrintWriter) throws Exception {
         StringBuffer strOutput = new StringBuffer();
         strOutput.append("DAT" + cstrNode + cstrSpaces.substring(0,30-cstrNode.length()));
         for (int i=0; i<cstrValues.length; i++) {
            strOutput.append(cstrValues[i]);
         }
         objPrintWriter.println();
         objPrintWriter.print(strOutput.toString());
         if (cobjNodes != null) {
            for (int i=0; i<cobjNodes.size(); i++) {
               ((cSapResultSetNode)cobjNodes.get(i)).appendToInterface(objPrintWriter);
            }
         }
      }
      
      /**
       * Sets the hierarchy for the result set node row
       * @throws Exception the exception message
       */
      protected void toHierarchy() throws Exception {
         if (cobjNodes != null) {
            for (int i=0; i<cobjNodes.size(); i++) {
               ((cSapResultSetNode)cobjNodes.get(i)).toHierarchy();
            }
         }
      }

   }

}