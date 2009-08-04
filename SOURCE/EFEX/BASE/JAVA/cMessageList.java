/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cMessageList
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application message list.
 */
public final class cMessageList extends cSortable {
   
   //
   // Instance private declarations
   //
   private int cintRecordId;
   private String cstrMessageId;
   private String cstrOwner;
   private String cstrTitle;
   private String cstrStatus;

   /**
    * Constructs a new instance
    */
   public cMessageList(int intRecordId) {
      cintRecordId = intRecordId;
      cstrMessageId = null;
      cstrOwner = null;
      cstrTitle = null;
      cstrStatus = "0";
   }
   
   /**
    * Override the cSortable abstract methods
    */
   public String getSortValue() {
      return new String(cstrStatus + cstrOwner);
   }
   
   /**
    * Property setters
    */
   public void setMessageId(String strValue) {
      cstrMessageId = strValue;
   }
   public void setOwner(String strValue) {
      cstrOwner = strValue;
   }
   public void setTitle(String strValue) {
      cstrTitle = strValue;
   }
   public void setStatus(String strValue) {
      cstrStatus = strValue;
   }
   
   /**
    * Property getters
    */
   public int getRecordId() {
      return cintRecordId;
   }
   public String getMessageId() {
      return cstrMessageId;
   }
   public String getOwner() {
      return cstrOwner;
   }
   public String getTitle() {
      return cstrTitle;
   }
   public String getStatus() {
      return cstrStatus;
   }
   
}
