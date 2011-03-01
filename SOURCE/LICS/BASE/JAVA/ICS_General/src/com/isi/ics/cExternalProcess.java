/**
 * System : Interface Control System
 * Type   : Class
 * Name   : cExternalProcess
 * Author : Steve Gregan
 * Date   : February 2011
 */
package com.isi.ics;
import java.io.*;

/**
 * This class implements the external process functionality.
 * This functionality supports the execution of external operating
 * system commands and scripts. Standard in and error are wrapped
 * and raised as an exception the the calling procedure. The
 * assumption is made that this is always executed from inside oracle.
 */
public final class cExternalProcess {
   
   //
   // Class static variables
   //
   private static char cchrSpace = ' ';
   private static char cchrQuote = '"';
   
   /**
    * Peeks at the character in the character array
    * 
    * @param chrArray the character array
    * @param intIndex the character array index
    * @return char the next character
    */
   private char peekArray(char[] chrArray, int intIndex) {
      if (intIndex > chrArray.length - 1) {
         return cchrSpace;
      }
      if (intIndex < 0) {
         return cchrSpace;
      }
      return chrArray[intIndex];
   }
   
   /**
    * Adds a token to the end of the token array
    * 
    * @param objTokens the original token array
    * @param objToken the token to be added
    * @return String[] the new tokens array
    */
   private String[] addToken(String[] objTokens, String objToken) {
      String[] objTemporary;
      try {
         objTemporary = new String[objTokens.length + 1];
         if (objTokens.length > 0) {
            System.arraycopy(objTokens, 0, objTemporary, 0, objTokens.length);
         }
         objTemporary[objTokens.length] = objToken;
         return objTemporary;
      } finally {
         objTemporary = null;
      }
   }
   
   /**
    * Executes the external procedure/function
    * 
    * @param strCommand the command string to execute
    * @return String the standard output from the external process
    * @exception Exception the exceptions including the standard error from the external process
    */
   private String execute(String objCommand) throws Exception {
      
      //
      // Local declarations
      //
      Process objProcess = null;
      StringBuffer objInputBuffer = null;
      BufferedReader objInputReader = null;
      StringBuffer objErrorBuffer = null;
      BufferedReader objErrorReader = null;
      String objReturn = null;
      StringBuffer objWork = null;
      String[] objTokens = null;
      char[] chrCommand = null;
      boolean bolQuoted;
      boolean bolSkip;
      StringWriter objStringWriter = null;
      PrintWriter objPrintWriter = null;

      //
      // Exceptions trap
      //
      try {
         
         //
         // Throw the empty command exception when required
         //
         if (objCommand.equals("")) {
            throw new Exception("Empty command string not allowed");
         }
         
         //
         // Build the command array from the passed string
         // **notes** 1. Space delimited
         //           2. Double quote delimited
         //
         objWork = new StringBuffer();
         objTokens = new String[0];
         chrCommand = objCommand.toCharArray();
         bolQuoted = false;
         bolSkip = false;
         for (int i=0; i<chrCommand.length; i++) {
            if (bolQuoted) {
               if (bolSkip) {
                  bolSkip = false;
               } else {
                  if (chrCommand[i] == cchrQuote) {
                     if (peekArray(chrCommand, i+1) == cchrSpace) {
                        bolQuoted = false;
                     } else {
                        objWork.append(chrCommand[i]);
                        if (peekArray(chrCommand, i+1) == cchrQuote) {
                           bolSkip = true;
                        } else {
                           throw new Exception("Single quotes within quoted string must be doubled");
                        }
                     }
                  } else {
                     objWork.append(chrCommand[i]);
                  }
               }
            } else {
               if (chrCommand[i] == cchrQuote && peekArray(chrCommand, i-1) == cchrSpace) {
                  bolQuoted = true;
                  if (objWork.length() != 0) {
                     objTokens = addToken(objTokens, objWork.toString());
                  }
                  objWork.setLength(0);
               } else if (chrCommand[i] == cchrSpace) {
                  if (objWork.length() != 0) {
                     objTokens = addToken(objTokens, objWork.toString());
                  }
                  objWork.setLength(0);
               } else {
                  objWork.append(chrCommand[i]);
               }
            }
         }
         if (objWork.length() != 0) {
            objTokens = addToken(objTokens, objWork.toString());
         }
         if (bolQuoted) {
            throw new Exception("Quoted string not terminated");
         }
         
         //
         // Execute the external process using the command array
         //
         objProcess = Runtime.getRuntime().exec(objTokens);
         
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
            objReturn = objInputBuffer.toString() + "\r\n" + objErrorBuffer.toString();
            if (objReturn.length() > 4000) {
               objReturn = objReturn.substring(0,3999);
            }
            throw new Exception(objReturn);
         }
         
         //
         // Return the standard out from the external process
         //
         objReturn = objInputBuffer.toString();
         if (objReturn.length() > 4000) {
            objReturn = objReturn.substring(0,3999);
         }
         return objReturn;
  
      } catch(Throwable objThrowable) {
         objStringWriter = new StringWriter();
         objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         throw new Exception("EXECUTE EXTERNAL PROCESS EXCEPTION - " + objStringWriter.getBuffer().toString());
         
      } finally {
         objProcess = null;
         objInputBuffer = null;
         objInputReader = null;
         objErrorBuffer = null;
         objErrorReader = null;
         objReturn = null;
         objWork = null;
         objTokens = null;
         chrCommand = null;
         objStringWriter = null;
         objPrintWriter = null;
      }
      
   }
      
   /**
    * Executes the external procedure
    * 
    * @param strCommand the command string to execute
    * @return void
    * @exception Exception the exceptions including the standard error from the external process
    */
   public static void executeProcedure(String objCommand) throws Exception {
      cExternalProcess objExternalProcess;
      try {
         objExternalProcess = new cExternalProcess();
         objExternalProcess.execute(objCommand);
      } finally {
         objExternalProcess = null;
      }
   }
   
   /**
    * Executes the external function
    * 
    * @param strCommand the command string to execute
    * @return String the standard output from the external process
    * @exception Exception the exceptions including the standard error from the external process
    */
   public static String executeFunction(String objCommand) throws Exception {
      cExternalProcess objExternalProcess;
      try {
         objExternalProcess = new cExternalProcess();
         return objExternalProcess.execute(objCommand);
      } finally {
         objExternalProcess = null;
      }
   }
   
}