/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cMessageStore
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;
import java.util.*;

/**
 * This class implements the Efex application message object model layer. The
 * object model implements the data mapping between the low level data store and
 * the high level data object model. The MIDlet application always interacts with
 * this data object model.
 */
public final class cMessageStore extends cDataStore {
    
   //
   // Instance private declarations
   //
   private int cintMessageId;
   private String cstrRecord;
   private String cstrMessageMessageId;
   private String cstrMessageOwner;
   private String cstrMessageTitle;
   private String cstrMessageText;
   private String cstrMessageStatus;
   
   /**
    * Constructs a new instance
    */
   public cMessageStore() {
      super.cstrDataStore = "EfexMessage";
      super.cchrRecord = cMailbox.EFEX_MSG;
      cintMessageId = 0;
      cstrRecord = null;
      cstrMessageMessageId = null;
      cstrMessageOwner = null;
      cstrMessageTitle = null;
      cstrMessageText = null;
      cstrMessageStatus = null;
   }
   
   /**
    * Loads the data store from the string buffer
    * 
    * @param String the data store string buffer
    * @throws Exception the exception message
    */
   public void loadDataStore(String objBuffer) throws Exception {
      super.clearFilters();
      java.util.Vector objOldMessageList = getMessageList();
      cintMessageId = 0;
      super.setDataStore(objBuffer, true);
      java.util.Vector objNewMessageList = getMessageList();
      for (int i=0; i<objNewMessageList.size(); i++) {
         for (int j=0; j<objOldMessageList.size(); j++) {
            if (((cMessageList)objNewMessageList.elementAt(i)).getMessageId().equals(((cMessageList)objOldMessageList.elementAt(j)).getMessageId())) {
               loadMessageModel(((cMessageList)objNewMessageList.elementAt(i)).getRecordId());
               setMessageStatus(((cMessageList)objOldMessageList.elementAt(j)).getStatus());
               saveMessageModel();
            }
         }
      }
      objOldMessageList = null;
      objNewMessageList = null;
   }
   
   /**
    * Saves the data store to the string buffer
    * 
    * @return String the data store string buffer
    * @throws Exception the exception message
    */
   public String saveDataStore() throws Exception {
      return super.getDataStore();
   }
   
   /**
    * Loads the message data model from the data store
    * 
    * @param intRecordId the data store record identifier
    * @throws Exception the exception message
    */
   public void loadMessageModel(int intRecordId) throws Exception {
      
      //
      // Local variable declarations
      //
      java.util.Vector objDataValues;
      cDataValue objDataValue = null;
      
      //
      // Initialise the data model
      //
      cstrRecord = null;
      cstrMessageMessageId = null;
      cstrMessageOwner = null;
      cstrMessageTitle = null;
      cstrMessageText = null;
      cstrMessageStatus = "0";
      
      //
      // Retrieve the data values from the data store and load the data model
      //
      cintMessageId = intRecordId;
      super.cintRecordId = cintMessageId;
      objDataValues = super.getRecord();
      if(objDataValues == null) {
         cintMessageId = 0;
      } else {
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            switch (objDataValue.getDataCode()) {

               //
               // Message properties
               //
               case cMailbox.EFEX_MSG: {
                  cstrRecord = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_MSG_ID: {
                  cstrMessageMessageId = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_MSG_OWNER: {
                  cstrMessageOwner = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_MSG_TITLE: {
                  cstrMessageTitle = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_MSG_TEXT: {
                  cstrMessageText = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_MSG_STATUS: {
                  cstrMessageStatus = objDataValue.getDataValue();
                  break;
               }

               //
               // Unknown properties
               //
               default: {
                  throw new Exception("(eFEX) Message store data value code (" + (int)(short)(objDataValue.getDataCode()) + ") NOT RECOGNISED");
               }

            } 
         }
      }
      
   }
   
   /**
    * Saves the message data model to the data store
    * 
    * @throws Exception the exception message
    */
   public void saveMessageModel() throws Exception {
    
      //
      // Customer properties
      //
      java.util.Vector objDataValues = new java.util.Vector();
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MSG, cstrRecord));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MSG_ID, cstrMessageMessageId));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MSG_OWNER, cstrMessageOwner));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MSG_TITLE, cstrMessageTitle));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MSG_TEXT, cstrMessageText));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MSG_STATUS, cstrMessageStatus));
      
      //
      // Set the data store record values
      //
      super.cintRecordId = cintMessageId;
      super.setRecord(objDataValues);
      
      //
      // Release the message
      //
      cintMessageId = 0;
        
   }
   
   /**
    * Gets the message data list from the data store
    * 
    * @return java.util.Vector the customer listing
    * @throws Exception the exception message
    */
   public java.util.Vector getMessageList() throws Exception {
      
      //
      // Local variable declarations
      //
      java.util.Vector objMessageList;
      char[] chrListFields;
      java.util.Vector objDataValues;
      cDataValue objDataValue = null;
      Object objObject = null;
      
      //
      // Retrieve the data values from the data store and load the data model
      //
      objMessageList = new java.util.Vector();
      chrListFields = new char[] {cMailbox.EFEX_MSG_ID, cMailbox.EFEX_MSG_OWNER, cMailbox.EFEX_MSG_TITLE, cMailbox.EFEX_MSG_STATUS};
      objDataValues = super.getListing(cMailbox.EFEX_MSG, cMailbox.EFEX_MSG_OWNER, chrListFields);
      if(objDataValues != null) {
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            switch (objDataValue.getDataCode()) {

               //
               // Message properties
               //
               case cMailbox.EFEX_MSG: {
                  objObject = new cMessageList(Integer.parseInt(objDataValue.getDataValue()));
                  objMessageList.addElement(objObject);
                  break;
               }
               case cMailbox.EFEX_MSG_ID: {
                  ((cMessageList)objObject).setMessageId(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_MSG_OWNER: {
                  ((cMessageList)objObject).setOwner(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_MSG_TITLE: {
                  ((cMessageList)objObject).setTitle(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_MSG_STATUS: {
                  ((cMessageList)objObject).setStatus(objDataValue.getDataValue());
                  break;
               }

               //
               // Not required properties
               //
               default: {
                  break;
               }

            } 
         }
      }
      sortVector(objMessageList);
      return objMessageList;
      
   }
   
   /**
    * Message property getters
    */
   public int getMessageId() {
      return cintMessageId;
   }
   public String getMessageMessageId() {
      return cstrMessageMessageId;
   }
   public String getMessageOwner() {
      return cstrMessageOwner;
   }
   public String getMessageTitle() {
      return cstrMessageTitle;
   }
   public String getMessageText() {
      return cstrMessageText;
   }
   public String getMessageStatus() {
      return cstrMessageStatus;
   }
   
   /**
    * Message property setters
    */
   public void setMessageStatus(String strValue) {
       cstrMessageStatus = strValue;
   }
   public void setMessageRead() {
      cstrMessageStatus = "1";
   }
   
   /**
    * Clear the data store filters
    */
   public void clearFilters() {
      super.clearFilters();
   }
   
}
