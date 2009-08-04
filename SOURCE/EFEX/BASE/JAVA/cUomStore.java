/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cUomStore
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application uom object model layer. The
 * object model implements the data mapping between the low level data store and
 * the high level data object model. The MIDlet application always interacts with
 * this data object model.
 */
public final class cUomStore extends cDataStore {
   
   /**
    * Constructs a new instance
    */
   public cUomStore() {
      super.cstrDataStore = "EfexUom";
      super.cchrRecord = cMailbox.EFEX_UOM;
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
      chrListFields = new char[] {cMailbox.EFEX_UOM_NAME, cMailbox.EFEX_UOM_TEXT};
      objDataValues = super.getListing(cMailbox.EFEX_UOM, cMailbox.EFEX_UOM_TEXT, chrListFields);
      if(objDataValues != null) {
         for (int i=0; i<objDataValues.size(); i++) {
            objDataValue = (cDataValue)objDataValues.elementAt(i);
            switch (objDataValue.getDataCode()) {
               case cMailbox.EFEX_UOM: {
                  objObject = new cUomList(Integer.parseInt(objDataValue.getDataValue()));
                  objList.addElement(objObject);
                  break;
               }
               case cMailbox.EFEX_UOM_NAME: {
                  ((cUomList)objObject).setName(objDataValue.getDataValue());
                  break;
               }
               case cMailbox.EFEX_UOM_TEXT: {
                  ((cUomList)objObject).setText(objDataValue.getDataValue());
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
