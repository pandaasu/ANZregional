/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cResourceBundle
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;
import java.util.Hashtable;

/**
 * This class implements the Efex application resource bundle abstract class. The
 * resource bundle implements the resource string storage and retrieval to allow
 * internationalization of the application. This implementation is required as
 * the majority of mobile devices do not yet implement the JSR238 specification
 * for internationalization.
 */
public abstract class cResourceBundle {
   
   //
   // Instance private constants
   //
   protected Hashtable objResourceStore = new java.util.Hashtable();
   
   /**
    * Property getters
    */
   public String getResource(String strKey) {
        return (String)objResourceStore.get(strKey);
    }

}
