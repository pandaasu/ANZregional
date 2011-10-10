/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cSapResultSetMetaData
 * Author  : Steve Gregan
 * Date    : May 2005
 */
package com.isi.sap;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements a SAP database query result set meta data. The result set meta
 * data is represented as a flat hash map of nodes. These nodes directly correspond to
 * the query node hierarchy. The result set meta data is only stored once for each node
 * in the hierarchy not for each execution of the node in the hierarchy.
 */
public final class cSapResultSetMetaData {

   //
   // Class static variables
   //
   private HashMap cobjNodes;
   private ArrayList cobjNodesList;
   private String cstrSpaces;
   private String cstrZeros;
   
   /**
    * Class constructor
    */
   protected cSapResultSetMetaData() {
      cobjNodes = new HashMap();
      cobjNodesList = new ArrayList();
      char[] chrSpaces = new char[1024];
      Arrays.fill(chrSpaces, ' ');
      cstrSpaces = String.valueOf(chrSpaces);
      char[] chrZeros = new char[64];
      Arrays.fill(chrZeros, '0');
      cstrZeros = String.valueOf(chrZeros);
   }
   
   /**
    * Writes the result set meta data to the specified file
    * @param strFileName the target file path and name
    * @param bolAppend append data o the target file
    * @throws Exception the exception message
    */
   public void toFile(String strFileName, boolean bolAppend) throws Exception {
      PrintWriter objPrintWriter = new PrintWriter(new FileWriter(strFileName, bolAppend));
      objPrintWriter.println("RESULT SET META DATA START : " + Calendar.getInstance().getTime());
      for (int i=0;i<cobjNodesList.size();i++) {
         ((cSapResultSetMetaDataNode)cobjNodesList.get(i)).toFile(objPrintWriter);
      }
      objPrintWriter.println("");
      objPrintWriter.println("RESULT SET META DATA END : " + Calendar.getInstance().getTime());
      objPrintWriter.close();
   }
   
   /**
    * Writes the result set meta data to the specified interface
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
      objPrintWriter.print("TAB" + strQuery);
      for (int i=0;i<cobjNodesList.size();i++) {
         ((cSapResultSetMetaDataNode)cobjNodesList.get(i)).toInterface(objPrintWriter);
      }
      objPrintWriter.close();
   }
   
   /**
    * Writes the result set meta data for the specified node
    * @param strNode the node identifier
    * @param objPrintWriter the target interface file
    * @throws Exception the exception message
    */
   public void toInterface(String strNode, PrintWriter objPrintWriter) throws Exception {
      if (cobjNodes.containsKey(strNode.toUpperCase())) {
         ((cSapResultSetMetaDataNode)cobjNodes.get(strNode.toUpperCase())).toInterface(objPrintWriter);
      }
   }
   
   /**
    * Adds a node to the result set meta data.
    * (note - all key value to hash maps are uppercased to make lookups case insensitive)
    * @param strNode the result set meta data node name
    * @return boolean node created indicator
    * @throws Exception the exception message
    */
   protected boolean addNode(String strNode) throws Exception {
      if (!cobjNodes.containsKey(strNode.toUpperCase())) {
         cSapResultSetMetaDataNode objNode = new cSapResultSetMetaDataNode(strNode);
         cobjNodes.put(strNode.toUpperCase(), objNode);
         cobjNodesList.add(objNode);
         return true;
      }
      return false;
   }
   
   /**
    * Adds a column to the result set meta data node.
    * @param strName the result set meta data table column name
    * @param strName the result set meta data table column data offset
    * @param strName the result set meta data table column data length
    * @param strType the result set meta data table column data type
    * @throws Exception the exception message
    */
   protected void addColumn(String strNode, String strName, int intOffset, int intLength, String strType) throws Exception {
      if (cobjNodes.containsKey(strNode.toUpperCase())) {
         ((cSapResultSetMetaDataNode)cobjNodes.get(strNode.toUpperCase())).addColumn(strName, intOffset, intLength, strType);
      }
   }
   
   /**
    * Gets the column count for the result set meta data node
    * @param strNode the result set meta data node to retrieve
    * @return int the result set meta data node column count
    */
   public int getColumnCount(String strNode) {
      if (cobjNodes.containsKey(strNode.toUpperCase())) {
         return ((cSapResultSetMetaDataNode)cobjNodes.get(strNode.toUpperCase())).getColumnCount();
      }
      return 0;
   }
   
   /**
    * Gets the column index for the result set meta data node column
    * @param strNode the result set meta data node to retrieve
    * @param strName the result set meta data node column name to retrieve
    * @return int the result set meta data node column index
    */
   public int getColumnIndex(String strNode, String strName) {
      if (cobjNodes.containsKey(strNode.toUpperCase())) {
         return ((cSapResultSetMetaDataNode)cobjNodes.get(strNode.toUpperCase())).getColumnIndex(strName);
      }
      return -1;
   }
   
   /**
    * Gets the column name for the result set meta data table column index
    * @param strNode the result set meta data node to retrieve
    * @param intIndex the result set meta data node column index to retrieve
    * @return String the result set meta data node column name
    */
   public String getColumnName(String strNode, int intIndex) {
      if (cobjNodes.containsKey(strNode.toUpperCase())) {
         return ((cSapResultSetMetaDataNode)cobjNodes.get(strNode.toUpperCase())).getColumnName(intIndex);
      }
      return null;
   }
   
   /**
    * Gets the column data type for the result set meta data node column index
    * @param strNode the result set meta data node to retrieve
    * @param intIndex the result set meta data node column index to retrieve
    * @return String the result set meta data node column data type
    */
   public String getColumnType(String strNode, int intIndex) {
      if (cobjNodes.containsKey(strNode.toUpperCase())) {
         return ((cSapResultSetMetaDataNode)cobjNodes.get(strNode.toUpperCase())).getColumnType(intIndex);
      }
      return null;
   }
   
   /**
    * Gets the column data offset for the result set meta data node column index
    * @param strNode the result set meta data node to retrieve
    * @param intIndex the result set meta data node column index to retrieve
    * @return int the result set meta data node column data offset
    */
   public int getColumnOffset(String strNode, int intIndex) {
      if (cobjNodes.containsKey(strNode.toUpperCase())) {
         return ((cSapResultSetMetaDataNode)cobjNodes.get(strNode.toUpperCase())).getColumnOffset(intIndex);
      }
      return 0;
   }
   
   /**
    * Gets the column data length for the result set meta data node column index
    * @param strNode the result set meta data node to retrieve
    * @param intIndex the result set meta data node column index to retrieve
    * @return int the result set meta data node column data length
    */
   public int getColumnLength(String strNode, int intIndex) {
      if (cobjNodes.containsKey(strNode.toUpperCase())) {
         return ((cSapResultSetMetaDataNode)cobjNodes.get(strNode.toUpperCase())).getColumnLength(intIndex);
      }
      return 0;
   }
   
   /**
    * Gets the column name array for the result set meta data node
    * @param strNode the result set meta data node to retrieve
    * @return String[] the result set meta data node column names array
    */
   public String[] getColumnNames(String strNode) {
      if (cobjNodes.containsKey(strNode.toUpperCase())) {
         return ((cSapResultSetMetaDataNode)cobjNodes.get(strNode.toUpperCase())).getColumnNames();
      }
      return null;
   }
   
   /**
    * Gets the column data type array for the result set meta data node
    * @param strNode the result set meta data node to retrieve
    * @return String[] the result set meta data node column data types array
    */
   public String[] getColumnTypes(String strNode) {
      if (cobjNodes.containsKey(strNode.toUpperCase())) {
         return ((cSapResultSetMetaDataNode)cobjNodes.get(strNode.toUpperCase())).getColumnTypes();
      }
      return null;
   }
   
   /**
    *****************************************
    * Result set meta data node inner class *
    *****************************************
    */
   private class cSapResultSetMetaDataNode {

      //
      // Class variables
      //
      private String cstrNode;
      private ArrayList cobjColumns;

      /**
       * Class constructor
       * @param strNode the node name
       */
      private cSapResultSetMetaDataNode(String strNode) {
         cstrNode = strNode;
         cobjColumns = new ArrayList();
      }
      
      /**
       * Outputs the node to the file writer
       * @param objPrintWriter the output file writer
       * @throws Exception the exception message
       */
      protected void toFile(PrintWriter objPrintWriter) throws Exception {
         objPrintWriter.println("");
         objPrintWriter.println("   NODE START - " + cstrNode + " Columns(" + cobjColumns.size() + ") : " + Calendar.getInstance().getTime());
         objPrintWriter.println("   FIELD                          TYPE                 OFFSET          LENGTH" );
         objPrintWriter.println("   -----                          ----                 ------          ------");
         for (int i=0;i<cobjColumns.size();i++) {
            ((cSapResultSetMetaDataTableColumn)cobjColumns.get(i)).toFile(objPrintWriter);
         }
      }
      
      /**
       * Outputs the node to the interface writer
       * @param objPrintWriter the output file writer
       * @throws Exception the exception message
       */
      protected void toInterface(PrintWriter objPrintWriter) throws Exception {
         for (int i=0;i<cobjColumns.size();i++) {
            ((cSapResultSetMetaDataTableColumn)cobjColumns.get(i)).toInterface(objPrintWriter);
         }
      }
      
      /**
       * Adds a column to the result set meta data node.
       * @param strName the result set meta data node column name
       * @param strName the result set meta data node column data offset
       * @param strName the result set meta data node column data length
       * @param strType the result set meta data node column data type
       * @throws Exception the exception message
       */
      private void addColumn(String strName, int intOffset, int intLength, String strType) throws Exception {
         cobjColumns.add(new cSapResultSetMetaDataTableColumn(strName, intOffset, intLength, strType));
      }
      
      /**
       * Gets the node column count
       * @return int the node column count
       */
      private int getColumnCount() {
         return cobjColumns.size();
      }
      
      /**
       * Gets the node column index for the specified name
       * @param strName the node column name
       * @return int the the node column index
       */
      private int getColumnIndex(String strName) {
         for (int i=0;i<cobjColumns.size();i++) {
            if (((cSapResultSetMetaDataTableColumn)cobjColumns.get(i)).getName().equals(strName)) {
               return i;
            }
         }
         return -1;
      }
      
      /**
       * Gets the node column name at the specified index
       * @param intIndex the index of the required node column
       * @return String the requested node column name
       */
      private String getColumnName(int intIndex) {
         if (intIndex >= 0 && intIndex < cobjColumns.size()) {
            return ((cSapResultSetMetaDataTableColumn)cobjColumns.get(intIndex)).getName();
         }
         return null;
      }
      
      /**
       * Gets the node column data type at the specified index
       * @param intIndex the index of the required node column
       * @return String the requested node column data type
       */
      private String getColumnType(int intIndex) {
         if (intIndex >= 0 && intIndex < cobjColumns.size()) {
            return ((cSapResultSetMetaDataTableColumn)cobjColumns.get(intIndex)).getType();
         }
         return null;
      }
      
      /**
       * Gets the node column data offset at the specified index
       * @param intIndex the index of the required node column
       * @return int the requested node column data offset
       */
      private int getColumnOffset(int intIndex) {
         if (intIndex >= 0 && intIndex < cobjColumns.size()) {
            return ((cSapResultSetMetaDataTableColumn)cobjColumns.get(intIndex)).getOffset();
         }
         return 0;
      }
      
      /**
       * Gets the node column data length at the specified index
       * @param intIndex the index of the required node column
       * @return int the requested node column data length
       */
      private int getColumnLength(int intIndex) {
         if (intIndex >= 0 && intIndex < cobjColumns.size()) {
            return ((cSapResultSetMetaDataTableColumn)cobjColumns.get(intIndex)).getLength();
         }
         return 0;
      }
      
      /**
       * Gets the node column names array
       * @return String[] the node column names array
       */
      private String[] getColumnNames() {
         String[] strNames = new String[cobjColumns.size()];
         for (int i=0;i<cobjColumns.size();i++) {
            strNames[i] = ((cSapResultSetMetaDataTableColumn)cobjColumns.get(i)).getName();
         }
         return strNames;
      }
      
      /**
       * Gets the node column data types array
       * @return String[] the node column data types array
       */
      private String[] getColumnTypes() {
         String[] strTypes = new String[cobjColumns.size()];
         for (int i=0;i<cobjColumns.size();i++) {
            strTypes[i] = ((cSapResultSetMetaDataTableColumn)cobjColumns.get(i)).getType();
         }
         return strTypes;
      }
      
      /**
       *************************************************
       * Result set meta data table column inner class *
       *************************************************
       */
      private class cSapResultSetMetaDataTableColumn {

         //
         // Class variables
         //
         private String cstrName;
         private int cintOffset;
         private int cintLength;
         private String cstrType;

         /**
          * Class constructor
          * @param strName the result set meta data node column name
          * @param strName the result set meta data node column data offset
          * @param strName the result set meta data node column data length
          * @param strType the result set meta data node column data type
          */
         private cSapResultSetMetaDataTableColumn(String strName, int intOffset, int intLength, String strType) {
            cstrName = strName;
            cintOffset = intOffset;
            cintLength = intLength;
            cstrType = strType;
         }
         
         /**
          * Outputs the node column to the file writer
          * @param objPrintWriter the output print writer
          * @throws Exception the exception message
          */
         protected void toFile(PrintWriter objPrintWriter) throws Exception {
            StringBuffer strOutput = new StringBuffer();
            strOutput.append("   " + cstrName + cstrSpaces.substring(0,31-cstrName.length()));
            strOutput.append(cstrType + cstrSpaces.substring(0,21-cstrType.length()));
            strOutput.append(Integer.toString(cintOffset) + cstrSpaces.substring(0,16-Integer.toString(cintOffset).length()));
            strOutput.append(Integer.toString(cintLength));
            objPrintWriter.println(strOutput.toString());
         }
         
         /**
          * Outputs the node column to the interface writer
          * @param objPrintWriter the output print writer
          * @throws Exception the exception message
          */
         protected void toInterface(PrintWriter objPrintWriter) throws Exception {
            StringBuffer strOutput = new StringBuffer();
            strOutput.append("FLD" + cstrNode + cstrSpaces.substring(0,30-cstrNode.length()));
            strOutput.append(cstrName + cstrSpaces.substring(0,30-cstrName.length()));
            strOutput.append(cstrType + cstrSpaces.substring(0,10-cstrType.length()));
            strOutput.append(cstrZeros.substring(0,9-Integer.toString(cintOffset).length()) + Integer.toString(cintOffset));
            strOutput.append(cstrZeros.substring(0,9-Integer.toString(cintLength).length()) + Integer.toString(cintLength));
            objPrintWriter.println();
            objPrintWriter.print(strOutput.toString());
         }
         
         /**
          * Gets the node column name
          * @return int the node column name
          */
         private String getName() {
            return cstrName;
         }

         /**
          * Gets the node column data offset
          * @return int the node column data offset
          */
         private int getOffset() {
            return cintOffset;
         }
         
         /**
          * Gets the node column data length
          * @return int the node column data length
          */
         private int getLength() {
            return cintLength;
         }

         /**
          * Gets the node column data type
          * @return int the node column data type
          */
         private String getType() {
            return cstrType;
         }

      }

   }

}