/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cCustomerList
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application customer location list.
 */
public final class cCustomerLocationList extends cSortable {
   
   //
   // Instance private declarations
   //
   private int cintRecordId;
   private String cstrName;
   private String cstrText;
   
   /**
    * Constructs a new instance
    */
   public cCustomerLocationList(int intRecordId) {
      cintRecordId = intRecordId;
      cstrName = null;
      cstrText = null;
   }
   
   /**
    * Override the cSortable abstract methods
    */
   public String getSortValue() {
      return cstrName;
   }
   
   /**
    * Property setters
    */
   public void setName(String strValue) {
      cstrName = strValue;
   }
   public void setText(String strValue) {
      cstrText = strValue;
   }
   
   /**
    * Property getters
    */
   public int getRecordId() {
      return cintRecordId;
   }
   public String getName() {
      return cstrName;
   }
   public String getText() {
      return cstrText;
   }
   
}
