/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cMobileStore
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application mobile object model layer. The
 * object model implements the data mapping between the low level data store and
 * the high level data object model. The MIDlet application always interacts with
 * this data object model.
 */
public final class cMobileStore extends cDataStore {

   //
   // Instance private declarations
   //
   private int cintMobileId;
   private String cstrRecord;
   private String cstrUserName;
   private String cstrLanguage;
   private String cstrServerUrl;
   private String cstrSecure;

   /**
    * Constructs a new instance
    */
   public cMobileStore() {
      super.cstrDataStore = "EfexMobile";
      super.cchrRecord = cMailbox.EFEX_MOB;
      cintMobileId = 0;
      cstrRecord = null;
      cstrUserName = null;
      cstrLanguage = "English";
      cstrServerUrl = null;
      cstrSecure = "1";
   }
   
   /**
    * Loads the mobile data model from the data store
    * 
    * @throws Exception the exception message
    */
   public void loadDataModel() throws Exception {
      
      //
      // Local variable declarations
      //
      java.util.Vector objDataValues;
      cDataValue objDataValue = null;
      
      //
      // Initialise the mobile data model
      //
      cstrRecord = null;
      cstrUserName = null;
      cstrLanguage = null;
      cstrServerUrl = null;
      cstrSecure = null;
      
      //
      // Retrieve the data values from the data store and load the data model
      //
      cintMobileId = 1;
      super.cintRecordId = cintMobileId;
      objDataValues = super.getRecord();
      cintMobileId = 0;
      if(objDataValues != null) {
         cintMobileId = 1;
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            switch (objDataValue.getDataCode()) {

               //
               // Control properties
               //
               case cMailbox.EFEX_MOB: {
                  cstrRecord = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_MOB_USERNAME: {
                  cstrUserName = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_MOB_LANGUAGE: {
                  cstrLanguage = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_MOB_SERVERURL: {
                  cstrServerUrl = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_MOB_SECURE: {
                  cstrSecure = objDataValue.getDataValue();
                  break;
               }
               
               //
               // Unknown properties
               //
               default: {
                  throw new Exception("(eFEX) Mobile store data value code (" + (int)(short)(objDataValue.getDataCode()) + ") NOT RECOGNISED");
               }

            } 
         }
      }
      
   }
   
   /**
    * Saves the mobile data model to the data store
    * 
    * @param strStatus the control status
    * @throws Exception the exception message
    */
   public void saveDataModel() throws Exception {
      
      //
      // Mobile properties
      //
      java.util.Vector objDataValues = new java.util.Vector();
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MOB, cstrRecord));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MOB_USERNAME, cstrUserName));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MOB_LANGUAGE, cstrLanguage));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MOB_SERVERURL, cstrServerUrl));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_MOB_SECURE, cstrSecure));

      //
      // Set the data store record values
      //
      if (cintMobileId == 0) {
         super.addRecord(objDataValues);
      } else {
         super.cintRecordId = cintMobileId;
         super.setRecord(objDataValues);
      }
      
   }
   
   /**
    * Mobile property getters
    */
   public String getUserName() {
      return cstrUserName;
   }
   public String getLanguage() {
      return cstrLanguage;
   }
   public String getServerUrl() {
      return cstrServerUrl;
   }
   public String getSecure() {
      return cstrSecure;
   }
   
   /**
    * Mobile property setters
    */ 
   public void setUserName(String strValue) {
      cstrUserName = strValue;
   }
   public void setLanguage(String strValue) {
      cstrLanguage = strValue;
   }
   public void setServerUrl(String strValue) {
      cstrServerUrl = strValue;
   }
   public void setSecure(String strValue) {
      cstrSecure = strValue;
   }

   /**
    * Clear the data store filters
    */
   public void clearFilters() {
      super.clearFilters();
   }

}
