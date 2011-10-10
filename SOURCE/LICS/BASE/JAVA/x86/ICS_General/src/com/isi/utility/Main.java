/*
 * Main.java
 *
 * Created on February 5, 2004, 8:20 AM
 */

package com.isi.utility;
import java.io.*;

/**
 *
 * @author  Steve Gregan
 */
public class Main {
   
   /** Creates a new instance of Main */
   public Main() {
   }
   
   /**
    * @param args the command line arguments
    */
   public static void main(String[] args) {
      
      //
      // Run the main
      //
      try {
         Documentation.retrieveDocumentation("LADS_APP","LADS_ATLLAD04_MONITOR","PACKAGE");
         System.out.println("finito");
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.err.println(objStringWriter.getBuffer().toString());
      }
         
   }
   
}
