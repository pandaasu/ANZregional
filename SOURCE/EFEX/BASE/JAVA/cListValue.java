/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cListValue
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application list value.
 */
public final class cListValue extends cSortable {
   
   //
   // Instance private declarations
   //
   private String cstrCode;
   private String cstrText;

   /**
    * Constructs a new instance
    */
   public cListValue(String strCode, String strText) {
      cstrCode = strCode;
      cstrText = strText;
   }
   
   /**
    * Override the cSortable abstract methods
    */
   public String getSortValue() {
      return cstrCode;
   }
   
   /**
    * Property getters
    */
   public String getCode() {
      return cstrCode;
   }
   public String getText() {
      return cstrText;
   }
   
}
