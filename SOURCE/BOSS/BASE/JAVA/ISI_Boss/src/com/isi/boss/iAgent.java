/**
 * Package : ISI Boss
 * Type    : Interface
 * Name    : iAgent
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.boss;
import java.util.*;

/**
 * This interface defines the collector agent interface.
 * All classes register as an agent must implement this interface.
 */
public interface iAgent {

   /**
    * Performs the file transformation
    * 
    * @param objAttributes the collector attributes
    * @return String the colector output
    * @exception Exception the exception
    */
   public String retrieve(HashMap objAttributes) throws Exception;
   
}
