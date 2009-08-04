/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cRouteStock
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application route stock object data layer.
 */
public final class cRouteStock extends cSortable {
   
   //
   // Instance private declarations
   //
   private String cstrId;
   private String cstrName;
   private String cstrRequired;
   private String cstrStockQty;
   private boolean cbolStockSelected;

   /**
    * Constructs a new instance
    */
   public cRouteStock() {
      cstrId = null;
      cstrName = null;
      cstrRequired = "N";
      cstrStockQty = "0";
      cbolStockSelected = false;
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
   public void setId(String strValue) {
      cstrId = strValue;
   }
   public void setName(String strValue) {
      cstrName = strValue;
   }
   public void setRequired(String strValue) {
      cstrRequired = strValue;
      if (cstrRequired.equals("")) {
         cstrRequired = "N";
      }
   }
   public void setStockQty(String strValue) {
      cstrStockQty = strValue;
      if (cstrStockQty.equals("")) {
         cstrStockQty = "0";
      }
   }
   public void setStockSelected(boolean bolValue) {
      cbolStockSelected = bolValue;
   }
   
   /**
    * Property getters
    */
   public String getId() {
      return cstrId;
   }
   public String getName() {
      return cstrName;
   }
   public String getRequired() {
      return cstrRequired;
   }
   public String getStockQty() {
      return cstrStockQty;
   }
   public boolean getStockSelected() {
      return cbolStockSelected;
   }
   
}
