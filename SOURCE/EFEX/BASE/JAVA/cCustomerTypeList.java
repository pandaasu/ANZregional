/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cCustomerTypeList
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application customer type list.
 */
public final class cCustomerTypeList extends cSortable {
   
   //
   // Instance private declarations
   //
   private int cintRecordId;
   private String cstrId;
   private String cstrName;
   private String cstrChannelId;
   
   /**
    * Constructs a new instance
    */
   public cCustomerTypeList(int intRecordId) {
      cintRecordId = intRecordId;
      cstrId = null;
      cstrName = null;
      cstrChannelId = null;
   }
   
   /**
    * Override the cSortable abstract methods
    */
   public String getSortValue() {
      return cstrId;
   }
   
   /**
    * Property setters
    */
   public void setId(String strValue) {
      cstrId = strValue;
   }
   public void setName(String strValue) {
      cstrName = strValue;
   }
   public void setChannelId(String strValue) {
      cstrChannelId = strValue;
   }
   
   /**
    * Property getters
    */
   public int getRecordId() {
      return cintRecordId;
   }
   public String getId() {
      return cstrId;
   }
   public String getName() {
      return cstrName;
   }
   public String getChannelId() {
      return cstrChannelId;
   }
   
}
