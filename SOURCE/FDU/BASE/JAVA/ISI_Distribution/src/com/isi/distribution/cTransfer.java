/**
 * Package : ISI Distribution
 * Type    : Class
 * Name    : cTransfer
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.distribution;
import java.util.*;
import java.io.*;

/**
 * This class implements the distribution transfer functionality.
 */
public class cTransfer {
   
   //
   // Instance private declarations
   //
   private static char cchrSpace = ' ';
   private static char cchrQuote = '"';
   private String cstrCode;
   private String cstrText;
   private String cstrScript;

   /**
    * Constructs a new instance
    * 
    * @param strParameters the transfer parameter array
    */
   public cTransfer(String[] strParameters) {
      cstrCode = strParameters[0];
      cstrText = strParameters[1];
      cstrScript = strParameters[2];
   }
   
   /**
    * Gets the transfer script
    *
    * @return String a copy of the transfer script
    */
   public String getScript() {
      return new String(cstrScript);
   }
   
   /**
    * Processes the distribution transfer using the supplied configuration.
    *
    * @param strOutputFile the transfer file
    * @param strScript the transfer script
    * @return String the return value
    * @throws Exception the exception message
    */
   public String process(String strOutputFile, String strScript) throws Exception {
      
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
      
      //
      // Process the transfer
      //
      try {
      
         //
         // Build the command array from the passed string
         // **notes** 1. Space delimited
         //           2. Double quote delimited
         //
         objWork = new StringBuffer();
         objTokens = new String[0];
         chrCommand = strScript.toCharArray();
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
         // Execute the external process using the token array
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
            objReturn = objInputBuffer.toString();
            if (objErrorBuffer.length() > 0) {
               objReturn = objReturn + "\r\n" + objErrorBuffer.toString();
            }
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
      
      } catch(Exception objException) {
         throw new Exception("Transfer (" + cstrCode + ") - " + objException.getMessage());
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
      }
      
   }
   
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

}