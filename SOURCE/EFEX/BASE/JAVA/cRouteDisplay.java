/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cRouteDisplay
 * Author  : Steve Gregan
 * Date    : April 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application customer display object data layer.
 */
public final class cRouteDisplay extends cSortable {
   
   //
   // Instance private declarations
   //
   private String cstrId;
   private String cstrName;
   private String cstrFlag;

   /**
    * Constructs a new instance
    */
   public cRouteDisplay() {
      cstrId = null;
      cstrName = null;
      cstrFlag = null;
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
   public void setFlag(String strValue) {
      cstrFlag = strValue;
      if (cstrFlag.equals("")) {
         cstrFlag = "0";
      }
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
   public String getFlag() {
      return cstrFlag;
   }
   
}
