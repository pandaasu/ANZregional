/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cDataFilter
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application data filter.
 */
public final class cDataFilter {
   
   //
   // Instance private declarations
   //
   private char cchrFilterCode;
   private String cstrFilterValue;
   private boolean cbolFilterFound;
   
   /**
    * Constructs a new instance
    */
   public cDataFilter(char chrFilterCode, String strFilterValue) {
      cchrFilterCode = chrFilterCode;
      cstrFilterValue = strFilterValue;
      cbolFilterFound = false;
   }
   
   /**
    * Property setters
    */
   public void setFilterFound(boolean bolValue) {
      cbolFilterFound = bolValue;
   }
   
   /**
    * Property getters
    */
   public char getFilterCode() {
      return cchrFilterCode;
   }
   public String getFilterValue() {
      return cstrFilterValue;
   }
   public boolean getFilterFound() {
      return cbolFilterFound;
   }
 
}
