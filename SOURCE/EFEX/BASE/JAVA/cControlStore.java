/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cControlStore
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application control object model layer. The
 * object model implements the data mapping between the low level data store and
 * the high level data object model. The MIDlet application always interacts with
 * this data object model.
 */
public final class cControlStore extends cDataStore {

   //
   // Instance private declarations
   //
   private int cintControlId;
   private String cstrRecord;
   private String cstrUserFirstName;
   private String cstrUserLastName;
   private String cstrMobileDate;
   private String cstrMobileStatus;
   private String cstrMobileLoadedTime;
   private String cstrMobileSavedTime;

   /**
    * Constructs a new instance
    */
   public cControlStore() {
      super.cstrDataStore = "EfexControl";
      super.cchrRecord = cMailbox.EFEX_CTL;
      cintControlId = 0;
      cstrRecord = null;
      cstrUserFirstName = null;
      cstrUserLastName = null;
      cstrMobileDate = null;
      cstrMobileStatus = null;
      cstrMobileLoadedTime = null;
      cstrMobileSavedTime = null;
   }
   
   /**
    * Loads the data store from the string buffer
    * 
    * @param String the data store string buffer
    * @throws Exception the exception message
    */
   public void loadDataStore(String strBuffer) throws Exception {
      cintControlId = 0;
      super.setDataStore(strBuffer, true);
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
    * Loads the control data model from the data store
    * 
    * @throws Exception the exception message
    */
   public void loadControlModel() throws Exception {
      
      //
      // Local variable declarations
      //
      java.util.Vector objDataValues;
      cDataValue objDataValue = null;
      
      //
      // Initialise the control data model
      //
      cstrRecord = null;
      cstrUserFirstName = null;
      cstrUserLastName = null;
      cstrMobileDate = null;
      cstrMobileStatus = null;
      cstrMobileLoadedTime = null;
      cstrMobileSavedTime = null;
      
      //
      // Retrieve the data values from the data store and load the data model
      //
      cintControlId = 1;
      super.cintRecordId = cintControlId;
      objDataValues = super.getRecord();
      if(objDataValues != null) {
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            switch (objDataValue.getDataCode()) {

               //
               // Control properties
               //
               case cMailbox.EFEX_CTL: {
                  cstrRecord = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CTL_USER_FIRSTNAME: {
                  cstrUserFirstName = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CTL_USER_LASTNAME: {
                  cstrUserLastName = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CTL_MOBILE_DATE: {
                  cstrMobileDate = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CTL_MOBILE_STATUS: {
                  cstrMobileStatus = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CTL_MOBILE_LOADED_TIME: {
                  cstrMobileLoadedTime = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CTL_MOBILE_SAVED_TIME: {
                  cstrMobileSavedTime = objDataValue.getDataValue();
                  break;
               }

               //
               // Unknown properties
               //
               default: {
                  throw new Exception("(eFEX) Control store data value code (" + (int)(short)(objDataValue.getDataCode()) + ") NOT RECOGNISED");
               }

            } 
         }
      }
      
   }
   
   /**
    * Saves the control data model to the data store
    * 
    * @param strStatus the control status
    * @throws Exception the exception message
    */
   public void saveControlModel(String strMobileStatus) throws Exception {
      
      //
      // Control properties
      //
      cstrMobileStatus = strMobileStatus;
      if (cstrMobileStatus.toUpperCase().equals("*SAVED")) {
         cstrMobileSavedTime = getTimestamp();
      }
      java.util.Vector objDataValues = new java.util.Vector();
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CTL, cstrRecord));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CTL_USER_FIRSTNAME, cstrUserFirstName));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CTL_USER_LASTNAME, cstrUserLastName));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CTL_MOBILE_DATE, cstrMobileDate));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CTL_MOBILE_STATUS, cstrMobileStatus));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CTL_MOBILE_LOADED_TIME, cstrMobileLoadedTime));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CTL_MOBILE_SAVED_TIME, cstrMobileSavedTime));

      //
      // Set the data store record values
      //
      super.cintRecordId = cintControlId;
      super.setRecord(objDataValues);

   }
   
   /**
    * Control property getters
    */
   public String getUserFirstName() {
      return cstrUserFirstName;
   }
   public String getUserLastName() {
      return cstrUserLastName;
   }
   public String getMobileDate() {
      return cstrMobileDate;
   }
   public String getMobileStatus() {
      return cstrMobileStatus;
   }
   public String getMobileLoadedTime() {
      return cstrMobileLoadedTime;
   }
   public String getMobileSavedTime() {
      return cstrMobileSavedTime;
   }

   /**
    * Clear the data store filters
    */
   public void clearFilters() {
      super.clearFilters();
   }

}
