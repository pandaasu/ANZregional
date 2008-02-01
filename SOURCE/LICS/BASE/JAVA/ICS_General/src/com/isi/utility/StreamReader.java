/**
 * System : ISI Utility
 * Type   : Class
 * Name   : StreamReader
 * Author : Steve Gregan
 * Date   : January 2004
 */
package com.isi.utility;
import java.io.*;

/**
 * This class implements the stream reader functionality.
 * This facility supports the execution of external operating
 * system commands and scripts. Standard in and error are wrapped
 * and raised as an exception the the calling procedure. The
 * assumption is made that this is always executed from inside oracle.
 */
public final class StreamReader extends Thread {
   
   //
   // Class declarations
   //
   InputStream cobjInputStream = null;
   StringBuffer cobjStringBuffer = null;
   
   /**
    * Constructor
    * 
    * @param objInputStream the input stream to read
    * @param objStringBuffer the result string buffer
    */
   public StreamReader(InputStream objInputStream, StringBuffer objStringBuffer) {
      this.cobjInputStream = objInputStream;
      this.cobjStringBuffer = objStringBuffer;
   }

   public void run() {
      try {
         BufferedReader objInputReader = new BufferedReader(new InputStreamReader(cobjInputStream));
         String objLine = null;
         while((objLine = objInputReader.readLine()) != null) {
            if (cobjStringBuffer.length() > 0) {
               cobjStringBuffer.append("\r\n");
            }
            cobjStringBuffer.append(objLine);
         }
         objInputReader.close();
      } catch (IOException objException) {
         System.out.println("xxxx");
         objException.printStackTrace();
      }
   }

}
