/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cDataValue
 * Author  : Steve Gregan
 * Date    : April 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application data value.
 */
public final class cDataValue {
   
   //
   // Instance private declarations
   //
   private char cchrDataCode;
   private String cstrDataValue;
   
   /**
    * Constructs a new instance
    */
   public cDataValue(char chrDataCode, String strDataValue) {
      cchrDataCode = chrDataCode;
      cstrDataValue = strDataValue;
   }
   
   /**
    * Property getters
    */
   public char getDataCode() {
      return cchrDataCode;
   }
   public String getDataValue() {
      return cstrDataValue;
   }
   
}
