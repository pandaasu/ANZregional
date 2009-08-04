/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cCustomerStore
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application customer object model layer. The
 * object model implements the data mapping between the low level data store and
 * the high level data object model. The MIDlet application always interacts with
 * this data object model.
 */
public final class cCustomerStore extends cDataStore {
   
   //
   // Instance private declarations
   //
   private int cintCustomerThis;
   private String cstrRecord;
   private String cstrCustomerDataType;
   private String cstrCustomerDataAction;
   private String cstrCustomerId;
   private String cstrCustomerCode;
   private String cstrCustomerName;
   private String cstrCustomerStatus;
   private String cstrCustomerAddress;
   private String cstrCustomerContactName;
   private String cstrCustomerPhoneNumber;
   private String cstrCustomerTypeId;
   private String cstrCustomerOutletLocation;
   private String cstrCustomerDistributorId;
   private String cstrCustomerPostcode;
   private String cstrCustomerFaxNumber;
   private String cstrCustomerEmailAddress;
   private int cintCustomerNext;
   
   /**
    * Constructs a new instance
    */
   public cCustomerStore() {
      super.cstrDataStore = "EfexCustomer";
      super.cchrRecord = cMailbox.EFEX_CUS;
      cintCustomerThis = 0;
      cstrRecord = null;
      cstrCustomerDataType = null;
      cstrCustomerDataAction = null;
      cstrCustomerId = null;
      cstrCustomerCode = null;
      cstrCustomerName = null;
      cstrCustomerStatus = null;
      cstrCustomerAddress = null;
      cstrCustomerContactName = null;
      cstrCustomerPhoneNumber = null;
      cstrCustomerTypeId = null;
      cstrCustomerOutletLocation = null;
      cstrCustomerDistributorId = null;
      cstrCustomerPostcode = null;
      cstrCustomerFaxNumber = null;
      cstrCustomerEmailAddress = null;
      cintCustomerNext = 0;
   }
   
   /**
    * Loads the data store from the string buffer
    * 
    * @param String the data store string buffer
    * @throws Exception the exception message
    */
   public void loadDataStore(String objBuffer) throws Exception {
      cintCustomerThis = 0;
      cintCustomerNext = 0;
      super.cintRecordId = cintCustomerThis;
      super.setDataStore(objBuffer, true);
   }
   
   /**
    * Appends to the data store from the string buffer
    * 
    * @param String the data store string buffer
    * @throws Exception the exception message
    */
   public void appendDataStore(String objBuffer) throws Exception {
      cintCustomerThis = 0;
      super.cintRecordId = cintCustomerThis;
      super.setDataStore(objBuffer, false);
      cintCustomerThis = super.cintRecordId;
   }
   
   /**
    * Updates to the data store from the string buffer
    * 
    * @param intRecordId the data store record identifier
    * @param String the data store string buffer
    * @throws Exception the exception message
    */
   public void updateDataStore(int intRecordId, String objBuffer) throws Exception {
      cintCustomerThis = intRecordId;
      super.cintRecordId = cintCustomerThis;
      super.setDataStore(objBuffer, false);
   }
   
   /**
    * Saves the data store to the string buffer
    * 
    * @return String the data store string buffer
    * @throws Exception the exception message
    */
   public String saveDataStore() throws Exception {
      super.clearFilters();
      super.addFilter(cMailbox.EFEX_CUS_DATA_ACTION, "*EDITED");
      return super.getDataStore();
   }
   
   /**
    * Loads the customer data model from the data store
    * 
    * @param intRecordId the data store record identifier
    * @throws Exception the exception message
    */
   public void loadCustomerModel(int intRecordId) throws Exception {
      
      //
      // Local variable declarations
      //
      java.util.Vector objDataValues;
      cDataValue objDataValue = null;
      
      //
      // Initialise the data model
      //
      cstrRecord = null;
      cstrCustomerDataType = null;
      cstrCustomerDataAction = null;
      cstrCustomerId = null;
      cstrCustomerCode = null;
      cstrCustomerName = null;
      cstrCustomerStatus = null;
      cstrCustomerAddress = null;
      cstrCustomerContactName = null;
      cstrCustomerPhoneNumber = null;
      cstrCustomerTypeId = null;
      cstrCustomerOutletLocation = null;
      cstrCustomerDistributorId = null;
      cstrCustomerPostcode = null;
      cstrCustomerFaxNumber = null;
      cstrCustomerEmailAddress = null;
      
      //
      // Retrieve the data values from the data store and load the data model
      //
      cintCustomerThis = intRecordId;
      super.cintRecordId = cintCustomerThis;
      objDataValues = super.getRecord();
      if(objDataValues == null) {
         cintCustomerThis = 0;
      } else {
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            switch (objDataValue.getDataCode()) {

               //
               // Customer properties
               //
               case cMailbox.EFEX_CUS: {
                  cstrRecord = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_DATA_TYPE: {
                  cstrCustomerDataType = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_DATA_ACTION: {
                  cstrCustomerDataAction = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_CUSTOMER_ID: {
                  cstrCustomerId = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_CODE: {
                  cstrCustomerCode = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_NAME: {
                  cstrCustomerName = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_STATUS: {
                  cstrCustomerStatus = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_ADDRESS: {
                  cstrCustomerAddress = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_CONTACT_NAME: {
                  cstrCustomerContactName = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_PHONE_NUMBER: {
                  cstrCustomerPhoneNumber = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_CUS_TYPE_ID: {
                  cstrCustomerTypeId = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_OUTLET_LOCATION: {
                  cstrCustomerOutletLocation = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_DISTRIBUTOR_ID: {
                  cstrCustomerDistributorId = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_POSTCODE: {
                  cstrCustomerPostcode = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_FAX_NUMBER: {
                  cstrCustomerFaxNumber = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_CUS_EMAIL_ADDRESS: {
                  cstrCustomerEmailAddress = objDataValue.getDataValue();
                  break;
               }

               //
               // Unknown properties
               //
               default: {
                  throw new Exception("(eFEX) Customer store data value code (" + (int)(short)(objDataValue.getDataCode()) + ") NOT RECOGNISED");
               }

            } 
         }
      }
      
   }
   
   /**
    * Saves the customer data model to the data store
    * 
    * @throws Exception the exception message
    */
   public void saveCustomerModel() throws Exception {

      //
      // Customer properties
      //
      cstrCustomerDataAction = "*EDITED";
      java.util.Vector objDataValues = new java.util.Vector();
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS, cstrRecord));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_DATA_TYPE, cstrCustomerDataType));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_DATA_ACTION, cstrCustomerDataAction));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_CUSTOMER_ID, cstrCustomerId));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_CODE, cstrCustomerCode));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_NAME, cstrCustomerName));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_STATUS, cstrCustomerStatus));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_ADDRESS, cstrCustomerAddress));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_CONTACT_NAME, cstrCustomerContactName));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_PHONE_NUMBER, cstrCustomerPhoneNumber));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_CUS_TYPE_ID, cstrCustomerTypeId));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_OUTLET_LOCATION, cstrCustomerOutletLocation));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_DISTRIBUTOR_ID, cstrCustomerDistributorId));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_POSTCODE, cstrCustomerPostcode));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_FAX_NUMBER, cstrCustomerFaxNumber));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_EMAIL_ADDRESS, cstrCustomerEmailAddress));
      
      //
      // Set the data store record values
      //
      super.cintRecordId = cintCustomerThis;
      super.setRecord(objDataValues);
      
      //
      // Release the customer
      //
      cintCustomerThis = 0;
        
   }
   
   /**
    * Clears the customer data model
    */
   public void clearCustomerModel() {
      cintCustomerThis = 0;
      cstrRecord = null;
      cstrCustomerDataType = null;
      cstrCustomerDataAction = null;
      cstrCustomerId = null;
      cstrCustomerCode = null;
      cstrCustomerName = null;
      cstrCustomerStatus = null;
      cstrCustomerAddress = null;
      cstrCustomerContactName = null;
      cstrCustomerPhoneNumber = null;
      cstrCustomerTypeId = null;
      cstrCustomerOutletLocation = null;
      cstrCustomerDistributorId = null;
      cstrCustomerPostcode = null;
      cstrCustomerFaxNumber = null;
      cstrCustomerEmailAddress = null;
   }
   
   /**
    * Adds the customer data model to the data store
    * 
    * @throws Exception the exception message
    */
   public void addCustomerModel() throws Exception {
       
      //
      // Customer properties
      //
      cintCustomerNext++;
      cstrCustomerDataType = "*NEW";
      cstrCustomerDataAction = "*EDITED";
      cstrCustomerId = "NEW" + new Integer(cintCustomerNext).toString();
      java.util.Vector objDataValues = new java.util.Vector();
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS, cstrRecord));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_DATA_TYPE, cstrCustomerDataType));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_DATA_ACTION, cstrCustomerDataAction));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_CUSTOMER_ID, cstrCustomerId));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_CODE, cstrCustomerCode));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_NAME, cstrCustomerName));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_STATUS, cstrCustomerStatus));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_ADDRESS, cstrCustomerAddress));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_CONTACT_NAME, cstrCustomerContactName));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_PHONE_NUMBER, cstrCustomerPhoneNumber));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_CUS_TYPE_ID, cstrCustomerTypeId));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_OUTLET_LOCATION, cstrCustomerOutletLocation));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_DISTRIBUTOR_ID, cstrCustomerDistributorId));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_POSTCODE, cstrCustomerPostcode));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_FAX_NUMBER, cstrCustomerFaxNumber));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_CUS_EMAIL_ADDRESS, cstrCustomerEmailAddress));
      
      //
      // Add the data store record values
      //
      super.addRecord(objDataValues);
      
      //
      // Release the customer
      //
      cintCustomerThis = 0;
        
   }
   
   /**
    * Validates the customer data model
    * 
    * @return java.util.Vector the message array
    * @throws Exception the exception message
    */
   public java.util.Vector validateCustomerModel(cResourceBundle objResourceBundle) throws Exception {
      java.util.Vector objMessages = new java.util.Vector();
      if (cstrCustomerStatus == null || (!cstrCustomerStatus.equals("X") && !cstrCustomerStatus.equals("A"))) {
         objMessages.addElement(objResourceBundle.getResource("CUSVAL001"));
      }
      if (cstrCustomerStatus != null && cstrCustomerStatus.equals("A")) {
         if (cstrCustomerName == null || cstrCustomerName.equals("")) {
            objMessages.addElement(objResourceBundle.getResource("CUSVAL002"));
         }
         if (cstrCustomerAddress == null || cstrCustomerAddress.equals("")) {
            objMessages.addElement(objResourceBundle.getResource("CUSVAL003"));
         }
         if (cstrCustomerContactName == null || cstrCustomerContactName.equals("")) {
            objMessages.addElement(objResourceBundle.getResource("CUSVAL004"));
         }
         if (cstrCustomerPhoneNumber == null || cstrCustomerPhoneNumber.equals("")) {
            objMessages.addElement(objResourceBundle.getResource("CUSVAL005"));
         }
         if (cstrCustomerTypeId == null || cstrCustomerTypeId.equals("")) {
            objMessages.addElement(objResourceBundle.getResource("CUSVAL006"));
         }
         if (cstrCustomerOutletLocation == null || cstrCustomerOutletLocation.equals("")) {
            objMessages.addElement(objResourceBundle.getResource("CUSVAL007"));
         }
         if (cstrCustomerDistributorId == null || cstrCustomerDistributorId.equals("")) {
            objMessages.addElement(objResourceBundle.getResource("CUSVAL008"));
         }
      }
      return objMessages;
   }
   
   /**
    * Gets the customer data list from the data store
    * 
    * @return java.util.Vector the customer listing
    * @throws Exception the exception message
    */
   public java.util.Vector getCustomerList() throws Exception {
      
      //
      // Local variable declarations
      //
      java.util.Vector objCustomerList;
      char[] chrListFields;
      java.util.Vector objDataValues;
      cDataValue objDataValue = null;
      Object objObject = null;
      
      //
      // Retrieve the data values from the data store and load the data model
      //
      objCustomerList = new java.util.Vector();
      chrListFields = new char[] {cMailbox.EFEX_CUS_DATA_TYPE, cMailbox.EFEX_CUS_DATA_ACTION, cMailbox.EFEX_CUS_STATUS, cMailbox.EFEX_CUS_CUSTOMER_ID, cMailbox.EFEX_CUS_CODE, cMailbox.EFEX_CUS_NAME};
      objDataValues = super.getListing(cMailbox.EFEX_CUS, cMailbox.EFEX_CUS_NAME, chrListFields);
      if(objDataValues != null) {
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            switch (objDataValue.getDataCode()) {

               //
               // Customer properties
               //
               case cMailbox.EFEX_CUS: {
                  objObject = new cCustomerList(Integer.parseInt(objDataValue.getDataValue()));
                  objCustomerList.addElement(objObject);
                  break;
               }
               case cMailbox.EFEX_CUS_DATA_TYPE: {
                  ((cCustomerList)objObject).setDataType(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_CUS_DATA_ACTION: {
                  ((cCustomerList)objObject).setDataAction(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_CUS_STATUS: {
                  ((cCustomerList)objObject).setStatus(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_CUS_CUSTOMER_ID: {
                  ((cCustomerList)objObject).setCustomerId(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_CUS_CODE: {
                  ((cCustomerList)objObject).setCode(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_CUS_NAME: {
                  ((cCustomerList)objObject).setName(objDataValue.getDataValue());
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
      sortVector(objCustomerList);
      return objCustomerList;
      
   }
   
   /**
    * Customer property getters
    */
   public int getCustomerThis() {
      return cintCustomerThis;
   }
   public String getCustomerDataType() {
      return cstrCustomerDataType;
   }
   public String getCustomerDataAction() {
      return cstrCustomerDataAction;
   }
   public String getCustomerId() {
      return cstrCustomerId;
   }
   public String getCustomerCode() {
      return cstrCustomerCode;
   }
   public String getCustomerName() {
      return cstrCustomerName;
   }
   public String getCustomerStatus() {
      return cstrCustomerStatus;
   }
   public String getCustomerAddress() {
      return cstrCustomerAddress;
   }
   public String getCustomerContactName() {
      return cstrCustomerContactName;
   }
   public String getCustomerPhoneNumber() {
      return cstrCustomerPhoneNumber;
   }
   public String getCustomerTypeId() {
      return cstrCustomerTypeId;
   }
   public String getCustomerOutletLocation() {
      return cstrCustomerOutletLocation;
   }
   public String getCustomerDistributorId() {
      return cstrCustomerDistributorId;
   }
   public String getCustomerPostcode() {
      return cstrCustomerPostcode;
   }
   public String getCustomerFaxNumber() {
      return cstrCustomerFaxNumber;
   }
   public String getCustomerEmailAddress() {
      return cstrCustomerEmailAddress;
   }
   
   /**
    * Customer property setters
    */ 
   public void setCustomerCode(String strValue) {
      cstrCustomerCode = strValue;
   }
   public void setCustomerName(String strValue) {
      cstrCustomerName = strValue;
   }
   public void setCustomerStatus(String strValue) {
      cstrCustomerStatus = strValue;
   }
   public void setCustomerAddress(String strValue) {
      cstrCustomerAddress = strValue;
   }
   public void setCustomerContactName(String strValue) {
      cstrCustomerContactName = strValue;
   }
   public void setCustomerPhoneNumber(String strValue) {
      cstrCustomerPhoneNumber = strValue;
   }
   public void setCustomerTypeId(String strValue) {
      cstrCustomerTypeId = strValue;
   }
   public void setCustomerOutletLocation(String strValue) {
      cstrCustomerOutletLocation = strValue;
   }
   public void setCustomerDistributorId(String strValue) {
      cstrCustomerDistributorId = strValue;
   }
   public void setCustomerPostcode(String strValue) {
      cstrCustomerPostcode = strValue;
   }
   public void setCustomerFaxNumber(String strValue) {
      cstrCustomerFaxNumber = strValue;
   }
   public void setCustomerEmailAddress(String strValue) {
      cstrCustomerEmailAddress = strValue;
   }
   
   /**
    * Clear the data store filters
    */
   public void clearFilters() {
      super.clearFilters();
   }
   
   /**
    * Add customer id filter
    *
    * @param String the customer id
    */
   public void addCustomerIdFilter(String strId) {
      super.addFilter(cMailbox.EFEX_CUS_CUSTOMER_ID, strId);
   }
   
   /**
    * Add customer code filter
    *
    * @param String the customer code
    */
   public void addCustomerCodeFilter(String strCode) {
      super.addFilter(cMailbox.EFEX_CUS_CODE, strCode);
   }
   
   /**
    * Add customer name filter
    *
    * @param String the customer name
    */
   public void addCustomerNameFilter(String strName) {
      super.addFilter(cMailbox.EFEX_CUS_NAME, strName);
   }
   
}
