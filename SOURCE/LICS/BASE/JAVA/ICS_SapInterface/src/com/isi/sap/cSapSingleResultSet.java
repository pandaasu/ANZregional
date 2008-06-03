/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cSapSingleResultSet
 * Author  : Steve Gregan
 * Date    : February 2007
 */
package com.isi.sap;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements a SAP single result set.
 */
public final class cSapSingleResultSet {

   //
   // Class variables
   //
   private String cstrSpaces;
   private cSapResultSetMetaData cobjResultSetMetaData;
   private ArrayList cobjRows;
   
   /**
    * Class constructor
    * @throws Exception the exception message
    */
   protected cSapSingleResultSet() throws Exception {
      char[] chrSpaces = new char[1024];
      Arrays.fill(chrSpaces, ' ');
      cstrSpaces = String.valueOf(chrSpaces);
      cobjResultSetMetaData = new cSapResultSetMetaData();
      cobjRows = new ArrayList();
   }
   
   /**
    * Gets the result set meta data reference
    * @return cSapResultSetMetaData the result set meta data reference
    */
   public cSapResultSetMetaData getMetaData() {
      return cobjResultSetMetaData;
   }
   
   /**
    * Adds a row to the result set.
    * @param strRowData the result set row data
    * @throws Exception the exception message
    */
   protected void addRow(String strNode, String strRowData) throws Exception {
      cobjRows.add(new cSapSingleResultSetRow(strNode, strRowData));
   }

   /**
    * Gets the row count
    * @return int the node row count
    */
   public int getRowCount() {
      return cobjRows.size();
   }
   
   /**
    * Gets the row count for the requested node
    * @param strNode the node name
    * @return int the node row count
    */
   public int getRowCount(String strNode) {
      int intCount = 0;
      for (int i=0; i<cobjRows.size(); i++) {
         if (((cSapSingleResultSetRow)cobjRows.get(i)).getNodeName().equals(strNode.toUpperCase())) {
            intCount++;
         }
      }
      return intCount;
   }

   /**
    * Gets the result set row for the specified row index
    * @param intIndex the row index to retrieve
    * @return cSapResultSetRow the result set row reference
    */
   public cSapSingleResultSetRow getRow(int intIndex) {
      return (cSapSingleResultSetRow)cobjRows.get(intIndex);
   }
   
   /**
    * Gets the result set field value for the specified row index
    * @param intRow the row index to retrieve
    * @param strColumn the column name
    * @return String the result set field value
    */
   public String getFieldValue(int intRow, String strColumn) {
      return ((cSapSingleResultSetRow)cobjRows.get(intRow)).getFieldValue(strColumn);
   }
   
   /**
    * Gets the result set field value for the specified row index
    * @param intRow the row index to retrieve
    * @param intColumn the column index
    * @return String the result set field value
    */
   public String getFieldValue(int intRow, int intColumn) {
      return ((cSapSingleResultSetRow)cobjRows.get(intRow)).getFieldValue(intColumn);
   }
   
   /**
    * Retrieves the merged array from the requested node
    * @param objList the source array
    * @param strNode the node name to merge
    * @param strColumn the column name to merge
    * @return ArrayList the merged array
    * @throws Exception the exception message
    */
   public ArrayList getMergedArray(ArrayList objList, String strNode, String strColumn) throws Exception {
      
      //
      // Return the list when required
      //
      if (strNode == null || strColumn == null) {
         return objList;
      }
      
      //
      // Create the work list when required
      //
      ArrayList objWork = objList;
      if (objWork == null) {
         objWork = new ArrayList();
      }
      
      //
      // Merge the node data into the work list
      //
      boolean bolFound;
      for (int i=0; i<cobjRows.size(); i++) {
         if (((cSapSingleResultSetRow)cobjRows.get(i)).getNodeName().equals(strNode.toUpperCase())) {
            bolFound = false;
            for (int j=0; j<objWork.size(); j++) {
               if (((cSapSingleResultSetRow)cobjRows.get(i)).getFieldValue(strColumn.toUpperCase()).trim().equals((String)objWork.get(j))) {
                  bolFound = true;
                  break;
               }
            }
            if (!bolFound) {
               objWork.add(((cSapSingleResultSetRow)cobjRows.get(i)).getFieldValue(strColumn.toUpperCase()).trim());
            }
         }
      }

      //
      // Return the merged array
      //
      return objWork;
      
   }
   
   /**
    * Retrieves the OR condition statements from the requested node
    * @param strNode the node name to query
    * @param strKeyCondition the key condition clause
    * @param intGroup the result grouping
    * @return ArrayList the condition array
    * @throws Exception the exception message
    */
   public ArrayList getOrConditionsArray(String strNode, String strKeyCondition, int intGroup) throws Exception {
      
      //
      // Return an empty array when required
      //
      if (strNode == null || strKeyCondition == null) {
         return new ArrayList();
      }
      
      //
      // Retrieve and load the result set data rows when required
      //
      String strPart1 = strKeyCondition;
      String strPart2 = null;
      String strPart3 = null;
      String strTag = "<KEYVALUE>";
      String strGat = "</KEYVALUE>";
      int intStart = 0;
      int intEnd = 0;
      if (strKeyCondition.indexOf(strTag,0) != -1) {
         intStart = strKeyCondition.indexOf(strTag,0);
         intEnd = strKeyCondition.indexOf(strGat,0);
         if (intEnd != -1) {
            strPart1 = strKeyCondition.substring(0,intStart);
            strPart2 = strKeyCondition.substring(intStart+strTag.length(),intEnd);
            strPart3 = strKeyCondition.substring(intEnd + strGat.length());
         }
      }
      
      //
      // Load the keys array
      //
      ArrayList objKeys = new ArrayList();
      String[] strKeys = null;
      int intTotal = getRowCount(strNode.toUpperCase());
      int intCount = intGroup - 1;
      for (int i=0; i<cobjRows.size(); i++) {
         if (((cSapSingleResultSetRow)cobjRows.get(i)).getNodeName().equals(strNode.toUpperCase())) {
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
               strKeys[intCount] = "(" + strPart1;
            } else {
               strKeys[intCount] = strPart1;
            }
            if (strPart2 != null) {
               strKeys[intCount] = strKeys[intCount] + ((cSapSingleResultSetRow)cobjRows.get(i)).getFieldValue(strPart2).trim();
               strKeys[intCount] = strKeys[intCount] + strPart3;
            } 
            if (intCount < (strKeys.length-1)) {
               strKeys[intCount] = strKeys[intCount] + " OR";
            } else {
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
   
   /**
    * Retrieves the OR condition statements from the requested node
    * @param strNode the node name to query
    * @param strKeyCondition the key condition clause
    * @return String[] the condition array
    * @throws Exception the exception message
    */
   public String[] getOrConditions(String strNode, String strKeyCondition) throws Exception {
      
      //
      // Return an empty array when required
      //
      if (strNode == null || strKeyCondition == null) {
         return new String[0];
      }
      
      //
      // Retrieve and load the result set data rows when required
      //
      String strPart1 = strKeyCondition;
      String strPart2 = null;
      String strPart3 = null;
      String strTag = "<KEYVALUE>";
      String strGat = "</KEYVALUE>";
      int intStart = 0;
      int intEnd = 0;
      if (strKeyCondition.indexOf(strTag,0) != -1) {
         intStart = strKeyCondition.indexOf(strTag,0);
         intEnd = strKeyCondition.indexOf(strGat,0);
         if (intEnd != -1) {
            strPart1 = strKeyCondition.substring(0,intStart);
            strPart2 = strKeyCondition.substring(intStart+strTag.length(),intEnd);
            strPart3 = strKeyCondition.substring(intEnd + strGat.length());
         }
      }

      //
      // Retrieve and load the result set data node rows
      //
      String[] strKeys = new String[getRowCount(strNode.toUpperCase())];
      int intCount = 0;
      for (int i=0; i<cobjRows.size(); i++) {
         if (((cSapSingleResultSetRow)cobjRows.get(i)).getNodeName().equals(strNode.toUpperCase())) {
            if (intCount == 0) {
               strKeys[intCount] = "(" + strPart1;
            } else {
               strKeys[intCount] = strPart1;
            }
            if (strPart2 != null) {
               strKeys[intCount] = strKeys[intCount] + ((cSapSingleResultSetRow)cobjRows.get(i)).getFieldValue(strPart2).trim();
               strKeys[intCount] = strKeys[intCount] + strPart3;
            } 
            if (intCount < (strKeys.length-1)) {
               strKeys[intCount] = strKeys[intCount] + " OR";
            } else {
               strKeys[intCount] = strKeys[intCount] + ")";
            }
            intCount++;
         }
      }
      
      //
      // Return the condition array
      //
      return strKeys;
      
   }
   
   /**
    * Writes the result set to the specified interface file
    * @param strFileName the target file path and name
    * @param strIdocName the target IDOC name
    * @param strQuery the query name
    * @param bolAppend append data o the target file
    * @throws Exception the exception message
    */
   public void toInterface(String strFileName, String strIdocName, String strQuery, boolean bolAppend) throws Exception {
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
      objPrintWriter.println();
      objPrintWriter.print("NOD" + strQuery + cstrSpaces.substring(0,30-strQuery.length()));
      for (int i=0; i<cobjRows.size(); i++) {
         ((cSapSingleResultSetRow)cobjRows.get(i)).toInterface(objPrintWriter);
      }
      objPrintWriter.close();
   }
   
   /**
    * Writes the result set to the specified interface file with meta data
    * @param strFileName the target file path and name
    * @param strIdocName the target IDOC name
    * @param strQuery the query name
    * @param bolAppend append data o the target file
    * @throws Exception the exception message
    */
   public void toInterfaceMeta(String strFileName, String strIdocName, String strQuery, boolean bolAppend) throws Exception {
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
      objPrintWriter.println();
      objPrintWriter.print("NOD" + strQuery + cstrSpaces.substring(0,30-strQuery.length()));
      cobjResultSetMetaData.toInterface(strQuery, objPrintWriter);
      for (int i=0; i<cobjRows.size(); i++) {
         ((cSapSingleResultSetRow)cobjRows.get(i)).toInterface(objPrintWriter);
      }
      objPrintWriter.close();
   }
   
   /**
    * Appends the result set to the specified interface file
    * @param strFileName the target file path and name
    * @throws Exception the exception message
    */
   public void appendToInterface(String strFileName) throws Exception {
      PrintWriter objPrintWriter = new PrintWriter(new FileWriter(strFileName, true));                 
      for (int i=0; i<cobjRows.size(); i++) {
         ((cSapSingleResultSetRow)cobjRows.get(i)).toInterface(objPrintWriter);
      }
      objPrintWriter.close();
   }
   
   /**
    ******************************
    * Result set row inner class *
    ******************************
    */
   protected class cSapSingleResultSetRow {

      //
      // Class variables
      //
      private String cstrNode;
      private String[] cstrValues;

      /**
       * Class constructor
       * @param strNode the result set node name
       * @param strRowData the result set row data
       */
      private cSapSingleResultSetRow(String strNode, String strRowData) {
         cstrNode = strNode;
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
      }
      
      /**
       * Gets the parent node name
       * @return String the parent node name
       */
      public String getNodeName() {
         return cstrNode;
      }
      
      /**
       * Gets the node row column count
       * @return int the node row column count
       */
      public int getFieldCount() {
         return cstrValues.length;
      }

      /**
       * Gets the row field value at the specified column index
       * @param intIndex the index of the column
       * @return String the field value
       */
      public String getFieldValue(int intIndex) {
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
      public String getFieldValue(String strColumn) {
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
      public String getFieldName(int intIndex) {
         return cobjResultSetMetaData.getColumnName(cstrNode, intIndex);
      }
      
      /**
       * Gets the row field type at the specified column index
       * @param intIndex the index of the column
       * @return String the field type
       */
      public String getFieldType(int intIndex) {
         return cobjResultSetMetaData.getColumnType(cstrNode, intIndex);
      }
      
      /**
       * Outputs the row to the interface writer
       * @param objPrintWriter the output interface writer
       * @throws Exception the exception message
       */
      protected void toInterface(PrintWriter objPrintWriter) throws Exception {
         StringBuffer strOutput = new StringBuffer();
         strOutput.append("DAT" + cstrNode + cstrSpaces.substring(0,30-cstrNode.length()));
         for (int i=0; i<cstrValues.length; i++) {
            strOutput.append(cstrValues[i]);
         }
         objPrintWriter.println();
         objPrintWriter.print(strOutput.toString());
      }

   }

}