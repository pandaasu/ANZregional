/**
 * Package : ISI SIMULATION
 * Type    : Class
 * Name    : cExecution
 * Author  : Steve Gregan
 * Date    : January 2006
 */
package com.isi.simulation;
import java.util.*;
import java.io.*;

/**
 * This class implements the operating system caller
 */
public class cExecution implements Comparable {
   
   //
   // Instance private declarations
   //
   private String cstrInterface;
   private long clngDelay;
   private String[] cobjTokens;
   
   
   /**
    * Constructs a new instance
    * 
    * @param strInterface the event interface name
    * @param lngDelay the execution millisecond delay from the simulation start
    * @param objTokens the operating system call token array
    */
   public cExecution(String strInterface, long lngDelay, String[] objTokens) {
      cstrInterface = strInterface;
      clngDelay = lngDelay;
      cobjTokens = objTokens;
   }
   
   /**
    * Retrieves the execution interface name
    *
    * @return String the parent event interface name
    */
   public String getInterface() {
      return cstrInterface;
   }
   
   /**
    * Retrieves the execution delay in milliseconds
    *
    * @return long the execution delay in milliseconds
    */
   public long getDelay() {
      return clngDelay;
   }
   
   /**
    * Executes the operating system call
    *
    * @param strProcessName the process name performing the execution
    * @throws Exception the exception message
    */
   public void execute(String strProcessName) throws Exception {
      
      //
      // Local declarations
      //
      Process objProcess = null;
      StringBuffer objInputBuffer = null;
      BufferedReader objInputReader = null;
      StringBuffer objErrorBuffer = null;
      BufferedReader objErrorReader = null;
      String objReturn = null;
      
      //
      // Set the process name in the token array
      //
      cobjTokens[1] = strProcessName;
      
      //
      // Execute the external process using the token array
      //
      objProcess = Runtime.getRuntime().exec(cobjTokens);
      
      //
      // Retrieve any standard out and error information from the external process
      //
      objInputBuffer = new StringBuffer();
      objInputReader = new BufferedReader(new InputStreamReader(objProcess.getInputStream()));
      while((objReturn = objInputReader.readLine()) != null) {
         if (objInputBuffer.length() > 0) {
            objInputBuffer.append("\r\n");
         }
         objInputBuffer.append(objReturn);
      }
      objInputReader.close();

      objErrorBuffer = new StringBuffer();
      objErrorReader = new BufferedReader(new InputStreamReader(objProcess.getErrorStream()));
      while((objReturn = objErrorReader.readLine()) != null) {
         if (objErrorBuffer.length() > 0) {
            objErrorBuffer.append("\r\n");
         }
         objErrorBuffer.append(objReturn);
      }
      objErrorReader.close();
      
      //
      // Wait for the external process to complete
      //
      int intReturn = objProcess.waitFor();
      if (intReturn != 0) {
         objReturn = objInputBuffer.toString();
         if (objErrorBuffer.length() > 0) {
            objReturn = objReturn + "\r\n" + objErrorBuffer.toString();
         }
         if (objReturn.length() > 4000) {
            objReturn = objReturn.substring(0,3999);
         }
         throw new Exception(objReturn);
      }
         
   }
   
   /**
    * Comparable interface implementation
    */
   public int compareTo(Object objObject) {
      if (this.clngDelay < ((cExecution)objObject).getDelay()) {
         return -1;
      } else if (this.clngDelay > ((cExecution)objObject).clngDelay) {
         return 1;
      }
      return 0;
   }
 
}