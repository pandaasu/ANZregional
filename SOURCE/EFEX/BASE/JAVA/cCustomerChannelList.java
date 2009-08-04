/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cCustomerChannelList
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application customer channel list.
 */
public final class cCustomerChannelList extends cSortable {
   
   //
   // Instance private declarations
   //
   private int cintRecordId;
   private String cstrId;
   private String cstrName;
   
   /**
    * Constructs a new instance
    */
   public cCustomerChannelList(int intRecordId) {
      cintRecordId = intRecordId;
      cstrId = null;
      cstrName = null;
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
   
}
