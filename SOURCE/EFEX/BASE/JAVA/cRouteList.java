/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cRouteList
 * Author  : Steve Gregan
 * Date    : April 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application customer list.
 */
public final class cRouteList extends cSortable {
   
   //
   // Instance private declarations
   //
   private int cintRecordId;
   private String cstrSequence;
   private String cstrCustomerId;
   private String cstrCustomerCode;
   private String cstrCustomerName;
   private String cstrCustomerType;
   private String cstrStatus;
   private String cstrSortValue;

   /**
    * Constructs a new instance
    */
   public cRouteList(int intRecordId) {
      cintRecordId = intRecordId;
      cstrSequence = null;
      cstrCustomerId = null;
      cstrCustomerCode = null;
      cstrCustomerName = null;
      cstrCustomerType = null;
      cstrStatus = "0";
      cstrSortValue = null;
   }
   
   /**
    * Override the cSortable abstract methods
    */
   public String getSortValue() {
      if (cstrSortValue != null) {
         return cstrSortValue;
      }
      return new String(cstrSequence + cstrCustomerName);
   }
   public void setSortValue(String strValue) {
      cstrSortValue = strValue;
   }
   
   /**
    * Property setters
    */
   public void setSequence(String strValue) {
      cstrSequence = strValue;
   }
   public void setCustomerId(String strValue) {
      cstrCustomerId = strValue;
   }
   public void setCustomerCode(String strValue) {
      cstrCustomerCode = strValue;
   }
   public void setCustomerName(String strValue) {
      cstrCustomerName = strValue;
   }
   public void setCustomerType(String strValue) {
      cstrCustomerType = strValue;
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
   public String getSequence() {
      return cstrSequence;
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
   public String getCustomerType() {
      return cstrCustomerType;
   }
   public String getStatus() {
      return cstrStatus;
   }
    
}
