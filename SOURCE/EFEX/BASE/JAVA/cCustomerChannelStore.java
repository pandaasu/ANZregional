/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cCustomerChannelStore
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application customer channel object model layer. The
 * object model implements the data mapping between the low level data store and
 * the high level data object model. The MIDlet application always interacts with
 * this data object model.
 */
public final class cCustomerChannelStore extends cDataStore {
   
   /**
    * Constructs a new instance
    */
   public cCustomerChannelStore() {
      super.cstrDataStore = "EfexCustomerChannel";
      super.cchrRecord = cMailbox.EFEX_CUS_TRADE_CHANNEL;
   }
   
   /**
    * Loads the data store from the string buffer
    * 
    * @param String the data store string buffer
    * @throws Exception the exception message
    */
   public void loadDataStore(String objBuffer) throws Exception {
      super.setDataStore(objBuffer, true);
   } 
   
   /**
    * Gets the data list from the data store
    * 
    * @return java.util.Vector the customer listing
    * @throws Exception the exception message
    */
   public java.util.Vector getDataList() throws Exception {
      
      //
      // Local variable declarations
      //
      java.util.Vector objList;
      char[] chrListFields;
      java.util.Vector objDataValues;
      cDataValue objDataValue = null;
      Object objObject = null;
      
      //
      // Retrieve the data values from the data store and load the data model
      //
      objList = new java.util.Vector();
      chrListFields = new char[] {cMailbox.EFEX_CUS_TRADE_CHANNEL_ID, cMailbox.EFEX_CUS_TRADE_CHANNEL_NAME};
      objDataValues = super.getListing(cMailbox.EFEX_CUS_TRADE_CHANNEL, cMailbox.EFEX_CUS_TRADE_CHANNEL_NAME, chrListFields);
      if(objDataValues != null) {
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            switch (objDataValue.getDataCode()) {
               case cMailbox.EFEX_CUS_TRADE_CHANNEL: {
                  objObject = new cCustomerChannelList(Integer.parseInt(objDataValue.getDataValue()));
                  objList.addElement(objObject);
                  break;
               }
               case cMailbox.EFEX_CUS_TRADE_CHANNEL_ID: {
                  ((cCustomerChannelList)objObject).setId(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_CUS_TRADE_CHANNEL_NAME: {
                  ((cCustomerChannelList)objObject).setName(objDataValue.getDataValue());
                  break;
               }
               default: {
                  break;
               }
            } 
         }
      }
      sortVector(objList);
      return objList;
      
   }
   
   /**
    * Clear the data store filters
    */
   public void clearFilters() {
      super.clearFilters();
   }

}
