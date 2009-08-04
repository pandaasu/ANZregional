/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cDataStore
 * Author  : Steve Gregan
 * Date    : April 2008
 */
package com.isi.efex;
import javax.microedition.rms.*;

/**
 * This abstract class implements the Efex application data store. The individual
 * object data models must extend this abstract class in order to interact with
 * the data store. The individual object data models are responsible for interpreting
 * the data store message structure.
 */
public abstract class cDataStore {

   //
   // Instance private declarations
   //
   protected String cstrDataStore = null;
   protected char cchrRecord = 0;
   protected int cintRecordId = 0;
   private java.util.Vector cobjFilters = new java.util.Vector();
   
   /**
    * Sets the data store from the string buffer.
    *
    * @param strBuffer the data store string buffer
    * @param bolReplace replaces the data store
    * @throws Exception the exception message
    */
   protected void setDataStore(String objBuffer, boolean bolReplace) throws Exception {
      
      //
      // Local variable declarations
      //
      RecordStore objDataStore = null;
      StringBuffer objRecord = null;
      byte[] objBytes = null;
      char chrCode = 0;
      short shrLength = 0;
      int intIndex = 0;
      int intNewId = 0;
           
      //
      // Delete the existing record store when requested
      // **note** ignore any exceptions
      //
      if (bolReplace) {
         cintRecordId = 0;
         try {
            RecordStore.deleteRecordStore(cstrDataStore);
         } catch(Exception objException) {}
      }

      //
      // Load the data store from the string buffer
      //
      try {
         
         //
         // Reset the new record identifier
         //
         if (cintRecordId == 0) {
            intNewId = 0;
         }

         //
         // Open the data store
         //
         objDataStore = RecordStore.openRecordStore(cstrDataStore, true);
      
         //
         // Load the data store from the string buffer
         //
         objRecord = new StringBuffer();
         intIndex = 0;
         while (intIndex < objBuffer.length()) {
            chrCode = objBuffer.charAt(intIndex);
            if (chrCode == cchrRecord && objRecord.length() != 0) {
               objBytes = objRecord.toString().getBytes("UTF-8");
               if (cintRecordId == 0) {
                  intNewId = objDataStore.addRecord(objBytes,0,objBytes.length);
               } else {
                  objDataStore.setRecord(cintRecordId, objBytes,0,objBytes.length);
               }
               objRecord = new StringBuffer();
            }
            objRecord.append(String.valueOf(chrCode));
            intIndex++;
            shrLength = (short)objBuffer.charAt(intIndex);
            objRecord.append(String.valueOf((char)shrLength));
            intIndex++;
            if (shrLength > 0) {
               objRecord.append(objBuffer.substring(intIndex, (intIndex + shrLength)));
               intIndex = intIndex + shrLength;
            }     
         }
         if (objRecord.length() != 0) {
            objBytes = objRecord.toString().getBytes("UTF-8");
            if (cintRecordId == 0) {
               intNewId = objDataStore.addRecord(objBytes,0,objBytes.length);
            } else {
               objDataStore.setRecord(cintRecordId, objBytes,0,objBytes.length);
            }
         }
         if (!bolReplace && cintRecordId == 0) {
            cintRecordId = intNewId;
         }
      
      } catch(Exception objException) {
         throw new Exception("(eFEX) Data store - Set data store failed - " + objException.toString());
      } finally {
         if (objDataStore != null) {
            objDataStore.closeRecordStore();   
         }
         objDataStore = null;
         objRecord = null;
      }
   
   }
   
   /**
    * Gets the data store string buffer
    *
    * @return String the data store string buffer
    * @throws Exception the exception message
    */
   protected String getDataStore() throws Exception {
      
      //
      // Local variable declarations
      //
      RecordStore objDataStore = null;
      RecordEnumeration objEnumeration = null;
      byte[] objBytes = null;
      StringBuffer objBuffer = new StringBuffer();
      int intRecordId = 0;
      
      //
      // Validate the data store
      //
      if (cstrDataStore == null) {
         throw new Exception("(eFEX) Data store name not specified");
      }
      
      //
      // Retrieve and load the data store into the string buffer
      //
      try {
         objDataStore = RecordStore.openRecordStore(cstrDataStore, true);
         if (cobjFilters.size() == 0) {
            objEnumeration = objDataStore.enumerateRecords(null, new cDataStoreComparator(cchrRecord), false);
         } else {
            objEnumeration = objDataStore.enumerateRecords(new cDataStoreFilter("*AND", true), new cDataStoreComparator(cchrRecord), false);
         }
         while (objEnumeration.hasNextElement()) {
            intRecordId = objEnumeration.nextRecordId();
            objBytes = objDataStore.getRecord(intRecordId);
            objBuffer.append(new String(objBytes,0,objBytes.length,"UTF-8"));
         }
         return objBuffer.toString();
      } catch(Exception objException) {
         throw new Exception("(eFEX) Data store - Get data store failed - " + objException.getMessage());
      } finally {
         if (objEnumeration != null) {
            objEnumeration.destroy(); 
         }
         if (objDataStore != null) {
            objDataStore.closeRecordStore();  
         }
         objEnumeration = null;
         objDataStore = null;
         objBytes = null;
      }
      
   }
   
   /**
    * Gets a record from the data store.
    *
    * @return java.util.Vector the data store record value array
    * @throws Exception the exception message
    */
   protected java.util.Vector getRecord() throws Exception {
      
      //
      // Local variable declarations
      //
      java.util.Vector objDataValues = null;
      RecordStore objDataStore = null;
      byte[] objBytes = null;
      String objBuffer = null;
      char chrCode = 0;
      short shrLength = 0;
      int intIndex = 0;
      
      //
      // Validate the data store and record identifier
      //
      if (cstrDataStore == null) {
         throw new Exception("(eFEX) Data store name not specified");
      }
      if (cintRecordId == 0) {
         throw new Exception("(eFEX) Data store record identifier not specified");
      }
      
      //
      // Retrieve the record from the data store
      //
      try {
         objDataStore = RecordStore.openRecordStore(cstrDataStore, true);
         objBytes = objDataStore.getRecord(cintRecordId);
      } catch(InvalidRecordIDException objException) {
         return null;
      } catch(Exception objException) {
         throw new Exception("(eFEX) Data store get record failed - " + objException.getMessage());
      } finally {
         if (objDataStore != null) {
            objDataStore.closeRecordStore();   
         }
         objDataStore = null;
      }
      
      //
      // Parse the data store record into the data values array
      //
      objDataValues = new java.util.Vector();
      try {
         objBuffer = new String(objBytes,0,objBytes.length,"UTF-8");
         intIndex = 0;
         while (intIndex < objBuffer.length()) {
            chrCode = objBuffer.charAt(intIndex);
            intIndex++;
            shrLength = (short)objBuffer.charAt(intIndex);
            intIndex++;
            if (shrLength <= 0) {
               objDataValues.addElement(new cDataValue(chrCode, ""));
            } else {
               objDataValues.addElement(new cDataValue(chrCode, objBuffer.substring(intIndex, (intIndex + shrLength))));
               intIndex = intIndex + shrLength;
            }
         }
         return objDataValues;
      } catch(Exception objException) {
         throw new Exception("(eFEX) Data store get record data parsing failed - " + objException.getMessage());
      } finally {
         objBytes = null;
         objBuffer = null;
      }
      
   }
   
   /**
    * Sets a record into the data store.
    *
    * @param objDataValues the data store record value array
    * @throws Exception the exception message
    */
   protected void setRecord(java.util.Vector objDataValues) throws Exception {
      
      //
      // Local variable declarations
      //
      RecordStore objDataStore = null;
      cDataValue objDataValue = null;
      StringBuffer objBuffer = null;
      byte[] objBytes = null;
      
      //
      // Validate the data store and record identifier
      //
      if (cstrDataStore == null) {
         throw new Exception("(eFEX) Data store name not specified");
      }
      if (cintRecordId == 0) {
         throw new Exception("(eFEX) Data store record identifier not specified");
      }
      
      //
      // Set the record into the data store
      //
      try {
         
         //
         // Build the data store string buffer and byte array
         //
         objBuffer = new StringBuffer();
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            if (objDataValue.getDataValue() == null || objDataValue.getDataValue().equals("")) {
               objBuffer.append(String.valueOf(objDataValue.getDataCode()) + String.valueOf((char)(short)"".length()));
            } else {
               objBuffer.append(String.valueOf(objDataValue.getDataCode()) + String.valueOf((char)(short)objDataValue.getDataValue().length()) + objDataValue.getDataValue());
            }
         }
         objBytes = objBuffer.toString().getBytes("UTF-8");
      
         //
         // Retrieve the record from the data store
         //
         objDataStore = RecordStore.openRecordStore(cstrDataStore, true);
         objDataStore.setRecord(cintRecordId, objBytes, 0, objBytes.length);
         
      } catch(Exception objException) {
         throw new Exception("(eFEX) Data store set record failed - " + objException.getMessage());
      } finally {
         if (objDataStore != null) {
            objDataStore.closeRecordStore();   
         }
         objDataStore = null;
         objDataValue = null;
         objBytes = null;
         objBuffer = null;
      }
      
   }
   
   /**
    * Adds a record into the data store.
    *
    * @param objDataValues the data store record value array
    * @throws Exception the exception message
    */
   protected void addRecord(java.util.Vector objDataValues) throws Exception {
      
      //
      // Local variable declarations
      //
      RecordStore objDataStore = null;
      cDataValue objDataValue = null;
      StringBuffer objBuffer = null;
      byte[] objBytes = null;
      
      //
      // Validate the data store and record identifier
      //
      if (cstrDataStore == null) {
         throw new Exception("(eFEX) Data store name not specified");
      }
      
      //
      // Add the record into the data store
      //
      try {
         
         //
         // Build the data store string buffer and byte array
         //
         objBuffer = new StringBuffer();
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            if (objDataValue.getDataValue() == null || objDataValue.getDataValue().equals("")) {
               objBuffer.append(String.valueOf(objDataValue.getDataCode()) + String.valueOf((char)(short)"".length()));
            } else {
               objBuffer.append(String.valueOf(objDataValue.getDataCode()) + String.valueOf((char)(short)objDataValue.getDataValue().length()) + objDataValue.getDataValue());
            }
         }
         objBytes = objBuffer.toString().getBytes("UTF-8");
      
         //
         // Retrieve the record from the data store
         //
         objDataStore = RecordStore.openRecordStore(cstrDataStore, true);
         objDataStore.addRecord(objBytes, 0, objBytes.length);
         
      } catch(Exception objException) {
         throw new Exception("(eFEX) Data store add record failed - " + objException.getMessage());
      } finally {
         if (objDataStore != null) {
            objDataStore.closeRecordStore();   
         }
         objDataStore = null;
         objDataValue = null;
         objBytes = null;
         objBuffer = null;
      }
      
   }
   
   /**
    * Deletes a record from the data store.
    *
    * @throws Exception the exception message
    */
   protected void deleteRecord() throws Exception {
      
      //
      // Local variable declarations
      //
      RecordStore objDataStore = null;
      
      //
      // Validate the data store and record identifier
      //
      if (cstrDataStore == null) {
         throw new Exception("(eFEX) Data store name not specified");
      }
      if (cintRecordId == 0) {
         throw new Exception("(eFEX) Data store record identifier not specified");
      }
      
      //
      // Delete the record from the data store
      //
      try {
         objDataStore = RecordStore.openRecordStore(cstrDataStore, true);
         objDataStore.deleteRecord(cintRecordId);
      } catch(Exception objException) {
         throw new Exception("(eFEX) Data store delete record failed - " + objException.getMessage());
      } finally {
         if (objDataStore != null) {
            objDataStore.closeRecordStore();   
         }
         objDataStore = null;
      }
      
   }
   
   /**
    * Clear the data store filters
    */
   protected void clearFilters() {
      cobjFilters.removeAllElements();
   }
   
   /**
    * Add data store filter
    *
    * @return String the filter value
    */
   protected void addFilter(char chrField, String strValue) {
      cobjFilters.addElement(new cDataFilter(chrField, strValue));
   }
   
   /**
    * Retrieves a listing from the data store using the requested segment.
    *
    * @param chrSegment the data store record segment to list
    * @param chrComparator the data store record comparator
    * @param chrFields the data store record segment fields
    * @return java.util.Vector the data store list data array
    * @throws Exception the exception message
    */
   protected java.util.Vector getListing(char chrSegment, char chrComparator, char[] chrFields) throws Exception {
      
      //
      // Local variable declarations
      //
      RecordStore objDataStore = null;
      RecordEnumeration objEnumeration = null;
      java.util.Vector objDataValues;
      int intRecordId = 0;
      byte[] objBytes = null;
      String objBuffer = null;
      char chrCode = 0;
      short shrLength = 0;
      int intIndex = 0;
      
      //
      // Validate the data store
      //
      if (cstrDataStore == null) {
         throw new Exception("(eFEX) Data store name not specified");
      }
      
      //
      // Retrieve and parse the data store records 
      //
      objDataValues = new java.util.Vector();
      try {
         objDataStore = RecordStore.openRecordStore(cstrDataStore, true);
         if (cobjFilters.size() == 0) {
            objEnumeration = objDataStore.enumerateRecords(null, new cDataStoreComparator(chrComparator), false);
         } else {
            objEnumeration = objDataStore.enumerateRecords(new cDataStoreFilter("*OR", false), new cDataStoreComparator(chrComparator), false);
         }
         while (objEnumeration.hasNextElement()) {
            intRecordId = objEnumeration.nextRecordId();
            objBytes = objDataStore.getRecord(intRecordId);
            objBuffer = new String(objBytes,0,objBytes.length,"UTF-8");
            intIndex = 0;
            while (intIndex < objBuffer.length()) {
               chrCode = objBuffer.charAt(intIndex);
               intIndex++;
               shrLength = (short)objBuffer.charAt(intIndex);
               intIndex++;
               if (chrCode == chrSegment) {
                  objDataValues.addElement(new cDataValue(chrCode, String.valueOf(intRecordId)));
               } else {
                  for (int i=0; i<chrFields.length; i++) {
                     if (chrCode == chrFields[i]) {
                        if (shrLength <= 0) {
                           objDataValues.addElement(new cDataValue(chrCode, ""));
                        } else {
                           objDataValues.addElement(new cDataValue(chrCode, objBuffer.substring(intIndex, (intIndex + shrLength))));
                        }
                     } 
                  }
               }
               intIndex = intIndex + shrLength;
            } 
         }
         return objDataValues;
      } catch(Exception objException) {
         throw new Exception("(eFEX) Data store listing failed - " + objException.getMessage());
      } finally {
         if (objEnumeration != null) {
            objEnumeration.destroy(); 
         }
         if (objDataStore != null) {
            objDataStore.closeRecordStore();  
         }
         objEnumeration = null;
         objDataStore = null;
         objBytes = null;
         objBuffer = null;
      }
      
   }
   
   /**
    * Searches the data store using the requested segment.
    *
    * @return boolean the search result
    * @throws Exception the exception message
    */
   protected boolean search() throws Exception {
      
      //
      // Local variable declarations
      //
      RecordStore objDataStore = null;
      RecordEnumeration objEnumeration = null;
      boolean bolReturn;
      
      //
      // Validate the data store
      //
      if (cstrDataStore == null) {
         throw new Exception("(eFEX) Data store name not specified");
      }
      
      //
      // Search the data store using the current filters
      //
      bolReturn = false;
      try {
         objDataStore = RecordStore.openRecordStore(cstrDataStore, true);
         objEnumeration = objDataStore.enumerateRecords(new cDataStoreFilter("*AND", true), null, false);
         if (objEnumeration.numRecords() != 0) {
            bolReturn = true;
         }
         return bolReturn;
      } catch(Exception objException) {
         throw new Exception("(eFEX) Data store search failed - " + objException.getMessage());
      } finally {
         if (objEnumeration != null) {
            objEnumeration.destroy(); 
         }
         if (objDataStore != null) {
            objDataStore.closeRecordStore();  
         }
         objEnumeration = null;
         objDataStore = null;
      }
      
   }
   
   /**
    * This class implements the data store comparator.
    */
   class cDataStoreComparator implements RecordComparator {
      
      //
      // Instance private declarations
      //
      private char cchrCode;
      
      /**
       * Constructs a new instance
       */
      public cDataStoreComparator(char chrCode) {
         cchrCode = chrCode;
      }
   
      /**
       * Implements the RecordComparator abstract methods
       */
      public int compare(byte[] bytArray01, byte[] bytArray02) {
         int intReturn = 0;
         String objBuffer;
         char chrCode = 0;
         short shrLength = 0;
         int intIndex = 0;
         String strValue01 = null;
         String strValue02 = null;
         try {
            objBuffer = new String(bytArray01,0,bytArray01.length,"UTF-8");
            intIndex = 0;
            while (intIndex < objBuffer.length()) {
               chrCode = objBuffer.charAt(intIndex);
               intIndex++;
               shrLength = (short)objBuffer.charAt(intIndex);
               intIndex++;
               if (shrLength != 0) {
                  if (chrCode == cchrCode) {
                     strValue01 = objBuffer.substring(intIndex, (intIndex + shrLength));
                     break;
                  }
                  intIndex = intIndex + shrLength;
               }
            }
            objBuffer = new String(bytArray02,0,bytArray02.length,"UTF-8");
            intIndex = 0;
            while (intIndex < objBuffer.length()) {
               chrCode = objBuffer.charAt(intIndex);
               intIndex++;
               shrLength = (short)objBuffer.charAt(intIndex);
               intIndex++;
               if (shrLength != 0) {
                  if (chrCode == cchrCode) {
                     strValue02 = objBuffer.substring(intIndex, (intIndex + shrLength));
                     break;
                  }
                  intIndex = intIndex + shrLength;
               }
            }
         } catch (Exception objException) {}
         intReturn = RecordComparator.EQUIVALENT;
         if (strValue01 != null && strValue02 != null) {
            int intCompare = strValue01.compareTo(strValue02);
            if (intCompare == 0) {
               intReturn = RecordComparator.EQUIVALENT;
            } else if (intCompare < 0) {
               intReturn = RecordComparator.PRECEDES;
            } else {
               intReturn = RecordComparator.FOLLOWS;
            }
         }
         return intReturn; 
      }
      
   }
   
   /**
    * This class implements the data store and filter.
    * Note that this implementation is based on AND logic, that is,
    * all filters must exist to satisfy the search.
    */
   class cDataStoreFilter implements RecordFilter {
      
      //
      // Instance private declarations
      //
      private String cstrTest;
      private boolean cbolFullMatch;
      
      /**
       * Constructs a new instance
       */
      public cDataStoreFilter(String strTest, boolean bolFullMatch) {
         cstrTest = strTest;
         cbolFullMatch = bolFullMatch;
      }

      /**
       * Implements the RecordFilter abstract methods
       */
      public boolean matches(byte[] bytArray) {
         boolean bolReturn = false;
         String objBuffer;
         char chrCode = 0;
         short shrLength = 0;
         int intIndex = 0;
         String strValue = null;
         cDataFilter objDataFilter;
         for (int i=0; i<cobjFilters.size(); i++) {
            ((cDataFilter)cobjFilters.elementAt(i)).setFilterFound(false);
         }
         try {
            objBuffer = new String(bytArray,0,bytArray.length,"UTF-8");
            intIndex = 0;
            while (intIndex < objBuffer.length()) {
               chrCode = objBuffer.charAt(intIndex);
               intIndex++;
               shrLength = (short)objBuffer.charAt(intIndex);
               intIndex++;
               if (shrLength != 0) {
                  strValue = objBuffer.substring(intIndex, (intIndex + shrLength));
                  if (cbolFullMatch) {
                     for (int i=0; i<cobjFilters.size(); i++) {
                        objDataFilter = (cDataFilter)cobjFilters.elementAt(i);
                        if (chrCode == objDataFilter.getFilterCode() &&
                            strValue.equals(objDataFilter.getFilterValue())) {
                           objDataFilter.setFilterFound(true);
                        }
                     }
                  } else {
                     for (int i=0; i<cobjFilters.size(); i++) {
                        objDataFilter = (cDataFilter)cobjFilters.elementAt(i);
                        if (chrCode == objDataFilter.getFilterCode() &&
                            strValue.startsWith(objDataFilter.getFilterValue())) {
                           objDataFilter.setFilterFound(true);
                        }
                     }
                  }
                  intIndex = intIndex + shrLength;
               }
            }
            
         } catch (Exception objException) {}
         if (cstrTest.equals("*AND")) {
            bolReturn = true;
            for (int i=0; i<cobjFilters.size(); i++) {
               if (!((cDataFilter)cobjFilters.elementAt(i)).getFilterFound()) {
                  bolReturn = false;
               }
            }
         } else {
            bolReturn = false;
            for (int i=0; i<cobjFilters.size(); i++) {
               if (((cDataFilter)cobjFilters.elementAt(i)).getFilterFound()) {
                  bolReturn = true;
               }
            }
         }
         return bolReturn; 
      }
      
   }
   
   /**
    * Sorts the supplied vector. The vector elements must extend the
    * abstract cSortable class. This is a simple insertion sort.
    * 
    * @param objVector the Vector to sort
    * @throws Exception the exception message
    */
   protected void sortVector(java.util.Vector objVector) throws Exception {
      for (int i=1; i<objVector.size(); i++) {
         cSortable objSortTemp = (cSortable)objVector.elementAt(i);
         int j = i;
         for (; j>0 && objSortTemp.compareTo(objVector.elementAt(j-1))<0; j--) {
            objVector.setElementAt(objVector.elementAt(j-1), j);
         }
         objVector.setElementAt(objSortTemp, j);
      }
   }
   
   /**
    * Gets the current timestamp
    * 
    * @return String the current timestamp
    * @throws Exception the exception message
    */
   protected String getTimestamp() throws Exception {
      
      //
      // Retrieve and format the current timestamp
      //
      // *TODO* format to fixed format
      java.util.Date objDate = new java.util.Date(System.currentTimeMillis());
      java.util.Calendar objCalendar = java.util.Calendar.getInstance();
      objCalendar.setTime(objDate);
      String strYear = String.valueOf(objCalendar.get(java.util.Calendar.YEAR));
      String strMonth = String.valueOf(objCalendar.get(java.util.Calendar.MONTH)+1);
      String strDay = String.valueOf(objCalendar.get(java.util.Calendar.DATE));
      String strHour = String.valueOf(objCalendar.get(java.util.Calendar.HOUR_OF_DAY));
      String strMinute = String.valueOf(objCalendar.get(java.util.Calendar.MINUTE));
      String strSecond = String.valueOf(objCalendar.get(java.util.Calendar.SECOND));
      return strYear + "/" + strMonth + "/" + strDay + " " + strHour + ":" + strMinute + ":" + strSecond;
        
   }
   
}
