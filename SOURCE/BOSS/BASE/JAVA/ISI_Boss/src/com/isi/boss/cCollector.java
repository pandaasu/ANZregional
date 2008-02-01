/**
 * Package : ISI Distribution
 * Type    : Class
 * Name    : cTransformAction
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.boss;
import java.util.*;
import java.io.*;

/**
 * This class implements the transform action functionality.
 */
public class cCollector {
   
   //
   // Instance private declarations
   //
   private String cstrAgent;
   private String cstrObject;
   private HashMap cobjAttributes;

   /**
    * Constructs a new instance
    * 
    * @param strParameters the collector parameter array
    * @param objAttributes the collector attributes map
    */
   public cCollector(String[] strParameters, HashMap objAttributes) {
      cstrAgent = strParameters[0];
      cstrObject = strParameters[1];
      cobjAttributes = objAttributes;
   }
   
   /**
    * Processes the collector
    *
    * @param objConfiguration the configuration reference
    * @throws Exception the exception message
    */
   public void process(cConfiguration objConfiguration) throws Exception {
      objConfiguration.processCollector(cstrAgent, cstrObject, cobjAttributes);  
   }

}