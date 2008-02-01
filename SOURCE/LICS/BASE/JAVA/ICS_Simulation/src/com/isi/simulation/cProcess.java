/**
 * Package : ISI SIMULATION
 * Type    : Class
 * Name    : cProcess
 * Author  : Steve Gregan
 * Date    : January 2006
 */
package com.isi.simulation;
import java.lang.*;
import java.util.*;

/**
 * This class implements the process
 */
public class cProcess implements Runnable {

   //
   // Instance private declarations
   //
   private String cstrName;
   private cSimulator cobjSimulator;
   private volatile Thread cobjThread;
   
   /**
    * Constructs a new instance
    * 
    * @param strName the name of the process
    * @param objSimulator the parent simulator reference
    * @param objEvent the simulation array list
    */
   public cProcess(String strName, cSimulator objSimulator) {
      cstrName = strName;
      cobjSimulator = objSimulator;
      cobjThread = null;
   }
   
   /**
    * Starts the process
    * **note** this method must be called from outside the class
    */
   public void start() {
      if (cobjThread == null) {
         cobjThread = new Thread(this, cstrName);
         cobjThread.start();
      }
   }
   
   /**
    * Stops the process
    * **note** this method must be called from outside the class
    */
   public void stop() {
      cobjThread = null;
   }
   
   /**
    * Checks the thread active state
    *
    * @return boolean the thread active state
    */
   public boolean isActive() {
      if (cobjThread == null) {
         return false;
      }
      return true;
   }
   
   /**
    * Runnable interface implementation
    */
   public void run() {
      Thread objThread = Thread.currentThread();
      while (cobjThread == objThread) {
         try {
            cExecution objExecution = cobjSimulator.getNextExecution();
            if (objExecution != null) {
               objExecution.execute(cstrName);
            }
            try {
               Thread.sleep(100);
            } catch (InterruptedException objException) {}
         } catch (Throwable objThrowable) {
            System.out.println(objThrowable.getMessage());
            cobjThread = null;
         }
      }
   }
   
}