/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cRouteStore
 * Author  : Steve Gregan
 * Date    : April 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application route object model layer. The
 * object model implements the data mapping between the low level data store and
 * the high level data object model. The MIDlet application always interacts with
 * this data object model.
 */
public final class cRouteStore extends cDataStore {
   
   //
   // Instance private declarations
   //
   private int cintCallId;
   private String cstrRecord;
   private String cstrCallSequence;
   private String cstrCallCustomerId;
   private String cstrCallCustomerCode;
   private String cstrCallCustomerName;
   private String cstrCallCustomerType;
   private String cstrCallMarket;
   private String cstrCallStatus;
   private String cstrCallStartTime;
   private String cstrCallDate;
   private String cstrCallEndTime;
   private String cstrCallOrderSend;
   private String cstrCallStockDistributionCount;
   private java.util.Vector cobjCallStocks;
   private java.util.Vector cobjCallOrders;
   private java.util.Vector cobjCallDisplays;
   private java.util.Vector cobjCallActivities;
   
   /**
    * Constructs a new instance
    */
   public cRouteStore() {
      super.cstrDataStore = "EfexRoute";
      super.cchrRecord = cMailbox.EFEX_RTE_CALL;
      cintCallId = 0;
      cstrRecord = null;
      cstrCallSequence = null;
      cstrCallCustomerId = null;
      cstrCallCustomerCode = null;
      cstrCallCustomerName = null;
      cstrCallCustomerType = null;
      cstrCallMarket = null;
      cstrCallStatus = null;
      cstrCallDate = null;
      cstrCallStartTime = null;
      cstrCallEndTime = null;
      cstrCallOrderSend = null;
      cstrCallStockDistributionCount = null;
      cobjCallStocks = new java.util.Vector();
      cobjCallOrders = new java.util.Vector();
      cobjCallDisplays = new java.util.Vector();
      cobjCallActivities = new java.util.Vector();
   }
   
   /**
    * Loads the data store from the string buffer
    * 
    * @param String the data store string buffer
    * @throws Exception the exception message
    */
   public void loadDataStore(String objBuffer) throws Exception {
      cintCallId = 0;
      super.setDataStore(objBuffer, true);
   }
   
   /**
    * Appends to the data store from the string buffer
    * 
    * @param String the data store string buffer
    * @throws Exception the exception message
    */
   public void appendDataStore(String objBuffer) throws Exception {
      cintCallId = 0;
      super.cintRecordId = cintCallId;
      super.setDataStore(objBuffer, false);
      cintCallId = super.cintRecordId;
   }
   
   /**
    * Saves the data store to the string buffer
    * 
    * @return String the data store string buffer
    * @throws Exception the exception message
    */
   public String saveDataStore() throws Exception {
      super.clearFilters();
      super.addFilter(cMailbox.EFEX_RTE_CALL_STATUS, "1");
      return super.getDataStore();
   }
   
   /**
    * Loads the call data model from the data store
    * 
    * @param intRecordId the data store record identifier
    * @throws Exception the exception message
    */
   public void loadCallModel(int intRecordId) throws Exception {
      
      //
      // Local variable declarations
      //
      java.util.Vector objDataValues;
      cDataValue objDataValue = null;
      Object objObject = null;
      
      //
      // Initialise the data model
      //
      cstrRecord = null;
      cstrCallSequence = null;
      cstrCallCustomerId = null;
      cstrCallCustomerCode = null;
      cstrCallCustomerName = null;
      cstrCallCustomerType = "*ROUTE";
      cstrCallMarket = "ICSF";
      cstrCallStatus = "0";
      cstrCallDate = null;
      cstrCallStartTime = null;
      cstrCallEndTime = null;
      cstrCallOrderSend = "0";
      cstrCallStockDistributionCount = "0";
      cobjCallStocks.removeAllElements();
      cobjCallOrders.removeAllElements();
      cobjCallDisplays.removeAllElements();
      cobjCallActivities.removeAllElements();
      
      //
      // Retrieve the data values from the data store and load the data model
      //
      cintCallId = intRecordId;
      super.cintRecordId = cintCallId;
      objDataValues = super.getRecord();
      if(objDataValues == null) {
         cintCallId = 0;
      } else {
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            switch (objDataValue.getDataCode()) {

               //
               // Call properties
               //
               case cMailbox.EFEX_RTE_CALL: {
                  cstrRecord = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_SEQUENCE: {
                  cstrCallSequence = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_CUSTOMER_ID: {
                  cstrCallCustomerId = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_CUSTOMER_CODE: {
                  cstrCallCustomerCode = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_CUSTOMER_NAME: {
                  cstrCallCustomerName = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_CUSTOMER_TYPE: {
                  cstrCallCustomerType = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_MARKET: {
                  cstrCallMarket = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_STATUS: {
                  cstrCallStatus = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_DATE: {
                  cstrCallDate = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_STR_TIME: {
                  cstrCallStartTime = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_END_TIME: {
                  cstrCallEndTime = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_ORDER_SEND: {
                  cstrCallOrderSend = objDataValue.getDataValue();
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_STOCK_DIST_COUNT: {
                  cstrCallStockDistributionCount = objDataValue.getDataValue();
                  break;
               }

               //
               // Customer stock properties
               //
               case cMailbox.EFEX_RTE_STCK_ITEM: {
                  objObject = new cRouteStock();
                  cobjCallStocks.addElement(objObject);
                  break;
               }
               case cMailbox.EFEX_RTE_STCK_ITEM_ID: {
                  ((cRouteStock)objObject).setId(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_STCK_ITEM_NAME: {
                  ((cRouteStock)objObject).setName(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_STCK_ITEM_REQUIRED: {
                  ((cRouteStock)objObject).setRequired(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_STCK_ITEM_QTY: {
                  ((cRouteStock)objObject).setStockQty(objDataValue.getDataValue());
                  break;
               }
               
               //
               // Customer order properties
               //
               case cMailbox.EFEX_RTE_ORDR_ITEM: {
                  objObject = new cRouteOrder();
                  cobjCallOrders.addElement(objObject);
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_ID: {
                  ((cRouteOrder)objObject).setId(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_NAME: {
                  ((cRouteOrder)objObject).setName(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_PRICE_TDU: {
                  ((cRouteOrder)objObject).setPriceTDU(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_PRICE_MCU: {
                  ((cRouteOrder)objObject).setPriceMCU(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_PRICE_RSU: {
                  ((cRouteOrder)objObject).setPriceRSU(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_BRAND: {
                  ((cRouteOrder)objObject).setBrand(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_PACKSIZE: {
                  ((cRouteOrder)objObject).setPacksize(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_REQUIRED: {
                  ((cRouteOrder)objObject).setRequired(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_UOM: {
                  ((cRouteOrder)objObject).setOrderUom(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_QTY: {
                  ((cRouteOrder)objObject).setOrderQty(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ORDR_ITEM_VALUE: {
                  ((cRouteOrder)objObject).setOrderValue(objDataValue.getDataValue());
                  break;
               }

               //
               // Customer display properties
               //
               case cMailbox.EFEX_RTE_DISP_ITEM: {
                  objObject = new cRouteDisplay();
                  cobjCallDisplays.addElement(objObject);
                  break;
               }
               case cMailbox.EFEX_RTE_DISP_ITEM_ID: {
                  ((cRouteDisplay)objObject).setId(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_DISP_ITEM_NAME: {
                  ((cRouteDisplay)objObject).setName(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_DISP_ITEM_FLAG: {
                  ((cRouteDisplay)objObject).setFlag(objDataValue.getDataValue());
                  break;
               }

               //
               // Customer activity properties
               //
               case cMailbox.EFEX_RTE_ACTV_ITEM: {
                  objObject = new cRouteActivity();
                  cobjCallActivities.addElement(objObject);
                  break;
               }
               case cMailbox.EFEX_RTE_ACTV_ITEM_ID: {
                  ((cRouteActivity)objObject).setId(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ACTV_ITEM_NAME: {
                  ((cRouteActivity)objObject).setName(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_ACTV_ITEM_FLAG: {
                  ((cRouteActivity)objObject).setFlag(objDataValue.getDataValue());
                  break;
               }

               //
               // Unknown properties
               //
               default: {
                  throw new Exception("(eFEX) Route store data value code (" + (int)(short)(objDataValue.getDataCode()) + ") NOT RECOGNISED");
               }

            } 
         }
      }
      
      //
      // Set the call start time when required
      //
      if (cstrCallStartTime == null || cstrCallStartTime.equals("") || cstrCallStartTime.equals("*NONE")) {
         cstrCallStartTime = getTimestamp();
      }
      
      //
      // Set the call stock selected indicator
      //
      for (int i=0; i<cobjCallStocks.size(); i++) {
         if (((cRouteStock)cobjCallStocks.elementAt(i)).getRequired().equals("Y")) {
            ((cRouteStock)cobjCallStocks.elementAt(i)).setStockSelected(true);
         }
      }
      
      //
      // Set the call order selected indicator
      //
      for (int i=0; i<cobjCallOrders.size(); i++) {
         if (((cRouteOrder)cobjCallOrders.elementAt(i)).getRequired().equals("Y") ||
             !((cRouteOrder)cobjCallOrders.elementAt(i)).getOrderQty().equals("0")) {
            ((cRouteOrder)cobjCallOrders.elementAt(i)).setOrderSelected(true);
         }
      }

      //
      // Sort the call data
      //
      sortVector(cobjCallDisplays);
      sortVector(cobjCallActivities);
      sortVector(cobjCallOrders);
      
   }
   
   /**
    * Saves the call data model to the data store
    * 
    * @throws Exception the exception message
    */
   public void saveCallModel() throws Exception {
      
      //
      // Set the call end time
      //
      cstrCallEndTime = getTimestamp();

      //
      // Call properties
      //
      java.util.Vector objDataValues = new java.util.Vector();
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL, cstrRecord));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_SEQUENCE, cstrCallSequence));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_CUSTOMER_ID, cstrCallCustomerId));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_CUSTOMER_CODE, cstrCallCustomerCode));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_CUSTOMER_NAME, cstrCallCustomerName));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_CUSTOMER_TYPE, cstrCallCustomerType));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_MARKET, cstrCallMarket));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_STATUS, cstrCallStatus));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_DATE, cstrCallDate));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_STR_TIME, cstrCallStartTime));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_END_TIME, cstrCallEndTime));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_ORDER_SEND, cstrCallOrderSend));
      objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_CALL_STOCK_DIST_COUNT, cstrCallStockDistributionCount));
      
      //
      // Call stock properties
      //
      for (int i=0; i<cobjCallStocks.size(); i++) {
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_STCK_ITEM, ""));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_STCK_ITEM_ID, ((cRouteStock)cobjCallStocks.elementAt(i)).getId()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_STCK_ITEM_NAME, ((cRouteStock)cobjCallStocks.elementAt(i)).getName()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_STCK_ITEM_REQUIRED, ((cRouteStock)cobjCallStocks.elementAt(i)).getRequired()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_STCK_ITEM_QTY, ((cRouteStock)cobjCallStocks.elementAt(i)).getStockQty()));
      }
      
      //
      // Call stock properties
      //
      for (int i=0; i<cobjCallOrders.size(); i++) {
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM, ""));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_ID, ((cRouteOrder)cobjCallOrders.elementAt(i)).getId()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_NAME, ((cRouteOrder)cobjCallOrders.elementAt(i)).getName()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_PRICE_TDU, ((cRouteOrder)cobjCallOrders.elementAt(i)).getPriceTDU()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_PRICE_MCU, ((cRouteOrder)cobjCallOrders.elementAt(i)).getPriceMCU()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_PRICE_RSU, ((cRouteOrder)cobjCallOrders.elementAt(i)).getPriceRSU()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_BRAND, ((cRouteOrder)cobjCallOrders.elementAt(i)).getBrand()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_PACKSIZE, ((cRouteOrder)cobjCallOrders.elementAt(i)).getPacksize()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_REQUIRED, ((cRouteOrder)cobjCallOrders.elementAt(i)).getRequired()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_UOM, ((cRouteOrder)cobjCallOrders.elementAt(i)).getOrderUom()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_QTY, ((cRouteOrder)cobjCallOrders.elementAt(i)).getOrderQty()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ORDR_ITEM_VALUE, ((cRouteOrder)cobjCallOrders.elementAt(i)).getOrderValue()));
      }

      //
      // Call display properties
      //
      for (int i=0; i<cobjCallDisplays.size(); i++) {
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_DISP_ITEM, ""));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_DISP_ITEM_ID, ((cRouteDisplay)cobjCallDisplays.elementAt(i)).getId()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_DISP_ITEM_NAME, ((cRouteDisplay)cobjCallDisplays.elementAt(i)).getName()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_DISP_ITEM_FLAG, ((cRouteDisplay)cobjCallDisplays.elementAt(i)).getFlag()));
      }

      //
      // Customer activity properties
      //
      for (int i=0; i<cobjCallActivities.size(); i++) {
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ACTV_ITEM, ""));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ACTV_ITEM_ID, ((cRouteActivity)cobjCallActivities.elementAt(i)).getId()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ACTV_ITEM_NAME, ((cRouteActivity)cobjCallActivities.elementAt(i)).getName()));
         objDataValues.addElement(new cDataValue(cMailbox.EFEX_RTE_ACTV_ITEM_FLAG, ((cRouteActivity)cobjCallActivities.elementAt(i)).getFlag()));
      }
      
      //
      // Set the data store record values
      //
      super.cintRecordId = cintCallId;
      super.setRecord(objDataValues);
      
      //
      // Release the customer
      //
      cintCallId = 0;
        
   }
   
   /**
    * Deletes the call data model from the data store
    * 
    * @throws Exception the exception message
    */
   public void deleteCallModel() throws Exception {
      super.cintRecordId = cintCallId;
      super.deleteRecord();
      cintCallId = 0;
   }
   
   /**
    * Gets the customer list from the data store
    * 
    * @return java.util.Vector the customer listing
    * @throws Exception the exception message
    */
   public java.util.Vector getRouteList() throws Exception {
      
      //
      // Local variable declarations
      //
      java.util.Vector objRouteList;
      char[] chrListFields;
      java.util.Vector objDataValues;
      cDataValue objDataValue = null;
      Object objObject = null;
      
      //
      // Retrieve the data values from the data store and load the data model
      //
      objRouteList = new java.util.Vector();
      chrListFields = new char[] {cMailbox.EFEX_RTE_CALL_SEQUENCE, cMailbox.EFEX_RTE_CALL_CUSTOMER_ID, cMailbox.EFEX_RTE_CALL_CUSTOMER_CODE, cMailbox.EFEX_RTE_CALL_CUSTOMER_NAME, cMailbox.EFEX_RTE_CALL_CUSTOMER_TYPE, cMailbox.EFEX_RTE_CALL_STATUS};
      objDataValues = super.getListing(cMailbox.EFEX_RTE_CALL, cMailbox.EFEX_RTE_CALL_SEQUENCE, chrListFields);
      if(objDataValues != null) {
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            switch (objDataValue.getDataCode()) {

               //
               // Customer properties
               //
               case cMailbox.EFEX_RTE_CALL: {
                  objObject = new cRouteList(Integer.parseInt(objDataValue.getDataValue()));
                  objRouteList.addElement(objObject);
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_SEQUENCE: {
                  ((cRouteList)objObject).setSequence(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_CUSTOMER_ID: {
                  ((cRouteList)objObject).setCustomerId(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_CUSTOMER_CODE: {
                  ((cRouteList)objObject).setCustomerCode(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_CUSTOMER_NAME: {
                  ((cRouteList)objObject).setCustomerName(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_CUSTOMER_TYPE: {
                  ((cRouteList)objObject).setCustomerType(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_RTE_CALL_STATUS: {
                  ((cRouteList)objObject).setStatus(objDataValue.getDataValue());
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
      sortVector(objRouteList);
      return objRouteList;
      
   }
   
   /**
    * Searches the data in the data store
    * 
    * @return boolean the search result
    * @throws Exception the exception message
    */
   public boolean searchRoute() throws Exception {
      return super.search();
   }
   
   /**
    * Call property getters
    */
   public int getCallId() {
      return cintCallId;
   }
   public String getCallCustomerId() {
      return cstrCallCustomerId;
   }
   public String getCallCustomerCode() {
      return cstrCallCustomerCode;
   }
   public String getCallCustomerName() {
      return cstrCallCustomerName;
   }
   public String getCallCustomerType() {
      return cstrCallCustomerType;
   }
   public String getCallMarket() {
      return cstrCallMarket;
   }
   public String getCallSequence() {
      return cstrCallSequence;
   }
   public String getCallStatus() {
      return cstrCallStatus;
   }
   public String getCallDate() {
      return cstrCallDate;
   }
   public String getCallStartTime() {
      return cstrCallStartTime;
   }
   public String getCallEndTime() {
      return cstrCallEndTime;
   }
   public String getCallOrderSend() {
      return cstrCallOrderSend;
   }
   public String getCallStockDistributionCount() {
      return cstrCallStockDistributionCount;
   }
   public java.util.Vector getCallStocks() {
      return cobjCallStocks;
   }
   public java.util.Vector getCallOrders() {
      return cobjCallOrders;
   }
   public java.util.Vector getCallDisplays() {
      return cobjCallDisplays;
   }
   public java.util.Vector getCallActivities() {
      return cobjCallActivities;
   }
   public java.util.Vector getOrderBrands() throws Exception {
      boolean bolFound;
      cRouteOrder objRouteOrder = null;
      cListValue objListValue = null;
      java.util.Vector objArray = new java.util.Vector();
      for (int i=0; i<cobjCallOrders.size(); i++) {
         bolFound = false;
         objRouteOrder = (cRouteOrder)cobjCallOrders.elementAt(i);
         for (int j=0; j<objArray.size(); j++) {
            objListValue = (cListValue)objArray.elementAt(j);
            if (objRouteOrder.getBrand().equals(objListValue.getCode())) {
               bolFound = true;
               break;
            }
         }
         if (!bolFound) {
            objArray.addElement(new cListValue(objRouteOrder.getBrand(), objRouteOrder.getBrand()));
         }
      }
      sortVector(objArray);
      return objArray;
   }
   public java.util.Vector getOrderPacksizes() throws Exception {
      boolean bolFound;
      cRouteOrder objRouteOrder = null;
      cListValue objListValue = null;
      java.util.Vector objArray = new java.util.Vector();
      for (int i=0; i<cobjCallOrders.size(); i++) {
         bolFound = false;
         objRouteOrder = (cRouteOrder)cobjCallOrders.elementAt(i);
         for (int j=0; j<objArray.size(); j++) {
            objListValue = (cListValue)objArray.elementAt(j);
            if (objRouteOrder.getPacksize().equals(objListValue.getCode())) {
               bolFound = true;
               break;
            }
         }
         if (!bolFound) {
            objArray.addElement(new cListValue(objRouteOrder.getPacksize(), objRouteOrder.getPacksize()));
         }
      }
      sortVector(objArray);
      return objArray;
   }
   public int[] getStockPointers() {
      int intSize = 0;
      for (int i=0; i<cobjCallStocks.size(); i++) {
         if (((cRouteStock)cobjCallStocks.elementAt(i)).getStockSelected()) {
            intSize++;
         }
      }
      int[] intPointers = new int[intSize];
      int intIndex = 0;
      for (int i=0; i<cobjCallStocks.size(); i++) {
         if (((cRouteStock)cobjCallStocks.elementAt(i)).getStockSelected()) {
            intPointers[intIndex] = i;
            intIndex++;
         }
      }
      return intPointers;
   }
   public int[] getOrderPointers() {
      int intSize = 0;
      for (int i=0; i<cobjCallOrders.size(); i++) {
         if (((cRouteOrder)cobjCallOrders.elementAt(i)).getOrderSelected()) {
            intSize++;
         }
      }
      int[] intPointers = new int[intSize];
      int intIndex = 0;
      for (int i=0; i<cobjCallOrders.size(); i++) {
         if (((cRouteOrder)cobjCallOrders.elementAt(i)).getOrderSelected()) {
            intPointers[intIndex] = i;
            intIndex++;
         }
      }
      return intPointers;
   }
   public int[] getOrderSelectPointers(String strBrand, String strPacksize) {
      int intSize = 0;
      boolean bolBrandSelect = false;
      boolean bolPacksizeSelect = false;
      cRouteOrder objRouteOrder = null;
      for (int i=0; i<cobjCallOrders.size(); i++) {
         objRouteOrder = (cRouteOrder)cobjCallOrders.elementAt(i);
         if (!objRouteOrder.getOrderSelected()) {
            bolBrandSelect = false;
            bolPacksizeSelect = false;
            if (strBrand.equals("*ALL") ||
                strBrand.equals(objRouteOrder.getBrand())) {
                bolBrandSelect = true;
            }
            if (strPacksize.equals("*ALL") ||
                strPacksize.equals(objRouteOrder.getPacksize())) {
                bolPacksizeSelect = true;
            }
            if (bolBrandSelect && bolPacksizeSelect) {
               intSize++;
            }
         }
      }
      int[] intPointers = new int[intSize];
      int intIndex = 0;   
      for (int i=0; i<cobjCallOrders.size(); i++) {
         objRouteOrder = (cRouteOrder)cobjCallOrders.elementAt(i);
         if (!objRouteOrder.getOrderSelected()) {
            bolBrandSelect = false;
            bolPacksizeSelect = false;
            if (strBrand.equals("*ALL") ||
                strBrand.equals(objRouteOrder.getBrand())) {
                bolBrandSelect = true;
            }
            if (strPacksize.equals("*ALL") ||
                strPacksize.equals(objRouteOrder.getPacksize())) {
                bolPacksizeSelect = true;
            }
            if (bolBrandSelect && bolPacksizeSelect) {
               intPointers[intIndex] = i;
               intIndex++;
            }
         }
      }
      objRouteOrder = null;
      return intPointers;
   }
   
   /**
    * Call property setters
    */
   public void setCallOrderSend(String strValue) {
      cstrCallOrderSend = strValue;
   }
   public void setCallStockDistributionCount(String strValue) {
      cstrCallStockDistributionCount = strValue;
   }
   public void setCallCalled() {
      cstrCallStatus = "1";
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
   public void addCustomerIdFilter(String strValue) {
      super.addFilter(cMailbox.EFEX_RTE_CALL_CUSTOMER_ID, strValue);
   }
   
   /**
    * Add customer code filter
    *
    * @param String the customer code
    */
   public void addCustomerCodeFilter(String strValue) {
      super.addFilter(cMailbox.EFEX_RTE_CALL_CUSTOMER_CODE, strValue);
   }

}
