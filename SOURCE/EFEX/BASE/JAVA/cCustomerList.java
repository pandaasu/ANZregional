/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cCustomerList
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application customer list.
 */
public final class cCustomerList extends cSortable {
   
   //
   // Instance private declarations
   //
   private int cintRecordId;
   private String cstrDataType;
   private String cstrDataAction;
   private String cstrStatus;
   private String cstrCustomerId;
   private String cstrCode;
   private String cstrName;

   /**
    * Constructs a new instance
    */
   public cCustomerList(int intRecordId) {
      cintRecordId = intRecordId;
      cstrDataType = null;
      cstrDataAction = null;
      cstrStatus = null;
      cstrCustomerId = null;
      cstrCode = null;
      cstrName = null;
   }
   
   /**
    * Override the cSortable abstract methods
    */
   public String getSortValue() {
      return new String(cstrCode + cstrName);
   }
   
   /**
    * Property setters
    */
   public void setDataType(String strValue) {
      cstrDataType = strValue;
   }
   public void setDataAction(String strValue) {
      cstrDataAction = strValue;
   }
   public void setStatus(String strValue) {
      cstrStatus = strValue;
   }
   public void setCustomerId(String strValue) {
      cstrCustomerId = strValue;
   }
   public void setCode(String strValue) {
      cstrCode = strValue;
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
   public String getDataType() {
      return cstrDataType;
   }
   public String getDataAction() {
      return cstrDataAction;
   }
   public String getStatus() {
      return cstrStatus;
   }
   public String getCustomerId() {
      return cstrCustomerId;
   }
   public String getCode() {
      return cstrCode;
   }
   public String getName() {
      return cstrName;
   }
   
}
