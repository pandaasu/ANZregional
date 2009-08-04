/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cRouteOrder
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application route order object data layer.
 */
public final class cRouteOrder extends cSortable {
   
   //
   // Instance private declarations
   //
   private String cstrId;
   private String cstrName;
   private String cstrPriceTDU;
   private String cstrPriceMCU;
   private String cstrPriceRSU;
   private String cstrBrand;
   private String cstrPacksize;
   private String cstrRequired;
   private String cstrOrderUom;
   private String cstrOrderQty;
   private String cstrOrderValue;
   private boolean cbolOrderSelected;

   /**
    * Constructs a new instance
    */
   public cRouteOrder() {
      cstrId = null;
      cstrName = null;
      cstrPriceTDU = "0";
      cstrPriceMCU = "0";
      cstrPriceRSU = "0";
      cstrBrand = "";
      cstrPacksize = "";
      cstrRequired = "N";
      cstrOrderUom = "RSU";
      cstrOrderQty = "0";
      cstrOrderValue = "0";
      cbolOrderSelected = false;
   }
   
   /**
    * Override the cSortable abstract methods
    */
   public String getSortValue() {
      String strSort = "1";
      if (cstrRequired.equals("Y")) {
         strSort = "0";
      }
      strSort = strSort + cstrName;
      return strSort;
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
   public void setPriceTDU(String strValue) {
      cstrPriceTDU = strValue;
      if (cstrPriceTDU.equals("")) {
         cstrPriceTDU = "0";
      }
   }
   public void setPriceMCU(String strValue) {
      cstrPriceMCU = strValue;
      if (cstrPriceMCU.equals("")) {
         cstrPriceMCU = "0";
      }
   }
   public void setPriceRSU(String strValue) {
      cstrPriceRSU = strValue;
      if (cstrPriceRSU.equals("")) {
         cstrPriceRSU = "0";
      }
   }
   public void setBrand(String strValue) {
      cstrBrand = strValue;
   }
   public void setPacksize(String strValue) {
      cstrPacksize = strValue;
   }
   public void setRequired(String strValue) {
      cstrRequired = strValue;
      if (cstrRequired.equals("")) {
         cstrRequired = "N";
      }
   }
   public void setOrderUom(String strValue) {
      cstrOrderUom = strValue;
      if (cstrOrderUom.equals("")) {
         cstrOrderUom = "TDU";
      }
   }
   public void setOrderQty(String strValue) {
      cstrOrderQty = strValue;
      if (cstrOrderQty.equals("")) {
         cstrOrderQty = "0";
      }
   }
   public void setOrderValue(String strValue) {
      cstrOrderValue = strValue;
      if (cstrOrderValue.equals("")) {
         cstrOrderValue = "0";
      }
   }
   public void setOrderSelected(boolean bolValue) {
      cbolOrderSelected = bolValue;
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
   public String getPriceTDU() {
      return cstrPriceTDU;
   }
   public String getPriceMCU() {
      return cstrPriceMCU;
   }
   public String getPriceRSU() {
      return cstrPriceRSU;
   }
   public String getBrand() {
      return cstrBrand;
   }
   public String getPacksize() {
      return cstrPacksize;
   }
   public String getRequired() {
      return cstrRequired;
   }
   public String getOrderUom() {
      return cstrOrderUom;
   }
   public String getOrderQty() {
      return cstrOrderQty;
   }
   public String getOrderValue() {
      return cstrOrderValue;
   }
   public boolean getOrderSelected() {
      return cbolOrderSelected;
   }
   
}
